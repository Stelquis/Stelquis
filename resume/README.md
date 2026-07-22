<div align="center">

<!-- 顶部横幅：本地 SVG，兼容 CNB / GitHub 等 Markdown 渲染 -->
<img src="assets/banner.svg" alt="Hi, I'm Niu - 数据科学 · 分布式 · 云原生" width="100%"/>

<br>

<!-- 联系徽章 - shields.io 静态图片，全平台兼容 -->
<a href="https://github.com/Stelquis">
  <img src="https://img.shields.io/badge/GitHub-Stelquis-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" />
</a>
<a href="https://gitee.com/star-n">
  <img src="https://img.shields.io/badge/Gitee-star--n-C71D23?style=for-the-badge&logo=gitee&logoColor=white" alt="Gitee" />
</a>
<a href="https://cnb.cool/u/STARS_NIU">
  <img src="https://img.shields.io/badge/CNB-STARS__NIU-00b894?style=for-the-badge&logo=codeforces&logoColor=white" alt="CNB" />
</a>
<a href="https://x.com/STARS_NIU">
  <img src="https://img.shields.io/badge/X-STARS__NIU-000000?style=for-the-badge&logo=x&logoColor=white" alt="X" />
</a>
<a href="#">
  <img src="https://img.shields.io/badge/%E5%9C%B0%E7%82%B9-%E6%B9%96%E5%8D%97%20%E9%95%BF%E6%B2%99-e17055?style=for-the-badge&logo=google-maps&logoColor=white" alt="地点" />
</a>

<br><br>

<!-- 状态标签 -->
<img src="https://img.shields.io/badge/%E7%8A%B6%E6%80%81-%E6%9C%AC%E7%A7%91%E5%9C%A8%E8%AF%BB-00b894?style=flat-square" alt="状态" />
<img src="https://img.shields.io/badge/%E5%AD%A6%E6%A0%A1-%E4%B8%AD%E5%8D%97%E5%A4%A7%E5%AD%A6-667eea?style=flat-square" alt="学校" />
<img src="https://img.shields.io/badge/%E4%B8%93%E4%B8%9A-%E6%95%B0%E6%8D%AE%E7%A7%91%E5%AD%A6%E4%B8%8E%E5%A4%A7%E6%95%B0%E6%8D%AE%E6%8A%80%E6%9C%AF-764ba2?style=flat-square" alt="专业" />
<img src="https://img.shields.io/badge/%E5%B9%B4%E7%BA%A7-2023%20%E7%BA%A7-e17055?style=flat-square" alt="年级" />

</div>

<br>

---

<!-- 关于我 -->
<div align="center">
  <h2>👋 关于我</h2>
</div>

<table>
<tr>
<td width="60%" style="vertical-align: top;">

```python
class Niu:
    """
    用数据理解世界，用代码构建未来。
    """

    def __init__(self):
        self.name     = "Niu"
        self.school   = "中南大学"
        self.major    = "数据科学与大数据技术"
        self.location = "湖南 · 长沙"

    def philosophy(self):
        return [
            "可复现 > 一次性",
            "系统化 > 打补丁",
            "数据驱动 > 凭感觉",
            "AI 不会取代你，会用 AI 的人才会",
        ]

    def build(self):
        return ["Docker", "Git", "Linux", "LaTeX"]

    def explore(self):
        return ["分布式系统", "数据可视化",
                "NLP", "并发编程"]
```

</td>
<td width="40%" style="vertical-align: top;">

<p><strong>🎯 我关心的事</strong></p>

| 我选择 |
|-------|
| 把实验跑在容器里，换机器不换环境 |
| 用数据说话，而不是直觉 |
| 写脚本让机器做重复的事 |
| 拥抱 AI，把它当副驾驶 |
| 分享知识，像 Datawhale 那样 |

</td>
</tr>
</table>

---

<!-- 项目经历 -->
<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%" />
</p>
<div align="center">
  <h2>🚀 项目经历</h2>
</div>

