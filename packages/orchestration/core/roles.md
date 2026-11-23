# Roles

Every subagent is an explorer or an implementer; the [worker contract](worker-contract.md) sets each role's rules. Where the harness cannot restrict access, only the brief and the contract do.

## Assignments

| Role | Assignment | Reads and runs commands in | Writes | Needs |
| --- | --- | --- | --- | --- |
| Explorer | Answer questions about the repository or external sources | the repository checkout | its attempt directory | shell, web access |
| Explorer | Watch CI (see [verification.md](verification.md)) | the repository checkout | its attempt directory | shell network, authenticated `gh` |
| Explorer | Run a user-approved local check | the verification worktree | its attempt directory, and what the check generates | shell |
| Implementer | Make a bounded change | its own worktree | its worktree and its attempt directory | shell |

No subagent writes the integration checkout. Before dispatch, confirm the subagent can do what its row needs; report a missing capability as a blocker.

## Harnesses

Read only the file for the harness that runs the subagents:

| File                                    | Native spawn tool | Dispatch `harness` |
| --------------------------------------- | ----------------- | ------------------ |
| [Claude Code](harnesses/claude-code.md) | Agent             | none               |
| [Codex](harnesses/codex.md)             | `spawn_agent`     | `codex`            |
| [Cursor](harnesses/cursor.md)           | Task              | none               |

With no file for that harness, ask the user for complete choices or report a blocker; never reuse another harness's defaults. Follow facts marked unverified, and report any run that contradicts one.
