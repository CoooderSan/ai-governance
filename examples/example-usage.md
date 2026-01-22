# 治理约束使用示例

> 本文档提供实际场景下的治理约束使用示例

---

## 示例1：创建RESTful API端点

### 用户输入
```
创建一个用户管理API，支持CRUD操作
```

### Claude 自动输出（遵循治理约束）

#### Step 1: 决策日志
```json
{
  "step_id": "step-001",
  "goal": "分析需求，设计API结构",
  "decision_summary": "使用Express Router，遵循RESTful规范",
  "tool_name": "read_file",
  "expected_result": "读取现有路由配置，确定集成点"
}
```

#### Step 2: 工具调用追踪
```json
{
  "event_type": "tool_call",
  "timestamp": "2026-01-22T14:30:00Z",
  "tool": "read_file",
  "input": {
    "file_path": "/src/routes/index.ts"
  },
  "reason": "了解现有路由结构，避免冲突",
  "risk_level": "low"
}
```

#### Step 3: 方案对比（可解释性）
```markdown
### 决策点：选择数据验证方案

**目标**：确保API输入数据的有效性

**备选方案**：
| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| Joi | 功能强大，文档完善 | 包体积较大 | ⭐⭐⭐ |
| Zod | TypeScript原生，类型安全 | 学习曲线 | ⭐⭐⭐⭐⭐ |
| class-validator | 装饰器语法，优雅 | 依赖reflect-metadata | ⭐⭐⭐ |

**最终选择**：Zod
**理由**：项目使用TypeScript，Zod提供最佳类型推导
```

#### Step 4: PR描述
```markdown
## 变更摘要
新增用户管理API，支持CRUD操作

## 变更内容
- [x] 新增 /src/routes/users.ts（路由定义）
- [x] 新增 /src/controllers/userController.ts（业务逻辑）
- [x] 新增 /src/validators/userSchema.ts（数据验证）
- [x] 新增 /test/routes/users.test.ts（API测试）

## 测试覆盖
- [x] GET /api/users - 获取用户列表
- [x] GET /api/users/:id - 获取单个用户
- [x] POST /api/users - 创建用户
- [x] PUT /api/users/:id - 更新用户
- [x] DELETE /api/users/:id - 删除用户
- [x] 输入验证测试（无效数据拒绝）

## 风险评估
- 影响范围：新增模块，不影响现有功能
- 风险等级：低
- 回滚方案：删除新增文件，移除路由注册
```

#### Step 5: 代码输出（带注释和测试）
```typescript
// src/routes/users.ts
import { Router } from 'express';
import { userController } from '../controllers/userController';
import { validateUser } from '../validators/userSchema';

const router = Router();

// 获取所有用户
router.get('/', userController.getAll);

// 获取单个用户
router.get('/:id', userController.getById);

// 创建用户（需验证）
router.post('/', validateUser, userController.create);

// 更新用户（需验证）
router.put('/:id', validateUser, userController.update);

// 删除用户
router.delete('/:id', userController.delete);

export default router;
```

```typescript
// test/routes/users.test.ts
import request from 'supertest';
import app from '../src/app';

describe('User API', () => {
  test('GET /api/users 应返回用户列表', async () => {
    const res = await request(app).get('/api/users');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  test('POST /api/users 应创建新用户', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ name: 'Test User', email: 'test@example.com' });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
  });

  test('POST /api/users 应拒绝无效数据', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ name: '' }); // 缺少email
    expect(res.status).toBe(400);
  });
});
```

---

## 示例2：重构遗留代码（触发人工确认）

### 用户输入
```
重构 /src/legacy/oldAuth.ts，使用新的认证系统
```

### Claude 自动输出

#### Step 1: 依赖分析
```json
{
  "step_id": "step-001",
  "goal": "分析oldAuth.ts的依赖关系",
  "decision_summary": "检查哪些模块依赖此文件",
  "tool_name": "grep_search",
  "expected_result": "找到所有import oldAuth的文件"
}
```

#### Step 2: 风险评估
```markdown
### 风险分析

**影响范围**：
- `/src/api/login.ts` - 使用 oldAuth.login()
- `/src/api/register.ts` - 使用 oldAuth.register()
- `/src/middleware/auth.ts` - 使用 oldAuth.verify()

**风险等级**：高
**原因**：核心认证逻辑，影响所有需要登录的功能

**建议方案**：
1. 先创建新认证模块（不影响现有代码）
2. 逐步迁移依赖模块
3. 最后删除旧代码
```

#### Step 3: 人工确认闸门
```
⚠️ 需要人工确认

操作类型：重构核心模块
目标：/src/legacy/oldAuth.ts（被 3 个模块依赖）
风险评估：高（认证系统，影响所有用户功能）

建议执行计划：
1. 创建 /src/auth/newAuth.ts（新认证模块）
2. 添加兼容层 /src/auth/adapter.ts
3. 逐步迁移 login.ts, register.ts, middleware/auth.ts
4. 完成迁移后删除 oldAuth.ts

预计步数：15 步
预计时长：8 分钟

请输入：
- "继续" - 执行完整重构
- "拒绝" - 取消操作
- "修改" - 仅创建新模块，暂不迁移
```

