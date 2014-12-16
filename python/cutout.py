"""
======
Cutout
======

Generate a cutout image from a .fits file

Originally from Adam Ginsburg (@keflavich)
https://code.google.com/p/agpy/source/browse/trunk/agpy/cutout.py

Modifications by Kyle Willett (@willettk), 15 Dec 2014:

    Uses astropy.coordinates instead of coords
    Default extragalactic reference frame is now ICRS

    wcs_sky2pix -> wcs_world2pix
    pyfits -> fits
    numpy -> np

    renamed definition cutout to Cutout

Example:

>>> mosaic_filename = '/Volumes/3TB/gz4/GOODS_full/GOODS_mosaics/nb_v1.0_sc03_osect52_drz.fits'
>>> ra_cen, dec_cen = 188.8973182, 62.200334300000002
>>> cutout_half_height = 120 # pixels
>>> cutout_half_width  = 120 # pixels
>>> 
>>> ct = Cutout(mosaic_filename, \
>>>                 ra_cen, dec_cen, \
>>>                 xw = cutout_half_width, yw = cutouthalf_height, \
>>>                 units='pixels',\
>>>                 outfile='~/Desktop/output.fits', \
>>>                 clobber=True, useMontage=False, coordframe='icrs', verbose=False)

"""

try:
    from astropy.io import fits
    import astropy.wcs as pywcs
except ImportError:
    import pyfits
    import pywcs

import numpy as np

try:
    from astropy.coordinates import SkyCoord
    from astropy import units as u
except ImportError:
    pass

try:
    import montage_wrapper as montage
    import os
    CanUseMontage=True
except (ImportError,SystemExit):
    CanUseMontage=False

class DimensionError(ValueError):
    pass

def Cutout(filename, xc, yc, xw=25, yw=25, units='pixels', outfile=None,
        clobber=True, useMontage=False, coordframe='icrs', verbose=False):
    """
    Inputs:
        file  - .fits filename or pyfits HDUList (must be 2D)
        xc,yc - x and y coordinates in the fits files' coordinate system (CTYPE)
        xw,yw - x and y width (pixels or wcs)
        units - specify units to use for xw,yw: either pixels or wcs
        outfile - optional output file
    """
    if isinstance(filename,str):
        file = fits.open(filename)
        opened=True
    elif isinstance(filename,fits.HDUList):
        file = filename
        opened=False
    else:
        raise Exception("cutout: Input file is wrong type (string or HDUList are acceptable).")

    head = file[0].header.copy()

    if head['NAXIS'] > 2:
        raise DimensionError("Too many (%i) dimensions!" % head['NAXIS'])
    cd1 = head.get('CDELT1') if head.get('CDELT1') else head.get('CD1_1')
    cd2 = head.get('CDELT2') if head.get('CDELT2') else head.get('CD2_2')
    if cd1 is None or cd2 is None:
        raise Exception("Missing CD or CDELT keywords in header")
    wcs = pywcs.WCS(head)

    if units == 'wcs':
        if coordframe=='icrs' and wcs.wcs.lngtyp=='GLON':
            pos_galactic = SkyCoord(ra = xc * u.degree, dec = yc * u.degree, frame=coordframe).galactic
            xc,yc = pos_galactic.l.degree, pos_galactic.b.degree
        elif coordframe=='galactic' and wcs.wcs.lngtyp=='RA':
            pos_icrs = SkyCoord(l = xc * u.degree, b = yc * u.degree, frame=coordframe).icrs
            xc,yc = pos_icrs.ra.degree, pos_icrs.dec.degree

    if useMontage and CanUseMontage:

        head['CRVAL1'] = xc
        head['CRVAL2'] = yc
        if units == 'pixels':
            head['CRPIX1'] = xw
            head['CRPIX2'] = yw
            head['NAXIS1'] = int(xw*2)
            head['NAXIS2'] = int(yw*2)
        elif units == 'wcs':
            
            cdelt = np.sqrt(cd1**2+cd2**2)
            head['CRPIX1'] = xw   / cdelt
            head['CRPIX2'] = yw   / cdelt
            head['NAXIS1'] = int(xw*2 / cdelt)
            head['NAXIS2'] = int(yw*2 / cdelt)

        head.toTxtFile('temp_montage.hdr',clobber=True)
        newfile = montage.wrappers.reproject_hdu(file[0],header='temp_montage.hdr',exact_size=True)
        os.remove('temp_montage.hdr')
    else:
        
        xx,yy = wcs.wcs_world2pix(xc,yc,0)

        if units=='pixels':
            xmin,xmax = np.max([0,xx-xw]),np.min([head['NAXIS1'],xx+xw])
            ymin,ymax = np.max([0,yy-yw]),np.min([head['NAXIS2'],yy+yw])
        elif units=='wcs':
            xmin,xmax = np.max([0,xx-xw/np.abs(cd1)]),np.min([head['NAXIS1'],xx+xw/np.abs(cd1)])
            ymin,ymax = np.max([0,yy-yw/np.abs(cd2)]),np.min([head['NAXIS2'],yy+yw/np.abs(cd2)])
        else:
            raise Exception("Can't use units %s." % units)

        if xmax < 0 or ymax < 0:
            raise ValueError("Max Coordinate is outside of map: %f,%f." % (xmax,ymax))
        if ymin >= head.get('NAXIS2') or xmin >= head.get('NAXIS1'):
            raise ValueError("Min Coordinate is outside of map: %f,%f." % (xmin,ymin))

        head['CRPIX1']-=xmin
        head['CRPIX2']-=ymin
        head['NAXIS1']=int(xmax-xmin)
        head['NAXIS2']=int(ymax-ymin)

        if head.get('NAXIS1') == 0 or head.get('NAXIS2') == 0:
            raise ValueError("Map has a 0 dimension: %i,%i." % (head.get('NAXIS1'),head.get('NAXIS2')))

        img = file[0].data[ymin:ymax,xmin:xmax]
        newfile = fits.PrimaryHDU(data=img,header=head)
        if verbose: print "Cut image %s with dims %s to %s.  xrange: %f:%f, yrange: %f:%f" % (filename, file[0].data.shape,img.shape,xmin,xmax,ymin,ymax)

    if isinstance(outfile,str):
        newfile.writeto(outfile,clobber=clobber)

    if opened:
        file.close()

    return newfile


