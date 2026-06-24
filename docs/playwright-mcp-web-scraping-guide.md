# Claude Code + Playwright MCP 网页抓取流程指南

用自然语言驱动 Claude Code，通过 Playwright MCP 工具完成动态网页的数据抓取与整理。

**已验证站点**：
- [DJI 大疆校招](https://we.dji.com) — Next.js SPA，[输出文档](../offer/dji-ai-intern-2026.md)
- [腾讯云智 Mokahr](https://app-tc.mokahr.com) — React SPA，[输出文档](../offer/tencent-csig-changsha-2026.md)

---

## 1. 工具链概览

```
用户（自然语言指令）
  ↓
Claude Code（理解意图、编排任务、整理结果）
  ↓
Playwright MCP Server（浏览器自动化）
  ↓
Chromium（执行页面渲染与交互）
  ↓
目标网站
```

**核心理念**：用户不需要写任何代码，只需用自然语言描述需求，Claude Code 会自动调用 Playwright MCP 提供的浏览器工具完成抓取。

---

## 2. 环境安装

### 2.1 安装 Playwright MCP

```bash
npm install -g @playwright/mcp
```

验证：

```bash
npx playwright --version
# → Version 1.60.0
```

### 2.2 安装浏览器

```bash
npx playwright install chromium
```

浏览器缓存位置：`~/.cache/ms-playwright/`

### 2.3 安装系统依赖（Linux / 容器环境）

```bash
npx playwright install-deps
```

> 安装 dbus、libgtk 等系统库。macOS 通常不需要此步。

---

## 3. Claude Code 配置 MCP

### 3.1 配置文件

编辑 `~/.claude/settings.json`，添加 `mcpServers` 字段：

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp",
        "--headless"
      ]
    }
  }
}
```

| 参数 | 说明 |
|------|------|
| `--headless` | 无头模式，服务器/CI 环境必须 |
| `--browser <name>` | 指定浏览器，默认 chromium |
| `--port <number>` | 指定 MCP 通信端口 |

### 3.2 验证配置

重启 Claude Code 会话后，MCP 工具会自动注册。如果 Claude Code 的工具列表中出现 `browser_navigate`、`browser_click`、`browser_evaluate` 等工具，说明配置成功。

常见问题排查：
- `@playwright/mcp` 未全局安装
- JSON 格式错误（多余逗号、引号）
- 未重启 Claude Code 会话

---

## 4. 使用方式

### 4.1 基本对话模式

直接在 Claude Code 中用自然语言描述需求即可：

```
用户: 帮我打开 https://example.com，抓取页面上所有职位标题
用户: 去这个网站把产品列表整理成表格
用户: 打开登录页面，截图发给我看看
```

Claude Code 会自动：
1. 调用 `browser_navigate` 打开页面
2. 等待页面加载完成
3. 调用 `browser_evaluate` 提取数据
4. 整理结果并呈现给用户

### 4.2 多步骤任务

对于复杂任务，Claude Code 会自动拆分步骤并逐步执行：

```
用户: 帮我把 DJI 校招页面上 4 个 AI 实习生岗位的任职要求都整理出来

Claude Code 自动执行:
  1. browser_navigate → 打开列表页
  2. browser_evaluate → 提取岗位链接
  3. browser_navigate → 逐个打开详情页
  4. browser_evaluate → 提取任职要求
  5. 整理输出结构化结果
```

### 4.3 交互式操作

支持需要点击、滚动、输入等交互的场景：

```
用户: 打开搜索页面，输入"AI实习生"，然后把搜索结果截图给我
用户: 点击"加载更多"按钮，直到所有内容都显示出来
用户: 滚动到页面底部，看看有没有分页按钮
```

---

## 5. Playwright MCP 提供的核心工具

Claude Code 可调用的 MCP 工具（名称以实际注册为准）：

| 工具 | 功能 | 示例场景 |
|------|------|---------|
| `browser_navigate` | 打开指定 URL | 打开目标网页 |
| `browser_click` | 点击页面元素 | 点击"下一页"、展开详情 |
| `browser_evaluate` | 执行 JS 表达式提取数据 | 获取页面文本、链接、属性 |
| `browser_screenshot` | 截取页面截图 | 视觉验证、记录结果 |
| `browser_wait` | 等待条件满足 | 等待元素出现、网络空闲 |
| `browser_fill` | 填写表单 | 搜索框输入关键词 |
| `browser_scroll` | 页面滚动 | 触发懒加载、查看底部内容 |

---

## 6. 实战案例：抓取 DJI 校招岗位

### 6.1 用户指令

```
帮我整理 https://we.dji.com/zh-CN/campus/position?project=intern&category=102&page=1
这个页面四个AI实习生岗位的具体职业要求
```

### 6.2 Claude Code 执行过程

**Step 1** — 尝试静态抓取：

> 调用 WebFetch 获取页面内容 → 发现返回 "找到 0 个职位"（SPA 动态渲染，静态抓取无效）

**Step 2** — 切换到 Playwright MCP：

> 调用 `browser_navigate` 打开页面 → 等待 `networkidle` → 调用 `browser_evaluate` 提取 `document.body.innerText` → 成功获取 4 个岗位摘要

**Step 3** — 发现详情页链接：

> 调用 `browser_evaluate` 提取所有 `<a>` 标签中包含 `position/detail` 的 href → 获得 4 个详情页 URL

**Step 4** — 逐个抓取详情：

> 对每个 URL 执行：`browser_navigate` → `browser_scroll`（触发懒加载）→ `browser_evaluate`（提取完整文本）

**Step 5** — 数据整理：

> 将原始文本按岗位结构化，输出工作职责 + 任职要求的清晰对比

### 6.3 最终输出示例

```
## AI 实习生 - 前端开发（AI Coding）

