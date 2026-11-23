# Cursor

## Defaults

| Role        | Type             | Model                    |
| ----------- | ---------------- | ------------------------ |
| Explorer    | `explore`        | `cursor-grok-4.6-medium` |
| Implementer | `generalPurpose` | `cursor-grok-4.6-medium` |

The model ID encodes the effort (unverified): keep it exact, and send no separate effort.

## Native spawning

- Pass the defaults as the Task tool's type and model. If it has no type field, state the role only in the message.
- A type name does not establish capabilities: `explore` subagents can write files and run shell commands (verified 2026-11-02, CLI 2026.10.22).
- Never use the Task tool's `resume` parameter (it continues a finished subagent with its prior context, unverified).
- Waiting: run subagents in the foreground. Background subagents return at launch, and how their completion is reported is not established (verified 2026-11-02, CLI 2026.10.22).

## Usage and timing

Subagent transcripts are `<parent transcript dir>/subagents/<subagent id>.jsonl`; whether they record token usage is unverified.
