# Skills

Authored agent skills for Claude Code, Codex and Cursor, and their tooling.

| Skill | Purpose |
| --- | --- |
| [`orchestrate`](packages/orchestration/orchestrate/SKILL.md) | Delegate implementation, research, exploration and checks to subagents, then review their changes and evidence. |
| [`babysit`](packages/babysit/SKILL.md) | Drive one GitHub pull request to merge-ready, without merging. |
| [`reviewable-prs`](packages/reviewable-prs/SKILL.md) | Deliver new work as small, independently reviewable pull requests. |

All three set `disable-model-invocation: true` (Claude Code, Cursor) and `policy.allow_implicit_invocation: false` (Codex), so they run only when invoked by name.

## Install

```sh
pnpm skills:install
```

This validates the skills (see [AGENTS.md](AGENTS.md#skill-directories)), then links each skill directory into `~/.agents/skills` (read by Codex and Cursor) and `~/.claude/skills` (read by Claude Code), as one directory link per skill: Cursor CLI's `/` menu skips a `SKILL.md` that is itself a symlink. Existing links with a skill's name are replaced, real directories are left alone and reported, and dangling links into this checkout are deleted. Run it again after adding or removing a skill.

The Cursor journal hook (`~/.cursor/hooks.json`, managed elsewhere) runs `$HOME/.agents/skills/orchestrate/hooks/cursor-journal.sh`, so it follows the installed link.

## Orchestration journals

`orchestrate` records task and attempt events in a `journal.jsonl` per task through [`journal-append`](packages/orchestration/orchestrate/scripts/journal-append) (see [activity-journal.md](packages/orchestration/orchestrate/references/activity-journal.md)). The analyzer reads those journals:

```sh
pnpm install
pnpm -F @skills/orchestration journal:install   # links packages/orchestration/src/cli.ts as ~/.local/bin/orchestrate-journal
orchestrate-journal analyze [--json] [--cursor-dir DIR] journal.jsonl...
```

It needs Node 26.13.1 or later, which runs the TypeScript entry point directly.

## Development

See [AGENTS.md](AGENTS.md) for commands and conventions.
