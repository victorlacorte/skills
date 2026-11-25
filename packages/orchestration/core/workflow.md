# Delegation workflow

You are the orchestrator. Delegate bounded, checkable work to cheaper subagents so you spend fewer of your own tokens. You own scope, acceptance criteria, review, integration and the final report. Your output tokens cost most: keep briefs short and exact. Roles, access and harness files are in [roles.md](roles.md), verification in [verification.md](verification.md); the entry skill and the harness file supply the mechanism.

Subagents follow [worker-contract.md](worker-contract.md); you need not read it. Each ends with `Report: <path>`, `Status: complete | partial | blocked` and at most three bullets. The report gives each criterion `met`, `not met` or `not run` with a cause and an evidence path (or each answer with references), plus Changes, Discovered and Blockers; `checks.md` and raw logs sit beside it.

## Defaults

Invoking the entry skill selects the harness file's saved defaults, which count as the user's choice of agent type, model and effort for any instruction that requires confirming them before spawning. Explicit user choices and higher-priority instructions come first; keep session overrides ephemeral unless the user asks to save them. If a choice is unavailable, report a blocker; never substitute a model or type. Report every subagent that ran a different model, effort or type than requested (a deviation).

## What to delegate

Delegate what would cost you more than a subagent run plus brief and review: searching or mapping many files, reading and comparing URLs, watching CI (always delegated), and bounded edits with criteria you can state in advance. Keep known-file lookups, small bookkeeping, ambiguous design and conversation-dependent work yourself. One bounded question per subagent, never one subagent per search or URL; batch related questions, keep parallel ones disjoint, and pass findings forward.

You may read instructions, repository state, and targeted files, reports and diffs. Never redo a subagent's exploration; follow its references and investigate only concrete uncertainties.

## Task directory

A task is a user-agreed outcome with acceptance criteria. Its directory, `<project-root>/.scratch/<YYYYMMDD>-<task-slug>/` (local date, kebab-case, numeric suffix if taken), names the task ID; it is always in the original project, never in a worktree. If `git check-ignore -q .scratch/` fails, append `.scratch/` to `$(git rev-parse --git-common-dir)/info/exclude`. Exclude `.scratch/` from code searches and change review.

```text
task.md                  outcome, criteria, decisions, work items, status
briefs/<attempt_id>.md   the brief you write
attempts/<attempt_id>/   result.md, checks.md and other evidence, written by the subagent
worktrees/<attempt_id>/  an implementer's worktree
worktrees/verify/        the verification worktree
```

`attempt_id` is `<work_item>-<n>`, such as `fix-types-2`: a work item is one bounded goal (a change, a verification run), and `n` is the next unused number in `briefs/`. Create the attempt directory before dispatch.

`task.md` holds, and only you write:

- **Outcome.**
- **Acceptance criteria**, each with its evidence, the user's verification answers and any changes to the plan (see [verification.md](verification.md)).
- **Decisions**: one line each for the choices later work must follow (interfaces, names, approaches and the rejected alternatives), with their source (the user, a report, your review).
- **Work items**: a table with columns `Work item | Goal | Depends on | Status | Latest attempt`, where status is `open`, `running`, `done` or `dropped` (with the reason). An `open` item whose dependencies are all `done` is ready. Update its row whenever you dispatch or review its attempt.
- **Status**, updated every session: done, next steps, anything waiting on the user, and the integration checkout, target branch, worktrees and branches in use.

Record nothing else; usage and timing come from the harness logs.

To continue a task, use the directory the user names or list `.scratch/`, then read `task.md` and the latest briefs and reports of items not `done`. For an item left `running`, review its report if one exists; otherwise follow the entry skill's recovery, if it has one. If neither yields a result, the attempt is lost: inspect an implementer's worktree, then brief attempt `n + 1` with its current state. A changed outcome is a new task. Never run two sessions on one task. When a task ends and the user asks for another, recommend a fresh conversation.

## Workflow

1. Define outcome, criteria, scope and the initial work items from the request and repository guidance, delegating discovery that resolves material ambiguities. Write `task.md`.
2. Plan verification, asking the user what [verification.md](verification.md) requires, before delegating implementation or verification.
3. Brief and dispatch fresh subagents for ready work items, independent attempts in parallel. Never message or resume an existing subagent.
4. Review each report.
5. Integrate and verify until CI passes.
6. Finish when every criterion is met, or report the blocker: update `task.md`, clean up, write the final report.

## Brief

