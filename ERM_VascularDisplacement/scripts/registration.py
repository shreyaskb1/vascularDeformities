import SimpleITK as sitk  
import numpy as np
import matplotlib.pyplot as plt

def register_bspline(fixed_image, moving_image):
    elastixImageFilter = sitk.ElastixImageFilter()
    elastixImageFilter.SetFixedImage(sitk.GetImageFromArray(fixed_image))
    elastixImageFilter.SetMovingImage(sitk.GetImageFromArray(moving_image))

    parameterMapVector = sitk.VectorOfParameterMap()
    parameterMapVector.append(sitk.GetDefaultParameterMap("affine"))
    parameterMapVector.append(sitk.GetDefaultParameterMap("bspline"))
    elastixImageFilter.SetParameterMap(parameterMapVector)

    elastixImageFilter.Execute()
    sitk.WriteImage(elastixImageFilter.GetResultImage())


    
def register_rigid(fixed_image, moving_image):
    elastixImageFilter = sitk.ElastixImageFilter()
    elastixImageFilter.SetFixedImage(sitk.GetImageFromArray(fixed_image))
    elastixImageFilter.SetMovingImage(sitk.GetImageFromArray(moving_image))
    elastixImageFilter.SetParameterMap(sitk.GetDefaultParameterMap("rigid"))
    elastixImageFilter.Execute()
    return sitk.GetArrayFromImage(elastixImageFilter.GetResultImage())