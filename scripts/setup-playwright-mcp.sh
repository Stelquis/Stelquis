# ===================================================================
# Playwright MCP Server 安装配置脚本
# ===================================================================
# 功能: 为 Claude Code 配置 Playwright 网页抓取能力
# 用途: 抓取 JS 渲染页面（如招聘官网职位描述）
# 配置路径: ~/.claude/settings.json
#
# 一键运行:
#   bash /workspace/scripts/setup-playwright-mcp.sh
# ===================================================================

set -e

echo "=== Playwright MCP Server 配置 ==="
echo ""

# 1. 安装 @playwright/mcp（幂等：已安装则跳过）
echo "[1/4] 安装 Playwright MCP Server..."
if npm list -g @playwright/mcp >/dev/null 2>&1; then
  echo "  ✓ 已安装，跳过"
else
  npm install -g @playwright/mcp
  echo "  ✓ 安装完成"
fi

# 2. 确保 Playwright 浏览器已安装
echo "[2/4] 安装 Playwright 浏览器（Chromium）..."
npx --yes playwright install chromium
echo "  ✓ 浏览器安装完成"

# 3. 安装系统依赖（Linux 环境需要，macOS 跳过）
echo "[3/4] 安装系统依赖..."
if [[ "$(uname)" == "Linux" ]]; then
  npx --yes playwright install-deps 2>/dev/null || echo "  ⚠ install-deps 需要 sudo 权限，可手动执行: sudo npx playwright install-deps"
else
  echo "  ✓ 非 Linux 环境，跳过"
fi

# 4. 写入 Claude Code 配置
SETTINGS_FILE="$HOME/.claude/settings.json"
echo "[4/4] 配置 Claude Code MCP 服务器..."

# 如果配置文件不存在，创建基础结构
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# 使用 Python 合并配置（保留现有配置）
python3 << 'PYEOF'
import json
import os

settings_path = os.path.expanduser("~/.claude/settings.json")

with open(settings_path, "r") as f:
    settings = json.load(f)

if "mcpServers" not in settings:
    settings["mcpServers"] = {}

settings["mcpServers"]["playwright"] = {
    "command": "npx",
    "args": ["@playwright/mcp", "--headless"]
}

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("  ✓ MCP 配置已写入 ~/.claude/settings.json")
PYEOF

echo ""
echo "=== 配置完成 ==="
echo ""
echo "重启 Claude Code 后即可使用 Playwright 能力。"
echo ""
echo "使用示例："
echo '  "帮我打开 https://example.com/careers 抓取所有职位信息"'
echo '  "用浏览器访问某招聘页，等待加载完成后提取职位描述"'
