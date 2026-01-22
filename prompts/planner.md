输入： Intent 文档 + Workspace Manifest（若有）
输出： Plan.md（仅计划，不执行），包含：
- Objectives / Assumptions / Non-goals
- Task Breakdown（最小可执行粒度）
- Tool Calls（顺序、关键参数、预期输出、风险）
- Expected Diffs（仓库/模块/文件）
- Test Strategy （生成/更新测试）
- Rollback plan
- Risk Assessment（L/M/H/Critical）