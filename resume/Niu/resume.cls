% ==================================================================
% resume.cls — 简历文档类
% ==================================================================
% 基于 article 类，为中英文简历定制，需使用 XeLaTeX 编译：
%   - A4 窄边距页面布局
%   - 中英文字体配置（宋 / 黑 / 楷 / 仿宋 + TeX Gyre Termes）
%   - 标题与列表排版
%   - 章节、个人信息、技能等排版命令
%   - Font Awesome 图标系统（见第六节）
% ==================================================================

% ==================================================================
% 一、类声明与基础设置
% ==================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}

\LoadClass[11pt]{article}

% 不使用首行缩进，段间垂直间距一律由 \vspace 显式控制
\setlength{\parindent}{0pt}

% ==================================================================
% 二、依赖包
% ==================================================================

% --- 2.1 引擎与字体 ---
% fontspec 提供 \setmainfont / \newfontfamily 等字体选择命令
% xeCJK 负责中文字体切换、标点压缩与中英文间距
\RequirePackage{fontspec}
\RequirePackage{xeCJK}

% --- 2.2 页面布局 ---
% A4 纸，左右 15mm、上下 5mm 窄边距；nohead 取消页眉，页脚由文档内 \pagestyle{empty} 清空
\RequirePackage[a4paper, left=15mm, right=15mm, top=5mm, bottom=5mm, nohead]{geometry}

% --- 2.3 标题与列表 ---
\RequirePackage{titlesec}    % \titleformat / \titlespacing 自定义标题格式
\RequirePackage{enumitem}    % \setlist 定制列表间距与缩进

% --- 2.4 链接与条件 ---
% 超链接显示为黑色，避免彩色打印失真
\RequirePackage[colorlinks=true, linkcolor=black, urlcolor=black]{hyperref}
% \ifthenelse / \isempty 用于带可选参数的命令（如 \github[显示名]{URL}）
\RequirePackage{xifthen}

% ==================================================================
% 三、字体配置
% ==================================================================

% --- 3.1 默认字体路径 ---
% 设为中文目录；英文与图标字体各自显式指定 Path，不受此项影响
\defaultfontfeatures{Path = ../assets/cn-fonts/}

% --- 3.2 英文字体：TeX Gyre Termes（Times New Roman 风格） ---
\setmainfont[
  Path       = ../assets/en-fonts/,
  Extension  = .otf,
  UprightFont    = *-regular,
  BoldFont       = *-bold,
  ItalicFont     = *-italic,
  BoldItalicFont = *-bold-italic,
  SmallCapsFont  = fontin-small-caps
]{tex-gyre-termes}

% --- 3.3 中文字体：Adobe 宋体 / 黑体 / 楷体 / 仿宋 ---
% 中文不使用斜体：\textit 仅用于英文与数字（如邮箱），故只映射 Bold / SmallCaps
\setCJKmainfont[
  BoldFont       = adobe-hei-ti-regular.otf,
  SmallCapsFont  = adobe-hei-ti-regular.otf
]{adobe-song-ti-light.otf}

\setCJKsansfont{adobe-hei-ti-regular.otf}

\setCJKmonofont[
  BoldFont      = adobe-hei-ti-regular.otf,
  SmallCapsFont = adobe-hei-ti-regular.otf
]{adobe-fang-song-regular.otf}

% --- 3.4 CJK 字体族 ---
\setCJKfamilyfont{zhsong}{adobe-song-ti-light.otf}
\setCJKfamilyfont{zhhei}{adobe-hei-ti-regular.otf}
\setCJKfamilyfont{zhfs}[
  BoldFont      = adobe-hei-ti-regular.otf,
  SmallCapsFont = adobe-hei-ti-regular.otf
]{adobe-fang-song-regular.otf}
\setCJKfamilyfont{zhkai}{adobe-kai-ti-regular.otf}

% --- 3.5 中文字体快捷命令 ---
% 用法：{\songti 内容}，作用于其后的中文
\newcommand*{\songti}{\CJKfamily{zhsong}}    % 宋体
\newcommand*{\heiti}{\CJKfamily{zhhei}}      % 黑体
\newcommand*{\kaishu}{\CJKfamily{zhkai}}     % 楷书
\newcommand*{\fangsong}{\CJKfamily{zhfs}}    % 仿宋

% ==================================================================
% 四、标题与列表格式
% ==================================================================

% --- 4.1 列表 ---
% topsep：列表整体与周围内容的间距，同时作用于列表上方和下方（本文件内各处列表的
%         上下留白均来自它）。0.1em 在正文 10.95pt 下约为 1.1pt / 0.39mm。
% itemsep：条目之间的间距，由 noitemsep 置为 0，条目紧靠行高排列。
\setlist{noitemsep}
\setlist[itemize]{topsep=0.1em, leftmargin=1.5pc}
\setlist[enumerate]{topsep=0.1em, leftmargin=1.5pc}

