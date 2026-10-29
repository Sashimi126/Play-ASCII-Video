#!/bin/bash

VIDEO_URL="https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"
TEMP_FILE="temp_video_$$.mp4"

# 安全清理機制
trap 'rm -f "$TEMP_FILE"' EXIT INT TERM

# 1. 自動偵測環境並安裝相依套件
install_dependencies() {
    if ! command -v mplayer &> /dev/null && ! command -v mpv &> /dev/null; then
        echo "[*] 正在檢測系統並自動安裝播放器..."
        
        if command -v pkg &> /dev/null; then
            # Termux (Android)
            echo "[*] 偵測到 Termux 環境..."
            pkg update -y && pkg install -y mplayer libcaca curl
        elif command -v brew &> /dev/null; then
            # macOS
            brew install mplayer
        elif command -v apt &> /dev/null; then
            # Ubuntu / Debian / WSL
            sudo apt update && sudo apt install -y mplayer caca-utils curl
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            sudo pacman -Sy --noconfirm mplayer caca curl
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "mingw"* ]]; then
            # Windows 原生 (Git Bash)
            winget install --id=io.mpv.mpv -e --accept-source-agreements --accept-package-agreements
        else
            echo "[!] 未知系統，請手動安裝 mplayer 或 mpv。"
            exit 1
        fi
    fi
}

install_dependencies

# 2. 下載影片
echo "[*] 正在下載影片..."
curl -sSL "$VIDEO_URL" -o "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
    echo "[!] 影片下載失敗，請檢查網路連線。"
    exit 1
fi

# 3. 專為 Termux 與 Linux/macOS 處理播放邏輯
echo "[*] 開始播放 ASCII 影片..."

if command -v pkg &> /dev/null || [ -d "/data/data/com.termux" ]; then
    # Termux 專屬設定：強制文字渲染，忽略音訊卡死
    export CACA_DRIVER=ncurses
    mplayer -vo caca -ao null -loop 1 -really-quiet "$TEMP_FILE"
elif command -v mplayer &> /dev/null && mplayer -vo help 2>&1 | grep -q 'caca'; then
    mplayer -vo caca -loop 1 -really-quiet "$TEMP_FILE"
elif command -v mpv &> /dev/null; then
    mpv --quiet "$TEMP_FILE"
else
    mplayer -really-quiet "$TEMP_FILE"
fi

echo "[*] 播放完成！"