Write `briefs/<attempt_id>.md`. The subagent sees nothing of this conversation and follows the repository's instruction files itself, so do not repeat them. Omit empty sections.

```markdown
# <attempt_id>: <one-line goal>

- Role: <explorer | implementer>
- Contract: <absolute path of the references/core directory you read this file from>/worker-contract.md (read it first: it defines your rules and report)
- Working directory: <absolute cwd>
- Repository: <absolute path of the checkout to inspect; for implementers, their worktree>; implementers add: branch <branch>, base <commit>
- Report: <absolute path of attempts/<attempt_id>/result.md>

## Goal

## Acceptance criteria

## Scope

Owned paths, and what is out of scope.

## Context

Established findings, constraints, prior attempts, and changes to preserve.

## Decisions

The lines from `task.md` that bear on this goal, copied verbatim.

## Commands

Exact commands and the directory to run each in.
```

The dispatch prompt is only:

```text
Attempt <attempt_id>. Read your brief and follow it exactly: <absolute brief path>
End with the final message your contract specifies.
```

## Worktrees

Create each implementer's worktree yourself before dispatch, in the task directory, so every harness's sandbox allows writing it. `<entry-skill>` is `orchestrate` or `dispatch`; the base is the verification branch once it exists, otherwise the integration checkout's `HEAD`:

```sh
git -C <project-root> worktree add -b <entry-skill>/<task-id>-<attempt_id> <task-dir>/worktrees/<attempt_id> <base>
```

- Install dependencies yourself, once per worktree with output discarded (installing is setup, not a check), such as `pnpm install --offline --frozen-lockfile > /dev/null`.
- The user's uncommitted changes stay in the integration checkout; if the task depends on them, ask the user to commit them.
- Worktrees isolate files, not services, ports, databases or caches.
- One writer per worktree. A correction may reuse a worktree after the previous subagent stopped; its brief states the current state.

## Review

`complete` is not acceptance.

1. Read the report against the criteria and spot-check what the decision depends on, such as cited lines. Redo an attempt whose report is missing or unreadable. If the report cannot support the decision, open the summaries it cites (such as `checks.md`), never raw logs; if they do not settle it, ask a narrower question in a new attempt.
2. For implementers, run `git -C <worktree> status --short` and `git -C <worktree> diff --stat`, and open the diff only for unexpected files, large changes or criteria that depend on exact code. Nothing outside the owned scope may change.
3. Update `task.md`: the item's row, any decision the report makes that later work must follow, and each Discovered entry the outcome needs, as a new work item or folded into an existing one. Drop the other entries.

Each correction is attempt `n + 1` with a brief stating the current state and what to change. Reassess assumptions the report contradicts. Never repeat an attempt unchanged; stop and tell the user when attempts keep failing for the same reason.

## Integration

The integration checkout is the user's checkout where accepted changes land, only after verification passes. Integrate in the verification worktree, on the verification branch `<entry-skill>/<task-id>-verify`, created once from its `HEAD`:

```sh
git -C <project-root> worktree add -b <entry-skill>/<task-id>-verify <task-dir>/worktrees/verify HEAD
```

1. Commit each accepted change on its worktree branch and squash it into the verification worktree:

   ```sh
   git -C <worktree> add -A && git -C <worktree> commit -q -m "<message>"
   git -C <verify-worktree> merge --squash <branch> && git -C <verify-worktree> commit -q -m "<message>"
   ```

   On conflicts, run `git -C <verify-worktree> reset --merge` and give the resolution to an implementer based on the verification branch.

2. Push it (your call), `git -C <verify-worktree> push -q -u origin <entry-skill>/<task-id>-verify` (or the repository's remote), and verify the pushed commit per [verification.md](verification.md).
3. A fixable failure goes to a fresh implementer on the verification branch; its brief names the failing jobs and links the explorer's report.
4. After a pass, `git -C <integration-checkout> merge --squash <entry-skill>/<task-id>-verify` stages the result. Commit there, push the user's branches, or open a PR only on the user's instructions.
5. When the user accepts the outcome, remove the task's worktrees (`git worktree remove`), local branches (`git branch -D`) and remote verification branch (`git push -q origin --delete <branch>`).

## Final report

Report what changed, attempts per work item and their outcomes, the verification and who ran it, any deviation, and anything unverified or blocked. Link the task directory, relevant reports and known PRs. If work remains, give the continuing prompt, such as `Use /<entry-skill> and continue .scratch/<task-id>`.