% --- 4.2 Section 标题（一级：14.4pt 楷书粗体 + 通栏分隔线）---
% 字体与分隔线在此统一，正文用 \cvsection{图标}{标题} 即可
%
% 间距一律用绝对单位 pt（相对单位会随字号缩放，且与 after-sep 叠加易变负值导致重叠）
% \rule 与 \vspace 会把 \prevdepth 置为 -1000pt，其后不再插入 \baselineskip，故各项直接相加：
%   上一板块 → 标题 3pt ｜ 标题基线 → 横线 18pt-15pt=3pt ｜ 横线 → 正文 0pt
% 改字号时只需重算中间项：负间距 = 新字号行距 - 3pt
\titleformat{\section}
  {\Large\kaishu\bfseries\raggedright}
  {}{0em}
  {}
  [\vspace{-15pt}\rule{\linewidth}{1.2pt}]
\titlespacing*{\section}{0cm}{3pt}{0pt}

% --- 4.3 Subsection 标题（二级：12pt 楷书 + 左对齐）---
% 同样用绝对单位：上方 5pt、下方 3pt；同 section 内相邻条目用 \gapProject 分隔（见 4.4）
\titleformat{\subsection}
  {\kaishu\large\raggedright}
  {}{0em}
  {}
\titlespacing*{\subsection}{0cm}{5pt}{3pt}

% --- 4.4 垂直间距常量 ---
% 正文统一引用，避免各处硬编码数值（1pt = 0.3515mm）
% 常量后若紧接标题，须以对应抵消命令结尾，扣掉标题自带前距（section 3pt、subsection 5pt），
% 否则实际间距会多出一截（叠加规则同 4.2）

\newcommand*{\gapBeforeSec}{\vspace{-3pt}}       % 抵消 section 自带前距（= -4.2 的 before-sep）
\newcommand*{\gapBeforeSubsec}{\vspace{-5pt}}    % 抵消 subsection 自带前距（= -4.3 的 before-sep）
\newcommand{\gapEntry}{\vspace{1mm}\gapBeforeSec}        % 基本信息区 → 首个 section（净 1mm）
\newcommand{\gapProject}{\vspace{1.5mm}\gapBeforeSubsec} % 相邻项目之间（净 1.5mm）
% 列表底部还会加一次 topsep（约 0.38mm），故此处 0.36mm 使总间距为 0.75mm
\newcommand{\gapDetail}{\vspace{0.36mm}}                 % 条目内附属内容（如要点列表 → 技术栈行）

% ==================================================================
% 五、自定义命令
% ==================================================================

