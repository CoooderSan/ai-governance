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
trellis init -u your-name
```

**参数说明：**
- `-u your-name`: 你的开发者名称（用于 workspace 隔离）

**可选参数（根据你使用的 AI 工具选择）：**
- `--claude`: 为 Claude Code 生成配置文件
- `--cursor`: 为 Cursor 生成配置文件
- `--codex`: 为 Codex 生成配置文件
- `--iflow`: 为 iFlow CLI 生成配置文件
- 更多选项见 `trellis init --help`

**示例：**
```bash
# Claude Code 用户
trellis init -u your-name --claude

# Cursor 用户
trellis init -u your-name --cursor

# 同时使用多个工具
trellis init -u your-name --claude --cursor
```

**交互式配置过程：**

在初始化过程中，会询问是否配置 governance 仓库：

```
? Configure governance repository for team constraints? (y/N)
```

- 选择 `y`：输入 governance 仓库地址（默认：团队仓库地址）
- 选择 `N` 或直接回车：跳过配置（不使用 governance）

**注意**：使用 `-y` 参数（`trellis init -u your-name -y`）会跳过所有交互，不配置 governance。

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

### 3. Governance 配置说明

**什么是 Governance？**

Governance 是团队级的 AI 治理约束，包括：
- Intent 文档门控
- 决策日志要求
- 人类在环确认
- 代码质量标准
- 语雀知识库集成

**配置方式：**

1. **在 `trellis init` 时配置（推荐）**

   初始化时会询问是否配置 governance 仓库，输入仓库地址即可。

2. **手动配置**

   创建配置文件：
   ```bash
   echo "https://your-governance-repo.git" > .trellis/.governance-repo
   ```

3. **验证配置**

   ```bash
   cat .trellis/.governance-repo
   ```

**自动同步机制：**

配置后，每次启动 Claude Code 会话时，`session-start.py` 会自动：
1. 读取 `.trellis/.governance-repo` 中的仓库地址
2. 从该仓库拉取最新约束
3. 同步 `spec/` 到 `.trellis/spec/governance/`
4. 同步 `skills/` 到 `.agents/skills/`

**无需手动同步**，开箱即用。

---

## 配置语雀集成

### 1. 获取语雀 Token

**方法：通过浏览器 Cookie 获取**

1. 登录语雀（https://www.yuque.com）

2. 打开浏览器开发者工具：
   - Windows/Linux: 按 `F12`
   - Mac: 按 `Option + Command + J`

3. 切换到 **Application** 标签页（Chrome/Edge）或 **存储** 标签页（Firefox）

4. 在左侧边栏展开 **Cookies**，选择 `https://www.yuque.com`

5. 找到名为 `_yuque_session` 的 Cookie，复制其 **Value** 值

   ```
   示例：
   Name: _yuque_session
   Value: abcd1234efgh5678...（这就是你的 token）
   ```

⚠️ **重要安全提示**：
- Cookie 包含你的个人登录信息，**切勿泄露给他人**
- 不要将 token 提交到 Git 仓库
- 定期更换 token（重新登录后会变化）

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
- `yuqueToken`: 你的 `_yuque_session` Cookie 值（⚠️ 不要共享或提交到 Git）
- `yuqueRepo`: 团队知识库 URL
- `yuqueCacheDir`: 本地缓存目录（可选，默认 `~/.cache/yuque`）

**注意**：
- 使用 Cookie 方式获取的 token（`_yuque_session`），不是语雀设置页面的 API Token
- Cookie token 会在重新登录后变化，需要重新获取

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

### Q1: 如何更新 Governance 约束？

**约束存储位置：**
- **远程仓库（源）**: https://codeup.aliyun.com/.../ai-governance.git
- **本地缓存**: `~/.cache/trellis-governance/`
- **项目目录**: `.trellis/spec/governance/`

**更新流程：**

