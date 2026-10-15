function get_ice_fn, ice_dir, yra, jda

   n_yr = fix(yra)                  ; float to int
   n_jd = fix(jda)
      
   num = 0                          ; no ice file
   loop = 5                         ; check till 5 days back if no ice file

   while ( (num eq 0) and (loop ge 0) ) do begin
         total_jd = julday( 1, 0, n_yr )
  print, n_yr
  print, total_jd
  print, n_jd
         total_jd = total_jd + n_jd
   
  print, total_jd
         caldat, total_jd, month, day, year
print, 'song', year
         year  = strtrim(year,1) 			; leading blanks are removed
         month = strtrim(month,1)
         day   = strtrim(day,1)
   print, year,' ',  month, ' ', day
 
         mn_arr = [ '00', '01','02','03' ,'04','05','06','07','08','09','10','11','12' ]
 
         s_yr = string(n_yr,format='(i4)')     
         s_jd = string(n_jd,format='(i3.3)')
         ice_fn = ice_dir + year + '/' + mn_arr(month) + '/g' + s_yr + s_jd + '00.lce'
           print, ice_fn             

         rt = file_search( ice_fn, count=num)
         if ( num eq 0 ) then begin
            n_jd = n_jd - 1
            if ( n_jd le 0 ) then begin
               
               n_yr = n_yr - 1

              if ( n_yr mod 4 ) then begin
                  n_jd = 365
              endif else begin
                  n_jd = 366
              endelse
            end
         end
         loop = loop - 1
            print, ice_fn, ' loop = ', loop, ' n_jd= ', n_jd

   endwhile
  
   if ( num eq 0 ) then begin
        ice_fn = ''
   end

   return, ice_fn
end

jda = 2.0
end_ice=158
begin_ice=318
yra=2017
ice_dir  = '/mnt/cwdata/p/s/lic/'

         if ( jda le end_ice or jda ge begin_ice) then begin                   ; ice season
             
            ice_fn = get_ice_fn( ice_dir, yra, jda)
          endif

end
