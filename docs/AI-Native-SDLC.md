# AI-Native SDLC

> **来源**：[The AI-Native SDLC playbook | Claude by Anthropic](https://claude.com/blog/the-ai-native-sdlc-playbook)
> **作者**：Louis Claxton（Anthropic Applied AI 团队）　**发布日期**：2026-08-21

---

## 0. 核心论点：Code is no longer the bottleneck

- Anthropic 内部约 **80% 的合入代码已由 Claude 完成**，工程师人均产出约为 2021–2025 年间的 **8 倍**。
- 代码变快之后，真正拖累收益的是**围绕代码的流程**：审批门、评审、交接、安全治理——它们仍以"人类速度"运行。
- 传统 SDLC 是为"写代码是最昂贵阶段"的时代设计的（PRD 仪式、估算会议、安全评审，本质都是在数周/数月的开发期里强制对齐）。当 Build 压缩到**数小时**后，三件事必然发生：
  1. **瓶颈转移**到 Build 两侧（Plan、Review/Test、Deploy 仍是人类速度）；
  2. **控制措施失效**——人工逐行评审跟不上 agent 产出的 diff；
  3. **治理成本上升**——例外仍要靠每周/每月的委员会。
- **AI-Native SDLC 的定义**：**保留旧的控制目标，换用新的执行方式**；流程从线性变为**循环（loop）**，AI 嵌入每个环节，实现自动化交接与触发（亦称 agentic SDLC / agentic software development）。

### 贯穿全文的机制：The Committed Artifact Chain（提交物链）

> "Every stage ends by writing one artifact to version control, and the next stage begins by reading it."

```
intent.md → spec.md → plan.md → diff + tests → PR / review findings → incident records
（意图）     （规格）    （计划）    （代码+测试）    （评审发现）        （事故记录）
```

- 每个阶段以**向版本控制写入一个 artifact** 结束，下一阶段从**读它**开始；artifact 被接受即自动触发下一阶段。
- 早期阶段用 `.md` 文件：product owner 与 agent 读的是**同一份文件**、执行同一份语义。
- **git 历史即审计线索**：谁提出需求、agent 产出了什么、谁批准的，全程可溯。
- 人类对所有需要判断力的决策保持问责（"Human judgement stays above the loop"）。

---

## 1. 六个阶段总览（传统 vs AI-Native）

| Stage              | 传统 SDLC                                 | AI-Native SDLC                                                                  |
| ------------------ | ----------------------------------------- | ------------------------------------------------------------------------------- |
| **Plan**     | 委员会收集需求，workshop + 签核，人工撰写 | Claude 从源头综合痛点，写成人类可读、机器可执行的`intent.md`                  |
| **Design**   | 分析师写 spec，设计师解析                 | 需求与设计压缩为一次 agent 会话，以 skills 形式编码的组织标准为约束，git 版本化 |
| **Build**    | 测试与代码手写，文档事后补                | 测试与代码由 AI 生成；机构知识维护为版本化的机器可读`CLAUDE.md` 与 skills     |
| **Test**     | 阶段边界上的 QA 门禁                      | 持续 evals 编织进实现过程                                                       |
| **Deploy**   | 人工逐行评审，治理依赖不一致的评审周期    | 多层 agentic review；人工评审保留给受监管与关键代码；hooks 作为审批门           |
| **Maintain** | 人类盯生产找 bug                          | Agent 监控线上部署，被突破的 control band 写回为新的`intent.md`               |

每个 Play（打法）模块化，包含：What changes / Getting started（Prerequisites + Infrastructure）/ 执行步骤 / Governance considerations / How to measure（leading + lagging 指标）。

---

## 2. Stage 1 — Plan：Capture as `intent.md`

**目标**：想法不再等人写下来；意图由发起人用自己的话一次性捕获为版本化 artifact。

- **AI 角色**：与发起人头脑风暴，主动提出分析师会问的问题（scope、用户、约束、成功标准），生成 proto-spec `intent.md`。
- **人的角色**：发起人用自然语言描述问题（无正式格式要求）、纠正 Claude 的误解；product owner 审核批准（accept/reject 记录为 merge 或关闭的 review）。
- **治理**：git 历史记录 author、timestamp 与全部修订。
- **指标**：
  - Leading——首次对话到 `intent.md` 提交的时间（从数周的 elicitation 降到数小时）；
  - Lagging——survival rate（被接受进入 Design 的比例）。

---

## 3. Stage 2 — Design：Requirements and Design

**目标**：需求与设计合并为一次会话；**政策在写 spec 时被应用**，而非几周后在评审中才发现。

- **AI 角色**：基于已接受的 `intent.md` 生成 requirements and design spec，受组织 skills（品牌、安全、合规、UX）约束，并**主动 flag 出关注点**（尤其无法同时满足的矛盾政策）。
- **人的角色**：product owner **审核但不撰写** spec；先逐个解决 flagged concerns（与对应 policy owner）；决定是否进入 Build——高风险时咨询技术负责人，**"A human teammate always makes this call"**。
- **产物**：`spec.md` 与 `intent.md` 成对提交。
- **指标**：
  - Leading——`intent.md` 到 `spec.md` 的 git 时间差；
  - Lagging——Build 开始后的需求返工（`plan.md` 首次提交后才出现的 `spec.md` commit 数）。

---

## 4. Stage 3 — Build

**目标**："Nothing is implemented without an accepted plan"；机构知识变成 agent 读取的文件，guardrails 以代码而非习惯运行。

### Play 1 — Plan mode as the default starting point

- **AI**：plan mode 下只读代码库，**工程师接受计划前不能编辑文件**；面试工程师、迭代计划；计划扎实后实施常是 single pass。
- **人**：提供 `intent.md` + `spec.md`，质询计划（会破坏什么、哪步最危险、放弃了哪些方案），迭代到**"没看过对话的工程师也能仅凭计划实现"**，批准后提交为 `plan.md`；实施偏离计划时在同一 commit 更新 `plan.md`（可用 hook 强制同步）。
- **治理原则**：设计评审**前移到代码生成之前**——此时改方向只是编辑文档。

### Play 2 — Auto mode

- 工程师批准计划后，Claude 无需逐次提示即可应用更改。当 guardrails 成熟（调优过的 `CLAUDE.md`、编码政策 skills、阻止危险操作的 hooks、可运行的测试套件），auto-accept 成为常规默认。
- 转变：从"盯着 agent 编辑"转向"**更长自治会话后审查 artifact**"；配合 git worktree 可并行，是自治 SDLC 的基础。

### Sidebar — Legacy systems and the source of truth

每个 artifact 指定**唯一 source of truth**，三选一：

1. repo 为准；
2. 遗留系统（Jira、ServiceNow）为准（Claude 经 MCP 读写）；
3. linkage 为最低标准（record ID + commit SHA 互链）。

避免两套真相。

### Play 3–5 — CLAUDE.md / Skills / Hooks（详见 §7）

### Play 6 — Parallel sessions and subagents

- **Parallel session**：独立 Claude Code 实例，各在独立 **git worktree**，互不知晓。
- **Subagent**：单会话内的 scoped helper，有独立 context window 与工具限制，适合重复任务（verifier、code simplifier、researcher）。
- **人的角色转变**：从执行者变为 orchestrator——拆分任务、驾驶多会话、评审产出；实用上限是"一个人能认真评审多少路流"（建议 2–3 路起步）。
- **治理**：控制来自 repo 配置（hooks、permission settings 作用于所有会话）；所有会话被记录并归因到运行的工程师。

---

## 5. Stage 4 — Test

**目标**：每个会话在人看到之前自检自查；**引导 agent 的配置本身也要像代码一样被回归测试**。

### Play 1 — Give Claude a feedback loop（验证闭环）

- **AI**：session 内自己跑测试/build/截图对比，自行修复直到通过，人才看到结果。
- **人**：搭建 loop——
  - 把验证包装成**单一命令**（`make test`，失败时非零退出）；
  - 在 `CLAUDE.md` 列出命令及**健康输出的示例**；
  - 给出**可量化目标**（"test_status.py 全部通过"、"截图与 mock 一致"、"endpoint 返回 200"）。
- **Bug fix 纪律**：先写失败测试（复现 bug、确认以预期原因失败、commit），再让 Claude 修复且**不得改测试**（test-file hook 强制）。
  > "A test that existed before the fix, and that the agent couldn't rewrite, is proof the bug is gone."
  >
- **UI 闭环**：browser/截图工具 + mock，迭代 2–3 轮。
- **保护 loop 本身**：修代码的 agent 不得削弱对该代码的检查——hook 禁改测试文件，或评审中拒绝触碰测试的 diff。
  > 口诀："If a test fails, fix the code, not the test."
  >
- **与 verifier subagent 的区别**：feedback loop 贯穿整个任务、随工作多次运行；verifier 是会话自认为完成后的**一次性终检**，用 **fresh context** 运行，避免结论被产生代码的那些假设污染。

### Play 2 — Continuous evals in CI

- Evals 是 **"the AI-native equivalent of stage-gate QA"**：每当 agent 的**配置**变更（换模型、改 prompt、改 `CLAUDE.md`/skills/hooks）时运行的回归套件。
  > "Configuration steers the agent and deserves the regression testing that code gets."
  >
- 做法：收集 20–50 个真实任务 + 验收标准 → CI 中非交互运行 → pass-rate 阈值作为 merge gate → **每个生产事故转化为一个永久 eval**（回归测试）。
- Evals 是 live suite：随模型进步淘汰失效 case、补充新 case。

---

## 6. Stage 5 — Deploy

**目标**："Review runs in both directions, and governance is enforced as the agent acts. The agent does everything up to the production gate and nothing past it."

### Play 1 — AI in the PR review loop

- **AI**：既给也收评审——对每个 PR 跑同一套 review pass，findings 按严重度排序；被 `@claude` 点名即响应评论并 push fix；可 babysit 自己开的 PR 直到 green。
- **人**：工程师上移一层——评审聚焦**意图与风险**；branch protection 仍要求 code owner 批准（**findings 本身不批准也不阻塞 PR**）。
- **`REVIEW.md`**：tech lead 编写的评审政策——
  - 三个 pass（Bugs / Security / Compliance，对照 `spec.md`、`plan.md` 与设计原则）；
  - Important 与 Nit 的定义（nit 上限 5 条）；
  - skip 清单（生成文件、CI 已强制项）。
- **反馈回路**：同一错误第二次被 flag → 修正写入 `CLAUDE.md`；review 还会标记 `CLAUDE.md` 是否过时；每月由 tech lead 调优。
- **治理核心**：separation of duties——**"the agent that wrote the code has no way to approve it"**；PR 历史即审计记录。

### Play 2 — Hooks as approval gates

- Hook 可 **allow / ask / block**；`ask` 即暂停等待特定人批准——用于 release gate。
- 步骤：领导层与 change management/compliance 列出必须保留的人工审批门 → 每个门表达为 hook 脚本 → 团队 hooks 放 `.claude/settings.json`（入 git）；不可协商的放 **managed settings**（工程师无法关闭）→ `block` 必须自我解释（原因 + 批准路径）。
- **Worked example（受监管企业的 managed settings）**：deny 读取 `.env`/secrets/WebFetch/curl；sandbox 域名 allowlist + 凭证 deny + `failIfUnavailable`；`allowManagedHooksOnly`、`disableSideloadFlags`、`strictKnownMarketplaces`、`allowManagedMcpServersOnly`、`requiredMinimumVersion`。
  > "Every deny trades against capability"——是定制起点而非照抄模板。
  >

### Play 3 — CI/CD integration and deployment

- **渐进路径**：从只读 judgment 步骤起步（`claude -p` triage 失败的 build、总结 flaky test、草拟 changelog）→ 写步骤全部经现有 gate（**一切以 PR 形式到达，没有 push to main 的路径**）→ 沙箱执行（容器、网络策略、短时 scoped tokens、默认无生产凭证）→ 经 MCP 暴露 deploy/status/rollback 为按环境 scope 的工具（**"an allowlist rather than a shell script with credentials"**）。
- **按环境分级自治**：dev 自由部署；production 由 agent 准备 + release manager 授权 + hook 强制门。
- **Rollback 是排练最多的路径**。
- **治理**：非交互运行以 agent 自己的身份；pipeline log 区分 agent 与触发工程师的动作；指标包括 DORA。

---

## 7. Stage 6 — Maintain

**目标**：loop 闭合——"A trigger invokes Claude with no person in the invocation path, and what it finds re-enters the pipeline as `intent.md`." 此阶段开始 headless 运行，阶段间由独立 confidence gate（确定性检查或 adversarial reviewing agent）决定继续还是升级给人。

### Play 1 — Closing the loop

- **确定性脚本监控 control band**（rolling window 统计 + Western Electric rules，**检测完全无模型参与**）；`bands.yaml` 版本化定义响应分级：
  - **1σ** 仅记录；
  - **2σ** 调 Claude 只读诊断；
  - **3σ** Claude 可行动（仅限开 PR 进 review gate，或触发预批准 runbook）。
- Claude 无状态运行（CI 非交互步骤或 Agent SDK 服务），把诊断写成 Stage 1 格式的 `intent.md`，进入正常 pipeline。
- **人**：service owner / on-call triage 队列（fix now / schedule / dismiss；dismissal 反过来调优 bands 降噪）。
- 示例：CI 测试失败率破 3σ → 隔离 flaky test 或开 revert PR；post-deploy 5xx 破 3σ 且窗口内有部署 → 触发现有 rollback pipeline。

### Play 2 — Recurring codebase scans（Claude Security）

- 理念：安全扫描是 **"point-in-time statement"**——代码和模型都会过时，因此定时扫描、无人触发、findings 走与其他变更相同的 gate。
- 单 PR 可修的经 Claude Code on the Web 审查后走 review gate；更大的写成 `intent.md`。
- > "Coverage is dated from the last run, not from the first."
  >
- 确定性检查留在 CI；模型扫描补充那些检查覆盖不到的 context-dependent 漏洞。

### Play 3 — Claude on call（Claude Tag）

- Claude 以自己的身份成为 Slack/Teams 频道成员，每个 incident 即刻有 first responder；任何人可在频道中引导响应、测试假设。
- > **"The channel is the audit trail"**——请求、诊断、人类授权、修复都留在 incident 处理处。
  >
- 经 MCP 验证指标回归基线；post-mortem 写入版本化 lessons 文件；小修走 PR gate，大改写成 `intent.md`——**"the loop starts feeding itself"**。

---

## 8. 文档、Spec 与知识管理最佳实践

1. **Artifact 链即单一事实来源**：`intent.md` / `spec.md` / `plan.md` / diff+tests / PR findings / incident records，全部版本控制；**git 链即 audit trail**。
2. **CLAUDE.md**：给 Claude "新成员 day one 所需的 context"（命令、约定、架构、常见错误）。
   - `/init` 生成 → 裁剪 → 入 repo 根目录随代码 review；
   - **"When Claude makes a mistake twice, the correction goes into `CLAUDE.md`"**；
   - 保持在一页以内（agent 每次会话读全文，stale 内容白白占用 context）。
3. **Skills**：让机构知识可运营化。
   - 判断规则："write a skill for institutional knowledge that must be applied consistently; don't write a skill for components that belong in `CLAUDE.md` or a prompt."
   - 结构：`SKILL.md`（frontmatter 定义触发时机，body 定义要做什么），放 `.claude/skills/<name>/` 随代码分发，或经 plugin 组织级分发；
   - 政策变更由 policy owner 签核，工程师下次会话自动生效。
4. **控制强度分层**：
   - Skill 是 **advisory control**（让违规罕见）；
   - 必须无条件成立的政策需要确定性层——**"The skill makes violations rare and the hook makes them close to impossible."**
5. **遗留系统整合**：每个 artifact 只认一个 source of truth（repo / 遗留系统 / linkage），避免两套真相。

---

## 9. 测试、验证与代码评审要点（速查）

- **自验证优先**：每个会话先通过自己的 feedback loop，人只看通过的结果；loop 需要被保护（agent 不可改测试）。
- **失败测试先行**的 bug fix 纪律；验证是 "done" 的一部分（运行并粘贴输出）。
- **Evals 守护配置**：`CLAUDE.md`/skills/hooks 的变更像代码一样被 CI 回归测试，阈值作为 merge gate；事故 → 永久 eval。
- **双向 PR review**：Claude 评审所有 PR（一致的标准、按严重度排序）+ 自动响应评审意见；人保留 code owner 批准权，聚焦意图与风险；`REVIEW.md` 统一评审标准并限制 nit 噪音。
- **Separation of duties**：写代码的 agent 无法批准代码；批准永远来自人（branch protection）。
- **评审发现反哺 `CLAUDE.md`**，形成学习回路。

---

## 10. 其他关键原则（速查）

1. **渐进自治路径**：手动 prompt 每一步 → codify 为 slash command → 最终 artifact 接受即自动触发下一 gate。
   > "Human attention concentrates at the gates, reviewing what the agent flagged rather than starting each stage from scratch."
   >
2. **Plan mode**：设计评审前移到代码生成之前；计划的检验标准是"局外人可仅凭计划实施"。
3. **Context 管理**：CLAUDE.md 精简（全文被读入）；subagent 承接重复/探索性工作；verifier 用 fresh context 保证结论无偏。
4. **确定性 vs 概率性控制**：检测保持确定性（统计规则，无模型）；模型只在被触发后行动且行动受 tier 限制；hook（确定性）兜底 skill（建议性）。
5. **Agent 身份与归因**：非交互运行以 agent 自己的身份执行，一切动作 logged、attributed、经 OpenTelemetry 导出。
6. **分级授权**：按环境（dev/staging/production）与响应等级（1σ/2σ/3σ）渐进放权；production gate 绝不可被 agent 越过。
7. **采用顺序与依赖**：plays 有依赖图（CI/CD 加速前必须先有 gates；feedback loop 减少 parallel sessions 的监督需求），按需分阶段转型。
8. **人机分工**：AI 负责生成、诊断、执行；人类保留在意图判断、政策裁决、风险接受与最终批准上。

> 结语：**"The loop keeps running. Human judgement stays above it."**
