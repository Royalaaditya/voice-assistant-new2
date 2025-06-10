import os, zipfile, subprocess, json, time, pathlib, sys

ZIP = "voice_assistant_new2.zip"
REPO = "voice-assistant-new2"
USER = "Royalaaditya"
POLL = 30
APK_DIR = "apk_new2"

# unzip
if not os.path.exists(REPO):
    with zipfile.ZipFile(ZIP, 'r') as z:
        z.extractall(REPO)

os.chdir(REPO)
subprocess.run(["git", "init"])
subprocess.run(["git", "config", "user.email", "bot@example.com"])
subprocess.run(["git", "config", "user.name", "AutoBot"])
subprocess.run(["git", "add", "."])
subprocess.run(["git", "commit", "-m", "init"])
subprocess.run(["gh", "repo", "create", f"{USER}/{REPO}", "--public", "--source=.", "--remote=origin", "--push"])

print("⏳ waiting build...")
while True:
    out = subprocess.run(["gh", "run", "list", "--limit", "1", "--json", "status,conclusion,id"], capture_output=True, text=True)
    run = json.loads(out.stdout)[0]
    if run["status"] == "completed":
        if run["conclusion"] != "success":
            sys.exit("Build failed")
        rid = str(run["id"]); break
    time.sleep(POLL)

path = pathlib.Path("..") / APK_DIR
path.mkdir(exist_ok=True)
subprocess.run(["gh", "run", "download", rid, "-n", "app-release-apk", "-D", str(path)])
print(f"✅ APK downloaded to {path}")
