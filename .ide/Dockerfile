# ===================================================================
# Dockerfile
# ===================================================================

# -----------------------------------------------------------------------------
# 基础镜像与环境变量
# -----------------------------------------------------------------------------

# 使用 Ubuntu 24.04 LTS 作为基础镜像
FROM ubuntu:24.04

# 环境变量配置
#   DEBIAN_FRONTEND=noninteractive: 禁用交互式提示，避免安装时卡住
ENV DEBIAN_FRONTEND=noninteractive

# 配置国内镜像源
# 说明: 使用腾讯云镜像加速 apt 下载
RUN . /etc/os-release 2>/dev/null || VERSION_CODENAME="noble" && \
    echo "deb https://mirrors.cloud.tencent.com/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.cloud.tencent.com/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.cloud.tencent.com/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.cloud.tencent.com/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list

# -----------------------------------------------------------------------------
# 系统工具安装
# -----------------------------------------------------------------------------

# 安装基础开发工具
# 说明: 合并安装减少镜像层数，--no-install-recommends 避免安装不必要的包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        git-lfs \
        curl \
        wget \
        procps \
        ca-certificates \
        gpg \
        python-is-python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# UV 包管理器与 Python 库
# -----------------------------------------------------------------------------

# 安装 UV - 极速 Python 包管理器
# 说明: 比 pip 快 10-100 倍，支持并行安装，与系统 Python 3.12 完美兼容
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# 添加 UV 到 PATH
ENV PATH="/root/.local/bin:$PATH"

# 创建虚拟环境并安装 Python 库
RUN uv venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 安装 Python 库
RUN uv pip install --python /opt/venv/bin/python \
        pydantic>=2.11.3 \
        python-dotenv>=1.0.0 \
        PyYAML>=6.0 \
        fastapi>=0.116.0 \
        uvicorn>=0.35.0 \
        httpx>=0.27.0 \
        pytest>=8.0 \
        pytest-asyncio>=0.24

# -----------------------------------------------------------------------------
# Node.js 安装
# -----------------------------------------------------------------------------

# 安装 Node.js 22.x
# 说明: 使用 NodeSource 官方源安装，确保版本 >= 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource_setup.sh && \
    bash /tmp/nodesource_setup.sh && \
    rm /tmp/nodesource_setup.sh && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    node --version && \
    npm --version

# -----------------------------------------------------------------------------
# LaTeX 编译环境 (XeLaTeX) 安装
# -----------------------------------------------------------------------------

# 安装 TeX Live 核心包，支持 XeLaTeX 编译 .tex 生成 PDF
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        texlive-xetex \
        texlive-latex-recommended \
        texlive-fonts-recommended \
        texlive-lang-chinese \
        latexmk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    xelatex --version

# -----------------------------------------------------------------------------
# code-server 与 VS Code 扩展
# -----------------------------------------------------------------------------

# 安装 code-server - 浏览器版 VS Code
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 安装 VS Code 扩展
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension james-yu.latex-workshop && \
    code-server --install-extension cweijan.vscode-office && \
    code-server --install-extension mathematic.vscode-pdf && \
    code-server --install-extension oderwat.indent-rainbow && \
    code-server --install-extension anthropic.claude-code && \
    code-server --install-extension tencent-cloud.coding-copilot && \
    code-server --install-extension openai.chatgpt && \
    code-server --install-extension cnbcool.cnb-welcome

# -----------------------------------------------------------------------------
# Claude Code 汉化包
# -----------------------------------------------------------------------------

# 安装 Claude Code 汉化包（非官方社区扩展）
RUN git clone --depth 1 https://github.com/zstings/claude-code-zh-cn.git /tmp/claude-code-zh-cn && \
    cd /tmp/claude-code-zh-cn && \
    npm install && \
    npx vsce package --no-dependencies --allow-star-activation && \
    code-server --install-extension ./claude-code-zhcn-*.vsix && \
    rm -rf /tmp/claude-code-zh-cn

# -----------------------------------------------------------------------------
# 环境变量与系统配置
# -----------------------------------------------------------------------------

# 字符集配置
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

# 容器默认工作目录
WORKDIR /workspace

# 容器默认启动命令
CMD ["/bin/bash"]