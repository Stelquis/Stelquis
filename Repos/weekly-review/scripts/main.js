const content = document.getElementById('content');
const page = document.getElementById('page');
const reportHead = document.querySelector('.report-head');
const saveStateEl = document.getElementById('saveState');
const archiveListEl = document.getElementById('archiveList');
const STORE_KEY = 'weeklyReviewReportsV2';
const THEME_DEFAULT = 'tundra';
const THEME_CONFIG = {
  tundra: {
    label: '有机苔原绿',
    className: 'theme-tundra',
    exportBg: '#FAF9F6',
    colors: ['#6B7B47','#8F9779','#B0805A','#C9B79C','#6E8B82','#9C8AA5','#A8743E','#7D8447'],
    scheduleBgMap: {'#6B7B47':'#E5EBD9','#B0805A':'#F1E2D2','#6E8B82':'#DDEBE7','#9C8AA5':'#E9E1ED','#8F9779':'#E8EBDD'},
    scheduleFallbackBg: '#ECE8DD'
  },
  prussian: {
    label: '深邃普鲁士',
    className: 'theme-prussian',
    exportBg: '#FFFFFF',
    colors: ['#003366','#1B2A41','#2F5F8F','#5C7896','#C5A47E','#8A6F4D','#6E7F91','#AAB4C0'],
    scheduleBgMap: {'#003366':'#E8EEF5','#1B2A41':'#E9EDF2','#2F5F8F':'#E7F0F8','#5C7896':'#EDF3F8','#C5A47E':'#F8F2E8','#8A6F4D':'#F3EEE7','#6E7F91':'#EEF2F5','#AAB4C0':'#F1F4F7'},
    scheduleFallbackBg: '#EEF2F5'
  },
  chinese: {
    label: '新中式雅致',
    className: 'theme-chinese',
    exportBg: '#FBF6EC',
    colors: ['#B65F3A','#3A3A36','#8F6F52','#C8A46A','#6E7567','#9A7C65','#D8C7AD','#4E4A43'],
    scheduleBgMap: {'#B65F3A':'#F2E1D7','#3A3A36':'#EDE8DF','#8F6F52':'#EFE4D6','#C8A46A':'#F4E8CE','#6E7567':'#E6E9DF','#9A7C65':'#EEE1D7','#D8C7AD':'#F5ECDE','#4E4A43':'#E9E4DA'},
    scheduleFallbackBg: '#F1E7DA'
  },
  silicon: {
    label: '硅谷活力橘',
    className: 'theme-silicon',
    exportBg: '#FFFFFF',
    colors: ['#FF5722','#000000','#2B2F36','#7A7F87','#0F6FFF','#00A676','#C8CCD2','#525866'],
    scheduleBgMap: {'#FF5722':'#FFE7DE','#000000':'#F0F1F3','#2B2F36':'#ECEEF1','#7A7F87':'#F3F4F6','#0F6FFF':'#E4EEFF','#00A676':'#E3F6EF','#C8CCD2':'#F7F7F8','#525866':'#EEF0F2'},
    scheduleFallbackBg: '#F7F7F7'
  },
  klein: {
    label: '极智克莱因',
    className: 'theme-klein',
    exportBg: '#FFFFFF',
    colors: ['#0047FF','#000000','#1A1A1A','#333333','#6B7280','#00B2FF','#A7B8FF','#D8DEE8'],
    scheduleBgMap: {'#0047FF':'#E8EEFF','#000000':'#ECEEF3','#1A1A1A':'#F0F1F5','#333333':'#F3F4F7','#6B7280':'#F5F6F8','#00B2FF':'#E4F7FF','#A7B8FF':'#EEF2FF','#D8DEE8':'#F7F8FA'},
    scheduleFallbackBg: '#F5F5F7'
  }
};
let currentTheme = THEME_DEFAULT;
let reports = [];
let currentReportId = null;
let saveTimer = null;
let isRestoring = false;
let defaultSnapshot = null;

