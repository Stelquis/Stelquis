<div align="center">

<!-- 顶部标题 - 纯文本优先，无动画依赖 -->
<h1>
  👋 Hi, I'm Niu
</h1>

<h3>数据科学 · 分布式系统 · 云原生</h3>

<br>

<!-- 联系徽章 - shields.io 静态图片，全平台兼容 -->
<a href="tel:+8613755122125">
  <img src="https://img.shields.io/badge/%E6%89%8B%E6%9C%BA-137--5512--2125-667eea?style=for-the-badge&logo=phone&logoColor=white" alt="手机" />
</a>
<a href="mailto:3420761503@qq.com">
  <img src="https://img.shields.io/badge/QQ-3420761503%40qq.com-764ba2?style=for-the-badge&logo=tencent-qq&logoColor=white" alt="QQ" />
</a>
<a href="mailto:XingChenNiu1001@gmail.com">
  <img src="https://img.shields.io/badge/Gmail-xingchenniu1001%40gmail.com-EA4335?style=for-the-badge&logo=gmail&logoColor=white" alt="Gmail" />
</a>
<a href="https://cnb.cool/u/STARS_NIU">
  <img src="https://img.shields.io/badge/CNB-STARS__NIU-00b894?style=for-the-badge&logo=codeforces&logoColor=white" alt="CNB" />
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
class NiuChenXun:
    def __init__(self):
        self.name = "牛晨勋"
        self.school = "中南大学"
        self.major = "数据科学与大数据技术"
        self.year = "2023 - 2027"
        self.location = "湖南 · 长沙"

    def focus(self):
        return ["分布式系统", "并发编程", "数据驱动优化"]

    def tools(self):
        return ["Python", "Docker", "Git", "Linux"]

    def motto(self):
        return "用数据理解世界，用代码构建未来"
```

</td>
<td width="40%" style="vertical-align: top;">

<div align="center">

**🎯 核心能力矩阵**

| 能力 | 水平 |
|------|------|
| Python 并发编程 | ████████░░ 80% |
| 分布式系统设计 | ██████░░░░ 60% |
| Docker / 云原生 | ███████░░░ 70% |
| 数据分析与可视化 | ████████░░ 80% |
| 算法与数据结构 | ███████░░░ 70% |

</div>

</td>
</tr>
</table>

---

<!-- 教育背景 -->
<div align="center">
  <h2>🎓 教育背景</h2>
</div>

<div align="center">

| 🏫 **中南大学** | 📅 2023.09 ~ 2027.07 |
|:---:|:---|
| **专业** | 数据科学与大数据技术（本科） |
| **排名** | 64 / 124 (前 50%) |

</div>

---

<!-- 项目经历 -->
<div align="center">
  <h2>🚀 项目经历</h2>
</div>

### 🕷️ PySpider - 高性能分布式网络爬虫系统 `2025.09 ~ 2025.12` [🔗 源码](https://cnb.cool/OrionSeeker/WebSpider)

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

**技术栈：** `Python 3.12` `threading` `requests` `Docker` `CNB`

<br>

### 📹 短视频流自适应预加载算法 `2025.12 ~ 2026.01` [🔗 源码](https://cnb.cool/OrionSeeker/Data-processing-method-Project)

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

**技术栈：** `Python 3.13` `NumPy` `Pandas` `MPC` `Docker` `CNB`

---

<!-- 专业技能 -->
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
<div align="center">
  <h2>💡 自我评价</h2>
</div>

<div align="center">

| 🤝 **团队协作** | 📚 **快速学习** | 🌱 **开源精神** |
|:---:|:---:|:---:
| 具备良好的团队协作意识，乐于沟通配合，能够在团队项目中主动承担任务并与成员有效协作 | 学习能力强，善于通过实践掌握新技术，乐于尝试和探索陌生领域，能够快速上手并解决问题 | 乐于知识分享与技术传播，热衷于参与 Datawhale 等开源学习活动，具有良好的社区贡献意识 |

</div>

---

<!-- 页脚 -->
<div align="center">

<br>

**📬 欢迎通过邮件或 CNB 与我联系，期待交流学习！**

<a href="mailto:3420761503@qq.com">
  <img src="https://img.shields.io/badge/QQ-3420761503%40qq.com-764ba2?style=for-the-badge&logo=tencent-qq&logoColor=white" alt="QQ" />
</a>
<a href="mailto:XingChenNiu1001@gmail.com">
  <img src="https://img.shields.io/badge/Gmail-xingchenniu1001%40gmail.com-EA4335?style=for-the-badge&logo=gmail&logoColor=white" alt="Gmail" />
</a>
<a href="https://cnb.cool/u/STARS_NIU">
  <img src="https://img.shields.io/badge/CNB-STARS__NIU-00b894?style=for-the-badge&logo=codeforces&logoColor=white" alt="CNB" />
</a>

<br><br>

</div>
