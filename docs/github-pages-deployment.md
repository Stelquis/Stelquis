# 个人主页 GitHub Pages 部署记录

> ⚠️ **当前状态（2026-09-07）**：`.github/workflows/pages.yml` 已移除——仓库暂无需要部署的网页。后续要恢复部署时，按下方「GitHub Actions 工作流」的 YAML 重建该文件即可，其余流程不变。

## 背景

为了把本仓库作为个人主页展示，同时让 CNB / Gitee / GitHub 仓库主页正常显示 README，做了以下改造：

- 将原来的 `README.html` 重命名为 `index.html`，避免 Gitee 把 HTML 源码当作 README 展示。
- 为 `README.md` 设计了一个本地 SVG 横幅 `assets/banner.svg`，替代之前依赖外部服务的打字机特效。
- 添加 GitHub Actions 工作流，自动将 `index.html` 部署到 GitHub Pages，获得可访问的网址。

## 文件结构

```
/
├── index.html              # 个人主页完整 HTML 版本
├── README.md               # 仓库说明文档，CNB/Gitee/GitHub 主页展示
├── assets/
│   └── banner.svg          # README.md 顶部横幅
├── docs/
│   └── github-pages-deployment.md  # 本部署记录
└── .github/
    └── workflows/
        └── pages.yml       # GitHub Pages 自动部署工作流
```

## GitHub Actions 工作流

文件：`.github/workflows/pages.yml`

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v5
        with:
          enablement: true

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: "."

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

关键点：

- `actions/configure-pages@v5` 的 `enablement: true` 可以自动开启 Pages，避免仓库未手动启用时报 `Not Found` 错误。
- `permissions` 中必须有 `pages: write` 和 `id-token: write`，否则部署步骤会权限不足。
- `path: "."` 表示把整个仓库根目录作为静态站点发布，`index.html` 会自动作为首页。

## 完整操作流程

1. 修改 `index.html` 或 `README.md` 后，先提交并推送到 CNB。

2. 同步到 GitHub

   ```bash
   bash /workspace/scripts/sync-to-github.sh
   ```

   脚本会检查 `gh` CLI 登录状态，然后把当前 `main` 分支内容同步到 GitHub 仓库 `Stelquis/Niu`。

3. 触发 GitHub Pages 工作流

   - 同步 push 会自动触发 `pages.yml`（因为 `on.push.branches: [main]`）。
   - 也可以手动触发：

     ```bash
     gh workflow run "Deploy to GitHub Pages" --repo Stelquis/Niu
     ```

4. 查看部署状态

   ```bash
   gh run watch <run-id> --exit-status
   ```

   或者打开：https://github.com/Stelquis/Niu/actions

5. 访问站点

   ```
   https://Stelquis.github.io/Niu/
   ```

## 实战经验与踩坑记录

### 1. Gitee 把 README.html 当成 README 展示

- **现象**：Gitee 仓库主页显示的是 HTML 源码文本，而不是渲染后的页面。
- **原因**：Gitee 会识别 `README.*` 文件作为仓库说明，即使后缀是 `.html` 也会直接按源码展示。
- **解决**：将 `README.html` 重命名为 `index.html`。这样 Gitee 会正常展示 `README.md`，而 `index.html` 可作为个人主页入口。

### 2. README.md 的打字机 SVG 在 CNB 不显示

- **现象**：README 顶部使用外部服务 `readme-typing-svg.demolab.com` 的打字机动画，在 CNB 仓库主页无法显示。
- **原因**：CNB 的 Markdown 渲染环境可能无法访问该外部域名，或者不支持动态 SVG。
- **解决**：用本地静态 SVG 横幅 `assets/banner.svg` 替换，兼容所有 Markdown 渲染平台。

### 3. GitHub Actions 首次部署报 `Not Found`

- **现象**：工作流 `actions/configure-pages` 步骤失败，报错：

  ```
  HttpError: Not Found - https://docs.github.com/rest/pages/pages#get-a-apiname-pages-site
  Get Pages site failed. Please verify that the repository has Pages enabled...
  ```

- **原因**：仓库尚未启用 GitHub Pages，或者 Pages 的 Source 没有设为 GitHub Actions。
- **解决**：给 `actions/configure-pages@v5` 添加 `enablement: true`，让 Action 自动开启 Pages。无需再去 Settings 手动点 Save。

