# ===================================================================
# Qoder 配置初始化脚本
# ===================================================================
# 功能: 安装 Qoder CLI 终端原生 AI 编程助手
# 官网: https://qoder.com
# 说明: Qoder 围绕真实代码协同开发，支持从开发、调试到上线全流程
#       支持 Claude、GPT、Gemini 等主流模型，内置终端 IDE
#
# 一键运行（推荐，PATH 自动生效）:
#   eval "$(bash /workspace/scripts/init-qoder.sh)"
#
# 普通运行（安装后需手动 source ~/.profile）:
#   bash /workspace/scripts/init-qoder.sh
# ===================================================================

set -e

# -----------------------------------------------------------------------------
# 用户配置区
# -----------------------------------------------------------------------------

# 安装方式: curl (官方一键脚本)
INSTALL_METHOD="${QODER_INSTALL_METHOD:-curl}"

# 安装脚本地址
INSTALL_URL="https://qoder.com/install"

# 注意: Qoder CLI 安装后的二进制名为 qodercli，非 qoder
QODER_BIN="qodercli"

# -----------------------------------------------------------------------------
# 辅助函数：提示信息输出到 stderr，stdout 只留给 eval 命令
# -----------------------------------------------------------------------------

log() {
    echo "$@" >&2
}

# -----------------------------------------------------------------------------
# 安装函数
# -----------------------------------------------------------------------------

install_qoder_cli() {
    case "$INSTALL_METHOD" in
        curl|*)
            log "📦 通过 curl 安装 Qoder CLI..."

            # 检查是否已安装
            if command -v "$QODER_BIN" &>/dev/null; then
                log "⏭️  Qoder CLI 已安装，当前版本: $($QODER_BIN --version 2>/dev/null || echo 'unknown')"
                return 0
            fi

            # 官方一键安装脚本（其输出也重定向到 stderr）
            curl -fsSL "$INSTALL_URL" | bash >&2
            ;;
    esac
}

# -----------------------------------------------------------------------------
# 验证安装
# -----------------------------------------------------------------------------

verify_installation() {
    log ""

    # 刷新 PATH（安装脚本可能写入 shell 配置文件）
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        [ -f "$rc" ] && source "$rc" 2>/dev/null || true
    done

    # 尝试常见安装路径
    for p in "$HOME/.qoder/bin" "$HOME/bin" "$HOME/.local/bin" "/usr/local/bin"; do
        [ -d "$p" ] && export PATH="$p:$PATH"
    done

    if command -v "$QODER_BIN" &>/dev/null; then
        log "✅ Qoder CLI 安装成功！"
        log "   版本: $($QODER_BIN --version 2>/dev/null || echo 'unknown')"
        log ""
        log "   使用方式:"
        log "     qodercli                     # 启动交互式终端"
        log "     qodercli \"你的问题\"            # 单次提问"
        log "     qodercli --help               # 查看帮助"
        log ""
        log "   特点:"
        log "     - 终端原生 AI 编程助手"
        log "     - 支持多模型（Claude / GPT / Gemini）"
        log "     - 内置代码编辑与 Diff 预览"
        log "     - 支持开发、调试、上线全流程"

        # stdout 输出 PATH 设置命令，供 eval 捕获
        QODER_PATH_DIR=""
        for p in "$HOME/.local/bin" "$HOME/.qoder/bin"; do
            [ -d "$p" ] && QODER_PATH_DIR="$p" && break
        done
        if [ -n "$QODER_PATH_DIR" ]; then
            echo "export PATH=\"$QODER_PATH_DIR:\$PATH\""
        fi
    else
        log ""
        log "❌ Qoder CLI 安装失败，请手动安装:"
        log "   curl -fsSL https://qoder.com/install | bash"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# 主流程
# -----------------------------------------------------------------------------

log "=== Qoder 配置初始化 ==="
log ""
log "Qoder 是终端原生 AI 编程助手，围绕真实代码协同开发。"
log "官网: https://qoder.com"
log ""

# 安装 CLI
install_qoder_cli

# 验证安装
verify_installation

log ""
log "=== 所有配置完成 ==="

# 如果脚本不是被 source 执行的，提醒用户
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log ""
    log "💡 下次可使用以下命令一键安装并自动配置 PATH："
    log "   eval \"\$(bash /workspace/scripts/init-qoder.sh)\""
fi
