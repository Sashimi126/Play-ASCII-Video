#!/bin/bash

VIDEO_URL="https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"
TEMP_FILE="temp_video.mp4"

# 保險機制：無論腳本正常結束、中途卡住按 Ctrl+C，都會強制刪除暫存檔
trap 'rm -f "$TEMP_FILE"' EXIT INT TERM

# 1. 檢查並自動安裝 mplayer 與 caca 套件
if ! command -v mplayer &> /dev/null; then
    echo "[*] 檢測到未安裝 mplayer，正在自動安裝中..."
    sudo apt update && sudo apt install -y mplayer caca-utils
fi

# 2. 下載影片至暫存檔
echo "[*] 正在下載影片..."
curl -sSL "$VIDEO_URL" -o "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
    echo "[!] 影片下載失敗，請檢查網路連線。"
    exit 1
fi

# 3. 使用 mplayer 播放（-loop 1 強制播放 1 次即關閉）
echo "[*] 開始播放..."
mplayer -vo caca -loop 1 -really-quiet "$TEMP_FILE"

echo "[*] 播放完成，已清理暫存檔。"