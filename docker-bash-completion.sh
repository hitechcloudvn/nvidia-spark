#!/usr/bin/env bash
# =============================================================================
# docker-bash-completion.sh — Cài completion bash cho Docker CLI
#                             Install Docker CLI bash completion
#
# EN: Install the Docker CLI bash completion script system-wide.
# VI: Cài script completion bash cho Docker CLI trên toàn hệ thống.
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

docker completion bash | sudo tee /etc/bash_completion.d/docker > /dev/null
sudo chmod 644 /etc/bash_completion.d/docker
docker completion bash | sudo tee /usr/share/bash-completion/completions/docker > /dev/null
sudo chmod 644 /usr/share/bash-completion/completions/docker
