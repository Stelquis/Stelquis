# ===================================================================
# Kimi Code 安装与配置初始化脚本
# ===================================================================
# 功能: 检测/安装 kimi CLI（新版 Kimi Code），生成 config.toml（root + admin 用户）
# 一键运行:
#   bash /workspace/scripts/init-kimicode.sh
# ===================================================================

set -e

# -----------------------------------------------------------------------------
# 用户配置区（可被同名环境变量覆盖）
# -----------------------------------------------------------------------------
MY_API_KEY=""                              # 留空则运行时交互输入
MY_BASE_URL="https://api.deepseek.com/v1"  # DeepSeek: api.deepseek.com/v1
MY_PROVIDER_TYPE="openai_legacy"
MY_DEFAULT_MODEL="deepseek/deepseek-v4-flash"
MY_DEEPSEEK_PRO_MODEL="deepseek-v4-pro"
MY_DEEPSEEK_PRO_1M_MODEL="deepseek-v4-pro[1M]"
MY_DEEPSEEK_FLASH_MODEL="deepseek-v4-flash"
MY_PRO_CONTEXT_SIZE=131072
MY_PRO_1M_CONTEXT_SIZE=1048576
MY_FLASH_CONTEXT_SIZE=131072
MY_DEFAULT_THINKING=true

# -----------------------------------------------------------------------------
# 配置读取（环境变量 > 脚本默认值）
# -----------------------------------------------------------------------------
KIMICODE_API_KEY="${KIMICODE_API_KEY:-$MY_API_KEY}"
KIMICODE_BASE_URL="${KIMICODE_BASE_URL:-$MY_BASE_URL}"
KIMICODE_PROVIDER_TYPE="${KIMICODE_PROVIDER_TYPE:-$MY_PROVIDER_TYPE}"
KIMICODE_DEFAULT_MODEL="${KIMICODE_DEFAULT_MODEL:-$MY_DEFAULT_MODEL}"
KIMICODE_PRO_MODEL="${KIMICODE_PRO_MODEL:-$MY_DEEPSEEK_PRO_MODEL}"
KIMICODE_PRO_1M_MODEL="${KIMICODE_PRO_1M_MODEL:-$MY_DEEPSEEK_PRO_1M_MODEL}"
KIMICODE_FLASH_MODEL="${KIMICODE_FLASH_MODEL:-$MY_DEEPSEEK_FLASH_MODEL}"
KIMICODE_PRO_CONTEXT_SIZE="${KIMICODE_PRO_CONTEXT_SIZE:-$MY_PRO_CONTEXT_SIZE}"
KIMICODE_PRO_1M_CONTEXT_SIZE="${KIMICODE_PRO_1M_CONTEXT_SIZE:-$MY_PRO_1M_CONTEXT_SIZE}"
KIMICODE_FLASH_CONTEXT_SIZE="${KIMICODE_FLASH_CONTEXT_SIZE:-$MY_FLASH_CONTEXT_SIZE}"
KIMICODE_DEFAULT_THINKING="${KIMICODE_DEFAULT_THINKING:-$MY_DEFAULT_THINKING}"

ROOT_DIR="/root/.kimi"
ADMIN_DIR="/home/admin/.kimi"

# 工具函数：仅当有内容时才 echo（避免空行满天飞）
say() { [ -n "$*" ] && echo "$*"; }

# -----------------------------------------------------------------------------
# 第一步：检测 / 安装 kimi CLI
# -----------------------------------------------------------------------------
KIMI_BIN=""
for _p in /usr/local/bin/kimi /usr/bin/kimi /root/.kimi/bin/kimi; do
    [ -x "$_p" ] && { KIMI_BIN="$_p"; break; }
done
[ -z "$KIMI_BIN" ] && command -v kimi >/dev/null 2>&1 && KIMI_BIN="$(command -v kimi)"

if [ -n "$KIMI_BIN" ]; then
    say "✅ Kimi Code: $KIMI_BIN"
