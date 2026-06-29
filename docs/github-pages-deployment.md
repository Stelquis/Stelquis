# 个人主页 GitHub Pages 部署记录

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

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: "."

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## 启用步骤

1. 同步到 GitHub

   ```bash
   bash /workspace/scripts/sync-to-github.sh
   ```

   按提示完成 GitHub CLI 登录，脚本会自动创建或更新 GitHub 仓库。

2. 在 GitHub 仓库开启 Pages

   - 进入仓库 → Settings → Pages
   - Build and deployment → Source 选择 **GitHub Actions**
   - 保存

3. 触发部署

   - 因为 `pages.yml` 已经提交，push 到 `main` 分支后会自动触发部署。
   - 也可以到 Actions 标签页手动运行 `Deploy to GitHub Pages` 工作流。

4. 访问地址

   - 默认格式：`https://<GitHub用户名>.github.io/Niu/`
   - 例如：`https://Stelquis.github.io/Niu/`

## 注意事项

- 工作流把整个仓库根目录作为静态站点发布，`index.html` 会自动作为首页。
- `README.md` 不会被当作站点首页，只作为仓库说明展示。
- 后续每次修改 `main` 分支的内容，GitHub Actions 都会自动重新部署。
