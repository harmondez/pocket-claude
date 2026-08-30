<a id="top"></a>

<div align="center">

<img src="assets/logo.png" width="480" alt="pocket-claude — a backpack labeled Pocket-Claude by harmondez, with a stack of gold coins beside it">

<br>

# 🪙 pocket-claude

### Spend fewer tokens per session. Touch nothing else.

**A personal baseline template for Claude Code** — built for Sonnet, high effort.

<br>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Made for Claude Code](https://img.shields.io/badge/made%20for-Claude%20Code-8A63D2)
![Measured, not vibes](https://img.shields.io/badge/benchmarks-measured%2C%20not%20vibes-brightgreen)
[![GitHub stars](https://img.shields.io/github/stars/harmondez/pocket-claude?style=social)](https://github.com/harmondez/pocket-claude/stargazers)

<br>

<a href="#why">Why</a> •
<a href="#install">Install</a> •
<a href="#try-it">Try it</a> •
<a href="#proof">Proof</a> •
<a href="#more-details">More details</a> •
<a href="#contributing">Contributing</a>

</div>

<br>

> [!TIP]
> **The whole design in one sentence:** only `CLAUDE.md` ever loads
> automatically. Everything else — reference docs, vendored cookbooks — is
> read on demand, one file at a time, never the whole directory.

<br>

---

<a id="why"></a>

## 🤔 Why this exists

Claude Code re-reads `CLAUDE.md` and re-evaluates your permission/hook setup
*every single session* — so every wasted line in there is a cost you pay
forever, not once. Most of that waste is avoidable: restating behavior the
harness already does by default, letting noisy test output flood the
context, guessing permissions instead of earning them. pocket-claude is the
small, boring fix for all three, built and verified (not guessed) file by
file — the measured proof is a few sections down.

<div align="right"><a href="#top">⬆ back to top</a></div>

<br>

---

<a id="install"></a>

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

### 3️⃣ Let Claude take it from here

You've got it! Now hand Claude this prompt so it reads pocket-claude and
internalizes it for this project from here on:

> [!TIP]
> ```text
> I just copied pocket-claude into this project's root. Read CLAUDE.md and
> the rest of what's in there, fill in the Commands, Architecture, and
> Testing sections with what you actually find in this project — real
> commands, real structure, real test setup, not guesses — and follow
> these conventions for how we work together here from now on.
> ```

<br>

### 4️⃣ Make sure `jq` is installed

The test-output hook needs it. [`jq`](https://jqlang.org/) is a
small, widely-used command-line tool for reading JSON — the hook uses it to
parse the tiny bit of JSON Claude Code hands it before rewriting a test
command.

> [!WARNING]
> Without `jq`, the hook silently does nothing — your commands still run
> fine, they just won't be filtered. Nothing breaks, but you also won't get
> the token savings until you install it.

| OS | Command |
|---|---|
| 🪟 Windows | `winget install jqlang.jq` |
| 🍎 macOS | `brew install jq` |
| 🐧 Debian / Ubuntu | `apt install jq` |

Or let Claude do it — paste this in:

> [!TIP]
> ```text
> Check whether jq is installed (`jq --version`). If it's missing, detect
> my OS and install it with the right package manager (winget on Windows,
> brew on macOS, apt on Debian/Ubuntu), then confirm it's on PATH.
> ```

<br>

✅ **Done.** Open Claude Code in the project and go.

<div align="right"><a href="#top">⬆ back to top</a></div>

<br>

---

<a id="try-it"></a>

## 🔥 Get ready to spend fewer tokens

You're set up — now go put it to work. Copy it into a real project, watch
`CLAUDE.md` stay lean instead of creeping past a thousand lines, and see
the test-output hook actually cut the noise before it ever hits your
context.

**Then tell us how it went.** Worked great? Found a bug, a hook that
misbehaves on your shell, or a claim in the docs that's gone stale?
[Open an issue](https://github.com/harmondez/pocket-claude/issues) — that's
exactly what this repo runs on.

<div align="right"><a href="#top">⬆ back to top</a></div>

<br>

---

<a id="proof"></a>

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

<div align="right"><a href="#top">⬆ back to top</a></div>

<br>

---

<a id="more-details"></a>

## 📚 More details

<br>

<details>
<summary>📦 <strong>What's inside</strong></summary>

<br>

| Path | Loads | Purpose |
|---|---|---|
| `CLAUDE.md` | Every session | Short, no restated defaults, three project-specific placeholders |
| `.claude/settings.json` | Every session | Small permissions allowlist, `autoCompactWindow`, hook registration |
| `.claude/hooks/filter-test-output.sh` | On matching `Bash` calls | Condenses pytest / npm test / jest / go test / cargo test output to failures + a summary |
| `docs/token-optimization-reference.md` | On demand | Verified notes on caching, model routing, data formats, context rot |
| `references/claude-cookbooks/` | On demand | Pruned snapshot of `anthropics/claude-cookbooks` (210MB → 9MB, relevant folders only) |
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

</details>

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

<div align="right"><a href="#top">⬆ back to top</a></div>

<br>

---

<a id="contributing"></a>

<div align="center">

MIT licensed. Fork it, prune it, make it yours. 🍴

</div>
