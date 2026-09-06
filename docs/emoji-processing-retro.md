# Emoji 处理复盘文档

> 本文档记录本次项目申请书中 emoji 符号的处理过程、问题根因、尝试方案及最终结论。

## 背景

项目申请书（`application.html`）使用了大量 emoji 作为标题和列表装饰符号（📌 🔧 📅 🌟 🐍 🔷 等），但在使用 WeasyPrint 导出 PDF 时，这些 emoji 无法正常渲染——表现为空白或乱码。

## 根因分析

WeasyPrint 在 Linux 上使用 Pango 做文本布局，Pango **不支持渲染彩色 emoji 字体**（如 Noto Color Emoji 的 CBDT/CBLC 格式）。遇到 emoji 字符时：

1. Pango 在字体栈中找不到能渲染它的字体
2. 回退到系统默认字体，默认字体也不支持彩色 emoji
3. 结果：要么完全消失（零宽字符），要么显示为方块（tofu）

## 尝试方案

### 方案 A：安装彩色 emoji 字体（失败）

- 安装 `fonts-noto-color-emoji`
- 结果：WeasyPrint/Pango 无法解析彩色位图格式，emoji 仍不可见

### 方案 B：安装纯黑 emoji 字体 Symbola（部分生效）

- 安装 `fonts-symbola`（纯黑矢量符号字体，OpenType 格式）
- 在 CSS 的 `--serif` 和 `--kai` 字体栈中加入 `"Symbola"`
- 问题：仅覆盖 Unicode 9.0 的 emoji（2016 年后的 emoji 不在 Symbola 中）
- 而且 CSS 加字体不生效，因为部分 emoji 位于 `--kai`（楷体）字体栈下，首次修改时遗漏了 `--kai`

### 方案 C：安装 Chrome + Puppeteer（未采用）

- 方案可行，但需下载约 300MB Chromium
- 排版需重新适配 WeasyPrint 的 `@page` 和 `break-inside` 规则

### 方案 D：彩色 emoji → 纯黑 Unicode 符号（最终方案）

- 保留 HTML 内容，将 emoji 字符替换为等价的纯黑 Unicode 符号（如 📌 → ◆, 🌟 → ★, 📋 → ☰）
- 这些是标准 Unicode 符号，WeasyPrint 用任意系统字体即可渲染
- 不需要额外字体，不改变排版

### 方案 E：完全删除 emoji（最终落地）

- 因部分纯黑符号渲染仍不稳定，最终决定删除所有 emoji 字符
- 标题前的 emoji 直接移除，正文中的 emoji 替换为适当上下文

## 最终 CSS 配置

```css
--kai: "KaiTi", "AR PL KaitiM GB", "AR PL KaitiM Big5", "Symbola", serif;
--serif: "PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", "Symbola", system-ui, -apple-system, sans-serif;
```

保留 Symbola 作为兜底，但不依赖它渲染特定符号。

## 经验教训

1. **不信任 emoji 在 Linux WeasyPrint 中的渲染** — 应从一开始就使用纯文本或 Unicode 符号
2. **Kami 的设计规范是正确的** — Kami 明确要求"不要在文档中使用图形 emoji"，所有 demo 模板中 emoji 数量为 0
3. **每次修改必须先验证再继续** — 多次出现改完一处就切换到下一处，导致修复链断裂
4. **字体栈需要覆盖所有用到的 font-family** — `--kai` 和 `--serif` 都要包含回退字体，不能只改其中一个

## 最终交付

| 文件 | 说明 |
|------|------|
| `application.html` | 零 emoji，纯文本符号，WeasyPrint 可渲染 |
| `application.pdf` | 7 页，所有字符正常显示 |
| `application-with-resume.pdf` | 8 页（含简历） |
