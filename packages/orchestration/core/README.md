# Orchestration core

Shared files of the `orchestrate` and `dispatch` skills, reached through each skill's `references/core` link. Agents start from the skills' `SKILL.md`; this README is for maintainers.

- [workflow.md](workflow.md): the delegation workflow.
- [worker-contract.md](worker-contract.md): the rules and report format subagents follow.
- [verification.md](verification.md): how criteria are verified, through CI by default.
- [roles.md](roles.md): the two roles, their assignments and access, and the harness index.
- `harnesses/<harness>.md`: one harness's defaults, native spawning rules and usage logs, plus a Subagents section for facts that also apply to dispatch workers. Adding a harness means adding its file and its row in `roles.md`.

## Unverified harness facts

These come from tool descriptions or documentation and have not been observed in a live run. Each is marked `(unverified)` where it is stated; confirm it with a live run of the listed skill, then replace the mark with `(verified <date>, <harness version>)` or correct the fact, and remove it here.

| Harness | Fact | Where | Confirm with |
| --- | --- | --- | --- |
| Claude Code | The built-in `Explore` type cannot use the Write or Edit tools (stated by the Agent tool). | [Defaults](harnesses/claude-code.md#defaults) | `orchestrate` |
| Codex | `gh workflow run` works with `network: true`. | [Subagents](harnesses/codex.md#subagents) | `dispatch` |
| Cursor | The model ID encodes the effort. | [Defaults](harnesses/cursor.md#defaults) | `orchestrate` |
| Cursor | Task `resume` continues a finished subagent with its prior context. | [Native spawning](harnesses/cursor.md#native-spawning) | `orchestrate` |
| Cursor | How background subagent completion is reported (subagents run in the foreground until established). | [Native spawning](harnesses/cursor.md#native-spawning) | `orchestrate` |
| Cursor | Whether transcripts record token usage. | [Usage and timing](harnesses/cursor.md#usage-and-timing) | `orchestrate` |

Facts labeled reported (from documentation, such as the Claude Code Bash timeout and transcript retention) are also unconfirmed locally; `grep -rn "reported\|unverified" harnesses` lists every one.
