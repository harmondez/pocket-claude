<div align="center">

<img src="assets/logo.jpg" width="220" alt="pocket-claude — a backpack logo labeled Pocket-Claude by harmondez, surrounded by gold coins and gears">

# 🪙 pocket-claude

**A personal baseline template for Claude Code that does one job well: spend fewer tokens per session without touching answer quality.**

Built for Sonnet, high effort.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Made for Claude Code](https://img.shields.io/badge/made%20for-Claude%20Code-8A63D2)

</div>

<br>

> [!TIP]
> **The whole design in one sentence:** only `CLAUDE.md` ever loads
> automatically. Everything else — reference docs, vendored cookbooks — is
> read on demand, one file at a time, never the whole directory.

<br>

---

## 🤔 Why this exists

Claude Code re-reads `CLAUDE.md` and re-evaluates your permission/hook setup
*every single session* — so every wasted line in there is a cost you pay
forever, not once. Most of that waste is avoidable: restating behavior the
harness already does by default, letting noisy test output flood the
context, guessing permissions instead of earning them. pocket-claude is the
small, boring fix for all three, built and verified (not guessed) file by
file — the measured proof is a few sections down.

<br>

---

## 🚀 Install

<br>

### 1️⃣ Get a local copy, once

Clone it somewhere permanent on your machine — this is the copy you'll pull
from every time you start a new project, not something you re-clone per
project.

```bash
git clone https://github.com/harmondez/pocket-claude.git ~/pocket-claude
```

<br>

### 2️⃣ Drop it into a new project

From the root of a new (or existing) project:

```bash
cp -r ~/pocket-claude/CLAUDE.md ~/pocket-claude/.claude ~/pocket-claude/docs ~/pocket-claude/references .
```

That's it — `CLAUDE.md` and `.claude/` now sit at your project root, right
where Claude Code looks for them.

<br>

### 3️⃣ Fill in the three placeholders

Open `CLAUDE.md` and replace each `<!-- fill per project -->` with concrete
detail about *this* project — they ship empty on purpose, a generic template
shouldn't guess. These are the three sections Anthropic's own best practices
recommend having, so Claude doesn't have to rediscover them by exploring the
repo every session:

| Section | What goes there | Example |
|---|---|---|
| 🛠️ **Commands** | The exact commands to build/test/lint this project | `npm run dev`, `npm run build`, `npm run lint` |
| 🏗️ **Architecture** | 2-3 lines on what isn't obvious from reading the code | "API in `src/api/`, business logic in `src/domain/`. Never import from `api/` into `domain/`." |
| ✅ **Testing** | Test framework and how to run it | `pytest`. Integration tests need `docker compose up -d db` first. |

> [!TIP]
> **You don't have to write this by hand.** Claude Code can fill it in for
> you by actually exploring the project instead of guessing. Paste this in:
>
> ```text
> I just copied pocket-claude into this project's root. Explore the repo
> and fill in the Commands, Architecture, and Testing sections of
> CLAUDE.md with what you actually find — real commands from
> package.json/pyproject.toml/Makefile/Cargo.toml (whichever applies),
> a short note on structure that isn't obvious from the file tree, and
> the real test framework/setup. Keep each section as short as the
> examples already in CLAUDE.md — concrete facts, not a tutorial.
> ```

<br>

### 4️⃣ Make sure `jq` is installed

The test-output hook needs it.

> [!WARNING]
> If `jq` is missing, the hook just fails open — no filtering, nothing
> breaks. Easy to skip, easy to forget, only noticed later when test output
> floods your context.

| OS | Command |
|---|---|
| 🪟 Windows | `winget install jqlang.jq` |
| 🍎 macOS | `brew install jq` |
| 🐧 Debian / Ubuntu | `apt install jq` |

<br>

✅ **Done.** Open Claude Code in the project and go.

<br>

---

## 📦 What's inside

<br>

| Path | Loads | Purpose |
|---|---|---|
| `CLAUDE.md` | Every session | Short, no restated defaults, three project-specific placeholders |
| `.claude/settings.json` | Every session | Small permissions allowlist, `autoCompactWindow`, hook registration |
| `.claude/hooks/filter-test-output.sh` | On matching `Bash` calls | Condenses pytest / npm test / jest / go test / cargo test output to failures + a summary |
| `docs/token-optimization-reference.md` | On demand | Verified notes on caching, model routing, data formats, context rot |
| `references/claude-cookbooks/` | On demand | Pruned snapshot of `anthropics/claude-cookbooks` (13MB → relevant folders only) |
| `references/claude-code-best-practice/` | On demand | Pruned snapshot of `shanraisshan/claude-code-best-practice` |

Both vendored snapshots keep their original `LICENSE` file — they're
third-party code under their own upstream licenses (both MIT), separate from
the rest of this repo. (`assets/` isn't in that table on purpose — it's the
logo for this README, not part of what gets copied into a project.)

> [!NOTE]
> **"On demand" means:** don't read the directory, read the one file you
> actually need, only when a task calls for it (writing a hook, tuning
> caching, designing an agent pattern). Loading any of it wholesale defeats
> the point of the whole repo.

<br>

---

## 📊 It actually works — measured, not vibes

A realistic synthetic `pytest` run (220 tests, 3 real failures, 244 lines)
pushed through the actual hook in this repo:

| | Lines | Characters |
|---|---|---|
| Raw output | 244 | 17,781 |
| Through the hook | 17 | 889 |
| **Reduction** | **93%** | **95%** |

All 3 failures and the summary line survived intact — only the 217 noisy
`PASSED` lines got dropped.

<br>

---

<details>
<summary>🔒 <strong>Permissions</strong></summary>

<br>

`.claude/settings.json` ships with a small, honest allowlist — a handful of
read-only git inspection commands — instead of a long speculative one. Grow
it per project with the `fewer-permission-prompts` skill as real prompts
actually show up, rather than guessing upfront.

> [!IMPORTANT]
> Don't edit permission rules mid-session: it invalidates the prompt cache.

</details>

<details>
<summary>🕶️ <strong>Why <code>.claude-example/</code> instead of <code>.claude/</code> inside references</strong></summary>

<br>

Both vendored repos ship their own example `.claude/` configs — demo agents,
skills, hooks (some genuinely useful patterns, e.g. the cookbook's own
`pre-bash.sh` hook). Every nested `.claude/` found inside `references/` was
renamed to `.claude-example/` so it can never be picked up as live config by
Claude Code in a project that has this template copied in. The content is
still there to read; it's just inert.

</details>

<details>
<summary>🔄 <strong>Refreshing <code>references/</code></strong></summary>

<br>

Both vendored repos are pruned, `.git`-stripped snapshots — a frozen copy,
not something that auto-updates. `claude-cookbooks/` had its
images/multimodal/capabilities/third-party/finetuning folders removed
(192MB of content irrelevant to token optimization); `claude-code-best-practice/`
had its screenshots/slides/videos removed. To pull either back to upstream's
current state:

```bash
rm -rf references/<name>
git clone --depth 1 <upstream-url> references/<name>
rm -rf references/<name>/.git
# re-prune if you want to keep it lean — see git log for what was removed
```

</details>

<details>
<summary>🧭 <strong>Explicitly out of scope for v1</strong></summary>

<br>

No custom subagents, no custom skills, no per-stack modular rules
(`.claude/rules/`). These get added later, per project, when a real need
shows up — not speculatively now.

</details>

<br>

---

## 🤝 Contributing

Found a claim in `docs/token-optimization-reference.md` that's gone stale,
a hook that misbehaves on your shell, or a pattern worth adding? Issues and
PRs are welcome — just keep the core rule intact: nothing goes in that isn't
verified, and nothing loads unless something actually needs it.

<br>

<div align="center">

MIT licensed. Fork it, prune it, make it yours. 🍴

</div>
