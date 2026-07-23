# tRPC-Agent 学习指南

> 从零到一，掌握 Agent 工程化实践。
>
> 本文档以开源学习路径为纲，以 tRPC-Agent-Python 仓库的文档和示例为参考，用通俗的语言带你理解 Agent 工程的核心概念、进阶能力和生产级实践。

---

## 一、基础篇

### 1.1 Agent 工程化核心概念

#### 什么是 Agent？

Agent（智能体）是一个"能自己思考、会调用工具、记得上下文"的程序。它不像传统程序那样按固定流程执行，而是：

1. 接收你的输入（问题/指令）
2. 自己决定怎么做（调用 LLM 推理）
3. 必要时使用工具（查天气、搜文档、执行代码）
4. 给出最终回答

#### tRPC-Agent 的六大核心抽象

| 概念 | 一句话理解 | 类比 |
|------|-----------|------|
| **Agent** | 智能体本身，决定"下一步做什么" | 一个员工 |
| **Runner** | 负责把 Agent 跑起来，管理会话生命周期 | 员工的经理 |
| **Model** | 背后的大语言模型（LLM），负责推理和生成 | 员工的大脑 |
| **Tool** | Agent 可以调用的外部能力（函数/API） | 员工的工具箱 |
| **Session** | 一次对话的完整记录，包括消息、状态、事件 | 员工的工单记录 |
| **Memory** | 跨会话的长期记忆，记住用户的偏好和历史 | 员工的笔记本 |
| **Graph** | 把多个 Agent 编排成工作流，像流程图一样执行 | 员工的操作手册 |

#### 一次 Agent 调用的完整链路

当用户发来一条消息，背后发生的事情：

```
① 用户输入 "今天北京天气怎么样？"
    │
    ▼
② Runner.run_async()
   ├── 获取或创建 Session（记录这次对话）
   ├── 把用户消息追加到 Session 中
   └── 创建 InvocationContext（这次调用的"工作证"）
    │
    ▼
③ Agent._run_async_impl()
   ├── Filter 链（前置检查：敏感词？权限？拦截？）
   ├── RequestProcessor 拼装请求
   │   ├── 系统指令（你是天气助手）
   │   ├── 工具列表（get_weather, search_web...）
   │   └── 历史消息（之前的对话）
   ├── LlmProcessor 调用 LLM
   │   └── LLM 返回：想用 get_weather("北京") 工具
   ├── ToolsProcessor 执行工具
   │   ├── 解析参数 → 调用 get_weather("北京")
   │   └── 返回结果 "25°C，晴"
   ├── LlmProcessor 再次调用 LLM（带上工具结果）
   │   └── LLM 返回：最终回答 "北京今天 25°C，天气晴朗"
   └── 循环，直到 LLM 不再调用工具
    │
    ▼
④ Runner 后处理
   ├── 生成会话摘要
   ├── 保存到 Memory（长期记忆）
   └── 发送 Telemetry（监控数据）
    │
    ▼
⑤ 事件流输出 → 用户看到回答
```

**关键理解**：这不是一次性的"问→答"，而是一个**多轮循环**——LLM 可以反复调用工具、拿到结果、再推理，直到给出最终答案。

#### 参考文档

- `docs/mkdocs/zh/llm_agent.md` — Agent 核心概念
- `docs/mkdocs/zh/model.md` — 模型配置
- 示例：`examples/quickstart/` — 最小 Agent

---

### 1.2 Quickstart：跑通你的第一个 Agent

#### 最小 Agent 示例

不需要理解所有细节，先跑起来：

```python
from trpc_agent_sdk.agents import LlmAgent
from trpc_agent_sdk.models import OpenAIModel
from trpc_agent_sdk.runners import Runner
from trpc_agent_sdk.sessions import InMemorySessionService

# 1. 配置模型（这里以 DeepSeek 为例）
model = OpenAIModel(
    model_name="deepseek-chat",
    api_key="sk-xxxxx",
    base_url="https://api.deepseek.com/v1",
)

# 2. 创建 Agent
agent = LlmAgent(
    name="assistant",
    model=model,
    instruction="你是一个友好的助手，请用中文回答。",
)

# 3. 创建 Runner（负责运行 Agent）
session_service = InMemorySessionService()
runner = Runner(
    app_name="demo",
    agent=agent,
    session_service=session_service,
)

# 4. 运行（异步迭代事件流）
import asyncio

async def main():
    async for event in runner.run_async(
        user_id="user1",
        session_id="session1",
        new_message="你好，请介绍一下自己。",
    ):
        if event.content and event.content.parts:
            for part in event.content.parts:
                if part.text:
                    print(part.text, end="")

asyncio.run(main())
```

