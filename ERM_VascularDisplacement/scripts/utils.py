import numpy as np
import os
import cv2
import matplotlib.pyplot as plt

def quiver_plot(img1, img2, dx, dy):
    x, y = np.meshgrid(np.arange(dx.shape[1]), np.arange(dx.shape[0]))
    plt.figure()
    plt.imshow(img1)
    plt.quiver(x, y, dx, dy, colositkr='red')
    plt.show()
    plt.figure()
    plt.imshow(img2)
  

def load_images(directory):
    images = []
    file_list = os.listdir(directory)
    file_list = [f for f in file_list if os.path.isfile(os.path.join(directory, f))]
    file_list.sort()
    file_paths = [os.path.join(directory, f) for f in file_list]

    for filename in file_paths:
      images.append(cv2.imread(filename, cv2.IMREAD_UNCHANGED))
    return images