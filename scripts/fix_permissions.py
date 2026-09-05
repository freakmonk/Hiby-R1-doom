import os, sys, stat, shutil

def fix_and_remove(path):
    if not os.path.exists(path):
        return
    print(f"Fixing permissions and removing: {path}")
    for root, dirs, files in os.walk(path, topdown=False):
        for name in files:
            p = os.path.join(root, name)
            try:
                os.chmod(p, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)
                os.remove(p)
            except Exception as e:
                pass
        for name in dirs:
            p = os.path.join(root, name)
            try:
                os.chmod(p, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)
                os.rmdir(p)
            except Exception as e:
                pass
    try:
        shutil.rmtree(path, ignore_errors=True)
    except Exception as e:
        pass

if __name__ == "__main__":
    for arg in sys.argv[1:]:
        fix_and_remove(arg)
