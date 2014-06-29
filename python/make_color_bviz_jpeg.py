__credits__ = '''Written by Kyle Willett (willettk@gmail.com); adapted from code by Taro Sato and Steven Bamford'''

import Image as I
import numpy as np
import nw

try:
    from astropy.io import fits
except:
    import pyfits as fits

basepath = '..'

jpg_path  = '%s/jpg_thumb/pythoned' % basepath
tiff_path = '%s/tiff_thumb/pythoned' % basepath
fits_path = '%s/fits_thumb/pythoned' % basepath

def make_jpeg(gal,ascales,anonlinearity,npix_final,desaturate=True,show_img=True):

    input_oid = gal['UID_MOSAIC']
    id_str = 'g%s' % input_oid
    print '----------------- %s --------------------' % id_str


    # Get the amount by which we need to resize the image
    # Consider all bands
    a_pix = max(gal['A_IMAGE_Z'], gal['A_IMAGE_I'], gal['A_IMAGE_V'], gal['A_IMAGE_B'])
    kron_r = max(gal['KRON_RADIUS_Z'], gal['KRON_RADIUS_I'], gal['KRON_RADIUS_V'], gal['KRON_RADIUS_B'])
    obj_size_pix = a_pix * kron_r

    img_size_hstpix = 2.5 * obj_size_pix

    # Sanity checks -- don't zoom in too far
    img_size_hstpix = max(img_size_hstpix, 120.)
    
    # Sanity checks -- don't zoom out too far
    img_size_hstpix = min(img_size_hstpix, 1000.)
    
    aresizefactor = npix_final / img_size_hstpix

    # Print re-sizing parameters to screen
    print 'Semi-major axis [pix]: %f\n Kron radius [pix]: %f\n Image size [pix]: %f\n Resize factor: %f' % (a_pix, kron_r*a_pix, img_size_hstpix, aresizefactor)

    # Load FITS data from existing cutouts

    with fits.open('%s/fits_thumb/%s_s%s_thumb.fits' % (basepath,id_str,'b')) as f:
        img_b = f[0].data
    with fits.open('%s/fits_thumb/%s_s%s_thumb.fits' % (basepath,id_str,'v')) as f:
        img_v = f[0].data
    with fits.open('%s/fits_thumb/%s_s%s_thumb.fits' % (basepath,id_str,'i')) as f:
        img_i = f[0].data
    with fits.open('%s/fits_thumb/%s_s%s_thumb.fits' % (basepath,id_str,'z')) as f:
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
    
    RGBim = nw.scale_rgb(RGBim,scales=ascales)
    RGBim = nw.arcsinh_fit(RGBim,nonlinearity=anonlinearity)
    RGBim = nw.fit_to_box(RGBim)


    if desaturate:
        # optionally desaturate pixels that are dominated by a single
        # colour to avoid colourful speckled sky
        a = RGBim.mean(axis=0)
        np.putmask(a, a == 0.0, 1.0)
        acube = np.resize(a,(3,nx,ny))
        bcube = (RGBim / acube) / anonlinearity
        mask = np.array(bcube)
        w = np.max(mask, 0)
        np.putmask(w, w > 1.0, 1.0)
        w = 1 - w
        w = np.sin(w*np.pi/2.0)
        RGBim = RGBim * w + a*(1-w)

    # Convert data to scaled bytes
    RGBim = (255.*RGBim).astype(int)
    RGBim = np.where(RGBim>255,255,RGBim)
    RGBim = np.where(RGBim<0,0,RGBim)

    # rebin
    # okay, all this currently does is resize the whole thing
    # that's great, but my final product needs to be an image
    # of the same pixel size as before -- so I need to e.g. cut
    # everything but the central 424 x 424, etc.
    # I think I can do that without too much issue... I hope.

    if nx >= npix_final and ny >= npix_final:
        RGBim = RGBim[:,(nx-npix_final)/2:nx - (nx-npix_final)/2,(ny-npix_final)/2:ny - (ny-npix_final)/2]
    else:
        print 'Image is smaller than %i pixels square (%i,%i)' % (npix_final,nx,ny)
    # RGBim = rebin(RGBim,floor(nx*aresizefactor),(ny*aresizefactor),3)

    R,G,B = RGBim
    data = np.array([R.ravel(),G.ravel(),B.ravel()])
    data = np.transpose(data)
    pdata = []
    # putdata(x) does not work unless the (R,G,B) is given as tuple!!
    for each in data: 
        pdata.append(tuple(each))

    # Make image

    img = I.new('RGB',size=RGBim.shape[1:])
    img.putdata(pdata)

    if show_img:
        img.show()

    # Save as both JPG and TIFF
    out_jpg = '%s/%s_bviz_thumb.jpg' % (jpg_path,id_str)
    out_tiff = '%s/%s_bviz_thumb.tiff' % (tiff_path,id_str)
    tiff_desc = {'RA':gal['ALPHA_J2000_B'],'DEC':gal['DELTA_J2000_B']}

    img.save(out_jpg,quality=100)
    img.save(out_tiff,quality=100,tiffinfo=tiff_desc)


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
        make_jpeg(gal,ascales,anonlinearity,npix_final,desaturate=True,show_img = False)
        n_imgs += 1
    
    print 'Created %i images in both JPG and TIFF formats.' % n_imgs
    print 'Done.'

 
if __name__ == '__main__':
    """test code"""
    hdus1 = fits.open('%s/f814_mosaic_wherry.fits' % basepath)
    hdus2 = fits.open('%s/f606_mosaic_wherry.fits' % basepath)
    hdus3 = fits.open('%s/f450_mosaic_wherry.fits' % basepath)

    img1,img2,img3 = hdus1[0].data,hdus2[0].data,hdus3[0].data

    lup = RGBImage(img1,img2,img3,
                   scales=[7000,4000,15000],
                   beta=2,
                   desaturate=True)

    lup.show()
    lup.save_as('%s/f_color_mosaic_wherry.jpg' % basepath,quality=100)
