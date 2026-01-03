#!/usr/bin/env bash
# Droid Factory helper for Gentleman Guardian Angel
# Provides a thin wrapper around the `droid` CLI so providers.sh can
# delegate to a helper when present (easier to test/mocks/timeouts).
#
# Improvements:
# - Prefer a helper binary shipped alongside the lib (./droid) if present and executable
# - Fallback to a 'droid' binary in PATH
# - Use printf to avoid adding extra newlines
# - Preserve and return the exit status of the droid process reliably

# If this file is sourced multiple times, avoid redefining the function.
# When sourced as a script (not via `source`) the `return` would fail, so
# tolerate that with a fallback to continue execution.
if declare -f droid_factory_run > /dev/null; then
  return 0 2>/dev/null || true
fi

droid_factory_run() {
  local prompt="$1"

  # Determine directory of this helper (works when sourced)
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Prefer a helper executable located alongside the lib, then fall back to PATH
  local droid_cmd=""
  if [[ -x "$script_dir/droid" ]]; then
    droid_cmd="$script_dir/droid"
  elif command -v droid &> /dev/null; then
    droid_cmd="$(command -v droid)"
  else
    echo "Error: droid CLI not found (neither $script_dir/droid nor droid in PATH)" >&2
    return 1
  fi

  # Use a subshell with pipefail to reliably capture the exit status of the droid command.
  # Capture output so we can forward it and return the correct exit code.
  local output
  if output=$( ( set -o pipefail; printf '%s' "$prompt" | "$droid_cmd" ) 2>&1 ); then
    # Successful execution - print output to stdout and return 0
    printf '%s\n' "$output"
    return 0
  else
    # Failure - print output to stderr and return non-zero
    printf '%s\n' "$output" >&2
    return 1
  fi
}
