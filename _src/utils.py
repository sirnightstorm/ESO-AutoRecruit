import glob
import subprocess
import shutil
import os
import sys
import re
import time

def copy(wildcard, dest):
    for file in glob.glob(wildcard):
        shutil.copy(file, dest)


def push(dest_dir, dir_list):
    if os.path.exists(dest_dir):
        shutil.rmtree(dest_dir)

    os.mkdir(dest_dir)

    copy(r'*.lua', dest_dir)
    copy(r'*.addon', dest_dir)
    copy(r'*.xml', dest_dir)

    for dir_name in dir_list:
        shutil.copytree(dir_name, f'{dest_dir}/{dir_name}')


def get_tag():
    result = subprocess.run(['git', 'tag', '-l', '--contains', 'HEAD'], stdout=subprocess.PIPE)
    version = result.stdout[1:].decode('utf-8').strip()
    return version


def convert_to_addon_version(version):
    version_match = re.search(r"^(\d+)\.(\d+)\.(\d+)", version)
    addon_version = int(version_match.group(1))*10000 + int(version_match.group(2))*100 + int(version_match.group(3))
    return addon_version


def get_line(file_string, prefix):
    lines = file_string.splitlines()
    for line in lines:
        if line.startswith(prefix):
            return line[len(prefix):].strip()
    return None

def get_addon_file_path(addon_name):
    home_dir = os.path.expanduser("~")
    if os.path.exists(f"{home_dir}/Documents/Elder Scrolls Online/live/AddOns/{addon_name}/{addon_name}.addon"):
        return f"{home_dir}/Documents/Elder Scrolls Online/live/AddOns/{addon_name}/{addon_name}.addon"
    elif os.path.exists(f"{home_dir}/Documents/Elder Scrolls Online/live/AddOns/{addon_name}/{addon_name}.txt"):
        return f"{home_dir}/Documents/Elder Scrolls Online/live/AddOns/{addon_name}/{addon_name}.txt"
    return None

def get_other_addon_version(addon_name):
    home_dir = os.path.expanduser("~")
    with open(get_addon_file_path(addon_name), 'r') as file:
        txt = file.read()
        ver_line = get_line(txt, "## AddOnVersion:")
        return ver_line


def check_dependencies(addon_name, depends_prefix, essential):
    with open(f"{addon_name}.addon", 'r') as file:
        txt = file.read()
        depends_on_line = get_line(txt, depends_prefix)
        if not depends_on_line:
            if essential:
                print("🛑 No OptionalDependsOn line found", file=sys.stderr)
                exit(1)
            else:
                return
        components = depends_on_line.split()
        split_items = [item.split(">=") for item in components]
        for name, version in split_items:
            current_version = get_other_addon_version(name)
            if version != current_version:
                print(f"⚠️ Addon {name} version mis-match: ours: {version}, theirs: {current_version}", file=sys.stderr)

# https://github.com/pywinauto/pywinauto
from pywinauto.application import Application
from pywinauto.keyboard import send_keys
from pywinauto.findwindows import ElementNotFoundError

def reload_eso(reloadui_keys):
    try:
        app = Application().connect(title_re="Elder Scrolls Online", class_name="EsoClientWndClass")
        win = app.window(title='Elder Scrolls Online')

        win.restore()
        win.set_focus()

        time.sleep(0.2)

        active_app = Application().connect(active_only=True)
        active_win = active_app.top_window()
        print(f"ESO: {win.window_text()}")
        print(f"Active: {active_win.window_text()}")
        if win.window_text() == active_win.window_text():
            send_keys(reloadui_keys, vk_packet=False)
        else:
            print("ESO not active")
    except ElementNotFoundError as e:
        print("ESO not running")