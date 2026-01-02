#!/usr/bin/env bash

# ============================================================================
# Gentleman Guardian Angel - Provider Functions
# ============================================================================
# Handles execution for different AI providers:
# - claude: Anthropic Claude Code CLI
# - gemini: Google Gemini CLI
# - codex: OpenAI Codex CLI
# - ollama:<model>: Ollama with specified model
# - copilot[:<model>]: GitHub Copilot via copilot-api proxy (default model: gpt-4o)
# ============================================================================

# Colors (in case sourced independently)
RED='\033[0;31m'
NC='\033[0m'

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
    copilot)
      if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl not found${NC}"
        echo ""
        echo "Install curl to use Copilot provider."
        echo ""
        return 1
      fi
      ;;
    factory)
      # Factory provider uses a web API; require curl and an API key/token.
      if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl not found${NC}"
        echo ""
        echo "Install curl to use Factory provider."
        echo ""
        return 1
      fi

      if [[ -z "${FACTORY_API_KEY:-}" && -z "${FACTORY_TOKEN:-}" ]]; then
        echo -e "${RED}❌ FACTORY_API_KEY or FACTORY_TOKEN not set${NC}"
        echo ""
        echo "Set FACTORY_API_KEY or FACTORY_TOKEN in your environment. See:"
        echo "  https://docs.factory.ai"
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
      echo "  - copilot"
      echo "  - factory"
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
    copilot)
      local model="${provider#*:}"
      if [[ "$model" == "$provider" ]]; then
        model="gpt-4o" # Default model
      fi
      execute_copilot "$model" "$prompt"
      ;;
    factory)
      execute_factory "$prompt"
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

# Basic Factory.ai provider implementation
# - Requires FACTORY_API_KEY or FACTORY_TOKEN to be set (validate_provider checks it)
# - FACTORY_API_URL can be used to override the API endpoint (useful for self-hosted / staging)
# - Response parsing is best-effort; Factory API formats may differ, but this provides a starting point.
execute_factory() {
  local prompt="$1"
  local api_url="${FACTORY_API_URL:-https://api.factory.ai/v1/agents/execute}"
  local api_key="${FACTORY_API_KEY:-$FACTORY_TOKEN}"

  # Escape double quotes and backslashes for JSON payload
  local escaped_prompt
  escaped_prompt=$(echo "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n')
  escaped_prompt=${escaped_prompt%\\n}

  local response
  response=$(curl -s -X POST "$api_url" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    -d "{
      \"input\": \"$escaped_prompt\"
    }")

  if [ $? -ne 0 ]; then
    echo "Error connecting to Factory API. Is FACTORY_API_URL reachable?" >&2
    return 1
  fi

  # Try to extract a "content" field if present, otherwise print raw response.
  local content
  content=$(echo "$response" | sed -n 's/.*"content": *"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g; s/\\\\/\\/g')
  if [[ -n "$content" ]]; then
    echo "$content"
    return 0
  fi

  # Fallback: try to extract "text" field used by some APIs
  content=$(echo "$response" | sed -n 's/.*"text": *"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g; s/\\\\/\\/g')
  if [[ -n "$content" ]]; then
    echo "$content"
    return 0
  fi

  # No specific field found; return raw response
  echo "$response"
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
    copilot)
      local model="${provider#*:}"
      if [[ "$model" == "$provider" ]]; then
        model="gpt-4o"
      fi
      echo "GitHub Copilot (model: $model)"
      ;;
    factory)
      # Provide a short, friendly name for Factory provider
      echo "Factory.ai (Droids)"
      ;;
    *)
      echo "Unknown provider"
      ;;
  esac
}
