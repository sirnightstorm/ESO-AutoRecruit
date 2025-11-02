import subprocess
import re
import shutil
import os
import glob
import sys

def copy(wildcard, dest):
    for file in glob.glob(wildcard):
        print(file)
        shutil.copy(file, dest)


result = subprocess.run(['git', 'tag', '-l', '--contains', 'HEAD'], stdout=subprocess.PIPE)

version = result.stdout[1:].decode('utf-8').strip()
if version == "":
    print("Failed to get git version", file=sys.stderr)
    exit(1)

print(f"Version {version}")

versionMatch = re.search(r"^(\d+)\.(\d+)\.(\d+)", version)
addOnVersion = int(versionMatch.group(1))*10000 + int(versionMatch.group(2))*100 + int(versionMatch.group(3))

print(f"AddOnVersion {addOnVersion}")

if os.path.exists("_build/AutoRecruit"):
    shutil.rmtree('_build/AutoRecruit')

os.mkdir('_build/AutoRecruit')

copy(r'*.lua', '_build/AutoRecruit')
copy(r'*.txt', '_build/AutoRecruit')
copy(r'*.xml', '_build/AutoRecruit')

# shutil.copytree('media', '_build/AutoRecruit/media')
# shutil.copytree('lang', '_build/AutoRecruit/lang')

with open('AutoRecruit.addon', 'r') as inFile:
    txt = inFile.read()
    # txt = re.sub(r'## Version: \w+', f"## Version: {version}", txt)
    # txt = re.sub(r'## AddOnVersion: \w+', f"## AddOnVersion: {addOnVersion}", txt)
    with open('_build/AutoRecruit/AutoRecruit.addon', 'w') as outFile:
        outFile.write(txt)

with open('AutoRecruit.lua', 'r') as inFile:
    lua = inFile.read()
    lua = re.sub(r'appVersion = "[^"]*"', f'appVersion = "{version}"', lua)
    with open('_build/AutoRecruit/AutoRecruit.lua', 'w') as outFile:
        outFile.write(lua)

shutil.make_archive(f"_build/AutoRecruit-v{version}", 'zip', root_dir='_build', base_dir='AutoRecruit')
