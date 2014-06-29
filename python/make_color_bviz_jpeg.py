__credits__ = '''Written by Kyle Willett (willettk@gmail.com); adapted from code by Taro Sato and Steven Bamford'''

import Image as I
import numpy as np
import nw

try:
    from astropy.io import fits as P
except:
    import pyfits as P

basepath = '..'

jpg_path  = '%s/jpg_thumb' % basepath
tiff_path = '%s/tiff_thumb' % basepath
fits_path = '%s/fits_thumb' % basepath

def make_color_jpeg_bviz(gal,ascales,anonlinearity,aresizefactor):

    input_oid = gal['UID_MOSAIC']
    id_str = 'g%s' % input_oid
    print '----------------- %s --------------------' % id_str


    # Get the amount by which we need to resize the image
    # Consider all bands
    a_pix = max(gal['A_IMAGE_Z'], gal['A_IMAGE_I'], gal['A_IMAGE_V'], gal['A_IMAGE_B'])
    kron_r = max(gal['KRON_RADIUS_Z'], gal['KRON_RADIUS_I'], gal['KRON_RADIUS_V'], gal['KRON_RADIUS_B'])
    obj_size_pix = a_pix * kron_r
    
    img_size_hstpix = 2.7 * obj_size_pix
    
    # Sanity checks -- don't zoom in too far
    img_size_hstpix = max(img_size_hstpix, 120.)
    
    # Sanity checks -- don't zoom out too far
    img_size_hstpix = min(img_size_hstpix, 1000.)
    
    aresizefactor = npix_final / img_size_hstpix

    # Print re-sizing parameters to screen
    print a_pix, kron_r, img_size_hstpix, aresizefactor

    # Load FITS data from existing cutouts

    with fits.open('%s/%s_s%s_thumb.fits' % (basepath,id_str,'b')) as f:
        img_b = f[0].data
    with fits.open('%s/%s_s%s_thumb.fits' % (basepath,id_str,'v')) as f:
        img_v = f[0].data
    with fits.open('%s/%s_s%s_thumb.fits' % (basepath,id_str,'i')) as f:
        img_i = f[0].data
    with fits.open('%s/%s_s%s_thumb.fits' % (basepath,id_str,'z')) as f:
        img_z = f[0].data

    # Check that all image sizes and shapes match
    # If all images don't exist, return assertion error

    assert img_b.shape == img_v.shape == img_i.shape == img_z.shape, \
        'Array sizes must be the same shape\n B:%s, V:%s, I:%s, Z:%s' % \
        (img_b.shape,img_v.shape,img_i.shape,img_z.shape)

    # If one out of four images doesn't exist, just erase the color (NOT YET IMPLEMENTED)
    
    rimage = img_z
    gimage = img_i
    bimage = np.array([img_b,img_v]).mean(axis=0)

    nx,ny = rimage.shape

    RGBim = np.array([rimage,gimage,bimage])
    
    RGBim_scaled = nw.scale_rgb(RGBim,scales=ascales)
    RGBim_arcsinh = nw.arcsinh_fit(RGBim_scaled,nonlinearity=anonlinearity)
    RGBim_boxed = nw.fit_to_box(RGBim_arcsinh,origin=aorigin)
    RGBim_byte = nw.float_to_byte(RGBim_byte)

    # rebin
    # okay, all this currently does is resize the whole thing
    # that's great, but my final product needs to be an image
    # of the same pixel size as before -- so I need to e.g. cut
    # everything but the central 424 x 424, etc.
    # I think I can do that without too much issue... I hope.

    RGBim_rebinned = rebin(RGBim_byte,floor(nx*aresizefactor),(ny*aresizefactor),3)

    # make image

    img = I.new('RGB',size=RGBim_rebinned.shape)
    img

    outjpg = '%s/%s_bviz_thumb.jpg' % (jpg_path,id_str)
    outtiff = '%s/%s_bviz_thumb.tiff' % (tiff_path,id_str)
    tiff_desc = 'RA = %15.6f # DEC = %15.6f' % (gal['alpha_j2000_b'],gal['delta_j2000_b'])
    WRITE_JPEG,outjpg,RGBim,TRUE=3,QUALITY=100


    # WRITE_JPEG and WRITE_TIFF need different array formats - awesome
    # plus, tiff images are usually read upside-down so needs to be flipped
    #            TIFFim = FLTARR(3, 3*nx, ny, /NOZERO) #make interleaved array
    #        TIFFim = FLTARR(3, nx, ny, /NOZERO) #make interleaved array
    #        TIFFim[0, *, *] = REVERSE(RGBim[*,*,0],2)
    #        TIFFim[1, *, *] = REVERSE(RGBim[*,*,1],2)
    #        TIFFim[2, *, *] = REVERSE(RGBim[*,*,2],2)
    
    #        print tiff_desc
    #        WRITE_TIFF,outtiff,TIFFim,DESCRIPTION=tiff_desc

    return None

def run_all_images():

    # set parameters - pretty much trial and error here
    # for H (f160w), (H+J)/2, J (f125w)
    #scales= 2.0*[8, 7, 7]
    # for B,V,(I+z)/2
    #           [r  ,g , b ]
    #scales= 1.5*[22.,13.,32.]
    # for (B+V)/2, V, (I+z)/2
    #scales= 1.5*[23.,18.,23.]
    
    
    # for (B+V)/2, I, z
    ascales= 1.75*np.array([45, 22, 28])
    
    
    # for V, (V+I)/2, I
    #scales= 2*[15,10,8]
    # for V, (V+z)/2, z
    #scales= 2*[15,10,8]
    #scales= 1.5*[26,22,21]
    #scales= 2.5*[16.,11.,11.]
    # according to Roger Griffith's program (also adapted from Hogg's)
    #scales= [1.3,1.4,1.3]
    anonlinearity= 2.0
    
    # don't zoom by default
    aresizefactor= 1.0
    
    # number of pixels the final image should have (in x and y, each)
    npix_final = 424.0
    
    finput_name = 'randomselect_uniformwithmag_basicinfo.fits'

    with fits.open('%s/%s' % (basepath,finput_name)) as f:
        finput_data = f[1].data
    
    n_imgs = 0
    for gal in finput_data:
        make_color_jpeg_bviz(gal,ascales,anonlinearity,aresizefactor)
        n_imgs += 1
    
    print 'Created %i images in both JPG and TIFF formats.' % n_imgs
    print 'Done.'

 
if __name__ == '__main__':
    """test code"""
    hdus1 = P.open('%s/f814_mosaic_wherry.fits' % basepath)
    hdus2 = P.open('%s/f606_mosaic_wherry.fits' % basepath)
    hdus3 = P.open('%s/f450_mosaic_wherry.fits' % basepath)

    img1,img2,img3 = hdus1[0].data,hdus2[0].data,hdus3[0].data

    lup = RGBImage(img1,img2,img3,
                   scales=[7000,4000,15000],
                   beta=2,
                   desaturate=True)

    lup.show()
    lup.save_as('%s/f_color_mosaic_wherry.jpg' % basepath,quality=100)
