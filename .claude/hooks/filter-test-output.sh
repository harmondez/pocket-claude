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

case "$command" in
  *pytest*|*"npm test"*|*"npm run test"*|*"yarn test"*|*jest*|*"go test"*|*"cargo test"*)
    awk_prog='{ total++; low=tolower($0); if (low ~ /fail|error|traceback|assertionerror|panic:|✕|✗/) { print; kept++ } } END { printf "\n[condensed: %d/%d lines shown]\n", kept+0, total }'
    modified_command="( $command ) 2>&1 | awk '$awk_prog'"
    jq -n --arg cmd "$modified_command" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        updatedInput: { command: $cmd }
      }
    }'
    ;;
  *)
    exit 0
    ;;
esac