#### 关键点

- **`LlmAgent`**：最基础的 Agent 类型，支持多轮 tool loop
- **`Runner`**：管理 Session 生命周期，生成事件流
- **`InMemorySessionService`**：会话数据存在内存中，适合开发测试
- **事件流**：`runner.run_async()` 返回的是一个异步生成器（AsyncGenerator），每次 `yield` 一个事件

#### 流式输出

把 `streaming=True` 传给 `Runner` 或 `RunConfig`，就可以看到逐字输出的效果：

```python
from trpc_agent_sdk.configs import RunConfig

runner = Runner(
    app_name="demo",
    agent=agent,
    session_service=session_service,
    run_config=RunConfig(streaming=True),
)
```

#### 参考文档与示例

- `docs/mkdocs/zh/llm_agent.md` — LlmAgent 详细配置
- `docs/mkdocs/zh/model.md` — 模型支持列表（OpenAI、Anthropic、DeepSeek、Gemini...）
- 示例：`examples/quickstart/` — 完整的最小 Agent 示例

---

### 1.3 Function Calling 与工具调用

#### 什么是 Function Calling？

Function Calling 是 LLM 的一项能力：它**不是直接回答问题**，而是说"我想调用某个函数，参数是这些"，然后由框架去执行这个函数，把结果带回给 LLM。

```
用户："北京天气怎么样？"
  │
LLM 思考："用户想查天气，我有一个 get_weather 工具"
  │
LLM 返回：{"function_call": {"name": "get_weather", "args": {"city": "北京"}}}
  │
框架执行 get_weather("北京") → "25°C，晴"
  │
LLM 拿到结果 → 组织回答："北京今天 25°C，天气晴朗。"
```

#### 把普通函数变成工具

```python
from trpc_agent_sdk.tools import FunctionTool

# 一个普通的 Python 函数
def get_weather(city: str) -> str:
    """查询指定城市的天气。
    
    Args:
        city: 城市名称，如"北京"、"上海"
    
    Returns:
        天气信息字符串
    """
    # 这里应该是真实的 API 调用
    return f"{city}: 25°C，晴"

# 封装成工具
weather_tool = FunctionTool(get_weather)

# 给 Agent 配上工具
agent = LlmAgent(
    name="weather_assistant",
    model=model,
    instruction="你是天气助手，查询天气时使用 get_weather 工具。",
    tools=[weather_tool],
)
```

#### SDK 自动帮你做了这些

1. **解析函数签名** → 生成 JSON Schema（LLM 能理解的格式）
2. **参数校验** → 确保 LLM 传的参数类型正确
3. **执行函数** → 调用你的 Python 函数
4. **错误处理** → 函数抛异常时，把错误信息返回给 LLM 重试或解释
5. **结果返回** → 把函数返回值送回给 LLM

#### 工具类型一览

| 工具类型 | 适用场景 | 参考 |
|---------|---------|------|
| `FunctionTool` | 普通函数封装 | 大多数场景 |
| `StreamingFunctionTool` | 流式输出工具（如实时翻译） | `examples/llmagent_with_streaming_tool_simple/` |
| `MCPToolset` | 通过 MCP 协议接入外部工具服务 | 进阶篇介绍 |
| `Agent-as-Tool` | 把一个 Agent 当作另一个 Agent 的工具 | `docs/mkdocs/zh/sub_agent.md` |

#### 参考文档与示例

- `docs/mkdocs/zh/tool.md` — 工具系统完整文档
- 示例：`examples/function_tools/` — 多种工具封装示例

---

### 1.4 Session 会话管理

#### 什么是 Session？

Session 就是一次对话的"档案袋"，里面装着：

- **消息历史**：用户说了什么、Agent 回了什么
- **状态**：当前对话的状态数据（如用户选择的选项）
- **事件**：每一步的详细记录（LLM 调用、工具执行、错误等）
- **Token 用量**：每次 LLM 调用花了多少 token

#### 三种会话后端

