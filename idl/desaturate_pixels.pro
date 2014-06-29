;+
; NAME:
;   desaturate_pixels
; BUGS:
;   
;-
function desaturate_pixels, r, g, b, beta_fac = beta_fac

; Optionally desaturate pixels that are dominated by a single
; colour to avoid colourful speckled sky

; Based on Steven Bamford's technique for MegaMorph
; https://github.com/MegaMorph/galfitm-illustrations/blob/master/RGBImage.py#L168

if ~keyword_set(beta_fac) then beta_fac = 2.

a = (r+g+b)/3.0
; Replace all pixels where the full color is zero with value of 1. Not sure why.
; N.putmask(a, a == 0.0, 1.0)
a[where(a eq 0.0)] = 1.0
rab = r / a / beta_fac
gab = g / a / beta_fac
bab = b / a / beta_fac
mask = [[[rab]],[[gab]],[[bab]]]
w = max(mask, dimension=3)
w[where(w gt 1.0)] = 1.0
w = 1. - w
w = sin(w*!pi/2.0)
r = r*w + a*(1-w)
g = g*w + a*(1-w)
b = b*w + a*(1-w)

return,[[[r]], [[g]], [[b]]]

end
