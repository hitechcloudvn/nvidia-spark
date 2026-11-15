# Changelog / Nhật ký thay đổi

All notable changes to this project will be documented in this file.
Tất cả thay đổi đáng chú ý của dự án sẽ được ghi lại tại đây.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] / [Chưa phát hành]

## [0.1.0] - 2026-11-16

### Added / Thêm mới

- Docker Compose stack for NVIDIA DGX Spark: `max-inference`, `llama.cpp`, `vibe-kanban` with health checks. / Chuỗi dịch vụ Docker Compose cho NVIDIA DGX Spark: `max-inference`, `llama.cpp`, `vibe-kanban` kèm health check.
- Dockerfiles: `Dockerfile.llama.cpp.spark` (multi-target base/full/light/server), `Dockerfile.vllm.spark` (torch nightly cu130, target `vllm-base`), `Dockerfile.vibe-kanban` (Claude Code Router + Vibe Kanban). / Các Dockerfile: llama.cpp đa target, vLLM với torch nightly cu130, Vibe Kanban kèm Claude Code Router.
- Helper scripts: build (`build-llama.cpp-cuda13-docker.sh`, `build-vllm-cuda13-docker.sh`, `build-vllm-cuda13.sh`), run (`run-llama.cpp-docker.sh`, `run-vllm-docker.sh`, `run-huggingface-tgi-docker.sh`, `run-claude-code-router.sh`, `run-vibe-kanban.sh`, `docker/run-vibe-kanban.sh`), install (`install-bun.sh`, `install-hf.sh`, `nvidia-docker-runtime.sh`, `docker-bash-completion.sh`), models (`download-hf-models.sh`, `llama.cpp.models.ini`). / Các script tiện ích: build, chạy, cài đặt, model.
- Bilingual Vietnamese/English documentation across the whole repository. / Tài liệu song ngữ Việt/Anh trên toàn bộ repository.
- CI/CD: GitHub Actions lint on push/PR; tag-driven release workflow building GHCR images (`ghcr.io/hitechcloudvn/nvidia-spark/*`) and creating the GitHub Release from this changelog. GitLab CI lint + `release:` job on `v*` tags. / CI/CD: GitHub Actions lint, workflow phát hành theo tag build ảnh GHCR và tạo GitHub Release từ changelog này; GitLab CI lint + job `release:` theo tag `v*`.
- `LICENSE` (MIT), `CONTRIBUTING.md`, `.env.example`, `docs/RELEASE.md`. / Các file giấy phép, hướng dẫn đóng góp, mẫu env, quy trình phát hành.

### Fixed / Sửa lỗi