| 后端 | 数据存哪 | 适合场景 | 参考文档 |
|------|---------|---------|---------|
| `InMemorySessionService` | 内存 | 开发/测试，重启即丢 | `docs/mkdocs/zh/session.md` |
| `SqlSessionService` | SQLite / PostgreSQL | 生产环境，需要持久化 | `docs/mkdocs/zh/session_sql.md` |
| `RedisSessionService` | Redis | 高并发、分布式场景 | `docs/mkdocs/zh/session_redis.md` |

#### SQL 会话持久化示例

```python
from trpc_agent_sdk.sessions import SqlSessionService

session_service = SqlSessionService("sqlite:///sessions.db")
runner = Runner(app_name="demo", agent=agent, session_service=session_service)
```

之后每次对话都会自动保存到数据库，重启后也能恢复。

#### 会话摘要

长对话会消耗大量 token。Session 支持**自动摘要**——当对话超过阈值时，自动把历史浓缩成摘要，释放上下文空间。

```python
from trpc_agent_sdk.sessions import SummarizerSessionManager

# 配置摘要策略
manager = SummarizerSessionManager(
    token_threshold=4000,      # 超过 4000 token 时触发摘要
    time_interval=3600,        # 或 1 小时后触发
    events_count_threshold=50, # 或 50 条消息后触发
)
```

详细文档：`docs/mkdocs/zh/session_summary.md`

#### 参考文档与示例

- `docs/mkdocs/zh/session.md` — 会话管理基础
- `docs/mkdocs/zh/session_sql.md` — SQL 持久化
- `docs/mkdocs/zh/session_redis.md` — Redis 持久化
- 示例：`examples/session_service_with_sql/` — SQLite 会话示例

---

## 二、进阶篇

### 2.1 Memory 与 Knowledge / RAG

#### Memory（长期记忆）

**问题**：Session 只记住一次对话内的内容。下次用户再来，Agent 不记得上次聊过什么。

**解决**：Memory 系统把重要的信息跨会话保存下来。

**工作流程**：

```
用户第一次："我叫张三，喜欢 Python。"
  │
会话结束后 → Memory 存储 {"name": "张三", "interests": ["Python"]}
  │
用户第二次："你还记得我吗？"
  │
Agent 启动 → load_memory_tool 自动加载记忆
  │
Agent 知道："这是张三，他喜欢 Python。"
```

**配置方式**：

```python
from trpc_agent_sdk.memory import SqlMemoryService
from trpc_agent_sdk.tools import load_memory_tool

memory_service = SqlMemoryService(
    db_url="sqlite:///memory.db",
    ttl=3600 * 24 * 30,  # 30 天过期
)

agent = LlmAgent(
    ...,
    tools=[load_memory_tool],  # 让 Agent 能主动加载记忆
)
```

**详细文档**：`docs/mkdocs/zh/memory.md`

#### Knowledge / RAG（检索增强生成）

**问题**：LLM 的知识有截止日期，也不知道你的内部文档。

**解决**：RAG 把"检索"和"生成"结合起来——先搜文档，再回答问题。

**完整流程**：

```
用户提问："我们的数据库连接超时怎么配置？"
  │
① 文档加载 → 读取公司内部的编码规范文档
  │
② 文本切分 → 把长文档切成 500 字的片段
  │
③ 向量化 → 每个片段转成向量（数学上的"语义指纹"）
  │
④ 向量检索 → 找到和问题最相关的 3 个片段
  │
⑤ 上下文拼接 → 把片段 + 问题一起发给 LLM
  │
⑥ LLM 回答 → 基于检索到的文档内容给出答案
```

**配置方式**：

```python
from trpc_agent_sdk.knowledge import LangchainKnowledge
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings

rag = LangchainKnowledge(
    document_loader=TextLoader("docs/coding_standards.md"),
    document_transformer=RecursiveCharacterTextSplitter(
        chunk_size=500, chunk_overlap=50,
    ),
    embedder=HuggingFaceEmbeddings(model_name="BAAI/bge-small-en-v1.5"),
    search_type="similarity",
    search_kwargs={"k": 3},
)
```

**知识库子模块详解**：

| 模块 | 做什么 | 常用选择 | 文档 |
|------|--------|---------|------|
| Document Loader | 读取文档 | TextLoader、PDFLoader、CSVLoader | `docs/mkdocs/zh/knowledge_document_loader.md` |
| Text Splitter | 切分文本 | RecursiveCharacterTextSplitter | `docs/mkdocs/zh/knowledge_text_splitter.md` |
| Embedder | 转向量 | HuggingFace、OpenAI | `docs/mkdocs/zh/knowledge_embedder.md` |
| Vector Store | 存向量 | InMemory、FAISS、Chroma | `docs/mkdocs/zh/knowledge_vectorstore.md` |
| Retriever | 检索 | 相似度搜索、MMR | `docs/mkdocs/zh/knowledge_retrievers.md` |
| Prompt Template | 拼提示词 | 自定义模板 | `docs/mkdocs/zh/knowledge_prompt_template.md` |

