



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    getbulgeless: finds bulgeless disk galaxies in HZ
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


pro getbulgeless

     n_fetch        = 25
     nclass_min     = 30
     nobulge_min    = 0.0
     nobulge_max    = 1.0
     nobulge_step   = 0.1

     fetch_th = 1

                                ; Note: description of fits files at end of this file
     hz_classifications = mrdfits ('gzhsttable2.fits', 1)

                                ;GOODS - photometry, redshift, galfit morphologies from Roger Griffiths
                                ;hz_parentcat = mrdfits ('gz_hst_info.fits',1)
                                ;COSMOS
                                ;hz_parentcat = mrdfits ('gz_hst_info_cosmos.fits',1)

     for thresh = nobulge_min, nobulge_max, nobulge_step do begin


;         is_bulgeless = where(hz_classifications(*).T02_EDGEON_TOTAL_WEIGHT GE nclass_min AND hz_classifications(*).T09_BULGE_SHAPE_A27_NO_BULGE_WEIGHTED_FRACTION GE thresh AND hz_classifications(*).T09_BULGE_SHAPE_A27_NO_BULGE_WEIGHTED_FRACTION LT thresh+nobulge_step)

         whichq_str = 'T09'
         is_bulgeless = where(hz_classifications(*).T09_BULGE_SHAPE_TOTAL_WEIGHT GE nclass_min AND hz_classifications(*).T09_BULGE_SHAPE_A27_NO_BULGE_WEIGHTED_FRACTION GE thresh AND hz_classifications(*).T09_BULGE_SHAPE_A27_NO_BULGE_WEIGHTED_FRACTION LT thresh+nobulge_step)


