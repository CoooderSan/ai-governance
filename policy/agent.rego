package agent.guard

default allow = false
default needs_approval = false

# 禁止高危命令
deny_reason[msg] {
    input.action == "exec"
    forbidden := {"DROP TABLE", "kubectl delete", "rm -rf /"}
    some f
    contains(input.command, f)
    msg := sprintf("forbidden command: %s", [f])
}

# 生产环境写操作需要审批
needs_approval {
    input.env == "prod"
    input.action == "write"
}

# 非白名单仓库禁止写入
deny_reason[msg] {
    input.action == "write"
    not input.repo in {"oms", "wms", "tms", "shared-libs"}
    msg := sprintf("repo not whitelisted: %s", [input.repo])
}

# 成本超过阈值需要审批
needs_approval {
    input.estimated_cost > 10.0
}

allow {
    count(deny_reason) == 0
}

