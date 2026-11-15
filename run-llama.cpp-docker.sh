#!/usr/bin/env bash
# =============================================================================
# run-llama.cpp-docker.sh — Chạy llama.cpp server trong Docker
#                           Run the llama.cpp server in Docker
#
# EN: Start the llama.cpp spark-full image (GHCR) with GPU access; extra
#     arguments are passed to llama-server (e.g. --models-preset). Override
#     the image with LLAMA_CPP_IMAGE.
# VI: Khởi động ảnh llama.cpp spark-full (GHCR) với GPU; đối số thêm được
#     truyền vào llama-server (vd: --models-preset). Đè ảnh bằng
#     LLAMA_CPP_IMAGE.
#
# Usage / Cách dùng:
#   ./run-llama.cpp-docker.sh --port 8090
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

LLAMA_CPP_IMAGE="${LLAMA_CPP_IMAGE:-ghcr.io/hitechcloudvn/nvidia-spark/llama.cpp:spark-full}"

# Remove any previous container so re-runs work / Xoá container cũ để chạy lặp được
docker rm -f llama.cpp 2>/dev/null || true

docker run -d --runtime nvidia --gpus all \
  --name llama.cpp \
  -v "${HOME}/.cache/huggingface:/root/.cache/huggingface" \
  -p 8090:8090 \
  --entrypoint /app/llama-server \
  "${LLAMA_CPP_IMAGE}" \
  "${@}"
