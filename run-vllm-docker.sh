#!/usr/bin/env bash
# =============================================================================
# run-vllm-docker.sh — Chạy vLLM OpenAI server trong Docker
#                       Run the vLLM OpenAI server in Docker
#
# EN: Start the vLLM spark image (GHCR) with GPU access; extra arguments are
#     passed straight to the vLLM API server (model name, tensor-parallel
#     size, ...). Override the image with VLLM_IMAGE.
# VI: Khởi động ảnh vLLM spark (GHCR) với GPU; đối số thêm được truyền thẳng
#     vào vLLM API server (tên model, tensor-parallel size, ...). Đè ảnh bằng
#     VLLM_IMAGE.
#
# Usage / Cách dùng:
#   ./run-vllm-docker.sh Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8 --gpu-memory-utilization 0.9
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

VLLM_IMAGE="${VLLM_IMAGE:-ghcr.io/hitechcloudvn/nvidia-spark/vllm:spark}"

# Remove any previous container so re-runs work / Xoá container cũ để chạy lặp được
docker rm -f vllm-openai 2>/dev/null || true

docker run -d --runtime nvidia --gpus all \
  --name vllm-openai \
  -v "${HOME}/.cache/huggingface:/root/.cache/huggingface" \
  -p 8000:8000 \
  "${VLLM_IMAGE}" \
  "${@}"
