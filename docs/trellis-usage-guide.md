# Trellis 使用教程

> 完整的 Trellis 安装、配置和使用指南

---

## 目录

1. [安装 Trellis](#安装-trellis)
2. [初始化项目](#初始化项目)
3. [配置语雀集成](#配置语雀集成)
4. [日常使用](#日常使用)
5. [常见问题](#常见问题)

---

## 安装 Trellis

### 从阿里云制品仓库安装（推荐）

```bash
npm install -g @ecochain/trellis
```

### 验证安装

```bash
trellis --version
# 应该显示: 0.3.7 或更高版本

tl --version  # tl 是 trellis 的简写
```

---

## 初始化项目

### 1. 进入项目目录

```bash
cd your-project
```

### 2. 初始化 Trellis

```bash
trellis init -u your-name --claude
```

**参数说明：**
- `-u your-name`: 你的开发者名称（用于 workspace 隔离）
- `--claude`: 为 Claude Code 生成配置文件

**执行后会创建：**
```
your-project/
├── .trellis/              # Trellis 工作目录
│   ├── .developer         # 开发者身份（gitignored）
│   ├── workflow.md        # 开发工作流程
│   ├── spec/              # 项目规范
│   │   ├── frontend/      # 前端开发规范
│   │   ├── backend/       # 后端开发规范
│   │   ├── guides/        # 思维指南
│   │   └── governance/    # 治理约束（自动同步）
│   ├── workspace/         # 开发者工作空间
│   │   └── your-name/     # 你的个人工作空间
│   ├── tasks/             # 任务跟踪
│   └── scripts/           # 工具脚本
├── .claude/               # Claude Code 配置
│   ├── hooks/             # 会话钩子
│   │   └── session-start.py  # 启动时自动同步 governance
│   └── commands/          # 自定义命令
└── .agents/               # AI Skills
    └── skills/            # 技能目录（自动同步）
```

### 3. 自动同步 Governance

初始化后，每次启动 Claude Code 会话时，`session-start.py` 会自动：
1. 从 `https://codeup.aliyun.com/.../ai-governance.git` 拉取最新约束
2. 同步 `spec/` 到 `.trellis/spec/governance/`
3. 同步 `skills/` 到 `.agents/skills/`

**无需手动配置**，开箱即用。

---

## 配置语雀集成

### 1. 获取语雀 Token

访问：https://www.yuque.com/settings/tokens

创建一个新的 Token，复制保存。

### 2. 配置 Token

编辑 `~/.claude/settings.json`（如果不存在则创建）：

```json
{
  "governance": {
    "yuqueToken": "your-yuque-token-here",
    "yuqueRepo": "https://www.yuque.com/your-org/your-repo",
    "yuqueCacheDir": "~/.cache/yuque"
  }
}
```

**参数说明：**
- `yuqueToken`: 你的个人 Token（⚠️ 不要共享或提交到 Git）
- `yuqueRepo`: 团队知识库 URL
- `yuqueCacheDir`: 本地缓存目录（可选，默认 `~/.cache/yuque`）

### 3. 同步语雀文档

在 Claude Code 中，直接告诉 AI：

```
同步语雀文档
```

或使用 skill 名称：

```
/ecochain:governance-sync-yuque
```

AI 会自动：
1. 检查 `yuque-dl` 是否安装（未安装则自动安装）
2. 读取你的配置
3. 执行同步：`yuque-dl <repo> -t <token> -d ~/.cache/yuque --incremental`
4. 报告同步结果

**首次同步可能需要几分钟**，后续使用 `--incremental` 只同步变更。

---

## 日常使用

### 启动开发会话

在 Claude Code 中执行：

```
/trellis:start
```

AI 会自动：
1. 读取 workflow.md 了解开发流程
2. 获取当前上下文（git 状态、任务列表等）
3. 读取项目规范（frontend/backend/guides）
4. 询问："What would you like to work on?"

### 开发任务流程

#### 简单任务（明确需求）

```
用户: "在用户列表页面添加搜索框"
AI: 确认理解 → 创建任务 → 写 PRD → 研究代码 → 实现 → 检查 → 完成
```

#### 复杂任务（需求不明确）

```
用户: "优化系统性能"
AI: 启动 brainstorm → 逐个提问澄清 → 更新 PRD → 确认 → 执行任务流程
```

### 语雀文档自动搜索

当你提出开发需求时，AI 会**自动搜索语雀文档**作为上下文：

```
用户: "实现 WES 拣货流程"

AI 自动执行：
1. 提取关键词：WES, 拣货
2. 搜索 ~/.cache/yuque/ 目录
3. 找到相关文档：
   - WES架构设计.md
   - 拣货流程说明.md
4. 读取并摘要呈现
5. 基于文档理解需求
6. 检查是否有 Intent 文档
7. 开始实现
```

**无需手动指定文档**，AI 会主动搜索。

### 完成工作

开发完成后：

```
/trellis:finish-work
```

AI 会执行 Pre-Commit 检查清单：
- ✓ 代码已提交
- ✓ Lint 通过
- ✓ 测试通过
- ✓ 工作区干净

### 记录会话

提交代码后：

```
/trellis:record-session
```

AI 会记录本次会话的工作内容到 journal 文件。

---

## 常见问题

### Q1: 如何更新 Trellis？

```bash
npm update -g @ecochain/trellis
```

### Q2: 如何更新 Governance 约束？

无需手动更新，每次启动 Claude Code 会话时自动同步最新版本。

如果需要强制更新：

```bash
rm -rf ~/.cache/trellis-governance
# 重启 Claude Code 会话
```

### Q3: 语雀 Token 过期怎么办？

1. 访问 https://www.yuque.com/settings/tokens
2. 重新生成 Token
3. 更新 `~/.claude/settings.json` 中的 `yuqueToken`
4. 重新同步：`同步语雀文档`

### Q4: 如何查看当前任务？

```bash
python3 ./.trellis/scripts/task.py list
```

或在 Claude Code 中：

```
/trellis:start
```

AI 会显示当前任务状态。

### Q5: 如何归档已完成的任务？

```bash
python3 ./.trellis/scripts/task.py archive <task-name>
```

### Q6: 多人协作如何避免冲突？

每个开发者有独立的：
- `.trellis/.developer` 文件（gitignored）
- `.trellis/workspace/<your-name>/` 目录
- Journal 文件

**共享的内容：**
- `.trellis/spec/` 规范文件
- `.trellis/tasks/` 任务目录
- `.trellis/workflow.md` 工作流程

### Q7: 如何自定义 Governance 约束？

Governance 约束存储在：
- 远程：https://codeup.aliyun.com/.../ai-governance.git
- 本地缓存：`~/.cache/trellis-governance/spec/`
- 项目：`.trellis/spec/governance/`

**修改流程：**
1. Clone ai-governance 仓库
2. 在 `develop` 分支修改 `spec/*.md`
3. 测试通过后合并到 `master`
4. 推送到远程
5. 团队成员重启会话自动同步

### Q8: yuque-dl 安装失败怎么办？

手动安装：

```bash
npm install -g yuque-dl
```

如果仍然失败，检查：
- Node.js 版本（需要 >= 18.17.0）
- npm 权限（可能需要 sudo）
- 网络连接

### Q9: 如何禁用 Governance 自动同步？

编辑 `.claude/hooks/session-start.py`，注释掉：

```python
# sync_governance_repo()  # 注释这行
```

**不推荐禁用**，除非你有特殊需求。

### Q10: 如何查看 AI 的决策日志？

Governance 约束要求 AI 输出结构化决策日志。查看 Claude Code 的输出即可看到：

```json
{
  "step_id": "step-001",
  "goal": "创建用户认证模块",
  "decision_summary": "使用JWT实现无状态认证",
  "tool_name": "write_file",
  "expected_result": "生成auth.ts文件"
}
```

---

## 相关链接

- **Trellis 仓库（阿里云）**: https://codeup.aliyun.com/.../Trellis.git
- **Trellis 仓库（GitHub）**: https://github.com/CoooderSan/Trellis
- **Governance 仓库（阿里云）**: https://codeup.aliyun.com/.../ai-governance.git
- **Governance 仓库（GitHub）**: https://github.com/CoooderSan/ai-governance
- **语雀 Token 管理**: https://www.yuque.com/settings/tokens

---

## 快速参考

### 常用命令

```bash
# 安装
npm install -g @ecochain/trellis

# 初始化
trellis init -u your-name --claude

# 查看任务
python3 ./.trellis/scripts/task.py list

# 获取上下文
python3 ./.trellis/scripts/get_context.py
```

### Claude Code Skills

```
/trellis:start                    # 开始会话
/trellis:finish-work              # 完成工作检查
/trellis:record-session           # 记录会话
/ecochain:governance-sync-yuque   # 同步语雀文档
```

### 配置文件

```
~/.claude/settings.json           # 语雀配置
.trellis/.developer               # 开发者身份
.trellis/workflow.md              # 工作流程
.trellis/spec/governance/         # 治理约束
```

---

## 总结

Trellis 提供了一套完整的 AI 辅助开发工作流：

1. **自动同步 Governance** - 团队约束自动注入
2. **语雀文档集成** - AI 主动搜索业务文档
3. **任务驱动开发** - 结构化的开发流程
4. **质量保证** - Pre-commit 检查和代码审查
5. **知识积累** - Journal 记录和 Spec 更新

开始使用：`trellis init -u your-name --claude`
