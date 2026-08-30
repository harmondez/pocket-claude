# pocket-claude

A personal baseline template for Claude Code. Drop it into any new project
and it does one job: keep token spend per session as low as possible without
touching answer quality, assuming Sonnet at high effort.

> Only `CLAUDE.md` ever loads automatically. Everything else in this repo —
> reference docs, vendored cookbooks — is read on demand, a single file at a
> time, never the whole directory. That's the whole design in one sentence.

---

## Install

### 1. Get a local copy of pocket-claude, once

Clone it somewhere permanent on your machine — this is the copy you'll pull
from every time you start a new project, not something you re-clone per
project.

```bash
git clone https://github.com/harmondez/pocket-claude.git ~/pocket-claude
```

### 2. Drop it into a new project

From the root of a new (or existing) project:

```bash
cp -r ~/pocket-claude/CLAUDE.md ~/pocket-claude/.claude ~/pocket-claude/docs ~/pocket-claude/references .
```

That's it — `CLAUDE.md` and `.claude/` now sit at your project root, right
where Claude Code looks for them.

### 3. Fill in the three placeholders

Open `CLAUDE.md` and fill in `Commands`, `Architecture`, and `Testing` for
*this* project. They ship empty on purpose — a generic template shouldn't
guess at project-specific detail.

### 4. Make sure `jq` is installed

The test-output hook needs it. If it's missing the hook just fails open (no
filtering, nothing breaks) — so this step is easy to skip and only notice
later.

| OS | Command |
|---|---|
| Windows | `winget install jqlang.jq` |
| macOS | `brew install jq` |
| Debian / Ubuntu | `apt install jq` |

Done. Open Claude Code in the project and go.

---

## What's inside

| Path | Loads | Purpose |
|---|---|---|
| `CLAUDE.md` | Every session | Short, no restated defaults, three project-specific placeholders |
| `.claude/settings.json` | Every session | Small permissions allowlist, `autoCompactWindow`, hook registration |
| `.claude/hooks/filter-test-output.sh` | On matching `Bash` calls | Condenses pytest / npm test / jest / go test / cargo test output to failures + a summary |
| `docs/token-optimization-reference.md` | On demand | Verified notes on caching, model routing, data formats, context rot |
| `references/claude-cookbooks/` | On demand | Pruned snapshot of `anthropics/claude-cookbooks` (13MB → relevant folders only) |
| `references/claude-code-best-practice/` | On demand | Pruned snapshot of `shanraisshan/claude-code-best-practice` |

**On demand** means: don't read the directory, read the one file you
actually need, only when a task calls for it (writing a hook, tuning
caching, designing an agent pattern). Loading any of it wholesale defeats
the point of the whole repo.

---

<details>
<summary><strong>Permissions</strong></summary>

`.claude/settings.json` ships with a small, honest allowlist — a handful of
read-only git inspection commands — instead of a long speculative one. Grow
it per project with the `fewer-permission-prompts` skill as real prompts
actually show up, rather than guessing upfront.

Don't edit permission rules mid-session: it invalidates the prompt cache.

</details>

<details>
<summary><strong>Why <code>.claude-example/</code> instead of <code>.claude/</code> inside references</strong></summary>

Both vendored repos ship their own example `.claude/` configs — demo agents,
skills, hooks (some genuinely useful patterns, e.g. the cookbook's own
`pre-bash.sh` hook). Every nested `.claude/` found inside `references/` was
renamed to `.claude-example/` so it can never be picked up as live config by
Claude Code in a project that has this template copied in. The content is
still there to read; it's just inert.

</details>

<details>
<summary><strong>Refreshing <code>references/</code></strong></summary>

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
<summary><strong>Explicitly out of scope for v1</strong></summary>

No custom subagents, no custom skills, no per-stack modular rules
(`.claude/rules/`). These get added later, per project, when a real need
shows up — not speculatively now.

</details>
