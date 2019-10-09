from matplotlib import pyplot as plt
import socket
import numpy as np
import array
if __name__ == '__main__':
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM )
    s.connect(("localhost", 8001))

    while True:
        im = bytearray()

        sz = s.recv(4)
        sz = int.from_bytes(sz, byteorder="little", signed=False)
        while len(im) < sz:
            im.extend(s.recv(1))
        print(sz,im.__len__())