**参考文档与示例**：
- `docs/mkdocs/zh/knowledge.md` — 知识库总览
- 示例：`examples/knowledge_with_rag_agent/` — 完整的 RAG Agent

---

### 2.2 多 Agent 协作与图编排

#### 为什么需要多 Agent？

一个 Agent 做所有事情就像一个人既当前台又当会计又当保洁——不高效。多 Agent 协作把不同职责拆给不同的 Agent：

| 场景 | 单 Agent 的问题 | 多 Agent 的好处 |
|------|---------------|----------------|
| 复杂任务 | 指令太长，LLM 容易混淆 | 每个 Agent 专注一件事 |
| 专业分工 | 一个 Agent 什么都会，什么都不精 | 每个 Agent 有自己的 instruction |
| 流程控制 | 难以控制执行顺序和条件 | 编排引擎决定谁先谁后 |

#### 编排方式一览

**ChainAgent（链式）**：顺序执行，前一个的输出传给后一个

```
Agent A（提取信息）→ Agent B（翻译）→ Agent C（格式化输出）
```

示例：`examples/multi_agent_chain/`

**ParallelAgent（并行）**：多个 Agent 同时执行，结果合并

```
        ┌→ Agent A（查天气）┐
用户输入 ┤→ Agent B（查新闻）├→ 结果合并
        └→ Agent C（查日历）┘
```

**CycleAgent（循环）**：循环执行直到满足条件

```
Agent A（生成方案）→ Agent B（评审）→ 不合格 → 回到 Agent A
                                    → 合格 → 输出
```

**TeamAgent（团队）**：一个 Manager 管理多个 Worker

```
Manager（分配任务）
  ├── Worker A（写代码）
  ├── Worker B（写测试）
  └── Worker C（写文档）
```

详细文档：`docs/mkdocs/zh/multi_agents.md`、`docs/mkdocs/zh/team.md`

#### GraphAgent（图编排）

GraphAgent 是最强大的编排方式，把工作流画成**有向图**：

```
          ┌→ 工具调用 ─→ ┐
用户输入 → 意图识别 ─→ 知识库搜索 ─→ 格式化输出
          └→ LLM 直接回答 ─→ ┘
```

**核心概念**：

| 概念 | 说明 | 类比 |
|------|------|------|
| **节点（Node）** | 工作流中的一个步骤 | 流程图中的方框 |
| **边（Edge）** | 节点之间的连接 | 箭头 |
| **条件路由** | 根据结果走不同分支 | if-else |
| **状态（State）** | 节点间传递的数据 | 流水线上的工件 |
| **状态 reducer** | 合并多个节点的输出 | 汇总 |
| **Checkpoint** | 保存执行进度 | 游戏存档 |
| **Interrupt/Resume** | 暂停等待人工审批，然后继续 | 审批流程 |

**GraphAgent 示例**：

```python
from trpc_agent_sdk.dsl.graph import GraphAgent, StateGraph, NodeConfig

async def step1(state):
    # 处理输入
    return {"processed": state["input"] + "processed"}

async def step2(state):
    # 最终输出
    return {"output": f"结果: {state['processed']}"}

graph = StateGraph(dict)
graph.add_node("step1", step1, config=NodeConfig(name="step1", desc="第一步"))
graph.add_node("step2", step2, config=NodeConfig(name="step2", desc="第二步"))
graph.set_entry_point("step1")
graph.set_finish_point("step2")
graph.add_edge("step1", "step2")

agent = GraphAgent(name="workflow", graph=graph.compile())
```

**GraphAgent 的高级用法**：

- `add_llm_node()`：添加 LLM 节点（带 instruction 的自动推理）
- `add_agent_node()`：添加子 Agent 节点
- `add_code_node()`：添加代码执行节点
- `add_knowledge_node()`：添加知识库检索节点
- `add_mcp_node()`：添加 MCP 工具调用节点
- `add_conditional_edges()`：条件路由，根据状态走不同分支

