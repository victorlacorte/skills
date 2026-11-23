# Claude Code

## Defaults

| Role        | Type              | Model    | Effort   |
| ----------- | ----------------- | -------- | -------- |
| Explorer    | `general-purpose` | `haiku`  | `medium` |
| Implementer | `general-purpose` | `sonnet` | `medium` |

Use `general-purpose` for every role: subagents write reports, and the Agent tool lists `Explore` without Write or Edit (Claude Code 2.1.330, unverified in a run).

## Native spawning

- Pass the defaults as the Agent tool's `subagent_type`, `model` and `effort`; they are the explicit choice the `effort` field requires. Keep the saved effort even for harder work.
- Never use `subagent_type: "fork"` or SendMessage.
- Subagents share the session's working directory and permissions; the brief's absolute paths direct them.
- A subagent's Write tool rejects report-like file names (`report.md`, `findings.md`, `summary.md`: "Subagents should return findings as text") but accepts `result.md`, `checks.md` and `notes.md`, for any model; Bash writes are not checked (verified 2026-11-22, Claude Code 2.1.330). Keep attempt file names outside that pattern, and re-verify after upgrades.
- Waiting: subagents run in the background, and the harness notifies you when each finishes (verified 2026-11-22, Claude Code 2.1.330).
- A Bash call times out after 2 minutes unless it sets `timeout` (at most 10 minutes, reported). Tell CI explorers to run `gh run watch` with the maximum timeout and repeat it until the run finishes.
- Create worktrees with Git, not the Agent tool's `isolation: "worktree"`: the brief must name the worktree before dispatch.

## Usage and timing

Each assistant message in a transcript records `timestamp`, `model` and `usage` (verified, Claude Code 2.1.330). The parent transcript is `~/.claude/projects/<project-slug>/<session-id>.jsonl`; subagent transcripts are under `<session-id>/subagents/`. Transcripts are deleted after `cleanupPeriodDays` (30 by default, reported).
