I need a bit more information before making code changes for "Agregar opencode".

Summary of what I see so far:
- lib/providers.sh already contains support for "opencode" (validate_provider, execute_opencode, get_provider_info).
- bin/gga references opencode in help/config text.
- spec/unit/providers_spec.sh already contains a test that checks get_provider_info includes "Opencode".

Possible causes for the bug "Agregar opencode":
1. The CI/tests are failing because the actual opencode binary has a different name (e.g. opencode-cli), so validate_provider incorrectly reports missing CLI.
2. Tests expect different wording or behavior (e.g. get_provider_info should return "Opencode" instead of "Opencode CLI").
3. The provider is listed in some places but not routed in execute_provider (not the case in current code).
4. A subtle quoting/return-value bug in execute_opencode or validate_provider that only surfaces in some environments.

Questions / Clarifications:
1. What is the observable failure? (Please paste failing test output, error messages, or describe the behavior you see.)
2. Should validate_provider accept both "opencode" and "opencode-cli" as the executable name? If you know the real CLI binary name, which is it?
3. Do you want the user-facing provider name to be "Opencode" or "Opencode CLI" (affects get_provider_info and tests)?
4. Are there any other places (docs, README, install scripts) you want updated as part of this work item?

Proposed minimal fixes (pick one or more):
A. If the CLI binary name varies: Update validate_provider to check for either "opencode" or "opencode-cli" (non-breaking).
B. If tests expect a different get_provider_info string: Adjust get_provider_info to match tests (or update tests).
C. If parsing/return-value is flaky: Normalize execute_opencode to capture and return the correct exit code (use local PIPESTATUS handling consistently).

Next steps after you reply:
- If you provide the failing output or confirm which option you prefer, I will produce precise SEARCH/REPLACE edits to the affected files (lib/providers.sh and possibly spec/unit/providers_spec.sh and bin/gga).
- If you prefer I choose a safe, backward-compatible option, I can implement option A + small robustness improvements (check for either executable name; ensure execute_opencode returns numeric exit code robustly) and update tests if needed.

Please respond with the failing output or which option you want me to implement.
