# Release Process / Quy trình phát hành

## English

### Versioning

- [Semantic Versioning](https://semver.org/): tags are `vMAJOR.MINOR.PATCH` (e.g. `v0.1.0`).
- Every release must have a matching section in [`CHANGELOG.md`](../CHANGELOG.md) (Keep a Changelog format).

### Cutting a release

1. Move the `[Unreleased]` entries in `CHANGELOG.md` into a new `## [X.Y.Z] - YYYY-MM-DD` section and add compare links.
2. Commit on `main`:
   ```bash
   git commit -m "chore: release vX.Y.Z"
   ```
3. Tag and push:
   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```

### What automation does

On a `v*` tag, GitHub Actions (`release.yml`):

1. **lint** — shellcheck + YAML validation (blocking).
2. **build-vibe-kanban** — builds and pushes `ghcr.io/hitechcloudvn/nvidia-spark/vibe-kanban` (blocking).
3. **build-llama.cpp / build-vllm** — build the heavy CUDA images on arm64 runners and push to GHCR (non-blocking, `continue-on-error`, pinned via `LLAMA_CPP_REF` / `VLLM_REF`).
4. **release** — creates the GitHub Release from the `CHANGELOG.md` section for the tag.

Images receive the tags `vX.Y.Z`, `latest` and the stable alias (`spark` / `spark-full`).

GitLab CI (`.gitlab-ci.yml`) mirrors this with a `release:` job on `v*` tags so the GitLab Release page stays in sync.

### After the first publish

Set the GHCR packages to **public** (required once per package; the repository is public but GHCR packages start private):

```bash
gh api -X PUT /orgs/hitechcloudvn/packages/container/nvidia-spark%2Fvibe-kanban/visibility -f visibility=public
gh api -X PUT /orgs/hitechcloudvn/packages/container/nvidia-spark%2Fllama.cpp/visibility -f visibility=public
gh api -X PUT /orgs/hitechcloudvn/packages/container/nvidia-spark%2Fvllm/visibility -f visibility=public
```

### Hotfix

Cherry-pick the fix onto a branch from the release tag, bump PATCH, update the changelog, tag `vX.Y.Z+1`.

## Tiếng Việt

### Đánh phiên bản

- [Semantic Versioning](https://semver.org/): tag dạng `vMAJOR.MINOR.PATCH` (vd: `v0.1.0`).
- Mỗi release phải có mục tương ứng trong [`CHANGELOG.md`](../CHANGELOG.md) (định dạng Keep a Changelog).

### Thực hiện release

1. Chuyển các mục `[Unreleased]` trong `CHANGELOG.md` sang mục mới `## [X.Y.Z] - YYYY-MM-DD` và thêm link so sánh.
2. Commit trên `main`:
   ```bash
   git commit -m "chore: release vX.Y.Z"
   ```
3. Tạo tag và đẩy:
   ```bash
   git tag vX.Y.Z
   git push origin main --tags
   ```

### Tự động hoá làm gì

Khi có tag `v*`, GitHub Actions (`release.yml`):

1. **lint** — shellcheck + kiểm tra YAML (chặn nếu lỗi).
2. **build-vibe-kanban** — build và đẩy `ghcr.io/hitechcloudvn/nvidia-spark/vibe-kanban` (chặn nếu lỗi).
3. **build-llama.cpp / build-vllm** — build các ảnh CUDA nặng trên runner arm64 và đẩy lên GHCR (không chặn, `continue-on-error`, ghim qua `LLAMA_CPP_REF` / `VLLM_REF`).
4. **release** — tạo GitHub Release từ mục `CHANGELOG.md` tương ứng với tag.

Ảnh nhận các tag `vX.Y.Z`, `latest` và bí danh ổn định (`spark` / `spark-full`).

GitLab CI (`.gitlab-ci.yml`) đối chiếu với job `release:` theo tag `v*` để trang GitLab Release luôn đồng bộ.

### Sau lần phát hành đầu

Đặt các gói GHCR ở chế độ **public** (cần làm một lần mỗi gói; repo public nhưng gói GHCR mặc định là private):

```bash
gh api -X PUT /orgs/hitechcloudvn/packages/container/nvidia-spark%2Fvibe-kanban/visibility -f visibility=public
gh api -X PUT /orgs/hitechcloudvn/packages/container/nvidia-spark%2Fllama.cpp/visibility -f visibility=public
gh api -X PUT /orgs/hitechcloudvn/packages/container/nvidia-spark%2Fvllm/visibility -f visibility=public
```

### Hotfix

Cherry-pick bản vá lên nhánh từ tag release, tăng PATCH, cập nhật changelog, tag `vX.Y.Z+1`.
