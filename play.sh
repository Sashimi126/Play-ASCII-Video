#!/bin/bash

VIDEO_URL="https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"
TEMP_FILE="temp_video.mp4"

# 1. 檢查並自動安裝 mplayer 與 caca 套件
if ! command -v mplayer &> /dev/null; then
    echo "[*] 檢測到未安裝 mplayer，正在自動安裝中..."
    sudo apt update && sudo apt install -y mplayer caca-utils
fi

# 2. 下載影片至暫存檔（避免 https 串流相容問題）
echo "[*] 正在下載影片..."
curl -sSL "$VIDEO_URL" -o "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
    echo "[!] 影片下載失敗，請檢查網路連線。"
    rm -f "$TEMP_FILE"
    exit 1
fi

# 3. 使用 mplayer 以 ASCII 模式播放
echo "[*] 開始播放..."
mplayer -vo caca -really-quiet "$TEMP_FILE"

# 4. 清理暫存檔
rm -f "$TEMP_FILE"#!/bin/bash

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