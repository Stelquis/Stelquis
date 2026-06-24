# ===================================================================
# Dockerfile 
# ===================================================================

# -----------------------------------------------------------------------------
# 第一部分: 基础镜像与环境变量
# -----------------------------------------------------------------------------

# 使用 Ubuntu 24.04 LTS 作为基础镜像
FROM ubuntu:24.04

# 环境变量配置
#   DEBIAN_FRONTEND=noninteractive: 禁用交互式提示，避免安装时卡住
#   LANG/LANGUAGE=C.UTF-8:          设置 UTF-8 编码，支持中文显示和输入
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

# -----------------------------------------------------------------------------
# 第二部分: 系统源配置
# -----------------------------------------------------------------------------

# 步骤1: 配置腾讯云 APT 镜像源（使用 HTTP 避免证书问题，后续安装证书后再使用）
RUN rm -rf /var/lib/apt/lists/* && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.cloud.tencent.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list

# -----------------------------------------------------------------------------
# 第三部分: 系统工具安装
# -----------------------------------------------------------------------------

# 安装系统工具
# 说明: 合并为单个 RUN 以减少镜像层数；--no-install-recommends 避免安装不必要的推荐包
#
# 分组说明:
#   基础系统工具:
#     git / curl                             版本控制与下载工具
#   网络与安全工具:
#     apt-transport-https / ca-certificates   APT HTTPS 支持与根证书
#   系统管理工具:
#     build-essential                         GCC/G++ 编译工具
#   AI 编程助手环境:
#     nodejs / npm                            Node.js 运行时与包管理器
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    update-ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh && \
    bash /tmp/nodesource_setup.sh && \
    rm /tmp/nodesource_setup.sh && \
    apt-get install -y --no-install-recommends \
        git curl \
        apt-transport-https \
        build-essential \
        nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    node --version && \
    npm --version

# -----------------------------------------------------------------------------
# 第四部分: LaTeX 编译环境 (XeLaTeX) 安装
# -----------------------------------------------------------------------------

# 安装 TeX Live 核心包，支持 XeLaTeX 编译 .tex 生成 PDF
# 包说明:
#   texlive-xetex             - XeTeX 引擎，支持 Unicode 和系统字体
#   texlive-latex-recommended - LaTeX 推荐宏包集 (amsmath, booktabs, geometry 等)
#   texlive-fonts-recommended - 推荐字体包 (ec, cm-super，含基础中英文字体)
#   texlive-lang-chinese      - 中文字体支持 (ctex, xeCJK)
#   latexmk                   - 自动化编译工具 (自动处理多次编译、参考文献等)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        texlive-xetex \
        texlive-latex-recommended \
        texlive-fonts-recommended \
        texlive-lang-chinese \
        latexmk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    xelatex --version && \
    latexmk --version

# -----------------------------------------------------------------------------
# 第五部分: code-server 与 VS Code 扩展
# -----------------------------------------------------------------------------

# 安装 code-server - 浏览器版 VS Code
# 说明: 官方 install.sh 自动下载最新版本并安装
#
# 扩展列表（按功能分类）:
#   Git 可视化:
#     mhutchie.git-graph             Git 提交历史可视化（图形化分支/合并/提交记录）
#   LaTeX 支持:
#     james-yu.latex-workshop       LaTeX 编辑与预览，支持编译、补全、正向/反向搜索
#   代码质量:
#     esbenp.prettier-vscode        代码格式化
#     redhat.vscode-yaml            YAML 语法校验与补全（.cnb.yml 等配置文件）
#   文档预览:
#     cweijan.vscode-office         Office 文件预览与编辑（支持 Word/Excel/PPT 等）
#     mathematic.vscode-pdf         PDF 文档预览与阅读
#     bierner.markdown-mermaid      Markdown 中渲染 Mermaid 图表（流程图/时序图）
#   编辑器增强:
#     oderwat.indent-rainbow        缩进彩虹，代码层级可视化
#     ritwickdey.liveserver         HTML 实时预览（右键 → Open with Live Server）
#     cloudstudio.live-server       云端实时预览（Cloud Studio 风格）
#   AI 编程助手:
#     anthropic.claude-code         Claude Code AI 编程助手
#     tencent-cloud.coding-copilot  腾讯 AI 辅助编程（CodeBuddy）
#     openai.chatgpt                ChatGPT AI 编程助手
#   CNB 平台扩展:
#     cnbcool.cnb-welcome           CNB 平台欢迎页
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --install-extension mhutchie.git-graph && \
    code-server --install-extension james-yu.latex-workshop && \
    code-server --install-extension esbenp.prettier-vscode && \
    code-server --install-extension redhat.vscode-yaml && \
    code-server --install-extension cweijan.vscode-office && \
    code-server --install-extension mathematic.vscode-pdf && \
    code-server --install-extension bierner.markdown-mermaid && \
    code-server --install-extension oderwat.indent-rainbow && \
    code-server --install-extension ritwickdey.liveserver && \
    code-server --install-extension cloudstudio.live-server && \
    code-server --install-extension anthropic.claude-code && \
    code-server --install-extension tencent-cloud.coding-copilot && \
    code-server --install-extension openai.chatgpt && \
    code-server --install-extension cnbcool.cnb-welcome

# -----------------------------------------------------------------------------
# 第六部分: CodeX CLI 配置
# -----------------------------------------------------------------------------

# 配置文件会在容器启动时通过 init-codex.sh 脚本动态生成

# 创建 CodeX 配置目录（空目录，内容由启动脚本填充）
RUN mkdir -p /root/.codex /home/admin/.codex

# 复制 CodeX 初始化脚本
COPY scripts/init-codex.sh /usr/local/bin/init-codex.sh
RUN chmod +x /usr/local/bin/init-codex.sh

# -----------------------------------------------------------------------------
# 第七部分: Claude Code CLI 配置 + 汉化包
# -----------------------------------------------------------------------------

# 安装 Claude Code CLI (需要 Node.js 22+)
RUN npm install -g @anthropic-ai/claude-code

# 复制 Claude Code 初始化脚本
COPY scripts/init-claude.sh /usr/local/bin/init-claude.sh
RUN chmod +x /usr/local/bin/init-claude.sh

# 安装 Claude Code 汉化包（非官方社区扩展）
# 说明: 克隆仓库、打包并安装汉化扩展，使用 --allow-star-activation 避免交互确认
RUN node --version && \
    npm --version && \
    git clone --depth 1 https://github.com/zstings/claude-code-zh-cn.git /tmp/claude-code-zh-cn && \
    cd /tmp/claude-code-zh-cn && \
    npm install && \
    npx vsce package --no-dependencies --allow-star-activation && \
    code-server --install-extension ./claude-code-zhcn-*.vsix && \
    rm -rf /tmp/claude-code-zh-cn

# -----------------------------------------------------------------------------
# 第八部分: 配置文件复制
# -----------------------------------------------------------------------------

# 复制 VS Code 设置到容器
# 路径说明: code-server 的机器级（Machine）设置目录
# 作用: 预配置编辑器主题、字体、Python 解释器路径等，开箱即用
COPY .vscode/settings.jsonc /root/.local/share/code-server/Machine/settings.json

# -----------------------------------------------------------------------------
# 第九部分: 工作目录与启动命令
# -----------------------------------------------------------------------------

# 设置容器默认工作目录
# 说明: 与 CNB 平台代码挂载点保持一致，启动后直接进入项目根目录
WORKDIR /workspace

# 默认启动命令: 交互式 bash，方便直接使用 LaTeX / Git 等工具
CMD ["/bin/bash"]