# Easy-Es AI Harness 自动化 PR 流水线

开源之夏（OSPP）2026 项目申请书及相关材料。

---

## 交付物

| 文件 | 说明 |
|---|---|
| `开源之夏2026-Easy-Es-AI-Harness-项目申请书.pdf` | **正式申请书**，37 页，Kami 设计系统排版 |
| `申请书.html` | 申请书的网页版，可直接浏览器打开或打印 |
| `项目申请书.md` | Markdown 源稿，便于在申请系统里复制粘贴、二次编辑 |
| `build_doc.py` | 从 Kami 模板生成上述 HTML/PDF 的脚本 |

> 申请系统通常需要填写 Markdown/富文本，用 `项目申请书.md` 最方便；
> 需要随邮件发送或打印时，用 PDF。

---

## 申请书结构

| 章节 | 内容 |
|---|---|
| 01 执行摘要 | 五条核心 Takeaways，含能力天花板与端到端数学 |
| 02 项目理解 | 五项产出的拆解、三个基本判断 |
| 03 前期调研 | 代码库现状、三处不一致、环境实测、Issue 生态预判 |
| 04 业界先例与理论支撑 | SWE-bench Multilingual 数据、工程先例、失败先例、差异化定位 |
| 05 技术方案 | 五条原则、七层架构、模块拆解、分层验证、方案对比、技术选型 |
| 06 实现路径 | 代码组织、交互边界、数据流、环境搭建 |
| 07 风险控制 | 九条风险矩阵、熔断设计（逐条对应事故归因）、待确认事项 |
| 08 时间规划 | 17 周里程碑、弹性缓冲、沟通计划 |
| 09 预期产出 | 八项交付物、三档验收标准、七项量化指标 |
| 10 个人匹配度 | 技术要求对照、三段核心经历、坦白的短板与补强 |
| 11 附录 | 参考资料、配置速查、沟通记录、申请人信息 |

---

## 核心论点

申请书区别于常规写法的地方，在于它是**被数据推着走**的，而非罗列技术名词：

1. **难度判断** —— 难度 4.2/5，脏活占比约 80%，而任务书叙事重心完全不在脏活上。

2. **能力天花板** —— SWE-bench Multilingual 实测 Java 解决率 **53.49%**（Python 63%），
   但该基准中位补丁仅 10 行，而 Easy-Es 新增一个查询 API 需横跨 **6 个文件层级**，
   故 53% 只是乐观上界。其中 `apache/lucene`（ES 底层库）仅 33.3%。

3. **瓶颈归属** —— SWE-bench 对成功/失败轨迹的人工检查表明，行动分布高度相似，
   说明**瓶颈在模型能力而非 Agent 设计**。这直接否定了「编排做复杂就能提升成功率」的路线。

4. **端到端数学** —— 设单环节正确率 0.65，六环节连乘成功率仅 **7.5%**，
   即平均需 6–35 次尝试。分层验证（L0<30s / L1<2min / L2 全量）是唯一解，
   目标单 PR 端到端 < 40 分钟。

5. **定位取舍** —— 做「AI 提供候选 + Maintainer 拍板」的 Copilot，而非全自治。
   依据包括 2026 年 9 月一起 Agent 夜间失控刷屏 500 条评论的真实事故。

---

## 重新生成

```bash
# 0. 子模块（必需！Kami 以 git submodule 引入，未初始化时目录为空、生成必然失败）
git -C /workspace submodule update --init repo/Kami

# 1. 准备环境（仅首次）
uv venv /tmp/kamienv --python 3.12
uv pip install --python /tmp/kamienv/bin/python weasyprint pymupdf pypdf
apt-get install -y libpango-1.0-0 libpangoft2-1.0-0 libharfbuzz0b \
                   libpangocairo-1.0-0 libcairo2

# 生成
cd /workspace/project/Easy-Es
/tmp/kamienv/bin/python build_doc.py

# 质量校验（需先 cd 到 Kami 目录）
cd /workspace/repo/Kami
/tmp/kamienv/bin/python scripts/build.py --check-placeholders /workspace/project/Easy-Es/申请书.html
/tmp/kamienv/bin/python scripts/build.py --check-markdown     /workspace/project/Easy-Es/*.pdf
/tmp/kamienv/bin/python scripts/build.py --check-density      /workspace/project/Easy-Es/*.pdf
```

修改内容请编辑 `build_doc.py` 中的章节常量（`CH_SUMMARY`、`CH_ARCH` 等），
不要直接改 `申请书.html`——它每次都会被脚本覆盖。

### 排版硬约束（`--check-markdown` 机器校验）

`Kami/scripts/checks.py` 的 `MARKDOWN_RESIDUE_MARKERS` 会扫描 PDF 文本层，命中即失败：

| 违规项 | 规则 | 正确做法 |
|---|---|---|
| **em dash** | 字符 `—`(U+2014) 一律禁止 | 改用逗号、句号、冒号或括号 |
| `**` | 未转换的加粗标记 | 用 `<strong>` |
| 反引号 | 未转换的行内代码标记 | 用 `<code>` |
| 分隔线 | 整行仅由 `-*_` 组成且 ≥3 个 | 用 `<hr>` 或分隔样式 |

> ⚠️ **最容易踩的坑**：`&mdash;` 这类 HTML 实体在源码里看不出问题，
> 但渲染进 PDF 文本层后就变成 U+2014，照样被判违规。表格里的空值不要用它，
> 改成 `-`、`不适用` 或具体说明。

**注意**：`项目申请书.md` 不经过 Kami 校验，因此保留了破折号以保持行文流畅。
两份产物的标点风格有意不同：md 用于粘贴进申请系统，PDF 用于打印与邮件发送。
若改动 `build_doc.py` 的正文，请勿直接从 md 复制含破折号的段落。

### 图表绘制的坑（重要）

**不要用 SVG 画含中文的图，会渲染成缺字方块。**

原因：SVG 内嵌 `<text>` 不会自动继承 HTML 的 `@font-face`，若写 `font-family: serif`
这类通用族，中文字形无覆盖，视觉上是乱码（但文本层仍可被提取，容易误判为正常）。

另外 SVG 的 `viewBox` 宽度远大于 A4 页面时会被大幅缩小，
760 宽的 viewBox 实际缩放比仅 0.48，框内文字只剩约 5pt（正文是 10pt）。

**正确做法**：用 `div` + CSS Grid 画框图，字号用 `pt` 单位，与正文保持一致。
本项目的图 1 即采用此方案，`build_doc.py` 中的 `.arch` 系列样式可直接复用。

---

## 待办

- [ ] 向导师发送咨询邮件（Q1 RISC-V64 口径 / Q2 PR 判定标准 / Q3 基线与双源抓取 / Q4 Harness 仓库归属）
- [ ] 收到回复后，据此更新 §07 待确认事项与 §08 时间规划
- [ ] 在 OSPP 系统内提交申请书

> 关于提交时机：2026 年开源之夏各流程**全年常态化开放，无统一 DDL**，
> 因此不存在"避开 DDL 拥堵"的问题。真正的时效约束是
> 「导师应在收到学生申请后**一周内**审核」，故尽早提交可为沟通往返留出余量。
> 另需注意：**中选公示前提交的 PR 不予认可**，请勿提前动手。