**参考文档与示例**：
- `docs/mkdocs/zh/graph.md` — GraphAgent 完整文档
- `docs/mkdocs/zh/langgraph_agent.md` — LangGraphAgent
- 示例：`examples/graph/` — 完整的 GraphAgent 示例

---

### 2.3 MCP、A2A 与 AG-UI 协议

#### MCP（Model Context Protocol）

MCP 是让 Agent 接入外部工具服务的**标准协议**。你可以把 MCP 理解为"工具的 USB 接口"——只要服务提供 MCP 接口，Agent 就能直接用。

**工作方式**：

```
Agent → MCPToolset → MCP Server（工具提供方）
                      ├── 计算器服务
                      ├── 数据库查询服务
                      └── 第三方 API 封装
```

**三种 MCP 模式**：
- **stdio**：本地启动子进程通信
- **HTTP SSE**：通过 HTTP 流式通信
- **WebSocket**：双向实时通信

#### A2A（Agent-to-Agent）

A2A 让不同的 Agent 之间可以互相通信。一个 Agent 可以把任务委托给另一个 Agent。

**工作方式**：

```
Agent A（用户助手）
  │  A2A 协议
  ▼
Agent B（专业翻译）
  │  A2A 协议
  ▼
Agent C（格式校对）
```

**A2A 服务部署**：

```python
from trpc_agent_sdk.server.a2a import TrpcA2aAgentService

a2a_svc = TrpcA2aAgentService(
    service_name="my_agent",
    agent=root_agent,
    session_service=session_service,
    memory_service=memory_service,
)
a2a_svc.initialize()
```

详细文档：`docs/mkdocs/zh/a2a.md`
示例：`examples/a2a/`

#### AG-UI（Agent UI 协议）

AG-UI 是 Agent 向前端（网页/App）输出结构化事件的标准协议。它让前端能实时看到 Agent 的"思考过程"。

**AG-UI 能做什么**：
- 实时显示 LLM 的逐字输出（流式）
- 显示工具调用过程（正在查天气...）
- 显示进度条（正在处理，已完成 30%...）
- 兼容 CopilotKit 等前端框架

**AG-UI 服务部署**：

```python
from trpc_agent_sdk.server.ag_ui import AgUiAgent, AgUiManager

agui_agent = AgUiAgent(trpc_agent=root_agent, app_name="my_app")
agui_manager = AgUiManager()
agui_service = AgUiService("my_service", app=fastapi_app)
agui_service.add_agent("/agent", agui_agent)
agui_manager.register_service("my_service", agui_service)
```

详细文档：`docs/mkdocs/zh/agui.md`
示例：`examples/agui/`

#### 服务化部署方式对比

| 方式 | 适用场景 | 参考 |
|------|---------|------|
| **FastAPI Server** | 标准 REST API | `examples/fastapi_server/` |
| **A2A Server** | Agent 间通信 | `examples/a2a/` |
| **AG-UI Server** | 前端实时交互 | `examples/agui/` |
| **Gateway Server** | 统一入口/多协议路由 | 进阶部署 |

---

### 2.4 Skills 与 CodeExecutor

#### Skill 体系

Skill 是把一组"规则 + 脚本"打包成可复用的能力单元。Agent 可以按需加载 Skill，在隔离环境中执行。

**Skill 的目录结构**：

```
skills/my-skill/
├── SKILL.md          # 技能描述（名称、规则、脚本说明）
├── rules/            # 规则文档
│   ├── rule1.md
│   └── rule2.md
└── scripts/          # 沙箱执行脚本
    ├── script1.py
    └── script2.sh
```

**SKILL.md 示例**：

```markdown
---
name: my-skill
description: 我的自定义技能
---

# My Skill

## Rules

- rule1: 规则说明
- rule2: 规则说明

## Scripts

1) script1.py <input> <output> — 脚本说明
2) script2.sh <input> <output> — 脚本说明

## Output Files

- out/result.json
```

**Agent 调用 Skill**：

```python
from trpc_agent_sdk.skills import SkillToolSet

skill_set = SkillToolSet("skills/my-skill")
await skill_set.skill_load("my-skill")  # 加载规则文档
await skill_set.skill_run("scripts/script1.py", args=[...])  # 执行脚本
```

详细文档：`docs/mkdocs/zh/skill.md`

#### CodeExecutor（沙箱执行）

Skill 的脚本在**沙箱**中执行，保证安全：

