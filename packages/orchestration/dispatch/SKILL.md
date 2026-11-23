---
name: dispatch
description: Delegate bounded exploration, research, checks and edits to cheaper worker agents in another harness through the agent-dispatch MCP server, then review their reports and integrate their changes.
disable-model-invocation: true
---

# Dispatch

Read [the delegation workflow](references/core/workflow.md) and follow it; this file supplies its mechanism through the agent-dispatch MCP tools.

## Target harness and access

Read [the harness file](references/core/roles.md#harnesses) whose dispatch `harness` value the `dispatch` tool accepts, skipping its Native spawning section. Set `harness` to that value and pass its defaults as `model` and `effort`. Enforce each [assignment](references/core/roles.md#assignments)'s access through the sandbox:

- `sandbox: workspace-write` for every worker.
- Implementer: `cwd` is its worktree and `writable_dirs` its attempt directory. Approved local check: `cwd` is the verification worktree, with the same `writable_dirs`. Other explorers: `cwd` is the attempt directory, with no `writable_dirs`.
- `network: true` only for explorers watching CI.

No worker gets `cwd` in the integration checkout. If the harness file records no verified sandbox behavior, or the `harness` field does not accept its value, report a blocker.

Use the attempt ID as `label`. For a CI-watching explorer, set `timeout_s` to the CI run's expected duration plus a margin.

## Dispatch and wait

- Dispatch independent jobs in one turn and `wait` on all their IDs; use `mode: any` only when an early result changes your next step.
- Never poll with short timeouts or sleep. Use `cancel` for jobs no longer needed.

## Before review

Check `state`, `failure_reason` and `observed` (a model, effort or sandbox that differs from the request: a deviation). If `final_message_truncated` is set, read `<dir>/final-message.md`.

| Job state | Action |
| --- | --- |
| `completed` | Review the report; its `Status:` is separate from the job state. |
| `failed` | Read `failure_reason`, and `<dir>/stderr.log` if it is unclear. Fix the brief or setup in attempt `n + 1`, or stop on a real blocker. |
| `timed_out` | Read any partial report. Retry as attempt `n + 1` with a narrower scope or a longer `timeout_s`. |
| `interrupted` | The supervisor died. Inspect an implementer's worktree before any new attempt. |

## Recovery and usage

After a restart, `list` recovers job IDs by label, and `wait` with `timeout_s: 0` returns a finished job's result and `dir`. Usage and timestamps are in `<dir>/meta.json`; the worker's transcript is at its `sessionLog`. List each attempt's job ID in the final report.
