# Skills

Authored agent skills for Claude Code, Codex and Cursor, and their tooling.

| Skill | Purpose |
| --- | --- |
| [`orchestrate`](packages/orchestration/orchestrate/SKILL.md) | Delegate implementation, research, exploration and checks to native subagents of the current harness, then review their reports and changes. |
| [`dispatch`](packages/orchestration/dispatch/SKILL.md) | The same workflow, delegating to workers in another harness through the [agent-dispatch](https://github.com/victorlacorte/agent-dispatch-mcp) MCP server. |
| [`babysit`](packages/babysit/SKILL.md) | Drive one GitHub pull request to merge-ready, without merging. |
| [`reviewable-prs`](packages/reviewable-prs/SKILL.md) | Deliver new work as small, independently reviewable pull requests. |

All of them set `disable-model-invocation: true` (Claude Code, Cursor) and `policy.allow_implicit_invocation: false` (Codex), so they run only when invoked by name.

## Install

```sh
pnpm skills:install
```

This validates the skills (see [AGENTS.md](AGENTS.md#skill-directories)), then links each skill directory into `~/.agents/skills` (read by Codex and Cursor) and `~/.claude/skills` (read by Claude Code), as one directory link per skill: Cursor CLI's `/` menu skips a `SKILL.md` that is itself a symlink. Existing links with a skill's name are replaced, real directories are left alone and reported, and dangling links into this checkout are deleted. Run it again after adding or removing a skill.

## Development

See [AGENTS.md](AGENTS.md) for commands and conventions.
