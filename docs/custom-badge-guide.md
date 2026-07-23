# 自建 SVG 徽章指南

> 如何像 shields.io 一样，用脚本生成一个自定义 SVG 徽章。

---

## 背景

shields.io 的徽章是**服务端生成的 SVG 图片**，不是 HTML/CSS 元素。一条 URL 就是一个完整的徽章：

```
https://img.shields.io/badge/Gitee-star--n-C71D23?logo=gitee&logoColor=white
```

但对于 simple-icons 库里没有的图标（如 CNB），shields.io 不支持自定义 logo 直接嵌入。因此需要自己写脚本生成 SVG 徽章。

## 生成流程

```
Python 脚本
    ↓
构建 SVG 元素（矩形背景 + 文字 + 图片）
    ↓
输出 .svg 文件
    ↓
README 中用 <img> 引用
```

## 技术要点

### 1. 徽章结构

一个 Flat 风格的徽章由以下 SVG 元素组成：

```
┌────────────────────────────────────────────────────────┐
│ <svg>                                                   │
│   <defs>                                                │
│     <filter id="blur">        ← 文字阴影模糊滤镜        │
│     <linearGradient>          ← 表面渐变遮罩            │
│     <clipPath>                ← 圆角裁剪路径            │
│   </defs>                                               │
│   <g clip-path="url(#c)">     ← 背景组（被圆角裁剪）    │
│     <rect fill="#24292e"/>    ← 左半（深色底）          │
│     <rect fill="#00b894"/>    ← 右半（绿色底）          │
│     <rect fill="url(#g)"/>    ← 渐变遮罩叠加            │
│   </g>                                                  │
│   <g fill="#fff">             ← 前景组（文字和图标）    │
│     <image/>                  ← logo 图标               │
│     <text>CNB</text>          ← 左侧标签名              │
│     <text>Stelquis</text>     ← 右侧账号名              │
│   </g>                                                  │
│ </svg>                                                  │
└────────────────────────────────────────────────────────┘
```

### 2. 间距设计

徽章分左右两区，所有间距用同一个 `PAD` 值控制：

```
左区（深色底）             右区（绿色底）
┌──────────────────────┐  ┌──────────────────┐
│ PAD  logo  PAD 文字  PAD │ PAD   文字    PAD │
│←5→   ←14→ ←5→  ←W→ ←5→│←5→    ←W→    ←5→│
└──────────────────────┘  └──────────────────┘
```

- PAD 统一为 5px
- logo 宽度 14px，高度 14px，垂直居中
- 文字宽度由 `text_width()` 函数计算

### 3. 文字渲染方式

shields.io 用 `<text>` 标签 + `textLength` 属性控制文字宽度：

```xml
<text x="320" y="140" transform="scale(.1)" textLength="240">CNB</text>
```

- `font-size="110"` 配合 `transform="scale(.1)"` 实际为 11px
- `textLength` 告诉浏览器文字应占多宽，浏览器自动拉伸/压缩字符适配
- 每个字符的宽度值决定字母间距

### 4. 字母间距配置

```python
def text_width(s):
    """估算 11px Verdana 下字符串宽度"""
    w = 0
    for c in s:
        if c.isupper():          # 大写字母
            w += 8
        elif c in "il":          # 窄字母
            w += 4
        else:                    # 小写字母
            w += 5.5
    return int(w)
```

值越大 → `textLength` 越大 → 字母间距越大。

## 生成脚本

将以下内容保存为 `make-badge.py`，然后运行 `python3 make-badge.py`：

