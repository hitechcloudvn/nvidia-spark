# Contributing / Hướng dẫn đóng góp

Thank you for your interest in contributing! / Cảm ơn bạn đã quan tâm đóng góp!

## English

### Development setup

1. Fork and clone the repository.
2. `cp .env.example .env` and fill in your keys (never commit `.env`).
3. Test scripts locally on an arm64 GPU host (NVIDIA DGX Spark), or let CI build the images.

### Pull requests

- Keep changes focused; one topic per PR.
- Write commit messages in [Conventional Commits](https://www.conventionalcommits.org/) style, e.g. `fix: repair profiles.json generation`.
- Documentation and user-facing strings must stay bilingual (Vietnamese + English).
- Every commit must carry these co-author trailers:

  ```
  Co-Authored-By: pgt-vn <nguyenthanhan92f1@gmail.com>
  Co-Authored-By: agent-hitechcloud <agent@hitechcloud.vn>
  ```

### Reporting issues

Please include: host OS/GPU, Docker version, the exact command you ran, and the full error output.

## Tiếng Việt

### Thiết lập phát triển

1. Fork và clone repository.
2. `cp .env.example .env` rồi điền khoá (không bao giờ commit `.env`).
3. Kiểm thử script trên máy GPU arm64 (NVIDIA DGX Spark), hoặc để CI build ảnh.

### Pull request

- Giữ thay đổi gọn, mỗi PR một chủ đề.
- Viết message theo [Conventional Commits](https://www.conventionalcommits.org/), ví dụ `fix: repair profiles.json generation`.
- Tài liệu và chuỗi hiển thị phải song ngữ (Việt + Anh).
- Mỗi commit phải kèm trailer đồng tác giả:

  ```
  Co-Authored-By: pgt-vn <nguyenthanhan92f1@gmail.com>
  Co-Authored-By: agent-hitechcloud <agent@hitechcloud.vn>
  ```

### Báo lỗi

Vui lòng cung cấp: OS/GPU, phiên bản Docker, lệnh đã chạy và toàn bộ lỗi.
