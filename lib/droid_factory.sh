#!/usr/bin/env bash
# Droid Factory helper for Gentleman Guardian Angel
# Provides a thin wrapper around the `droid` CLI so providers.sh can
# delegate to a helper when present (easier to test/mocks/timeouts).

droid_factory_run() {
  local prompt="$1"

  if ! command -v droid &> /dev/null; then
    echo "Error: droid CLI not found in PATH" >&2
    return 1
  fi

  # Pass prompt via stdin to the droid CLI and forward output.
  # Preserve exit code from the droid binary.
  echo "$prompt" | droid 2>&1
  return "${PIPESTATUS[1]}"
}
