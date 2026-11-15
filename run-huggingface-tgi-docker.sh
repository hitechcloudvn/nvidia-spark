#!/usr/bin/env bash
# =============================================================================
# run-huggingface-tgi-docker.sh — Chạy Hugging Face TGI trong Docker
#                                 Run Hugging Face TGI in Docker
#
# EN: Start Hugging Face Text Generation Inference with GPU access; extra
#     arguments are passed to the TGI launcher (e.g. --model-id). Override
#     the image with TGI_IMAGE.
# VI: Khởi động Hugging Face Text Generation Inference với GPU; đối số thêm
#     được truyền vào TGI launcher (vd: --model-id). Đè ảnh bằng TGI_IMAGE.
#
# Usage / Cách dùng:
#   ./run-huggingface-tgi-docker.sh --model-id Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

TGI_IMAGE="${TGI_IMAGE:-ghcr.io/huggingface/text-generation-inference:latest}"

# Remove any previous container so re-runs work / Xoá container cũ để chạy lặp được
docker rm -f huggingface-tgi 2>/dev/null || true

docker run -d --runtime nvidia --gpus all \
  --name huggingface-tgi \
  -p 8100:80 \
  -v "${HOME}/.cache/huggingface:/root/.cache/huggingface" \
  "${TGI_IMAGE}" "${@}"
