#!/usr/bin/env bash

# ============================================================================
# Gentleman Guardian Angel - Provider Functions
# ============================================================================
# Handles execution for different AI providers:
# - claude: Anthropic Claude Code CLI
# - gemini: Google Gemini CLI
# - codex: OpenAI Codex CLI
# - ollama:<model>: Ollama with specified model
# - droid: Droid Factory CLI
# - copilot[:<model>]: GitHub Copilot via copilot-api proxy (default model: gpt-4o)
# ============================================================================

# Colors (in case sourced independently)
RED='\033[0;31m'
NC='\033[0m'

# Optional: load droid factory helper if present alongside other libs.
# When providers.sh is sourced in tests, BASH_SOURCE[0] will point to the lib path.
# Respect an externally provided LIB_DIR (e.g. by tests). Only compute it if unset.
: "${LIB_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
if [[ -f "$LIB_DIR/droid_factory.sh" ]]; then
  # shellcheck source=/dev/null
  source "$LIB_DIR/droid_factory.sh"
else
  # Also check a common installed location (e.g. ~/.local/share/gga/lib)
  installed_helper="${XDG_DATA_HOME:-$HOME/.local/share}/gga/lib/droid_factory.sh"
  if [[ -f "$installed_helper" ]]; then
    # shellcheck source=/dev/null
    source "$installed_helper"
  fi
fi

# ============================================================================
# Provider Validation
# ============================================================================

validate_provider() {
  local provider="$1"
  local base_provider="${provider%%:*}"

  case "$base_provider" in
    claude)
      if ! command -v claude &> /dev/null; then
        echo -e "${RED}❌ Claude CLI not found${NC}"
        echo ""
        echo "Install Claude Code CLI:"
        echo "  https://claude.ai/code"
        echo ""
        return 1
      fi
      ;;
    gemini)
      if ! command -v gemini &> /dev/null; then
        echo -e "${RED}❌ Gemini CLI not found${NC}"
        echo ""
        echo "Install Gemini CLI:"
        echo "  npm install -g @anthropic-ai/gemini-cli"
        echo "  # or"
        echo "  brew install gemini"
        echo ""
        return 1
      fi
      ;;
    codex)
      if ! command -v codex &> /dev/null; then
        echo -e "${RED}❌ Codex CLI not found${NC}"
        echo ""
        echo "Install OpenAI Codex CLI:"
        echo "  npm install -g @openai/codex"
        echo "  # or"
        echo "  brew install --cask codex"
        echo ""
        return 1
      fi
      ;;
    ollama)
      if ! command -v ollama &> /dev/null; then
        echo -e "${RED}❌ Ollama not found${NC}"
        echo ""
        echo "Install Ollama:"
        echo "  https://ollama.ai/download"
        echo "  # or"
        echo "  brew install ollama"
        echo ""
        return 1
      fi
      # Check if model is specified
      local model="${provider#*:}"
      if [[ "$model" == "$provider" || -z "$model" ]]; then
        echo -e "${RED}❌ Ollama requires a model${NC}"
        echo ""
        echo "Specify model in provider config:"
        echo "  PROVIDER=\"ollama:llama3.2\""
        echo "  PROVIDER=\"ollama:codellama\""
        echo ""
        return 1
      fi
      ;;
    droid)
      # Droid Factory can be provided either by a local `droid` CLI or by
      # a helper function (droid_factory_run) exposed via lib/droid_factory.sh.
      # If either is available we're good to go.
      if command -v droid &> /dev/null || type droid_factory_run &> /dev/null; then
        :
      else
        echo -e "${RED}❌ Droid CLI or droid factory helper not found${NC}"
        echo ""
        echo "Provide a way to run the Droid Factory provider:"
        echo "  1) Install a 'droid' CLI and ensure it is in PATH"
        echo "     (example install: https://example.com/droid)"
        echo ""
        echo "  2) Or include the helper script in your installation so"
        echo "     lib/droid_factory.sh is sourced by providers.sh (this"
        echo "     exposes droid_factory_run which can wrap any runtime)"
        echo ""
        return 1
      fi
      ;;
    copilot)
      if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl not found${NC}"
        echo ""
        echo "Install curl to use Copilot provider."
        echo ""
        return 1
      fi
      ;;
    *)
      echo -e "${RED}❌ Unknown provider: $provider${NC}"
      echo ""
      echo "Supported providers:"
      echo "  - claude"
      echo "  - gemini"
      echo "  - codex"
      echo "  - ollama:<model>"
      echo "  - droid"
      echo "  - copilot"
      echo ""
      return 1
      ;;
  esac

  return 0
}

