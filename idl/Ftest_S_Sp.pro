pro Ftest_S_Sp

  modifier = '_ctrmask'
;  modifier = ''
  SJfile  = 'fitcat_agn'+modifier+'_f125w.S.cat'
  SHfile  = 'fitcat_agn'+modifier+'_f160w.S.cat'
  SpJfile = 'fitcat_agn'+modifier+'_f125w.Sp.cat'
  SpHfile = 'fitcat_agn'+modifier+'_f160w.Sp.cat'

  outfile = 'Ftest_S_Sp'+modifier+'_lowerdof_out.dat'

  S_J  = read_ascii(SJfile, data_start=0)
  S_H  = read_ascii(SHfile, data_start=0)
  Sp_J = read_ascii(SpJfile, data_start=0)
  Sp_H = read_ascii(SpHfile, data_start=0)

  S_J  = S_J.field01
  S_H  = S_H.field01
  Sp_J = Sp_J.field01
  Sp_H = Sp_H.field01

  chi2_S  = 21-1
  nu_S    = 22-1
  chi2_Sp = 38-1
  nu_Sp   = 39-1

  ;F = ( (CHI1-CHI2)/(DOF1-DOF2) )   /  (CHI2/DOF2)

  dof_correction = 0.220  ; drizzling process correlates pixels
  ; the correction factor should be based on new/orig pixel area ratio
  ; for CANDELS, (0.06/0.128)^2
  ; except I think that's too low because it doesn't account for
  ; offset multi-epoch data
  ; should figure out the offset and calculate a new DOF-pixel
  ; size based on that.
  ;dof_correction = 1.0  ; no correction for correlated pixels
  ; note DOF1 > DOF2 for this to work
  dnu_J = fix((S_J(nu_S,*)-Sp_J(nu_Sp,*))*dof_correction)
  dnu_H = fix((S_H(nu_S,*)-Sp_H(nu_Sp,*))*dof_correction)

  ; weird? should never be the case 
  dnu_J(where(dnu_J lt 0.01)) = 1.000
  dnu_H(where(dnu_H lt 0.01)) = 1.000

  F_J = ((S_J(chi2_S,*) - Sp_J(chi2_Sp,*))/(dnu_J))/(Sp_J(chi2_Sp,*)/Sp_J(nu_Sp,*))
  F_H = ((S_H(chi2_S,*) - Sp_H(chi2_Sp,*))/(dnu_H))/(Sp_H(chi2_Sp,*)/Sp_H(nu_Sp,*))

  ; this is only the case when the fit is obviously not better
  ; (I checked each one)
  F_J(where(F_J lt 0.00)) = 0.00
  F_H(where(F_H lt 0.00)) = 0.00

  prob_J = dnu_J - dnu_J
  prob_H = dnu_H - dnu_H

  openw, 3, outfile

  printf, 3, '#ID', 'prob_f125', 'prob_f160', format='(A8, A11, A11)'
  for i=0, n_elements(prob_J)-1 do begin
  ; PROB = MPFTEST(F, DOF1-DOF2, DOF2, ... )
      ;print, 'prob_J(i) = mpftest(',F_J(i), ',', dnu_J(i), ',', SP_J(nu_Sp, i), ')'
      prob_J(i) = mpftest(F_J(i), dnu_J(i), Sp_J(nu_Sp,i))
      ;print, 'prob_H(i) = mpftest(',F_H(i), ',', dnu_H(i), ',', SP_H(nu_Sp, i), ')'
      prob_H(i) = mpftest(F_H(i), dnu_H(i), Sp_H(nu_Sp,i))

      print, 'J:', F_J(i), prob_J(i), '  & H:', F_H(i), prob_H(i)

      printf, 3, S_J(0,i), prob_J(i), prob_H(i), $
        format='(I8, E11.3, E11.3)'

  endfor 


  close, 3

  stop

end
