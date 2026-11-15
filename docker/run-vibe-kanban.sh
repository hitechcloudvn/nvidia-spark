#!/usr/bin/env bash
# =============================================================================
# docker/run-vibe-kanban.sh — Entry point container Vibe Kanban
#                             Vibe Kanban container entrypoint
#
# EN: Runs inside the vibe-kanban container (copied to /startup.sh). Waits for
#     the selected inference service, writes Claude Code Router + Vibe Kanban
#     configs, then starts the router and Vibe Kanban in screen sessions.
# VI: Chạy bên trong container vibe-kanban (được copy thành /startup.sh). Chờ
#     inference service đã chọn, ghi cấu hình Claude Code Router + Vibe Kanban,
#     rồi khởi động router và Vibe Kanban trong các screen session.
#
# Note / Lưu ý:
#   EN: Secrets come from the compose `environment` block; a .env file under
#       NVIDIA_SPARK_HOME (or /root/.env) is loaded as a fallback.
#   VI: Bí mật lấy từ khối `environment` của compose; file .env trong
#       NVIDIA_SPARK_HOME (hoặc /root/.env) được nạp như phương án dự phòng.
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

# Source environment variables if available / Nạp biến môi trường nếu có
NVIDIA_SPARK_HOME="${NVIDIA_SPARK_HOME:-/root/src/github.com/hitechcloudvn/nvidia-spark}"
if [ -f "${NVIDIA_SPARK_HOME}/.env" ]; then
  # shellcheck disable=SC1091
  source "${NVIDIA_SPARK_HOME}/.env"
elif [ -f /root/.env ]; then
  # shellcheck disable=SC1091
  source /root/.env
fi

# Wait for the selected inference service to be available
# Chờ inference service đã chọn sẵn sàng
SERVICE_HOST="${AGENT_INFERENCE_SERVER:-max-inference}"
SERVICE_PORT="8100"

if [ "$SERVICE_HOST" = "llama.cpp" ]; then
  SERVICE_PORT="8090"
fi

echo "Waiting for $SERVICE_HOST service... "
while ! nc -z "$SERVICE_HOST" "$SERVICE_PORT"; do
  sleep 1
done
echo "$SERVICE_HOST service is available"

# Create Claude Code Router config / Tạo cấu hình Claude Code Router
cat <<EOT > /root/.claude-code-router/config.json
{
  "LOG": false,
  "API_TIMEOUT_MS": 600000,
  "NON_INTERACTIVE_MODE": false,
  "Providers": [
    {
      "name": "max-inference",
      "api_base_url": "http://max-inference:8100/v1/chat/completions",
      "api_key": "EMPTY",
      "models": ["noctrex/MiniMax-M2-REAP-139B-A10B-MXFP4_MOE-GGUF"]
    },
    {
      "name": "llama.cpp",
      "api_base_url": "http://llama.cpp:8090/v1/chat/completions",
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

# Create Vibe Kanban config / Tạo cấu hình Vibe Kanban
cat <<EOT > /root/.local/share/vibe-kanban/profiles.json
{
  "executors": {
    "CLAUDE_CODE": {
      "DEFAULT": {
        "CLAUDE_CODE": {
          "append_prompt": null,
          "claude_code_router": true,
          "plan": false,
          "approvals": true,
          "dangerously_skip_permissions": true,
          "disable_api_key": true,
          "base_command_override": "bunx --bun @musistudio/claude-code-router@latest code"
        }
      },
      "PLAN": {
        "CLAUDE_CODE": {
          "append_prompt": null,
          "claude_code_router": true,
          "plan": true,
          "approvals": true,
          "dangerously_skip_permissions": true,
          "disable_api_key": true,
          "base_command_override": "bunx --bun @musistudio/claude-code-router@latest code"
        }
      }
    },
    "QWEN_CODE": {
      "DEFAULT": {
        "QWEN_CODE": {
          "append_prompt": null,
          "yolo": true,
          "base_command_override": "bunx @qwen-code/qwen-code@latest"
        }
      }
    }
  }
}
EOT

cat <<EOT > /root/.local/share/vibe-kanban/config.json
{
  "config_version": "v8",
  "theme": "DARK",
  "executor_profile": {
    "executor": "CLAUDE_CODE"
  },
  "disclaimer_acknowledged": true,
  "onboarding_acknowledged": true,
  "notifications": {
    "sound_enabled": true,
    "push_enabled": true,
    "sound_file": "COW_MOOING"
  },
  "editor": {
    "editor_type": "VS_CODE",
    "custom_command": null,
    "remote_ssh_host": null,
    "remote_ssh_user": null
  },
  "github": {
    "pat": null,
    "oauth_token": null,
    "username": "${GITHUB_USER:-}",
    "primary_email": "${GITHUB_EMAIL:-}",
    "default_pr_base": "main"
  },
  "analytics_enabled": false,
  "workspace_dir": null,
  "show_release_notes": false,
  "language": "BROWSER",
  "git_branch_prefix": "vk",
  "showcases": {
    "seen_features": [
      "task-panel-onboarding"
    ]
  },
  "pr_auto_description_enabled": true,
  "pr_auto_description_prompt": null
}
EOT

# Kill existing screens if they exist / Dọn screen cũ nếu có
if screen -list | grep -q "ccr-server"; then
  ccr stop 2>/dev/null || true
  sleep 2
  screen -S ccr-server -X quit 2>/dev/null || true
fi

if screen -list | grep -q "vibe-kanban"; then
  screen -S vibe-kanban -X quit 2>/dev/null || true
fi

# Start Claude Code Router in screen / Khởi động Claude Code Router trong screen
screen -L -Logfile /tmp/ccr-server.log -dmS ccr-server ccr start

# Start Vibe Kanban in screen on port 8888 / Chạy Vibe Kanban trong screen ở cổng 8888
screen -L -Logfile /tmp/vibe-kanban.log -dmS vibe-kanban bash -c "PORT=${VIBE_KANBAN_PORT:-8888} bunx vibe-kanban@latest"

# Show active screens / Liệt kê screen đang chạy
screen -list

# Keep container running and monitor logs / Giữ container chạy và theo dõi log
tail -f /tmp/ccr-server.log /tmp/vibe-kanban.log