| 执行器 | 隔离级别 | 启动方式 | 安全等级 |
|--------|---------|---------|---------|
| `UnsafeLocalCodeExecutor` | 无隔离，本地直接执行 | 即时 | ⚠️ 仅开发 |
| `ContainerCodeExecutor` | Docker 容器隔离 | 需 Docker 环境 | ✅ 生产 |
| `CubeCodeExecutor` | 远程 Cube/E2B 沙箱 | 远程 workspace | ✅ 生产 |

**配置沙箱**：

```python
from trpc_agent_sdk.code_executors import ContainerCodeExecutor

executor = ContainerCodeExecutor(
    timeout=30,                    # 超时 30 秒
    max_output_size=1_048_576,     # 输出上限 1MB
    env_whitelist=["PATH", "HOME"], # 环境变量白名单
)
```

**Skill + 沙箱的完整链路**：

```
Agent 决定使用 Skill
  → skill_load 加载规则文档到上下文
  → Filter 检查脚本是否安全（高风险模式？路径白名单？）
  → skill_run 在沙箱中执行脚本
  → 收集输出结果
  → 结果返回给 Agent 分析
```

详细文档：`docs/mkdocs/zh/code_executor.md`
示例：`examples/code_executors/`、`examples/skills/`

---

### 2.5 评测、优化与可观测性

#### 评测（Evaluation）

**为什么需要评测**？没有评测，你就不知道 Agent 改得好不好。

**评测体系**：

```
EvalSet（评测数据集）
  ├── EvalCase 1：输入"北京的天气" → 期望输出"北京..." → 期望调用工具 get_weather
  ├── EvalCase 2：输入"翻译成英文" → 期望输出翻译结果
  └── EvalCase 3：输入"..., ..., ..." → 期望输出"..., ..., ..."
      │
      ▼
AgentEvaluator（自动评测引擎）
  ├── 运行 Agent 处理每个 EvalCase
  ├── 对比实际输出 vs 期望输出
  └── 产出量化指标
```

**评测指标**：

| 指标 | 测量什么 | 说明 |
|------|---------|------|
| `tool_trajectory_avg_score` | 工具调用路径 | Agent 是否调用了正确的工具、顺序对不对 |
| `response_match_score` | 回答匹配度 | Agent 的回答是否和期望一致 |
| `LLM Judge` | LLM 评估 | 用另一个 LLM 来评估回答质量 |
| `Rubric` | 评分规则 | 按自定义规则打分（如"是否包含引用来源"） |

**运行评测**：

```python
from trpc_agent_sdk.evaluation import AgentEvaluator

await AgentEvaluator.evaluate(
    agent_module="my_agent",
    eval_dataset_file_path_or_dir="evals/my_evalset.json",
    print_detailed_results=True,
)
```

详细文档：`docs/mkdocs/zh/evaluation.md`
示例：`examples/evaluation/quickstart/`

#### 优化（Optimization）

**AgentOptimizer**：自动优化 Agent 的 Prompt。

工作流程：
```
① 定义评测集
② 运行评测 → 得到基线分数
③ AgentOptimizer 分析失败案例
④ 自动调整 Prompt
⑤ 再次运行评测 → 对比分数提升
⑥ 循环，直到分数达标
```

详细文档：`docs/mkdocs/zh/optimization.md`

#### 可观测性（Observability）

| 工具 | 监控什么 | 文档 |
|------|---------|------|
| **OpenTelemetry** | 链路追踪（每次 LLM 调用、工具执行的耗时和状态） | 内置 |
| **Langfuse** | LLM 调用监控、Token 用量、成本分析 | `docs/mkdocs/zh/openclaw.md` |
| **Filter Telemetry** | 拦截记录、耗时分析 | `docs/mkdocs/zh/filter.md` |
| **结构化日志** | 支持 JSON 格式，可接入 ELK 等日志系统 | 内置 |

---

## 三、实战篇

### 3.1 推荐学习路径

```
第一阶段：基础入门
  Quickstart → 跑通最小 Agent（1-2 小时）
  → FunctionTool → 封装第一个工具（1 小时）
  → Session → 理解会话管理（1 小时）

第二阶段：进阶能力
  Memory/Knowledge → 长期记忆和 RAG（2-3 小时）
  Multi-Agent/GraphAgent → 多 Agent 编排（2-3 小时）
  Skills/CodeExecutor → 沙箱执行（1-2 小时）
  Server/Protocols → 服务化部署（1-2 小时）

第三阶段：生产化
  Evaluation → 评测体系建设（1-2 小时）
  Observability → 监控和可观测性（1 小时）
  Optimization → Prompt 优化（1 小时）

第四阶段：综合实战
  选择一个项目，整合以上所有能力
```

