#!/usr/bin/env bash
# =============================================================================
# run-vibe-kanban.sh — Chạy Vibe Kanban cục bộ (host) với Claude Code Router
#                      Run Vibe Kanban locally (host) with Claude Code Router
#
# EN: Start the selected inference server via docker compose, install bun
#     tooling, write Vibe Kanban profiles/config, then launch Vibe Kanban in a
#     screen session on PORT (default 8888).
# VI: Khởi động inference server đã chọn qua docker compose, cài công cụ bun,
#     ghi profiles/config của Vibe Kanban, rồi chạy Vibe Kanban trong screen
#     trên PORT (mặc định 8888).
#
# Usage / Cách dùng:
#   cp .env.example .env   # then edit / rồi điền khoá
#   ./run-vibe-kanban.sh
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

# Start the selected inference service (default: llama.cpp)
# Khởi động inference service đã chọn (mặc định: llama.cpp)
docker compose -f "${CUR_DIR}/docker-compose.yaml" up -d "${AGENT_INFERENCE_SERVER:-llama.cpp}"
bash "${CUR_DIR}/install-bun.sh"

mkdir -p "${HOME}/.local/share/vibe-kanban"

cat <<EOT > "${HOME}/.local/share/vibe-kanban/profiles.json"
{
  "executors": {
    "CLAUDE_CODE": {
      "DEFAULT": {
        "CLAUDE_CODE": {
          "append_prompt": null,
          "claude_code_router": true,
          "plan": false,
          "approvals": false,
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
          "approvals": false,
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

cat <<EOT > "${HOME}/.local/share/vibe-kanban/config.json"
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
  "last_app_version": "0.0.137",
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

# Restart cleanly if already running / Khởi động lại sạch nếu đang chạy
if screen -list | grep -q "vibe-kanban"; then
  screen -S vibe-kanban -X quit || true
fi

screen -L -Logfile /tmp/vibe-kanban.log -dmS vibe-kanban bash -c "PORT=${VIBE_KANBAN_PORT:-8888} bunx vibe-kanban@latest"
screen -list
