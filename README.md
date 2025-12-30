<p align="center">
  <img src="https://img.shields.io/badge/version-2.2.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
  <img src="https://img.shields.io/badge/bash-5.0%2B-orange.svg" alt="Bash">
  <img src="https://img.shields.io/badge/homebrew-tap-FBB040.svg" alt="Homebrew">
  <img src="https://img.shields.io/badge/tests-68%20passing-brightgreen.svg" alt="Tests">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome">
</p>

<h1 align="center">🤖 Gentleman Guardian Angel</h1>

<p align="center">
  <strong>Provider-agnostic code review using AI</strong><br>
  Use Claude, Gemini, Codex, Ollama, or any AI to enforce your coding standards.<br>
  Zero dependencies. Pure Bash. Works everywhere.
</p>

<p align="center">
  <a href="#-installation">Installation</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-providers">Providers</a> •
  <a href="#-commands">Commands</a> •
  <a href="#-configuration">Configuration</a> •
  <a href="#-smart-caching">Caching</a> •
  <a href="#-development">Development</a>
</p>

---

## Example

<img width="962" height="941" alt="image" src="https://github.com/user-attachments/assets/c8963dff-6aa5-420c-b58b-1416e81af384" />

## 🎯 Why?

You have coding standards. Your team ignores them. Code reviews catch issues too late.

**Gentleman Guardian Angel** runs on every commit, validating your staged files against your project's `REVIEW.md` (or any rules file). It's like having a senior developer review every line before it hits the repo.

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   git commit    │ ──▶ │  AI Review   │ ──▶ │  ✅ Pass/Fail   │
│  (staged files) │     │  (any LLM)   │     │  (with details) │
└─────────────────┘     └──────────────┘     └─────────────────┘
```

**Key features:**
- 🔌 **Provider agnostic** - Use whatever AI you have installed
- 📦 **Zero dependencies** - Pure Bash, no Node/Python/Go required
- 🪝 **Git native** - Installs as a standard pre-commit hook
- ⚙️ **Highly configurable** - File patterns, exclusions, custom rules
- 🚨 **Strict mode** - Fail CI on ambiguous responses
- ⚡ **Smart caching** - Skip unchanged files for faster reviews
- 🍺 **Homebrew ready** - One command install

---

## 📦 Installation

### Homebrew (Recommended) 🍺

```bash
brew tap gentleman-programming/tap
brew install gga
```

Or in a single command:

```bash
brew install gentleman-programming/tap/gga
```

### Manual Installation

```bash
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
cd gga
./install.sh
```

### Verify Installation

```bash
gga version
# Output: gga v2.2.0
```

---

## 🚀 Quick Start

```bash
# 1. Go to your project
cd ~/your-project

# 2. Initialize config
gga init

# 3. Create your rules file
touch REVIEW.md  # Add your coding standards

# 4. Install the git hook
gga install

# 5. Done! Now every commit gets reviewed 🎉
```

---

## 🎬 Real World Example

Let's walk through a complete example from setup to commit:

### Step 1: Setup in your project

```bash
$ cd ~/projects/my-react-app

$ gga init

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Gentleman Guardian Angel v2.2.0
  Provider-agnostic code review using AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Created config file: .gga

ℹ️  Next steps:
  1. Edit .gga to set your preferred provider
  2. Create REVIEW.md with your coding standards
  3. Run: gga install
```

### Step 2: Configure your provider

```bash
$ cat .gga

# AI Provider (required)
PROVIDER="claude"

# File patterns to include in review (comma-separated)
FILE_PATTERNS="*.ts,*.tsx,*.js,*.jsx"

# File patterns to exclude from review (comma-separated)
EXCLUDE_PATTERNS="*.test.ts,*.spec.ts,*.test.tsx,*.spec.tsx,*.d.ts"

# File containing code review rules
RULES_FILE="REVIEW.md"

# Strict mode: fail if AI response is ambiguous
STRICT_MODE="true"
```

### Step 3: Create your coding standards

```bash
$ cat > REVIEW.md << 'EOF'
# Code Review Rules

## TypeScript
- No `any` types - use proper typing
- Use `const` over `let` when possible
- Prefer interfaces over type aliases for objects