### 3.2 实战项目建议

| 项目 | 难度 | 涉及技术 | 参考示例 |
|------|------|---------|---------|
| **工具型助手** | ⭐⭐ | FunctionTool + 多轮对话 | `examples/function_tools/` |
| **RAG 问答 Agent** | ⭐⭐⭐ | Knowledge + 向量检索 + 多轮对话 | `examples/knowledge_with_rag_agent/` |
| **自动代码审查** | ⭐⭐⭐⭐ | Skills + Sandbox + DB + Filter + Graph | `examples/skills_code_review_agent/` |
| **企业知识助手** | ⭐⭐⭐⭐⭐ | RAG + Memory + Graph + A2A + AG-UI | `examples/graph/` + `examples/a2a/` |
| **研发自动化助手** | ⭐⭐⭐⭐⭐ | Skills + CodeExecutor + MCP + Session | `examples/skills/` + `examples/code_executors/` |

### 3.3 学习成果验收

完成学习后，你应该能：

1. **解释清楚**一次 Agent 运行中：
   - 模型输入长什么样（instruction + tools + history）
   - 工具调用是怎么触发的（LLM → function_call → 执行 → 返回）
   - 状态是怎么变化的（Session state → Graph state）
   - 记忆是怎么召回的（load_memory_tool → 相似度检索）
   - 事件是怎么输出的（事件流 → 前端/日志）
   - 评测结果说明了什么（指标 → 改进方向）

2. **构建一个综合项目**，至少包含：
   - ✅ 多轮对话
   - ✅ 工具调用
   - ✅ 知识库检索（RAG）
   - ✅ 长期记忆
   - ✅ 任务拆解（GraphAgent/ChainAgent）
   - ✅ 流式事件输出
   - ✅ 运行日志
   - ✅ 评测集
   - ✅ 一种服务化协议（A2A / AG-UI / FastAPI）

3. **从"使用框架"进入"理解工程"**：
   - 知道为什么 Agent 这样设计，而不是怎么调 API
   - 知道什么场景该用 ChainAgent、什么场景该用 GraphAgent
   - 知道怎么评测、怎么优化、怎么监控

---

## 四、参考资源

### 4.1 文档索引

