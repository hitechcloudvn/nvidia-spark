#!/usr/bin/env bash
# =============================================================================
# build-llama.cpp-cuda13-docker.sh — Build ảnh llama.cpp CUDA 13 cho DGX Spark
#                                    Build the llama.cpp CUDA 13 image for DGX Spark
#
# EN: Clone ggml-org/llama.cpp into ~/src (HTTPS, idempotent), check out the
#     latest upstream release (override with LLAMA_CPP_RELEASE), then build
#     the "full" target with Dockerfile.llama.cpp.spark. The build context is
#     the llama.cpp source tree, not this repository.
# VI: Clone ggml-org/llama.cpp vào ~/src (HTTPS, chạy lặp được), checkout
#     release mới nhất của upstream (đè bằng LLAMA_CPP_RELEASE), rồi build
#     target "full" với Dockerfile.llama.cpp.spark. Build context là mã nguồn
#     llama.cpp, không phải repo này.
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
SRC_DIR="${HOME}/src/github.com/ggml-org/llama.cpp"

mkdir -p "${SRC_DIR}"
# Idempotent: only clone when the directory is not a git repo yet.
# Chạy lặp được: chỉ clone khi thư mục chưa phải git repo.
if [ ! -d "${SRC_DIR}/.git" ]; then
  git clone https://github.com/ggml-org/llama.cpp.git "${SRC_DIR}"
fi

# Default to the latest upstream release; keep in sync with LLAMA_CPP_REF in
# .github/workflows/release.yml. / Mặc định lấy release mới nhất upstream;
# đồng bộ với LLAMA_CPP_REF trong .github/workflows/release.yml.
LLAMA_CPP_RELEASE="${LLAMA_CPP_RELEASE:-$(curl -sL -H "Accept: application/json" https://github.com/ggml-org/llama.cpp/releases/latest | jq -r .tag_name)}"

cd "${SRC_DIR}"
git fetch --tags --force
git checkout master
git pull --ff-only || true
git checkout "${LLAMA_CPP_RELEASE}"

CUDA_VERSION="${CUDA_VERSION:-13.0.2}"
UBUNTU_VERSION="${UBUNTU_VERSION:-$(grep 'VERSION_ID' /etc/os-release | cut -d'"' -f2)}"
CUDA_DOCKER_ARCH="${CUDA_DOCKER_ARCH:-121}"

docker build --progress=plain --platform=linux/arm64 \
  -f "${CUR_DIR}/Dockerfile.llama.cpp.spark" \
  --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
  --build-arg CUDA_VERSION="${CUDA_VERSION}" \
  --build-arg CUDA_DOCKER_ARCH="${CUDA_DOCKER_ARCH}" \
  --target full -t ghcr.io/hitechcloudvn/nvidia-spark/llama.cpp:spark-full "${SRC_DIR}"
