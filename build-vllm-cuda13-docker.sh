#!/usr/bin/env bash
# =============================================================================
# build-vllm-cuda13-docker.sh — Build ảnh vLLM CUDA 13 cho DGX Spark
#                               Build the vLLM CUDA 13 image for DGX Spark
#
# EN: Clone vllm-project/vllm into ~/src (HTTPS, idempotent) and build the
#     "vllm-base" target with Dockerfile.vllm.spark. VLLM_REF selects the
#     upstream ref to build (default: the pin used by CI).
# VI: Clone vllm-project/vllm vào ~/src (HTTPS, chạy lặp được) và build
#     target "vllm-base" với Dockerfile.vllm.spark. VLLM_REF chọn ref upstream
#     sẽ build (mặc định: ref CI đang pin).
#
# Note / Lưu ý:
#   EN: Building needs an arm64 host (DGX Spark, sm_121). CI builds the same
#       image on GitHub-hosted arm64 runners — see .github/workflows/release.yml.
#   VI: Build cần host arm64 (DGX Spark, sm_121). CI build cùng ảnh trên runner
#       arm64 của GitHub — xem .github/workflows/release.yml.
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${HOME}/src/github.com/vllm-project/vllm"

mkdir -p "${SRC_DIR}"
# Idempotent: only clone when the directory is not a git repo yet.
# Chạy lặp được: chỉ clone khi thư mục chưa phải git repo.
if [ ! -d "${SRC_DIR}/.git" ]; then
  git clone https://github.com/vllm-project/vllm.git "${SRC_DIR}"
fi

# Keep in sync with VLLM_REF in .github/workflows/release.yml.
# Đồng bộ với VLLM_REF trong .github/workflows/release.yml.
VLLM_REF="${VLLM_REF:-v0.33.0}"

cd "${SRC_DIR}"
git checkout -- . 2>/dev/null || true
git fetch --tags --force
git checkout main
git pull --ff-only || true
git checkout "${VLLM_REF}"

CUDA_VERSION="${CUDA_VERSION:-13.0.2}"
UBUNTU_VERSION="${UBUNTU_VERSION:-$(grep 'VERSION_ID' /etc/os-release | cut -d'"' -f2)}"

docker build --progress=plain --platform=linux/arm64 \
  -f "${CUR_DIR}/Dockerfile.vllm.spark" \
  --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
  --build-arg CUDA_VERSION="${CUDA_VERSION}" \
  --target vllm-base -t ghcr.io/hitechcloudvn/nvidia-spark/vllm:spark "${SRC_DIR}"