工作职责：
1. 参与大疆各软件产品中 Web 产品的前端开发工作
2. 与产品和设计团队协作，制定技术解决方案
3. 基于AI实现开发，从需求到上线的全链路交付

任职要求：
1. 本科及以上学历，计算机等相关专业
2. 能够使用 AI Coding 工具（Cursor、ClaudeCode 等）
3. 了解前端主流框架，如 Vue、React 等
```

---

## 7. 实战案例：抓取腾讯云智 CSIG 校招岗位

### 7.1 用户指令

```
帮我整理 https://app-tc.mokahr.com/campus-recruitment/csig/20001#/jobs?...
这个页面工作地点包含长沙的所有实习岗和全职岗
```

### 7.2 Claude Code 执行过程

**Step 1** — 打开列表页，发现 14 个岗位标题和详情页链接：

> `browser_navigate` → 等待 `networkidle` + 5 秒 → 提取所有 `<a[href*="/job/"]>` 获得 14 个详情 URL

**Step 2** — 逐个抓取详情页（踩坑过程）：

> 第一次尝试：用 `document.querySelector('[class*=detail]')` 提取 → **拿到空内容**（该站无 detail 容器类名）
>
> 修正方案：改用 `document.body.innerText` + 文本标记截取（`职位描述` 到 `申请职位` 之间的内容）

**Step 3** — 发现内容不完整：

> `networkidle` 后直接提取 → 岗位要求部分缺失（懒加载未触发）
>
> 修正方案：`networkidle` → 等待 4 秒 → `scrollTo(0, scrollHeight)` → 再等 2 秒 → 提取

### 7.3 踩坑总结

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| CSS 选择器提取到空内容 | 站点无统一容器类名 | 用 `document.body.innerText` + 文本标记截取 |
| 内容截断/缺失 | 懒加载未触发 | `networkidle` + 等待 + `scrollTo` + 再等待 |
| 等待 3 秒不够 | 不同站点渲染速度差异 | Mokahr 需要 4s + scroll + 2s，DJI 3s 够用 |
| 列表页只有摘要 | SPA 设计，详情需单独打开 | 必须逐个进入详情页抓取 |

---

## 8. 技巧与注意事项

### 8.1 内容提取策略（重要）

不同站点的 DOM 结构差异很大，需要灵活选择提取方式：

**方式一：CSS 选择器（优先尝试）**
```javascript
document.querySelector('[class*=detail]').innerText
```
适用于有明确容器类名的站点（如 DJI 的 `PositionCard_*`）。

**方式二：文本标记截取（兜底方案）**
```javascript
const text = document.body.innerText;
const start = text.indexOf('职位描述');
const end = text.indexOf('申请职位', start);
return text.substring(start, end);
```
适用于无统一容器的站点（如 Mokahr）。关键：找到页面中的固定文本标记作为截取锚点。

**方式三：按元素类型提取**
```javascript
Array.from(document.querySelectorAll('h2, h3, p')).map(el => el.innerText)
```
适用于结构化程度高的页面。

### 8.2 等待与滚动策略

```javascript
// 标准流程：等网络空闲 → 等渲染 → 滚动触发懒加载 → 再等渲染 → 提取
await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
await page.waitForTimeout(4000);          // 等待 JS 渲染完成
await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
await page.waitForTimeout(2000);          // 等待懒加载内容渲染
const content = await page.evaluate(() => document.body.innerText);
```

不同站点的等待时间参考：

| 站点 | networkidle 后等待 | 滚动后等待 |
|------|-------------------|-----------|
| DJI (Next.js) | 3 秒 | 2 秒 |
| Mokahr (React) | 4 秒 | 2 秒 |

### 8.3 如何获得更好的抓取效果

- **明确目标**：告诉 Claude Code 你要什么数据，而不是怎么做
- **提供上下文**：说明页面是 SPA、需要登录等信息，Claude Code 会自动选择合适策略
- **分步确认**：复杂任务可以让 Claude Code 先截图确认页面状态，再决定下一步
- **URL 带筛选参数**：在 URL 中预设好筛选条件（如地点、类别），减少页面交互步骤

### 8.4 MCP 未加载时的降级方案

如果 MCP 工具不可用，Claude Code 会降级到：
1. `WebFetch` 静态抓取（适合服务端渲染页面）
2. 通过 Bash 工具执行 Node.js 脚本调用 Playwright（需要本地安装 playwright 模块）

### 8.5 注意事项

1. **遵守 robots.txt** — 抓取前检查目标站点的爬虫规则
2. **控制频率** — Claude Code 会自动加适当延时，避免对目标服务器造成压力
3. **动态内容** — 列表页可能只展示摘要，完整信息通常在详情页中
4. **无头模式** — 服务器环境下必须使用 `--headless`，本地调试可去掉
5. **hash 路由站点** — URL 中 `#/path` 是前端路由，`page.goto()` 可以直接导航到 hash 路由页面