function deepClone(obj){ return JSON.parse(JSON.stringify(obj)); }
function getThemeConfig(){ return THEME_CONFIG[currentTheme] || THEME_CONFIG[THEME_DEFAULT]; }
function getThemeColors(){ return getThemeConfig().colors; }
function themeColor(index){ const colors=getThemeColors(); return colors[index % colors.length]; }
function remapThemeColor(color, fromTheme, toTheme){
  const fromColors=THEME_CONFIG[fromTheme]?.colors || [];
  const toColors=THEME_CONFIG[toTheme]?.colors || [];
  const idx=fromColors.findIndex(c=>c.toUpperCase()===String(color||'').toUpperCase());
  return idx>=0 ? toColors[idx % toColors.length] : color;
}
function remapBoardColors(fromTheme, toTheme){
  if(gantt?.groups) gantt.groups.forEach(g=>{
    g.color=remapThemeColor(g.color,fromTheme,toTheme);
    (g.rows||[]).forEach(row=>(row.bars||[]).forEach(bar=>{ bar.color=remapThemeColor(bar.color,fromTheme,toTheme); }));
  });
  if(progressBoard?.columns) progressBoard.columns.forEach(col=>{ col.tone=remapThemeColor(col.tone,fromTheme,toTheme); });
  if(scheduleBoard?.events) scheduleBoard.events.forEach(ev=>{ ev.color=remapThemeColor(ev.color,fromTheme,toTheme); });
}
function applyTheme(themeId, options={}){
  const prevTheme=currentTheme;
  const nextTheme=THEME_CONFIG[themeId] ? themeId : THEME_DEFAULT;
  if(options.remapColors && prevTheme!==nextTheme) remapBoardColors(prevTheme,nextTheme);
  currentTheme=nextTheme;
  Object.values(THEME_CONFIG).forEach(t=>document.body.classList.remove(t.className));
  document.body.classList.add(getThemeConfig().className);
  const select=document.getElementById('themeSelect');
  if(select) select.value=currentTheme;
  if(typeof renderAdvancedComponents==='function') renderAdvancedComponents();
  if(!options.silent) scheduleSave();
}
function escapeHTML(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function fmtTs(d){
  const p=n=>String(n).padStart(2,'0');
  return `${d.getFullYear()}${p(d.getMonth()+1)}${p(d.getDate())}-${p(d.getHours())}${p(d.getMinutes())}${p(d.getSeconds())}`;
}
function nowISO(){ return new Date().toISOString(); }
function getCurrentTitle(){
  const t=document.querySelector('.report-title')?.textContent?.trim();
  return t||'项目周报·模板';
}
function setSaveState(type,text){
  saveStateEl.classList.remove('saving','saved','error');
  saveStateEl.classList.add(type);
  saveStateEl.textContent=text;
}
function buildSnapshot(){
  return {
    theme: currentTheme,
    headHTML: reportHead.innerHTML,
    contentHTML: content.innerHTML,
    gantt: deepClone(gantt),
    progressBoard: deepClone(progressBoard),
    scheduleBoard: deepClone(scheduleBoard)
  };
}
function applySnapshot(snap){
  isRestoring = true;
  applyTheme(snap.theme || THEME_DEFAULT, {silent:true, remapColors:false});
  reportHead.innerHTML = snap.headHTML;
  content.innerHTML = snap.contentHTML;
  gantt = deepClone(snap.gantt || defaultGantt());
  progressBoard = deepClone(snap.progressBoard || defaultProgressBoard());
  scheduleBoard = deepClone(snap.scheduleBoard || defaultScheduleBoard());
  refreshAll();
  reorderAdvancedComponents();
  content.querySelectorAll('table.report-table').forEach(enableColResize);
  renderAdvancedComponents();
  syncAdvancedPicker();
  currentBlock = content.querySelector('.block');
  setMode(document.body.classList.contains('read-mode'));
  isRestoring = false;
}
function persistReports(){
  localStorage.setItem(STORE_KEY, JSON.stringify(reports));
}
function getSnapshotTitle(snap){
  if(!snap?.headHTML) return '';
  const box=document.createElement('div');
  box.innerHTML=snap.headHTML;
  return box.querySelector('.report-title')?.textContent?.trim() || '';
}
function getReportDisplayTitle(r){
  return getSnapshotTitle(r.snapshot) || r.title || r.name || '未命名周报';
}
function renderArchiveList(){
  const sorted=[...reports].sort((a,b)=>new Date(b.updatedAt)-new Date(a.updatedAt));
  archiveListEl.innerHTML='';
  sorted.forEach(r=>{
    const item=document.createElement('div');
    item.className='archive-item'+(r.id===currentReportId?' active':'');
    item.dataset.id=r.id;
    const top=document.createElement('div'); top.className='archive-item-top';
    const main=document.createElement('div'); main.className='archive-item-main';
    const t=document.createElement('div'); t.className='t'; t.textContent=getReportDisplayTitle(r);
    const m=document.createElement('div'); m.className='m'; m.textContent='更新 '+new Date(r.updatedAt).toLocaleString();
    main.append(t,m);
    const actions=document.createElement('div'); actions.className='archive-actions';
    const renameBtn=document.createElement('button'); renameBtn.className='archive-act'; renameBtn.textContent='重命名';
    const delBtn=document.createElement('button'); delBtn.className='archive-act danger'; delBtn.textContent='删除';
    renameBtn.title='重命名该存档';
    delBtn.title='删除该存档';
    renameBtn.addEventListener('click',(e)=>{
      e.stopPropagation();
      const oldName = getReportDisplayTitle(r);
      const next = prompt('请输入新的存档名称：', oldName);
      if(next===null) return;
      const n = next.trim();
      if(!n){ showHint('名称不能为空'); return; }
      const idx=reports.findIndex(x=>x.id===r.id);
      if(idx<0) return;
      reports[idx].name=n;
      reports[idx].updatedAt=nowISO();
      persistReports();
      renderArchiveList();
      showHint('已重命名');
    });
    delBtn.addEventListener('click',(e)=>{
      e.stopPropagation();
      const name = getReportDisplayTitle(r);
      if(!confirm(`确认删除存档「${name}」？`)) return;
      reports = reports.filter(x=>x.id!==r.id);
      if(reports.length===0){
        // 至少保留一个周报
        currentReportId=null;
        createReportFromCurrent(`新建周报 ${fmtTs(new Date())}`);
        showHint('已删除，已自动创建新周报');
        return;
      }
      if(currentReportId===r.id){
        const latest=[...reports].sort((a,b)=>new Date(b.updatedAt)-new Date(a.updatedAt))[0];
        currentReportId=latest.id;
        applySnapshot(latest.snapshot);
      }
      persistReports();
      renderArchiveList();
      showHint('已删除');
    });
    actions.append(renameBtn,delBtn);
    top.append(main,actions);
    item.append(top);
    item.addEventListener('click',()=>switchReport(r.id));
    archiveListEl.appendChild(item);
  });
}
function scheduleSave(){
  if(isRestoring || !currentReportId) return;
  setSaveState('saving','保存中…');
  clearTimeout(saveTimer);
  saveTimer = setTimeout(()=>{
    const idx = reports.findIndex(r=>r.id===currentReportId);
    if(idx<0) return;
    const snap = buildSnapshot();
    const title = getCurrentTitle();
    reports[idx].title = title;
    if(reports[idx].name && reports[idx].name !== title) delete reports[idx].name;
    reports[idx].updatedAt = nowISO();
    reports[idx].snapshot = snap;
    persistReports();
    renderArchiveList();
    setSaveState('saved','已保存');
  }, 450);
}
function switchReport(id){
  const target=reports.find(r=>r.id===id);
  if(!target) return;
  currentReportId=id;
  applySnapshot(target.snapshot);
  renderArchiveList();
  setSaveState('saved','已保存');
}
function createReportFromCurrent(name){
  const report = {
    id: crypto.randomUUID ? crypto.randomUUID() : String(Date.now()+Math.random()),
    name,
    title:getCurrentTitle(),
    createdAt: nowISO(),
    updatedAt: nowISO(),
    snapshot: buildSnapshot()
  };
  reports.push(report);
  persistReports();
  currentReportId = report.id;
  renderArchiveList();
  setSaveState('saved','已保存');
  return report;
}
function initReports(){
  let loaded=[];
  try{ loaded = JSON.parse(localStorage.getItem(STORE_KEY)||'[]'); }catch{ loaded=[]; }
  defaultSnapshot = buildSnapshot();
  if(!Array.isArray(loaded) || loaded.length===0){
    reports = [];
    createReportFromCurrent(getCurrentTitle()+' '+fmtTs(new Date()));
    return;
  }
  reports = loaded.filter(r=>r&&r.id&&r.snapshot);
  if(reports.length===0){
    createReportFromCurrent(getCurrentTitle()+' '+fmtTs(new Date()));
    return;
  }
  const latest=[...reports].sort((a,b)=>new Date(b.updatedAt)-new Date(a.updatedAt))[0];
  currentReportId = latest.id;
  try{
    applySnapshot(latest.snapshot);
  }catch(err){
    console.warn('恢复存档失败，已回到默认周报', err);
    localStorage.removeItem(STORE_KEY);
    reports = [];
    currentReportId = null;
    isRestoring = false;
    applySnapshot(defaultSnapshot);
    createReportFromCurrent(getCurrentTitle()+' '+fmtTs(new Date()));
    return;
  }
  renderArchiveList();
  setSaveState('saved','已保存');
}

/* =========================================================
   选区保存 / 恢复
========================================================= */
let savedRange = null;
document.addEventListener('selectionchange', ()=>{
  const sel = window.getSelection();
  if(sel.rangeCount===0) return;
  const r = sel.getRangeAt(0);
  if(content.contains(r.commonAncestorContainer)) savedRange = r.cloneRange();
});
function restoreSel(){
  if(!savedRange){ const b=currentBlock&&currentBlock.querySelector('.block-body[contenteditable="true"]'); if(b)b.focus(); return; }
  const sel=window.getSelection(); sel.removeAllRanges(); sel.addRange(savedRange);
}
function exec(cmd,val=null){ restoreSel(); document.execCommand('styleWithCSS',false,true); document.execCommand(cmd,false,val); }

/* 彻底清除选中文字的所有内联格式（加粗/斜体/下划线/划线/字色/填充/字号/字重/mark 等），恢复默认 */
function clearFormat(){
  restoreSel();
  const sel=window.getSelection();
  if(!sel.rangeCount||sel.isCollapsed){ showHint('请先选中要清除格式的文字'); return; }
  document.execCommand('styleWithCSS',false,true);
  document.execCommand('removeFormat');
  document.execCommand('hiliteColor',false,'transparent');
  // 解开选区内残留的 mark / b / strong / span 等包裹标签并清掉内联 style
  const range=sel.getRangeAt(0);
  const rootEl=range.commonAncestorContainer.nodeType===1?range.commonAncestorContainer:range.commonAncestorContainer.parentElement;
  const scope=rootEl.closest('.block-body, td, th')||rootEl;
  scope.querySelectorAll('mark, font').forEach(el=>{ if(range.intersectsNode(el)) unwrap(el); });
  scope.querySelectorAll('[style]').forEach(el=>{
    if(el.classList.contains('callout')) return;
    if(range.intersectsNode(el)){ el.removeAttribute('style'); el.removeAttribute('color'); el.removeAttribute('bgcolor'); }
  });
  showHint('已清除选中文字的格式');
}
function unwrap(el){ const p=el.parentNode; while(el.firstChild) p.insertBefore(el.firstChild, el); p.removeChild(el); }

/* =========================================================
   富文本工具栏
========================================================= */
document.querySelectorAll('[data-cmd]').forEach(b=>{
  b.addEventListener('mousedown',e=>e.preventDefault());
  b.addEventListener('click',()=>exec(b.dataset.cmd));
});
const clearFmtBtn=document.getElementById('clearFmt');
clearFmtBtn.addEventListener('mousedown',e=>e.preventDefault());
clearFmtBtn.addEventListener('click',clearFormat);
document.getElementById('blockStyle').addEventListener('change',e=>{
  restoreSel();
  const v=e.target.value;
  document.execCommand('formatBlock',false,v==='p'?'P':v.toUpperCase());
  if(currentBlock) refreshBlockClass(currentBlock);
  e.target.value='p';
});
function wrapInline(prop,val){
  restoreSel();
  const sel=window.getSelection();
  if(!sel.rangeCount||sel.isCollapsed) return;
  const range=sel.getRangeAt(0);
  const span=document.createElement('span'); span.style[prop]=val;
  try{ span.appendChild(range.extractContents()); range.insertNode(span);
    sel.removeAllRanges(); const nr=document.createRange(); nr.selectNodeContents(span); sel.addRange(nr); savedRange=nr.cloneRange();
  }catch(err){console.warn(err);}
}
document.getElementById('fontSize').addEventListener('change',e=>{ if(e.target.value) wrapInline('fontSize',e.target.value); e.target.value=''; });
document.getElementById('fontWeight').addEventListener('change',e=>{ if(e.target.value) wrapInline('fontWeight',e.target.value); e.target.value=''; });
document.querySelectorAll('[data-fore]').forEach(s=>{ s.addEventListener('mousedown',e=>e.preventDefault()); s.addEventListener('click',()=>exec('foreColor',s.dataset.fore)); });
document.querySelectorAll('[data-back]').forEach(s=>{ s.addEventListener('mousedown',e=>e.preventDefault()); s.addEventListener('click',()=>{const v=s.dataset.back; exec('hiliteColor',v==='transparent'?'transparent':v);}); });

/* =========================================================
   区块系统
========================================================= */
let currentBlock=null;
const RAIL = `<div class="block-rail editor-only">
  <button class="block-drag" title="拖动排序">⠿</button>
  <button data-bact="up" title="上移">⌃</button>
  <button data-bact="down" title="下移">⌄</button>
  <button data-bact="dup" title="复制区块">⧉</button>
  <button data-bact="add" title="在下方插入区块">＋</button>
  <button data-bact="del" class="danger" title="删除区块">✕</button>
</div>`;

function injectRail(block){
  if(block.querySelector('.block-rail')) return;
  block.insertAdjacentHTML('afterbegin', RAIL);
}
function refreshBlockClass(block){
  block.classList.remove('mod-h1','mod-h2','mod-h3','mod-table','mod-gantt','mod-progress-board','mod-schedule-board');
  const type=block.dataset.type;
  if(type==='table'){ block.classList.add('mod-table'); return; }
  if(type==='gantt'){ block.classList.add('mod-gantt'); return; }
  if(type==='progressBoard'){ block.classList.add('mod-progress-board'); return; }
  if(type==='scheduleBoard'){ block.classList.add('mod-schedule-board'); return; }
  const body=block.querySelector('.block-body');
  const first=body&&body.firstElementChild;
  if(first){
    if(first.tagName==='H1') block.classList.add('mod-h1');
    else if(first.tagName==='H2') block.classList.add('mod-h2');
    else if(first.tagName==='H3') block.classList.add('mod-h3');
  }
}
function refreshAll(){ content.querySelectorAll('.block').forEach(b=>{injectRail(b); refreshBlockClass(b);}); }

function newBlockHTML(type){
  switch(type){
    case 'p': return {t:'text', e:true, h:'<p>在此输入正文内容…</p>'};
    case 'h1': return {t:'text', e:true, h:'<h1>一级标题</h1>'};
    case 'h2': return {t:'text', e:true, h:'<h2>二级标题</h2>'};
    case 'h3': return {t:'text', e:true, h:'<h3>三级小标题</h3>'};
    case 'ul': return {t:'list', e:true, h:'<ul><li>列表项</li></ul>'};
    case 'ol': return {t:'list', e:true, h:'<ol><li>列表项</li></ol>'};
    case 'callout': return {t:'callout', e:true, h:'<div class="callout"><p>在此输入需要强调的内容…</p></div>'};
    case 'warn': return {t:'callout', e:true, h:'<div class="callout warn"><p>在此输入风险 / 提示内容…</p></div>'};
    case 'table': return {t:'table', e:false, h:defaultTable(3,3)};
    case 'gantt': return {t:'gantt', e:false, h:'<div id="ganttMount"></div>'};
    case 'progressBoard': return {t:'progressBoard', e:false, h:'<div id="progressBoardMount"></div>'};
    case 'scheduleBoard': return {t:'scheduleBoard', e:false, h:'<div id="scheduleBoardMount"></div>'};
  }
}
function createBlock(type,inner,editable){
  const b=document.createElement('div');
  b.className='block'; b.dataset.type=type;
  b.innerHTML = RAIL + '<div class="block-body" contenteditable="'+editable+'">'+inner+'</div>';
  refreshBlockClass(b);
  return b;
}
function insertAfter(block,refBlock){
  if(refBlock&&refBlock.parentElement===content) refBlock.after(block);
  else content.appendChild(block);
}
function focusBlock(block){
  const body=block.querySelector('.block-body[contenteditable="true"]');
  if(body){ body.focus();
    const r=document.createRange(); r.selectNodeContents(body); r.collapse(false);
    const s=window.getSelection(); s.removeAllRanges(); s.addRange(r);
  }
  currentBlock=block;
}

// 轨道按钮
content.addEventListener('click',e=>{
  const b=e.target.closest('[data-bact]');
  if(!b) return;
  const block=b.closest('.block'); currentBlock=block;
  const act=b.dataset.bact;
  if(act==='up'){ const prev=block.previousElementSibling; if(prev) content.insertBefore(block,prev); }
  else if(act==='down'){ const next=block.nextElementSibling; if(next) content.insertBefore(next,block); }
  else if(act==='del'){ if(content.querySelectorAll('.block').length>1) block.remove(); hideTableToolbar(); syncAdvancedPicker(); }
  else if(act==='dup'){
    if(isAdvancedType(block.dataset.type)){ showHint('高级组件仅支持单个区块'); return; }
    const clone=block.cloneNode(true);
    block.after(clone);
    if(clone.dataset.type==='table') enableColResize(clone.querySelector('table'));
    refreshBlockClass(clone);
  }
  else if(act==='add'){ openBlockMenu(b, block); }
});

// 插入菜单
const blockMenu=document.getElementById('blockMenu');
let menuTarget=null;
function openBlockMenu(anchorEl, targetBlock){
  menuTarget=targetBlock;
  const r=anchorEl.getBoundingClientRect();
  blockMenu.style.top=Math.min(window.innerHeight-340, r.top)+'px';
  blockMenu.style.left=(r.right+8)+'px';
  blockMenu.classList.add('show');
}
function closeBlockMenu(){ blockMenu.classList.remove('show'); menuTarget=null; }
blockMenu.addEventListener('click',e=>{
  const b=e.target.closest('[data-new]'); if(!b) return;
  const spec=newBlockHTML(b.dataset.new);
  const block=createBlock(spec.t, spec.h, spec.e);
  insertAfter(block, menuTarget||currentBlock);
  if(spec.t==='table') enableColResize(block.querySelector('table'));
  if(spec.e) focusBlock(block);
  closeBlockMenu();
});
document.addEventListener('mousedown',e=>{ if(blockMenu.classList.contains('show') && !blockMenu.contains(e.target) && !e.target.closest('[data-bact="add"]')) closeBlockMenu(); });

// 工具栏快捷插入
document.querySelectorAll('[data-insert]').forEach(btn=>{
  btn.addEventListener('mousedown',e=>e.preventDefault());
  btn.addEventListener('click',()=>{
    const spec=newBlockHTML(btn.dataset.insert);
    const block=createBlock(spec.t, spec.h, spec.e);
    insertAfter(block, currentBlock);
    if(spec.t==='table') enableColResize(block.querySelector('table'));
    if(spec.e) focusBlock(block);
  });
});
document.getElementById('addBlockEnd').addEventListener('click',()=>{
  const last=content.lastElementChild;
  openBlockMenu(document.getElementById('addBlockEnd'), last);
});

// 追踪当前区块
content.addEventListener('focusin',e=>{ const b=e.target.closest('.block'); if(b) currentBlock=b; });
content.addEventListener('mousedown',e=>{ const b=e.target.closest('.block'); if(b&&!e.target.closest('.block-rail')) currentBlock=b; });

// 拖拽排序
let dragSrc=null;
content.addEventListener('mousedown',e=>{ const h=e.target.closest('.block-drag'); if(h) h.closest('.block').setAttribute('draggable','true'); });
content.addEventListener('dragstart',e=>{
  const block=e.target.closest('.block[draggable="true"]'); if(!block){e.preventDefault();return;}
  dragSrc=block; block.classList.add('dragging'); e.dataTransfer.effectAllowed='move'; e.dataTransfer.setData('text/plain','');
});
content.addEventListener('dragover',e=>{
  if(!dragSrc) return; e.preventDefault();
  const over=e.target.closest('.block'); if(!over||over===dragSrc) return;
  const r=over.getBoundingClientRect();
  const after=(e.clientY-r.top)/r.height>0.5;
  content.insertBefore(dragSrc, after?over.nextSibling:over);
});
content.addEventListener('dragend',()=>{ if(dragSrc){ dragSrc.classList.remove('dragging'); dragSrc.removeAttribute('draggable'); dragSrc=null; } });

/* =========================================================
   表格：默认结构 / 列宽拖拽 / Excel 粘贴
========================================================= */
function tableMarkup(N, thead, tbody){
  let cg='<colgroup>'; for(let i=0;i<N;i++) cg+='<col style="width:'+(100/N).toFixed(4)+'%">'; cg+='</colgroup>';
  return '<div class="tbl-wrap"><table class="report-table">'+cg+'<thead>'+thead+'</thead><tbody>'+tbody+'</tbody></table></div>';
}
function defaultTable(rows,cols){
  let th=''; for(let c=0;c<cols;c++) th+='<th>表头'+(c+1)+'</th>';
  let tb=''; for(let r=0;r<rows;r++){ tb+='<tr>'; for(let c=0;c<cols;c++) tb+='<td contenteditable="true">内容</td>'; tb+='</tr>'; }
  return tableMarkup(cols,'<tr>'+th+'</tr>',tb);
}
function escapeCell(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

function cleanFromHTMLTable(html){
  const tmp=document.createElement('div'); tmp.innerHTML=html;
  const src=tmp.querySelector('table'); if(!src) return null;
  const rows=[...src.rows]; if(!rows.length) return null;
  let N=0; [...rows[0].cells].forEach(td=>N+=(td.colSpan||1));
  let thead='', tbody='';
  rows.forEach((tr,ri)=>{
    let cells='';
    [...tr.cells].forEach(td=>{
      const cs=(td.colSpan>1)?' colspan="'+td.colSpan+'"':'';
      const rs=(td.rowSpan>1)?' rowspan="'+td.rowSpan+'"':'';
      const txt=escapeCell((td.innerText||td.textContent||'').trim());
      if(ri===0) cells+='<th'+cs+rs+'>'+txt+'</th>';
      else cells+='<td'+cs+rs+' contenteditable="true">'+txt+'</td>';
    });
    if(ri===0) thead='<tr>'+cells+'</tr>'; else tbody+='<tr>'+cells+'</tr>';
  });
  return tableMarkup(N, thead, tbody);
}
function cleanFromTSV(text){
  const lines=text.replace(/\r/g,'').split('\n').filter(l=>l.length>0);
  if(lines.length<1) return null;
  const rows=lines.map(l=>l.split('\t'));
  const N=Math.max(...rows.map(r=>r.length));
  let thead='', tbody='';
  rows.forEach((r,ri)=>{
    let cells='';
    for(let i=0;i<N;i++){ const t=escapeCell((r[i]||'').trim());
      if(ri===0) cells+='<th>'+t+'</th>'; else cells+='<td contenteditable="true">'+t+'</td>'; }
    if(ri===0) thead='<tr>'+cells+'</tr>'; else tbody+='<tr>'+cells+'</tr>';
  });
  return tableMarkup(N, thead, tbody);
}
function insertTableMarkup(markup){
  const block=createBlock('table', markup, false);
  insertAfter(block, currentBlock);
  enableColResize(block.querySelector('table'));
  currentBlock=block;
}

content.addEventListener('paste',e=>{
  if(document.body.classList.contains('read-mode')) return;
  const cd=e.clipboardData; if(!cd) return;
  const html=cd.getData('text/html');
  const text=cd.getData('text/plain');
  let markup=null;
  if(html && /<table[\s>]/i.test(html)) markup=cleanFromHTMLTable(html);
  else if(text && text.indexOf('\t')>-1 && text.indexOf('\n')>-1) markup=cleanFromTSV(text);
  if(markup){ e.preventDefault(); insertTableMarkup(markup); showHint('已将表格渲染为主题样式，可继续调整列宽与换行'); return; }
  // 普通富文本 → 粘为纯文本，避免格式错乱
  if(html){ e.preventDefault(); document.execCommand('insertText',false,text); }
});

// 单元格内回车 = 软换行（插入 <br>），而非另起段落 / 跳出单元格
content.addEventListener('keydown',e=>{
  if(e.key!=='Enter'||e.isComposing) return;
  if(document.body.classList.contains('read-mode')) return;
  const cell=e.target.closest&&e.target.closest('td,th');
  if(cell){ e.preventDefault(); document.execCommand('insertLineBreak'); }
});

function enableColResize(table){
  if(!table) return;
  const cols=table.querySelectorAll('colgroup col');
  if(!cols.length) return;
  const headRow=table.tHead&&table.tHead.rows[0];
  if(!headRow) return;
  let colIdx=0;
  [...headRow.cells].forEach(th=>{
    const span=th.colSpan||1;
    const last=colIdx+span-1; colIdx+=span;
    if(th.querySelector('.col-resize')) return;
    th.style.position='relative';
    const grip=document.createElement('div'); grip.className='col-resize editor-only'; th.appendChild(grip);
    grip.addEventListener('mousedown',ev=>{
      ev.preventDefault(); ev.stopPropagation();
      const startX=ev.clientX;
      const widths=[...cols].map(c=>c.offsetWidth);
      const i=last, j=(last+1<cols.length)?last+1:last-1;
      if(j<0) return;
      const startI=widths[i], startJ=widths[j];
      function move(m){
        let d=m.clientX-startX; if(j<i) d=-d;
        let a=startI+d, b=startJ-d; const min=46;
        if(a<min){ b-=(min-a); a=min; } if(b<min){ a-=(min-b); b=min; }
        const total=widths.reduce((x,y)=>x+y,0);
        cols[i].style.width=(a/total*100).toFixed(4)+'%';
        cols[j].style.width=(b/total*100).toFixed(4)+'%';
      }
      function up(){ document.removeEventListener('mousemove',move); document.removeEventListener('mouseup',up); }
      document.addEventListener('mousemove',move); document.addEventListener('mouseup',up);
    });
  });
}

/* 表格浮动操作条 */
const tableToolbar=document.getElementById('tableToolbar');
let curCell=null;
content.addEventListener('click',e=>{
  const cell=e.target.closest('td,th');
  if(cell && content.contains(cell) && !e.target.closest('.col-resize') && !document.body.classList.contains('read-mode')){
    curCell=cell; positionTableToolbar(cell);
  }else if(!e.target.closest('.table-toolbar')) hideTableToolbar();
});
function positionTableToolbar(cell){
  const r=cell.getBoundingClientRect();
  tableToolbar.classList.add('show');
  let top=r.top+window.scrollY-tableToolbar.offsetHeight-8;
  if(top<window.scrollY+70) top=r.bottom+window.scrollY+8;
  let left=Math.min(r.left+window.scrollX, window.innerWidth-tableToolbar.offsetWidth-12);
  tableToolbar.style.top=top+'px'; tableToolbar.style.left=Math.max(8,left)+'px';
}
function hideTableToolbar(){ tableToolbar.classList.remove('show'); }
window.addEventListener('scroll',()=>{ if(curCell&&tableToolbar.classList.contains('show')) positionTableToolbar(curCell); });
function newCell(tag){ const c=document.createElement(tag); if(tag==='td'){c.contentEditable='true';c.textContent='内容';} else c.textContent='表头'; return c; }

tableToolbar.addEventListener('mousedown',e=>e.preventDefault());
tableToolbar.addEventListener('click',e=>{
  const b=e.target.closest('[data-tact]'); if(!b||!curCell) return;
  const act=b.dataset.tact, row=curCell.parentElement, table=curCell.closest('table'), inHead=curCell.tagName==='TH';
  if(act==='rowAbove'||act==='rowBelow'){
    const tr=document.createElement('tr'); const n=row.children.length;
    for(let i=0;i<n;i++) tr.appendChild(newCell('td'));
    row.parentElement.insertBefore(tr, act==='rowAbove'?row:row.nextSibling);
  }
  else if(act==='rowDel'){ if(row.parentElement.children.length>1) row.remove(); hideTableToolbar(); curCell=null; }
  else if(act==='colLeft'||act==='colRight'){
    const ci=curCell.cellIndex;
    [...table.rows].forEach(tr=>{ const isH=tr.parentElement.tagName==='THEAD'; const ref=tr.cells[ci]; const nc=newCell(isH?'th':'td');
      if(act==='colLeft') tr.insertBefore(nc,ref); else tr.insertBefore(nc,ref?ref.nextSibling:null); });
    addColToColgroup(table);
  }
  else if(act==='colDel'){ const ci=curCell.cellIndex; [...table.rows].forEach(tr=>{ if(tr.cells[ci]&&tr.cells.length>1) tr.deleteCell(ci); }); removeColFromColgroup(table,ci); hideTableToolbar(); curCell=null; }
  else if(act==='mergeRight'){ const next=curCell.nextElementSibling; if(next){ curCell.colSpan=(curCell.colSpan||1)+(next.colSpan||1); next.remove(); } }
  else if(act==='mergeDown'){ const nr=row.nextElementSibling; if(nr){ const ci=curCell.cellIndex; const below=nr.cells[ci]; if(below){ curCell.rowSpan=(curCell.rowSpan||1)+(below.rowSpan||1); below.remove(); } } }
  else if(act==='split'){
    const cs=curCell.colSpan||1, rs=curCell.rowSpan||1;
    if(cs>1){ for(let i=1;i<cs;i++){ const nc=newCell(inHead?'th':'td'); nc.textContent=''; curCell.parentElement.insertBefore(nc,curCell.nextSibling); } curCell.colSpan=1; }
    if(rs>1){ const ci=curCell.cellIndex; let rr=row; for(let i=1;i<rs;i++){ rr=rr.nextElementSibling; if(rr){ const nc=newCell('td'); nc.textContent=''; rr.insertBefore(nc, rr.cells[ci]||null); } } curCell.rowSpan=1; }
  }
  else if(act==='alignLeft') curCell.style.textAlign='left';
  else if(act==='alignCenter') curCell.style.textAlign='center';
  else if(act==='alignRight') curCell.style.textAlign='right';
  else if(act==='wrap') curCell.classList.toggle('nowrap');
  else if(act==='br'){
    restoreSel();
    document.execCommand('insertLineBreak');
  }
});
function addColToColgroup(table){
  const cg=table.querySelector('colgroup'); if(!cg) return;
  const col=document.createElement('col'); cg.appendChild(col);
  equalizeCols(table);
}
function removeColFromColgroup(table,ci){
  const cg=table.querySelector('colgroup'); if(!cg) return;
  if(cg.children[ci]) cg.children[ci].remove();
  equalizeCols(table);
}
function equalizeCols(table){
  const cg=table.querySelector('colgroup'); if(!cg) return;
  const n=cg.children.length; [...cg.children].forEach(c=>c.style.width=(100/n).toFixed(4)+'%');
}

/* =========================================================
   甘特图
========================================================= */
const GANTT_COLORS=THEME_CONFIG.tundra.colors;
function defaultGantt(){
  return {
    months:['6月','7月','8月','9月'],
    groups:[
      { name:'项目1 · 客户触达系统', color:themeColor(0), rows:[
        { task:'迭代1：规则闭环与灰度验证', bars:[{start:0,span:1,label:'灰度验证',color:themeColor(0)}] },
        { task:'迭代2：正式上线与反馈收集', bars:[{start:0,span:2,label:'上线与反馈',color:themeColor(1)}] },
        { task:'迭代3：监测口径扩展', bars:[{start:2,span:1,label:'口径扩展',color:themeColor(3)}] },
      ]},
      { name:'项目2 · 知识协作平台', color:themeColor(4), rows:[
        { task:'迭代1：学习日历内容上架', bars:[{start:0,span:1,label:'内容上架',color:themeColor(4)}] },
        { task:'迭代2：专题分享沉淀', bars:[{start:0,span:2,label:'沉淀复用',color:themeColor(1)}] },
        { task:'迭代3：机器人采集联调', bars:[{start:1,span:2,label:'联调',color:themeColor(2)}] },
        { task:'迭代4：区域负责人入口', bars:[{start:2,span:2,label:'入口设计',color:themeColor(5)}] },
      ]},
      { name:'项目3 · 重点区域团队赋能', color:themeColor(1), rows:[
        { task:'迭代1：月报模板定稿', bars:[{start:0,span:1,label:'模板定稿',color:themeColor(1)}] },
        { task:'迭代2：重点工作提示', bars:[{start:1,span:1,label:'提示交付',color:themeColor(0)}] },
        { task:'迭代3：周度工作小结', bars:[{start:2,span:1,label:'周度小结',color:themeColor(3)}] },
      ]},
    ]
  };
}
let gantt=defaultGantt();
const TASK_W=224, GLABEL_W=38, GAP=8;
const LEFTPAD=GLABEL_W+GAP+TASK_W+GAP;

function renderGantt(){
  const mount=document.getElementById('ganttMount') || document.querySelector('[data-type="gantt"] .gantt-mount'); if(!mount) return;
  const isRead=document.body.classList.contains('read-mode');
  const M=gantt.months.length;
  let h='<div class="gantt" contenteditable="false">';
  h+='<div class="gantt-header-row"><div class="gantt-title-wrap"><div class="gantt-kicker">PROJECT GANTT</div><div class="gantt-title" contenteditable="'+(!isRead)+'">项目推进甘特图</div></div><div class="gantt-mark"></div></div>';
  h+='<div class="gantt-canvas">';
  h+='<div class="gantt-months" style="--leftpad:'+LEFTPAD+'px">';
  gantt.months.forEach(m=>h+='<div class="gm">'+m+'</div>'); h+='</div>';
  gantt.groups.forEach((g,gi)=>{
    h+='<div class="gantt-group">';
    h+='<div class="gantt-glabel" style="background:'+g.color+'" contenteditable="'+(!isRead)+'" data-g="'+gi+'" data-f="name">'+escapeHTML(g.name)+'</div>';
    h+='<div class="gantt-gbody">';
    g.rows.forEach((row,ri)=>{
      h+='<div class="gantt-row">';
      h+='<div class="gantt-task" contenteditable="'+(!isRead)+'" data-g="'+gi+'" data-r="'+ri+'" data-f="task">'+escapeHTML(row.task)+'</div>';
      h+='<div class="gantt-track'+(isRead?'':' empty-hint')+'" data-g="'+gi+'" data-r="'+ri+'">';
      row.bars.forEach((bar,bi)=>{
        const left=(bar.start/M*100), width=(bar.span/M*100);
        h+='<div class="gantt-bar" title="'+escapeHTML(bar.label||'')+'" style="left:calc('+left+'% + 4px);width:calc('+width+'% - 8px);background:'+bar.color+'" data-g="'+gi+'" data-r="'+ri+'" data-b="'+bi+'"><span class="bar-txt">'+escapeHTML(bar.label||'')+'</span></div>';
      });
      h+='</div>';
      if(!isRead) h+='<button class="gantt-del-row editor-only" title="删除该行" data-delrow data-g="'+gi+'" data-r="'+ri+'">✕</button>';
      h+='</div>';
    });
    if(!isRead) h+='<div class="gantt-rowadd editor-only"><button class="mini-add" data-addrow data-g="'+gi+'">＋ 添加任务行</button></div>';
    h+='</div></div>';
  });
  if(!isRead){
    h+='<div class="gantt-add editor-only"><button class="mini-add" data-addgroup>＋ 添加项目分组</button><button class="mini-add" data-addmonth>＋ 添加月份</button><button class="mini-add" data-delmonth>－ 删除末月</button></div>';
  }
  h+='</div></div>';
  mount.innerHTML=h;
}
document.addEventListener('input',e=>{
  const t=e.target;
  if(t.classList&&(t.classList.contains('gantt-glabel')||t.classList.contains('gantt-task'))){
    const gi=+t.dataset.g, ri=+t.dataset.r, f=t.dataset.f;
    if(f==='name') gantt.groups[gi].name=t.textContent;
    else if(f==='task') gantt.groups[gi].rows[ri].task=t.textContent;
  }
});
document.addEventListener('click',e=>{
  if(document.body.classList.contains('read-mode')) return;
  if(!e.target.closest('#ganttMount')) return;
  const bar=e.target.closest('.gantt-bar');
  if(bar){ openGanttPop(+bar.dataset.g,+bar.dataset.r,+bar.dataset.b,bar); return; }
  const addRow=e.target.closest('[data-addrow]');
  if(addRow){ gantt.groups[+addRow.dataset.g].rows.push({task:'新任务行',bars:[]}); renderGantt(); return; }
  const delRow=e.target.closest('[data-delrow]');
  if(delRow){ const g=+delRow.dataset.g; if(gantt.groups[g].rows.length>1) gantt.groups[g].rows.splice(+delRow.dataset.r,1); renderGantt(); return; }
  const addGroup=e.target.closest('[data-addgroup]');
  if(addGroup){ gantt.groups.push({name:'新项目分组',color:themeColor(gantt.groups.length),rows:[{task:'新任务行',bars:[]}]}); renderGantt(); return; }
  const addMonth=e.target.closest('[data-addmonth]');
  if(addMonth){ gantt.months.push((gantt.months.length+5)+'月'); renderGantt(); return; }
  const delMonth=e.target.closest('[data-delmonth]');
  if(delMonth){ if(gantt.months.length>1){ gantt.months.pop(); gantt.groups.forEach(g=>g.rows.forEach(r=>r.bars=r.bars.filter(b=>b.start<gantt.months.length).map(b=>{b.span=Math.min(b.span,gantt.months.length-b.start);return b;}))); renderGantt(); } return; }
  const track=e.target.closest('.gantt-track');
  if(track){
    const gi=+track.dataset.g, ri=+track.dataset.r, rect=track.getBoundingClientRect();
    const ratio=(e.clientX-rect.left)/rect.width;
    const start=Math.max(0,Math.min(gantt.months.length-1,Math.floor(ratio*gantt.months.length)));
    gantt.groups[gi].rows[ri].bars.push({start,span:1,label:'新任务',color:gantt.groups[gi].color});
    renderGantt();
  }
});
const ganttPop=document.getElementById('ganttPop');
let popCtx=null;
function buildSelectOptions(){
  const ss=document.getElementById('gpStart'), sp=document.getElementById('gpSpan');
  ss.innerHTML=''; sp.innerHTML='';
  gantt.months.forEach((m,i)=>ss.add(new Option(m,i)));
  for(let i=1;i<=gantt.months.length;i++) sp.add(new Option(i+' 个月',i));
  const cb=document.getElementById('gpColors'); cb.innerHTML='';
  getThemeColors().forEach(c=>{ const s=document.createElement('span'); s.className='swatch'; s.style.background=c;
    s.onclick=()=>{ if(popCtx){ popCtx.bar.color=c; document.querySelectorAll('#gpColors .swatch').forEach(x=>x.style.outline='none'); s.style.outline='2px solid '+c; } }; cb.appendChild(s); });
}
function openGanttPop(gi,ri,bi,el){
  popCtx={gi,ri,bi,bar:gantt.groups[gi].rows[ri].bars[bi]};
  buildSelectOptions();
  document.getElementById('gpLabel').value=popCtx.bar.label||'';
  document.getElementById('gpStart').value=popCtx.bar.start;
  document.getElementById('gpSpan').value=popCtx.bar.span;
  const r=el.getBoundingClientRect();
  let top=r.bottom+8; if(top>window.innerHeight-280) top=Math.max(70,r.top-290);
  ganttPop.style.top=top+'px'; ganttPop.style.left=Math.max(8,Math.min(r.left,window.innerWidth-300))+'px';
  ganttPop.classList.add('show');
}
document.getElementById('gpLabel').addEventListener('input',e=>{ if(popCtx) popCtx.bar.label=e.target.value; });
document.getElementById('gpStart').addEventListener('change',e=>{ if(popCtx){ popCtx.bar.start=+e.target.value; const max=gantt.months.length-popCtx.bar.start; if(popCtx.bar.span>max) popCtx.bar.span=max; } });
document.getElementById('gpSpan').addEventListener('change',e=>{ if(popCtx){ const max=gantt.months.length-popCtx.bar.start; popCtx.bar.span=Math.min(+e.target.value,max); } });
document.getElementById('gpDelete').addEventListener('click',()=>{ if(popCtx) gantt.groups[popCtx.gi].rows[popCtx.ri].bars.splice(popCtx.bi,1); closePop(); });
document.getElementById('gpDone').addEventListener('click',closePop);
function closePop(){ ganttPop.classList.remove('show'); popCtx=null; renderGantt(); }
document.addEventListener('mousedown',e=>{ if(ganttPop.classList.contains('show')&&!ganttPop.contains(e.target)&&!e.target.closest('.gantt-bar')) closePop(); });

/* =========================================================
   项目进度看板 / 高级组件
========================================================= */
function defaultProgressBoard(){
  return {
    columns:[
      {title:'待启动',tone:themeColor(3),cards:[
        {status:'待确认',title:'指标监测扩展',desc:'等待规则范围与监测口径确认后启动排期。',owner:'规则小组',priority:'P1'},
        {status:'准备中',title:'区域负责人入口',desc:'梳理移动端入口与权限边界，形成首版方案。',owner:'产品组',priority:'P2'},
      ]},
      {title:'进行中',tone:themeColor(4),cards:[
        {status:'推进中',title:'客户触达系统',desc:'灰度验证进入收尾，准备正式上线并收集首轮反馈。',owner:'项目负责人',priority:'P0'},
        {status:'推进中',title:'知识协作平台',desc:'学习日历与专题分享持续上架，同步推进机器人采集联调。',owner:'项目组',priority:'P1'},
      ]},
      {title:'已完成',tone:themeColor(1),cards:[
        {status:'已完成',title:'重点区域团队赋能',desc:'月报模板与重点工作提示已定稿，进入交付复盘。',owner:'赋能小组',priority:'P1'},
      ]},
    ]
  };
}
let progressBoard=defaultProgressBoard();

const ADVANCED_COMPONENTS={
  gantt:{type:'gantt',title:'项目甘特图',mount:'<div id="ganttMount"></div>',render:renderGantt},
  progressBoard:{type:'progressBoard',title:'项目进度看板',mount:'<div id="progressBoardMount"></div>',render:renderProgressBoard},
  scheduleBoard:{type:'scheduleBoard',title:'日程看板',mount:'<div id="scheduleBoardMount"></div>',render:renderScheduleBoard}
};
const ADVANCED_ORDER=['gantt','progressBoard','scheduleBoard'];
function isAdvancedType(type){ return ADVANCED_ORDER.some(k=>ADVANCED_COMPONENTS[k].type===type); }
function advancedComponentKeyByType(type){ return ADVANCED_ORDER.find(k=>ADVANCED_COMPONENTS[k].type===type); }
function findAdvancedBlock(key){ return content.querySelector(`.block[data-type="${ADVANCED_COMPONENTS[key].type}"]`); }
function getAdvancedBlockPair(key){
  const block=findAdvancedBlock(key);
  if(!block) return null;
  return {title:findAdvancedTitleBlock(block,key) || content.querySelector(`.block[data-advanced-title="${key}"]`), block};
}
function findAdvancedInsertRef(key){
  const index=ADVANCED_ORDER.indexOf(key);
  for(let i=index+1;i<ADVANCED_ORDER.length;i++){
    const pair=getAdvancedBlockPair(ADVANCED_ORDER[i]);
    if(pair) return pair.title || pair.block;
  }
  return null;
}
function findAdvancedAppendAnchor(key){
  const index=ADVANCED_ORDER.indexOf(key);
  for(let i=index-1;i>=0;i--){
    const pair=getAdvancedBlockPair(ADVANCED_ORDER[i]);
    if(pair) return pair.block;
  }
  return null;
}
function reorderAdvancedComponents(){
  let anchor=null;
  ADVANCED_ORDER.forEach(key=>{
    const pair=getAdvancedBlockPair(key);
    if(!pair) return;
    const title=pair.title, block=pair.block;
    if(anchor){
      anchor.after(title || block);
      if(title) title.after(block);
    }else if(title && title.nextElementSibling!==block){
      title.after(block);
    }
    anchor=block;
  });
}
function findAdvancedTitleBlock(block, key){
  let prev=block&&block.previousElementSibling;
  const title=ADVANCED_COMPONENTS[key].title;
  if(prev && prev.dataset.type==='text' && prev.textContent.trim()===title) return prev;
  return null;
}
function insertAdvancedComponent(key){
  const comp=ADVANCED_COMPONENTS[key];
  if(!comp || findAdvancedBlock(key)) return;
  const titleBlock=createBlock('text','<h1>'+comp.title+'</h1>',true);
  titleBlock.dataset.advancedTitle=key;
  const compBlock=createBlock(comp.type,comp.mount,false);
  compBlock.dataset.advancedKey=key;
  const ref=findAdvancedInsertRef(key);
  if(ref) ref.before(titleBlock);
  else{
    const appendAnchor=findAdvancedAppendAnchor(key);
    if(appendAnchor) appendAnchor.after(titleBlock);
    else content.appendChild(titleBlock);
  }
  titleBlock.after(compBlock);
  currentBlock=compBlock;
  comp.render();
  syncAdvancedPicker();
}
function removeAdvancedComponent(key){
  const block=findAdvancedBlock(key);
  if(!block) return;
  const title=findAdvancedTitleBlock(block,key) || content.querySelector(`.block[data-advanced-title="${key}"]`);
  block.remove();
  if(title && content.querySelectorAll('.block').length>1) title.remove();
  syncAdvancedPicker();
}
function syncAdvancedPicker(){
  document.querySelectorAll('[data-advanced]').forEach(input=>{ input.checked=!!findAdvancedBlock(input.dataset.advanced); });
}
function renderAdvancedComponents(){ renderGantt(); renderProgressBoard(); renderScheduleBoard(); }

function defaultScheduleBoard(){
  return {
    days:['周一','周二','周三','周四','周五'],
    startHour:9,
    endHour:18,
    ticks:['09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00'],
    events:[
      {day:0,start:9,end:11,title:'周例会',desc:'同步本周重点项目节奏',color:themeColor(0)},
      {day:1,start:14,end:16,title:'需求评审',desc:'进度看板与周报模板对齐',color:themeColor(2)},
      {day:2,start:10,end:12,title:'数据复盘',desc:'核心指标与风险项校准',color:themeColor(4)},
      {day:3,start:15,end:17,title:'方案打磨',desc:'平台入口和机器人联调',color:themeColor(5)},
      {day:4,start:11,end:12,title:'周报整理',desc:'沉淀结论与下周计划',color:themeColor(1)},
    ]
  };
}
let scheduleBoard=defaultScheduleBoard();
function normalizeScheduleBoard(){
  if(!scheduleBoard || !Array.isArray(scheduleBoard.days) || !Array.isArray(scheduleBoard.events)) scheduleBoard=defaultScheduleBoard();
  scheduleBoard.startHour=Math.floor(+scheduleBoard.startHour||9);
  scheduleBoard.endHour=Math.ceil(+scheduleBoard.endHour||18);
  if(scheduleBoard.endHour<=scheduleBoard.startHour) scheduleBoard.endHour=scheduleBoard.startHour+1;
  scheduleBoard.ticks=getScheduleTicks();
  scheduleBoard.events.forEach(normalizeScheduleEvent);
}
function formatHour(h){
  const hour=Math.floor(+h||0), min=Math.round(((+h||0)-hour)*60);
  return String(hour).padStart(2,'0')+':'+String(min).padStart(2,'0');
}
function getScheduleTicks(){
  const start=scheduleBoard?.startHour||9, end=scheduleBoard?.endHour||18, ticks=[];
  for(let h=start;h<=end;h++) ticks.push(formatHour(h));
  return ticks;
}
function getScheduleHours(includeEnd=false){
  const start=scheduleBoard?.startHour||9, end=scheduleBoard?.endHour||18, hours=[];
  for(let h=start;h<=(includeEnd?end:end-1);h++) hours.push(h);
  return hours;
}
function normalizeScheduleEvent(ev){
  const start=scheduleBoard.startHour||9, end=scheduleBoard.endHour||18;
  ev.day=Math.max(0,Math.min((scheduleBoard.days||[]).length-1,Math.floor(+ev.day||0)));
  ev.start=Math.max(start,Math.min(end-1,Math.floor(+ev.start||start)));
  ev.end=Math.max(ev.start+1,Math.min(end,Math.ceil(+ev.end||ev.start+1)));
}
function scheduleEventBg(color){
  const map=getThemeConfig().scheduleBgMap || {};
  return map[String(color||'').toUpperCase()] || getThemeConfig().scheduleFallbackBg;
}
function parseTimeRange(text){
  const m=String(text||'').match(/(\d{1,2})(?::(\d{2}))?\s*[-—–]\s*(\d{1,2})(?::(\d{2}))?/);
  if(!m) return null;
  const min=scheduleBoard?.startHour||9, max=scheduleBoard?.endHour||18;
  const s=+m[1]+((+m[2]||0)/60), e=+m[3]+((+m[4]||0)/60);
  if(e<=s) return null;
  return {start:Math.max(min,Math.min(max,s)),end:Math.max(min,Math.min(max,e))};
}
function scheduleEditableAttr(){ return document.body.classList.contains('read-mode') ? ' contenteditable="false"' : ' contenteditable="true" spellcheck="false"'; }
function renderScheduleTimeSelect(eventIndex, field, value, startValue){
  const min=field==='end' ? Math.max((+startValue||scheduleBoard.startHour)+1,scheduleBoard.startHour+1) : scheduleBoard.startHour;
  const max=field==='end' ? scheduleBoard.endHour : scheduleBoard.endHour-1;
  let h='<select class="schedule-time-select" data-sb-time-select data-event="'+eventIndex+'" data-field="'+field+'" aria-label="'+(field==='start'?'开始时间':'结束时间')+'">';
  for(let hour=min;hour<=max;hour++) h+='<option value="'+hour+'"'+(hour===value?' selected':'')+'>'+formatHour(hour)+'</option>';
  h+='</select>';
  return h;
}
function renderScheduleBoard(){
  const mount=document.getElementById('scheduleBoardMount'); if(!mount) return;
  normalizeScheduleBoard();
  const days=scheduleBoard.days||[], start=scheduleBoard.startHour||9, end=scheduleBoard.endHour||18, span=end-start, readMode=document.body.classList.contains('read-mode');
  let h='<div class="schedule-board" contenteditable="false"><div class="schedule-board-canvas">';
  h+='<div class="schedule-board-head"><div class="schedule-board-title-wrap"><div class="schedule-board-kicker">WEEKLY SCHEDULE</div><div class="schedule-board-title">日程看板</div></div><div class="schedule-board-mark"></div></div>';
  h+='<div class="schedule-grid" style="--day-count:'+Math.max(days.length,1)+'">';
  h+='<div class="schedule-corner">TIME</div>';
  days.forEach((day,di)=>{ h+='<div class="schedule-day-head" data-sb="day" data-day="'+di+'"'+scheduleEditableAttr()+'>'+escapeHTML(day)+'</div>'; });
  h+='<div class="schedule-times">';
  getScheduleTicks().forEach(t=>h+='<div>'+escapeHTML(t)+'</div>');
  h+='</div>';
  days.forEach((day,di)=>{
    h+='<div class="schedule-lane" data-day="'+di+'">';
    for(let hour=start+1;hour<end;hour++) h+='<span class="schedule-line" style="top:'+(((hour-start)/span)*100)+'%"></span>';
    if(!readMode){
      getScheduleHours(false).forEach(hour=>{
        const top=((hour-start)/span)*100, height=(1/span)*100;
        h+='<button class="schedule-slot-add editor-only" style="top:'+top+'%;height:'+height+'%" data-sb-add-event data-day="'+di+'" data-start="'+hour+'">＋ 日程</button>';
      });
    }
    (scheduleBoard.events||[]).filter(ev=>ev.day===di).forEach((ev)=>{
      const realIndex=scheduleBoard.events.indexOf(ev), color=ev.color||themeColor(realIndex);
      const top=Math.max(0,Math.min(100,((ev.start-start)/span*100)));
      const height=Math.max(9,Math.min(100-top,((ev.end-ev.start)/span*100)));
      const compact=(ev.end-ev.start)<=1;
      h+='<article class="schedule-event'+(compact?' schedule-event-compact':'')+'" style="--event-color:'+escapeHTML(color)+';--event-bg:'+escapeHTML(scheduleEventBg(color))+';top:'+top+'%;height:'+height+'%" data-event="'+realIndex+'">';
      if(readMode) h+='<div class="schedule-event-time">'+formatHour(ev.start)+'–'+formatHour(ev.end)+'</div>';
      else h+='<div class="schedule-event-time-controls">'+renderScheduleTimeSelect(realIndex,'start',ev.start,ev.start)+'<span>–</span>'+renderScheduleTimeSelect(realIndex,'end',ev.end,ev.start)+'</div>';
      h+='<div class="schedule-event-title" data-sb="title" data-event="'+realIndex+'"'+scheduleEditableAttr()+'>'+escapeHTML(ev.title)+'</div>';
      h+='<div class="schedule-event-desc" data-sb="desc" data-event="'+realIndex+'"'+scheduleEditableAttr()+'>'+escapeHTML(ev.desc)+'</div>';
      if(!readMode) h+='<button class="schedule-event-del editor-only" data-sb-del-event data-event="'+realIndex+'">✕</button>';
      h+='</article>';
    });
    h+='</div>';
  });
  h+='</div></div></div>';
  mount.innerHTML=h;
}
function addScheduleEvent(day,startHour){
  normalizeScheduleBoard();
  const boardStart=scheduleBoard.startHour||9, boardEnd=scheduleBoard.endHour||18;
  const start=Math.max(boardStart,Math.min(boardEnd-1,Math.floor(+startHour||boardStart)));
  scheduleBoard.events.push({day,start,end:start+1,title:'新日程',desc:'请输入日程说明',color:themeColor(scheduleBoard.events.length)});
  renderScheduleBoard(); scheduleSave(); showHint('已添加日程');
}
function deleteScheduleEvent(index){
  normalizeScheduleBoard();
  scheduleBoard.events.splice(index,1);
  renderScheduleBoard(); scheduleSave(); showHint('已删除日程');
}
function updateScheduleEventTime(index,field,value){
  normalizeScheduleBoard();
  const ev=scheduleBoard.events[+index]; if(!ev) return;
  const start=scheduleBoard.startHour||9, end=scheduleBoard.endHour||18, hour=Math.floor(+value||start);
  if(field==='start'){
    ev.start=Math.max(start,Math.min(end-1,hour));
    if(ev.end<=ev.start) ev.end=ev.start+1;
  }else if(field==='end') ev.end=Math.max(ev.start+1,Math.min(end,hour));
  normalizeScheduleEvent(ev);
  renderScheduleBoard(); scheduleSave(); showHint('时间已更新');
}
function updateScheduleField(el){
  normalizeScheduleBoard();
  const field=el.dataset.sb;
  if(field==='day'){
    const di=+el.dataset.day;
    if(scheduleBoard.days[di]) scheduleBoard.days[di]=el.textContent.trim()||('周'+(di+1));
    return;
  }
  const ev=scheduleBoard.events[+el.dataset.event]; if(!ev) return;
  if(field==='time'){
    const parsed=parseTimeRange(el.textContent);
    if(parsed){ ev.start=parsed.start; ev.end=parsed.end; normalizeScheduleEvent(ev); }
    return;
  }
  if(field==='title'||field==='desc') ev[field]=el.textContent.trim();
}
content.addEventListener('input',e=>{
  const el=e.target.closest('[data-sb]');
  if(!el || document.body.classList.contains('read-mode')) return;
  updateScheduleField(el);
});
content.addEventListener('change',e=>{
  const select=e.target.closest('[data-sb-time-select]');
  if(!select || document.body.classList.contains('read-mode')) return;
  updateScheduleEventTime(+select.dataset.event,select.dataset.field,select.value);
});
content.addEventListener('click',e=>{
  if(document.body.classList.contains('read-mode')) return;
  const add=e.target.closest('[data-sb-add-event]');
  if(add){ addScheduleEvent(+add.dataset.day,+add.dataset.start); return; }
  const del=e.target.closest('[data-sb-del-event]');
  if(del){ deleteScheduleEvent(+del.dataset.event); return; }
});
function normalizeProgressBoard(){
  if(progressBoard && Array.isArray(progressBoard.columns)) return;
  const oldItems=Array.isArray(progressBoard?.items)?progressBoard.items:[];
  progressBoard=defaultProgressBoard();
  if(oldItems.length){
    progressBoard.columns.forEach(c=>c.cards=[]);
    oldItems.forEach(item=>{
      const col=item.status==='已完成'?2:(item.status==='待确认'||item.status==='准备中'?0:1);
      progressBoard.columns[col].cards.push({
        status:item.status||'推进中',
        title:item.title||'未命名项目',
        desc:(item.milestones||[]).join('；') || item.period || '请输入项目描述。',
        owner:item.owner||'负责人',
        priority:item.progress>=90?'P0':(item.progress>=60?'P1':'P2')
      });
    });
  }
}
function pbTone(col){ return col.tone || themeColor(0); }
function pbEditable(){ return !document.body.classList.contains('read-mode'); }
function editableAttr(){ return pbEditable() ? ' contenteditable="true" spellcheck="false"' : ' contenteditable="false"'; }
function renderProgressBoard(){
  const mount=document.getElementById('progressBoardMount'); if(!mount) return;
  normalizeProgressBoard();
  const cols=progressBoard.columns||[];
  const total=cols.reduce((sum,col)=>sum+(col.cards||[]).length,0);
  let h='<div class="progress-board" contenteditable="false"><div class="progress-board-canvas">';
  h+='<div class="progress-board-head"><div class="progress-board-title-wrap"><div class="progress-board-kicker">PROJECT KANBAN</div><div class="progress-board-title">项目进度看板</div></div><div class="progress-board-mark"></div></div>';
  h+='<div class="kanban-columns" style="--kanban-cols:'+Math.max(cols.length,1)+'">';
  cols.forEach((col,ci)=>{
    const cards=col.cards||[];
    h+='<section class="kanban-column" style="--col-color:'+escapeHTML(pbTone(col))+'" data-col="'+ci+'">';
    h+='<div class="kanban-column-head"><div><div class="kanban-column-kicker">COLUMN '+String(ci+1).padStart(2,'0')+'</div><div class="kanban-column-title" data-pb="columnTitle" data-col="'+ci+'"'+editableAttr()+'>'+escapeHTML(col.title)+'</div></div></div>';
    if(pbEditable()) h+='<div class="kanban-column-actions editor-only"><button class="mini-add" data-pb-add-card data-col="'+ci+'">＋ 项目卡片</button><button class="mini-add danger-mini" data-pb-del-col data-col="'+ci+'">删除栏目</button></div>';
    h+='<div class="kanban-card-list">';
    cards.forEach((card,ri)=>{
      h+='<article class="kanban-card" data-col="'+ci+'" data-card="'+ri+'">';
      h+='<div class="kanban-card-top"><span class="kanban-pill status-pill" data-pb="status" data-col="'+ci+'" data-card="'+ri+'"'+editableAttr()+'>'+escapeHTML(card.status)+'</span><span class="kanban-pill priority-pill" data-pb="priority" data-col="'+ci+'" data-card="'+ri+'"'+editableAttr()+'>'+escapeHTML(card.priority)+'</span></div>';
      h+='<div class="kanban-card-title" data-pb="title" data-col="'+ci+'" data-card="'+ri+'"'+editableAttr()+'>'+escapeHTML(card.title)+'</div>';
      h+='<div class="kanban-card-desc" data-pb="desc" data-col="'+ci+'" data-card="'+ri+'"'+editableAttr()+'>'+escapeHTML(card.desc)+'</div>';
      h+='<div class="kanban-card-foot"><span>负责人</span><b data-pb="owner" data-col="'+ci+'" data-card="'+ri+'"'+editableAttr()+'>'+escapeHTML(card.owner)+'</b></div>';
      if(pbEditable()) h+='<button class="kanban-card-del editor-only" title="删除卡片" data-pb-del-card data-col="'+ci+'" data-card="'+ri+'">✕</button>';
      h+='</article>';
    });
    h+='</div></section>';
  });
  h+='</div>';
  if(pbEditable()) h+='<div class="kanban-board-actions editor-only"><button class="mini-add" data-pb-add-col>＋ 添加栏目</button><span>'+total+' 个项目卡片 · 点击文字可直接编辑</span></div>';
  h+='</div></div>';
  mount.innerHTML=h;
}
function addProgressColumn(){
  normalizeProgressBoard();
  progressBoard.columns.push({title:'新栏目',tone:themeColor(progressBoard.columns.length),cards:[]});
  renderProgressBoard(); scheduleSave(); showHint('已添加栏目');
}
function addProgressCard(ci){
  normalizeProgressBoard();
  const col=progressBoard.columns[ci]; if(!col) return;
  col.cards.push({status:'新项目',title:'项目名称',desc:'请输入项目描述。',owner:'负责人',priority:'P2'});
  renderProgressBoard(); scheduleSave(); showHint('已添加项目卡片');
}
function deleteProgressColumn(ci){
  normalizeProgressBoard();
  if(progressBoard.columns.length<=1){ showHint('至少保留一个栏目'); return; }
  progressBoard.columns.splice(ci,1);
  renderProgressBoard(); scheduleSave(); showHint('已删除栏目');
}
function deleteProgressCard(ci,ri){
  normalizeProgressBoard();
  const cards=progressBoard.columns[ci]?.cards; if(!cards) return;
  cards.splice(ri,1);
  renderProgressBoard(); scheduleSave(); showHint('已删除项目卡片');
}
function updateProgressField(el){
  normalizeProgressBoard();
  const field=el.dataset.pb, ci=+el.dataset.col;
  if(field==='columnTitle'){
    if(progressBoard.columns[ci]) progressBoard.columns[ci].title=el.textContent.trim()||'未命名栏目';
    return;
  }
  const ri=+el.dataset.card;
  const card=progressBoard.columns[ci]?.cards?.[ri];
  if(card && field) card[field]=el.textContent.trim();
}
content.addEventListener('input',e=>{
  const el=e.target.closest('[data-pb]');
  if(!el || document.body.classList.contains('read-mode')) return;
  updateProgressField(el);
});
content.addEventListener('click',e=>{
  if(document.body.classList.contains('read-mode')) return;
  const addCol=e.target.closest('[data-pb-add-col]');
  if(addCol){ addProgressColumn(); return; }
  const addCard=e.target.closest('[data-pb-add-card]');
  if(addCard){ addProgressCard(+addCard.dataset.col); return; }
  const delCol=e.target.closest('[data-pb-del-col]');
  if(delCol){ deleteProgressColumn(+delCol.dataset.col); return; }
  const delCard=e.target.closest('[data-pb-del-card]');
  if(delCard){ deleteProgressCard(+delCard.dataset.col,+delCard.dataset.card); return; }
});
document.querySelectorAll('[data-advanced]').forEach(input=>{
  input.addEventListener('change',()=>{
    if(input.checked) insertAdvancedComponent(input.dataset.advanced);
    else removeAdvancedComponent(input.dataset.advanced);
    scheduleSave();
    showHint(input.checked?'已添加高级组件':'已移除高级组件');
  });
});
const themeSelect=document.getElementById('themeSelect');
if(themeSelect){
  themeSelect.addEventListener('change',e=>{
    applyTheme(e.target.value,{remapColors:true});
    showHint('已切换风格：'+getThemeConfig().label);
  });
}

/* =========================================================
   模式切换
========================================================= */
function setMode(read){
  document.body.classList.toggle('read-mode',read);
  document.body.classList.toggle('edit-mode',!read);
  document.getElementById('modeEdit').classList.toggle('active',!read);
  document.getElementById('modeRead').classList.toggle('active',read);
  content.querySelectorAll('.block').forEach(b=>{
    const body=b.querySelector('.block-body');
    if(b.dataset.type==='table'||isAdvancedType(b.dataset.type)) body.setAttribute('contenteditable','false');
    else body.setAttribute('contenteditable', read?'false':'true');
  });
  content.querySelectorAll('td,th').forEach(c=>{ if(c.tagName==='TD') c.setAttribute('contenteditable', read?'false':'true'); });
  document.querySelectorAll('.report-head [contenteditable]').forEach(el=>el.setAttribute('contenteditable', read?'false':'true'));
  hideTableToolbar(); closePop(); closeBlockMenu();
  renderAdvancedComponents();
  syncAdvancedPicker();
  showHint(read?'阅读模式 · 可导出 PDF / Word / 图片':'编辑模式 · 悬停区块左侧可移动 / 删除 / 插入');
}
document.getElementById('modeEdit').addEventListener('click',()=>setMode(false));
document.getElementById('modeRead').addEventListener('click',()=>setMode(true));
document.getElementById('archiveBtn').addEventListener('click',()=>{
  const name = `${getCurrentTitle()} ${fmtTs(new Date())}`;
  createReportFromCurrent(name);
  showHint('已存档：'+name);
});
document.getElementById('newReportBtn').addEventListener('click',()=>{
  isRestoring = true;
  applySnapshot(defaultSnapshot);
  isRestoring = false;
  const name = `新建周报 ${fmtTs(new Date())}`;
  createReportFromCurrent(name);
  showHint('已创建：'+name);
});
document.addEventListener('input',e=>{
  if(isRestoring) return;
  if(e.target.closest('#page')) scheduleSave();
});
document.addEventListener('click',e=>{
  if(isRestoring) return;
  if(e.target.closest('#page') && (e.target.closest('[data-bact]') || e.target.closest('[data-insert]') || e.target.closest('[data-tact]') || e.target.closest('[data-addrow],[data-delrow],[data-addgroup],[data-addmonth],[data-delmonth],.mini-add,.gantt-bar,[data-advanced],[data-sb-add-event],[data-sb-del-event]') )) scheduleSave();
});

let hintTimer;
function showHint(txt){ const h=document.getElementById('hintEdge'); h.textContent=txt; h.classList.add('show'); clearTimeout(hintTimer); hintTimer=setTimeout(()=>h.classList.remove('show'),2400); }

/* =========================================================
   导出
========================================================= */
function exportPatchCSS(){
  return `
    .exporting-image .gantt-bar{top:6px !important;transform:none !important;height:30px !important;box-sizing:border-box !important;align-items:center !important;overflow:hidden !important;}
    .exporting-image .gantt-bar .bar-txt{display:block !important;max-width:100% !important;line-height:30px !important;overflow:hidden !important;text-overflow:ellipsis !important;white-space:nowrap !important;}
    .exporting-image.theme-tundra .gantt-mark,
    .exporting-image.theme-tundra .progress-board-mark,
    .exporting-image.theme-tundra .schedule-board-mark{background:none !important;position:relative !important;}
    .exporting-image.theme-tundra .gantt-mark,
    .exporting-image.theme-tundra .progress-board-mark,
    .exporting-image.theme-tundra .schedule-board-mark{width:46px !important;height:34px !important;display:block !important;background:url("data:image/png;base64,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") no-repeat center/contain !important;color:inherit !important;}
    .exporting-image.theme-tundra .gantt-mark::before,
    .exporting-image.theme-tundra .progress-board-mark::before,
    .exporting-image.theme-tundra .schedule-board-mark::before,
    .exporting-image.theme-tundra .gantt-mark::after,
    .exporting-image.theme-tundra .progress-board-mark::after,
    .exporting-image.theme-tundra .schedule-board-mark::after{display:none !important;content:none !important;}
    .exporting-image.theme-chinese .block-body h3::before{content:"" !important;display:inline-block !important;width:16px !important;height:16px !important;margin-right:8px !important;vertical-align:-2px !important;background:url("data:image/png;base64,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") no-repeat center/contain !important;border:none !important;box-shadow:none !important;}
    .exporting-image.theme-chinese .gantt-mark,
    .exporting-image.theme-chinese .progress-board-mark,
    .exporting-image.theme-chinese .schedule-board-mark{width:42px !important;height:42px !important;display:block !important;background:url("data:image/png;base64,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") no-repeat center/contain !important;box-shadow:none !important;color:inherit !important;}
    .exporting-image.theme-chinese .gantt-mark::before,
    .exporting-image.theme-chinese .progress-board-mark::before,
    .exporting-image.theme-chinese .schedule-board-mark::before,
    .exporting-image.theme-chinese .gantt-mark::after,
    .exporting-image.theme-chinese .progress-board-mark::after,
    .exporting-image.theme-chinese .schedule-board-mark::after{display:none !important;content:none !important;}
    .exporting-image.theme-silicon .gantt-mark,
    .exporting-image.theme-silicon .progress-board-mark,
    .exporting-image.theme-silicon .schedule-board-mark{width:58px !important;height:36px !important;display:block !important;background:url("data:image/png;base64,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") no-repeat center/contain !important;box-shadow:none !important;color:inherit !important;}
    .exporting-image.theme-silicon .gantt-mark::before,
    .exporting-image.theme-silicon .progress-board-mark::before,
    .exporting-image.theme-silicon .schedule-board-mark::before,
    .exporting-image.theme-silicon .gantt-mark::after,
    .exporting-image.theme-silicon .progress-board-mark::after,
    .exporting-image.theme-silicon .schedule-board-mark::after{display:none !important;content:none !important;}
    .exporting-image.theme-klein .gantt-mark,
    .exporting-image.theme-klein .progress-board-mark,
    .exporting-image.theme-klein .schedule-board-mark{width:58px !important;height:42px !important;display:block !important;background:url("data:image/png;base64,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") no-repeat center/contain !important;box-shadow:none !important;color:inherit !important;}
    .exporting-image.theme-klein .gantt-mark::before,
    .exporting-image.theme-klein .progress-board-mark::before,
    .exporting-image.theme-klein .schedule-board-mark::before,
    .exporting-image.theme-klein .gantt-mark::after,
    .exporting-image.theme-klein .progress-board-mark::after,
    .exporting-image.theme-klein .schedule-board-mark::after{display:none !important;content:none !important;}
  `;
}
async function snapshot(scale=2){
  // 固定导出最小宽度，避免窗口较窄时表格/甘特图在导出图里被挤压变形
  const width = Math.max(1100, Math.ceil(page.getBoundingClientRect().width));
  const host = document.createElement('div');
  const bg = getThemeConfig().exportBg;
  host.style.cssText=`position:fixed;left:-100000px;top:0;width:${width}px;background:${bg};pointer-events:none;z-index:0;`;
  const clone = page.cloneNode(true);
  clone.classList.add('exporting-image', getThemeConfig().className);
  clone.style.width = width+'px';
  clone.style.minWidth = width+'px';
  clone.style.maxWidth = 'none';
  clone.style.margin = '0';
  clone.querySelectorAll('.tbl-wrap').forEach(el=>el.style.overflow='visible');
  clone.querySelectorAll('.gantt,.progress-board,.schedule-board').forEach(el=>el.style.overflow='visible');
  const patch=document.createElement('style');
  patch.textContent=exportPatchCSS();
  host.appendChild(patch);
  host.appendChild(clone);
  document.body.appendChild(host);
  try{
    if(document.fonts && document.fonts.ready){ try{ await document.fonts.ready; }catch{} }
    await new Promise(r=>setTimeout(r,80));
    const height=Math.ceil(clone.scrollHeight);
    const canvas = await html2canvas(clone,{
      scale,
      backgroundColor:bg,
      useCORS:true,
      allowTaint:false,
      width,
      height,
      windowWidth: width,
      windowHeight: height,
      imageTimeout: 15000
    });
    return canvas;
  }finally{
    host.remove();
  }
}
async function withReadModeExport(task){
  const wasRead = document.body.classList.contains('read-mode');
  if(!wasRead) setMode(true);
  try{ await task(); } finally { if(!wasRead) setMode(false); }
}
document.getElementById('exportImg').addEventListener('click',async()=>{
  await withReadModeExport(async()=>{
    showHint('正在生成图片…');
    try{
      const c=await snapshot(2);
      const a=document.createElement('a');
      a.href=c.toDataURL('image/png');
      a.download='项目周报.png';
      a.click();
    }catch(err){
      console.error('图片生成失败', err);
      showHint('图片生成失败，请稍后重试');
    }
  });
});
document.getElementById('exportPdf').addEventListener('click',async()=>{
  await withReadModeExport(async()=>{
    showHint('正在生成 PDF…');
    const canvas=await snapshot(2);
    const img=canvas.toDataURL('image/jpeg',0.95);
    const {jsPDF}=window.jspdf; const pdf=new jsPDF('p','mm','a4');
    const pw=pdf.internal.pageSize.getWidth(), ph=pdf.internal.pageSize.getHeight();
    const iw=pw, ih=canvas.height*pw/canvas.width; let left=ih, pos=0;
    pdf.addImage(img,'JPEG',0,pos,iw,ih); left-=ph;
    while(left>0){ pos-=ph; pdf.addPage(); pdf.addImage(img,'JPEG',0,pos,iw,ih); left-=ph; }
    pdf.save('项目周报.pdf');
  });
});
function collectPageStyles(){
  let styles='';
  [...document.styleSheets].forEach(sheet=>{
    try{ [...sheet.cssRules].forEach(rule=>styles+=rule.cssText+'\n'); }catch{}
  });
  return styles;
}
document.getElementById('exportWord').addEventListener('click',()=>{
  showHint('正在生成 Word…');
  const styles=collectPageStyles();
  const themeClass=getThemeConfig().className;
  const html='<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40"><head><meta charset="utf-8"><style>'+styles+'</style></head><body class="read-mode '+themeClass+'"><div class="page">'+page.innerHTML+'</div></body></html>';
  const blob=new Blob(['\ufeff',html],{type:'application/msword'});
  const a=document.createElement('a'); a.href=URL.createObjectURL(blob); a.download='项目周报.doc'; a.click();
});

/* 初始化 */
function migrateLegacyTitle(){
  document.title = '项目周报·模板';
  const titleEl = document.querySelector('.report-title');
  const legacyTitles = new Set(['项目周报·普鲁士','项目周报·新中式']);
  if(titleEl && legacyTitles.has(titleEl.textContent.trim())){
    titleEl.textContent = '项目周报·模板';
    scheduleSave();
  }
}
function migrateTemplateTerms(){
  const replacements = [
    ['共享中台在进步','知识协作平台'],
    ['共享中台','知识协作平台'],
    ['行长及总经理室','关键角色与管理团队'],
    ['重点二级行','重点区域团队'],
    ['分行管理者','区域负责人'],
    ['中台','协作平台'],
    ['MOT 事件推送','客户触达系统'],
    ['MOT事件推送','客户触达系统'],
    ['源希','项目负责人'],
    ['事件触达','消息触达'],
    ['知识沉淀','知识复用'],
    ['系统收集对接机器人','数据采集机器人'],
    ['专业团队分享','专题分享'],
  ];
  const replaceText = text => replacements.reduce((s,[from,to])=>s.split(from).join(to), text);
  let changed = false;
  const walker = document.createTreeWalker(page, NodeFilter.SHOW_TEXT, null);
  const nodes = [];
  while(walker.nextNode()) nodes.push(walker.currentNode);
  nodes.forEach(node=>{
    const next = replaceText(node.nodeValue);
    if(next !== node.nodeValue){ node.nodeValue = next; changed = true; }
  });
  if(gantt?.groups) gantt.groups.forEach(g=>{
    const name=replaceText(g.name||''); if(name!==g.name){ g.name=name; changed=true; }
    (g.rows||[]).forEach(row=>{
      const task=replaceText(row.task||''); if(task!==row.task){ row.task=task; changed=true; }
      (row.bars||[]).forEach(bar=>{ const label=replaceText(bar.label||''); if(label!==bar.label){ bar.label=label; changed=true; } });
    });
  });
  if(progressBoard?.columns) progressBoard.columns.forEach(col=>{
    (col.cards||[]).forEach(card=>{
      ['status','title','desc','owner','priority'].forEach(k=>{ const next=replaceText(card[k]||''); if(next!==card[k]){ card[k]=next; changed=true; } });
    });
  });
  if(scheduleBoard?.events) scheduleBoard.events.forEach(ev=>{
    ['title','desc'].forEach(k=>{ const next=replaceText(ev[k]||''); if(next!==ev[k]){ ev[k]=next; changed=true; } });
  });
  if(changed){ renderAdvancedComponents(); scheduleSave(); }
}

migrateLegacyTitle();
refreshAll();
content.querySelectorAll('table.report-table').forEach(enableColResize);
renderAdvancedComponents();
syncAdvancedPicker();
initReports();
migrateLegacyTitle();
migrateTemplateTerms();
window.addEventListener('load',()=>setTimeout(()=>showHint('编辑模式 · 悬停区块左侧可移动 / 删除 / 插入'),400));
