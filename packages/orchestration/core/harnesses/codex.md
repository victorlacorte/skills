# Codex

## Defaults

| Role        | Model        | Effort   |
| ----------- | ------------ | -------- |
| Explorer    | `gpt-6-luna` | `medium` |
| Implementer | `gpt-6-luna` | `medium` |

## Subagents

- A trivial run takes 10 to 20 seconds and about 40k mostly cached input tokens (codex-cli 0.171.0). Delegate only work worth that overhead.
- Through dispatch (verified, codex-cli 0.171.0), `workspace-write` allows writes only under `cwd`, `writable_dirs` and temporary directories, and `.git` is read-only. Checks that write inside the repository (build output, coverage, incremental build info) fail unless `cwd` is that checkout.
- There is no shell network unless enabled, which opens every host. With it, `gh` authenticates through the keyring and `gh run list`, `gh run watch` and `gh run view` work (`gh workflow run` is unverified). The built-in web tool reads public URLs without it (verified 2026-11-22).

## Native spawning

- Subagents inherit the session's sandbox, writable roots, network setting, approval policy and working directory; `spawn_agent` cannot set them (verified 2026-11-07, codex-cli 0.167.0). Worktrees in the task directory are writable when the session runs in the project; a CI explorer needs the session to have network access.
- Call `spawn_agent` with `task_name` (the attempt ID with hyphens replaced by underscores: only lowercase letters, digits and underscores), `message` (the dispatch prompt), `model` and `reasoning_effort` (the defaults, always explicit) and `fork_turns: "none"` (the default, `all`, passes this conversation). There is no type field (codex-cli 0.171.0).
- Never use `send_message` or `followup_task`.
- Waiting: `wait_agent` returns when any subagent has an update, or after `timeout_ms` (at most 3600000), without the content; each final message arrives as a message from its subagent (verified 2026-11-07, codex-cli 0.167.0). Call it until every subagent has sent its final message.

## Usage and timing

The session log is `~/.codex/sessions/YYYY/MM/DD/rollout-*-<thread-id>.jsonl`, with timestamps and `token_count` events per turn; the current thread ID is `$CODEX_THREAD_ID` (both verified 2026-11-22, codex-cli 0.171.0).
