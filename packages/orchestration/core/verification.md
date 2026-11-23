# Verification

You never run checks or read raw check output. CI runs the checks; fresh explorers find or trigger the run, watch it and report per criterion. Local runs load the user's machine heavily: only with the user's approval.

## Plan

Before delegating implementation or verification, map each criterion in `task.md` to its evidence: a CI job (workflow and job), a behavioral scenario (target, initial state, steps, expected observations, evidence), or your review of one named artifact. Name gaps; never assume lint, types or an existing suite prove the behavior. Ask the user, and record the answer in `task.md`, when no CI workflow runs for a pushed branch (on push or `workflow_dispatch`), or when a criterion lacks CI coverage: add it to CI, approve a local check (exact command and directory), or rely on your review.

Implementers run only the cheapest scoped self-checks the brief lists, such as one package's typecheck; self-checks are not evidence.

## Running CI

Verify the pushed verification branch (see Integration in [workflow.md](workflow.md)). The explorer's brief gives `<owner/repo>`, the branch and head commit, the workflow, the target branch, the criteria each job covers, and these commands, with `-R <owner/repo>` on every `gh` call and output files as absolute paths in its attempt directory:

1. `gh auth status`; on failure, report `blocked`.
2. Find the run: `gh run list -R <owner/repo> --commit <sha> --workflow <workflow> --json databaseId,status,createdAt`, and take the newest. If the workflow does not run on push, trigger it once with `gh workflow run <workflow> -R <owner/repo> --ref <branch>` and list again. If no run appears within five minutes, report its criteria as `not run`.
3. Wait: `gh run watch <id> -R <owner/repo> --exit-status > <attempt-dir>/watch.log 2>&1`.
4. On failure, save `gh run view <id> -R <owner/repo> --log-failed > <attempt-dir>/failed.log`, then compare with the target branch's latest run (`gh run list -R <owner/repo> --branch <target> --workflow <workflow> --limit 1 --json databaseId,headSha,conclusion`) and report each failed job as new or pre-existing.

The entry skill says how the explorer gets network access and how long it may wait. A job that passed only on rerun is flaky: a limitation for the user to decide. CI evidence covers only its commit, so verify again after every change; when the task delivers a PR, its run on the final head commit is the final verification.

There is no baseline run. Fix every failure, except a pre-existing one outside the task's scope, which goes to the user. Never drop required checks or redefine expected behavior to hide a failure.

## Acceptance

Review each criterion against the report. A passing job supports only what it exercises, and a success status alone is not a meaningful observation. A failed, skipped, cancelled or unrun required check is a limitation or blocker, never a pass.
