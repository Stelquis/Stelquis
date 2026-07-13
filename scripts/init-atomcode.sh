# ===================================================================
# AtomCode AI 编程助手配置初始化脚本
# ===================================================================
# 功能: 使用官方安装脚本安装 AtomCode CLI
# 安装方式:
#   curl -fsSL https://raw.atomgit.com/atomgit_atomcode/atomcode/raw/main/scripts/install.sh | sh
# 首次使用: 终端输入 atomcode 并按提示跳转网页登录
# ===================================================================
# 一键运行:
#   bash /workspace/scripts/init-atomcode.sh
# ===================================================================

set -e

echo "=== AtomCode 安装与初始化 ==="

# -----------------------------------------------------------------------------
# 第一步: 安装 AtomCode CLI
# -----------------------------------------------------------------------------
echo ""
echo "📦 正在安装 AtomCode CLI..."
echo "    源: https://raw.atomgit.com/atomgit_atomcode/atomcode/raw/main/scripts/install.sh"
echo ""

curl -fsSL https://raw.atomgit.com/atomgit_atomcode/atomcode/raw/main/scripts/install.sh | sh

echo ""
echo "✅ AtomCode CLI 安装完成"

# -----------------------------------------------------------------------------
# 第二步: 提示用户手动登录
# -----------------------------------------------------------------------------
echo ""
echo "============================================"
echo "  🚀 首次使用请在终端执行:"
echo ""
echo "     atomcode"
echo ""
echo "  按提示跳转网页登录后即可开始使用"
echo "============================================"
echo ""

echo "=== AtomCode 安装完成 ==="