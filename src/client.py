import asyncio
import websockets
import json
import logging

logging.basicConfig(level=logging.INFO)

STREAM_URL_TEMPLATE = "rtmp://localhost:1935/live/{}"
SERVE_CMD = "ffmpeg -re -i out.mp4 -c copy -an -f flv rtmp://localhost:1935/live/{}"

# type: key, connect, error, push
def make_msg(type_, data):
    return json.dumps({"type": type_, "data": data})

async def kill_self_later(t):
    await asyncio.sleep(t)
    exit()

async def recv_task(ws):
    received_key = False
    while True:
        res = await ws.recv()
        j = json.loads(res)
        if j['type'] == 'key':
            received_key = True
            print(SERVE_CMD.format(j['data']))
            await asyncio.sleep(10)
        if received_key:
            print("client: received: {}".format(res))

async def hello(uri):
    # asyncio.ensure_future(kill_self_later(60))
    counter = 0
    async with websockets.connect(uri + "/test_client") as websocket:
        asyncio.ensure_future(recv_task(websocket))
        await websocket.send(make_msg("key", ""))
        await asyncio.sleep(10)
        await websocket.send(make_msg("connected", ""))
        await asyncio.sleep(100)
        # while True:
        #     await websocket.send("Hello world! " + str(counter))
        #     counter += 1
        #     await asyncio.sleep(1)


asyncio.get_event_loop().run_until_complete(
    hello('ws://localhost:8765'))
