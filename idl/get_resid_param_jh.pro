;+
; NAME:
;   make_simgal_jpeg
; BUGS:
;   everything hard wired
;-
pro get_resid_param_jh

; this ought to be an odd number
; note this is now not used here
;region_size = 25

; instead we're going to loop through; still need odd numbers
; so that the region has a central pixel & it doesn't shift
region_size_min=5
region_size_max=99

rsize_arr=findgen((region_size_max-region_size_min)/2 + 1)
for i=0, n_elements(rsize_arr)-1 do begin

    rsize_arr(i) = region_size_min + (2*i)

endfor 

;input_data = read_ascii('candels_F125W_F160W_ECDFS_Xray_matches.tofit.allz.cat', data_start=0)
;input_data = read_ascii('candels_f125_f160_4ms_additional_tofit.dat', data_start=1)
input_data = read_ascii('X11_musyc_candels_matched_tofit_batch_in.cat', data_start=1)
input_data = input_data.field01
; cid mid ra dec (f125)x y mag dmag bkgd ba pa r1 r2 r3 c_s (f160)x y mag dmag
; bkgd ba pa r1 r2 r3 c_s (musyc)xrflag zspec zsrc zqual zpeak zlo zhi zhi2
; qz starflag vmag umv vmj


input_oid   = fix(input_data(1,*), TYPE=3)
id_str = 'x' + strtrim(string(input_oid), 2)

basedir = '../agn/'

fitspath_arr = basedir+id_str+'/'

band = ['f125w', 'f160w']
fittype = ['Sp', 'S']


; band, fittype, id
sum_resid  = findgen(n_elements(band),n_elements(fittype),n_elements(input_oid), n_elements(rsize_arr))
; zero them out (initialize)
sum_resid   = sum_resid - sum_resid
min_resid   = sum_resid - sum_resid  ; straight min/max/diff
max_resid   = sum_resid - sum_resid
diff_resid  = sum_resid - sum_resid
min1_resid  = sum_resid - sum_resid  ; 1-sigma (68%)
max1_resid  = sum_resid - sum_resid
diff1_resid = sum_resid - sum_resid
min2_resid  = sum_resid - sum_resid  ; 2-sigma (95%)
max2_resid  = sum_resid - sum_resid  
diff2_resid = sum_resid - sum_resid
min3_resid  = sum_resid - sum_resid  ; 3-sigma (99%)
max3_resid  = sum_resid - sum_resid
diff3_resid = sum_resid - sum_resid
avg_img     = sum_resid - sum_resid  ; avg value on original image
med_img     = sum_resid - sum_resid  ; avg value on original image

; skip first row (header) of input file
for i_id=0, n_elements(id_str)-1 do begin
;for i=8,8 do begin  ; for tests
    fitspath = fitspath_arr(i_id)

    print, '----------------- x'+id_str(i_id)+' --------------------'

    for i_band = 0, n_elements(band)-1 do begin

        for i_fit = 0,n_elements(fittype)-1 do begin

            fname = 'residparam/'+id_str(i_id)+'_'+band(i_band)+'_'+fittype(i_fit)+'_residparam.dat'
            
            openw, 33, fname
            
            printf, 33, '#rsize', 'sum', 'min_tot', 'max_tot', 'diff_tot', 'min_1sig', 'max_1sig', 'diff_1sig', 'min_2sig', 'max_2sig', 'diff_2sig', 'min_3sig', 'max_3sig', 'diff_3sig', 'avg_image', 'med_image', format='(A8, A15, A14, A11, A11, A14, A11, A11, A14, A11, A11, A14, A11, A11, A15, A11)'
            

            imgname = fitspath+id_str(i_id)+'_'+band(i_band)+'_gfit.out.'+fittype(i_fit)+'.fits'
            
            dat_img = mrdfits(imgname, 1)
            res_img = mrdfits(imgname, 3)
            
            imgsize = size(res_img,/dimensions)
            
            for i_size=0,n_elements(rsize_arr)-1 do begin

                region_size = rsize_arr(i_size)
                

