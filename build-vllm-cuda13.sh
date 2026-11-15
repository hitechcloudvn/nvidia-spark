#!/usr/bin/env bash
# =============================================================================
# build-vllm-cuda13.sh — Build vLLM từ source (không dùng Docker)
#                        Build vLLM from source (no Docker)
#
# EN: Build vLLM straight from source inside a Python venv for CUDA 13 /
#     sm_121 (DGX Spark). Clones vllm-project/vllm into ~/src (HTTPS,
#     idempotent) and installs it editable with torch nightly (cu130).
# VI: Build vLLM thẳng từ source trong venv Python cho CUDA 13 / sm_121
#     (DGX Spark). Clone vllm-project/vllm vào ~/src (HTTPS, chạy lặp được)
#     và cài đặt dạng editable với torch nightly (cu130).
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

SRC_DIR="${HOME}/src/github.com/vllm-project/vllm"

sudo apt install -y python3-pip python3.12-dev python3.12-venv pipx build-essential ninja-build cmake
pipx install uv

# Idempotent: only clone when the directory is not a git repo yet.
# Chạy lặp được: chỉ clone khi thư mục chưa phải git repo.
if [ ! -d "${SRC_DIR}/.git" ]; then
  git clone https://github.com/vllm-project/vllm.git "${SRC_DIR}"
fi

cd "${SRC_DIR}"
git checkout -- . 2>/dev/null || true
git checkout main
git pull --ff-only
# Pin a release instead of main when needed / Ghim release thay cho main khi cần:
# git checkout "$(curl -sL -H "Accept: application/json" https://github.com/vllm-project/vllm/releases/latest | jq -r .tag_name)"

uv venv --allow-existing
# shellcheck disable=SC1091
source ./.venv/bin/activate
uv pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu130
python use_existing_torch.py
uv pip install -r requirements/build.txt

# sm_121 = Blackwell GB10 (DGX Spark) / sm_121 = Blackwell GB10 (DGX Spark)
export TORCH_CUDA_ARCH_LIST="12.1"
export VLLM_TARGET_DEVICE=cuda
export MAX_JOBS="$(nproc)"
export CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=121"
export VLLM_CUDA_VERSION="13.0"

uv pip install -e . --no-build-isolation -v
