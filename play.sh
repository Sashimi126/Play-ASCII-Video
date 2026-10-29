#!/bin/bash

VIDEO_URL="https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"
TEMP_FILE="temp_video_$$.mp4"

# 安全清理機制：離開時自動清理暫存檔
trap 'rm -f "$TEMP_FILE"' EXIT INT TERM

# 1. 判斷是否為 Termux 環境
IS_TERMUX=false
if command -v pkg &> /dev/null || [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
fi

# 2. 自動偵測環境與安裝套件
if $IS_TERMUX; then
    echo "[*] 偵測到 Termux 環境，自動安裝 mpv、libcaca 與 pulseaudio..."
    pkg update -y && pkg install -y mpv libcaca pulseaudio curl
    # 啟動 Termux 背景音訊服務
    pulseaudio --start --exit-idle-time=-1 2>/dev/null
elif command -v brew &> /dev/null; then
    if ! command -v mplayer &> /dev/null && ! command -v mpv &> /dev/null; then
        echo "[*] 偵測到 macOS，安裝 mplayer..."
        brew install mplayer
    fi
elif command -v apt &> /dev/null; then
    if ! command -v mplayer &> /dev/null; then
        echo "[*] 偵測到 Ubuntu/WSL，安裝 mplayer..."
        sudo apt update && sudo apt install -y mplayer caca-utils curl
    fi
elif command -v pacman &> /dev/null; then
    if ! command -v mplayer &> /dev/null; then
        sudo pacman -Sy --noconfirm mplayer caca curl
    fi
fi

# 3. 下載影片
echo "[*] 正在下載影片..."
curl -sSL "$VIDEO_URL" -o "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
    echo "[!] 影片下載失敗，請檢查網路連線。"
    exit 1
fi

# 4. 根據系統動態選擇最合適的播放器與驅動
echo "[*] 開始播放 ASCII 影片..."

if $IS_TERMUX; then
    # Termux: 使用 mpv + caca 模式
    unset CACA_DRIVER
    mpv --vo=caca --quiet "$TEMP_FILE"
elif command -v mplayer &> /dev/null && mplayer -vo help 2>&1 | grep -q 'caca'; then
    # Ubuntu/Debian/WSL: 使用 mplayer + caca 模式
    mplayer -vo caca -loop 1 -really-quiet "$TEMP_FILE"
elif command -v mpv &> /dev/null && mpv --vo=help 2>&1 | grep -q 'caca'; then
    mpv --vo=caca --quiet "$TEMP_FILE"
elif command -v mpv &> /dev/null; then
    mpv --quiet "$TEMP_FILE"
else
    mplayer -really-quiet "$TEMP_FILE"
fi

echo "[*] 播放完成！"