#!/bin/bash

VIDEO_URL="https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"

# 檢查系統套件依賴
if ! command -v mpv &> /dev/null; then
    echo "[!] 系統尚未安裝 mpv，請先執行安裝："
    echo "    - macOS: brew install mpv caca"
    echo "    - Ubuntu/Debian: sudo apt update && sudo apt install -y mpv caca-utils"
    echo "    - Arch Linux: sudo pacman -S mpv caca"
    exit 1
fi

mpv --vo=caca --quiet "$VIDEO_URL"