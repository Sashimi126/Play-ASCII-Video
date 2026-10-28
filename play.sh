#!/bin/bash

# ================= 參數設定（請修改這裡） =================
GITHUB_USER="Sashimi126"
REPO_NAME="Play-ASCII-Video"
BRANCH="main"
FILE_PATH="video.mp4"
# ========================================================

VIDEO_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/${FILE_PATH}"

# 檢查系統套件依賴
if ! command -v mpv &> /dev/null; then
    echo "[!] 系統尚未安裝 mpv，請先執行安裝："
    echo "    - macOS: brew install mpv caca"
    echo "    - Ubuntu/Debian: sudo apt update && sudo apt install -y mpv caca-utils"
    echo "    - Arch Linux: sudo pacman -S mpv caca"
    exit 1
fi

echo "[*] 正在連線至 GitHub 串流播放 ASCII 影片與音訊..."
mpv --vo=caca --quiet "$VIDEO_URL"