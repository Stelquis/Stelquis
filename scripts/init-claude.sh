# ===================================================================
# Claude Code 配置初始化脚本
# ===================================================================
# 功能: 根据环境变量或默认值生成 Claude Code CLI 配置文件
# 配置路径: /root/.claude/ 和 /home/admin/.claude/
# 一键运行:
#   bash /workspace/scripts/init-claude.sh
# ===================================================================

set -e

# -----------------------------------------------------------------------------
# 用户配置区
# -----------------------------------------------------------------------------

# API Key: 留空则运行时交互输入
# 支持任意兼容 Anthropic API 的提供商
# 格式: sk-xxxxx (OpenRouter/官方) 或 tp-xxxxx (Token Plan) 等
# DeepSeek Platform: https://platform.deepseek.com/
MY_API_KEY=""

# API 基础地址
MY_BASE_URL="https://api.deepseek.com/anthropic"

# 模型名称
# DeepSeek 模型: deepseek-v4-pro[1m] / deepseek-v4-flash
MY_MODEL="deepseek-v4-pro[1m]"

MY_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
MY_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
MY_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
MY_SUBAGENT_MODEL="deepseek-v4-flash"

# 工作努力程度: min / low / medium / high / max
MY_EFFORT_LEVEL="max"

# -----------------------------------------------------------------------------
# 配置读取逻辑
# -----------------------------------------------------------------------------
# 优先级: 环境变量 > 脚本默认值

ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$MY_API_KEY}"
ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-$MY_BASE_URL}"
ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-$MY_MODEL}"
ANTHROPIC_DEFAULT_OPUS_MODEL="${ANTHROPIC_DEFAULT_OPUS_MODEL:-$MY_DEFAULT_OPUS_MODEL}"
ANTHROPIC_DEFAULT_SONNET_MODEL="${ANTHROPIC_DEFAULT_SONNET_MODEL:-$MY_DEFAULT_SONNET_MODEL}"
ANTHROPIC_DEFAULT_HAIKU_MODEL="${ANTHROPIC_DEFAULT_HAIKU_MODEL:-$MY_DEFAULT_HAIKU_MODEL}"
CLAUDE_CODE_SUBAGENT_MODEL="${CLAUDE_CODE_SUBAGENT_MODEL:-$MY_SUBAGENT_MODEL}"
CLAUDE_CODE_EFFORT_LEVEL="${CLAUDE_CODE_EFFORT_LEVEL:-$MY_EFFORT_LEVEL}"

ROOT_CLAUDE_DIR="/root/.claude"
ADMIN_CLAUDE_DIR="/home/admin/.claude"

echo "=== Claude Code 配置初始化 ==="

# 如果 API Key 为空，交互式输入
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo ""
    echo "🔑 未检测到 ANTHROPIC_API_KEY，请交互输入："
    read -r -p "请输入 API Key: " ANTHROPIC_API_KEY
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo "❌ API Key 不能为空，配置终止。"
        exit 1
    fi
    echo ""
    echo "✅ 已读取 API Key，自动继续配置..."
fi

if [ -z "$ANTHROPIC_API_KEY" ]; then
    mkdir -p "$ROOT_CLAUDE_DIR" "$ADMIN_CLAUDE_DIR"
else
    echo "✅ 检测到 ANTHROPIC_API_KEY，正在生成配置文件..."

    mkdir -p "$ROOT_CLAUDE_DIR"

    # 创建 settings.json - Claude Code 环境变量配置
    cat > "$ROOT_CLAUDE_DIR/settings.json" << EOF
{
    "env": {
        "ANTHROPIC_BASE_URL": "${ANTHROPIC_BASE_URL}",
        "ANTHROPIC_AUTH_TOKEN": "${ANTHROPIC_API_KEY}",
        "ANTHROPIC_MODEL": "${ANTHROPIC_MODEL}",
        "ANTHROPIC_DEFAULT_OPUS_MODEL": "${ANTHROPIC_DEFAULT_OPUS_MODEL}",
        "ANTHROPIC_DEFAULT_SONNET_MODEL": "${ANTHROPIC_DEFAULT_SONNET_MODEL}",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL": "${ANTHROPIC_DEFAULT_HAIKU_MODEL}",
        "CLAUDE_CODE_SUBAGENT_MODEL": "${CLAUDE_CODE_SUBAGENT_MODEL}",
        "CLAUDE_CODE_EFFORT_LEVEL": "${CLAUDE_CODE_EFFORT_LEVEL}"
    },
    "theme": "light-daltonized"
}
EOF

    # 创建 .claude.json - 初始化完成标志
    cat > "$ROOT_CLAUDE_DIR/.claude.json" << EOF
{
    "hasCompletedOnboarding": true
}
EOF

    echo "✅ 已创建 $ROOT_CLAUDE_DIR/settings.json"
    echo "✅ 已创建 $ROOT_CLAUDE_DIR/.claude.json"

    mkdir -p "$ADMIN_CLAUDE_DIR"
    cp "$ROOT_CLAUDE_DIR/settings.json" "$ADMIN_CLAUDE_DIR/"
    cp "$ROOT_CLAUDE_DIR/.claude.json" "$ADMIN_CLAUDE_DIR/"

    echo "✅ 已创建 $ADMIN_CLAUDE_DIR/ 配置"
    echo ""
    echo "=== Claude Code 配置完成 ==="
    echo "Base URL: ${ANTHROPIC_BASE_URL}"
    echo "模型: ${ANTHROPIC_MODEL}"
fi

echo ""
echo "=== 所有配置完成 ==="