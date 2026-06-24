
# 短视频流自适应预加载算法设计与实现

[![Python 3.13](https://img.shields.io/badge/python-3.13-blue.svg)](https://www.python.org/downloads/release/python-3130/)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://www.docker.com/)

> 基于 ACM Multimedia 2022 短视频流挑战赛的自适应预加载算法实现，通过智能带宽预测与动态预加载策略，在保障用户体验（QoE）的同时显著降低带宽浪费。

## 项目简介

本项目针对短视频应用（如 TikTok/抖音）中的流式传输优化问题，设计并实现了一套自适应预加载算法。在短视频场景中，用户通过滑动方式观看视频，系统需要预加载当前视频和推荐队列中的视频以保证流畅播放，但用户可能随时滑动跳过，导致预加载数据浪费。

**核心挑战**：如何在保证用户体验质量（QoE）的同时最小化带宽浪费，是多变的网络状态和不确定的用户行为下的关键难题。

**解决方案**：提出四级优化策略——三级网络状态分类、基于条件概率的动态预加载决策、自适应下载优先级调度、码率增强机制，实现 QoE 与带宽效率的最优平衡。

## 核心特性

-**智能带宽预测**：结合调和平均数与算术均值，实现鲁棒的带宽预测

-**动态预加载决策**：基于用户留存条件概率，动态调整预加载阈值

-**自适应优先级调度**：根据网络状态智能选择下载目标与码率

-**多网络环境适配**：支持高/中/低/混合四种网络环境的自适应优化

-**完整仿真平台**：基于 ACM MM'22 官方模拟器，支持算法快速验证

-**云原生开发环境**：Docker + CNB 云原生平台，一键启动开发环境

## 性能提升

对比 Baseline 算法在 4 种网络环境下的平均性能：

| 指标 | 提升幅度 |

|------|---------|

| **综合得分（Score）** | **+45.41%** |

| **用户体验质量（QoE）** | **+7.53%** |

| **带宽使用量** | **-9.00%** |

| **带宽浪费** | **-21.03%** |

| **下载/观看时间比** | **-10.17%** |

详细测试结果见 [result.txt](./Short-Video-Streaming-Challenge/result.txt)。

## 技术栈

### 基础设施

-**操作系统**: Ubuntu 24.04 LTS

-**编程语言**: Python 3.13

-**容器化**: Docker

-**云原生平台**: CNB (Cloud Native Build)

-**Web IDE**: code-server (VS Code Server)

### Python 依赖

```

numpy>=1.21.0

pandas>=1.5.0

scipy>=1.9.0

matplotlib>=3.5.0

seaborn>=0.12.0

scikit-learn>=1.0.0

```

## 快速开始

### 方式一：本地运行

1.**克隆仓库**

```bash

   git clone <repository-url>

   cd Short-Video-Streaming-Challenge

```

2.**安装依赖**

```bash

   pip install -r requirements.txt

```

3.**运行算法**

```bash

   # 运行自定义算法

   python run.py --solution ./

   

   # 运行基线算法对比

   python run.py --baseline no_save

   

   # 指定网络环境测试

   python run.py --solution ./ --trace high

```

### 方式二：Docker 运行

1.**构建镜像**

```bash

   docker build -t short-video-streaming .

```

2.**运行容器**

```bash

   docker run -it -v $(pwd):/workspace short-video-streaming

```

3.**在容器内运行算法**

```bash

   cd Short-Video-Streaming-Challenge

   python run.py --solution ./

```

### 方式三：CNB 云原生开发环境

点击 CNB 平台的「云原生开发」按钮，直接进入预配置的开发环境（包含 Python 3.13、VS Code Server、所有依赖）。

## 项目结构

```

.

├── Dockerfile                    # Docker 开发环境配置

├── .cnb.yml                      # CNB 云原生构建配置

├── LICENSE                       # MIT 开源许可证

├── requirements.txt              # Python 依赖

├── README.md                     # 项目文档

├── Overview.md                   # 详细项目概述

├── setting.json                  # VS Code 配置

└── Short-Video-Streaming-Challenge/

    ├── solution.py               # 核心算法实现（204行）

    ├── run.py                    # 仿真平台主程序

    ├── analysis.ipynb            # 数据分析与可视化

    ├── result.txt                # 性能测试结果

    ├── test.sh                   # Bash 测试脚本（Linux/macOS）

    ├── run_all.ps1               # PowerShell 测试脚本（Windows）

    │

    ├── simulator/                # 仿真器模块

    │   ├── controller.py         # 环境控制器（191行）

    │   ├── mpc_module.py         # MPC 算法模块（124行）

    │   ├── video_player.py       # 视频播放器（164行）

    │   ├── user_module.py        # 用户行为模型

    │   ├── network_module.py     # 网络模拟

    │   └── short_video_load_trace.py  # 数据加载

    │

    ├── baseline/

    │   └── no_save.py            # 基线算法（187行）

    │

    ├── quickstart/

    │   └── fix_preload.py        # 快速入门示例

    │

    ├── data/                     # 数据集

    │   ├── network_traces/       # 网络带宽 trace（4类×20条）

    │   │   ├── high/             # 高带宽网络

    │   │   ├── low/              # 低带宽网络

    │   │   ├── medium/           # 中等带宽网络

    │   │   └── mixed/            # 混合波动网络

    │   ├── short_video_size/     # 视频数据（7视频×3码率）

    │   └── user_ret/             # 用户留存模型（7视频）

    │

    ├── image/                    # 可视化图表（11张）

    │   ├── network_bandwidth_distribution.png

    │   ├── network_timeseries.png

    │   ├── video_data_analysis.png

    │   ├── user_retention_part1.png

    │   ├── user_retention_part2.png

    │   ├── bandwidth_prediction_*.png  # 4种网络预测图

    │   ├── performance_radar_chart.png

    │   └── improvement_percentage_bars.png

    │

    ├── file/                                  # 文档与参考资料

    │   ├── Official_README.md                 # 官方比赛说明

    │   ├── README_B.md                        # Baseline 说明

    │   ├── README_Q.md                        # Quickstart 说明

    │   ├── README_S.md                        # Solution 说明

    │   ├── ShortVideoPreloading.md            # 问题与算法详解

    │   ├── 短视频预加载的数据分析和算法设计.pdf  # 详细报告

    │   ├── video_data_illustration.jpeg

    │   ├── 图1：短视频场景下的视频播放流程.png

    │   └── 图2：短视频模拟器框架.png

    │

    ├── logs/                     # 测试日志

    │   ├── log.txt               # Solution 日志

    │   ├── log_nosave.txt        # Baseline 日志

    │   ├── log_fixpreload.txt    # Quickstart 日志

    │   └── sample_user/          # 用户行为采样

    │

    └── submit/                   # 提交文件

        ├── README.md             # 提交说明

        ├── submit.zip            # 提交包

        └── submit/solution.py    # 精简版提交代码

```

## 算法架构

### 四大核心策略

#### 1. 三级网络状态分类与带宽预测

- 使用**算术均值**进行网络状态分类（high/medium/low）
- 使用**调和平均数**进行带宽预测（抗极端值干扰）
- 动态阈值：高带宽 > 0.5 Mbps，低带宽 < 0.21 Mbps

#### 2. 基于条件概率的动态预加载决策

```python

# 计算用户留存条件概率

cond_p = retention[chunk_i] / retention[current]


# 动态阈值调整

threshold = base_threshold + 0.08 * buffer_factor

```

- 只有当当前和下一个 chunk 的观看概率都超过阈值时才预加载

#### 3. 自适应下载优先级

- 优先保证当前播放视频的缓冲区充足
- 根据网络状态动态调整目标缓冲区大小
- 缓冲区充足后，基于条件概率判断推荐队列视频的预加载价值

#### 4. 码率增强机制

- 在 MPC 基础上尝试更高码率
- 使用 0.92 安全边界防止卡顿
- 低质量网络时保守策略，高质量网络时积极提升

### MPC 基础算法

模型预测控制（MPC）通过枚举未来 5 个 chunk 的所有码率组合（3^5 = 243 种），选择使奖励最大化的组合：

```python

reward = (bitrate_sum/1000.0) 

       - (REBUF_PENALTY * rebuffer_time/1000.0) 

       - (smoothness_diffs/1000.0)

```

## 评估体系

### QoE 模型

```

QoE = Σ(w₁ × bitrateⱼ - w₂ × rebufferⱼ - w₃ × smoothⱼ)


权重系数：

- w₁ (码率权重) = 1

- w₂ (卡顿权重) = 1.85

- w₃ (平滑度权重) = 1

- w₄ (带宽浪费惩罚) = 0.5

```

### 评估维度

1.**QoE（用户体验质量）**：比特率收益 - 卡顿惩罚 - 平滑度惩罚

2.**Bandwidth Usage（带宽使用量）**：总下载字节数

3.**Sum Wasted Bytes（带宽浪费）**：下载但未被观看的字节数

4.**Wasted Time Ratio（下载/观看时间比）**：下载时间 / 总观看时间

5.**Score（综合得分）**：QoE - w₄ × 带宽使用

## 自动化测试

### Bash 脚本（Linux/macOS）

```bash

cdShort-Video-Streaming-Challenge

./test.sh

```

功能：

- Python 环境验证与依赖安装
- 4 种网络环境 × 3 种算法并行测试
- 性能指标自动提取与对比

### PowerShell 脚本（Windows）

```powershell

cd Short-Video-Streaming-Challenge

.\run_all.ps1

```

功能：

- 彩色输出与格式化
- Python 文件编译验证
- 结果对比表格生成

## 数据分析

项目包含完整的数据分析 Notebook（[analysis.ipynb](./Short-Video-Streaming-Challenge/analysis.ipynb)），提供丰富的可视化分析：

### 📊 网络带宽分析

| 网络带宽分布 | 网络带宽时序 |

|:-----------:|:-----------:|

| ![网络带宽分布](./Short-Video-Streaming-Challenge/image/network_bandwidth_distribution.png) | ![网络带宽时序](./Short-Video-Streaming-Challenge/image/network_timeseries.png) |

### 📹 视频数据分析

![视频数据分析](./Short-Video-Streaming-Challenge/image/video_data_analysis.png)

### 👤 用户留存分析

| 用户留存 (Part 1) | 用户留存 (Part 2) |

|:-----------------:|:-----------------:|

| ![用户留存1](./Short-Video-Streaming-Challenge/image/user_retention_part1.png) | ![用户留存2](./Short-Video-Streaming-Challenge/image/user_retention_part2.png) |

### 📈 带宽预测分析

| High网络 | Low网络 | Medium网络 | Mixed网络 |

|:--------:|:-------:|:----------:|:---------:|

| ![High](./Short-Video-Streaming-Challenge/image/bandwidth_prediction_high_trace16.png) | ![Low](./Short-Video-Streaming-Challenge/image/bandwidth_prediction_low_trace18.png) | ![Medium](./Short-Video-Streaming-Challenge/image/bandwidth_prediction_medium_trace12.png) | ![Mixed](./Short-Video-Streaming-Challenge/image/bandwidth_prediction_mixed_trace7.png) |

### 🏆 算法性能对比

| 性能雷达图 | 提升幅度对比 |

|:----------:|:------------:|

| ![雷达图](./Short-Video-Streaming-Challenge/image/performance_radar_chart.png) | ![提升幅度](./Short-Video-Streaming-Challenge/image/improvement_percentage_bars.png) |

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

## 参考文献

本项目基于以下研究工作：

1. [ACM Multimedia 2022 Grand Challenge](https://www.aitrans.online/MMGC2022)
2. Xutong Zuo et al. "Bandwidth-Efficient Multi-video Prefetching for Short Video Streaming." MM'22.
3. Chao Zhou et al. "PDAS: Probability-Driven Adaptive Streaming for Short Video." MM'22.
4. Ximing Wu et al. "QoE-aware Download Control and Bitrate Adaptation for Short Video Streaming." MM'22.
5. Si-Ze Qian et al. "DAM: Deep Reinforcement Learning based Preload Algorithm with Action Masking for Short Video Streaming." MM'22.

更多技术细节见 [Overview.md](./Overview.md)。

## 许可证

本项目采用 [MIT License](LICENSE) 开源许可证。

---

> 如果本项目对你有帮助，欢迎 ⭐ Star 支持！
>