### 4. Node.js 20 弃用警告

- **现象**：工作流日志出现警告：

  ```
  Node.js 20 is deprecated. The following actions target Node.js 20...
  ```

- **原因**：GitHub Actions 正在逐步升级 runner 默认 Node 版本，旧版本 action 会有提示。
- **影响**：这只是警告，不会导致部署失败。等官方 action 发布新版本后更新版本号即可。

### 5. 个人主页地址格式

- 如果仓库名是 `Niu`，用户名是 `Stelquis`，GitHub Pages 默认地址就是：

  ```
  https://Stelquis.github.io/Niu/
  ```

- 如果是用户/组织站点（仓库名必须是 `<username>.github.io`），则地址是 `https://Stelquis.github.io/`。

### 6. CNB 环境同步脚本 GPG 签名 403

- **现象**：运行 `sync-to-github.sh` 或 `sync-to-gitee.sh` 时报错：

  ```
  error signing commit: error making request: 403 | Author is invalid
  error: gpg failed to sign the data
  fatal: failed to write commit object
  ```

- **原因**：CNB 开发环境系统级 git 配置强制开启 GPG 签名：

  ```
  gpg.program=/usr/local/bin/cnb-gpgsign
  commit.gpgsign=true
  user.email=...@noreply.cnb.cool
  ```

  `cnb-gpgsign` 是 CNB 平台专属的签名程序，它会校验 commit 的 **author 和 committer 邮箱**，只认可 CNB noreply 邮箱（`...@noreply.cnb.cool`）。而同步脚本为了记录 GitHub 贡献，把 author 设成了 QQ 邮箱（`3420761503@qq.com`），导致签名被拒绝。

- **解决**：同步脚本的 `git commit` 命令加 `-c commit.gpgsign=false` 临时关闭签名：

  ```bash
  git -c commit.gpgsign=false commit -m "..."
  ```

- **影响分析**：
  - ✅ **GitHub 贡献绿格**：正常记录（贡献看的是 author 邮箱，不是签名）
  - ✅ **CNB 主仓库**：不受影响（CNB 自己的 commit 仍用 noreply 邮箱 + 正常签名）
  - ❌ **同步 commit 无 Verified 徽章**：无影响（这只是同步用的临时 commit，不是源仓库提交）

- **为何昨天正常今天报错**：昨天直接在 CNB 环境提交（author = noreply 邮箱），cnb-gpgsign 认可。今天运行同步脚本后，脚本把 author 改成 QQ 邮箱，触发签名校验失败。

### 7. 推送到 CNB 不触发 GitHub Action

- **现象**：`git push` 后 GitHub Pages 没有更新。
- **原因**：`origin` 远程指向 CNB（`https://cnb.cool/OrionSeeker/Niu.git`），`git push` 只推到了 CNB，GitHub 仓库没收到推送，Action 不触发。
- **解决**：推送 CNB 后，额外运行同步脚本：

  ```bash
  bash /workspace/scripts/sync-to-github.sh
  ```

  脚本会把 main 分支内容同步到 GitHub，触发 `pages.yml` 工作流。

## 后续维护

- 每次更新 `index.html` 或 `assets/banner.svg` 后，先提交并推送到 CNB：

  ```bash
  git add -A && git commit -m "feat: 更新说明" && git push
  ```

- 然后同步到 GitHub（触发 Pages 自动部署）：

  ```bash
  bash /workspace/scripts/sync-to-github.sh
  ```

- 如需同步到 Gitee：

  ```bash
  bash /workspace/scripts/sync-to-gitee.sh
  ```

- 如需自定义域名，可在仓库根目录添加 `CNAME` 文件，并在 DNS 服务商配置 CNAME 记录。
- 如需启用私有仓库的 Pages，需要 GitHub Pro / Enterprise 支持，免费版仅支持公开仓库 Pages。

## 参考链接

- GitHub Pages 文档：https://docs.github.com/en/pages
- GitHub Actions Pages 工作流：https://github.com/actions/starter-workflows/tree/main/pages
- 本仓库 GitHub 地址：https://github.com/Stelquis/Niu
- 已部署站点：https://Stelquis.github.io/Niu/
