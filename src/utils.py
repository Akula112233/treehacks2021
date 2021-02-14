import requests
import logging
import subprocess
import re
import os

logging.basicConfig(level=logging.INFO)

KEY_URL_TEMPLATE = "http://localhost:8090/control/get?room={}"
VIDEO_URL_TEMPLATE = "rtmp://localhost:1935/live/{}"

CUR_DIR = os.path.dirname(__file__)

def get_key(user):
    try:
        res = requests.get(KEY_URL_TEMPLATE.format(str(user)))
        j = res.json()
    except Exception as e:
        logging.info("get key failed: {}".format(e))
        return None
    if j['status'] == 200:
        return j['data']
    else:
        logging.info("get key failed: {}".format(res.content))
        return None

# DEPRECATED, DO NOT USE !!!
# run inference code in another process
# callback get invoked every time when it get recognized
def run_inference(user, callback):
    cmds = ["python3", CUR_DIR + "/ml/Inference.py", "--file", VIDEO_URL_TEMPLATE.format(user)]
    # print(" ".join(cmds))
    # exit()
    p = subprocess.Popen(cmds, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=os.environ.copy())
    line = p.stdout.readline()
    logging.info(line)
    while line is not None:
        line = p.stdout.readline()
        logging.info(line)
        res = re.search(b"frame: ([0-9]+)", line)
        if res:
            frame = int(res.group(1))
        else:
            frame = None
        res = re.search(b"moves: ([0-9]+)", line)
        if res:
            moves = int(res.group(1))
        else:
            moves = None
        # logging.info("!!! frame: {}, moves: {}".format(frame, moves))
        callback(frame, moves)
    callback(None, None)

if __name__ == "__main__":
    print(os.path.dirname(__file__))