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

  # Pass prompt via stdin to the droid CLI and forward output.
  # Preserve exit code from the droid binary.
  printf '%s' "$prompt" | "$droid_cmd" 2>&1
  local status=${PIPESTATUS[1]:-1}
  return $status
}
