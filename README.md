# Governance (组织级工程治理文档库)

> 目的：作为组织的**单一事实来源（SSoT）**，通过**提示词工程**实现软约束治理，确保团队使用 Claude Code 时遵循统一的流程和规范。

---

## 🎯 核心理念

**不做额外工程开发，通过 Prompt + Skills 实现治理约束**

类似"阿里巴巴代码规范"的软约束方式，让 Claude Code 自动遵循：
- ✅ 结构化决策日志
- ✅ 工具调用追踪
- ✅ 人工确认闸门
- ✅ 代码质量要求
- ✅ 可解释性约束
- ✅ 成本配额控制

---

## 📁 目录结构

```
/ai-governance
    prompts/
        governance-master.md      # 核心治理约束（6大方向）
        claude-code-config.json   # Skills配置文件
        planner.md                # 规划者角色提示词
        executor.md               # 执行者角色提示词
        reviewer.md               # 审查者角色提示词
        tester.md                 # 测试者角色提示词
    templates/
        intent.md                 # 需求描述模板
        change-proposal.md        # 变更提案模板
        pr-description.md         # PR描述模板
    policy/
        blacklist.yml             # 黑名单（禁止操作）
        whitelist.yml             # 白名单（允许操作）
        quotas.yml                # 配额限制
        risk-matrix.md            # 风险评估矩阵
        agent.rego                # OPA策略规则
    examples/
        example-usage.md          # 使用示例
    docs/
        [治理相关文档]
```

---

## 🚀 快速开始

### 推荐方式：使用 Trellis（自动集成）

**完整教程**: [Trellis 使用教程](./docs/trellis-usage-guide.md)

```bash
# 1. 安装 Trellis
npm install -g @ecochain/trellis

# 2. 初始化项目
cd your-project
trellis init -u your-name --claude

# 3. 启动 Claude Code
# Governance 约束和 Skills 会自动同步并注入
```

**自动同步机制**：
- 每次启动 Claude Code 会话时，自动从本仓库同步最新的 `spec/` 和 `skills/`
- 无需手动配置，开箱即用
- 支持语雀文档集成（详见使用教程）

---

### 方式二：直接复制 Prompt（临时使用）

1. 打开 `prompts/governance-master.md`
2. 复制全部内容
3. 在 Claude Code 中输入：
   ```
   请严格遵循以下治理约束：
   
   [粘贴内容]
   
   现在开始我的任务：[你的需求]
   ```

### 方式三：配置 Skills（手动集成）

1. 安装 Skill：
   ```bash
   cd ../skills/packages/agent-governance-bootstrap
   npm install
   npm run build
   ```

2. 配置环境变量：
   ```bash
   export GOVERNANCE_REPO_URL="https://github.com/your-org/ai-governance.git"
   export GOVERNANCE_CACHE_DIR="$HOME/.claude/agent-governance"
   ```

3. 在 Claude Code 中启用 Skill（自动加载治理约束）

详细步骤见：[QUICK_START.md](../QUICK_START.md)

---

## 📋 六大治理约束

### 1️⃣ 结构化决策日志
每一步输出 JSON 格式的决策记录：
```json
{
  "step_id": "step-001",
  "goal": "创建用户认证模块",
  "decision_summary": "使用JWT实现无状态认证",
  "tool_name": "write_file",
  "expected_result": "生成auth.ts文件"
}
```

### 2️⃣ 事件流与工具调用追踪
每次工具调用前记录元数据：
```json
{
  "event_type": "tool_call",
  "tool": "edit_file",
  "reason": "实现JWT验证逻辑",
  "risk_level": "low"
}
```

### 3️⃣ 人类在环（HITL）
高风险操作自动暂停，请求确认：
- 写入/修改文件（>100行）
- 删除文件/目录
- 调用外部API
- 执行系统命令

### 4️⃣ 代码与工件治理
强制要求：
- ✅ 代码注释
- ✅ 单元测试
- ✅ PR 描述
- ✅ Git 工作流

### 5️⃣ 可解释性约束
关键决策必须：
- 提供 2-3 个备选方案
- 说明选择理由
- 使用结构化格式

### 6️⃣ 成本与配额控制
自动监控：
- 最大步数：20
- 最大时长：10分钟
- 最大工具调用：50次

---

## 🚫 黑名单（严格禁止）

### 命令黑名单
- `DROP TABLE`
- `kubectl delete`
- `rm -rf /`
- `chmod 777`
- `eval()`

### 路径黑名单
- `/etc/passwd`
- `/var/lib/kubelet`
- `node_modules/`
- `.git/`

详见：[policy/blacklist.yml](./policy/blacklist.yml)

---

## ✅ 白名单（允许操作）

### 允许的目录
- `/src/*`
- `/test/*`
- `/docs/*`

### 允许的工具
- `read_file`
- `write_file`（需确认）
- `edit_file`（需确认）
- `run_command`（需确认）

详见：[policy/whitelist.yml](./policy/whitelist.yml)

---

## 🔧 维护指南

### 组织维护者

1. **更新治理约束**：修改 `prompts/governance-master.md`
2. **调整配额策略**：修改 `policy/quotas.yml`
3. **维护黑白名单**：修改 `policy/blacklist.yml` 和 `whitelist.yml`
4. **更新模板**：修改 `templates/` 下的文件

修改后，下次会话或缓存过期后自动生效。

### 开发者

1. **遵循治理约束**：每次使用 Claude Code 前加载约束
2. **响应人工确认**：高风险操作时及时确认
3. **反馈问题**：发现约束不合理时及时反馈

---

## 📚 相关文档

- **[Trellis 使用教程](./docs/trellis-usage-guide.md)** - 完整的安装、配置和使用指南 ⭐
- [Trellis + Governance 集成指南](./docs/trellis-governance-guide.md) - Governance 自动同步机制
- [使用示例](./examples/example-usage.md) - 实际场景示例
- [治理约束完整文档](./prompts/governance-master.md) - 完整约束说明

---

## 🔄 与 Skills 的关系

Skills 仓库中的 `agent-governance-bootstrap` 会：
1. 读取环境变量 `GOVERNANCE_REPO_URL`（可选）
2. 远程拉取本仓库的模板/Prompt/策略
3. 自动注入到 Claude Code 的系统提示中
4. 在运行时执行策略拦截和审计

---

## 📊 版本历史

- **v1.2.0** (2026-03-06)
  - ✅ 整合到单一仓库（master + develop 分支）
  - ✅ 添加 Skills（governance-init, governance-sync-yuque, governance-update）
  - ✅ 添加语雀知识库集成规范
  - ✅ 完整的 Trellis 使用教程
  - ✅ 自动同步机制（session-start hook）

- **v1.0.0** (2026-01-22)
  - ✅ 完整的6大治理约束
  - ✅ 基于Prompt工程的软约束实现
  - ✅ Skills自动加载支持
  - ✅ 黑白名单和配额控制
  - ✅ 完整的使用文档和示例

---

**维护者**：组织治理团队
**更新时间**：2026-03-06
**当前版本**：v1.2.0