### 用户响应
```
修改
```

#### Step 4: 调整执行计划
```json
{
  "step_id": "step-002",
  "goal": "仅创建新认证模块，保留旧代码",
  "decision_summary": "降低风险，分阶段迁移",
  "tool_name": "write_file",
  "expected_result": "创建newAuth.ts，与旧系统并存"
}
```

---

## 示例3：配额控制触发

### 用户输入
```
为整个项目添加错误处理和日志记录
```

### Claude 自动输出

#### Step 5: 配额报告
```
📊 配额使用情况（Step 5）

当前步数：5 / 20
运行时长：2分15秒 / 10分钟
工具调用：18 / 50

状态：正常 ✅

已完成：
- [x] 分析项目结构
- [x] 创建日志工具类
- [x] 为 /src/api/ 添加错误处理
- [x] 为 /src/services/ 添加错误处理
- [ ] 为 /src/utils/ 添加错误处理（进行中）
```

#### Step 10: 配额警告
```
📊 配额使用情况（Step 10）

当前步数：10 / 20
运行时长：5分30秒 / 10分钟
工具调用：35 / 50

状态：正常 ✅
```

#### Step 15: 配额预警
```
📊 配额使用情况（Step 15）

当前步数：15 / 20 ⚠️
运行时长：8分10秒 / 10分钟 ⚠️
工具调用：42 / 50 ⚠️

提示：即将达到配额上限（75%），请确认是否继续

剩余任务：
- [ ] 为 /src/database/ 添加错误处理
- [ ] 为 /src/middleware/ 添加错误处理
- [ ] 更新测试

预计还需 8 步

请输入：
- "继续" - 继续执行
- "暂停" - 保存进度，稍后继续
```

### 用户响应
```
继续
```

#### Step 20: 配额耗尽
```
📊 配额使用情况（Step 20）

当前步数：20 / 20 ❌
运行时长：9分45秒 / 10分钟
工具调用：48 / 50

状态：已达到最大步数限制 ⛔

已完成：
- [x] 创建日志工具类
- [x] 为 /src/api/ 添加错误处理
- [x] 为 /src/services/ 添加错误处理
- [x] 为 /src/utils/ 添加错误处理
- [x] 为 /src/database/ 添加错误处理
- [x] 部分 /src/middleware/ 添加错误处理

未完成：
- [ ] 剩余 2 个中间件文件
- [ ] 更新测试

建议：
1. 审查已完成部分
2. 创建新会话继续剩余工作
3. 或调整配额限制（修改 quotas.yml）
```

---

## 示例4：黑名单拦截

### 用户输入
```
清理所有临时文件
```

### Claude 自动输出

#### Step 1: 分析清理范围
```json
{
  "step_id": "step-001",
  "goal": "识别临时文件位置",
  "decision_summary": "扫描常见临时目录",
  "tool_name": "grep_search",
  "expected_result": "找到 .tmp, .cache 等目录"
}
```

#### Step 2: 黑名单拦截
```
❌ 操作被拒绝

原因：命令触发黑名单规则
命令：rm -rf /tmp/*
违反规则：forbidden_commands 包含 "rm -rf /"

建议：
1. 使用更安全的清理方式
2. 明确指定要删除的文件
3. 避免使用通配符删除

替代方案：
- 使用 `find` 命令查找特定文件
- 逐个删除确认的临时文件
- 使用项目的清理脚本（如 npm run clean）
```

---

## 示例5：白名单验证

### 用户输入
```
修改 node_modules/express/lib/router.js
```

### Claude 自动输出

```
❌ 操作被拒绝

原因：路径不在白名单中
目标路径：node_modules/express/lib/router.js
违反规则：blacklist.paths 包含 "node_modules/"

说明：
禁止直接修改依赖包代码，这会导致：
1. 代码无法在其他环境复现
2. npm install 会覆盖修改
3. 团队协作困难

建议：
1. 通过 patch-package 创建补丁
2. Fork 依赖包并使用自己的版本
3. 向上游提交 PR 修复问题
4. 使用中间件或装饰器扩展功能

是否需要帮助实现以上方案？
```

---

## 总结

### 治理约束的核心价值

1. **结构化输出**：每一步都有清晰的决策日志
2. **风险控制**：高风险操作自动触发人工确认
3. **可追溯性**：完整的工具调用追踪
4. **代码质量**：强制要求注释和测试
5. **资源控制**：配额限制防止失控
6. **安全防护**：黑白名单防止危险操作

### 使用建议

1. **初次使用**：从简单任务开始，熟悉约束流程
2. **调整配额**：根据任务复杂度调整 quotas.yml
3. **自定义规则**：根据团队需求修改黑白名单
4. **持续优化**：收集反馈，改进治理策略

---

**版本**：v1.0.0  
**更新时间**：2026-01-22
