---
name: opus-review
description: Add-on to the tstack skills. Use Claude Opus wherever they call for GPT Sol, because there is no OpenAI subscription. Load it whenever sol-loop, full-send, full-stop or council runs, or a skill asks for a Sol review.
---

# opus-review

There is no OpenAI (Codex) or opencode subscription, so GPT Sol cannot run. This
skill patches the vendored tstack skills (`sol-loop`, `full-send`, `full-stop`,
`council`) without editing them. Where this file and those skills
disagree, this file wins.

## The substitution

Wherever a tstack skill says Sol, use the latest Claude Opus instead. This
overrides sol-loop's "If no route runs Sol, report the blocker. Do not
substitute a model." Every other rule in those skills still applies: budget,
ledger, brief, severities, stop conditions, and no scope creep.

## Starting the reviewer

- **Claude Code, including in T3:** use the native `Agent` tool with
  `subagent_type: "general-purpose"`, `model: "opus"` and
  `run_in_background: false`. Do not hardcode a model ID; the `opus` alias
  resolves to the latest. Never use `subagent_type: "fork"`. A fork inherits
  your context and reviews with your own blind spots, and the review is only
  worth something because the reviewer starts cold.
- **Later rounds:** follow up with `SendMessage` to the saved agent ID, as
  sol-loop says for a native reviewer (load `SendMessage` with ToolSearch
  first if it is deferred). If that ID is gone, start a fresh
  `Agent` with the round 1 brief plus the ledger.
- **T3 `delegate_task`:** use it only if the user asks, or if you need a
  separate worktree. Pick the Claude provider and the latest Opus from
  `orchestrator_capabilities`.

The reviewer is the same model family as the author, so the brief matters
more. Ask it to argue against the change, not to confirm it. Also ask it to
start its reply with `MODEL: <its model name>`, because the Agent result does
not say which model ran.

## Council

Use the providers you can reach. For a seat you cannot fill, such as GPT Sol,
start one more Opus delegate with a fresh context and a different focus (for
example "assume there is a bug and find it"). Do not report that seat as a
blocker, unless the user named that member. Label it honestly in the score
table, for example `Claude Opus (in place of GPT Sol)`.

Council delegates run in parallel: start them with `run_in_background: true`
and `effort: "high"`, not in the foreground like the sol-loop reviewer.

## Naming it honestly

Never write "Sol" for a review Opus did. In the PR line from sol-loop, write:

`Reviewed with sol-loop: <N> rounds with <model>. Verdict: approved`

`<model>` is the name the reviewer gave on its `MODEL:` line. Without one,
write `Claude Opus`.