## React  
- Use functional components with hooks
- No `import * as React` - use named imports like `import { useState }`
- All images must have alt text for accessibility

## Styling
- Use Tailwind CSS utilities only
- No inline styles or CSS-in-JS
- No hardcoded colors - use design system tokens
EOF
```

### Step 4: Install the git hook

```bash
$ gga install

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Gentleman Guardian Angel v2.2.0
  Provider-agnostic code review using AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Installed pre-commit hook: /Users/dev/projects/my-react-app/.git/hooks/pre-commit
```

### Step 5: Make some changes and commit

```bash
$ git add src/components/Button.tsx
$ git commit -m "feat: add new button component"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Gentleman Guardian Angel v2.2.0
  Provider-agnostic code review using AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Provider: claude
ℹ️  Rules file: REVIEW.md
ℹ️  File patterns: *.ts,*.tsx,*.js,*.jsx
ℹ️  Cache: enabled

Files to review:
  - src/components/Button.tsx

ℹ️  Sending to claude for review...

STATUS: FAILED

Violations found:

1. **src/components/Button.tsx:3** - TypeScript Rule
   - Issue: Using `any` type for props
   - Fix: Define proper interface for ButtonProps

2. **src/components/Button.tsx:15** - React Rule  
   - Issue: Using `import * as React`
   - Fix: Use `import { useState, useCallback } from 'react'`

3. **src/components/Button.tsx:22** - Styling Rule
   - Issue: Hardcoded color `#3b82f6`
   - Fix: Use Tailwind class `bg-blue-500` instead

❌ CODE REVIEW FAILED

Fix the violations listed above before committing.
```

### Step 6: Fix issues and commit again

```bash
$ git add src/components/Button.tsx
$ git commit -m "feat: add new button component"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Gentleman Guardian Angel v2.2.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Provider: claude
ℹ️  Cache: enabled

Files to review:
  - src/components/Button.tsx

ℹ️  Sending to claude for review...

STATUS: PASSED

All files comply with the coding standards defined in REVIEW.md.

✅ CODE REVIEW PASSED

[main 4a2b3c1] feat: add new button component
 1 file changed, 45 insertions(+)
 create mode 100644 src/components/Button.tsx
```

---

## 📋 Commands

| Command | Description | Example |
|---------|-------------|---------|
| `init` | Create sample `.gga` config file | `gga init` |
| `install` | Install git pre-commit hook in current repo | `gga install` |
| `uninstall` | Remove git pre-commit hook from current repo | `gga uninstall` |
| `run` | Run code review on staged files | `gga run` |
| `run --no-cache` | Run review ignoring cache | `gga run --no-cache` |
| `config` | Display current configuration and status | `gga config` |
| `cache status` | Show cache status for current project | `gga cache status` |
| `cache clear` | Clear cache for current project | `gga cache clear` |
| `cache clear-all` | Clear all cached data | `gga cache clear-all` |
| `help` | Show help message with all commands | `gga help` |
| `version` | Show installed version | `gga version` |

### Command Details

#### `gga init`

Creates a sample `.gga` configuration file in your project root with sensible defaults.

```bash
$ gga init
✅ Created config file: .gga
```

#### `gga install`

Installs a git pre-commit hook that automatically runs code review on every commit.

```bash
$ gga install
✅ Installed pre-commit hook: .git/hooks/pre-commit
```

If a pre-commit hook already exists, it will ask if you want to append to it.

#### `gga uninstall`

Removes the git pre-commit hook from your repository.

```bash
$ gga uninstall
✅ Removed pre-commit hook
```

#### `gga run [--no-cache]`

Runs code review on currently staged files. Uses intelligent caching by default to skip unchanged files.

```bash
$ git add src/components/Button.tsx
$ gga run
# Reviews the staged file (uses cache)

$ gga run --no-cache
# Forces review of all files, ignoring cache
```

#### `gga config`

Shows the current configuration, including where config files are loaded from and all settings.

```bash
$ gga config

Current Configuration:

Config Files:
  Global:  Not found
  Project: .gga

