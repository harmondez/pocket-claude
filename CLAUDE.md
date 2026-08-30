# pocket-claude baseline

This is the pocket-claude template, dropped into this project's root to minimize
token spend while working with Claude Code (Sonnet, high effort). It intentionally
does not restate Claude Code's own default behavior (comment policy, error-handling
scope, avoiding premature abstraction, etc.) — repeating defaults here would just
burn tokens every session for no gain.

## Reference material — read on demand only

`references/` contains vendored snapshots of `anthropics/claude-cookbooks` and
`shanraisshan/claude-code-best-practice`. `docs/token-optimization-reference.md` is
a verified reference on token-saving techniques. None of this is meant to be loaded
wholesale. Before implementing something non-trivial involving hooks, agent
patterns, prompt caching, or context management, look up the specific file you
need in there — don't read the whole directory.

## Permissions and compaction

Tool permissions live in `.claude/settings.json`, not here. Don't change permission
rules mid-session — it invalidates the prompt cache. Grow the allowlist with the
`fewer-permission-prompts` skill as real prompts show up, rather than guessing a
long list upfront.

## Commands

<!-- fill per project, e.g.:
- Dev server: `npm run dev`
- Build: `npm run build`
- Lint: `npm run lint`
-->

## Architecture

<!-- fill per project — 2-3 lines on what isn't obvious from reading the
code, e.g.:
API lives in `src/api/`, business logic in `src/domain/`. Never import
from `api/` into `domain/`.
-->

## Testing

<!-- fill per project, e.g.:
`pytest`. Integration tests need `docker compose up -d db` first.
-->
