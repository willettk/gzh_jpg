__credits__ = '''Written by Kyle Willett (willettk@gmail.com); adapted from code by Taro Sato, Steven Bamford, and Brooke Simmons'''

import Image as I
import numpy as np
import nw
from scipy.misc import imresize
from matplotlib import pyplot as plt

try:
    from astropy.io import fits
except:
    import pyfits as fits

basepath = '..'

jpg_path  = '%s/jpg_thumb/from_mosaics' % basepath
tiff_path = '%s/tiff_thumb/from_mosaics' % basepath
fits_path = '%s/fits_thumb' % basepath
mosaic_path = '/Volumes/BDS_backup/Astro/GOODS/v1.0/images'

def make_jpeg(gal,ascales,anonlinearity,npix_final=424,pedestal=0,desaturate=False,show_img=True,load_from_mosaic=False,mosaics=None):

    input_oid = gal['UID_MOSAIC']
    id_str = 'g%s' % input_oid
    print '----------------- %s --------------------' % id_str


    # Get the amount by which we need to resize the image
    # Consider all bands
    a_pix = max(gal['A_IMAGE_Z'], gal['A_IMAGE_I'], gal['A_IMAGE_V'], gal['A_IMAGE_B'])
    kron_r = max(gal['KRON_RADIUS_Z'], gal['KRON_RADIUS_I'], gal['KRON_RADIUS_V'], gal['KRON_RADIUS_B'])
    obj_size_pix = a_pix * kron_r

    # Scale in HST pixel size; go out to 2.5 times the Kron radius (standard aperture for SExtractor)
    img_size_hstpix = 2.5 * obj_size_pix

    # Sanity checks -- don't zoom in or out too far
    img_size_hstpix = max(img_size_hstpix, 120.)
    img_size_hstpix = min(img_size_hstpix, 1000.)
    
    resize_factor = npix_final / img_size_hstpix

    # Print re-sizing parameters to screen
    print 'Semi-major axis [pix]: %f\n Kron radius [pix]: %f\n Image size [pix]: %f\n Resize factor: %f' % (a_pix, kron_r*a_pix, img_size_hstpix, resize_factor)

    # Load FITS data from original GOODS mosaics

    if load_from_mosaic:
        if mosaics is None:
            osect_z = gal['OSECT_Z']
            with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'b',osect_z)) as f:
                img_b = np.transpose(f[0].data)
            with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'v',osect_z)) as f:
                img_v = np.transpose(f[0].data)
            with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'i',osect_z)) as f:
                img_i = np.transpose(f[0].data)
            with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'z',osect_z)) as f:
                img_z = np.transpose(f[0].data)
        else:
            img_b,img_v,img_i,img_z = mosaics

        # Cut down the image to the Kron radius aperture

        xsize,ysize = img_v.shape
        xstart,ystart = gal['X_IMAGE_B'],gal['Y_IMAGE_B']
        halfbox = np.floor(img_size_hstpix/2.).astype(int)
        img_b = img_b[xstart-halfbox:xstart+halfbox,ystart-halfbox:ystart+halfbox]
        img_v = img_v[xstart-halfbox:xstart+halfbox,ystart-halfbox:ystart+halfbox]
        img_i = img_i[xstart-halfbox:xstart+halfbox,ystart-halfbox:ystart+halfbox]
        img_z = img_z[xstart-halfbox:xstart+halfbox,ystart-halfbox:ystart+halfbox]

    # Load FITS data from existing cutouts

    else:
        with fits.open('%s/%s_s%s_thumb.fits' % (fits_path,id_str,'b')) as f:
            img_b = f[0].data
        with fits.open('%s/%s_s%s_thumb.fits' % (fits_path,id_str,'v')) as f:
            img_v = f[0].data
        with fits.open('%s/%s_s%s_thumb.fits' % (fits_path,id_str,'i')) as f:
            img_i = f[0].data
        with fits.open('%s/%s_s%s_thumb.fits' % (fits_path,id_str,'z')) as f:
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

    if load_from_mosaic:
        RGBim = np.array([np.transpose(rimage),np.transpose(gimage),np.transpose(bimage)])
    else:
        RGBim = np.array([rimage,gimage,bimage])
    
    # Use Nick Wherry's adapted IDL codes to scale and fit the image data
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

    # Add optional grey pedestal to the byte-scaled data

    RGBim += pedestal
    RGBim = np.where(RGBim>255,255,RGBim)

    R = RGBim[0,:,:]
    G = RGBim[1,:,:]
    B = RGBim[2,:,:]

    data = np.array([R.ravel(),G.ravel(),B.ravel()])
    data = np.transpose(data)
    pdata = []
    # putdata(x) does not work unless the (R,G,B) is given as tuple!!
    for each in data: 
        pdata.append(tuple(each))

    # Make Image in PIL format

    img = I.new('RGB',size=R.shape)
    img.putdata(pdata)

    # Rebin images to 424x424 pixels
    img = img.resize((424,424),I.ANTIALIAS)

    if show_img:
        img.show()

    # Save hardcopy as both JPG and TIFF
    out_jpg = '%s/%s_bviz_thumb.jpg' % (jpg_path,id_str)
    out_tiff = '%s/%s_bviz_thumb.tiff' % (tiff_path,id_str)
    tiff_desc = {'RA':gal['ALPHA_J2000_B'],'DEC':gal['DELTA_J2000_B']}

    img.save(out_jpg,quality=100)
    img.save(out_tiff,quality=100,tiffinfo=tiff_desc)

    return None

