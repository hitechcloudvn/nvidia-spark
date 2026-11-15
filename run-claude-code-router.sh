#!/usr/bin/env bash
# =============================================================================
# run-claude-code-router.sh — Chạy Claude Code Router trên host
#                             Run Claude Code Router on the host
#
# EN: Install bun tooling (qwen-code, claude-code, claude-code-router), start
#     the selected inference server via docker compose, write the router
#     config, register MCP servers, then launch the router in a screen session.
# VI: Cài công cụ bun (qwen-code, claude-code, claude-code-router), khởi động
#     inference server đã chọn qua docker compose, ghi cấu hình router, đăng
#     ký MCP server, rồi chạy router trong screen.
#
# Usage / Cách dùng:
#   cp .env.example .env   # then edit / rồi điền khoá
#   ./run-claude-code-router.sh
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Source environment variables if available / Nạp biến môi trường nếu có
if [ -f "${CUR_DIR}/.env" ]; then
  # shellcheck disable=SC1091
  source "${CUR_DIR}/.env"
fi

bash "${CUR_DIR}/install-bun.sh"

if [[ "max-inference" == "${AGENT_INFERENCE_SERVER:-}" ]]; then
  mkdir -p "${HOME}/.cache/max_cache"
fi

# Default to llama.cpp so `up -d` never starts every service at once.
# Mặc định llama.cpp để `up -d` không bật đồng loạt mọi service.
docker compose -f "${CUR_DIR}/docker-compose.yaml" up -d "${AGENT_INFERENCE_SERVER:-llama.cpp}"

mkdir -p "${HOME}/.claude-code-router"
cat <<EOT > "${HOME}/.claude-code-router/config.json"
{
  "LOG": false,
  "API_TIMEOUT_MS": 600000,
  "NON_INTERACTIVE_MODE": false,
  "Providers": [
    {
      "name": "max-inference",
      "api_base_url": "http://127.0.0.1:8100/v1/chat/completions",
      "api_key": "EMPTY",
      "models": ["noctrex/MiniMax-M2-REAP-139B-A10B-MXFP4_MOE-GGUF"]
    },
    {
      "name": "llama.cpp",
      "api_base_url": "http://127.0.0.1:8090/v1/chat/completions",
      "api_key": "llama.cpp",
      "models": ["noctrex/MiniMax-M2-139B","noctrex/Qwen3-Next-80B","noctrex/Nemotron-3-Nano-30B"]
    },
    {
      "name": "openrouter",
      "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
      "api_key": "${OPENROUTER_API_KEY:-}",
      "models": [
        "google/gemini-3-pro-preview",
        "anthropic/claude-sonnet-4.5",
        "x-ai/grok-4.1-fast",
        "qwen/qwen-plus-2025-07-28",
        "qwen/qwen3-coder:exacto",
        "moonshotai/kimi-k2-0905:exacto",
        "deepseek/deepseek-v3.2-speciale",
        "perplexity/sonar"
      ],
      "transformer": {
        "use": ["openrouter"]
      }
    },
    {
      "name": "deepseek",
      "api_base_url": "https://api.deepseek.com/chat/completions",
      "api_key": "${DEEPSEEK_API_KEY:-}",
      "models": ["deepseek-chat", "deepseek-reasoner"],
      "transformer": {
        "use": ["deepseek"],
        "deepseek-chat": {
          "use": ["tooluse"]
        }
      }
    }
  ],
  "Router": {
    "default": "${AGENT_INFERENCE_SERVER:-max-inference},${AGENT_MAIN_MODEL:-noctrex/MiniMax-M2-REAP-139B-A10B-MXFP4_MOE-GGUF}",
    "background": "${AGENT_INFERENCE_SERVER:-max-inference},${AGENT_BACKGROUND_MODEL:-noctrex/MiniMax-M2-REAP-139B-A10B-MXFP4_MOE-GGUF}",
    "think": "openrouter,x-ai/grok-4.1-fast",
    "longContext": "openrouter,x-ai/grok-4.1-fast",
    "longContextThreshold": 98304,
    "webSearch": "openrouter,perplexity/sonar"
  }
}
EOT

bun install -g @qwen-code/qwen-code@latest
bun install -g @anthropic-ai/claude-code@latest
bun install -g @musistudio/claude-code-router@latest

claude mcp add --scope user --transport http gitmcp https://gitmcp.io/docs/
claude mcp add --scope user vibe_kanban -e PORT="${VIBE_KANBAN_PORT:-8888}" -- bunx --bun vibe-kanban@latest --mcp
claude mcp list

qwen mcp add --scope user --transport http gitmcp https://gitmcp.io/docs/
qwen mcp add --scope user vibe_kanban bunx --bun vibe-kanban@latest --mcp -e PORT="${VIBE_KANBAN_PORT:-8888}"
qwen mcp list

# Restart cleanly if already running / Khởi động lại sạch nếu đang chạy
if screen -list | grep -q "ccr-server"; then
  ccr stop 2>/dev/null || true
  sleep 2
  screen -S ccr-server -X quit 2>/dev/null || true
fi

screen -L -Logfile /tmp/ccr-server.log -dmS ccr-server ccr start
screen -list
