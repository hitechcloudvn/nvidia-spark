#!/usr/bin/env bash
# =============================================================================
# nvidia-docker-runtime.sh — Đăng ký runtime NVIDIA cho Docker
#                            Register the NVIDIA runtime with Docker
#
# EN: Configure the NVIDIA Container Toolkit runtime and restart Docker so
#     `--gpus all` / `--runtime nvidia` works.
# VI: Cấu hình runtime NVIDIA Container Toolkit và khởi động lại Docker để
#     `--gpus all` / `--runtime nvidia` hoạt động.
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

sudo nvidia-ctk runtime configure
sudo systemctl restart docker
