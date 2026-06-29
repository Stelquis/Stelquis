# ===================================================================
# CodeX 配置初始化脚本
# ===================================================================
# 功能: 根据环境变量或默认值生成 CodeX CLI 配置文件
# 配置路径: /root/.codex/ 和 /home/admin/.codex/
#
# 一键运行:
#   bash /workspace/scripts/init-codex.sh
# ===================================================================

set -e

# -----------------------------------------------------------------------------
# 用户配置区
# -----------------------------------------------------------------------------

# API Key: 留空则运行时交互输入
MY_API_KEY=""

# 中转站地址
# 可选: https://api.aifamily.vip/v1 或 https://laoni.laonics.top/v1
MY_BASE_URL="https://laoni.laonics.top/v1"

# 模型名称
# 可选: gpt-5.4, gpt-5.5, gpt-5.3-codex
MY_MODEL="gpt-5.4"

# -----------------------------------------------------------------------------
# 配置读取逻辑
# -----------------------------------------------------------------------------
# 优先级: 环境变量 > 脚本默认值

CODEX_API_KEY="${CODEX_API_KEY:-$MY_API_KEY}"
CODEX_BASE_URL="${CODEX_BASE_URL:-$MY_BASE_URL}"
CODEX_MODEL="${CODEX_MODEL:-$MY_MODEL}"

ROOT_CODEX_DIR="/root/.codex"
ADMIN_CODEX_DIR="/home/admin/.codex"

echo "=== CodeX 配置初始化 ==="

# 如果 API Key 为空，交互式输入
if [ -z "$CODEX_API_KEY" ]; then
    echo ""
    echo "🔑 未检测到 CODEX_API_KEY，请交互输入："
    read -r -p "请输入 API Key: " CODEX_API_KEY
    if [ -z "$CODEX_API_KEY" ]; then
        echo "❌ API Key 不能为空，配置终止。"
        exit 1
    fi
    echo ""
    echo "✅ 已读取 API Key，自动继续配置..."
fi

if [ -z "$CODEX_API_KEY" ]; then
    mkdir -p "$ROOT_CODEX_DIR" "$ADMIN_CODEX_DIR"
else
    echo "✅ 检测到 CODEX_API_KEY，正在生成配置文件..."

    mkdir -p "$ROOT_CODEX_DIR"

    cat > "$ROOT_CODEX_DIR/config.toml" << EOF
model_provider = "my_codex"
model = "${CODEX_MODEL}"
model_reasoning_effort = "high"
disable_response_storage = true

[model_providers.my_codex]
name = "my_codex"
wire_api = "responses"
requires_openai_auth = true
base_url = "${CODEX_BASE_URL}"

[linux]
sandbox = "elevated"
EOF

    cat > "$ROOT_CODEX_DIR/auth.json" << EOF
{
    "OPENAI_API_KEY": "${CODEX_API_KEY}"
}
EOF

    echo "✅ 已创建 /root/.codex/config.toml"
    echo "✅ 已创建 /root/.codex/auth.json"

    mkdir -p "$ADMIN_CODEX_DIR"
    cp "$ROOT_CODEX_DIR/config.toml" "$ADMIN_CODEX_DIR/"
    cp "$ROOT_CODEX_DIR/auth.json" "$ADMIN_CODEX_DIR/"

    echo "✅ 已创建 /home/admin/.codex/ 配置"
    echo ""
    echo "=== CodeX 配置完成 ==="
    echo "中转站: ${CODEX_BASE_URL}"
    echo "模型: ${CODEX_MODEL}"
fi

echo ""
echo "=== 所有配置完成 ==="