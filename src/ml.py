import torch.nn as nn
import torch.nn.functional as F

class Net(nn.Module):
    '''
    Class contains CNN model architecture
    '''
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(3, 6, 3)
        self.pool = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(6, 16, 3)

        self.conv3 = nn.Conv2d(16, 32, 5)
        self.conv4 = nn.Conv2d(32, 64, 5)

        self.dropout = nn.Dropout(0.3)

        self.fc1 = nn.Linear(64 * 27 * 27, 512)
        self.bnorm1 = nn.BatchNorm1d(512)

        self.fc2 = nn.Linear(512, 128)
        self.bnorm2 = nn.BatchNorm1d(128)

        self.fc3 = nn.Linear(128, 64)
        self.bnorm3 = nn.BatchNorm1d(64)

        self.fc4 = nn.Linear(64, 3)

    def forward(self, x):
        x = F.relu(self.conv1(x))

        x = self.pool(F.relu(self.conv2(x)))

        x = F.relu(self.conv3(x))
        x = self.pool(F.relu(self.conv4(x)))

        x = x.view(-1, 64 * 27 * 27)
        x = self.dropout(x)
        x = F.relu(self.bnorm1(self.fc1(x)))
        x = F.relu(self.bnorm2(self.fc2(x)))
        x = F.relu(self.bnorm3(self.fc3(x)))
        x = self.fc4(x)
        return x

import cv2
import matplotlib.pyplot as plt

# from Net import Net
import torch
import torchvision.transforms as transforms

import numpy as np
import argparse
import os
import time
import threading
import logging

class Model:
    def __init__(self, model_path):
        self.takeFrame = 2
        self.IM_SIZE = (128, 128)

        self.model_path = model_path

        # loading model and image transforms
        self.net = Net()
        self.net.load_state_dict(torch.load(model_path))
        self.net.eval()


model = Model(os.path.dirname(__file__) + "/../model/model.pt")

def getOptFlow(flow, prev_gray, gray, mask):
    '''
    Returns image with dense optical flow image
    :param flow: previous optical flow value
    :param prev_gray: previous frame gray image
    :param gray: current frame gray image
    :param mask:
    :return: opt flow image, new mask, new opt flow object
    '''
    if len(flow) == 0:
        flow = cv2.calcOpticalFlowFarneback(prev_gray, gray, None, 0.5, 3, 100, 3, 7, 1.1, 0)
    else:
        flow = cv2.calcOpticalFlowFarneback(prev_gray, gray, flow, 0.5, 3, 100, 3, 7, 1.1, 0)

    # Computes the magnitude and angle of the 2D vectors
    magnitude, angle = cv2.cartToPolar(flow[..., 0], flow[..., 1])

    # Sets image hue according to the optical flow direction
    mask[..., 0] = angle * 180 / np.pi / 2

    # Sets image value according to the optical flow magnitude (normalized)
    mask[..., 2] = cv2.normalize(magnitude, None, 0, 255, cv2.NORM_MINMAX)

    # Converts HSV to RGB (BGR) color representation
    rgb = cv2.cvtColor(mask, cv2.COLOR_HSV2BGR)

    return rgb, mask, flow

def readFrame(cap, IMG_SIZE=(128, 128)):
    '''
    Reads the next frame using cap from cv2.VideoCapture
    :param cap: cv2.VideoCapture instance
    :param IMG_SIZE: size of the returned image
    :return: Returns frame and its gray analog
    '''

    ret, origFrame = cap.read()
    if ret:
        #frame = cv2.resize(origFrame, (128, 128))
        frame = cv2.resize(origFrame, IMG_SIZE)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    else:
        return None, None, None

    return origFrame, frame, gray

def prepareTransforms():
    '''
    Prepares transformers for image preprocessing
    :return: transformers for preprocessing
    '''
    transform = transforms.Compose(
        [
            transforms.ToPILImage(),
            transforms.ToTensor(),
            transforms.Normalize(mean=(0.5,), std=(0.5,))
        ])

    return transform

def contains(a, b):
    '''
    Checks if array b is a subsequence of array a
    :param a:
    :param b:
    :return: returns True if array b is a subsequence of a, else False
    '''
    for i in range(a.shape[0] - b.shape[0] + 1):
        if (a[i:i + b.shape[0]] == b).all():
            return True
    return False

def getMovesCount(labels, moves, sequence = [0, 0, 0, 2, 2, 2]):
    '''
    If the current label sequence contains the move label sequence clear label sequence and add 1 push up to the moves
    counter
    :param labels: Current CNN prediction sequence
    :param moves: Current number of moves
    :param sequence: The move sequence to search for in the labels sequence
    :return: current label sequnce and total move count
    '''
    if contains(np.array(labels)[np.array(labels) != 1], np.array(sequence)):
        labels = [1, 1, 1, 1, 1]
        moves += 1
    return labels, moves

class MLSession:
    def __init__(self, model=model, input_="/tmp/out.mp4", max_time=None, max_retry=5, callback=None):
        self.video = input_
        # open stream or video
        self.transform = prepareTransforms()
        self.model = model
        self.thread = None
        self.interrupted = False
        self.thread = threading.Thread(target=self.run_pipeline, args=())
        # read from outside
        self.moves = 0
        self.start_time = 0
        self.running = False
        self.max_retry = max_retry
        self.callback = callback

    def start(self):
        self.thread.start()

    def stop(self):
        self.interrupted = True
    
    def join(self):
        # TODO: this may cause freeze
        self.thread.join()

    def run_pipeline(self):
        # open stream or video
        # cap = cv2.VideoCapture("rtmp://localhost:1935/live/test_client1")
        cap = cv2.VideoCapture(self.video)
        retry = 0
        while not cap.isOpened() and retry < self.max_retry:
            if self.interrupted:
                cap.release()
                return
            logging.warn("stream open failed, retry")
            cap = cv2.VideoCapture(self.video)
            retry += 1
            time.sleep(1)

        if not cap.isOpened():
            logging.error("stream open failed, all retry failed")
            self.running = False
            return

        # read first frame
        origFrame, first_frame, prev_gray = readFrame(cap)

        # setup things
        mask = np.zeros_like(first_frame)
        mask[..., 1] = 255
        frameIndex = 0
        flow = []
        labels = [1, 1, 1, 1, 1]

        self.start_time = time.time()
        self.running = True
        logging.info("pipeline started")

        frame = first_frame
        gray = prev_gray

        while cap.isOpened() and frame is not None and not self.interrupted:
            rgb, mask, flow = getOptFlow(flow, prev_gray, gray, mask)

            if frameIndex % 2 == 0 and frameIndex > 0:
                image = cv2.cvtColor(rgb, cv2.COLOR_BGR2RGB)
                x = self.transform(image).reshape(1, 3, 128, 128)
                res = np.argmax(self.model.net(x).detach().numpy())
                labels.append(res)
                labels, self.moves = getMovesCount(labels, self.moves)
                if self.callback is not None:
                    self.callback(self.moves)

            prev_gray = gray
            frameIndex += 1
            # print(frameIndex, self.moves)

            origFrame, frame, gray = readFrame(cap)
        cap.release()
        self.running = False

if __name__ == "__main__":
    model = Model("/<...>/model.pt")
    s = MLSession(model)
    s.start()
    # time.sleep(5)
    # s.stop()
    s.join()