Values:
  PROVIDER:          claude
  FILE_PATTERNS:     *.ts,*.tsx,*.js,*.jsx
  EXCLUDE_PATTERNS:  *.test.ts,*.spec.ts
  RULES_FILE:        REVIEW.md
  STRICT_MODE:       true

Rules File: Found
```

---

## ⚡ Smart Caching

GGA includes intelligent caching to speed up reviews by skipping files that haven't changed.

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cache Logic                               │
├─────────────────────────────────────────────────────────────────┤
│  1. Hash REVIEW.md + .gga config                                │
│     └─► If changed → Invalidate ALL cache                       │
│                                                                  │
│  2. For each staged file:                                        │
│     └─► Hash file content                                        │
│         └─► If hash exists in cache with PASSED → Skip          │
│         └─► If not cached → Send to AI for review               │
│                                                                  │
│  3. After PASSED review:                                         │
│     └─► Store file hash in cache                                │
└─────────────────────────────────────────────────────────────────┘
```

### Cache Invalidation

The cache automatically invalidates when:

| Change | Effect |
|--------|--------|
| File content changes | Only that file is re-reviewed |
| `REVIEW.md` changes | **All files** are re-reviewed |
| `.gga` config changes | **All files** are re-reviewed |

### Cache Commands

```bash
# Check cache status
$ gga cache status

Cache Status:

  Cache directory: ~/.cache/gga/a1b2c3d4...
  Cache validity: Valid
  Cached files: 12
  Cache size: 4.0K

# Clear project cache
$ gga cache clear
✅ Cleared cache for current project

# Clear all cache (all projects)
$ gga cache clear-all
✅ Cleared all cache data
```

### Bypass Cache

```bash
# Force review all files, ignoring cache
gga run --no-cache
```

### Cache Location

```
~/.cache/gga/
├── <project-hash-1>/
│   ├── metadata          # Hash of REVIEW.md + .gga
│   └── files/
│       ├── <file-hash-a> # "PASSED"
│       └── <file-hash-b> # "PASSED"
└── <project-hash-2>/
    └── ...
```

---

## 🔌 Providers

Use whichever AI CLI you have installed:

