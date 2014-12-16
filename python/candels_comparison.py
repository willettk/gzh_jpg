# Make a webpage to compare Brooke Simmons' new CANDELS 2-epoch images to the ones we showed before
#
# 1st column should be the 5-epoch GOODS-S images (deeper)
# 2nd column should be the same 5-epoch GOODS-S images (deeper), but which we mistakenly thought were 2-epoch ones in 2013
# 3rd column should be the new, shallower 2-epoch images Brooke has made
#

# Pick 20 random galaxies
#

import glob

candelsdir = '/Volumes/3TB/gz4/CANDELS'
newdir = '/Volumes/3TB/gz4/CANDELS_2epoch'
webdir = '/Users/willettk/Astronomy/meetings/uk2014/gzh_jpg/candels_comparison'

imgs = glob.glob('%s/jpg/*jpg' % newdir)

import random

n = 25
randomimgs = random.sample(imgs,n)

import shutil

with open('/Users/willettk/Astronomy/meetings/uk2014/gzh_jpg/candels_comparison.html','w') as f:
    for gal in randomimgs:
        galfile = gal.split('/')[-1]
        galid = galfile.split('.')[0].rsplit('_',1)[0]
        # CANDELS original
        original = '%s/jpg/GDS_stamps_large/%s.jpg' % (candelsdir,galid)
        shutil.copy(original,'%s/original/%s.jpg' % (webdir,galid))
        f.write('<IMG SRC="candels_comparison/original/%s.jpg" TITLE="CANDELS GOODS-S 5-epoch id:%s">' % (galid,galid))
        # CANDELS incorrectly-labeled "2-epoch" (should be same as first column)
        bad_2epoch = '%s/jpg/GDS_stamps_large_2epoch/%s.jpg' % (candelsdir,galid)
        shutil.copy(bad_2epoch,'%s/bad_2epoch/%s.jpg' % (webdir,galid))
        f.write('<IMG SRC="candels_comparison/bad_2epoch/%s.jpg" TITLE="CANDELS GOODS-S mislabeled 2-epoch id:%s">' % (galid,galid))
        # New, properly-produced 2-epoch CANDELS images
        new_2epoch = '%s/jpg/%s_2ep.jpg' % (newdir,galid)
        shutil.copy(new_2epoch,'%s/new_2epoch/%s.jpg' % (webdir,galid))
        f.write('<IMG SRC="candels_comparison/new_2epoch/%s.jpg" TITLE="CANDELS GOODS-S correct 2-epoch id:%s"><br>' % (galid,galid))