<details open>
<summary><b>🎭 「梨园星图」—— 京剧剧本多维可视分析系统</b> &nbsp;<sub>2026.03 ~ 2026.06</sub> &nbsp;<a href="https://cnb.cool/OrionDawn/HumanVIZ">🔗 源码</a></summary>
<br>

> 针对 1,473 部京剧剧本的非结构化文本难以直接量化分析，系统提取角色关系、主题分布与叙事模式，搭建数据挖掘与可视分析管线，**ChinaVis 2026 可视化竞赛参赛作品**。

<div align="center">

| 指标 | 数值 |
|------|------|
| 📊 数据规模 | 1,473 部剧本 / 7,965 角色人次 |
| 🔗 关系网络 | 22,494 节点 / 72,257 条边 |
| 🏷️ 特征体系 | 29 维角色特征 + 12 维主题 |
| 📖 叙事模式 | 8 种（KMeans 聚类） |
| 🎨 前端代码 | ~35,000 行 TS/TSX |

</div>

**核心亮点：**
- 🔬 **数据处理管线**：30+ Python 脚本，提取 29 维角色特征、8 项网络拓扑指标
- 📊 **统计建模**：卡方检验、ANOVA、PCA 降维 + 层次聚类，归纳 6 种主题原型与 8 种叙事模式
- 🤖 **NLP 语义增强**：BGE 嵌入、KeyBERT 关键词提取、SimCSE 语义相似度，DeepSeek 大模型辅助消歧
- 🖥️ **交互式可视分析**：力导向网络图、主题气泡矩阵、叙事丝带图及 3D 螺旋星系等多视图联动

**技术栈：** <kbd>Python</kbd> <kbd>FastAPI</kbd> <kbd>React</kbd> <kbd>TypeScript</kbd> <kbd>D3.js</kbd> <kbd>Three.js</kbd> <kbd>LangChain</kbd>

</details>

<br>

<details>
<summary><b>📹 短视频流自适应预加载算法</b> &nbsp;<sub>2025.12 ~ 2026.01</sub> &nbsp;<a href="https://cnb.cool/OrionSeeker/Data-processing-method-Project">🔗 源码</a></summary>
<br>

> 基于 **ACM Multimedia 2022 短视频流挑战赛**，针对短视频应用滑动式观看模式下的预加载数据浪费与带宽波动问题，设计并实现了一套自适应预加载算法。

<div align="center">

| 指标 | 提升幅度 |
|------|----------|
| 📊 **综合得分** | **+45.41%** ⬆️ |
| 🎯 **QoE 提升** | **+7.53%** ⬆️ |
| 💾 **带宽浪费降低** | **-21.03%** ⬇️ |
| 🌐 **带宽使用降低** | **-9.00%** ⬇️ |

</div>

**核心亮点：**
- 🧠 **预加载策略设计**：三级网络状态分类、基于条件概率的动态预加载决策、自适应下载优先级、码率增强机制
- 📈 **带宽预测实现**：结合调和平均数与算术均值进行鲁棒带宽预测，动态调整预加载阈值
- 🧪 **性能测试**：在 4 种网络环境（共 80 条 trace）下测试，综合得分平均提升 45.41%
- ☁️ **云原生开发**：Docker + CNB + code-server 开发环境，双平台自动化测试脚本

**技术栈：** <kbd>Python 3.13</kbd> <kbd>NumPy</kbd> <kbd>Pandas</kbd> <kbd>MPC</kbd> <kbd>Docker</kbd> <kbd>CNB</kbd>

</details>

<br>

<details>
<summary><b>🕷️ PySpider - 高性能分布式网络爬虫系统</b> &nbsp;<sub>2025.09 ~ 2025.12</sub> &nbsp;<a href="https://cnb.cool/OrionSeeker/WebSpider">🔗 源码</a></summary>
<br>

> 针对大规模网页抓取任务中高并发、URL 去重、数据持久化等挑战，设计并实现了基于**生产者-消费者模式**的分布式爬虫系统，在本地测试环境中成功完成 **160,000+ 网页**的抓取与解析。

