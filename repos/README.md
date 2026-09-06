# 📦 repos

本目录收录引入的第三方仓库与参考资料，逐条简介见下。

---

## 📚 目录总览

| 目录                  | 仓库                                                                             | 引入方式  | 默认分支 | 锁定 commit | 语言       | Star   | 上游最近 push | 本地状态    |
| --------------------- | -------------------------------------------------------------------------------- | --------- | -------- | ----------- | ---------- | ------ | ------------- | ----------- |
| `Kami`              | [tw93/Kami](https://github.com/tw93/Kami)                                         | submodule | `main` | `8fb9f26` | HTML       | 11,195 | 2026-09-03    | ✅ 已初始化 |
| `khazix-skills`     | [KKKKhazix/Khazix-Skills](https://github.com/KKKKhazix/Khazix-Skills)             | submodule | `main` | `93d800f` | Python     | 20,410 | 2026-08-16    | ⬜ 未初始化 |
| `trpc-agent-go`     | [trpc-group/trpc-agent-go](https://github.com/trpc-group/trpc-agent-go)           | submodule | `main` | `dd71886` | Go         | 1,763  | 2026-09-04    | ⬜ 未初始化 |
| `trpc-agent-python` | [trpc-group/trpc-agent-python](https://github.com/trpc-group/trpc-agent-python)   | submodule | `main` | `6a2f7f9` | Python     | 144    | 2026-09-04    | ⬜ 未初始化 |
| `WeRead-MCP`        | [Stelquis/WeRead-MCP](https://github.com/Stelquis/WeRead-MCP)                     | submodule | `main` | `5113a55` | Rust       | 0      | 2026-07-28    | ⬜ 未初始化 |
| `weekly-review`     | [SiyuanJia/weekly-review](https://github.com/SiyuanJia/weekly-review)             | submodule | `main` | `792d949` | JavaScript | 9      | 2026-06-27    | ⬜ 未初始化 |
| `heyuan110-blog/`   | [heyuan110/heyuan110.github.io](https://github.com/heyuan110/heyuan110.github.io) | 本地副本  | —       | —          | HTML       | 1      | 2026-07-27    | ✅ 28 MB（已去 git） |
| `heyuan110.md`      | [heyuan110.md](./heyuan110.md)                                                    | 索引文件  | —       | —          | Markdown   | —     | —            | ✅ 207 条（待补 6 篇） |

---

## 📄 Kami — 文档排版工具

[tw93/Kami](https://github.com/tw93/Kami) · submodule · `main` · `8fb9f26`（V1.11.0）

**是什么**：tw93 开源的文档排版工具（Kami = 紙，日语「纸」），口号 *"Good content deserves good paper."*。用一套约束语言配合多种文档模板，把 Markdown 渲染成可直接交付的 HTML / PDF，稳定到 Agent 也能可靠运行。

**要点**：

- 模板体系：覆盖简历、财报点评、推荐信、Slides、Changelog 等场景，另有 Landing Page 系统
- Agent 友好：以插件形式供 Claude Code / Codex 使用，也支持 `~/.agents/` 通用接入
- 多语言排版：中 / 英 / 日文模板，A4 打印与屏幕阅读两套样式

**状态**：11,195 star，创建于 2026-04，最近 push 2026-09-03，迭代非常快。

**在本仓库的用途**：`project/Easy-Es/build_doc.py` 用它生成申请书 PDF，依赖 `long-doc.html` 模板与 `assets/fonts` 字体。

**⚠️ 踩过的坑**：

- 禁用破折号「——」，`--check-markdown` 会报错，改用逗号或句号
- 不要用 SVG 画含中文的图，会渲染成缺字方块；改用 `div` + CSS Grid，字号用 `pt`
- 外部引用时字体相对路径 `../fonts/` 需改写为绝对路径

---

## 🧩 khazix-skills — AI Skills 合集

[KKKKhazix/Khazix-Skills](https://github.com/KKKKhazix/Khazix-Skills) · submodule · `main` · `93d800f`（目录名为小写 `khazix-skills`）

**是什么**：数字生命卡兹克开源的 AI Agent Skills 合集，本目录 star 最高的仓库。官方描述：

> Agent Skills: leader（帮你定义目标）, neat-freak 洁癖, hv-analysis, khazix-writer & more — Claude Code, Codex & 40+ agents

**要点**：

- 技能化工作流：把可复用的工作方法封装为 `SKILL.md`
- 跨平台兼容：同时适配 Claude Code、Codex 及 40+ 种 Agent 工具
- Python 实现

**状态**：20,410 star，创建于 2026-04，最近 push 2026-08-16，社区活跃度高。

---

## 🐹 trpc-agent-go — Go 版 Agent 框架

[trpc-group/trpc-agent-go](https://github.com/trpc-group/trpc-agent-go) · submodule · `main` · `dd71886`
主页 [trpc-group.github.io/trpc-agent-go](https://trpc-group.github.io/trpc-agent-go/)

**是什么**：tRPC 官方的 Go 生产级 Agent 框架。官方描述为 *"A Go framework for building production agent systems with graph workflows, tools, memory, A2A, AG-UI, MCP, evaluation, and observability."*

**要点**：

- Go 原生运行时：流式 Runner、context 取消、服务友好 API
- GraphAgent：类型安全的图工作流，多条件路由，相当于 Go 版 LangGraph
- 多 Agent 协作：链式、并行、循环工作流
- 工具生态：函数工具、MCP、Web 搜索、代码执行
- 自进化与评测：Hermes 式会话回顾抽取 `SKILL.md`，内置评测集与指标

**状态**：1,763 star，创建于 2025-05，最近 push 2026-09-04，处于高频维护。

---

## 🐍 trpc-agent-python — Python 版 Agent 框架

[trpc-group/trpc-agent-python](https://github.com/trpc-group/trpc-agent-python) · submodule · `main` · `6a2f7f9`

**是什么**：tRPC 官方的 Python 生产级 Agent 框架，与 Python AI 生态深度集成。官方描述为 *"end-to-end foundation for agent building, orchestration, tool integration, session and long-term memory, service deployment, and observability."*

**要点**：

- 多范式编排：`ChainAgent` / `ParallelAgent` / `CycleAgent` / `TransferAgent`，`GraphAgent` 支持 DSL 图编排
- 生态扩展：`LangGraphAgent` / `ClaudeAgent` / `TeamAgent`、`MCP` / LangChain、LangChain RAG、`LiteLLM`
- 完整记忆：`Session` 会话内状态 + `Memory` 跨会话长期记忆，支持 InMemory / Redis / SQL
- 服务与可观测：FastAPI 暴露 HTTP / A2A / AG-UI，内置 OpenTelemetry
- trpc-claw：基于 [nanobot](https://github.com/HKUDS/nanobot) 的个人 Agent，支持 Telegram / 企业微信

**状态**：144 star，创建于 2025-12，最近 push 2026-09-04。与 Go 版 star 差一个数量级，但同样在活跃开发。

---

## 📰 WeRead-MCP — 微信公众号文章阅读器

[Stelquis/WeRead-MCP](https://github.com/Stelquis/WeRead-MCP) · submodule · `main` · `5113a55`

**是什么**：本仓库所有者自有的项目。微信公众号文章阅读器 MCP 服务，官方描述：

> WeRead MCP - 微信公众号文章阅读器 MCP 服务，纯 HTTP 无需浏览器，自动下载图片到本地，输出结构化 Markdown

**要点**：

- 纯 HTTP 抓取，不依赖浏览器 / 无头内核
- 图片本地化，自动下载配图避免外链失效
- 结构化输出，直接产出可使用的 Markdown
- Rust 实现，MIT 协议，单二进制分发

**状态**：0 star，创建于 2026-07-15，最近 push 2026-07-28，早期个人项目。

---

## 📊 weekly-review — 周报

[SiyuanJia/weekly-review](https://github.com/SiyuanJia/weekly-review) · submodule · `main` · `792d949`

**是什么**：JavaScript 实现的周报仓库，从仓库名推断为周期性回顾 / 周报类内容沉淀（**上游未提供 description**）。

**要点**：

- JavaScript 实现
- 上游信息较少，如需准确描述建议初始化后阅读其 README

**状态**：9 star，创建于 2026-06-27，最近 push 同为 2026-06-27，创建后即未再更新。

---

## 📖 heyuan110-blog — Bruce 的 AI 工程博客

[heyuan110/heyuan110.github.io](https://github.com/heyuan110/heyuan110.github.io) · 本地副本（已移除 `.git`，原 HEAD `c9e47cc`）

**是什么**：heyuan110（Bruce）的技术博客源站，Hugo 静态站点，主题 `hermit-V2`。内容以 **AI 工程 / Agent 架构 / Claude Code 实战**为主。本地已精简为纯内容副本——仅保留 `content/` 与 `static/images/`，Hugo 主题 / 模板 / 构建脚本 / 站点静态资源与 `.git` 均已剔除。

**要点**：

- 文章 213 篇，每篇中英双版；全库 441 个 `.md`（213 英文 + 213 中文 + 9 个文章目录内的 `CLAUDE.md` + 6 个站点 / 索引页）
- 分类分布：`ai` 169 篇（绝对主力）、`linux` 18、`docker` 6、`python` / `middleware` / `macos` / `elasticsearch` 各 3、`mysql` / `java` 各 2，其余 4 类各 1
- `ai/` 中的 **Harness Engineering 系列**是博主核心方法论，与本站 `project/Easy-Es` 的 Harness 实践直接相关
- 体积 28 MB，含 413 个 `.webp` 图片资源（已剔除 `.git`、主题、模板、构建脚本与站点静态资源）

**状态**：1 star，上游最近 push 2026-07-27。本地副本已移除 `.git`（原 HEAD `c9e47cc`），无法再 pull，需同步请重新克隆。

**📑 索引**：文章的分类整理见 [`heyuan110.md`](./heyuan110.md)。

---

### 📑 heyuan110.md — 博客文章分类索引

[heyuan110.md](./heyuan110.md) · 索引文件

**是什么**：对 `heyuan110-blog` 全部文章的人工分类整理，按主题归并为 13 组并逐条附上链接与发布日期，文末给出分层次的阅读建议。

**要点**：

- 主体为 AI 类（169 篇），细分为 Harness Engineering、上下文工程 / RAG、斯坦福 CS146S 精读、方法论、Claude Code、Skills / SubAgent、Hooks / Worktree、MCP、浏览器自动化、OpenClaw 专题、AI 安全、工具评测等
- 另有 Linux、Docker、Python、中间件、Elasticsearch、MySQL、macOS、Java、TypeScript、Go、管理、数据仓库共 44 篇传统技术文章
- 文末「吸收建议」按**先用 → 后学 → 常备 → 传统技术补课**四层排序，标注了每组该什么时候读

**状态**：随博客同步整理，数据源为 [heyuan110.com](https://www.heyuan110.com/zh/posts/)。

**⚠️ 与本地内容的差异**（2026-09-06 比对）：漏收 6 篇——`ai/ai-automation-hub`、`linux/linux-ops-basics-hub`、`macos/show-hide-files`、`linux/nginx/` 下 3 篇；1 条死链——`linux/nginx/nginx-https-complete-guide`；3 处链接与目录名不一致——`&` 被站方去除 2 处、`mq-rabbitmQ` 大小写 1 处。

---

## 🚀 操作指南

### 初始化

全部拉取：

```bash
git submodule update --init --recursive
```

只拉某一个（网络受限时推荐）：

```bash
git submodule update --init repos/Kami
```

> 新克隆后未初始化的目录是空的，依赖其内容的脚本会直接失败。

### 更新

全部更新到各自跟踪分支的最新提交：

```bash
git submodule update --remote --recursive
```

单独更新某一个：

```bash
git submodule update --remote repos/trpc-agent-go
```

本地副本（非 submodule）的更新方式：

> `heyuan110-blog` 已移除 `.git`，**不能再用 pull 更新**。如需同步上游，请重新克隆后按「仅保留 `content/` 与 `static/images/`」再次精简。

---

## ⚠️ 注意

- submodule 记录的是**某个具体 commit** 而非「永远跟随最新」，更新后需**把 commit 变更一并提交**才会被主仓库记录。
- 切换分支或回滚后，submodule 内容不会自动同步，需补跑 `git submodule update`。
- 删除 submodule 需同步清理 `.gitmodules`、`.git/config`、`.git/modules`，建议用 `git submodule deinit` + `git rm`，不要直接删目录。