- `docker/run-vibe-kanban.sh`: hardcoded `Slach` path for `.env`; stray `}` in `Router.background`; trailing commas producing invalid JSON in `profiles.json` and the openrouter model list. / Đường dẫn `.env` gắn cứng `Slach`; thừa `}` ở `Router.background`; dấu phẩy thừa làm JSON không hợp lệ.
- `run-claude-code-router.sh`: same stray `}` and trailing comma; unguarded `source .env`; `docker compose up -d` without a default service. / Lỗi tương tự; `source .env` không kiểm tra; `docker compose up -d` không có service mặc định.
- `Dockerfile.vibe-kanban`: missing `@qwen-code/qwen-code` made `qwen mcp` build steps fail. / Thiếu `@qwen-code/qwen-code` khiến bước `qwen mcp` lỗi khi build.
- `Dockerfile.vllm.spark`: invalid `ARG PYTHON_VERSION=13.2` → `3.12`. / Giá trị `PYTHON_VERSION` không hợp lệ.
- `docker-compose.yaml`: broken `llama.cpp` build context → prebuilt GHCR image; missing `OPENROUTER_API_KEY`/`DEEPSEEK_API_KEY`/`GITHUB_USER`/`GITHUB_EMAIL` for `vibe-kanban`. / Ngữ cảnh build `llama.cpp` sai → dùng ảnh GHCR; thiếu biến môi trường cho `vibe-kanban`.
- Build scripts: SSH clone URLs → HTTPS, idempotent clones, `VLLM_REF` checked out consistently. / URL clone SSH → HTTPS, clone chạy lặp được, checkout `VLLM_REF` nhất quán.
- `install-bun.sh`: symlink to `bun` ran before `~/.bun/bin` was on `PATH`. / Symlink `bun` chạy trước khi thêm `~/.bun/bin` vào `PATH`.
- Missing `#!/usr/bin/env bash` shebangs and `set -euo pipefail` in several scripts. / Thiếu shebang và `set -euo pipefail` ở nhiều script.
- `.gitignore` was a Go template → replaced with a shell/Docker-oriented one. / `.gitignore` vốn là template Go → thay bằng bản phù hợp shell/Docker.
- `Dockerfile.vibe-kanban`: `curl` was used to download the GitHub CLI keyring before it was installed → install `ca-certificates curl` first. / Dùng `curl` tải keyring GitHub CLI trước khi cài `curl` → cài `ca-certificates curl` trước.
- `Dockerfile.vllm.spark`: `COPY use_existing_torch.py` pointed at a path missing from the vLLM tree → `tools/use_existing_torch.py` (matches upstream v0.33.0). / `COPY use_existing_torch.py` trỏ tới đường dẫn không tồn tại trong mã nguồn vLLM → `tools/use_existing_torch.py` (khớp upstream v0.33.0).
- GitHub Actions: invalid job id `build-llama.cpp` (dots are not allowed) → `build-llama-cpp`; the GitHub Release now runs as soon as lint passes so image failures can never block it. / Job id `build-llama.cpp` không hợp lệ (không được chứa dấu chấm) → `build-llama-cpp`; GitHub Release chạy ngay khi lint pass để lỗi build ảnh không bao giờ chặn release.
- GitLab CI: the `release:` job image lacked the `release-cli` binary → `registry.gitlab.com/gitlab-org/release-cli:latest`. / Ảnh của job `release:` thiếu binary `release-cli` → dùng `registry.gitlab.com/gitlab-org/release-cli:latest`.
- `docs/RELEASE.md`: the documented `gh api .../visibility` commands cannot work — the GitHub REST API/GraphQL have no package-visibility write endpoint; replaced with the web UI steps and direct settings links. / Các lệnh `gh api .../visibility` trong tài liệu không thể chạy được — REST API/GraphQL của GitHub không có endpoint ghi visibility gói; thay bằng các bước trên giao diện web và link settings trực tiếp.
- `Dockerfile.vibe-kanban`: `bun install` builds `better-sqlite3` from source and node-gyp needs Python, make and g++ on the image → install `build-essential python3`. / `bun install` biên dịch `better-sqlite3` từ nguồn và node-gyp cần Python, make, g++ trên ảnh → cài `build-essential python3`.
- `Dockerfile.vllm.spark`: `requirements/build.txt` no longer exists at vLLM v0.33.0 → install `requirements/build/cuda.txt` (the torch pin is stripped by `use_existing_torch.py`); test stage `requirements/nightly_torch_test.txt` → `requirements/test/nightly-torch.txt`; add a best-effort Rust toolchain for vLLM's optional Rust frontend. / `requirements/build.txt` không còn ở vLLM v0.33.0 → cài `requirements/build/cuda.txt` (ghim torch bị `use_existing_torch.py` loại bỏ); stage test `requirements/nightly_torch_test.txt` → `requirements/test/nightly-torch.txt`; thêm toolchain Rust cho frontend Rust tùy chọn của vLLM.
- `Dockerfile.vllm.spark`: upstream default `max_jobs=20` spawns 20 parallel nvcc jobs on a 4-core / 16 GB runner → OOM kills the runner mid-compile (job dies ~1 h in with no logs) → default to `max_jobs=4`, `nvcc_threads=1`. / `max_jobs=20` mặc định của upstream tạo 20 job nvcc song song trên runner 4 core / 16 GB → hết RAM, runner chết giữa lúc biên dịch (job chết sau ~1 giờ, không có log) → đổi mặc định thành `max_jobs=4`, `nvcc_threads=1`.
- `release.yml` `build-vllm`: stock runner has only ~14 GB free disk and the vLLM CUDA build (devel image + torch cu130 + compiled kernels) needs tens of GB → runs out of disk and kills the job without logs → reclaim preinstalled toolchains (dotnet/android/ghc/…) before building. / Runner mặc định chỉ có ~14 GB đĩa trống, build vLLM CUDA (ảnh devel + torch cu130 + kernel đã biên dịch) cần hàng chục GB → hết đĩa, job chết không có log → giải phóng các toolchain cài sẵn (dotnet/android/ghc/…) trước khi build.

### Changed / Thay đổi

- Organization references standardized to `hitechcloudvn` on GitHub and GitLab (replacing old upstream paths). / Chuẩn hoá tham chiếu tổ chức thành `hitechcloudvn` trên GitHub và GitLab.
- Container images published under `ghcr.io/hitechcloudvn/nvidia-spark/{llama.cpp,vllm,vibe-kanban}`. / Ảnh container phát hành tại `ghcr.io/hitechcloudvn/nvidia-spark/*`.
- Author and Committer of the whole history standardized to `Nguyễn Thanh An <thanhan92f1@gmail.com>`. / Tác giả và người commit của toàn bộ lịch sử được chuẩn hoá về `Nguyễn Thanh An <thanhan92f1@gmail.com>`.

[Unreleased]: https://github.com/hitechcloudvn/nvidia-spark/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hitechcloudvn/nvidia-spark/releases/tag/v0.1.0
