# Trellis + Governance 使用指南

## 这是什么

通过 Fork 版 Trellis 的 `--governance-repo` 参数，团队可以在初始化项目时自动拉取组织级治理约束，注入到 `.trellis/spec/governance/`，让 Claude Code 每次会话都自动遵循统一规范。

---

## 工作原理

```
trellis init --governance-repo <url>
        │
        ▼
git clone <url> → ~/.cache/trellis-governance/
        │
        ▼
复制 spec/ → .trellis/spec/governance/
        │
        ▼
session-start.py 启动时读取 governance/*.md
        │
        ▼
治理约束注入到 Claude Code 上下文（<guidelines> 段）
```

**两个触发时机：**

| 时机 | 触发方式 | 说明 |
|------|---------|------|
| 项目初始化 | `trellis init --governance-repo <url>` | 一次性拉取，写入项目 |
| 每次会话启动 | `TRELLIS_GOVERNANCE_REPO` 环境变量 | 自动 pull 最新版本 |

---

## 快速开始

### 第一步：安装 Fork 版 Trellis

```bash
npm install -g @your-org/trellis
# 或直接从私服安装
npm install -g https://codeup.aliyun.com/...
```

### 第二步：初始化项目

```bash
cd your-project
trellis init -u your-name --claude \
  --governance-repo https://codeup.aliyun.com/63b637070a96c30780aae039/ecochain/ai-governance/develop-governance.git
```

执行后，`.trellis/spec/governance/` 下会出现：

```
.trellis/spec/governance/
├── intent-gate.md       # Intent 文档门控
├── audit-log.md         # 决策日志 + 工具追踪
├── hitl.md              # 人类在环确认
├── access-control.md    # 黑白名单
├── quotas.md            # 成本配额控制
├── cost-estimation.md   # Change Proposal 成本估算
└── code-governance.md   # 代码与 PR 治理
```

### 第三步：配置自动同步（推荐）

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
export TRELLIS_GOVERNANCE_REPO=https://codeup.aliyun.com/63b637070a96c30780aae039/ecochain/ai-governance/develop-governance.git
```

之后每次启动 Claude Code 会话，`session-start.py` 会自动 `git pull` 最新约束并注入上下文。

---

## 治理约束说明

### Intent 门控（intent-gate.md）
收到开发需求时，必须先检查 `docs/intents/` 下是否有对应 Intent 文档，没有则拒绝执行。

### 决策日志（audit-log.md）
每步执行前输出 JSON 格式决策记录，工具调用前记录原因和风险等级。

### 人类在环（hitl.md）
删除文件、执行系统命令、修改配置文件等高风险操作，必须暂停等待人工确认。

### 访问控制（access-control.md）
禁止 `DROP TABLE`、`rm -rf /`、直连生产数据库等危险操作。

### 配额控制（quotas.md）
最大 20 步、10 分钟、50 次工具调用，达到阈值自动暂停。

### 成本估算（cost-estimation.md）
每个 Change Proposal 必须包含 AI 工时 + 人工工时 + 成本对比。

### 代码治理（code-governance.md）
代码必须附注释，先生成 PR 描述再写代码，禁止跳过测试。

---

## 更新治理约束

修改 `develop-governance` 仓库的 `spec/*.md` 文件后：

- **已配置环境变量的开发者**：重启 Claude Code 会话自动生效
- **未配置环境变量的开发者**：重新执行 `trellis init --governance-repo <url>`

---

## Governance Repo 结构要求

```
your-governance-repo/
└── spec/          ← 必须在根目录
    ├── *.md       ← 每个文件对应一类约束
    └── ...
```

---

## 相关仓库

| 仓库 | 地址 | 说明 |
|------|------|------|
| Trellis Fork | `codeup.aliyun.com/.../Trellis.git` | 添加了 `--governance-repo` 支持 |
| Governance Spec | `codeup.aliyun.com/.../develop-governance.git` | 治理约束 spec 文件 |
