#!/bin/bash
# PreToolUse hook (Bash matcher). Rewrites common test-runner commands so
# their output is condensed to failure-indicating lines + a summary count
# BEFORE it ever reaches Claude's context.
#
# This has to be a PreToolUse hook, not PostToolUse: by the time a
# PostToolUse hook runs, the full command output is already committed to
# context and cannot be suppressed or replaced — only supplemented
# (verified against code.claude.com/docs/en/hooks). PreToolUse can rewrite
# tool_input.command via `updatedInput` before the command ever runs, so the
# condensing happens at the source instead.

# Requires jq. If it's missing, fail open (no filtering, command still runs
# unmodified) instead of breaking the session.
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

[[ -z "$command" ]] && exit 0

# What counts as a "test command" lives in test-patterns.txt, not here —
# one substring per line, so covering a new test runner is a data change,
# not a script change.
patterns_file="$(dirname "${BASH_SOURCE[0]}")/test-patterns.txt"
[[ -f "$patterns_file" ]] || exit 0

low_command=$(printf '%s' "$command" | tr '[:upper:]' '[:lower:]')
matched=0
while IFS= read -r pattern; do
  [[ -z "$pattern" || "$pattern" == \#* ]] && continue
  low_pattern=$(printf '%s' "$pattern" | tr '[:upper:]' '[:lower:]')
  if [[ "$low_command" == *"$low_pattern"* ]]; then
    matched=1
    break
  fi
done < "$patterns_file"

[[ "$matched" -eq 1 ]] || exit 0

awk_prog='{ total++; low=tolower($0); if (low ~ /fail|error|traceback|assertionerror|panic:|✕|✗/) { print; kept++ } } END { printf "\n[condensed: %d/%d lines shown]\n", kept+0, total }'
modified_command="( $command ) 2>&1 | awk '$awk_prog'"
jq -n --arg cmd "$modified_command" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    updatedInput: { command: $cmd }
  }
}'