| Provider | Config Value | CLI Command Used | Installation |
|----------|-------------|------------------|--------------|
| **Claude** | `claude` | `echo "prompt" \| claude --print` | [claude.ai/code](https://claude.ai/code) |
| **Gemini** | `gemini` | `echo "prompt" \| gemini` | [github.com/google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) |
| **Codex** | `codex` | `codex exec "prompt"` | `npm i -g @openai/codex` |
| **Ollama** | `ollama:<model>` | `ollama run <model> "prompt"` | [ollama.ai](https://ollama.ai) |

### Provider Examples

```bash
# Use Claude (recommended - most reliable)
PROVIDER="claude"

# Use Google Gemini
PROVIDER="gemini"

# Use OpenAI Codex
PROVIDER="codex"

# Use Ollama with Llama 3.2
PROVIDER="ollama:llama3.2"

# Use Ollama with CodeLlama (optimized for code)
PROVIDER="ollama:codellama"

# Use Ollama with Qwen Coder
PROVIDER="ollama:qwen2.5-coder"

# Use Ollama with DeepSeek Coder
PROVIDER="ollama:deepseek-coder"
```

---

## ⚙️ Configuration

### Config File: `.gga`

Create this file in your project root:

```bash
# AI Provider (required)
# Options: claude, gemini, codex, ollama:<model>
PROVIDER="claude"

# File patterns to review (comma-separated globs)
# Default: * (all files)
FILE_PATTERNS="*.ts,*.tsx,*.js,*.jsx"

# Patterns to exclude from review (comma-separated globs)
# Default: none
EXCLUDE_PATTERNS="*.test.ts,*.spec.ts,*.d.ts"

# File containing your coding standards
# Default: REVIEW.md
RULES_FILE="REVIEW.md"

# Fail if AI response is ambiguous (recommended for CI)
# Default: true
STRICT_MODE="true"
```

### Configuration Options

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `PROVIDER` | ✅ Yes | - | AI provider to use |
| `FILE_PATTERNS` | No | `*` | Comma-separated file patterns to include |
| `EXCLUDE_PATTERNS` | No | - | Comma-separated file patterns to exclude |
| `RULES_FILE` | No | `REVIEW.md` | Path to your coding standards file |
| `STRICT_MODE` | No | `true` | Fail on ambiguous AI responses |

### Config Hierarchy (Priority Order)

1. **Environment variable** `GGA_PROVIDER` (highest priority)
2. **Project config** `.gga` (in project root)
3. **Global config** `~/.config/gga/config` (lowest priority)

```bash
# Override provider for a single run
GGA_PROVIDER="gemini" gga run

# Or export for the session
export GGA_PROVIDER="ollama:llama3.2"
```

---

## 📝 Rules File (REVIEW.md)

The AI needs to know your standards. Create an `REVIEW.md` file:

```markdown
# Code Review Rules

## TypeScript
- Use `const` and `let`, never `var`
- No `any` types - always use proper typing
- Prefer interfaces over type aliases for objects
- Use optional chaining (`?.`) and nullish coalescing (`??`)

## React
- Functional components only, no class components
- No `import * as React` - use named imports
- Use semantic HTML elements
- All images need alt text
- Interactive elements need aria labels

## Styling
- Use Tailwind CSS utilities
- No inline styles
- No hex colors - use design tokens

## Testing
- All new features need tests
- Test files must be co-located with source files
- Use descriptive test names that explain the behavior
```

> 💡 **Pro tip**: Your `REVIEW.md` can also serve as documentation for human reviewers!

---

## 🎨 Project Examples

### TypeScript/React Project

```bash
# .gga
PROVIDER="claude"
FILE_PATTERNS="*.ts,*.tsx"
EXCLUDE_PATTERNS="*.test.ts,*.test.tsx,*.spec.ts,*.d.ts,*.stories.tsx"
RULES_FILE="REVIEW.md"
```

### Python Project

```bash
# .gga
PROVIDER="ollama:codellama"
FILE_PATTERNS="*.py"
EXCLUDE_PATTERNS="*_test.py,test_*.py,conftest.py,__pycache__/*"
RULES_FILE=".coding-standards.md"
```

### Go Project

```bash
# .gga
PROVIDER="gemini"
FILE_PATTERNS="*.go"
EXCLUDE_PATTERNS="*_test.go,mock_*.go,*_mock.go"
```

### Full-Stack Monorepo

```bash
# .gga
PROVIDER="claude"
FILE_PATTERNS="*.ts,*.tsx,*.py,*.go"
EXCLUDE_PATTERNS="*.test.*,*_test.*,*.mock.*,*.d.ts,dist/*,build/*"
```

---

## 🔄 How It Works

```
git commit -m "feat: add feature"
    │
    ▼
┌───────────────────────────────────────┐
│  Pre-commit Hook (gga run) │
└───────────────────────────────────────┘
    │
    ├──▶ 1. Load config from .gga
    │
    ├──▶ 2. Validate provider is installed
    │
    ├──▶ 3. Check REVIEW.md exists
    │
    ├──▶ 4. Get staged files matching FILE_PATTERNS
    │       (excluding EXCLUDE_PATTERNS)
    │
    ├──▶ 5. Read coding rules from REVIEW.md
    │
    ├──▶ 6. Build prompt: rules + file contents
    │
    ├──▶ 7. Send to AI provider (claude/gemini/codex/ollama)
    │
    └──▶ 8. Parse response
            │
            ├── "STATUS: PASSED" ──▶ ✅ Commit proceeds
            │
            └── "STATUS: FAILED" ──▶ ❌ Commit blocked
                                       (shows violation details)
```

---

## 🚫 Bypass Review

Sometimes you need to commit without review:

```bash
# Skip pre-commit hook entirely
git commit --no-verify -m "wip: work in progress"

# Short form
git commit -n -m "hotfix: urgent fix"
```

---

## 🔗 Integrations

Gentleman Guardian Angel works standalone with native git hooks, but you can also integrate it with popular hook managers.

### Native Git Hook (Default)

This is what `gga install` does automatically:

```bash
# .git/hooks/pre-commit
#!/usr/bin/env bash
gga run || exit 1
```

### Husky (Node.js projects)

[Husky](https://typicode.github.io/husky/) is popular in JavaScript/TypeScript projects.

#### Setup with Husky v9+

```bash
# Install husky
npm install -D husky

# Initialize husky
npx husky init
```

Edit `.husky/pre-commit`:

```bash
#!/usr/bin/env bash

# Run Gentleman Guardian Angel
gga run || exit 1

# Your other checks (optional)
npm run lint
npm run typecheck
```

#### With lint-staged (review only staged files)

```bash
# Install dependencies
npm install -D husky lint-staged
```

`package.json`:
```json
{
  "scripts": {
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

`.husky/pre-commit`:
```bash
#!/usr/bin/env bash

# AI Review first (uses git staged files internally)
gga run || exit 1

# Then lint-staged for formatting
npx lint-staged
```

### pre-commit (Python projects)

[pre-commit](https://pre-commit.com/) is the standard for Python projects.

#### Setup

```bash
# Install pre-commit
pip install pre-commit

# Or with brew
brew install pre-commit
```

Create `.pre-commit-config.yaml`:

```yaml
repos:
  # Gentleman Guardian Angel (runs first)
  - repo: local
    hooks:
      - id: gga
        name: Gentleman Guardian Angel
        entry: gga run
        language: system
        pass_filenames: false
        stages: [pre-commit]

  # Your other hooks
  - repo: https://github.com/psf/black
    rev: 24.4.2
    hooks:
      - id: black

  - repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
      - id: flake8

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy
```

Install the hooks:

```bash
pre-commit install
```

#### Running manually

```bash
# Run all hooks
pre-commit run --all-files

# Run only AI review
pre-commit run gga
```

### Lefthook (Fast, language-agnostic)

[Lefthook](https://github.com/evilmartians/lefthook) is a fast Git hooks manager written in Go.

#### Setup

```bash
# Install
brew install lefthook

# Or with npm
npm install -D lefthook
```

Create `lefthook.yml`:

```yaml
pre-commit:
  parallel: false
  commands:
    ai-review:
      run: gga run
      fail_text: "Gentleman Guardian Angel failed. Fix violations before committing."

    lint:
      glob: "*.{ts,tsx,js,jsx}"
      run: npm run lint

    typecheck:
      run: npm run typecheck
```

Install hooks:

```bash
lefthook install
```

### CI/CD Integration

You can also run Gentleman Guardian Angel in your CI pipeline:

#### GitHub Actions

```yaml
# .github/workflows/ai-review.yml
name: Gentleman Guardian Angel

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Install Gentleman Guardian Angel
        run: |
          git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git /tmp/gga
          chmod +x /tmp/gga/bin/gga
          echo "/tmp/gga/bin" >> $GITHUB_PATH

      - name: Install Claude CLI
        run: |
          # Install your preferred provider CLI
          npm install -g @anthropic-ai/claude-code
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

      - name: Run AI Review
        run: |
          # Get changed files in PR
          git diff --name-only origin/${{ github.base_ref }}...HEAD > /tmp/changed_files.txt
          
          # Stage them for review
          cat /tmp/changed_files.txt | xargs git add
          
          # Run review
          gga run
```

#### GitLab CI

```yaml
# .gitlab-ci.yml
gga:
  stage: test
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y git curl
    - git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git /opt/gga
    - export PATH="/opt/gga/bin:$PATH"
    # Install your provider CLI here
  script:
    - git diff --name-only $CI_MERGE_REQUEST_DIFF_BASE_SHA | xargs git add
    - gga run
  only:
    - merge_requests
```

---

## 🐛 Troubleshooting

### "Provider not found"

```bash
# Check if your provider CLI is installed and in PATH
which claude   # Should show: /usr/local/bin/claude or similar
which gemini
which codex
which ollama

# Test if the provider works
echo "Say hello" | claude --print
```

### "Rules file not found"

The tool requires a rules file to know what to check:

```bash
# Create your rules file
touch REVIEW.md

# Add your coding standards
echo "# My Coding Standards" > REVIEW.md
echo "- No console.log in production" >> REVIEW.md
```

### "Ambiguous response" in Strict Mode

The AI must respond with `STATUS: PASSED` or `STATUS: FAILED` as the first line. If it doesn't:

1. Try Claude (most reliable at following instructions)
2. Check your rules file isn't confusing the AI
3. Temporarily disable strict mode: `STRICT_MODE="false"`

### Slow reviews on large files

The tool sends full file contents. For better performance:

```bash
# Add large/generated files to exclude
EXCLUDE_PATTERNS="*.min.js,*.bundle.js,dist/*,build/*,*.generated.ts"
```

---

## 🧪 Development

### Project Structure

```
gentleman-guardian-angel/
├── bin/
│   └── gga                    # Main CLI script
├── lib/
│   ├── providers.sh           # AI provider implementations
│   └── cache.sh               # Smart caching logic
├── spec/                      # ShellSpec test suite
│   ├── spec_helper.sh         # Test setup and helpers
│   ├── unit/
│   │   ├── cache_spec.sh      # Cache unit tests (27 tests)
│   │   └── providers_spec.sh  # Provider unit tests (13 tests)
│   └── integration/
│       └── commands_spec.sh   # CLI integration tests (28 tests)
├── Makefile                   # Development commands
├── .shellspec                 # Test runner config
├── install.sh                 # Manual installer
├── uninstall.sh               # Uninstaller
└── README.md
```

### Running Tests

GGA uses [ShellSpec](https://shellspec.info/) for testing - a BDD-style testing framework for shell scripts.

```bash
# Install dependencies (once)
brew install shellspec shellcheck

# Run all tests (68 total)
make test

# Run specific test suites
make test-unit        # Unit tests only (40 tests)
make test-integration # Integration tests only (28 tests)

# Lint shell scripts with shellcheck
make lint

# Run all checks before commit (lint + tests)
make check
```

### Test Coverage

| Module | Tests | Description |
|--------|-------|-------------|
| `cache.sh` | 27 | Hash functions, cache validation, file caching |
| `providers.sh` | 13 | Provider parsing, validation, info display |
| CLI commands | 28 | init, install, uninstall, run, config, cache |
| **Total** | **68** | Full coverage of core functionality |

### Adding New Tests

```bash
# Create a new spec file
touch spec/unit/my_feature_spec.sh

# Run only your new tests
shellspec spec/unit/my_feature_spec.sh
```

---

## 📋 Changelog

### v2.2.0 (Latest)
- ✅ Added comprehensive test suite with **68 tests**
- ✅ Unit tests for `cache.sh` and `providers.sh`
- ✅ Integration tests for all CLI commands
- ✅ Added `Makefile` with `test`, `lint`, `check` targets
- ✅ Fixed shellcheck warnings

### v2.1.0
- ✅ Smart caching system - skip unchanged files
- ✅ Auto-invalidation when REVIEW.md or .gga changes
- ✅ Cache commands: `status`, `clear`, `clear-all`
- ✅ `--no-cache` flag to bypass caching

### v2.0.0
- ✅ Renamed to Gentleman Guardian Angel (gga)
- ✅ Auto-migration from legacy `ai-code-review` hooks
- ✅ Homebrew tap distribution

### v1.0.0
- ✅ Initial release with Claude, Gemini, Codex, Ollama support
- ✅ File patterns and exclusions
- ✅ Strict mode for CI/CD

---

## 🤝 Contributing

Contributions are welcome! Some ideas:

- [ ] Add more providers (Copilot, Codeium, etc.)
- [ ] Support for `.gga.yaml` format  
- [x] ~~Caching to avoid re-reviewing unchanged files~~ ✅ Done in v2.1.0
- [x] ~~Add test suite~~ ✅ Done in v2.2.0
- [ ] GitHub Action version
- [ ] Output formats (JSON, SARIF for IDE integration)

```bash
# Fork, clone, and submit PRs!
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
cd gentleman-guardian-angel

# Run tests before submitting
make check
```

---

## 📄 License

MIT © 2024

---

<p align="center">
  <sub>Built with 🧉 by developers who got tired of repeating the same code review comments</sub>
</p>
