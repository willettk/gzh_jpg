# Make a webpage to compare Brooke Simmons' new CANDELS 2-epoch images to the ones we showed before
#
# 1st column should be the original GEMS images (shallow)
# 2nd column should be the same GEMS images (shallow), but which we mistakenly thought were deeper GOODS images in the original GZ:Hubble release
# 3rd column should be the new, deeper GOODS-N and GOODS-S images I (Kyle) made
#

import glob

from astropy.io import fits

newdir = '/Volumes/3TB/gz4/GOODS_full'
olddir = '/Volumes/3TB/gzh'
webdir = '/Users/willettk/Astronomy/meetings/uk2014/gzh_jpg/goods_comparison'

with fits.open('/Users/willettk/Astronomy/meetings/uk2014/gzh_jpg/goods_matched_oldnew.fits') as f:
    data = f[1].data

import random

n = 25
randomimgs = random.sample(data,n)

import shutil

with open('/Users/willettk/Astronomy/meetings/uk2014/gzh_jpg/goods_comparison.html','w') as f:
    for gal in randomimgs:

        oldimg = '%s/jpg/%i.jpg' % (olddir,gal['OBJNO'])
        newimg = '%s/jpg/goods_s_g%i_bviz_thumb.jpg' % (newdir,gal['UID_MOSAIC_Z'])

        old_galid = oldimg.split('/')[-1]
        new_galid = newimg.split('/')[-1]

        # GZH original
        shutil.copy(oldimg,'%s/original/%s' % (webdir,old_galid))
        f.write('<IMG SRC="goods_comparison/original/%s" TITLE="GOODS-S 2-epoch id:%s">' % (old_galid,old_galid))
        # New, properly-produced 5-epoch GOODS images for GZ4
        shutil.copy(newimg,'%s/new_5epoch/%s' % (webdir,new_galid))
        f.write('<IMG SRC="goods_comparison/new_5epoch/%s" TITLE="GOODS-S 5-epoch id:%s"><br>' % (new_galid,new_galid))

