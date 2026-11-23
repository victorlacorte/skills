---
name: orchestrate
description: Delegate implementation, research, codebase exploration and checks to fresh native subagents of the current harness, then review their reports and changes.
disable-model-invocation: true
---

# Orchestrate

Read [the delegation workflow](references/core/workflow.md) and follow it, spawning the current harness's native subagents. Use [the harness file](references/core/roles.md#harnesses) whose native spawn tool you have, including its Native spawning section. Native spawning cannot set a working directory or access: subagents act within the session's, directed by the brief's absolute paths. Before dispatch, confirm the session allows what [the assignment](references/core/roles.md#assignments) needs, or report a blocker.