1. **Clone governance 仓库**（首次）：
   ```bash
   cd ~/projects
   git clone https://codeup.aliyun.com/63b637070a96c30780aae039/ecochain/ai-governance/ai-governance.git
   cd ai-governance
   ```

2. **切换到 develop 分支**：
   ```bash
   git checkout develop
   ```

3. **修改约束文件**：
   ```bash
   # 编辑 spec 目录下的约束文件
   vim spec/intent-gate.md
   vim spec/yuque-knowledge-base.md
   # 或添加新的约束文件
   ```

4. **提交更改**：
   ```bash
   git add spec/
   git commit -m "feat: update governance constraints"
   ```

5. **合并到 master 分支**：
   ```bash
   git checkout master
   git merge develop --no-ff -m "Merge develop: update constraints"
   ```

6. **推送到远程**：
   ```bash
   git push origin master
   git push origin develop
   ```

7. **团队成员自动同步**：
   - 重启 Claude Code 会话，session-start hook 会自动拉取最新版本
   - 或手动强制更新：`rm -rf ~/.cache/trellis-governance`

**分支策略：**
- `master`: 稳定版本（session-start 同步此分支）
- `develop`: 开发版本
- `feature/*`: 功能分支

### Q2: 如何更新 Trellis？

```bash
npm update -g @ecochain/trellis
```

### Q2: 如何更新 Trellis？

```bash
npm update -g @ecochain/trellis
```

### Q3: 如何配置自定义的 Governance 仓库？

**方式一：在 init 时配置（推荐）**

```bash
trellis init -u your-name --claude
# 询问时选择 y，然后输入你的仓库地址
```

**方式二：手动修改配置文件**

```bash
echo "https://your-custom-governance-repo.git" > .trellis/.governance-repo
```

**验证配置：**

```bash
cat .trellis/.governance-repo
```

### Q4: 如何更新 Governance 约束？

无需手动更新，每次启动 Claude Code 会话时自动同步最新版本。

如果需要强制更新：

```bash
rm -rf ~/.cache/trellis-governance
# 重启 Claude Code 会话
```

### Q5: 如何禁用 Governance 自动同步？

删除配置文件：

```bash
rm .trellis/.governance-repo
```

或者将配置文件内容清空：

```bash
echo "" > .trellis/.governance-repo
```

重启 Claude Code 会话后，将不再同步 governance。

### Q6: 语雀 Token 过期怎么办？

语雀 Cookie token（`_yuque_session`）会在以下情况失效：
- 重新登录语雀
- Cookie 过期
- 清除浏览器缓存

**解决方法：**
1. 重新登录语雀
2. 按照上面的步骤重新获取 `_yuque_session` Cookie
3. 更新 `~/.claude/settings.json` 中的 `yuqueToken`
4. 重新同步：`同步语雀文档`

### Q7: 如何查看当前任务？

```bash
python3 ./.trellis/scripts/task.py list
```

或在 Claude Code 中：

```
/trellis:start
```

AI 会显示当前任务状态。

### Q8: 如何归档已完成的任务？

```bash
python3 ./.trellis/scripts/task.py archive <task-name>
```

### Q9: 多人协作如何避免冲突？

每个开发者有独立的：
- `.trellis/.developer` 文件（gitignored）
- `.trellis/workspace/<your-name>/` 目录
- Journal 文件

**共享的内容：**
- `.trellis/spec/` 规范文件
- `.trellis/tasks/` 任务目录
- `.trellis/workflow.md` 工作流程

### Q10: 如何更新 Skills？

Skills 也存储在 ai-governance 仓库的 `skills/` 目录中，更新流程与约束相同：

1. 在 ai-governance 仓库的 `develop` 分支修改 `skills/` 目录
2. 提交并合并到 `master`
3. 推送到远程
4. 团队成员重启会话自动同步

### Q11: yuque-dl 安装失败怎么办？

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

### Q12: 如何查看 AI 的决策日志？

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
