import asyncio
import websockets
import logging
import json
# from collections import deque
# import heapq
import time
import utils
import threading
import ml

logging.basicConfig(level=logging.INFO)

# type: key, connect, error, push
def make_msg(type_, data):
    return json.dumps({"type": type_, "data": data})

VIDEO_URL_TEMPLATE = "rtmp://localhost:1935/live/{}"

class WSSession:
    def __init__(self, sock, user):
        self.sock = sock
        self.streamURL = None
        self.inference_therad = None
        self.interrupted = False
        self.user = user
        self.count = [0]

    def dump(self):
        pass

    def destroy(self):
        if self.inference_therad is not None:
            logging.info("stopping inference thread")
            self.inference_therad.stop()

    async def send_counts(self):
        while True:
            # # send only when count is available
            # if self.inference_therad is not None:
            #     msg = make_msg('push', self.count)
            #     logging.info("sending count")
            #     await self.send_later(0.1, msg)
            # else:
            #     logging.info("count not available yet")
            #     await asyncio.sleep(0.5)
            msg = make_msg('push', self.count[0])
            logging.info("sending count")
            await self.send_later(0.3, msg)

    async def handle_message(self, obj):
        if obj['type'] == 'key':
            msg = make_msg("key", utils.get_key(self.user))
            asyncio.ensure_future(self.send_later(0, msg))
        elif obj['type'] == 'connected':
            # user connected to the stream server and start streaming
            # self.inference_thread = threading.Thread(target=utils.run_inference, args=(self.user, self.inference_cb))
            # self.inference_thread.start()
            self.inference_thread = ml.MLSession(input_=VIDEO_URL_TEMPLATE.format(self.user), callback=self.inference_cb)
            self.inference_thread.start()
            logging.info("MLSession return")
        else:
            # ignore unrecognized event
            pass

    def inference_cb(self, count):
        # logging.info("inference_cb {}".format(count))
        self.count[0] = count
        # self.loop.self.loop.call_soon_threadsafe(send_later)

    async def handle_error(self, err):
        await self.sock.send(make_err(str(err)))

    async def consumer_handler(self):
        async for message in self.sock:
            logging.info("server received user: {}, msg: {}".format(self.user, message))
            try:
                data = json.loads(message)
            except Exception:
                await self.handle_error("invalid json")
            await self.handle_message(data)

    async def send_later(self, delay, msg):
        await asyncio.sleep(delay)
        await self.sock.send(msg)

    async def producer_handler(self):
        while True:
            await self.send_counts()
            # cur_time = time.time()
            # while len(self.send_queue) > 0 and self.send_queue[0].time < cur_time:
            #     msg = heapq.heappop(self.send_queue).msg
            #     await websocket.send(msg)
            # await asyncio.sleep(0.1)

class Server:
    def __init__(self, addr='localhost', port=8765):
        self.addr = addr
        self.port = port
        self.clients = {}
        self.counter = 0

    def generate_id(self):
        self.counter += 1
        return self.counter

    async def handle_client(self, websocket, path):
        cid = self.generate_id()
        user = path.split("/")[-1] + str(cid)
        logging.info("client connected, path: {}, id: {}".format(path, cid))
        s = WSSession(websocket, user)
        self.clients[user] = s

        consumer_task = asyncio.ensure_future(
            s.consumer_handler())
        producer_task = asyncio.ensure_future(
            s.producer_handler())

        

        done, pending = await asyncio.wait(
            [consumer_task, producer_task],
            return_when=asyncio.FIRST_COMPLETED,
        )
        for task in pending:
            task.cancel()
        s.destroy()
        logging.info("connection closed, path: {}, id: {}".format(path, cid))
        del self.clients[user]

    def start(self):
        asyncio.get_event_loop().run_until_complete(
            websockets.serve(self.handle_client, self.addr , self.port))
        asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
    s = Server()
    s.start()


# # message types
# # login
# # request_key
# # listen
# # close
