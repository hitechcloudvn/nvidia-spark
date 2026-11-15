# AI HomeLab on NVIDIA DGX Spark

[English](#english) | [Tiếng Việt](#tiếng-việt)

[![CI](https://github.com/hitechcloudvn/nvidia-spark/actions/workflows/ci.yml/badge.svg)](https://github.com/hitechcloudvn/nvidia-spark/actions/workflows/ci.yml)
[![Release](https://github.com/hitechcloudvn/nvidia-spark/actions/workflows/release.yml/badge.svg)](https://github.com/hitechcloudvn/nvidia-spark/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Repositories / Kho lưu trữ:
**GitHub:** <https://github.com/hitechcloudvn/nvidia-spark> ·
**GitLab:** <https://gitlab.com/hitechcloudvn/nvidia-spark>

---

## English

Tools and configurations for running your own AI HomeLab on NVIDIA DGX Spark — local LLM inference with llama.cpp / vLLM / MAX, plus Claude Code Router and Vibe Kanban for AI-assisted development workflows.

### Features

- Docker-based deployments with health checks (Docker Compose)
- llama.cpp (CUDA 13, sm_121) and vLLM (torch nightly cu130) images built for DGX Spark
- Hugging Face model catalog (GGUF + safetensors) with one-shot download script
- Claude Code Router with local + OpenRouter + DeepSeek providers and smart routing
- Vibe Kanban for orchestrating coding agents (Claude Code, Qwen Code)
- Bilingual Vietnamese/English docs; CI/CD builds and publishes everything — no local build required

### Repository layout

| Path | Purpose |
| --- | --- |
| `docker-compose.yaml` | `max-inference`, `llama.cpp`, `vibe-kanban` services |
| `Dockerfile.llama.cpp.spark` | llama.cpp CUDA 13 image (targets: base/full/light/server) |
| `Dockerfile.vllm.spark` | vLLM CUDA 13 image (target: vllm-base) |
| `Dockerfile.vibe-kanban` | Vibe Kanban + Claude Code Router image |
| `build-*-docker.sh` | Local image builds (optional — CI builds the same images) |
| `run-*.sh` | Run inference servers / agent stack |
| `download-hf-models.sh` | Download the model catalog |
| `install-*.sh`, `nvidia-docker-runtime.sh`, `docker-bash-completion.sh` | Host setup |
| `llama.cpp.models.ini` | Model presets for llama.cpp server |
| `docs/` | Release process, integration notes |

### Quick start

```bash
# 1. Environment / Biến môi trường
cp .env.example .env          # fill in your keys / điền khoá

# 2. NVIDIA Docker runtime (once) / một lần
./nvidia-docker-runtime.sh

# 3. Models (hundreds of GB) / model (hàng trăm GB)
./install-hf.sh
./download-hf-models.sh

# 4a. Inference server via Docker Compose / inference server qua Compose
docker compose up -d llama.cpp

# 4b. Full agent stack / toàn bộ agent stack
./run-claude-code-router.sh   # router + MCP
./run-vibe-kanban.sh          # Vibe Kanban UI on :8888
```

Prebuilt images are pulled from GHCR automatically; to build locally use `./build-llama.cpp-cuda13-docker.sh` / `./build-vllm-cuda13-docker.sh` (arm64 host required).

### Images (GHCR)

| Image | Tags |
| --- | --- |
| `ghcr.io/hitechcloudvn/nvidia-spark/llama.cpp` | `spark-full`, `latest`, `vX.Y.Z` |
| `ghcr.io/hitechcloudvn/nvidia-spark/vllm` | `spark`, `latest`, `vX.Y.Z` |
| `ghcr.io/hitechcloudvn/nvidia-spark/vibe-kanban` | `spark`, `latest`, `vX.Y.Z` |

### Models supported

Configured in `llama.cpp.models.ini` / Cấu hình trong `llama.cpp.models.ini`:

- `noctrex/MiniMax-M2-139B` (MiniMax-M2-REAP-139B-A10B-MXFP4)
- `noctrex/Qwen3-Next-80B` (1M context, YaRN rope-scaling)
- `noctrex/Nemotron-3-Nano-30B`
- `unsloth/Devstral-2-123B-Instruct-2512-GGUF`
- `bartowski/zai-org_GLM-4.7`
- `endyjasmi/Qwen3-Embedding-8B`

`download-hf-models.sh` additionally fetches coding, VLM, embedding, image/video (ComfyUI), voice and OCR models.

### Environment variables

See `.env.example` / Xem `.env.example`: `HF_TOKEN`, `OPENROUTER_API_KEY`, `DEEPSEEK_API_KEY`, `GITHUB_USER`, `GITHUB_EMAIL`, `AGENT_INFERENCE_SERVER`, `AGENT_MAIN_MODEL`, `AGENT_BACKGROUND_MODEL`, `VIBE_KANBAN_PORT`.

### CI/CD & releases

- `ci.yml` — lint (shellcheck + YAML validation) on every push/PR.
- `release.yml` — on `v*` tags: builds all three images on arm64 runners, pushes them to GHCR, and publishes the GitHub Release from `CHANGELOG.md`. Fragile upstream GPU builds are non-blocking (`continue-on-error`), so releases always publish.
- `.gitlab-ci.yml` — lint + GitLab Release on `v*` tags.

Releases follow semver; the process is documented in [`docs/RELEASE.md`](docs/RELEASE.md).

### Requirements

- NVIDIA GPU with CUDA (DGX Spark, sm_121 / GB10 recommended)
- Docker + Docker Compose, NVIDIA Container Toolkit
- Bun runtime (installed by `install-bun.sh`)
- ~128 GB RAM recommended for the large MoE models; hundreds of GB of disk for the model catalog

### License

MIT — see [LICENSE](LICENSE). Dual copyright: original portions by [Slach/nvidia-spark](https://github.com/Slach/nvidia-spark), modifications and maintenance by Nguyễn Thanh An (thanhan92f1) — HiTechCloud (`hitechcloudvn`).

### Acknowledgements

Based on [Slach/nvidia-spark](https://github.com/Slach/nvidia-spark). Thanks to the upstream projects: [llama.cpp](https://github.com/ggml-org/llama.cpp), [vLLM](https://github.com/vllm-project/vllm), [Claude Code Router](https://github.com/musistudio/claude-code-router), [Vibe Kanban](https://vibekanban.com).

---

## Tiếng Việt

Công cụ và cấu hình để vận hành AI HomeLab của riêng bạn trên NVIDIA DGX Spark — suy luận LLM cục bộ với llama.cpp / vLLM / MAX, kèm Claude Code Router và Vibe Kanban cho quy trình phát triển có AI hỗ trợ.

### Tính năng

- Triển khai dựa trên Docker kèm health check (Docker Compose)
- Ảnh llama.cpp (CUDA 13, sm_121) và vLLM (torch nightly cu130) build riêng cho DGX Spark
- Danh mục model Hugging Face (GGUF + safetensors) với script tải một chạm
- Claude Code Router với provider cục bộ + OpenRouter + DeepSeek và định tuyến thông minh
- Vibe Kanban để điều phối coding agent (Claude Code, Qwen Code)
- Tài liệu song ngữ Việt/Anh; CI/CD build và phát hành toàn bộ — không cần build cục bộ

### Bố cục repository

| Đường dẫn | Mục đích |
| --- | --- |
| `docker-compose.yaml` | Dịch vụ `max-inference`, `llama.cpp`, `vibe-kanban` |
| `Dockerfile.llama.cpp.spark` | Ảnh llama.cpp CUDA 13 (target: base/full/light/server) |
| `Dockerfile.vllm.spark` | Ảnh vLLM CUDA 13 (target: vllm-base) |
| `Dockerfile.vibe-kanban` | Ảnh Vibe Kanban + Claude Code Router |
| `build-*-docker.sh` | Build ảnh cục bộ (tuỳ chọn — CI build cùng ảnh) |
| `run-*.sh` | Chạy inference server / agent stack |
| `download-hf-models.sh` | Tải danh mục model |
| `install-*.sh`, `nvidia-docker-runtime.sh`, `docker-bash-completion.sh` | Thiết lập host |
| `llama.cpp.models.ini` | Preset model cho llama.cpp server |
| `docs/` | Quy trình phát hành, ghi chú tích hợp |

### Bắt đầu nhanh

```bash
# 1. Biến môi trường
cp .env.example .env          # điền khoá

# 2. NVIDIA Docker runtime (một lần)
./nvidia-docker-runtime.sh

# 3. Model (hàng trăm GB)
./install-hf.sh
./download-hf-models.sh

# 4a. Inference server qua Compose
docker compose up -d llama.cpp

# 4b. Toàn bộ agent stack
./run-claude-code-router.sh   # router + MCP
./run-vibe-kanban.sh          # giao diện Vibe Kanban ở cổng 8888
```

Ảnh dựng sẵn tự động kéo từ GHCR; nếu muốn build cục bộ dùng `./build-llama.cpp-cuda13-docker.sh` / `./build-vllm-cuda13-docker.sh` (cần máy arm64).

### Ảnh (GHCR)

| Ảnh | Tag |
| --- | --- |
| `ghcr.io/hitechcloudvn/nvidia-spark/llama.cpp` | `spark-full`, `latest`, `vX.Y.Z` |
| `ghcr.io/hitechcloudvn/nvidia-spark/vllm` | `spark`, `latest`, `vX.Y.Z` |
| `ghcr.io/hitechcloudvn/nvidia-spark/vibe-kanban` | `spark`, `latest`, `vX.Y.Z` |

### Model hỗ trợ

Cấu hình trong `llama.cpp.models.ini`:

- `noctrex/MiniMax-M2-139B` (MiniMax-M2-REAP-139B-A10B-MXFP4)
- `noctrex/Qwen3-Next-80B` (ngữ cảnh 1M, YaRN rope-scaling)
- `noctrex/Nemotron-3-Nano-30B`
- `unsloth/Devstral-2-123B-Instruct-2512-GGUF`
- `bartowski/zai-org_GLM-4.7`
- `endyjasmi/Qwen3-Embedding-8B`

`download-hf-models.sh` tải thêm model lập trình, VLM, embedding, ảnh/video (ComfyUI), giọng nói và OCR.

### Biến môi trường

Xem `.env.example`: `HF_TOKEN`, `OPENROUTER_API_KEY`, `DEEPSEEK_API_KEY`, `GITHUB_USER`, `GITHUB_EMAIL`, `AGENT_INFERENCE_SERVER`, `AGENT_MAIN_MODEL`, `AGENT_BACKGROUND_MODEL`, `VIBE_KANBAN_PORT`.

### CI/CD & phát hành

- `ci.yml` — lint (shellcheck + kiểm tra YAML) trên mọi push/PR.
- `release.yml` — khi có tag `v*`: build cả ba ảnh trên runner arm64, đẩy lên GHCR, tạo GitHub Release từ `CHANGELOG.md`. Các bước build GPU upstream dễ hỏng được đặt không chặn (`continue-on-error`) để release luôn được phát hành.
- `.gitlab-ci.yml` — lint + GitLab Release theo tag `v*`.

Release theo semver; quy trình tại [`docs/RELEASE.md`](docs/RELEASE.md).

### Yêu cầu

- GPU NVIDIA có CUDA (khuyến nghị DGX Spark, sm_121 / GB10)
- Docker + Docker Compose, NVIDIA Container Toolkit
- Bun runtime (cài qua `install-bun.sh`)
- Khuyến nghị ~128 GB RAM cho các model MoE lớn; hàng trăm GB ổ đĩa cho danh mục model

### Giấy phép

MIT — xem [LICENSE](LICENSE). Bản quyền kép: phần gốc bởi [Slach/nvidia-spark](https://github.com/Slach/nvidia-spark), sửa đổi và bảo trì bởi Nguyễn Thanh An (thanhan92f1) — HiTechCloud (`hitechcloudvn`).

### Ghi nhận

Dựa trên [Slach/nvidia-spark](https://github.com/Slach/nvidia-spark). Cảm ơn các dự án upstream: [llama.cpp](https://github.com/ggml-org/llama.cpp), [vLLM](https://github.com/vllm-project/vllm), [Claude Code Router](https://github.com/musistudio/claude-code-router), [Vibe Kanban](https://vibekanban.com).
