#!/bin/bash

VIDEO_URL="https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"
TEMP_FILE="temp_video_$$.mp4"

# 安全清理機制：不論正常結束或按 Ctrl+C 中斷，一律自動刪除暫存檔
trap 'rm -f "$TEMP_FILE"' EXIT INT TERM

# 1. 自動偵測環境並安裝相依套件 (mplayer & caca)
install_dependencies() {
    if ! command -v mplayer &> /dev/null; then
        echo "[*] 檢測到尚未安裝 mplayer，正在辨識系統並自動安裝..."
        
        if command -v pkg &> /dev/null; then
            # Termux (Android)
            echo "[*] 偵測到 Termux 環境..."
            pkg update -y && pkg install -y mplayer libcaca curl
        elif command -v brew &> /dev/null; then
            # macOS (Homebrew)
            echo "[*] 偵測到 macOS 環境..."
            brew install mplayer
        elif command -v apt &> /dev/null; then
            # Ubuntu / Debian / WSL
            echo "[*] 偵測到 Ubuntu/Debian/WSL 環境..."
            sudo apt update && sudo apt install -y mplayer caca-utils curl
        elif command -v pacman &> /dev/null; then
            # Arch Linux
            echo "[*] 偵測到 Arch Linux 環境..."
            sudo pacman -Sy --noconfirm mplayer caca curl
        else
            echo "[!] 未知系統，請手動安裝 mplayer 與 caca 套件後再試。"
            exit 1
        fi
    fi
}

install_dependencies

# 2. 下載影片暫存檔
echo "[*] 正在下載影片..."
curl -sSL "$VIDEO_URL" -o "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
    echo "[!] 影片下載失敗，請檢查網路連線。"
    exit 1
fi

# 3. 執行 ASCII 播放
echo "[*] 開始播放 ASCII 影片..."
mplayer -vo caca -loop 1 -really-quiet "$TEMP_FILE"

echo "[*] 播放完成！"