# CV-NIU

> 一份开箱即用的中文 LaTeX 简历模板 —— 改几行内容，`make` 一下，PDF 就有了。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![LaTeX](https://img.shields.io/badge/LaTeX-XeLaTeX-blue.svg)](https://www.latex-project.org/)
[![CNB](https://img.shields.io/badge/CNB-OrionSeeker%2FNiu-00b894)](https://cnb.cool/OrionSeeker/Niu)

## 快速开始

```bash
# 1. 克隆
git clone https://cnb.cool/OrionSeeker/Niu.git
cd Niu

# 2. 打开 resume/Niu/resume.tex，把个人信息替换成你自己的

# 3. 编译
make
```

打开 `resume/Niu/resume.pdf`，你的简历已经生成好了。

> 需要 LaTeX 环境？也可以直接用 Docker：`docker build -t cv-niu . && docker run --rm -v $(pwd):/workspace cv-niu`

## 定制指南

`resume.tex` 里所有需要修改的地方都标注了 `【修改】`，全局搜索就能找到。

### 你只需要关心这几个部分：

| 章节 | 文件中的位置 | 说明 |
|------|-------------|------|
| **基本信息** | 第 138–166 行 | 姓名、电话、邮箱、地点、年龄 |
| **个人照片** | 第 59–62 行 | 替换 `assets/photos/N.jpg` |
| **教育背景** | 第 182–202 行 | 学校、专业、GPA、排名 |
| **项目经历** | 第 250–276 行 | 两个项目示例，删改即可 |
| **荣誉奖项** | 第 334–339 行 | 奖项列表 |
| **专业技能** | 第 348–356 行 | 编程语言、工具、证书 |
| **自我评价** | 第 364–370 行 | 个人特质描述 |

### 可选模块（默认已注释，需要时取消注释）：

| 模块 | 用途 |
|------|------|
| 考研成绩表 | 复试简历专用 |
| 实习经历 | 有实习就打开 |
| 毕业设计 | 毕设题目 |
| 校园实践 | 社团、学生会 |
| 志愿经历 | 志愿服务 |
| 硕士规划 | 复试材料 |

### 替换照片

把证件照放到 `resume/assets/photos/` 目录下，然后在 `resume.tex` 第 61 行修改文件名即可。

### 参考模板

`resume/assets/template/` 目录下提供了 20+ 份真实求职简历 PDF，覆盖 Java、C++、前端、算法等方向，可作为撰写参考。

## 特性

| 特性 | 说明 |
|------|------|
| **专业排版** | XeLaTeX 引擎，PDF 输出效果对标杂志排版 |
| **中文优先** | 内置 Adobe 宋/黑/楷/仿宋四款中文字体 |
| **FontAwesome 图标** | 电话、邮箱、地点等可视化信息展示 |
| **模块化** | 每块内容独立，注释标记清晰，想改哪里改哪里 |
| **考研成绩** | 可选显示/隐藏初试成绩表格 |
| **一键编译** | `make` 编译 + 自动清理中间文件 |
| **Docker** | 提供 Dockerfile，免配 LaTeX 环境 |
| **跨平台** | Windows / macOS / Linux |
| **参考丰富** | 20+ 份各方向真实简历 PDF 示例 |

## 一个模板的故事

大一那年，我第一次写简历。Word 里对齐姓名和电话花了一整个下午，调完页边距整个人都麻了。室友看了一眼说："你这个……跟网上的模板感觉不太一样。"

后来接触到 LaTeX，才发现排版原来可以如此优雅。但市面上的模板要么纯英文，要么中文支持一塌糊涂。我在 [CTAN](https://ctan.org/) 文档和字体配置里折腾了三周，才调出让自己满意的效果。

**于是我把它整理成一个模板。**

我希望任何一个刚接触 LaTeX 的同学，打开文件、改几行内容、跑一遍 `make`，就能拿到一份排版精致的简历——不用像我当初那样在字体配置里掉头发。

这大概就是"用代码构建未来"的意义：写一段代码，替别人省下一整天。

## 项目结构

```
.
├── Makefile                        # 编译脚本
├── Dockerfile                      # 免配环境的容器化方案
├── scripts/                        # 辅助脚本
│
├── resume/
│   ├── Niu/                        # 模板主体
│   │   ├── resume.tex              #   简历内容 ← 你需要改的文件
│   │   ├── resume.cls              #   文档类（页面布局/字体/章节样式）
│   │   ├── resume.pdf              #   编译生成的简历
│   │   ├── *.sty                   #   字体/行距/图标样式文件
│   │   └── fontawesomesymbols-*.tex #  FontAwesome 图标定义
│   │
│   └── assets/
│       ├── cn-fonts/               # 中文字体 .otf × 4
│       ├── en-fonts/               # 英文字体 .otf × 5
│       ├── icon-fonts/             # Font Awesome 图标字体
│       ├── photos/                 # 照片示例
│       └── template/               # 20+ 参考简历 PDF
```

## 贡献

欢迎提 Issue 和 PR。如果你有好的简历模板或改进建议，随时贡献。

## 协议

MIT License © NIU

---

**祝求职顺利，复试成功！** 🎉
