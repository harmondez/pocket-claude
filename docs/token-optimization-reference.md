# Token optimization reference

Verified reference material on reducing Claude / Claude Code token spend. Not
loaded automatically by `CLAUDE.md` — read specific sections here on demand.
Corrected from an initial deep-research draft; see "Corrections log" at the
bottom for what was wrong in that draft and why.

## Prompt caching (confirmed against official docs)

- Ephemeral, server-side cache keyed on exact byte-prefix match. Up to 4
  cache breakpoints per request; using all 4 leaves no slot for automatic
  caching.
- TTL: 5 min write (1.25x base price) or 1 hour write (2x base price), reads
  always 0.1x. Changing model, effort, denying a tool mid-session, or a CLI
  upgrade invalidates the cache.
- Tool schemas serialized from a dict/set in some languages (Swift, Go)
  randomize key order and silently break the cache — keep tool ordering
  deterministic.
- Layer static content first (tools → system prompt → stable
  docs/RAG context → dynamic conversation), and keep timestamps/UUIDs/user
  variables out of anything above a breakpoint.

## Model routing and current pricing (Aug 2026)

| Model | Input $/MTok | Output $/MTok |
|---|---|---|
| Claude Haiku 4.5 | $1.00 | $5.00 |
| Claude Sonnet 5 | $2.00 | $10.00 |
| Claude Opus 5 | $5.00 | $25.00 |

Route mechanical/high-volume subagent work (log parsing, grep-heavy search,
formatting) to Haiku; keep Sonnet as the default orchestrator; reserve Opus
for genuinely high-complexity architectural reasoning. Message Batches API
gives a flat 50% discount for async workloads with 24h turnaround.

**Caveat that matters more than the routing advice itself**: every subagent
invocation pays ~20,000-33,000 tokens of fixed startup overhead (its own
system prompt + tool definitions, re-paid fresh every call, no cache
inherited from the parent) *before* any real work happens. Measured directly
in this project: a trivial one-line-file-read subagent task cost 33,329
tokens end to end. Routing that subagent to Haiku only cuts the cost of that
overhead by roughly 30% — it does not remove the tokens. A documented real
case: a task that cost 121K tokens done directly cost 513K tokens fanned out
across 2 subagents. Net effect: a subagent (Haiku-routed or not) is a **net
loss** for anything smaller than the overhead itself — a single grep, one
file, a quick lookup. It only pays for itself on genuinely large volume
(tens of thousands of tokens of raw material, or 10+ files) that would cost
more read directly than the subagent's own startup cost.

## Context rot and compaction

Retrieval precision degrades as context fills up (Anthropic's own MRCR v2
eval shows a real drop from ~93% at 256K tokens to ~76% at 1M). Real,
documented settings.json/env-var controls:

- `autoCompactWindow` (settings.json key) — sets how full the context gets
  before Claude Code compacts. There is **no** env var called
  `CLAUDE_CODE_AUTO_COMPACT_WINDOW` — that name doesn't exist; use the
  settings.json key instead.
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (env var, confirmed real) — percentage
  (1-100) of the auto-compact window at which compaction triggers, applies
  to main conversation and subagents.
- `CLAUDE_CODE_DISABLE_1M_CONTEXT` (env var, confirmed real) — useful
  workaround when a proxy or integration misreports context window size and
  triggers compaction failures.

## CLAUDE.md and skills

- Keep CLAUDE.md short — every line is a recurring cost, loaded every
  session. Cut anything Claude can already infer, and anything the harness
  already enforces by default (comment policy, error-handling scope,
  premature-abstraction avoidance — Claude Code already does this natively,
  restating it wastes tokens for zero behavior change).
- Skills use progressive disclosure: only the frontmatter description is
  always in context; the SKILL.md body loads only when invoked. Keep
  SKILL.md itself under ~500 lines and push heavy reference material into
  separate files the skill links to — a real skill went from >200K tokens to
  ~25K just by moving inline content into referenced files.
- In monorepos, skills are discovered per nested directory
  (`packages/frontend/.claude/skills/`) and load on demand, not all at
  session start.

## Data formats: token cost of the wire format

Confirmed from real (if scattered) benchmarks — treat as directional ranges,
not fixed universal numbers:

- **XML is the worst option** for structured data exchange: ~14% more
  tokens than formatted JSON (directly confirmed), and clearly worse than
  Markdown/TOON in every source checked. Still fine for delimiting sections
  inside a prose prompt — that's a different use case.
- **YAML**: roughly 20-30% fewer tokens than JSON for nested/config data,
  depending on the dataset.
- **Markdown**: roughly 34-38% fewer tokens than JSON for nested, mostly
  textual data — good default for code summaries, directory trees, RAG
  context.
- **TOON** (Token-Oriented Object Notation): 40-60% fewer tokens than JSON
  specifically for uniform tabular data (schema declared once in a header,
  rows as pipe-separated values). Worse fit for deeply nested data.

## Tool-use minimalism

- Disconnect idle MCP servers with `/mcp` — each one costs its full schema
  every turn just by being connected, whether or not it's used.
- Prefer a native CLI (`gh`, `aws`, `gcloud`) over an MCP wrapper when both
  exist — the CLI only costs tokens during its own invocation.
- Redirect/paginate noisy commands (`| tail -100`, `> out.txt`) instead of
  letting raw log dumps hit context.

## Neural prompt compression (LLMLingua family) — know the limits

Real Microsoft Research (arXiv 2310.05736, EMNLP'23), genuinely achieves
large compression ratios with low degradation **on the specific benchmarks
it was measured on** (e.g. GSM8K), but degradation is much larger on others
(BBH: 8.5-13 points, not "<2% universally"). More importantly: it requires
running an auxiliary local model (BERT or a 7B-class LLM) to score token
perplexity. That's real infrastructure, not a drop-in technique for an
individual Claude Code user without dedicated compute — treat this family as
enterprise/RAG-pipeline tooling, not something to bolt onto a personal
project template.

## Third-party tools — use with caution, never as a default dependency

Several community tools (test-output filters, terminal interceptors, local
compression proxies) are real, maintained, and do what they claim. But any
tool that proxies or intercepts your Claude Code traffic is inherently more
attack surface than a native Claude Code mechanism (hooks, settings.json,
skills) — a compromised maintainer or a bad update affects everything that
passes through it. If you ever consider one: read the source, pin to a
specific commit/release, and prefer the native equivalent first. This
reference intentionally does not vendor or auto-install any of them.

## Corrections log (from the original deep-research draft)

- Pricing was for Sonnet 3.5 / an older Opus generation (~2 generations
  stale) — replaced with current Aug-2026 pricing above.
- A claimed "precision drop from 52.7% to 44.4% with XML" was fabricated by
  merging two unrelated table cells from the source (52.7% was JSON accuracy
  on Llama 3.2 3B; 44.4% was XML accuracy on a different model, GPT-5 Nano) —
  removed, no causal XML-degrades-accuracy number is asserted here.
- A "Px-Render" image-rendering feature was misattributed to one proxy tool;
  the real feature belongs to a different, unrelated project — dropped
  entirely rather than re-attributed, since it's not being recommended here.
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` does not exist as an env var — replaced
  with the real `autoCompactWindow` settings.json key.
- The "<2% degradation" LLMLingua claim was a single-benchmark result
  generalized as universal — noted as benchmark-dependent above.
