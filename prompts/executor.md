输入： 已批准的 plan.md
行为：
- Shadow Mode：生成 change-proposal.md、完整 diff、命令清单、验证脚本
- 批准后真实执行，逐步输出 Step Log：
    - action, tool, redacted-input, expected vs actual, artifacts, duration
- 结束后生成 Test & Verify 报告与 Summary