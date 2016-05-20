gzh_dir = '/Users/willettk/Astronomy/meetings/uk2014/gzh_jpg'
ext_dir = '/Volumes/3TB/gz4/GOODS_full'

from astropy.io import fits
from astropy.table import Table
import numpy as np
import warnings

warnings.simplefilter("ignore",RuntimeWarning)

with fits.open('%s/master_3dhst_musyc_griffith_3arcsec.fits' % gzh_dir) as f:
    dfits = f[1].data

data = Table(dfits)

blankz = np.ones(len(data)) * -99

def choose_redshift(data):

    survey = ('3dhst_n','3dhst_s','musyc','griffith')
    ztype = ('spec','peak')

    prevmask = np.zeros(len(data),dtype=bool)
    for zt in ztype:
        for s in survey:
            zcol = 'z_%s_%s' % (zt,s)
            mask = np.isfinite(data[zcol])  & (data[zcol] > 0.) & np.logical_not(prevmask)
            blankz[mask] = data[zcol][mask]
            prevmask = mask

    return blankz

zarr = choose_redshift(data)

# Calculate absolute size in kpc

from astropy.cosmology import WMAP9
from astropy import units as u

size = [WMAP9.kpc_proper_per_arcmin(z).to(u.kpc/u.arcsec) * (r * u.arcsec) if z > 0 else -99. * u.kpc for z,r in zip(zarr,data['KRON_RADIUS_I'])]
#re = 0.162 * data['FLUX_RADIUS1_B_1']**1.87
absmag = [zmag * u.mag - WMAP9.distmod(z) if z > 0 else -99. * u.mag for z,zmag in zip(zarr,data['Z_1'])]

data.rename_column('hubble_id_1'     , 'hubble_id'      )
data.rename_column('coords_ra_1'     , 'ra')
data.rename_column('coords_dec_1'    , 'dec')
data.rename_column('KRON_RADIUS_I' , 'kron_radius_I')
data.rename_column('FLUX_RADIUS1_I', 'flux_radius1_I')
data.rename_column('B_1'             , 'B')
data.rename_column('V_1'             , 'V')
data.rename_column('I_1'             , 'I')
data.rename_column('Z_1'             , 'Z')
data.rename_column('group_type_1'    , 'group_type')
data.rename_column('retire_at_1'     , 'retire_at')
data.rename_column('survey_1'        , 'survey')
data.rename_column('depth_1'         , 'depth')
del data['KRON_RADIUS_B_1']
del data['FLUX_RADIUS1_B_1']
del data['depth']
del data['survey']
del data['camera_1']
del data['hubble_id_2']
del data['coords_ra_2']
del data['coords_dec_2']
del data['KRON_RADIUS_B_2']
del data['FLUX_RADIUS1_B_2']
del data['B_2']
del data['V_2']
del data['I_2']
del data['Z_2']
del data['group_type_2']
del data['retire_at_2']
del data['survey_2']
del data['depth_2']
del data['camera_2']
del data['id_goods_n_3dhst']
del data['ra_3dhst_n']
del data['dec_3dhst_n']
del data['z_spec_3dhst_n']
del data['z_peak_3dhst_n']
del data['Separation_1']
del data['hubble_id_2a']
del data['coords_ra_2a']
del data['coords_dec_2a']
del data['KRON_RADIUS_B_2a']
del data['FLUX_RADIUS1_B_2a']
del data['B_2a']
del data['V_2a']
del data['I_2a']
del data['Z_2a']
del data['group_type_2a']
del data['retire_at_2a']
del data['survey_2a']
del data['depth_2a']
del data['camera_2a']
del data['hubble_id_3dhst_s']
del data['id_goods_s_3dhst']
del data['ra_3dhst_s']
del data['dec_3dhst_s']
del data['z_spec_3dhst_s']
del data['z_peak_3dhst_s']
del data['Separation_2']
del data['hubble_id_3']
del data['coords_ra_3']
del data['coords_dec_3']
del data['KRON_RADIUS_B_3']
del data['FLUX_RADIUS1_B_3']
del data['B_3']
del data['V_3']
del data['I_3']
del data['Z_3']
del data['group_type_3']
del data['retire_at_3']
del data['survey_3']
del data['depth_3']
del data['camera_3']
del data['hubble_id_musyc']
del data['id_musyc']
del data['ra_musyc']
del data['dec_musyc']
del data['z_spec_musyc']
del data['z_peak_musyc']
del data['Separation_3']
del data['hubble_id_4']
del data['coords_ra_4']
del data['coords_dec_4']
del data['KRON_RADIUS_B_4']
del data['FLUX_RADIUS1_B_4']
del data['B_4']
del data['V_4']
del data['I_4']
del data['Z_4']
del data['group_type_4']
del data['retire_at_4']
del data['survey_4']
del data['depth_4']
del data['camera_4']
del data['hubble_id_griffith']
del data['objno_griffith']
del data['survey_id_griffith']
del data['ra_griffith']
del data['dec_griffith']
del data['z_spec_griffith']
del data['z_peak_griffith']
del data['Separation_4']

data['redshift'] = zarr
data['survey'] = ['goods_full'] * len(data)

sizearr = [s.value for s in size]
absmagarr = [m.value for m in absmag]
data['absolute_size'] = sizearr
data['absmag_Z'] = absmagarr

# Add location

data.write('%s/goods_full_metadata.fits' % ext_dir,format='fits',overwrite=True)

# Decide on final fields, compute distances and sizes from astropy.cosmology
