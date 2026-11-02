import atexit
import os
import platform
import shutil
import signal
import subprocess
import sys
import tempfile
import urllib.request

# 1. 影片資料庫（可自行新增更多影片短代號與網址）
VIDEO_LIBRARY = {
    "1": {
        "name": "咕咕嘎嘎 1",
        "url": "https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4",
    }
}

DEFAULT_KEY = "1"
TEMP_FILE = os.path.join(
    tempfile.gettempdir(), f"ascii_video_{os.getpid()}.mp4"
)


def cleanup():
    if os.path.exists(TEMP_FILE):
        try:
            os.remove(TEMP_FILE)
        except Exception:
            pass


atexit.register(cleanup)


def handle_signal(sig, frame):
    cleanup()
    sys.exit(0)


signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)


def is_termux():
    return os.path.exists("/data/data/com.termux")


def is_installed(cmd):
    return shutil.which(cmd) is not None


def install_dependencies():
    if is_termux():
        if not is_installed("mpv"):
            subprocess.run(["pkg", "update", "-y"])
            subprocess.run(
                ["pkg", "install", "-y", "mpv", "libcaca", "pulseaudio"]
            )
        subprocess.run(["pulseaudio", "--start"], stderr=subprocess.DEVNULL)
    elif platform.system() == "Linux":
        if not is_installed("mplayer") and not is_installed("mpv"):
            subprocess.run(["sudo", "apt", "update"])
            subprocess.run(
                ["sudo", "apt", "install", "-y", "mplayer", "caca-utils"]
            )
    elif platform.system() == "Darwin":
        if not is_installed("mplayer") and not is_installed("mpv"):
            subprocess.run(["brew", "install", "mplayer"])


def read_tty_input(prompt):
    """確保在 curl | python 管道下仍能讀取使用者鍵盤輸入"""
    print(prompt, end="", flush=True)
    try:
        with open("/dev/tty", "r") as tty:
            return tty.readline().strip()
    except Exception:
        return sys.stdin.readline().strip()


def resolve_video_url():
    """判斷要播放哪部影片"""
    # 檢查是否傳入參數（例如: python3 - 2 或 python3 - https://...）
    args = [a for a in sys.argv[1:] if a != "-"]
    if args:
        target = args[0]
        if target.startswith("http://") or target.startswith("https://"):
            return target
        if target in VIDEO_LIBRARY:
            return VIDEO_LIBRARY[target]["url"]

    # 若無參數且有多部影片，顯示選單
    print("\n==== 請選擇要播放的 ASCII 影片 ====")
    for key, info in VIDEO_LIBRARY.items():
        if key.isdigit():
            print(f" [{key}] {info['name']}")
    print("===================================")

    choice = read_tty_input("請輸入編號 (預設 1): ")
    if not choice:
        choice = DEFAULT_KEY

    return VIDEO_LIBRARY.get(choice, VIDEO_LIBRARY[DEFAULT_KEY])["url"]


def main():
    install_dependencies()
    video_url = resolve_video_url()

    print(f"\n[*] 正在下載影片: {video_url}")
    urllib.request.urlretrieve(video_url, TEMP_FILE)

    print("[*] 開始播放 ASCII 影片...")
    os.system("clear" if platform.system() != "Windows" else "cls")

    tty_stdin = None
    try:
        tty_stdin = open("/dev/tty", "rb")
    except Exception:
        tty_stdin = sys.stdin

    try:
        if is_termux():
            os.environ["CACA_DRIVER"] = "ncurses"
            subprocess.run(
                ["mpv", "--vo=caca", "--vid=1", "--quiet", TEMP_FILE],
                stdin=tty_stdin,
            )
        elif is_installed("mplayer"):
            subprocess.run(
                [
                    "mplayer",
                    "-vo",
                    "caca",
                    "-loop",
                    "1",
                    "-really-quiet",
                    TEMP_FILE,
                ],
                stdin=tty_stdin,
            )
        elif is_installed("mpv"):
            subprocess.run(
                ["mpv", "--vo=caca", "--vid=1", "--quiet", TEMP_FILE],
                stdin=tty_stdin,
            )
    finally:
        if tty_stdin and tty_stdin != sys.stdin:
            tty_stdin.close()


if __name__ == "__main__":
    try:
        main()
    finally:
        cleanup()
        print("[*] 播放結束，已清理暫存檔！")

