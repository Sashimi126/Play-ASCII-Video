#!/bin/bash
VIDEO_URL="https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"
TEMP_FILE="temp_$$.mp4"

# 自動清理暫存檔
trap 'rm -f "$TEMP_FILE"' EXIT INT TERM

# 判斷是否為 Termux
[ -d "/data/data/com.termux" ] && IS_TERMUX=true || IS_TERMUX=false

# 1. 自動依系統補齊套件
if $IS_TERMUX; then
    command -v mpv &>/dev/null || pkg install -y mpv libcaca pulseaudio curl
    pulseaudio --start 2>/dev/null
elif command -v apt &>/dev/null; then
    command -v mplayer &>/dev/null || (sudo apt update && sudo apt install -y mplayer caca-utils curl)
elif command -v brew &>/dev/null; then
    command -v mplayer &>/dev/null || brew install mplayer
fi

# 2. 下載影片
curl -sSL "$VIDEO_URL" -o "$TEMP_FILE" || exit 1

# 3. 播放 ASCII 影片
clear
if $IS_TERMUX; then
    export CACA_DRIVER=ncurses
    mpv --vo=caca --vid=1 --quiet "$TEMP_FILE"
else
    mplayer -vo caca -loop 1 -really-quiet "$TEMP_FILE" 2>/dev/null || mpv --quiet "$TEMP_FILE"
fi