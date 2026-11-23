# AGENTS.md

This repository holds the user's authored agent skills and their tooling, as a pnpm workspace. Every directory under `packages/` that contains a `SKILL.md` is one skill, installed by linking the whole directory into `~/.agents/skills` (Codex, Cursor) and `~/.claude/skills` (Claude Code). See [README.md](README.md) for installation.

## Commands

Node and pnpm are pinned (`mise.toml`, the `packageManager` field). In a non-interactive shell, run `eval "$(mise env -s bash)"` first.

```sh
pnpm install
pnpm check            # typecheck, lint, format:check, check:text, check:skills and test (root and every package): run before finishing a change
pnpm format           # oxfmt, also formats Markdown
pnpm skills:install   # links every skill into the user skill roots
```

TypeScript runs directly through Node's type stripping. There is no build step, so use only erasable syntax (no enums, namespaces or parameter properties) and import with `.ts` extensions.

## Writing rules

- Never use the em dash (U+2014). Use the plain dash, or rewrite the sentence with commas, parentheses or a colon.
- Never use curly single quotes (U+2018, U+2019). Use the plain apostrophe.
- This repository is public: no absolute paths into a home directory (under `/Users` or `/home`), user names or secrets. Use `~` or a placeholder.
- `pnpm check:text` enforces these three rules on every tracked file.
- Skill text is paid for in tokens every time an agent reads it. Keep it short, state each rule in exactly one place, and link instead of repeating.

## Layout

```text
packages/<skill>/             a skill with no code: the package directory is the skill
packages/<family>/            skills that share files, optionally a workspace package (package.json, src/, test/) with their code
packages/<family>/<skill>/    a skill inside a family; never holds package files
scripts/                      repository tooling and its tests
```

`packages/orchestration/` is the family of `orchestrate` and `dispatch`. Both are thin entry skills over `core/` (the shared workflow, worker contract, verification policy, roles, and one file per harness under `core/harnesses/`), which each reaches through its `references/core -> ../../core` link. `core/` has no `SKILL.md`, is never installed itself, and its files link only to each other: a `..` from `references/core/` resolves differently lexically and physically. A rule belongs in `core/` unless it depends on the delegation mechanism. Everything about one harness (spawn tool, dispatch value, role defaults, its subagents' capabilities, native spawning and waiting, usage logs) lives in its `core/harnesses/<harness>.md`, so adding a harness means adding that file and its link in `core/roles.md`; the `dispatch` MCP fields are harness-independent and stay in `dispatch/SKILL.md`. [core/README.md](packages/orchestration/core/README.md) lists the unverified harness facts.

## Skill directories

`scripts/install-skills` finds skills and validates them before linking anything; `pnpm check:skills` runs the same validation. A skill directory:

- is named after the skill, and its `SKILL.md` frontmatter `name` matches the directory name. The [Agent Skills specification](https://agentskills.io/specification) requires this, and allows 1-64 characters of `a-z`, `0-9` and hyphens, not leading, trailing or doubled. Do not add suffixes such as `-skill`.
- has a name no other skill uses, wherever it sits under `packages/`.
- contains nothing that is not skill payload: no `package.json`, `node_modules` or nested skill, because the whole directory is installed. When a Markdown-only skill gains code, give it a package directory and move the skill inside: `packages/<skill>/<skill>/`.
- refers to files outside itself only through relative links that still resolve after installation (the install links the directory, and harnesses follow the link to this checkout).

## Where things go

- **`docs/`** holds durable knowledge: decisions, verified harness behavior. It must not link into `.scratch/`.
- **`.scratch/`** holds throwaway material (plans, handoffs, research, trial evidence, side-effects logs). It is ignored by Git and never committed. Use one directory per piece of work, named `<YYYYMMDD>-<kebab-case-subject>/`, and reuse it when continuing that work.

## Working rules

- **Label harness facts** as verified (observed locally, with the harness version) or reported (from documentation).
- **Log side effects.** Record every command that changes state outside this repository (home directory files, symlinks, global installs) in the work's `.scratch/` directory, with how to revert it.
- **Behavior changes need tests.**
- Before spawning subagents, confirm the agent type and reasoning level with the user.
- Commit only when the user asks.