| 主题 | 中文文档 | 英文文档 |
|------|---------|---------|
| Agent 核心 | `docs/mkdocs/zh/llm_agent.md` | `docs/mkdocs/en/llm_agent.md` |
| 模型配置 | `docs/mkdocs/zh/model.md` | `docs/mkdocs/en/model.md` |
| 工具系统 | `docs/mkdocs/zh/tool.md` | `docs/mkdocs/en/tool.md` |
| 会话管理 | `docs/mkdocs/zh/session.md` | `docs/mkdocs/en/session.md` |
| SQL 会话 | `docs/mkdocs/zh/session_sql.md` | `docs/mkdocs/en/session_sql.md` |
| Redis 会话 | `docs/mkdocs/zh/session_redis.md` | `docs/mkdocs/en/session_redis.md` |
| 会话摘要 | `docs/mkdocs/zh/session_summary.md` | `docs/mkdocs/en/session_summary.md` |
| 长期记忆 | `docs/mkdocs/zh/memory.md` | `docs/mkdocs/en/memory.md` |
| 知识库总览 | `docs/mkdocs/zh/knowledge.md` | `docs/mkdocs/en/knowledge.md` |
| 文档加载器 | `docs/mkdocs/zh/knowledge_document_loader.md` | `docs/mkdocs/en/knowledge_document_loader.md` |
| 文本切分器 | `docs/mkdocs/zh/knowledge_text_splitter.md` | `docs/mkdocs/en/knowledge_text_splitter.md` |
| 向量化 | `docs/mkdocs/zh/knowledge_embedder.md` | `docs/mkdocs/en/knowledge_embedder.md` |
| 向量存储 | `docs/mkdocs/zh/knowledge_vectorstore.md` | `docs/mkdocs/en/knowledge_vectorstore.md` |
| 检索器 | `docs/mkdocs/zh/knowledge_retrievers.md` | `docs/mkdocs/en/knowledge_retrievers.md` |
| 提示词模板 | `docs/mkdocs/zh/knowledge_prompt_template.md` | `docs/mkdocs/en/knowledge_prompt_template.md` |
| 自定义组件 | `docs/mkdocs/zh/knowledge_custom_components.md` | `docs/mkdocs/en/knowledge_custom_components.md` |
| 图编排 | `docs/mkdocs/zh/graph.md` | `docs/mkdocs/en/graph.md` |
| LangGraph | `docs/mkdocs/zh/langgraph_agent.md` | `docs/mkdocs/en/langgraph_agent.md` |
| 多 Agent | `docs/mkdocs/zh/multi_agents.md` | `docs/mkdocs/en/multi_agents.md` |
| 团队协作 | `docs/mkdocs/zh/team.md` | `docs/mkdocs/en/team.md` |
| 子 Agent | `docs/mkdocs/zh/sub_agent.md` | `docs/mkdocs/en/sub_agent.md` |
| Skill | `docs/mkdocs/zh/skill.md` | `docs/mkdocs/en/skill.md` |
| 沙箱执行 | `docs/mkdocs/zh/code_executor.md` | `docs/mkdocs/en/code_executor.md` |
| Filter | `docs/mkdocs/zh/filter.md` | `docs/mkdocs/en/filter.md` |
| 评测 | `docs/mkdocs/zh/evaluation.md` | `docs/mkdocs/en/evaluation.md` |
| 优化 | `docs/mkdocs/zh/optimization.md` | `docs/mkdocs/en/optimization.md` |
| A2A | `docs/mkdocs/zh/a2a.md` | `docs/mkdocs/en/a2a.md` |
| AG-UI | `docs/mkdocs/zh/agui.md` | `docs/mkdocs/en/agui.md` |
| Human-in-the-loop | `docs/mkdocs/zh/human_in_the_loop.md` | `docs/mkdocs/en/human_in_the_loop.md` |
| Plan Mode | `docs/mkdocs/zh/plan.md` | `docs/mkdocs/en/plan.md` |
| 自定义 Agent | `docs/mkdocs/zh/custom_agent.md` | `docs/mkdocs/en/custom_agent.md` |
| 取消机制 | `docs/mkdocs/zh/cancel.md` | `docs/mkdocs/en/cancel.md` |

### 4.2 示例代码索引

| 示例 | 路径 | 学习内容 |
|------|------|---------|
| Quickstart | `examples/quickstart/` | 最小 Agent、Runner、Session |
| FunctionTool | `examples/function_tools/` | 工具封装、参数校验、错误处理 |
| Skills | `examples/skills/` | SKILL.md、skill_run、skill_load |
| CodeExecutor | `examples/code_executors/` | 容器/本地沙箱配置 |
| Session SQL | `examples/session_service_with_sql/` | SQLite 会话持久化 |
| Memory SQL | `examples/memory_service_with_sql/` | 长期记忆持久化 |
| RAG | `examples/knowledge_with_rag_agent/` | 文档加载、向量检索、RAG 问答 |
| A2A | `examples/a2a/` | Agent-to-Agent 协议、多轮对话 |
| AG-UI | `examples/agui/` | 前端事件流、实时交互 |
| FastAPI | `examples/fastapi_server/` | REST API 服务化部署 |
| 评测 | `examples/evaluation/quickstart/` | EvalSet、AgentEvaluator、评分 |
| Filter | `examples/filter_with_tool/` | 工具拦截、Filter 治理 |
| 流式工具 | `examples/llmagent_with_streaming_tool_simple/` | StreamingFunctionTool |
| 多 Agent 链 | `examples/multi_agent_chain/` | ChainAgent 顺序编排 |
| Graph | `examples/graph/` | 图编排、条件路由、状态管理 |
| Human-in-the-loop | `examples/llmagent_with_human_in_the_loop/` | 审批流程、中断恢复 |
| Plan Mode | `examples/plan_mode/` | 先计划后执行、读写门控 |
| MCP | `examples/mcp/` | MCP 工具集成 |
| ReviewMind | `examples/skills_code_review_agent/` | 综合项目：Skills + 沙箱 + 数据库 + Filter + 评测 + 服务化 |

---

*本文档基于 tRPC-Agent-Python 仓库中的文档和示例编写，旨在为学习者提供一条从基础到实践的完整学习路径。建议结合仓库中的 `docs/` 文档和 `examples/` 示例一起学习。*