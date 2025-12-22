Work item: Add "Opencode" provider — Analysis & Implementation Plan
===================================================================

Goal
----
Add support for a new provider named "opencode" so users can set PROVIDER="opencode" (optionally with an argument like opencode:<id>) and use it the same way they use existing providers (claude, gemini, codex, ollama, copilot).

Files we'll change
------------------
- lib/providers.sh          (add validation, execution, info for opencode)
- spec/unit/providers_spec.sh (add unit tests for provider info and basic validation behavior)
- bin/gga                   (help text: list opencode in supported providers)

I don't need any additional files right now. The files you already added are sufficient for the initial implementation and tests.

1) Identify code to refactor
---------------------------
Primary changes live in lib/providers.sh:
- validate_provider(): add an "opencode" branch to ensure we provide a useful error message when required tooling is missing (or allow a curl fallback).
- execute_provider(): dispatch "opencode" to a new execute_opencode() function.
- Implement execute_opencode(): execute opencode-specific invocation (or call a local HTTP endpoint via curl if that's the intended integration).
- get_provider_info(): add a short human-friendly description for opencode.

Also:
- spec/unit/providers_spec.sh: add tests asserting get_provider_info includes "Opencode" and tests for validate_provider behavior that don't require external CLIs where possible.
- bin/gga: update help/config docs to include opencode in the provider list.

2) Dependencies and potential impacts
------------------------------------
- validate_provider() currently checks for provider CLIs and uses tools like curl for copilot. For opencode we must decide whether it has its own CLI or if we'll use a generic HTTP endpoint. To avoid hard dependency on a new binary, implement validation to accept either:
  - opencode CLI present (command -v opencode) OR
  - curl is available (command -v curl) and allow a curl-based execution path.
- If opencode integration requires auth, token handling must be added later (config or env vars).
- Tests: avoid asserting presence of external binaries. Keep unit tests limited to pure string-based functions (get_provider_info and parsing). If we need to test validate_provider we should either:
  - Mock command -v via a helper in the test harness, or
  - Only test that unknown providers fail (already covered), and add get_provider_info tests for opencode.

3) Refactoring plan (step-by-step)
----------------------------------
Step 0 — Confirm: you are OK for me to implement the changes described below.

Step 1 — Add provider dispatch & info
- In lib/providers.sh:
  - Add "opencode" to the top-level case in validate_provider(), following the style of 'copilot' (check for curl) and 'ollama' (model parsing).
  - Add "opencode" to execute_provider() dispatch, invoking execute_opencode.
  - Add get_provider_info() mapping for opencode.

Step 2 — Implement execute_opencode()
- Create execute_opencode() accepting either:
  - execute_opencode "<model_or_id>" "<prompt>"
  - or execute_opencode "<prompt>" (if no model)
- Implementation options:
  - If an 'opencode' CLI exists: echo "$prompt" | opencode [--some-flag]
  - Else if curl is available: POST the prompt to a configurable endpoint (env var or default localhost) and extract response similar to execute_copilot().
- Keep the implementation zero-dependency where possible (use curl + sed) and return 0 on success, non-zero on failure.

Step 3 — Add tests
- Update spec/unit/providers_spec.sh:
  - Add an It block checking get_provider_info "opencode" returns "Opencode" (or similar).
  - Avoid adding tests that require actual network or CLI presence.
- Optionally, extend provider base/model extraction tests if opencode accepts a colon argument (opencode:<id>).

Step 4 — Update CLI help
- Add "opencode" to provider list in bin/gga print_help (and any other user-facing text).

Step 5 — Run tests and iterate
- Run unit tests; if validate_provider tests need to check existence of curl/opencode binary, either mock such checks in tests or relax tests to only cover string parsing/info functions.
- If integration tests are added later, stub network calls to avoid flakiness.

4) Risks and breaking changes
-----------------------------
- Pattern collision / parsing: if opencode accepts provider strings with colons (opencode:<id>), ensure parsing logic (provider%%:*, provider#*: ) handles it consistently and doesn't conflict with ollama or copilot.
- Hard dependency on a new CLI/tool: avoid failing validate_provider for users who intend to use a curl-based integration. Prefer a fallback strategy (curl).
- Network-related flakiness: if execute_opencode uses HTTP, integration tests could become flaky. Prefer local stubs/mocks or only unit-test non-network logic.
- Help docs misalignment: remember to update user-facing help text (bin/gga) so help lists opencode.
- Cache collisions: if opencode returns or caches responses keyed by provider, ensure unique namespacing so opencode cache entries don't clash with other providers' cache keys.

Acceptance criteria checklist
----------------------------
- [ ] lib/providers.sh exports validate_provider and execute_provider behavior for opencode.
- [ ] execute_opencode implemented with a safe fallback (opencode CLI or curl).
- [ ] get_provider_info includes opencode.
- [ ] bin/gga help lists opencode in supported providers.
- [ ] spec/unit/providers_spec.sh updated to assert get_provider_info for opencode and any non-network parsing logic.

Next steps
----------
If you approve this plan I will:
- Edit lib/providers.sh to add validate_provider/execute_provider/get_provider_info changes and implement execute_opencode().
- Edit spec/unit/providers_spec.sh to add the minimal tests.
- Edit bin/gga help text.
I will produce small, focused SEARCH/REPLACE blocks for each file change.

Questions for you
-----------------
- Do you have a preferred integration pattern for Opencode? (native CLI, HTTP endpoint URL, or both)
- If HTTP, what is the default endpoint (e.g., localhost:4141 like copilot) or should it be configurable via environment variable?
- Does Opencode require authentication (API key/token)? If yes, how should that be supplied (env var or config)?

Please confirm and answer the questions above, or say "go ahead" to start implementing the changes described.
