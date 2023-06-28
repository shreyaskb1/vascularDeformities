import numpy as np
from skimage.measure import label, regionprops
import cv2
import math
from skimage import morphology
from scipy.optimize import minimize
from scipy.ndimage import rotate, shift
from skimage.morphology import skeletonize


def remove_small_components(binary_image, min_size=1000):
    labeled_image = label(binary_image)
    for region in regionprops(labeled_image):
        if region.area < min_size:
            for coord in region.coords:
                binary_image[coord[0], coord[1]] = 0
                
    return binary_image

def blood_vessel_thickness(segmented_image):
    widths_image_1 = np.zeros(segmented_image.shape)
    widths_image_2 = np.zeros(segmented_image.shape)

    skeleton = skeletonize(segmented_image / 255)
    centerline_rows, centerline_cols = np.nonzero(skeleton)
    width_window_length = 100

    for i in range(len(centerline_rows)):
        cx = centerline_rows[i]
        cy = centerline_cols[i]


        if i == len(centerline_rows) - 1:
            prev_x = centerline_rows[i-1]
            prev_y = centerline_cols[i-1]
            slope =  - (cx - prev_x) / (cy - prev_y)

        else:   
            next_x = centerline_rows[i+1]
            next_y = centerline_cols[i+1]
            slope = - (next_x - cx) / (next_y - cy)

        delta_x = int(np.round(width_window_length / np.sqrt(1 + slope**2)))
        delta_y = int(np.round(slope * delta_x))
        start_x = max(0, cx - delta_x)
        start_y = max(0, cy - delta_y)
        end_x = min(segmented_image.shape[0] - 1, cx + delta_x)
        end_y = min(segmented_image.shape[1] - 1, cy + delta_y)

        line_points = list(zip(np.linspace(start_x, end_x, width_window_length), np.linspace(start_y, end_y, width_window_length)))
        line_points = np.round(line_points).astype(int)
        binary_values = segmented_image[line_points[:, 1], line_points[:, 0]] 
        width = np.sum(binary_values) / 255
        x_coords, y_coords = zip(*line_points)
        widths_image_1[y_coords, x_coords] = width

        delta_y = int(np.round(width_window_length / np.sqrt(1 + slope**2)))
        delta_x = int(np.round(slope * delta_y))
        start_x = max(0, cx - delta_x)
        start_y = max(0, cy - delta_y)
        end_x = min(segmented_image.shape[0] - 1, cx + delta_x)
        end_y = min(segmented_image.shape[1] - 1, cy + delta_y)

        line_points = list(zip(np.linspace(start_x, end_x, width_window_length), np.linspace(start_y, end_y, width_window_length)))
        line_points = np.round(line_points).astype(int)
        binary_values = segmented_image[line_points[:, 1], line_points[:, 0]] 
        width = np.sum(binary_values) / 255
        x_coords, y_coords = zip(*line_points)
        widths_image_2[y_coords, x_coords] = width
    
    return cv2.bitwise_and(np.uint8(np.add(widths_image_1, widths_image_2)), np.uint8(segmented_image))

def find_branchpoints(binary_image):
    skeleton = morphology.skeletonize(binary_image)
    endpoints = morphology.dilation(skeleton, morphology.square(3))
    branch_points = np.subtract(endpoints, skeleton)
    masked_image = np.where(branch_points, 255, 0)
    return masked_image