def run_all_images(load_from_mosaic=True):

    ascales,anonlinearity,npix_final,apedestal = get_image_defaults()
   
    finput_name = 'randomselect_uniformwithmag_basicinfo.fits'

    with fits.open('%s/%s' % (basepath,finput_name)) as f:
        finput_data = f[1].data
    
    n_imgs = 0

    # Load mosaic files by OSECT_Z to save on memory reads
    if load_from_mosaic:
        osects = np.unique(finput_data['OSECT_Z'])
        for o in osects:
            osect_galaxies = finput_data[finput_data['OSECT_Z'] == o]
            for gal in osect_galaxies:
                with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'b',o)) as f:
                    img_b = np.transpose(f[0].data)
                with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'v',o)) as f:
                    img_v = np.transpose(f[0].data)
                with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'i',o)) as f:
                    img_i = np.transpose(f[0].data)
                with fits.open('%s/s%s_v1.0_sc03_osect%i_drz.fits' % (mosaic_path,'z',o)) as f:
                    img_z = np.transpose(f[0].data)
                make_jpeg(gal,ascales,anonlinearity,npix_final,apedestal,desaturate=False,show_img = False,\
                    load_from_mosaic = True, mosaics = (img_b,img_v,img_i,img_z))
                n_imgs += 1

    # Loading from Brooke's FITS cutouts
    else:
        for gal in finput_data:
            make_jpeg(gal,ascales,anonlinearity,npix_final,apedestal,desaturate=False,show_img = False,load_from_mosaic = False)
            n_imgs += 1
    
    print 'Created %i images in both JPG and TIFF formats.' % n_imgs
    print 'Done.'

def get_image_defaults():

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
    
    # number of pixels the final image should have (in x and y, each)
    npix_final = 424

    # Pedestal
    apedestal = 0

    return ascales,anonlinearity,npix_final,apedestal

def mosaic_vs_cutout():

    # Test to make sure images pulled from mosaic and Brooke's cutouts are identical for indexing (they are)

    with fits.open('%s/g7416_sv_thumb.fits' % fits_path) as f:
        thumbnail = f[0].data 
    with fits.open('%s/sv_v1.0_sc03_osect43_drz.fits' % mosaic_path) as f:
        mosaic = f[0].data
    finput_name = 'randomselect_uniformwithmag_basicinfo.fits'
    with fits.open('%s/%s' % (basepath,finput_name)) as f:
        finput_data = f[1].data
    gal = finput_data[finput_data['UID_MOSAIC'] == 7416][0]

    cutout = np.transpose(mosaic)[gal['xstart']-1:gal['xend'],gal['ystart']-1:gal['yend']]

    vmin,vmax = 0.0, 0.25

    fig = plt.figure(2)
    fig.clf()
    ax1,ax2,ax3 = fig.add_subplot(131,aspect='equal'),fig.add_subplot(132,aspect='equal'),fig.add_subplot(133,aspect='equal')

    cutout_t = np.transpose(cutout)
    im1 = ax1.imshow(thumbnail,vmin=vmin,vmax=vmax)
    im2 = ax2.imshow(cutout_t,vmin=vmin,vmax=vmax)
    im3 = ax3.imshow(thumbnail - cutout_t)

    ax1.set_title('FITS thumbnail')
    ax2.set_title('Image from mosaic')
    ax3.set_title('Difference')

    fig.subplots_adjust(left=0.3)
    cbar_ax = fig.add_axes([0.15, 0.15, 0.05, 0.7])
    fig.colorbar(im1, cax=cbar_ax)

    fig.show()

    return None
    
if __name__ == '__main__':

    """Test the code"""

    ascales,anonlinearity,npix_final,apedestal = get_image_defaults()

    finput_name = 'randomselect_uniformwithmag_basicinfo.fits'

    with fits.open('%s/%s' % (basepath,finput_name)) as f:
        finput_data = f[1].data

    make_jpeg(finput_data[finput_data['UID_MOSAIC'] == 7416][0],ascales,anonlinearity,npix_final,apedestal,desaturate = False,show_img = True,load_from_mosaic = True)
