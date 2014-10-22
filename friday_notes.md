Notes from discussion between Brooke and Kyle on Fri 27 Jun 2014
===

* [done] repixelate (larger) images to 424x424 after scaling to fixed fraction of galaxy radius
* [done] examine the stretch and appropriate values for each band
* [done] Noise decoloring (Bamford method) with a raised floor
** [done] Nonlinearity level of 3.0 +- 0.5 seems appropriate to bring out detail and raise noise floor a bit. 

* [need catalog] Make the FULL GOODS-S catalog, which should be about 6,000 galaxies (in excess of the 500 random sample)
* [need catalog] Cut on magnitudes less than 24.5 in z-band
* [need GZH results] Remove objects flagged as stars/artifacts; suggest CLASS_STELLAR_MAX >= 0.90 to start? Would leave roughly 20% of images
* [need catalog] Add GOODS-N

Fixed and updated the PIL software (required upgrade to Pillow and some changes in how Image is imported in code)

citation for GOODS data is Giavalisco+04

make multiple versions (cols 1 and 3) so that we can point to the "original" versions if there are questions on artifacts
