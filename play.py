import os
import platform
import shutil
import subprocess
import urllib.request

VIDEO_URL = "https://raw.githubusercontent.com/Sashimi126/Play-ASCII-Video/main/videos/gugugaga_1.mp4"
TEMP_FILE = f"temp_{os.getpid()}.mp4"


def is_termux():
    return os.path.exists("/data/data/com.termux")


def is_installed(cmd):
    # 使用 Python 原生 shutil.which 檢查指令是否存在
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


def main():
    install_dependencies()

    print("[*] 正在下載影片...")
    urllib.request.urlretrieve(VIDEO_URL, TEMP_FILE)

    print("[*] 開始播放 ASCII 影片...")
    os.system("clear" if platform.system() != "Windows" else "cls")

    if is_termux():
        os.environ["CACA_DRIVER"] = "ncurses"
        subprocess.run(["mpv", "--vo=caca", "--vid=1", "--quiet", TEMP_FILE])
    elif is_installed("mplayer"):
        subprocess.run(
            ["mplayer", "-vo", "caca", "-loop", "1", "-really-quiet", TEMP_FILE]
        )
    elif is_installed("mpv"):
        subprocess.run(["mpv", "--vo=caca", "--vid=1", "--quiet", TEMP_FILE])


if __name__ == "__main__":
    try:
        main()
    finally:
        if os.path.exists(TEMP_FILE):
            os.remove(TEMP_FILE)
        print("[*] 播放完成！")