; if image doesn't exist (or is too small), skip the whole thing entirely
; and set the parameters equal to -99
                
                if imgsize[0] NE 0 AND imgsize[0] GE region_size then begin
                    
                                ; just take the central region

                    nx = imgsize[0]
                    ny = imgsize[1]
                    
                    ctr_x = fix(nx/2)
                    ctr_y = fix(ny/2)
                    
                    x1 = fix(ctr_x - (region_size-1)/2)
                    x2 = x1+region_size
                    
                    y1 = fix(ctr_y - (region_size-1)/2)
                    y2 = y1+region_size
                    
                    res_img_ctr = res_img[x1:x2,y1:y2]
                    dat_img_ctr = dat_img[x1:x2,y1:y2]
                    
                    sum_resid(i_band, i_fit, i_id, i_size) = total(res_img_ctr)
                    avg_img(i_band, i_fit, i_id, i_size) = mean(dat_img_ctr)
                    med_img(i_band, i_fit, i_id, i_size) = median(dat_img_ctr)

                    
                    i_sortpix = sort(res_img_ctr)
                                ; straight up min, max, total difference
                    min_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(0)]
                    max_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(n_elements(i_sortpix)-1)]
                    
                    diff_resid(i_band, i_fit, i_id, i_size) = max_resid(i_band, i_fit, i_id, i_size) - min_resid(i_band, i_fit, i_id, i_size)
                    
                                ; take pixel values 1 sigma (enclosing middle 68%, so 16-84%)
                    min1_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(fix(0.16*n_elements(i_sortpix)))]
                    max1_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(fix(0.84*n_elements(i_sortpix)))]
                    
                    diff1_resid(i_band, i_fit, i_id, i_size) = max1_resid(i_band, i_fit, i_id, i_size) - min1_resid(i_band, i_fit, i_id, i_size)
                    

                                ; take pixel values 2 sigma (enclosing middle 95%, so 2.5-97.5%)
                    min2_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(fix(0.025*n_elements(i_sortpix)))]
                    max2_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(fix(0.975*n_elements(i_sortpix)))]
                    
                    diff2_resid(i_band, i_fit, i_id, i_size) = max2_resid(i_band, i_fit, i_id, i_size) - min2_resid(i_band, i_fit, i_id, i_size)
                    

                                ; take pixel values 3 sigma (enclosing middle 99%, so 0.5-99.5%)
                    min3_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(fix(0.005*n_elements(i_sortpix)))]
                    max3_resid(i_band, i_fit, i_id, i_size) = res_img_ctr[i_sortpix(fix(0.995*n_elements(i_sortpix)))]
                    
                    diff3_resid(i_band, i_fit, i_id, i_size) = max3_resid(i_band, i_fit, i_id, i_size) - min3_resid(i_band, i_fit, i_id, i_size)
                    
                    
                endif else begin ; end check that at least 1 image exists
                    
                    sum_resid(i_band, i_fit, i_id, i_size)   = -99.0
                    min_resid(i_band, i_fit, i_id, i_size)   = -99.0
                    max_resid(i_band, i_fit, i_id, i_size)   = -99.0
                    diff_resid(i_band, i_fit, i_id, i_size)  = -99.0
                    min1_resid(i_band, i_fit, i_id, i_size)  = -99.0
                    max1_resid(i_band, i_fit, i_id, i_size)  = -99.0
                    diff1_resid(i_band, i_fit, i_id, i_size) = -99.0
                    min2_resid(i_band, i_fit, i_id, i_size)  = -99.0
                    max2_resid(i_band, i_fit, i_id, i_size)  = -99.0
                    diff2_resid(i_band, i_fit, i_id, i_size) = -99.0
                    min3_resid(i_band, i_fit, i_id, i_size)  = -99.0
                    max3_resid(i_band, i_fit, i_id, i_size)  = -99.0
                    diff3_resid(i_band, i_fit, i_id, i_size) = -99.0

                endelse 

                printf, 33, region_size, sum_resid(i_band, i_fit, i_id, i_size),$
                  min_resid(i_band, i_fit, i_id, i_size), max_resid(i_band, i_fit, i_id, i_size), diff_resid(i_band, i_fit, i_id, i_size), $
                  min1_resid(i_band, i_fit, i_id, i_size), max1_resid(i_band, i_fit, i_id, i_size), diff1_resid(i_band, i_fit, i_id, i_size), $
                  min2_resid(i_band, i_fit, i_id, i_size), max2_resid(i_band, i_fit, i_id, i_size), diff2_resid(i_band, i_fit, i_id, i_size), $
                  min3_resid(i_band, i_fit, i_id, i_size), max3_resid(i_band, i_fit, i_id, i_size), diff3_resid(i_band, i_fit, i_id, i_size), $
                  avg_img(i_band, i_fit, i_id, i_size), med_img(i_band, i_fit, i_id, i_size), $
                  format='(I8, E15.3, E14.3, E11.3, E11.3, E14.3, E11.3, E11.3, E14.3, E11.3, E11.3, E14.3, E11.3, E11.3, E15.3, E11.3)'


            endfor              ; end loop through region size
            
            close, 33

        endfor                  ; end loop through fit types
    endfor                      ; end loop through bands
endfor                          ; end outer loop through ids

;print, input_oid(0)

;stop

return
end
