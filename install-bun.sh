#!/usr/bin/env bash
# =============================================================================
# install-bun.sh — Cài đặt / nâng cấp Bun runtime
#                   Install / upgrade the Bun runtime
#
# EN: If Bun is already installed, upgrade Bun and refresh its global packages.
#     Otherwise install Bun from bun.sh and wire `node`/`npx` shims to it.
# VI: Nếu Bun đã được cài, nâng cấp Bun và các gói global. Nếu chưa, cài Bun
#     từ bun.sh và tạo shim `node`/`npx` trỏ tới Bun.
#
# Repo: https://github.com/hitechcloudvn/nvidia-spark
#       https://gitlab.com/hitechcloudvn/nvidia-spark
# =============================================================================
set -euo pipefail

if command -v bun >/dev/null 2>&1; then
    bun upgrade
    cd "${HOME}/.bun/install/global/"
    bun update
else
    curl -fsSL https://bun.sh/install | bash
    # The installer puts bun into ~/.bun/bin — refresh PATH before resolving it,
    # otherwise `which bun` is empty and the node symlink breaks.
    # Trình cài đặt đặt bun vào ~/.bun/bin — nạp lại PATH trước khi tìm đường
    # dẫn, nếu không `which bun` rỗng và symlink node sẽ hỏng.
    export PATH="${HOME}/.bun/bin:${PATH}"
    sudo ln -sf "$(command -v bun)" /usr/local/bin/node
    echo 'exec bunx "${@//-y /}"' | sudo tee /usr/local/bin/npx > /dev/null
    sudo chmod +x /usr/local/bin/npx
fi
