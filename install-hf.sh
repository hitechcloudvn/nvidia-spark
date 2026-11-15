#!/usr/bin/env bash
# =============================================================================
# install-hf.sh — Cài đặt Hugging Face CLI (hf)
#                  Install the Hugging Face CLI (hf)
#
# EN: Install uv and huggingface_hub[cli] via pipx, log in to Hugging Face,
#     then enable the high-performance XET transfer backend in ~/.bashrc.
# VI: Cài uv và huggingface_hub[cli] qua pipx, đăng nhập Hugging Face, sau đó
#     bật backend truyền tải XET hiệu năng cao trong ~/.bashrc.
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

pipx install uv
pipx install "huggingface_hub[cli]"
hf auth

grep -q -F "HF_XET_HIGH_PERFORMANCE" "${HOME}/.bashrc" || echo "export HF_XET_HIGH_PERFORMANCE=1" >> "${HOME}/.bashrc"
