from utils import load_images
from image_utils import align_rigid, find_branchpoints, remove_small_components, blood_vessel_thickness
from registration import register_bspline, register_rigid
import matplotlib
matplotlib.use('tkagg')
import matplotlib.pyplot as plt
from PIL import Image

preop_seg_imgs_path = '..\pre_op_segmented'
postop_seg_imgs_path = '..\post_op_segmented'

preop = load_images(preop_seg_imgs_path)
postop = load_images(postop_seg_imgs_path)

registration_method = 'bspline'

for i in range(len(preop)):
    img1 = remove_small_components(preop[i])
    img2 = remove_small_components(postop[i])
    new_img1, new_img2 = align_rigid(img1, img2)
    if registration_method == 'bspline':
       img = bspline_registration(new_img1, new_img2, i)
    
    # elif registration_method == 'bspline_keypoints':
        # keypoints1, keypoints2 = find_branchpoints(aligned_img1, img2)
        # registered, dx, dy = register_bspline(aligned_img1, img2, keypoints1, keypoints2)

