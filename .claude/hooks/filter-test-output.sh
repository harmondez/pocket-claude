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

# A pattern only counts if it sits outside any open quote — otherwise a
# command that merely *mentions* a test runner in a string argument (a git
# commit message, an echo, a sed replacement) gets misdetected as actually
# invoking one. Found in the wild: a heredoc commit message describing
# "dart test/flutter test" support tripped the old plain substring match
# and got wrapped, corrupting the rewritten command. Quote parity in the
# text before the match (odd count of " or ' = we're inside one) is a
# cheap, verified way to tell "invoking npm test" from "talking about npm
# test" apart without a real shell parser.
matched=$(awk -v cmd="$command" -v dq='"' -v sq="'" '
  BEGIN { c = tolower(cmd) }
  {
    pattern = $0
    if (pattern == "" || substr(pattern, 1, 1) == "#") next
    p = tolower(pattern)
    pos = index(c, p)
    if (pos == 0) next
    prefix = substr(c, 1, pos - 1)
    n = split(prefix, chars, "")
    dqcount = 0; sqcount = 0
    for (i = 1; i <= n; i++) {
      if (chars[i] == dq) dqcount++
      if (chars[i] == sq) sqcount++
    }
    if (dqcount % 2 == 1 || sqcount % 2 == 1) next
    print "yes"
    exit
  }
' "$patterns_file")

[[ "$matched" == "yes" ]] || exit 0

awk_prog='{ total++; low=tolower($0); if (low ~ /fail|error|traceback|assertionerror|panic:|✕|✗/) { print; kept++ } } END { printf "\n[condensed: %d/%d lines shown]\n", kept+0, total }'
modified_command="( $command ) 2>&1 | awk '$awk_prog'"
jq -n --arg cmd "$modified_command" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    updatedInput: { command: $cmd }
  }
}'
