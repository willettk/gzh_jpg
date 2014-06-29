;+
; NAME:
;   make_simgal_jpeg
; BUGS:
;   everything hard wired
;-
pro make_color_jpeg_bviz

; set parameters - pretty much trial and error here
; for H (f160w), (H+J)/2, J (f125w)
;scales= 2.0*[8, 7, 7]
; for B,V,(I+z)/2
;           [r  ,g , b ]
;scales= 1.5*[22.,13.,32.]
; for (B+V)/2, V, (I+z)/2
;scales= 1.5*[23.,18.,23.]


; for (B+V)/2, I, z
ascales= 1.75*[45, 22, 28]


; for V, (V+I)/2, I
;scales= 2*[15,10,8]
; for V, (V+z)/2, z
;scales= 2*[15,10,8]
;scales= 1.5*[26,22,21]
;scales= 2.5*[16.,11.,11.]
; according to Roger Griffith's program (also adapted from Hogg's)
;scales= [1.3,1.4,1.3]
anonlinearity= 2.0

; don't zoom by default
aresizefactor= 1.0

n_imgs = 0

; number of pixels the final image should have (in x and y, each)
npix_final = 424.0

finput_name = 'randomselect_uniformwithmag_basicinfo.fits'

finput_data = mrdfits(finput_name, 1)
                                ;input_grid  = finput_data.objno
input_oid   = finput_data.uid_mosaic
id_str = 'g' + strtrim(string(input_oid), 2)

basedir = '../'

jpgpath  = basedir+'jpg_thumb/'
tiffpath = basedir+'tiff_thumb/'
fitspath = basedir+'fits_thumb/'

for i_id=0, n_elements(id_str)-1 do begin

    ;print, id_str(i_id)
    print, '----------------- '+id_str(i_id)+' --------------------'


    ; get the amount by which we need to resize
    ; consider all bands
    a_pix = max(finput_data.a_image_z(i_id), max(finput_data.a_image_i(i_id), max(finput_data.a_image_b(i_id), finput_data.a_image_v(i_id))))
    kron_r= max(finput_data.kron_radius_z(i_id), max(finput_data.kron_radius_i(i_id), max(finput_data.kron_radius_b(i_id), finput_data.kron_radius_v(i_id))))
    obj_size_pix = a_pix * kron_r
    
    img_size_hstpix = 2.7 * obj_size_pix
    
    ; sanity checks -- don't zoom in too far
    img_size_hstpix = max(img_size_hstpix, 120.)
    
    ; sanity checks -- don't zoom out too far
    img_size_hstpix = min(img_size_hstpix, 1000.)
    
    aresizefactor = npix_final / img_size_hstpix


    print, a_pix, kron_r, img_size_hstpix, aresizefactor


    bimg  = fitspath+id_str(i_id)+'_sb_thumb.fits'
    vimg  = fitspath+id_str(i_id)+'_sv_thumb.fits'
    iimg  = fitspath+id_str(i_id)+'_si_thumb.fits'
    zimg  = fitspath+id_str(i_id)+'_sz_thumb.fits'

    print, zimg
    img_b = mrdfits(bimg)
    img_v = mrdfits(vimg)
    img_i = mrdfits(iimg)
    img_z = mrdfits(zimg)
    
    bsize = size(img_b,/dimensions)
    vsize = size(img_v,/dimensions)
    isize = size(img_i,/dimensions)
    zsize = size(img_z,/dimensions)


    
; if all images don't exist, skip the whole thing entirely
; but if one image or the other doesn't exist, just erase the color
    
    if bsize[0] NE 0 and vsize[0] NE 0 and isize[0] NE 0 and zsize[0] NE 0 then begin

        rimage = img_z
        gimage = img_i
        bimage = 0.5*(img_b+img_v)

        tmp= size(rimage,/dimensions)
        nx= tmp[0]
        ny= tmp[1]

        RGBim = [[[rimage]],[[gimage]],[[bimage]]]
        
        RGBim = nw_scale_rgb(RGBim,scales=ascales)
        RGBim = nw_arcsinh_fit(RGBim,nonlinearity=anonlinearity)
        RGBim = nw_fit_to_box(RGBim,origin=aorigin)
        RGBim = nw_float_to_byte(RGBim)

        ; rebin
        ; okay, all this currently does is resize the whole thing
        ; that's great, but my final product needs to be an image
        ; of the same pixel size as before -- so I need to e.g. cut
        ; everything but the central 424 x 424, etc.
        ; I think I can do that without too much issue... I hope.
        RGBim= rebin(RGBim,floor(nx*aresizefactor),(ny*aresizefactor),3)

        outjpg = jpgpath+id_str(i_id)+'_bviz_thumb.jpg'
        outtiff = tiffpath+id_str(i_id)+'_bviz_thumb.tiff'
;            tiff_desc = ''
        tiff_desc = 'RA = '+strtrim(string(finput_data(i_id).alpha_j2000_b, FORMAT='(F15.6)'),2)+' ; DEC = '+strtrim(string(finput_data(i_id).delta_j2000_b, FORMAT='(F15.6)'),2)
        WRITE_JPEG,outjpg,RGBim,TRUE=3,QUALITY=100


; WRITE_JPEG and WRITE_TIFF need different array formats - awesome
; plus, tiff images are usually read upside-down so needs to be flipped
;            TIFFim = FLTARR(3, 3*nx, ny, /NOZERO) ;make interleaved array
;        TIFFim = FLTARR(3, nx, ny, /NOZERO) ;make interleaved array
;        TIFFim[0, *, *] = REVERSE(RGBim[*,*,0],2)
;        TIFFim[1, *, *] = REVERSE(RGBim[*,*,1],2)
;        TIFFim[2, *, *] = REVERSE(RGBim[*,*,2],2)

;        print, tiff_desc
;        WRITE_TIFF,outtiff,TIFFim,DESCRIPTION=tiff_desc

        n_imgs += 1
        
    endif                     ; end check that at least 1 image exists

endfor                          ; end outer loop through ids


;print, input_oid(0)

print, 'Created '+strtrim(string(n_imgs, FORMAT='(I6)'),2)+' images in both jpg and tiff formats... done.'

return
end