else
    say "📦 正在安装 Kimi Code ..."
    curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash || {
        curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash
    }

    # 单二进制安装后通常直接可用，但刷新 PATH 以防万一
    if [ -f /root/.local/bin/env ]; then
        . /root/.local/bin/env
    elif [ -d /root/.local/bin ]; then
        export PATH="/root/.local/bin:$PATH"
    fi

    if command -v kimi >/dev/null 2>&1; then
        KIMI_BIN="$(command -v kimi)"
        say "✅ Kimi Code: $KIMI_BIN"
    else
        say "⚠️  安装完成，但 kimi 不在 PATH 中，请手动加入后重试"
    fi
fi

# -----------------------------------------------------------------------------
# 第二步：获取 API Key
# -----------------------------------------------------------------------------
if [ -z "$KIMICODE_API_KEY" ]; then
    echo
    read -r -p "🔑 请输入 API Key: " KIMICODE_API_KEY
    [ -z "$KIMICODE_API_KEY" ] && { say "❌ API Key 不能为空"; exit 1; }
fi

# -----------------------------------------------------------------------------
# 第三步：生成配置
# -----------------------------------------------------------------------------
mkdir -p "$ROOT_DIR"

cat > "$ROOT_DIR/config.toml" << TOMLEOF
# ===================================================================
# Kimi Code 配置文件 — 由 init-kimicode.sh 自动生成
# ===================================================================

# 默认选中的模型（必须是 [models] 中定义的 key）
default_model = "${KIMICODE_DEFAULT_MODEL}"

# 默认是否开启 Thinking 模式
default_thinking = ${KIMICODE_DEFAULT_THINKING}

# 默认是否以计划模式启动新会话
default_plan_mode = false

# 在 Live 区域实时展示思考文本流
show_thinking_stream = true

# 合并所有可用技能目录
merge_all_available_skills = true

# 遥测开关
telemetry = true

# ===================================================================
# 供应商配置
# ===================================================================

[providers.deepseek]
type = "${KIMICODE_PROVIDER_TYPE}"
base_url = "${KIMICODE_BASE_URL}"
api_key = "${KIMICODE_API_KEY}"

# ===================================================================
# 模型映射
# ===================================================================
# DeepSeek V4 系列均支持 Thinking 模式，但不支持图片/视频输入
# capabilities 可选值: thinking, always_thinking, image_in, video_in

[models."deepseek/deepseek-v4-pro"]
provider = "deepseek"
model = "${KIMICODE_PRO_MODEL}"
max_context_size = ${KIMICODE_PRO_CONTEXT_SIZE}
capabilities = ["thinking"]

[models."deepseek/deepseek-v4-pro-1m"]
provider = "deepseek"
model = "${KIMICODE_PRO_1M_MODEL}"
max_context_size = ${KIMICODE_PRO_1M_CONTEXT_SIZE}
capabilities = ["thinking"]

[models."deepseek/deepseek-v4-flash"]
provider = "deepseek"
model = "${KIMICODE_FLASH_MODEL}"
max_context_size = ${KIMICODE_FLASH_CONTEXT_SIZE}
capabilities = ["thinking"]

# ===================================================================
# Agent 循环控制
# ===================================================================

[loop_control]
max_steps_per_turn = 1000
max_retries_per_step = 3
reserved_context_size = 50000
compaction_trigger_ratio = 0.85

# ===================================================================
# 后台任务
# ===================================================================

[background]
max_running_tasks = 4
keep_alive_on_exit = false
agent_task_timeout_s = 900

# ===================================================================
# MCP 客户端
# ===================================================================

[mcp.client]
tool_call_timeout_ms = 60000
TOMLEOF

# 同步到 admin 用户
if id admin >/dev/null 2>&1; then
    mkdir -p "$ADMIN_DIR"
    cp "$ROOT_DIR/config.toml" "$ADMIN_DIR/"
fi

# -----------------------------------------------------------------------------
# 输出摘要
# -----------------------------------------------------------------------------
echo
echo "✔  配置完成"
echo "   Base URL: ${KIMICODE_BASE_URL}"
echo "   默认模型: ${KIMICODE_DEFAULT_MODEL}"
echo "   可用模型: deepseek-v4-pro / deepseek-v4-pro-1m / deepseek-v4-flash"
echo "   配置路径: ${ROOT_DIR}/config.toml"
echo
echo "💡 启动: kimi"
echo "💡 切换模型: /model"
