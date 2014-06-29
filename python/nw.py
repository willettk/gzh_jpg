import numpy as np
from math import asinh

#+
#NAME:
#  nw_arcsinh_fit
#PURPOSE:
#  scales the fits image by a degree of nonlinearity specified by user
#INPUTS:
#  colors      - (NXxNYx3) array that contains the R/G/B images
#OPTIONAL INPUTS:
#  nonlinearity- 'b'
#              - b=0 for linear fit, b=Inf for logarithmic
#              - default is 3
#KEYWORDS:
#
#OUTPUTS:
#  The image
#BUGS:
#  
#REVISION HISTORY:
#  11/07/03 written - wherry
#  11/12/03 changed radius - wherry
#-

def arcsinh_fit(colors,nonlinearity=3.):
    
    color_arr = np.array(colors)

    radius = color_arr.sum(axis=0)
    radius[radius == 0] += 1

    val = asinh(radius*nonlinearity)/nonlinearity if nonlinearity != 0. else 0.
    
    fitted_colors = color_arr * val / radius

    return fitted_colors

#+
#NAME:
#  nw_fit_to_box
#PURPOSE:
#  Limits the pixel values of the image to a 'box', so that the colors
#  do not saturate to white but to a specific color.
#INPUTS:
#  colors      - (NXxNYx3) array that contains the R/G/B images
#OPTIONAL INPUTS:
#  origin      - (3x1) array containing R0/G0/B0
#              - default is [0,0,0]
#KEYWORDS:
#
#OUTPUTS:
#  The color limited image
#BUGS:
#  
#REVISION HISTORY:
#  11/07/03 written - wherry
#  11/12/03 changed default origin - wherry
#-
def fit_to_box(colors,origin=[0,0,0]):

    color_arr = np.array(colors)
    nx,ny = color_arr.shape
    
    # Creates an 'origin' array
    origin_arr = np.zeros_like(color_arr)
    for idx,o in enumerate(origin):
       origin_arr[idx,:,:] = o

    pos_dist = 1 - origin_arr
    
    factor = (color_arr / pos_dist).max(axis=0)
    factor[factor < 1.0] = 1.0

    boxed_colors = colors / factor

    return boxed_colors


#+
#NAME:
#  nw_float_to_byte
#PURPOSE:
#  Converts floats of an array to bytes
#INPUTS:
#  image       - image array
#OPTIONAL INPUTS:
#  none
#KEYWORDS:
#  none
#OUTPUTS:
#  The float-value image
#REVISION HISTORY:
#  10/03/03 written - wherry
#-
def float_to_byte(image):
    byte_image = bytearray(image)
    return byte_image


#+
#NAME:
#  nw_scale_rgb
#PURPOSE:
#  mulitiplies the RGB image by their respective scales
#CALLING SEQUENCE:
#  nw_scale_rgb, colors, [scales=]
#INPUTS:
#  colors      - (NXxNYx3) array containing the R, G, and B
#OPTIONAL INPUTS:
#  scales      - (3x1) array to scale the R/G/B
#              - defaults are [4.9,5.7,7.8]
#KEYWORDS:
#  none
#OUTPUTS:
#  The RGB image 
#BUGS:
#  
#DEPENDENCIES:
#
#REVISION HISTORY:
#  11/07/03 written - wherry
#-
def scale_rgb(colors,scales=[4.9,5.7,7.8]):

    scaled_colors = np.zeros_like(colors)
    for idx,s in enumerate(scales):
        scaled_colors[idx,:,:] = colors[idx,:,:] * s
    
    return scaled_colors