;         whichq_str = 'T05'
;         is_bulgeless = where(hz_classifications(*).T05_BULGE_PROMINENCE_TOTAL_WEIGHT GE nclass_min AND hz_classifications(*).T05_BULGE_PROMINENCE_A10_NO_BULGE_WEIGHTED_FRACTION GE thresh AND hz_classifications(*).T05_BULGE_PROMINENCE_A10_NO_BULGE_WEIGHTED_FRACTION LT thresh+nobulge_step)

         ; only get a random sample of n_fetch objects
         i_get = fix(n_elements(is_bulgeless)*randomu(9236478, n_fetch))

                                ; fetch images
         for i=0, n_elements(i_get)-1 do begin

             if i_get(i) ge n_elements(is_bulgeless) then i_get(i) = n_elements(is_bulgeless)-1
             if i_get(i) lt 0 then i_get(i) = 0


             i_hz = is_bulgeless(i_get(i))

                                ; the file name is
                                ; "http://amazonawsurl/name.jpg"
             jpg_location = 'http://zoo-hst.s3.amazonaws.com/'+hz_classifications(i_hz).OBJID_STR+'.jpg'

             outjpg_name = 'jpg/bulgeless/'+whichq_str+'_thresh_'+strtrim(string(thresh, FORMAT='(F3.1)'),2)+'_nobulge_'+hz_classifications(i_hz).OBJID_STR+'.jpg'
                                ;print, outjpg_name(i)

             if fetch_th eq 1 then begin
                 spawn, 'wget '+jpg_location+' -O '+outjpg_name
             endif 

         endfor                 ; end fetching imgs 1

         print, n_elements(is_bulgeless), ' bulgeless between ',  thresh,' and ', thresh+nobulge_step

     endfor

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;; BEGIN DESCRIPTION OF FITS FILES ;;;;;;;;;;;;;;;;;;;
; simAGN_ids: 
; ** Structure <11ffe628>, 11 tags, length=112, data length=102, refs=1:
;    GROUPID         INT              0
;    LABEL           STRING    'original'
;    ZOONIVERSE_ID   STRING    'AHZ40008a4'
;    COLOR           STRING    'none'
;    LRAT            FLOAT           0.00000
;    ASSET_ID        LONG             21422
;    NAME            LONG          90045664
;    THUMBNAIL_LOCATION
;                    STRING    'http://zoo-hst-50.s3.amazonaws.com/90045664.jpg  '
;    RA              DOUBLE           53.202349
;    DEC             DOUBLE          -27.751297
;    REDSHIFT        DOUBLE          0.89977700
;
;
;
; hz_classifications: 
; ** Structure <1203bd18>, 283 tags, length=1152, data length=986, refs=1:
;    OBJID           LONG64                  10000189
;    ASSET_ID        LONG                 1
;    OBJID_STR       STRING    '10000189'
;    TOTAL_COUNT     INT            313
;    TOTAL_WEIGHT    FLOAT           308.367
;    T01_SMOOTH_OR_FEATURES_A01_SMOOTH_COUNT
;                    INT             65
;    T01_SMOOTH_OR_FEATURES_A01_SMOOTH_WEIGHT
;                    FLOAT           65.0000
;    T01_SMOOTH_OR_FEATURES_A01_SMOOTH_FRACTION
;                    FLOAT          0.714000
;    T01_SMOOTH_OR_FEATURES_A01_SMOOTH_WEIGHTED_FRACTION
;                    FLOAT          0.753000
;    T01_SMOOTH_OR_FEATURES_A02_FEATURES_OR_DISK_COUNT
;                    INT             15
;    T01_SMOOTH_OR_FEATURES_A02_FEATURES_OR_DISK_WEIGHT
;                    FLOAT           15.0000
;    T01_SMOOTH_OR_FEATURES_A02_FEATURES_OR_DISK_FRACTION
;                    FLOAT          0.165000
;    T01_SMOOTH_OR_FEATURES_A02_FEATURES_OR_DISK_WEIGHTED_FRACTION
;                    FLOAT          0.174000                
;    T01_SMOOTH_OR_FEATURES_A03_STAR_OR_ARTIFACT_COUNT
;                    INT             11
;    T01_SMOOTH_OR_FEATURES_A03_STAR_OR_ARTIFACT_WEIGHT
;                    FLOAT           6.36700
;    T01_SMOOTH_OR_FEATURES_A03_STAR_OR_ARTIFACT_FRACTION
;                    FLOAT          0.121000
;    T01_SMOOTH_OR_FEATURES_A03_STAR_OR_ARTIFACT_WEIGHTED_FRACTION
;                    FLOAT         0.0740000
;    T01_SMOOTH_OR_FEATURES_TOTAL_COUNT
;                    INT             91
;    T01_SMOOTH_OR_FEATURES_TOTAL_WEIGHT
;                    FLOAT           86.3670
;    T02_EDGEON_A04_YES_COUNT
;                    INT              0
;    T02_EDGEON_A04_YES_WEIGHT
;                    FLOAT           0.00000
;    T02_EDGEON_A04_YES_FRACTION
;                    FLOAT           0.00000
;    T02_EDGEON_A04_YES_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T02_EDGEON_A05_NO_COUNT                       
;                    INT             10
;    T02_EDGEON_A05_NO_WEIGHT
;                    FLOAT           10.0000
;    T02_EDGEON_A05_NO_FRACTION
;                    FLOAT           1.00000
;    T02_EDGEON_A05_NO_WEIGHTED_FRACTION
;                    FLOAT           1.00000
;    T02_EDGEON_TOTAL_COUNT
;                    INT             10
;    T02_EDGEON_TOTAL_WEIGHT
;                    FLOAT           10.0000
;    T03_BAR_A06_BAR_COUNT
;                    INT              0
;    T03_BAR_A06_BAR_WEIGHT
;                    FLOAT           0.00000
;    T03_BAR_A06_BAR_FRACTION
;                    FLOAT           0.00000
;    T03_BAR_A06_BAR_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T03_BAR_A07_NO_BAR_COUNT
;                    INT             10  
;    T03_BAR_A07_NO_BAR_WEIGHT
;                    FLOAT           10.0000
;    T03_BAR_A07_NO_BAR_FRACTION
;                    FLOAT           1.00000
;    T03_BAR_A07_NO_BAR_WEIGHTED_FRACTION
;                    FLOAT           1.00000
;    T03_BAR_TOTAL_COUNT
;                    INT             10
;    T03_BAR_TOTAL_WEIGHT
;                    FLOAT           10.0000
;    T04_SPIRAL_A08_SPIRAL_COUNT
;                    INT              0
;    T04_SPIRAL_A08_SPIRAL_WEIGHT
;                    FLOAT           0.00000
;    T04_SPIRAL_A08_SPIRAL_FRACTION
;                    FLOAT           0.00000
;    T04_SPIRAL_A08_SPIRAL_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T04_SPIRAL_A09_NO_SPIRAL_COUNT
;                    INT             10
;    T04_SPIRAL_A09_NO_SPIRAL_WEIGHT                         
;                    FLOAT           10.0000
;    T04_SPIRAL_A09_NO_SPIRAL_FRACTION
;                    FLOAT           1.00000
;    T04_SPIRAL_A09_NO_SPIRAL_WEIGHTED_FRACTION
;                    FLOAT           1.00000
;    T04_SPIRAL_TOTAL_COUNT
;                    INT             10
;    T04_SPIRAL_TOTAL_WEIGHT
;                    FLOAT           10.0000
;    T05_BULGE_PROMINENCE_A10_NO_BULGE_COUNT
;                    INT              0
;    T05_BULGE_PROMINENCE_A10_NO_BULGE_WEIGHT
;                    FLOAT           0.00000
;    T05_BULGE_PROMINENCE_A10_NO_BULGE_FRACTION
;                    FLOAT           0.00000
;    T05_BULGE_PROMINENCE_A10_NO_BULGE_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T05_BULGE_PROMINENCE_A11_JUST_NOTICEABLE_COUNT
;                    INT              0
;    T05_BULGE_PROMINENCE_A11_JUST_NOTICEABLE_WEIGHT
;                    FLOAT           0.00000               
;    T05_BULGE_PROMINENCE_A11_JUST_NOTICEABLE_FRACTION
;                    FLOAT           0.00000
;    T05_BULGE_PROMINENCE_A11_JUST_NOTICEABLE_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T05_BULGE_PROMINENCE_A12_OBVIOUS_COUNT
;                    INT              3
;    T05_BULGE_PROMINENCE_A12_OBVIOUS_WEIGHT
;                    FLOAT           3.00000
;    T05_BULGE_PROMINENCE_A12_OBVIOUS_FRACTION
;                    FLOAT          0.300000
;    T05_BULGE_PROMINENCE_A12_OBVIOUS_WEIGHTED_FRACTION
;                    FLOAT          0.300000
;    T05_BULGE_PROMINENCE_A13_DOMINANT_COUNT
;                    INT              7
;    T05_BULGE_PROMINENCE_A13_DOMINANT_WEIGHT
;                    FLOAT           7.00000
;    T05_BULGE_PROMINENCE_A13_DOMINANT_FRACTION
;                    FLOAT          0.700000
;    T05_BULGE_PROMINENCE_A13_DOMINANT_WEIGHTED_FRACTION
;                    FLOAT          0.700000
;    T05_BULGE_PROMINENCE_TOTAL_COUNT                   
;                    INT             10
;    T05_BULGE_PROMINENCE_TOTAL_WEIGHT
;                    FLOAT           10.0000
;    T06_ODD_A14_YES_COUNT
;                    INT              7
;    T06_ODD_A14_YES_WEIGHT
;                    FLOAT           7.00000
;    T06_ODD_A14_YES_FRACTION
;                    FLOAT         0.0880000
;    T06_ODD_A14_YES_WEIGHTED_FRACTION
;                    FLOAT         0.0880000
;    T06_ODD_A15_NO_COUNT
;                    INT             73
;    T06_ODD_A15_NO_WEIGHT
;                    FLOAT           73.0000
;    T06_ODD_A15_NO_FRACTION
;                    FLOAT          0.912000
;    T06_ODD_A15_NO_WEIGHTED_FRACTION
;                    FLOAT          0.912000
;    T06_ODD_TOTAL_COUNT
;                    INT             80                 
;    T06_ODD_TOTAL_WEIGHT
;                    FLOAT           80.0000
;    T07_ROUNDED_A16_COMPLETELY_ROUND_COUNT
;                    INT             50
;    T07_ROUNDED_A16_COMPLETELY_ROUND_WEIGHT
;                    FLOAT           50.0000
;    T07_ROUNDED_A16_COMPLETELY_ROUND_FRACTION
;                    FLOAT          0.769000
;    T07_ROUNDED_A16_COMPLETELY_ROUND_WEIGHTED_FRACTION
;                    FLOAT          0.769000
;    T07_ROUNDED_A17_IN_BETWEEN_COUNT
;                    INT             15
;    T07_ROUNDED_A17_IN_BETWEEN_WEIGHT
;                    FLOAT           15.0000
;    T07_ROUNDED_A17_IN_BETWEEN_FRACTION
;                    FLOAT          0.231000
;    T07_ROUNDED_A17_IN_BETWEEN_WEIGHTED_FRACTION
;                    FLOAT          0.231000
;    T07_ROUNDED_A18_CIGAR_SHAPED_COUNT
;                    INT              0
;    T07_ROUNDED_A18_CIGAR_SHAPED_WEIGHT                 
;                    FLOAT           0.00000
;    T07_ROUNDED_A18_CIGAR_SHAPED_FRACTION
;                    FLOAT           0.00000
;    T07_ROUNDED_A18_CIGAR_SHAPED_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T07_ROUNDED_TOTAL_COUNT
;                    INT             65
;    T07_ROUNDED_TOTAL_WEIGHT
;                    FLOAT           65.0000
;    T08_ODD_FEATURE_A19_RING_COUNT
;                    INT              2
;    T08_ODD_FEATURE_A19_RING_WEIGHT
;                    FLOAT           2.00000
;    T08_ODD_FEATURE_A19_RING_FRACTION
;                    FLOAT          0.286000
;    T08_ODD_FEATURE_A19_RING_WEIGHTED_FRACTION
;                    FLOAT          0.286000
;    T08_ODD_FEATURE_A20_LENS_OR_ARC_COUNT
;                    INT              1
;    T08_ODD_FEATURE_A20_LENS_OR_ARC_WEIGHT
;                    FLOAT           1.00000               
;    T08_ODD_FEATURE_A20_LENS_OR_ARC_FRACTION
;                    FLOAT          0.143000
;    T08_ODD_FEATURE_A20_LENS_OR_ARC_WEIGHTED_FRACTION
;                    FLOAT          0.143000
;    T08_ODD_FEATURE_A21_DISTURBED_COUNT
;                    INT              0
;    T08_ODD_FEATURE_A21_DISTURBED_WEIGHT
;                    FLOAT           0.00000
;    T08_ODD_FEATURE_A21_DISTURBED_FRACTION
;                    FLOAT           0.00000
;    T08_ODD_FEATURE_A21_DISTURBED_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T08_ODD_FEATURE_A22_IRREGULAR_COUNT
;                    INT              1
;    T08_ODD_FEATURE_A22_IRREGULAR_WEIGHT
;                    FLOAT           1.00000
;    T08_ODD_FEATURE_A22_IRREGULAR_FRACTION
;                    FLOAT          0.143000
;    T08_ODD_FEATURE_A22_IRREGULAR_WEIGHTED_FRACTION
;                    FLOAT          0.143000
;    T08_ODD_FEATURE_A23_OTHER_COUNT                    
;                    INT              2
;    T08_ODD_FEATURE_A23_OTHER_WEIGHT
;                    FLOAT           2.00000
;    T08_ODD_FEATURE_A23_OTHER_FRACTION
;                    FLOAT          0.286000
;    T08_ODD_FEATURE_A23_OTHER_WEIGHTED_FRACTION
;                    FLOAT          0.286000
;    T08_ODD_FEATURE_A24_MERGER_COUNT
;                    INT              1
;    T08_ODD_FEATURE_A24_MERGER_WEIGHT
;                    FLOAT           1.00000
;    T08_ODD_FEATURE_A24_MERGER_FRACTION
;                    FLOAT          0.143000
;    T08_ODD_FEATURE_A24_MERGER_WEIGHTED_FRACTION
;                    FLOAT          0.143000
;    T08_ODD_FEATURE_A38_DUST_LANE_COUNT
;                    INT              0
;    T08_ODD_FEATURE_A38_DUST_LANE_WEIGHT
;                    FLOAT           0.00000
;    T08_ODD_FEATURE_A38_DUST_LANE_FRACTION
;                    FLOAT           0.00000                
;    T08_ODD_FEATURE_A38_DUST_LANE_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T08_ODD_FEATURE_TOTAL_COUNT
;                    INT              7
;    T08_ODD_FEATURE_TOTAL_WEIGHT
;                    FLOAT           7.00000
;    T09_BULGE_SHAPE_A25_ROUNDED_COUNT
;                    INT              0
;    T09_BULGE_SHAPE_A25_ROUNDED_WEIGHT
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A25_ROUNDED_FRACTION
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A25_ROUNDED_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A26_BOXY_COUNT
;                    INT              0
;    T09_BULGE_SHAPE_A26_BOXY_WEIGHT
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A26_BOXY_FRACTION
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A26_BOXY_WEIGHTED_FRACTION           
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A27_NO_BULGE_COUNT
;                    INT              0
;    T09_BULGE_SHAPE_A27_NO_BULGE_WEIGHT
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A27_NO_BULGE_FRACTION
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_A27_NO_BULGE_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T09_BULGE_SHAPE_TOTAL_COUNT
;                    INT              0
;    T09_BULGE_SHAPE_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A28_TIGHT_COUNT
;                    INT              0
;    T10_ARMS_WINDING_A28_TIGHT_WEIGHT
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A28_TIGHT_FRACTION
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A28_TIGHT_WEIGHTED_FRACTION
;                    FLOAT           0.00000              
;    T10_ARMS_WINDING_A29_MEDIUM_COUNT
;                    INT              0
;    T10_ARMS_WINDING_A29_MEDIUM_WEIGHT
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A29_MEDIUM_FRACTION
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A29_MEDIUM_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A30_LOOSE_COUNT
;                    INT              0
;    T10_ARMS_WINDING_A30_LOOSE_WEIGHT
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A30_LOOSE_FRACTION
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_A30_LOOSE_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T10_ARMS_WINDING_TOTAL_COUNT
;                    INT              0
;    T10_ARMS_WINDING_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A31_1_COUNT                        
;                    INT              0
;    T11_ARMS_NUMBER_A31_1_WEIGHT
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A31_1_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A31_1_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A32_2_COUNT
;                    INT              0
;    T11_ARMS_NUMBER_A32_2_WEIGHT
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A32_2_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A32_2_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A33_3_COUNT
;                    INT              0
;    T11_ARMS_NUMBER_A33_3_WEIGHT
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A33_3_FRACTION
;                    FLOAT           0.00000                
;    T11_ARMS_NUMBER_A33_3_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A34_4_COUNT
;                    INT              0
;    T11_ARMS_NUMBER_A34_4_WEIGHT
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A34_4_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A34_4_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A36_MORE_THAN_4_COUNT
;                    INT              0
;    T11_ARMS_NUMBER_A36_MORE_THAN_4_WEIGHT
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A36_MORE_THAN_4_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A36_MORE_THAN_4_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A37_CANT_TELL_COUNT
;                    INT              0
;    T11_ARMS_NUMBER_A37_CANT_TELL_WEIGHT               
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A37_CANT_TELL_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_A37_CANT_TELL_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T11_ARMS_NUMBER_TOTAL_COUNT
;                    INT              0
;    T11_ARMS_NUMBER_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T12_ARMS_NUMBER_TOTAL_COUNT
;                    INT              0
;    T12_ARMS_NUMBER_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T13_ARMS_NUMBER_TOTAL_COUNT
;                    INT              0
;    T13_ARMS_NUMBER_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T14_CLUMPY_A39_YES_COUNT
;                    INT              5
;    T14_CLUMPY_A39_YES_WEIGHT
;                    FLOAT           5.00000               
;    T14_CLUMPY_A39_YES_FRACTION
;                    FLOAT          0.333000
;    T14_CLUMPY_A39_YES_WEIGHTED_FRACTION
;                    FLOAT          0.333000
;    T14_CLUMPY_A40_NO_COUNT
;                    INT             10
;    T14_CLUMPY_A40_NO_WEIGHT
;                    FLOAT           10.0000
;    T14_CLUMPY_A40_NO_FRACTION
;                    FLOAT          0.667000
;    T14_CLUMPY_A40_NO_WEIGHTED_FRACTION
;                    FLOAT          0.667000
;    T14_CLUMPY_TOTAL_COUNT
;                    INT             15
;    T14_CLUMPY_TOTAL_WEIGHT
;                    FLOAT           15.0000
;    T15_MULTIPLE_CLUMPS_A41_YES_COUNT
;                    INT              0
;    T15_MULTIPLE_CLUMPS_A41_YES_WEIGHT
;                    FLOAT           0.00000
;    T15_MULTIPLE_CLUMPS_A41_YES_FRACTION                
;                    FLOAT           0.00000
;    T15_MULTIPLE_CLUMPS_A41_YES_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T15_MULTIPLE_CLUMPS_A42_NO_COUNT
;                    INT              0
;    T15_MULTIPLE_CLUMPS_A42_NO_WEIGHT
;                    FLOAT           0.00000
;    T15_MULTIPLE_CLUMPS_A42_NO_FRACTION
;                    FLOAT           0.00000
;    T15_MULTIPLE_CLUMPS_A42_NO_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T15_MULTIPLE_CLUMPS_TOTAL_COUNT
;                    INT              0
;    T15_MULTIPLE_CLUMPS_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T16_BRIGHT_CLUMP_A43_YES_COUNT
;                    INT              0
;    T16_BRIGHT_CLUMP_A43_YES_WEIGHT
;                    FLOAT           0.00000
;    T16_BRIGHT_CLUMP_A43_YES_FRACTION
;                    FLOAT           0.00000                
;    T16_BRIGHT_CLUMP_A43_YES_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T16_BRIGHT_CLUMP_A44_NO_COUNT
;                    INT              0
;    T16_BRIGHT_CLUMP_A44_NO_WEIGHT
;                    FLOAT           0.00000
;    T16_BRIGHT_CLUMP_A44_NO_FRACTION
;                    FLOAT           0.00000
;    T16_BRIGHT_CLUMP_A44_NO_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T16_BRIGHT_CLUMP_TOTAL_COUNT
;                    INT              0
;    T16_BRIGHT_CLUMP_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T17_BRIGHT_CLUMP_CENTRAL_A45_YES_COUNT
;                    INT              0
;    T17_BRIGHT_CLUMP_CENTRAL_A45_YES_WEIGHT
;                    FLOAT           0.00000
;    T17_BRIGHT_CLUMP_CENTRAL_A45_YES_FRACTION
;                    FLOAT           0.00000
;    T17_BRIGHT_CLUMP_CENTRAL_A45_YES_WEIGHTED_FRACTION             
;                    FLOAT           0.00000
;    T17_BRIGHT_CLUMP_CENTRAL_A46_NO_COUNT
;                    INT              0
;    T17_BRIGHT_CLUMP_CENTRAL_A46_NO_WEIGHT
;                    FLOAT           0.00000
;    T17_BRIGHT_CLUMP_CENTRAL_A46_NO_FRACTION
;                    FLOAT           0.00000
;    T17_BRIGHT_CLUMP_CENTRAL_A46_NO_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T17_BRIGHT_CLUMP_CENTRAL_TOTAL_COUNT
;                    INT              0
;    T17_BRIGHT_CLUMP_CENTRAL_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A47_LINE_COUNT
;                    INT              0
;    T18_CLUMPS_ARRANGEMENT_A47_LINE_WEIGHT
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A47_LINE_FRACTION
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A47_LINE_WEIGHTED_FRACTION
;                    FLOAT           0.00000                    
;    T18_CLUMPS_ARRANGEMENT_A48_CHAIN_COUNT
;                    INT              0
;    T18_CLUMPS_ARRANGEMENT_A48_CHAIN_WEIGHT
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A48_CHAIN_FRACTION
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A48_CHAIN_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A49_CLUSTER_COUNT
;                    INT              0
;    T18_CLUMPS_ARRANGEMENT_A49_CLUSTER_WEIGHT
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A49_CLUSTER_FRACTION
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A49_CLUSTER_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A59_SPIRAL_COUNT
;                    INT              0
;    T18_CLUMPS_ARRANGEMENT_A59_SPIRAL_WEIGHT
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A59_SPIRAL_FRACTION            
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_A59_SPIRAL_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T18_CLUMPS_ARRANGEMENT_TOTAL_COUNT
;                    INT              0
;    T18_CLUMPS_ARRANGEMENT_TOTAL_WEIGHT
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A50_2_COUNT
;                    INT              0
;    T19_CLUMPS_COUNT_A50_2_WEIGHT
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A50_2_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A50_2_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A51_3_COUNT
;                    INT              0
;    T19_CLUMPS_COUNT_A51_3_WEIGHT
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A51_3_FRACTION
;                    FLOAT           0.00000  
;    T19_CLUMPS_COUNT_A51_3_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A52_4_COUNT
;                    INT              0
;    T19_CLUMPS_COUNT_A52_4_WEIGHT
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A52_4_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A52_4_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A53_MORE_THAN_4_COUNT
;                    INT              0
;    T19_CLUMPS_COUNT_A53_MORE_THAN_4_WEIGHT
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A53_MORE_THAN_4_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A53_MORE_THAN_4_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A54_CANT_TELL_COUNT
;                    INT              0
;    T19_CLUMPS_COUNT_A54_CANT_TELL_WEIGHT
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A54_CANT_TELL_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A54_CANT_TELL_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T19_CLUMPS_COUNT_A60_1_COUNT
;                    INT              5
;    T19_CLUMPS_COUNT_A60_1_WEIGHT
;                    FLOAT           5.00000
;    T19_CLUMPS_COUNT_A60_1_FRACTION
;                    FLOAT           1.00000
;    T19_CLUMPS_COUNT_A60_1_WEIGHTED_FRACTION
;                    FLOAT           1.00000
;    T19_CLUMPS_COUNT_TOTAL_COUNT
;                    INT              5
;    T19_CLUMPS_COUNT_TOTAL_WEIGHT
;                    FLOAT           5.00000
;    T20_CLUMPS_SYMMETRICAL_A55_YES_COUNT
;                    INT              5
;    T20_CLUMPS_SYMMETRICAL_A55_YES_WEIGHT
;                    FLOAT           5.00000    
;    T20_CLUMPS_SYMMETRICAL_A55_YES_FRACTION
;                    FLOAT           1.00000
;    T20_CLUMPS_SYMMETRICAL_A55_YES_WEIGHTED_FRACTION
;                    FLOAT           1.00000
;    T20_CLUMPS_SYMMETRICAL_A56_NO_COUNT
;                    INT              0
;    T20_CLUMPS_SYMMETRICAL_A56_NO_WEIGHT
;                    FLOAT           0.00000
;    T20_CLUMPS_SYMMETRICAL_A56_NO_FRACTION
;                    FLOAT           0.00000
;    T20_CLUMPS_SYMMETRICAL_A56_NO_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T20_CLUMPS_SYMMETRICAL_TOTAL_COUNT
;                    INT              5
;    T20_CLUMPS_SYMMETRICAL_TOTAL_WEIGHT
;                    FLOAT           5.00000
;    T21_CLUMPS_EMBEDDED_A57_YES_COUNT
;                    INT              5
;    T21_CLUMPS_EMBEDDED_A57_YES_WEIGHT
;                    FLOAT           5.00000
;    T21_CLUMPS_EMBEDDED_A57_YES_FRACTION     
;                    FLOAT           1.00000
;    T21_CLUMPS_EMBEDDED_A57_YES_WEIGHTED_FRACTION
;                    FLOAT           1.00000
;    T21_CLUMPS_EMBEDDED_A58_NO_COUNT
;                    INT              0
;    T21_CLUMPS_EMBEDDED_A58_NO_WEIGHT
;                    FLOAT           0.00000
;    T21_CLUMPS_EMBEDDED_A58_NO_FRACTION
;                    FLOAT           0.00000
;    T21_CLUMPS_EMBEDDED_A58_NO_WEIGHTED_FRACTION
;                    FLOAT           0.00000
;    T21_CLUMPS_EMBEDDED_TOTAL_COUNT
;                    INT              5
;    T21_CLUMPS_EMBEDDED_TOTAL_WEIGHT
;                    FLOAT           5.00000
;
;
;
; hz_parentcat:
; ** Structure <1200d298>, 97 tags, length=464, data length=460, refs=1:
;    OBJNO           LONG          10000189
;    SURVEY_ID       LONG              -999
;    RA              DOUBLE           214.23582
;    DEC             DOUBLE           52.396332
;    NTOT_HI         LONG                 2
;    NTOT_LOW        LONG                 2
;    IMAGING         STRING    'AEGIS  '
;    SPECZ           FLOAT          -999.000
;    PHOTOZ          FLOAT          -999.000
;    PHOTOZ_CHI2     FLOAT          -999.000
;    PHOTOZ_ERR      FLOAT           0.00000
;    ZQUALITY        FLOAT          -999.000
;    Z_ORIGIN        STRING    '           '
;    Z               FLOAT          -999.000
;    MAGB            FLOAT          -999.000
;    MAGB_ERR        FLOAT          -999.000
;    MAGR            FLOAT          -999.000
;    MAGR_ERR        FLOAT          -999.000
;    MAGI            FLOAT          -999.000
;    MAGI_ERR        FLOAT          -999.000
;    CFHT_U          FLOAT           27.8230  
;    CFHT_U_ERR      FLOAT           1.29700
;    CFHT_G          FLOAT           25.6870
;    CFHT_G_ERR      FLOAT          0.101000
;    CFHT_R          FLOAT           23.6520
;    CFHT_R_ERR      FLOAT         0.0200000
;    CFHT_I          FLOAT           22.2960
;    CFHT_I_ERR      FLOAT        0.00700000
;    CFHT_Z          FLOAT           21.6180
;    CFHT_Z_ERR      FLOAT         0.0110000
;    EBV             FLOAT          -999.000
;    CLASS           STRING    '               '
;    MU_HI           FLOAT           20.7488
;    MU_LOW          FLOAT           23.1473
;    THETA_IMAGE_HI  DOUBLE           14.200000
;    THETA_IMAGE_LOW DOUBLE           27.700000
;    THETA_WORLD_HI  DOUBLE          -32.795274
;    THETA_WORLD_LOW DOUBLE          -19.295274
;    BA_HI           FLOAT          0.770000
;    BA_LOW          FLOAT          0.911000
;    KRON_RADIUS_HI  FLOAT           3.80000
;    KRON_RADIUS_LOW FLOAT           5.08000   
;    FWHM_HI         FLOAT           0.00000
;    FWHM_LOW        FLOAT           8.39000
;    A_IMAGE_HI      FLOAT           7.87500
;    A_IMAGE_LOW     FLOAT           5.31700
;    B_IMAGE_HI      FLOAT           6.06400
;    B_IMAGE_LOW     FLOAT           4.84400
;    BACKGROUND_HI   FLOAT          0.503155
;    BACKGROUND_LOW  FLOAT          0.581530
;    FLUX_BEST_HI    FLOAT           64279.8
;    FLUX_BEST_LOW   FLOAT           21261.3
;    FLUXERR_BEST_HI FLOAT           258.222
;    FLUXERR_BEST_LOW
;                    FLOAT           283.257
;    MAG_BEST_HI     FLOAT           22.2224
;    MAG_BEST_LOW    FLOAT           24.0523
;    MAGERR_BEST_HI  FLOAT        0.00440000
;    MAGERR_BEST_LOW FLOAT         0.0145000
;    FLUX_RADIUS_HI  FLOAT           2.74700
;    FLUX_RADIUS_LOW FLOAT           2.89300
;    ISOAREA_IMAGE_HI
;                    FLOAT           1200.00     
;    ISOAREA_IMAGE_LOW
;                    FLOAT           442.000
;    SEX_FLAGS_HI    LONG                 4
;    SEX_FLAGS_LOW   LONG                 4
;    FLAG_GALFIT_HI  LONG                 0
;    FLAG_GALFIT_LOW LONG                 0
;    CHI2NU_HI       FLOAT           1.38300
;    CHI2NU_LOW      FLOAT           1.22900
;    CLASS_STAR_HI   FLOAT         0.0300000
;    CLASS_STAR_LOW  FLOAT         0.0400000
;    X_GALFIT_HI     FLOAT           86.4300
;    X_GALFIT_LOW    FLOAT           87.9100
;    Y_GALFIT_HI     FLOAT           73.3200
;    Y_GALFIT_LOW    FLOAT           86.6000
;    MAG_GALFIT_HI   FLOAT           22.0000
;    MAG_GALFIT_LOW  FLOAT           23.6500
;    RE_GALFIT_HI    FLOAT           7.45000
;    RE_GALFIT_LOW   FLOAT           8.81000
;    N_GALFIT_HI     FLOAT           4.84000
;    N_GALFIT_LOW    FLOAT           5.73000
;    BA_GALFIT_HI    FLOAT          0.820000   
;    BA_GALFIT_LOW   FLOAT          0.990000
;    PA_GALFIT_HI    FLOAT          -74.0600
;    PA_GALFIT_LOW   FLOAT          -44.9500
;    SKY_GALFIT_HI   FLOAT         0.0100000
;    SKY_GALFIT_LOW  FLOAT          0.190000
;    MAGERR_GALFIT_HI
;                    FLOAT         0.0100000
;    MAGERR_GALFIT_LOW
;                    FLOAT         0.0500000
;    REERR_GALFIT_HI FLOAT          0.230000
;    REERR_GALFIT_LOW
;                    FLOAT          0.910000
;    NERR_GALFIT_HI  FLOAT          0.150000
;    NERR_GALFIT_LOW FLOAT          0.460000
;    BAERR_GALFIT_HI FLOAT         0.0100000
;    BAERR_GALFIT_LOW
;                    FLOAT         0.0300000
;    PAERR_GALFIT_HI FLOAT           2.29000
;    PAERR_GALFIT_LOW
;                    FLOAT           173.970
;    VIS_MORPH       STRING    '           0'           

;;;;;;;;;;;;;;;;;; END DESCRIPTION OF FITS FILES ;;;;;;;;;;;;;;;;;;;;