<div align="center">

| 指标 | 数值 |
|------|------|
| 并发线程 | **44** 线程（24 抓取 + 20 解析） |
| 去重优化 | 锁竞争降低 **98%**，查询 < **1ms** |
| 内存占用 | **800MB** / 10万 URL |
| 抓取规模 | **160,000+** 网页 |

</div>

**核心亮点：**
- ⚡ **并发架构设计**：多级消息队列（FetchQueue → ParseQueue → ResultQueue），实现 44 线程并发，避免阻塞
- 🔍 **URL 去重优化**：64 分片集合去重器，全局锁竞争降低 98%，平均查询时间 < 1ms
- 🛡️ **系统稳定性**：优雅关闭机制、动态超时控制、异常隔离策略；逐行 CSV 持久化，断电不丢失
- 🐳 **容器化部署**：Docker + CNB 云原生开发平台，一键部署开箱即用

**技术栈：** <kbd>Python 3.12</kbd> <kbd>threading</kbd> <kbd>requests</kbd> <kbd>Docker</kbd> <kbd>CNB</kbd>

</details>

---

<!-- 专业技能 -->
<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%" />
</p>
<div align="center">
  <h2>🛠️ 专业技能</h2>
</div>

<div align="center">

**编程语言**

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![C](https://img.shields.io/badge/C-A8B9CC?style=for-the-badge&logo=c&logoColor=black)

**开发工具**

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![VS Code](https://img.shields.io/badge/VS%20Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)

**Python 生态**

![NumPy](https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Requests](https://img.shields.io/badge/Requests-FF6F00?style=for-the-badge)

**认证与能力**

| 认证 | 详情 |
|------|------|
| 🏅 **CCF CSP** | 200 分 |
| 🐳 **工程能力** | 熟悉 Docker 容器化部署和云原生开发流程 |
| 🌍 **英语能力** | CET-4 |

</div>

---

<!-- 荣誉奖项 -->
<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%" />
</p>
<div align="center">
  <h2>🏆 荣誉奖项</h2>
</div>

<div align="center">

| 🏅 奖项 | 📅 时间 |
|:---|:---|
| 中南大学数学建模竞赛校赛 **三等奖** | 2025.07 |
| Datawhale AI 夏令营 **优秀学习者** | 2024.08 |

</div>

---

<!-- 自我评价 -->
<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%" />
</p>
<div align="center">
  <h2>💡 自我评价</h2>
</div>

<table>
<tr>
<td width="33%" align="center" style="padding:16px; border-radius:12px; background:#f8f9fc; border-left:4px solid #667eea;">
<h3>🤝 团队协作</h3>
<p>具备良好的团队协作意识，乐于沟通配合，能够在团队项目中主动承担任务并与成员有效协作</p>
</td>
<td width="33%" align="center" style="padding:16px; border-radius:12px; background:#f8f9fc; border-left:4px solid #764ba2;">
<h3>📚 快速学习</h3>
<p>学习能力强，善于通过实践掌握新技术，乐于尝试和探索陌生领域，能够快速上手并解决问题</p>
</td>
<td width="33%" align="center" style="padding:16px; border-radius:12px; background:#f8f9fc; border-left:4px solid #00b894;">
<h3>🌱 开源精神</h3>
<p>乐于知识分享与技术传播，热衷于参与 Datawhale 等开源学习活动，具有良好的社区贡献意识</p>
</td>
</tr>
</table>

<p align="center">
  <img src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/colored.png" width="100%" />
</p>

<div align="center">

<a href="mailto:stelquis@gmail.com">
  <img src="https://img.shields.io/badge/Gmail-stelquis%40gmail.com-EA4335?style=for-the-badge&logo=gmail&logoColor=white" alt="Gmail" />
</a>
<a href="mailto:3420761503@qq.com">
  <img src="https://img.shields.io/badge/QQ-3420761503%40qq.com-764ba2?style=for-the-badge&logo=tencent-qq&logoColor=white" alt="QQ" />
</a>

</div>