% --- 5.1 章节与日期 ---
% 带图标的章节标题：\cvsection{图标}{标题}
% 图标固定占 1.2em 宽并左对齐，保证各章节标题文字左端对齐
% 第二参数同时作为 PDF 书签文本，无需再写 \texorpdfstring
% \mdseries 用于抵消 section 的 \bfseries：图标字体仅有 regular 字形，
% 若沿用加粗，会请求 b/n 而回退并告警，且会把该字体额外嵌入一份加粗子集（PDF 体积翻倍）
\newcommand{\cvsection}[2]{%
  \section{\texorpdfstring{\makebox[1.2em][l]{\mdseries#1}~#2}{#2}}}

% 标题左对齐、日期右对齐（\hfill）；方括号参数为书签中显示的纯文本
\newcommand{\datedsection}[2]{\section[#1]{#1 \hfill #2}}
\newcommand{\datedsubsection}[2]{\subsection[#1]{#1 \hfill #2}}
% 列表项中的「内容 \hfill 日期」
\newcommand{\datedline}[2]{{\par #1 \hfill #2 \par}}

% --- 5.2 个人信息 ---
% 以下五个命令当前简历未使用（姓名区在文档内手工排版），保留作通用接口
\newcommand{\name}[1]{\centerline{\Huge\scshape{#1}}\vspace{1em}}              % 姓名，居中大号
\newcommand{\basicInfo}[1]{\centerline{\ttfamily\large{#1}}\vspace{1.25ex}}    % 信息行，等宽居中
\newcommand{\email}[1]{\faEnvelope\ {\textbf{#1}}}                             % 邮箱
\newcommand{\phone}[1]{\faPhone\ {\textbf{#1}}}                                % 电话
% 微信：图标正式名为 weixin，无 wechat 别名
\newcommand{\Wechat}[1]{\faWeixin\ {\textbf{#1}}}

% 带图标的链接：可选参数 #1 为显示文字，省略时直接显示 URL #2
\newcommand{\linkedin}[2][]{\faLinkedin\
  \ifthenelse{\isempty{#1}}
    {\href{#2}{#2}}
    {\href{#2}{#1}}}

\newcommand{\github}[2][]{\faGithub\
  \ifthenelse{\isempty{#1}}
    {\href{#2}{#2}}
    {\href{#2}{#1}}}

\newcommand{\homepage}[2][]{\faLink\
  \ifthenelse{\isempty{#1}}
    {\href{#2}{#2}}
    {\href{#2}{#1}}}

% --- 5.3 角色 ---
% 当前简历未使用（部门与职位已并入 subsection 标题行），保留作通用接口
% #1 部门、#2 职位；中文无真正斜体，改用「楷书粗体 + 楷书正体」区分层级
% 前后 \vspace{-0.2em} 用于收紧与上下内容的间距
\newcommand{\role}[2]{%
  \vspace{-0.2em}%
  {\par\kaishu\textbf{#1} ~ #2}%
  \vspace{-0.2em}}

% ==================================================================
% 六、附录：Font Awesome 图标系统
% ==================================================================
% 字体：../assets/icon-fonts/font-awesome（Font Awesome 4.6.3）
% 用法：\faGraduationCap，或 \faicon{图标名}
% 新增图标需成对添加：6.3 加别名 \def\faXxx{\faicon{xxx}}，6.4 加字形 \csname faicon@xxx\endcsname
% glyph 码位查 https://fontawesome.com/v4.7.0/icons/（与 4.6.3 码位一致）
% 已知问题：该字体有 51 个 glyph 未命名，子集化时 xdvipdfmx 报 "Invalid glyph name component"，
%           属字体文件缺陷，不影响输出，勿据此认为配置有误
% ==================================================================

% --- 6.1 图标字体族 ---
% Bold/Italic 均指向自身：该字体仅有 regular 字形；若不声明，
% \bfseries 作用域内（如 section 标题）的图标会回退，导致与标题粗细不一致
\newfontfamily{\FA}[
  Path          = ../assets/icon-fonts/,
  Scale         = 0.85,
  BoldFont      = font-awesome,
  ItalicFont    = font-awesome,
  SmallCapsFont = *
]{font-awesome}

% --- 6.2 通用图标命令 ---
\newcommand*{\faicon}[1]{{\csname faicon@#1\endcsname}}

% --- 6.3 图标定义 ---

% 联系与社交
\def\faEnvelope{\faicon{envelope}}
\def\faEnvelopeO{\faicon{envelope-o}}
\def\faEnvelopeSquare{\faicon{envelope-square}}
\def\faAt{\faicon{at}}
\def\faPhone{\faicon{phone}}
\def\faPhoneSquare{\faicon{phone-square}}
\def\faMobile{\faicon{mobile}}
\def\faFax{\faicon{fax}}
\def\faWeixin{\faicon{weixin}}
\def\faQq{\faicon{qq}}
\def\faWeibo{\faicon{weibo}}
\def\faGithub{\faicon{github}}
\def\faGithubAlt{\faicon{github-alt}}
\def\faGithubSquare{\faicon{github-square}}
\def\faGit{\faicon{git}}
\def\faGitlab{\faicon{gitlab}}
\def\faBitbucket{\faicon{bitbucket}}
\def\faLinkedin{\faicon{linkedin}}
\def\faLinkedinSquare{\faicon{linkedin-square}}
\def\faTwitter{\faicon{twitter}}
\def\faStackOverflow{\faicon{stack-overflow}}
\def\faSlack{\faicon{slack}}
\def\faSkype{\faicon{skype}}
\def\faGlobe{\faicon{globe}}
\def\faRss{\faicon{rss}}
\def\faHome{\faicon{home}}
\def\faLink{\faicon{link}}
\def\faExternalLink{\faicon{external-link}}
\def\faExternalLinkSquare{\faicon{external-link-square}}
\def\faPaperclip{\faicon{paperclip}}

% 位置与时间
\def\faMapMarker{\faicon{map-marker}}
\def\faMapPin{\faicon{map-pin}}
\def\faMapO{\faicon{map-o}}
\def\faLocationArrow{\faicon{location-arrow}}
\def\faCalendar{\faicon{calendar}}
\def\faCalendarO{\faicon{calendar-o}}
\def\faClockO{\faicon{clock-o}}
\def\faHistory{\faicon{history}}

% 文件与文档
\def\faFile{\faicon{file}}
\def\faFileO{\faicon{file-o}}
\def\faFileText{\faicon{file-text}}
\def\faFileTextO{\faicon{file-text-o}}
\def\faFilePdfO{\faicon{file-pdf-o}}
\def\faFileWordO{\faicon{file-word-o}}
\def\faFileCodeO{\faicon{file-code-o}}
\def\faFileImageO{\faicon{file-image-o}}
\def\faFileArchiveO{\faicon{file-archive-o}}
\def\faFolder{\faicon{folder}}
\def\faFolderOpen{\faicon{folder-open}}
\def\faArchive{\faicon{archive}}
\def\faDownload{\faicon{download}}
\def\faUpload{\faicon{upload}}
\def\faCloud{\faicon{cloud}}
\def\faCloudUpload{\faicon{cloud-upload}}
\def\faCloudDownload{\faicon{cloud-download}}
\def\faFloppyO{\faicon{floppy-o}}
\def\faPrint{\faicon{print}}
\def\faBook{\faicon{book}}
\def\faBookmark{\faicon{bookmark}}
\def\faNewspaperO{\faicon{newspaper-o}}

% 教育、工作与团队
\def\faGraduationCap{\faicon{graduation-cap}}
\def\faUniversity{\faicon{university}}
\def\faBriefcase{\faicon{briefcase}}
\def\faSuitcase{\faicon{suitcase}}
\def\faBuilding{\faicon{building}}
\def\faBuildingO{\faicon{building-o}}
\def\faIndustry{\faicon{industry}}
\def\faBalanceScale{\faicon{balance-scale}}
\def\faGavel{\faicon{gavel}}
\def\faUser{\faicon{user}}
\def\faUsers{\faicon{users}}
\def\faUserPlus{\faicon{user-plus}}
\def\faComments{\faicon{comments}}
\def\faCommentsO{\faicon{comments-o}}
\def\faLanguage{\faicon{language}}

% 技术与工具
\def\faCode{\faicon{code}}
\def\faCodeFork{\faicon{code-fork}}
\def\faTerminal{\faicon{terminal}}
\def\faDatabase{\faicon{database}}
\def\faServer{\faicon{server}}
\def\faCog{\faicon{cog}}
\def\faCogs{\faicon{cogs}}
\def\faWrench{\faicon{wrench}}
\def\faFilter{\faicon{filter}}
\def\faSliders{\faicon{sliders}}
\def\faCube{\faicon{cube}}
\def\faCubes{\faicon{cubes}}
\def\faKey{\faicon{key}}
\def\faLock{\faicon{lock}}
\def\faUnlock{\faicon{unlock}}
\def\faShield{\faicon{shield}}
\def\faPlug{\faicon{plug}}
\def\faWifi{\faicon{wifi}}
\def\faLaptop{\faicon{laptop}}
\def\faDesktop{\faicon{desktop}}
\def\faTablet{\faicon{tablet}}
\def\faRocket{\faicon{rocket}}
\def\faBolt{\faicon{bolt}}
\def\faMagic{\faicon{magic}}
\def\faSitemap{\faicon{sitemap}}
\def\faPuzzlePiece{\faicon{puzzle-piece}}
\def\faObjectGroup{\faicon{object-group}}
\def\faTasks{\faicon{tasks}}
\def\faClipboard{\faicon{clipboard}}
\def\faCalculator{\faicon{calculator}}
\def\faSearch{\faicon{search}}
\def\faBug{\faicon{bug}}
\def\faFlask{\faicon{flask}}
\def\faLightbulbO{\faicon{lightbulb-o}}
\def\faEye{\faicon{eye}}
\def\faCompass{\faicon{compass}}
\def\faBinoculars{\faicon{binoculars}}
\def\faStickyNote{\faicon{sticky-note}}
\def\faHashtag{\faicon{hashtag}}
\def\faPercent{\faicon{percent}}
\def\faCrosshairs{\faicon{crosshairs}}
\def\faBullseye{\faicon{bullseye}}

% 数据与图表
\def\faBarChart{\faicon{bar-chart}}
\def\faLineChart{\faicon{line-chart}}
\def\faPieChart{\faicon{pie-chart}}
\def\faAreaChart{\faicon{area-chart}}
\def\faTable{\faicon{table}}
\def\faListUl{\faicon{list-ul}}
\def\faListOl{\faicon{list-ol}}
\def\faTachometer{\faicon{tachometer}}
\def\faSignal{\faicon{signal}}
\def\faSort{\faicon{sort}}

% 奖项与标记
\def\faTrophy{\faicon{trophy}}
\def\faCertificate{\faicon{certificate}}
\def\faStar{\faicon{star}}
\def\faStarO{\faicon{star-o}}
\def\faStarHalf{\faicon{star-half}}
\def\faStarHalfO{\faicon{star-half-o}}
\def\faHeart{\faicon{heart}}
\def\faHeartO{\faicon{heart-o}}
\def\faThumbsUp{\faicon{thumbs-up}}
\def\faThumbsOUp{\faicon{thumbs-o-up}}
\def\faFlag{\faicon{flag}}
\def\faFlagO{\faicon{flag-o}}
\def\faFire{\faicon{fire}}
\def\faDiamond{\faicon{diamond}}
\def\faTag{\faicon{tag}}
\def\faTags{\faicon{tags}}
\def\faThumbTack{\faicon{thumb-tack}}
\def\faCheck{\faicon{check}}
\def\faCheckCircle{\faicon{check-circle}}
\def\faCheckCircleO{\faicon{check-circle-o}}
\def\faCheckSquare{\faicon{check-square}}
\def\faCheckSquareO{\faicon{check-square-o}}

% 符号与箭头
\def\faCircle{\faicon{circle}}
\def\faCircleO{\faicon{circle-o}}
\def\faDotCircleO{\faicon{dot-circle-o}}
\def\faSquare{\faicon{square}}
\def\faSquareO{\faicon{square-o}}
\def\faAngleRight{\faicon{angle-right}}
\def\faAngleLeft{\faicon{angle-left}}
\def\faAngleUp{\faicon{angle-up}}
\def\faAngleDown{\faicon{angle-down}}
\def\faAngleDoubleRight{\faicon{angle-double-right}}
\def\faChevronRight{\faicon{chevron-right}}
\def\faChevronLeft{\faicon{chevron-left}}
\def\faCaretRight{\faicon{caret-right}}
\def\faCaretDown{\faicon{caret-down}}
\def\faCaretUp{\faicon{caret-up}}
\def\faArrowRight{\faicon{arrow-right}}
\def\faArrowLeft{\faicon{arrow-left}}
\def\faArrowUp{\faicon{arrow-up}}
\def\faArrowDown{\faicon{arrow-down}}
\def\faLongArrowRight{\faicon{long-arrow-right}}
\def\faEllipsisH{\faicon{ellipsis-h}}
\def\faEllipsisV{\faicon{ellipsis-v}}
\def\faPlus{\faicon{plus}}
\def\faMinus{\faicon{minus}}
\def\faTimes{\faicon{times}}
\def\faHandORight{\faicon{hand-o-right}}
\def\faExclamationCircle{\faicon{exclamation-circle}}
\def\faExclamationTriangle{\faicon{exclamation-triangle}}
\def\faInfoCircle{\faicon{info-circle}}
\def\faQuestionCircle{\faicon{question-circle}}
\def\faBan{\faicon{ban}}

% 其它常用
\def\faBell{\faicon{bell}}
\def\faBellO{\faicon{bell-o}}
\def\faTrashO{\faicon{trash-o}}
\def\faPencil{\faicon{pencil}}
\def\faPencilSquareO{\faicon{pencil-square-o}}
\def\faRefresh{\faicon{refresh}}
\def\faRepeat{\faicon{repeat}}
\def\faUndo{\faicon{undo}}
\def\faCopyright{\faicon{copyright}}
\def\faRegistered{\faicon{registered}}
\def\faTrademark{\faicon{trademark}}
\def\faMars{\faicon{mars}}
\def\faVenus{\faicon{venus}}
\def\faMale{\faicon{male}}
\def\faFemale{\faicon{female}}
\def\faChild{\faicon{child}}
\def\faPaperPlane{\faicon{paper-plane}}
\def\faHeartbeat{\faicon{heartbeat}}
\def\faSmileO{\faicon{smile-o}}

% --- 6.4 字形定义（与 6.3 的别名一一对应）---
\expandafter\def\csname faicon@envelope\endcsname{{\FA\symbol{"F0E0}}}
\expandafter\def\csname faicon@envelope-o\endcsname{{\FA\symbol{"F003}}}
\expandafter\def\csname faicon@envelope-square\endcsname{{\FA\symbol{"F199}}}
\expandafter\def\csname faicon@at\endcsname{{\FA\symbol{"F1FA}}}
\expandafter\def\csname faicon@phone\endcsname{{\FA\symbol{"F095}}}
\expandafter\def\csname faicon@phone-square\endcsname{{\FA\symbol{"F098}}}
\expandafter\def\csname faicon@mobile\endcsname{{\FA\symbol{"F10B}}}
\expandafter\def\csname faicon@fax\endcsname{{\FA\symbol{"F1AC}}}
\expandafter\def\csname faicon@weixin\endcsname{{\FA\symbol{"F1D7}}}
\expandafter\def\csname faicon@qq\endcsname{{\FA\symbol{"F1D6}}}
\expandafter\def\csname faicon@weibo\endcsname{{\FA\symbol{"F18A}}}
\expandafter\def\csname faicon@github\endcsname{{\FA\symbol{"F09B}}}
\expandafter\def\csname faicon@github-alt\endcsname{{\FA\symbol{"F113}}}
\expandafter\def\csname faicon@github-square\endcsname{{\FA\symbol{"F092}}}
\expandafter\def\csname faicon@git\endcsname{{\FA\symbol{"F1D3}}}
\expandafter\def\csname faicon@gitlab\endcsname{{\FA\symbol{"F296}}}
\expandafter\def\csname faicon@bitbucket\endcsname{{\FA\symbol{"F171}}}
\expandafter\def\csname faicon@linkedin\endcsname{{\FA\symbol{"F0E1}}}
\expandafter\def\csname faicon@linkedin-square\endcsname{{\FA\symbol{"F08C}}}
\expandafter\def\csname faicon@twitter\endcsname{{\FA\symbol{"F099}}}
\expandafter\def\csname faicon@stack-overflow\endcsname{{\FA\symbol{"F16C}}}
\expandafter\def\csname faicon@slack\endcsname{{\FA\symbol{"F198}}}
\expandafter\def\csname faicon@skype\endcsname{{\FA\symbol{"F17E}}}
\expandafter\def\csname faicon@globe\endcsname{{\FA\symbol{"F0AC}}}
\expandafter\def\csname faicon@rss\endcsname{{\FA\symbol{"F09E}}}
\expandafter\def\csname faicon@home\endcsname{{\FA\symbol{"F015}}}
\expandafter\def\csname faicon@link\endcsname{{\FA\symbol{"F0C1}}}
\expandafter\def\csname faicon@external-link\endcsname{{\FA\symbol{"F08E}}}
\expandafter\def\csname faicon@external-link-square\endcsname{{\FA\symbol{"F14C}}}
\expandafter\def\csname faicon@paperclip\endcsname{{\FA\symbol{"F0C6}}}
\expandafter\def\csname faicon@map-marker\endcsname{{\FA\symbol{"F041}}}
\expandafter\def\csname faicon@map-pin\endcsname{{\FA\symbol{"F276}}}
\expandafter\def\csname faicon@map-o\endcsname{{\FA\symbol{"F278}}}
\expandafter\def\csname faicon@location-arrow\endcsname{{\FA\symbol{"F124}}}
\expandafter\def\csname faicon@calendar\endcsname{{\FA\symbol{"F073}}}
\expandafter\def\csname faicon@calendar-o\endcsname{{\FA\symbol{"F133}}}
\expandafter\def\csname faicon@clock-o\endcsname{{\FA\symbol{"F017}}}
\expandafter\def\csname faicon@history\endcsname{{\FA\symbol{"F1DA}}}
\expandafter\def\csname faicon@file\endcsname{{\FA\symbol{"F15B}}}
\expandafter\def\csname faicon@file-o\endcsname{{\FA\symbol{"F016}}}
\expandafter\def\csname faicon@file-text\endcsname{{\FA\symbol{"F15C}}}
\expandafter\def\csname faicon@file-text-o\endcsname{{\FA\symbol{"F0F6}}}
\expandafter\def\csname faicon@file-pdf-o\endcsname{{\FA\symbol{"F1C1}}}
\expandafter\def\csname faicon@file-word-o\endcsname{{\FA\symbol{"F1C2}}}
\expandafter\def\csname faicon@file-code-o\endcsname{{\FA\symbol{"F1C9}}}
\expandafter\def\csname faicon@file-image-o\endcsname{{\FA\symbol{"F1C5}}}
\expandafter\def\csname faicon@file-archive-o\endcsname{{\FA\symbol{"F1C6}}}
\expandafter\def\csname faicon@folder\endcsname{{\FA\symbol{"F07B}}}
\expandafter\def\csname faicon@folder-open\endcsname{{\FA\symbol{"F07C}}}
\expandafter\def\csname faicon@archive\endcsname{{\FA\symbol{"F187}}}
\expandafter\def\csname faicon@download\endcsname{{\FA\symbol{"F019}}}
\expandafter\def\csname faicon@upload\endcsname{{\FA\symbol{"F093}}}
\expandafter\def\csname faicon@cloud\endcsname{{\FA\symbol{"F0C2}}}
\expandafter\def\csname faicon@cloud-upload\endcsname{{\FA\symbol{"F0EE}}}
\expandafter\def\csname faicon@cloud-download\endcsname{{\FA\symbol{"F0ED}}}
\expandafter\def\csname faicon@floppy-o\endcsname{{\FA\symbol{"F0C7}}}
\expandafter\def\csname faicon@print\endcsname{{\FA\symbol{"F02F}}}
\expandafter\def\csname faicon@book\endcsname{{\FA\symbol{"F02D}}}
\expandafter\def\csname faicon@bookmark\endcsname{{\FA\symbol{"F02E}}}
\expandafter\def\csname faicon@newspaper-o\endcsname{{\FA\symbol{"F1EA}}}
\expandafter\def\csname faicon@graduation-cap\endcsname{{\FA\symbol{"F19D}}}
\expandafter\def\csname faicon@university\endcsname{{\FA\symbol{"F19C}}}
\expandafter\def\csname faicon@briefcase\endcsname{{\FA\symbol{"F0B1}}}
\expandafter\def\csname faicon@suitcase\endcsname{{\FA\symbol{"F0F2}}}
\expandafter\def\csname faicon@building\endcsname{{\FA\symbol{"F1AD}}}
\expandafter\def\csname faicon@building-o\endcsname{{\FA\symbol{"F0F7}}}
\expandafter\def\csname faicon@industry\endcsname{{\FA\symbol{"F275}}}
\expandafter\def\csname faicon@balance-scale\endcsname{{\FA\symbol{"F24E}}}
\expandafter\def\csname faicon@gavel\endcsname{{\FA\symbol{"F0E3}}}
\expandafter\def\csname faicon@user\endcsname{{\FA\symbol{"F007}}}
\expandafter\def\csname faicon@users\endcsname{{\FA\symbol{"F0C0}}}
\expandafter\def\csname faicon@user-plus\endcsname{{\FA\symbol{"F234}}}
\expandafter\def\csname faicon@comments\endcsname{{\FA\symbol{"F086}}}
\expandafter\def\csname faicon@comments-o\endcsname{{\FA\symbol{"F0E6}}}
\expandafter\def\csname faicon@language\endcsname{{\FA\symbol{"F1AB}}}
\expandafter\def\csname faicon@code\endcsname{{\FA\symbol{"F121}}}
\expandafter\def\csname faicon@code-fork\endcsname{{\FA\symbol{"F126}}}
\expandafter\def\csname faicon@terminal\endcsname{{\FA\symbol{"F120}}}
\expandafter\def\csname faicon@database\endcsname{{\FA\symbol{"F1C0}}}
\expandafter\def\csname faicon@server\endcsname{{\FA\symbol{"F233}}}
\expandafter\def\csname faicon@cog\endcsname{{\FA\symbol{"F013}}}
\expandafter\def\csname faicon@cogs\endcsname{{\FA\symbol{"F085}}}
\expandafter\def\csname faicon@wrench\endcsname{{\FA\symbol{"F0AD}}}
\expandafter\def\csname faicon@filter\endcsname{{\FA\symbol{"F0B0}}}
\expandafter\def\csname faicon@sliders\endcsname{{\FA\symbol{"F1DE}}}
\expandafter\def\csname faicon@cube\endcsname{{\FA\symbol{"F1B2}}}
\expandafter\def\csname faicon@cubes\endcsname{{\FA\symbol{"F1B3}}}
\expandafter\def\csname faicon@key\endcsname{{\FA\symbol{"F084}}}
\expandafter\def\csname faicon@lock\endcsname{{\FA\symbol{"F023}}}
\expandafter\def\csname faicon@unlock\endcsname{{\FA\symbol{"F09C}}}
\expandafter\def\csname faicon@shield\endcsname{{\FA\symbol{"F132}}}
\expandafter\def\csname faicon@plug\endcsname{{\FA\symbol{"F1E6}}}
\expandafter\def\csname faicon@wifi\endcsname{{\FA\symbol{"F1EB}}}
\expandafter\def\csname faicon@laptop\endcsname{{\FA\symbol{"F109}}}
\expandafter\def\csname faicon@desktop\endcsname{{\FA\symbol{"F108}}}
\expandafter\def\csname faicon@tablet\endcsname{{\FA\symbol{"F10A}}}
\expandafter\def\csname faicon@rocket\endcsname{{\FA\symbol{"F135}}}
\expandafter\def\csname faicon@bolt\endcsname{{\FA\symbol{"F0E7}}}
\expandafter\def\csname faicon@magic\endcsname{{\FA\symbol{"F0D0}}}
\expandafter\def\csname faicon@sitemap\endcsname{{\FA\symbol{"F0E8}}}
\expandafter\def\csname faicon@puzzle-piece\endcsname{{\FA\symbol{"F12E}}}
\expandafter\def\csname faicon@object-group\endcsname{{\FA\symbol{"F247}}}
\expandafter\def\csname faicon@tasks\endcsname{{\FA\symbol{"F0AE}}}
\expandafter\def\csname faicon@clipboard\endcsname{{\FA\symbol{"F0EA}}}
\expandafter\def\csname faicon@calculator\endcsname{{\FA\symbol{"F1EC}}}
\expandafter\def\csname faicon@search\endcsname{{\FA\symbol{"F002}}}
\expandafter\def\csname faicon@bug\endcsname{{\FA\symbol{"F188}}}
\expandafter\def\csname faicon@flask\endcsname{{\FA\symbol{"F0C3}}}
\expandafter\def\csname faicon@lightbulb-o\endcsname{{\FA\symbol{"F0EB}}}
\expandafter\def\csname faicon@eye\endcsname{{\FA\symbol{"F06E}}}
\expandafter\def\csname faicon@compass\endcsname{{\FA\symbol{"F14E}}}
\expandafter\def\csname faicon@binoculars\endcsname{{\FA\symbol{"F1E5}}}
\expandafter\def\csname faicon@sticky-note\endcsname{{\FA\symbol{"F249}}}
\expandafter\def\csname faicon@hashtag\endcsname{{\FA\symbol{"F292}}}
\expandafter\def\csname faicon@percent\endcsname{{\FA\symbol{"F295}}}
\expandafter\def\csname faicon@crosshairs\endcsname{{\FA\symbol{"F05B}}}
\expandafter\def\csname faicon@bullseye\endcsname{{\FA\symbol{"F140}}}
\expandafter\def\csname faicon@bar-chart\endcsname{{\FA\symbol{"F080}}}
\expandafter\def\csname faicon@line-chart\endcsname{{\FA\symbol{"F201}}}
\expandafter\def\csname faicon@pie-chart\endcsname{{\FA\symbol{"F200}}}
\expandafter\def\csname faicon@area-chart\endcsname{{\FA\symbol{"F1FE}}}
\expandafter\def\csname faicon@table\endcsname{{\FA\symbol{"F0CE}}}
\expandafter\def\csname faicon@list-ul\endcsname{{\FA\symbol{"F0CA}}}
\expandafter\def\csname faicon@list-ol\endcsname{{\FA\symbol{"F0CB}}}
\expandafter\def\csname faicon@tachometer\endcsname{{\FA\symbol{"F0E4}}}
\expandafter\def\csname faicon@signal\endcsname{{\FA\symbol{"F012}}}
\expandafter\def\csname faicon@sort\endcsname{{\FA\symbol{"F0DC}}}
\expandafter\def\csname faicon@trophy\endcsname{{\FA\symbol{"F091}}}
\expandafter\def\csname faicon@certificate\endcsname{{\FA\symbol{"F0A3}}}
\expandafter\def\csname faicon@star\endcsname{{\FA\symbol{"F005}}}
\expandafter\def\csname faicon@star-o\endcsname{{\FA\symbol{"F006}}}
\expandafter\def\csname faicon@star-half\endcsname{{\FA\symbol{"F089}}}
\expandafter\def\csname faicon@star-half-o\endcsname{{\FA\symbol{"F123}}}
\expandafter\def\csname faicon@heart\endcsname{{\FA\symbol{"F004}}}
\expandafter\def\csname faicon@heart-o\endcsname{{\FA\symbol{"F08A}}}
\expandafter\def\csname faicon@thumbs-up\endcsname{{\FA\symbol{"F164}}}
\expandafter\def\csname faicon@thumbs-o-up\endcsname{{\FA\symbol{"F087}}}
\expandafter\def\csname faicon@flag\endcsname{{\FA\symbol{"F024}}}
\expandafter\def\csname faicon@flag-o\endcsname{{\FA\symbol{"F11D}}}
\expandafter\def\csname faicon@fire\endcsname{{\FA\symbol{"F06D}}}
\expandafter\def\csname faicon@diamond\endcsname{{\FA\symbol{"F219}}}
\expandafter\def\csname faicon@tag\endcsname{{\FA\symbol{"F02B}}}
\expandafter\def\csname faicon@tags\endcsname{{\FA\symbol{"F02C}}}
\expandafter\def\csname faicon@thumb-tack\endcsname{{\FA\symbol{"F08D}}}
\expandafter\def\csname faicon@check\endcsname{{\FA\symbol{"F00C}}}
\expandafter\def\csname faicon@check-circle\endcsname{{\FA\symbol{"F058}}}
\expandafter\def\csname faicon@check-circle-o\endcsname{{\FA\symbol{"F05D}}}
\expandafter\def\csname faicon@check-square\endcsname{{\FA\symbol{"F14A}}}
\expandafter\def\csname faicon@check-square-o\endcsname{{\FA\symbol{"F046}}}
\expandafter\def\csname faicon@circle\endcsname{{\FA\symbol{"F111}}}
\expandafter\def\csname faicon@circle-o\endcsname{{\FA\symbol{"F10C}}}
\expandafter\def\csname faicon@dot-circle-o\endcsname{{\FA\symbol{"F192}}}
\expandafter\def\csname faicon@square\endcsname{{\FA\symbol{"F0C8}}}
\expandafter\def\csname faicon@square-o\endcsname{{\FA\symbol{"F096}}}
\expandafter\def\csname faicon@angle-right\endcsname{{\FA\symbol{"F105}}}
\expandafter\def\csname faicon@angle-left\endcsname{{\FA\symbol{"F104}}}
\expandafter\def\csname faicon@angle-up\endcsname{{\FA\symbol{"F106}}}
\expandafter\def\csname faicon@angle-down\endcsname{{\FA\symbol{"F107}}}
\expandafter\def\csname faicon@angle-double-right\endcsname{{\FA\symbol{"F101}}}
\expandafter\def\csname faicon@chevron-right\endcsname{{\FA\symbol{"F054}}}
\expandafter\def\csname faicon@chevron-left\endcsname{{\FA\symbol{"F053}}}
\expandafter\def\csname faicon@caret-right\endcsname{{\FA\symbol{"F0DA}}}
\expandafter\def\csname faicon@caret-down\endcsname{{\FA\symbol{"F0D7}}}
\expandafter\def\csname faicon@caret-up\endcsname{{\FA\symbol{"F0D8}}}
\expandafter\def\csname faicon@arrow-right\endcsname{{\FA\symbol{"F061}}}
\expandafter\def\csname faicon@arrow-left\endcsname{{\FA\symbol{"F060}}}
\expandafter\def\csname faicon@arrow-up\endcsname{{\FA\symbol{"F062}}}
\expandafter\def\csname faicon@arrow-down\endcsname{{\FA\symbol{"F063}}}
\expandafter\def\csname faicon@long-arrow-right\endcsname{{\FA\symbol{"F178}}}
\expandafter\def\csname faicon@ellipsis-h\endcsname{{\FA\symbol{"F141}}}
\expandafter\def\csname faicon@ellipsis-v\endcsname{{\FA\symbol{"F142}}}
\expandafter\def\csname faicon@plus\endcsname{{\FA\symbol{"F067}}}
\expandafter\def\csname faicon@minus\endcsname{{\FA\symbol{"F068}}}
\expandafter\def\csname faicon@times\endcsname{{\FA\symbol{"F00D}}}
\expandafter\def\csname faicon@hand-o-right\endcsname{{\FA\symbol{"F0A4}}}
\expandafter\def\csname faicon@exclamation-circle\endcsname{{\FA\symbol{"F06A}}}
\expandafter\def\csname faicon@exclamation-triangle\endcsname{{\FA\symbol{"F071}}}
\expandafter\def\csname faicon@info-circle\endcsname{{\FA\symbol{"F05A}}}
\expandafter\def\csname faicon@question-circle\endcsname{{\FA\symbol{"F059}}}
\expandafter\def\csname faicon@ban\endcsname{{\FA\symbol{"F05E}}}
\expandafter\def\csname faicon@bell\endcsname{{\FA\symbol{"F0F3}}}
\expandafter\def\csname faicon@bell-o\endcsname{{\FA\symbol{"F0A2}}}
\expandafter\def\csname faicon@trash-o\endcsname{{\FA\symbol{"F014}}}
\expandafter\def\csname faicon@pencil\endcsname{{\FA\symbol{"F040}}}
\expandafter\def\csname faicon@pencil-square-o\endcsname{{\FA\symbol{"F044}}}
\expandafter\def\csname faicon@refresh\endcsname{{\FA\symbol{"F021}}}
\expandafter\def\csname faicon@repeat\endcsname{{\FA\symbol{"F01E}}}
\expandafter\def\csname faicon@undo\endcsname{{\FA\symbol{"F0E2}}}
\expandafter\def\csname faicon@copyright\endcsname{{\FA\symbol{"F1F9}}}
\expandafter\def\csname faicon@registered\endcsname{{\FA\symbol{"F25D}}}
\expandafter\def\csname faicon@trademark\endcsname{{\FA\symbol{"F25C}}}
\expandafter\def\csname faicon@mars\endcsname{{\FA\symbol{"F222}}}
\expandafter\def\csname faicon@venus\endcsname{{\FA\symbol{"F221}}}
\expandafter\def\csname faicon@male\endcsname{{\FA\symbol{"F183}}}
\expandafter\def\csname faicon@female\endcsname{{\FA\symbol{"F182}}}
\expandafter\def\csname faicon@child\endcsname{{\FA\symbol{"F1AE}}}
\expandafter\def\csname faicon@paper-plane\endcsname{{\FA\symbol{"F1D8}}}
\expandafter\def\csname faicon@heartbeat\endcsname{{\FA\symbol{"F21E}}}
\expandafter\def\csname faicon@smile-o\endcsname{{\FA\symbol{"F118}}}

\endinput