# ============================================================================
# Provider Execution
# ============================================================================

execute_provider() {
  local provider="$1"
  local prompt="$2"
  local base_provider="${provider%%:*}"

  case "$base_provider" in
    claude)
      execute_claude "$prompt"
      ;;
    gemini)
      execute_gemini "$prompt"
      ;;
    codex)
      execute_codex "$prompt"
      ;;
    ollama)
      local model="${provider#*:}"
      execute_ollama "$model" "$prompt"
      ;;
    droid)
      execute_droid "$prompt"
      ;;
    copilot)
      local model="${provider#*:}"
      if [[ "$model" == "$provider" ]]; then
        model="gpt-4o" # Default model
      fi
      execute_copilot "$model" "$prompt"
      ;;
  esac
}

# ============================================================================
# Individual Provider Implementations
# ============================================================================

execute_claude() {
  local prompt="$1"
  
  # Claude CLI accepts prompt via stdin pipe
  echo "$prompt" | claude --print 2>&1
  return "${PIPESTATUS[1]}"
}

execute_gemini() {
  local prompt="$1"
  
  # Gemini CLI accepts prompt via stdin pipe or -p flag
  echo "$prompt" | gemini 2>&1
  return "${PIPESTATUS[1]}"
}

execute_codex() {
  local prompt="$1"
  
  # Codex uses exec subcommand for non-interactive mode
  # Using --output-last-message to get just the final response
  codex exec "$prompt" 2>&1
  return $?
}

execute_ollama() {
  local model="$1"
  local prompt="$2"
  
  # Ollama accepts prompt as argument after model name
  ollama run "$model" "$prompt" 2>&1
  return $?
}

execute_droid() {
  local prompt="$1"

  # If a dedicated helper is available use it (allows test/timeouts/custom handling)
  if type droid_factory_run &> /dev/null; then
    droid_factory_run "$prompt"
    return $?
  fi

  # Fallback: Droid Factory CLI accepts prompt via stdin
  echo "$prompt" | droid 2>&1
  return "${PIPESTATUS[1]}"
}

execute_copilot() {
  local model="$1"
  local prompt="$2"
  
  # Escape double quotes and backslashes in the prompt for JSON
  # This is a basic escaping, might need more robust handling for complex chars if strict JSON is required
  local escaped_prompt
  escaped_prompt=$(echo "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n')
  
  # Remove the last \n added by the loop above (optional, but cleaner)
  escaped_prompt=${escaped_prompt%\\n}

  # Call the local copilot-api proxy
  # Assuming default port 4141
  local response
  response=$(curl -s -X POST http://localhost:4141/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"$model\",
      \"messages\": [{\"role\": \"user\", \"content\": \"$escaped_prompt\"}]
    }")

  if [ $? -ne 0 ]; then
    echo "Error connecting to copilot-api. Is it running on port 4141?" >&2
    return 1
  fi

  # Extract content from JSON response using sed (zero dependency)
  # Strategy:
  # 1. Replace escaped quotes \" with a placeholder (control char \x01)
  # 2. Extract string between "content": " and the next "
  # 3. Restore escaped quotes
  # 4. Unescape newlines and backslashes
  
  local content
  content=$(echo "$response" | \
    sed 's/\\"/\x01/g' | \
    sed -n 's/.*"content": *"\([^"]*\)".*/\1/p' | \
    sed 's/\x01/\\"/g' | \
    sed 's/\\n/\n/g; s/\\\\/\\/g')
  
  echo "$content"
  
  return 0
}

# ============================================================================
# Provider Info
# ============================================================================

get_provider_info() {
  local provider="$1"
  local base_provider="${provider%%:*}"

  case "$base_provider" in
    claude)
      echo "Anthropic Claude Code CLI"
      ;;
    gemini)
      echo "Google Gemini CLI"
      ;;
    codex)
      echo "OpenAI Codex CLI"
      ;;
    ollama)
      local model="${provider#*:}"
      echo "Ollama (model: $model)"
      ;;
    droid)
      echo "Droid Factory CLI (or helper: lib/droid_factory.sh)"
      ;;
    copilot)
      local model="${provider#*:}"
      if [[ "$model" == "$provider" ]]; then
        model="gpt-4o"
      fi
      echo "GitHub Copilot (model: $model)"
      ;;
    *)
      echo "Unknown provider"
      ;;
  esac
}
