# pocket-claude

Personal baseline template for Claude Code, focused on one thing: minimize
token spend per session while keeping (or improving) answer quality, assuming
Sonnet, high effort. Copy this folder into the root of any new project.

## What's inside

```
CLAUDE.md                              always loaded every session — kept short
.claude/settings.json                  permissions allowlist, autoCompactWindow, hook registration
.claude/hooks/filter-test-output.sh    PreToolUse hook: condenses test-runner output
docs/token-optimization-reference.md   verified reference notes — read on demand
references/claude-cookbooks/           pruned vendor snapshot of anthropics/claude-cookbooks
references/claude-code-best-practice/  pruned vendor snapshot of shanraisshan/claude-code-best-practice
```

**Only `CLAUDE.md` loads automatically.** Everything in `docs/` and
`references/` is there to be read on demand — a specific file, not the whole
directory — when working on something that touches hooks, agent patterns,
prompt caching, or context management. `CLAUDE.md` itself points this out.

## Deploying to a new project

Copy the whole folder's contents into the new project's root (so `CLAUDE.md`
and `.claude/` end up at the project root, not nested under `pocket/`). Then
fill in the `Commands` / `Architecture` / `Testing` placeholders in
`CLAUDE.md` for that specific project — they're intentionally left empty
here since project-specific detail doesn't belong in a generic template.

## Requirements

- `jq` must be installed for `.claude/hooks/filter-test-output.sh` to
  actually filter anything. Without it, the hook fails open (no filtering,
  the command still runs normally) — it won't break a session, it just won't
  save anything. Install: `winget install jqlang.jq` (Windows),
  `brew install jq` (macOS), `apt install jq` (Debian/Ubuntu).

## Permissions

`.claude/settings.json` ships with a small, honest allowlist (read-only git
inspection commands) rather than a long speculative one. Grow it per project
with the `fewer-permission-prompts` skill as real prompts actually show up.
Don't edit permission rules mid-session — it invalidates the prompt cache.

## Why `.claude-example/` and not `.claude/` inside references

Both vendored repos ship their own example `.claude/` configs (demo agents,
skills, hooks — some of them genuinely useful patterns, e.g. the cookbook's
own `pre-bash.sh` hook). Every nested `.claude/` found inside `references/`
was renamed to `.claude-example/` so it can never be picked up as live
config by Claude Code in a project that has this template copied in — the
content is still there to read, it's just inert.

## Maintaining `references/`

Both vendored repos are pruned, `.git`-stripped snapshots, not submodules —
they're a frozen copy, not auto-updating. `claude-cookbooks/` had its
images/multimodal/capabilities/third_party/finetuning example directories
removed (192MB of content irrelevant to token optimization);
`claude-code-best-practice/` had its screenshots/slides/videos removed. To
refresh either one to upstream's current state:

```
rm -rf references/<name>
git clone --depth 1 <upstream-url> references/<name>
rm -rf references/<name>/.git
# re-apply the same pruning as above if you want to keep it lean
```

## Explicitly out of scope for v1

No custom subagents, no custom skills, no per-stack modular rules
(`.claude/rules/`). These get added later, per project, when a real need
shows up — not speculatively here.