```python
#!/usr/bin/env python3
"""生成 shields.io 风格的自定义 SVG 徽章

用法：
    python3 make-badge.py

配置：
    修改下方 LABEL / MSG / COLOR_L / COLOR_R / PAD 等常量即可自定义徽章
"""

import xml.etree.ElementTree as ET
import base64

# ===== 配置 =====
HEIGHT = 20
RX = 3
FONT = "Verdana,Geneva,DejaVu Sans,sans-serif"
PAD = 5            # 统一间距
LOGO_H = 14
SCALE = 10

# 徽章内容
LABEL = "CNB"
MSG = "Stelquis"
COLOR_L = "#24292e"
COLOR_R = "#00b894"

# 读取 logo（需替换为实际路径）
with open("logo.svg") as f:
    logo = base64.b64encode(f.read().strip().encode()).decode()


def text_width(s):
    """估算 11px Verdana 下字符串宽度，含字间距"""
    w = 0
    for c in s:
        if c.isupper():
            w += 8
        elif c in "il":
            w += 4
        else:
            w += 5.5
    return int(w)


def build_svg(label, msg, color_l, color_r, logo_b64, out_path):
    lw = text_width(label)
    mw = text_width(msg)
    logo_w = 14

    # 左半：PAD + logo + PAD + 文字 + PAD
    left_w = PAD + logo_w + PAD + lw + PAD
    # 右半：PAD + 文字 + PAD
    right_w = PAD + mw + PAD
    total_w = left_w + right_w

    # 文字水平居中位置
    label_center = PAD + logo_w + PAD + lw / 2
    msg_center = left_w + PAD + mw / 2

    # shields.io 方式：放大 SCALE 倍再 scale(.1)
    lx = SCALE * label_center
    mx = SCALE * msg_center
    ty = 140
    tl = SCALE * lw
    tm = SCALE * mw

    logo_y = int(0.5 * (HEIGHT - LOGO_H))

    svg = ET.Element("svg", {
        "xmlns": "http://www.w3.org/2000/svg",
        "width": str(total_w), "height": str(HEIGHT),
        "role": "img", "aria-label": f"{label}: {msg}"
    })

    defs = ET.SubElement(svg, "defs")
    f = ET.SubElement(defs, "filter", {"id": "b"})
    ET.SubElement(f, "feGaussianBlur", {"stdDeviation": "16"})
    g = ET.SubElement(defs, "linearGradient", {"id": "g", "x2": "0", "y2": "100%"})
    ET.SubElement(g, "stop", {"offset": "0", "stop-color": "#bbb", "stop-opacity": ".1"})
    ET.SubElement(g, "stop", {"offset": "1", "stop-opacity": ".1"})
    cp = ET.SubElement(defs, "clipPath", {"id": "c"})
    ET.SubElement(cp, "rect", {"width": str(total_w), "height": str(HEIGHT), "rx": str(RX)})

    bg = ET.SubElement(svg, "g", {"clip-path": "url(#c)"})
    ET.SubElement(bg, "rect", {"width": str(left_w), "height": str(HEIGHT), "fill": color_l})
    ET.SubElement(bg, "rect", {"x": str(left_w), "width": str(right_w), "height": str(HEIGHT), "fill": color_r})
    ET.SubElement(bg, "rect", {"width": str(total_w), "height": str(HEIGHT), "fill": "url(#g)"})

    fg = ET.SubElement(svg, "g", {
        "fill": "#fff", "text-anchor": "middle",
        "font-family": FONT, "font-size": "110",
        "text-rendering": "geometricPrecision"
    })
    ET.SubElement(fg, "image", {
        "x": str(PAD), "y": str(logo_y),
        "width": str(logo_w), "height": str(LOGO_H),
        "href": f"data:image/svg+xml;base64,{logo_b64}"
    })
    t1 = ET.SubElement(fg, "text", {
        "x": str(int(lx)), "y": str(ty),
        "transform": "scale(.1)", "textLength": str(tl)
    })
    t1.text = label
    t2 = ET.SubElement(fg, "text", {
        "x": str(int(mx)), "y": str(ty),
        "transform": "scale(.1)", "textLength": str(tm)
    })
    t2.text = msg

    ET.ElementTree(svg).write(out_path, encoding="utf-8", xml_declaration=True)
    print(f"✅ 生成 {out_path}  ({total_w}x{HEIGHT})")


if __name__ == "__main__":
    build_svg(LABEL, MSG, COLOR_L, COLOR_R, logo, "cnb-badge.svg")
```

## 在 README 中使用

生成 SVG 文件后，直接像 shields.io 徽章一样用 `<img>` 引用：

```markdown
<img src="assets/photos/cnb-badge.svg" alt="CNB">
```

## 与 shields.io 徽章的对比

| 对比项 | shields.io 徽章 | 自建 SVG 徽章 |
|:---|:---|:---|
| 生成方式 | 服务端在线生成 | 本地脚本生成 |
| 自定义图标 | 仅支持 simple-icons 库 | 任意 SVG 图标 |
| 引用方式 | `<img src="URL">` | `<img src="文件路径">` |
| 样式控制 | URL 参数 | 修改脚本常量 |
| 依赖 | 无 | Python 3 + 标准库 |

## 关键参数速查

| 参数 | 位置 | 作用 |
|:---|:---|:---|
| `PAD` | 脚本第 23 行 | 统一内外边距 |
| `w += 8` | `text_width()` 函数 | 大写字母间距 |
| `w += 4` | `text_width()` 函数 | 窄字母(i/l)间距 |
| `w += 5.5` | `text_width()` 函数 | 小写字母间距 |
| `LOGO_H` | 脚本第 24 行 | Logo 图标高度 |
| `COLOR_L` / `COLOR_R` | 脚本第 30-31 行 | 左右背景色 |
| `LABEL` / `MSG` | 脚本第 28-29 行 | 徽章文字内容 |