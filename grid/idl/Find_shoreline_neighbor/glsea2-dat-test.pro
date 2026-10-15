;--------------------------------------------------------------------------
pro cwmap,ipx,jpx,lat,lon,conv
;--------------------------------------------------------------------------
; Subroutine cwmap: Return pixel location, given latitude and longitude, or
;  latitude and longitude given pixel location within synoptic 1024x1024
;  CoastWatch image. (Approximate WGS-84 Mercator Projection - DJS 2007)


   ; Set conv to -1 for (lat, lon) to (ipx, jpx) conversion,
   ; anything else for inverse

   slat  =  38.8744   ;  Southern latitude
   wlon  = -92.4106   ;  Western longitude
   elon  = -75.8690   ;  Eastern longitude

   f1 = 0.99664  ; N-S scale adjustment for WGS-84

   ; Constants

   alon0 = -wlon
   a1 = 1023. / (!dtor * ( elon-wlon ) )
   y0 = a1 * alog(tan (!dtor * (45.0 + slat / 2.) ))

   ; Calculate latitude and longitude if conv = -1, else calculate ipx and jpx

   if(conv eq -1) then begin
      ipx=fix(a1*!dtor*(alon0-lon)+0.5)
      jpx=fix(f1*(a1*alog(tan(!dtor*(45.+lat/2.)))-y0)+0.5)       
   end else begin
      lat = 2.0 * ((( atan ( exp ( (jpx/f1 + y0) / a1) )) / !dtor) - 45.0)
      lon = -1.0*((ipx / (a1 * !dtor)) - alon0)     
   end

   return
end

;--------------------------------------------------------------------------

function get_ice_concentration, raw_ice

   sicode  = ['10','20','30','40','50','60','70','80','90','91','92','93',     $
              '01','02','12','13','24','35','45','46','57','68','79','89','81',$
              '11','22','23','33','34','44','55','56','66','67','77','78','88']

                                                   ; GLSEA ice color index

   clridx  = [ 12,  14,  16,  18,  20,  22,  24,  26,  28,  29,  30,  30,      $
               11,  12,  13,  14,  16,  18,  19,  20,  22,  24,  26,  27,  28, $
               12,  14,  15,  16,  17,  18,  20,  21,  22,  23,  24,  25,  26]

;-----------------------------------------------------------------------------------
;  Color               Median Ice                  Color               Median Ice
;  index    SI Code   Concentration                index    SI Code    Concentration
;-----------------------------------------------------------------------------------
;   11          01          5                       24    68,70,77         70
;   -------------------------
;   12    02,10,11         10                       25          78         75
;                                                   26    79,80,88         80
;   13       12,15         15                       27          89         85
;                                                   -------------------------
;   14    13,20,22         20                       28       81,90         90
;   15          23         25                       29          91         95
;   16    24,30,33         30                       -------------------------
;   17          34         35                       30       92,93        100
;   -------------------------
;   18    35,40,44         40
;   19          45         45                     11-12  Off-white
;   20    46,50,55         50                     13-17  Light gray
;   21          56         55                     18-23  Medium gray
;   22    57,60,66         60                     24-29  Dark gray
;   23          67         65                     30-30  Black
;-----------------------------------------------------------------------------------

   asc_arr = bytarr(1024,1024)

   ice_index = where( (raw_ice ne 255) and (raw_ice ne 0) )  ; 0 = water,  255 = land (in lce file it is -1)
   
   c_01 = where(raw_ice eq 1, c_num)
   if (c_num ne 0 ) then asc_arr( c_01 ) = 5 
      
   c_02 = where(raw_ice eq 2, c_num)
   if (c_num ne 0 ) then asc_arr( c_02 ) = 10
   
   c_10 = where(raw_ice eq 10, c_num)
   if (c_num ne 0 ) then asc_arr( c_10 ) = 10
    
   c_11 = where(raw_ice eq 11, c_num)
   if (c_num ne 0 ) then asc_arr( c_11 ) = 10
         
   c_12 = where(raw_ice eq 12, c_num)
   if (c_num ne 0 ) then asc_arr( c_12 ) = 15
    
   c_15 = where(raw_ice eq 15, c_num)
   if (c_num ne 0 ) then asc_arr( c_15 ) = 15     
   
   c_13 = where(raw_ice eq 13, c_num)
   if (c_num ne 0 ) then asc_arr( c_13 ) = 20
   
   c_20 = where(raw_ice eq 20, c_num)
   if (c_num ne 0 ) then asc_arr( c_20 ) = 20
    
   c_22 = where(raw_ice eq 22, c_num)
   if (c_num ne 0 ) then asc_arr( c_22 ) = 20   
  
   c_23 = where(raw_ice eq 23, c_num)
   if (c_num ne 0 ) then asc_arr( c_23 ) = 25   
    
   c_24 = where(raw_ice eq 24, c_num)
   if (c_num ne 0 ) then asc_arr( c_24 ) = 30 
   
   c_30 = where(raw_ice eq 30, c_num)
   if (c_num ne 0 ) then asc_arr( c_30 ) = 30
    
   c_33 = where(raw_ice eq 33, c_num)
   if (c_num ne 0 ) then asc_arr( c_33 ) = 30   
   
   c_34 = where(raw_ice eq 34, c_num)
   if (c_num ne 0 ) then asc_arr( c_34 ) = 35  
    
   c_35 = where(raw_ice eq 35, c_num)
   if (c_num ne 0 ) then asc_arr( c_35 ) = 40
   
   c_40 = where(raw_ice eq 40, c_num)
   if (c_num ne 0 ) then asc_arr( c_40 ) = 40
    
   c_44= where(raw_ice eq 44, c_num)
   if (c_num ne 0 ) then asc_arr( c_44 ) = 40   
 
   c_45= where(raw_ice eq 45, c_num)
   if (c_num ne 0 ) then asc_arr( c_45 ) = 45   
  
   c_46 = where(raw_ice eq 46, c_num)
   if (c_num ne 0 ) then asc_arr( c_46 ) = 50
   
   c_50 = where(raw_ice eq 50, c_num)
   if (c_num ne 0 ) then asc_arr( c_50 ) = 50
    
   c_55= where(raw_ice eq 55, c_num)
   if (c_num ne 0 ) then asc_arr( c_55 ) = 50
      
   c_56= where(raw_ice eq 56, c_num)
   if (c_num ne 0 ) then asc_arr( c_56 ) = 55      
   
   c_57 = where(raw_ice eq 57, c_num)
   if (c_num ne 0 ) then asc_arr( c_57 ) = 60
   
   c_60 = where(raw_ice eq 60, c_num)
   if (c_num ne 0 ) then asc_arr( c_60 ) = 60
    
   c_66= where(raw_ice eq 66, c_num)
   if (c_num ne 0 ) then asc_arr( c_66 ) = 60
  
   c_67= where(raw_ice eq 67, c_num)
   if (c_num ne 0 ) then asc_arr( c_67 ) = 65
  
   c_68 = where(raw_ice eq 68, c_num)
   if (c_num ne 0 ) then asc_arr( c_68 ) = 70
   
   c_70 = where(raw_ice eq 70, c_num)
   if (c_num ne 0 ) then asc_arr( c_70 ) = 70
    
   c_77= where(raw_ice eq 77, c_num)
   if (c_num ne 0 ) then asc_arr( c_77 ) = 70
 
   c_78= where(raw_ice eq 78, c_num)
   if (c_num ne 0 ) then asc_arr( c_78 ) = 75
 
   c_79 = where(raw_ice eq 79, c_num)
   if (c_num ne 0 ) then asc_arr( c_79 ) = 80
   
   c_80 = where(raw_ice eq 80, c_num)
   if (c_num ne 0 ) then asc_arr( c_80 ) = 80
    
   c_88= where(raw_ice eq 88, c_num)
   if (c_num ne 0 ) then asc_arr( c_88 ) = 80

   c_89= where(raw_ice eq 89, c_num)
   if (c_num ne 0 ) then asc_arr( c_89 ) = 85 
  
   c_81 = where(raw_ice eq 81, c_num)
   if (c_num ne 0 ) then asc_arr( c_81 ) = 90
   
   c_90 = where(raw_ice eq 90, c_num)
   if (c_num ne 0 ) then asc_arr( c_90 ) = 90        
    
   c_91= where(raw_ice eq 91, c_num)
   if (c_num ne 0 ) then asc_arr( c_91 ) = 95

   c_92= where(raw_ice eq 92, c_num)
   if (c_num ne 0 ) then asc_arr( c_92 ) = 100
  
   c_93= where(raw_ice eq 93, c_num)
   if (c_num ne 0 ) then asc_arr( c_93 ) = 100
       
   return, asc_arr
end

;-----------------------------------------------------------------------------------

function get_year_month_day, yra, jda
   
   n_yr = fix(yra)                  ; float to int
   n_jd = fix(jda)

   total_jd = julday( 1, 0, n_yr )
   total_jd = total_jd + n_jd

   caldat, total_jd, month, day, year
   year  = strtrim(year,1) 			; leading blanks are removed
   month = strtrim(month,1)
   day   = strtrim(day,1)
   
   y_m_d = string(year, format='(i4)') + string(month,format='(i2.2)') +string(day,format='(i2.2)')  
   return, y_m_d
end

;-----------------------------------------------------------------------------------

function get_ice_fn, ice_dir, yra, jda

   n_yr = fix(yra)                  ; float to int
   n_jd = fix(jda)
      
   num = 0                          ; no ice file
   loop = 5                         ; check till 5 days back if no ice file

   while ( (num eq 0) and (loop ge 0) ) do begin
         total_jd = julday( 1, 0, n_yr )
         total_jd = total_jd + n_jd
   
         caldat, total_jd, month, day, year
         year  = strtrim(year,1) 			; leading blanks are removed
         month = strtrim(month,1)
         day   = strtrim(day,1)
 
         mn_arr = [ '00', '01','02','03' ,'04','05','06','07','08','09','10','11','12' ]
 
         s_yr = string(n_yr,format='(i4)')     
         s_jd = string(n_jd,format='(i3.3)')
         ice_fn = ice_dir + year + '/' + mn_arr(month) + '/g' + s_yr + s_jd + '00.lce'

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


;-----------------------------------------------------------------------------------

pro ch_ipx_jpx, ch_ncep_fn, ipx, jpx, indx_arr, c_i_arr, c_j_arr
   
   index_len = 22  ; 22 point out of the water that need to swift from land to water

   indx = 0
   c_i = 0
   c_j = 0
   line = ' '
  
   openr, lun, ch_ncep_fn, /get_lun
   readf, lun, line

   for k=0, index_len-1 do begin
      readf, lun, line
         ; print, line
      reads, line, indx, c_i, c_j     
      ipx(indx) = ipx(indx) + c_i
      jpx(indx) = jpx(indx) + c_j
      indx_arr(k) = indx
      c_i_arr(k) = c_i
      c_j_arr(k) = c_j

         ;print, indx, c_i, c_j
   end
   free_lun, lun
   return
end

;-----------------------------------------------------------------------------------

pro  mk_ncep_data, ncepetagl_fn, ncep_fn, ch_ncep_fn, land_mask, raw_ice, w_sst, ice_season

   indx_len    = 287
   ch_indx_len = 22

   lat_arr = fltarr(indx_len)
   lon_arr = fltarr(indx_len)
   ind_arr = lonarr(indx_len)

   ch_ind_arr = intarr(ch_indx_len)
   ch_i_arr   =  intarr(ch_indx_len)
   ch_j_arr   =  intarr(ch_indx_len)

   line = ' '
   openr, lun, ncep_fn, /get_lun
   readf, lun, line, line

   index = 0
   lat = 0.0
   lon = 0.0

   for k=0, indx_len-1 do begin
      readf, lun, line
           ; print, line
      reads, line, index, lat, lon
      ind_arr(k) = index
      lon_arr(k) = 360 - lon  
      lat_arr(k) = lat
    
      ; print, ind_arr(k), lat_arr(k), lon_arr(k) 
   end

   free_lun, lun
  
   cwmap,ipx ,jpx ,lat_arr,lon_arr, -1
   ch_ipx_jpx, ch_ncep_fn, ipx, jpx, ch_ind_arr,ch_i_arr,ch_j_arr
   cwmap,ipx ,jpx ,lat_arr,lon_arr, 0                                ; get new lat and lon
       
   asc_arr = fltarr(1024,1024)
   ice_arr = raw_ice             ; for non ice season

   water=where(land_mask lt 100,nwater)
   asc_arr(water) = w_sst

   if ( ice_season eq 1 ) then begin  
       ice_arr = get_ice_concentration( raw_ice )
 
      ice_index = where( (raw_ice ne 255) and (raw_ice ne 0) )  ; 0 = water,  255 = land (in lce file it is -1)
      asc_arr(ice_index) = 0.2
   endif
   
   fn = file_basename(ncepetagl_fn)      ; fn    = 'ncepetagl20140124.dat'
   y_m_d = strmid(fn, 9,8)               ; y_m_d = '20140124'
   openw, lun, ncepetagl_fn, /get_lun
   printf, lun, y_m_d, '0.2 degree C used for ice coverd pixels', format='(a8, a53)'

   for k=0, indx_len-1 do begin
      done = 0
      for n=0, ch_indx_len-1 do begin
         if ( k eq ch_ind_arr(n) ) then  begin
             ; print, ind_arr(k) , asc_arr(ipx(k), jpx(k)), ice_arr( ipx(k), jpx(k))/100., k+1, ch_j_arr(n), ch_i_arr(n), lat_arr(k),lon_arr(k), format='(i5,  f5.1, f5.2, i8, i4,i4,  f7.3, f8.3)'
             if ( ice_season eq 1 ) then begin
                printf, lun,  ind_arr(k) , asc_arr(ipx(k), jpx(k)), ice_arr(ipx(k), jpx(k))/100., k+1, ch_j_arr(n), ch_i_arr(n), lat_arr(k),lon_arr(k), format='(i5,  f5.1, f5.2, i8, i4,i4, f7.3, f8.3)'
             endif else begin
               ; printf, lun,  ind_arr(k) , asc_arr(ipx(k), jpx(k)), ice_arr, k+1, ch_j_arr(n), ch_i_arr(n), lat_arr(k),lon_arr(k), format='(i5,  f5.1, f5.2, i8, i4,i4, f7.3, f8.3)'
                printf, lun,  ind_arr(k) , asc_arr(ipx(k), jpx(k)), 0, k+1, ch_j_arr(n), ch_i_arr(n), lat_arr(k),lon_arr(k), format='(i5,  f5.1, f5.2, i8, i4,i4, f7.3, f8.3)'
            endelse

             done = 1
             break
         end           
      end ;for
    
      if ( done eq 0 ) then begin
         ; print, ind_arr(k) , asc_arr(ipx(k), jpx(k)), ice_arr( ipx(k), jpx(k))/100., k+1,  format='(i5,  f5.1,   f5.2, i8)'
         printf, lun,  ind_arr(k) , asc_arr(ipx(k), jpx(k)), ice_arr( ipx(k), jpx(k))/100., k+1,  format='(i5,  f5.1,   f5.2, i8)'
      endif

      ;aa = where( (asc_arr(ipx(k), jpx(k)) eq 0) and (ice_arr( ipx(k), jpx(k)) eq 0) )
      ;print,k, aa 

   end ; for
    
   free_lun, lun
   return
end

;-----------------------------------------------------------------------------------

; img get the color index based on the ice code

pro ice_overlay, raw_ice, img


   sicode  = ['10','20','30','40','50','60','70','80','90','91','92','93',     $
              '01','02','12','13','24','35','45','46','57','68','79','89','81',$
              '11','22','23','33','34','44','55','56','66','67','77','78','88']

                                                   ; GLSEA ice color index

   clridx  = [ 12,  14,  16,  18,  20,  22,  24,  26,  28,  29,  30,  30,      $
               11,  12,  13,  14,  16,  18,  19,  20,  22,  24,  26,  27,  28, $
               12,  14,  15,  16,  17,  18,  20,  21,  22,  23,  24,  25,  26]

;-----------------------------------------------------------------------------------
;  Color               Median Ice                  Color               Median Ice
;  index    SI Code   Concentration                index    SI Code    Concentration
;-----------------------------------------------------------------------------------
;   11          01          5                       24    68,70,77         70
;   -------------------------
;   12    02,10,11         10                       25          78         75
;                                                   26    79,80,88         80
;   13       12,15         15                       27          89         85
;                                                   -------------------------
;   14    13,20,22         20                       28       81,90         90
;   15          23         25                       29          91         95
;   16    24,30,33         30                       -------------------------
;   17          34         35                       30       92,93        100
;   -------------------------
;   18    35,40,44         40
;   19          45         45                     11-12  Off-white
;   20    46,50,55         50                     13-17  Light gray
;   21          56         55                     18-23  Medium gray
;   22    57,60,66         60                     24-29  Dark gray
;   23          67         65                     30-30  Black
;-----------------------------------------------------------------------------------
 
   if ( max(raw_ice gt 0) ne 0) then begin
      for sigrid=0,n_elements(sicode)-1 do begin
          ; print, sigrid, ' ', sicode(sigrid)
         nice=0 & ice_index=where(raw_ice eq sicode(sigrid),nice)
         if (nice gt 0) then img(ice_index)=clridx(sigrid)
      end
   end   
  
   return
end
 
;-----------------------------------------------------------------------------------

pro get_raw_ice, ice_fn, nb_fn, land_mask, raw_ice

   land = where(land_mask ge 100)

   openr, lun, ice_fn, /get_lun

   name       = ' '       
   date       = ' '
   ncols      = ' '
   nrows      = ' '
   xllcorner  = ' ' 
   yllcorner  = ' ' 
   cellsize   = ' '    
   NODATA_value = ' '  
 
   readf,lun, name, date, ncols,nrows,xllcorner,yllcorner,cellsize,NODATA_value 
   readf,lun,raw_ice
   raw_ice = rotate(temporary(raw_ice),7)

   openr, lun, nb_fn, /get_lun

   line = ' '
   readf, lun, line, line, line,line, line, line
print,'song'
   while not eof(lun) do begin
      readf, lun, line
           ; print, line
      o_col = 0
      o_row = 0
      red = 0
      n_col = 0
      n_row = 0
      blue = 0
      flag = 0
   
      reads, line, o_col, o_row, red, n_col, n_row, blue, flag 
   
           ;print, o_col, o_row, red, n_col, n_row, blue, flag 
      raw_ice(o_col, o_row) = raw_ice(n_col, n_row) 
   end
   
   free_lun, lun
   
   raw_ice(land) = -1.0    ; change ice to land (cw is land, nic is ice)

   return
end

 
;-----------------------------------------------------------------------------------

function agv_with_ice, raw_ice, land_mask,  w_sst

   l_s_index  = where( (land_mask le 7 ) and (land_mask ge 1 ) , s_num )
   l_m_index  = where( (land_mask le 14) and (land_mask ge 11) , m_num)
   l_h_index  = where( (land_mask le 26) and (land_mask ge 21) , h_num)
   l_st_index = where( (land_mask le 31) and (land_mask ge 30) , St_num)  ; 30 is Lake St. Clair
   l_e_index  = where( (land_mask le 44) and (land_mask ge 41) , e_num)
   l_o_index  = where( (land_mask le 52) and (land_mask ge 51) , o_num)

   asc_arr = fltarr(1024,1024)

   water=where(land_mask lt 100,nwater)
   asc_arr(water) = w_sst
  
   ice_index = where( (raw_ice ne 255) and (raw_ice ne 0) )  ; 0 = water,  255 = land (in lce file it is -1)
   asc_arr(ice_index) = 0.2
    
   avg_arr = fltarr(6)

   avg_arr(0) =  mean( asc_arr(l_s_index) )
   avg_arr(1) =  mean( asc_arr(l_m_index) )
   avg_arr(2) =  mean( asc_arr(l_h_index) )
   avg_arr(3) =  mean( asc_arr(l_st_index) )
   avg_arr(4) =  mean( asc_arr(l_e_index) )
   avg_arr(5) =  mean( asc_arr(l_o_index) )
      
   return, avg_arr
end

;-----------------------------------------------------------------------------------

pro  asc_fill_ice, raw_ice, asc_arr

   c_01 = where(raw_ice eq 1, c_num)
   if (c_num ne 0 ) then asc_arr( c_01 ) = 99.005 
      
  
   c_02 = where(raw_ice eq 2, c_num)
   if (c_num ne 0 ) then asc_arr( c_02 ) = 99.010
   
   c_10 = where(raw_ice eq 10, c_num)
   if (c_num ne 0 ) then asc_arr( c_10 ) = 99.010
    
   c_11 = where(raw_ice eq 11, c_num)
   if (c_num ne 0 ) then asc_arr( c_11 ) = 99.010
     
     
   c_12 = where(raw_ice eq 12, c_num)
   if (c_num ne 0 ) then asc_arr( c_12 ) = 99.015
    
   c_15 = where(raw_ice eq 15, c_num)
   if (c_num ne 0 ) then asc_arr( c_15 ) = 99.015
     
   
   c_13 = where(raw_ice eq 13, c_num)
   if (c_num ne 0 ) then asc_arr( c_13 ) = 99.020
   
   c_20 = where(raw_ice eq 20, c_num)
   if (c_num ne 0 ) then asc_arr( c_20 ) = 99.020
    
   c_22 = where(raw_ice eq 22, c_num)
   if (c_num ne 0 ) then asc_arr( c_22 ) = 99.020
   
  
   c_23 = where(raw_ice eq 23, c_num)
   if (c_num ne 0 ) then asc_arr( c_23 ) = 99.025
   
    
   c_24 = where(raw_ice eq 24, c_num)
   if (c_num ne 0 ) then asc_arr( c_24 ) = 99.030 
   
   c_30 = where(raw_ice eq 30, c_num)
   if (c_num ne 0 ) then asc_arr( c_30 ) = 99.030
    
   c_33 = where(raw_ice eq 33, c_num)
   if (c_num ne 0 ) then asc_arr( c_33 ) = 99.030
   
   
   c_34 = where(raw_ice eq 34, c_num)
   if (c_num ne 0 ) then asc_arr( c_34 ) = 99.035
  
    
   c_35 = where(raw_ice eq 35, c_num)
   if (c_num ne 0 ) then asc_arr( c_35 ) = 99.040
   
   c_40 = where(raw_ice eq 40, c_num)
   if (c_num ne 0 ) then asc_arr( c_40 ) = 99.040
    
   c_44= where(raw_ice eq 44, c_num)
   if (c_num ne 0 ) then asc_arr( c_44 ) = 99.040
   
 
   c_45= where(raw_ice eq 45, c_num)
   if (c_num ne 0 ) then asc_arr( c_45 ) = 99.045
   
  
   c_46 = where(raw_ice eq 46, c_num)
   if (c_num ne 0 ) then asc_arr( c_46 ) = 99.050
   
   c_50 = where(raw_ice eq 50, c_num)
   if (c_num ne 0 ) then asc_arr( c_50 ) = 99.050
    
   c_55= where(raw_ice eq 55, c_num)
   if (c_num ne 0 ) then asc_arr( c_55 ) = 99.050
   
   
   c_56= where(raw_ice eq 56, c_num)
   if (c_num ne 0 ) then asc_arr( c_56 ) = 99.055
      
   
   c_57 = where(raw_ice eq 57, c_num)
   if (c_num ne 0 ) then asc_arr( c_57 ) = 99.060
   
   c_60 = where(raw_ice eq 60, c_num)
   if (c_num ne 0 ) then asc_arr( c_60 ) = 99.060
    
   c_66= where(raw_ice eq 66, c_num)
   if (c_num ne 0 ) then asc_arr( c_66 ) = 99.060

  
   c_67= where(raw_ice eq 67, c_num)
   if (c_num ne 0 ) then asc_arr( c_67 ) = 99.065
  
 
   c_68 = where(raw_ice eq 68, c_num)
   if (c_num ne 0 ) then asc_arr( c_68 ) = 99.070
   
   c_70 = where(raw_ice eq 70, c_num)
   if (c_num ne 0 ) then asc_arr( c_70 ) = 99.070
    
   c_77= where(raw_ice eq 77, c_num)
   if (c_num ne 0 ) then asc_arr( c_77 ) = 99.070

 
   c_78= where(raw_ice eq 78, c_num)
   if (c_num ne 0 ) then asc_arr( c_78 ) = 99.075
 
 
   c_79 = where(raw_ice eq 79, c_num)
   if (c_num ne 0 ) then asc_arr( c_79 ) = 99.080
   
   c_80 = where(raw_ice eq 80, c_num)
   if (c_num ne 0 ) then asc_arr( c_80 ) = 99.080
    
   c_88= where(raw_ice eq 88, c_num)
   if (c_num ne 0 ) then asc_arr( c_88 ) = 99.080

 
   c_89= where(raw_ice eq 89, c_num)
   if (c_num ne 0 ) then asc_arr( c_89 ) = 99.085
 
  
   c_81 = where(raw_ice eq 81, c_num)
   if (c_num ne 0 ) then asc_arr( c_81 ) = 99.090
   
   c_90 = where(raw_ice eq 90, c_num)
   if (c_num ne 0 ) then asc_arr( c_90 ) = 99.090
        
    
   c_91= where(raw_ice eq 91, c_num)
   if (c_num ne 0 ) then asc_arr( c_91 ) = 99.095


   c_92= where(raw_ice eq 92, c_num)
   if (c_num ne 0 ) then asc_arr( c_92 ) = 99.100
  
   c_93= where(raw_ice eq 93, c_num)
   if (c_num ne 0 ) then asc_arr( c_93 ) = 99.100
   
   return
end

;---------------------------------------------------------------------------

pro mk_glsea_asc, asc_fn, asc_arr
      
   openw, lun, asc_fn, /get_lun

   printf, lun, 'ncols         1024'
   printf, lun, 'nrows         1024'

;   printf, lun, 'xllcorner     -10288021.955346'
;   printf, lun, 'yllcorner     4675974.1582466'

   printf, lun, 'xllcorner     -10288921.955'    ; corrected x, y
   printf, lun, 'yllcorner     4676874.158'
   printf, lun, 'cellsize      1800'
   printf, lun, 'NODATA_value  -9999.0'

   for i=1024-1, 0, -1 do begin
          printf, lun, asc_arr(*,i),  format='(1024f8.3)'
   endfor
      ;printf, lun, asc_arr
   free_lun, lun
   return
end

;-----------------------------------------------------------------------------------

function get_gl_ice_cover, land_mask, raw_ice 
 
   water = where( land_mask ne 255, water_pix_num )
   gl_ice_pix_value = raw_ice(water)
   gl_sum = total(gl_ice_pix_value)   ; total ice contration over water
 
   return, gl_sum / water_pix_num

end

;-----------------------------------------------------------------------------------

; s_w_flag:    0 -- summer, 1 -- winter

pro mk_glsea_png, png_fn, ice_fn, bk_fn, c_pal_fn, land_mask, raw_ice, farr, nk1, s_w_flag 
    
   openr,lun, c_pal_fn,/get_lun

   a=' '
   b=bytarr(3,256)
   readf, lun,a,format='(a)' 
   readf, lun,b,format='(3z2.2)'
   free_lun, lun

   red=bytarr(256)                   ; Color map
   grn=bytarr(256)
   blu=bytarr(256)
   red(*)=b(0,*)
   grn(*)=b(1,*)
   blu(*)=b(2,*)
 
   tvlct,b(0,*),b(1,*),b(2,*)

   tvlct,215,239,255,254             ; Color 254 to light blue

   tvlct,  0, 71,153,1               ; for NOAA logo
   tvlct,  0,189,236,2
   tvlct,255,255,255,3
;print, red, grn, blu 
   water = where( land_mask ne 255, num )

   bk_img = bytarr(1024,1024)
   openr, lun, bk_fn, /get_lun
   readu, lun, bk_img
   free_lun,lun
 
   ; in composit.pal, each color take 5 line, 30 * 5 = 150
   ; index under 50 is reserved
 
   bk_img(water) = round( farr / 30. * 150 ) + 50     
 
   if ( s_w_flag eq 1 ) then begin             ; winter ice overlay

      tvlct, 220,220,220,11			; color for ice  scale

      for i=12, 17 do begin
         tvlct, 190,190,190, i
      end

      for i=18, 23 do begin			
         tvlct, 160,160,160, i
      end
 
      for i=24, 27 do begin
         tvlct, 110,110,110, i
      end

      for i=28, 29 do begin
         tvlct, 70,70,70, i
      end

      tvlct, 0,0,0,30
      
      ice_overlay, raw_ice, bk_img


   endif

;bk_img(*, 825) = 150
 ;bk_img(215, *) = 150
;bk_img(110, 683) = 150
;bk_img(215, 825) = 150
    tv, bk_img

   !p.color=0
   !p.font=1   ; true font
   !p.charthick=0.5   ; font will be darker
   !p.charsize=2.5

   fn = file_basename(png_fn)    ; fn = 2014_029_glsea.dat
   str_yr = strmid(fn, 0, 4)
   str_jd = strmid(fn, 5, 3)

   start_jd = julday(1,0, str_yr)
   n_jd = start_jd + str_jd
   caldat, n_jd, mo, dy

   str_mo = string(mo, format='(i2.2)')
   str_dy = string(dy, format='(i2.2)')
   ;xyouts,494,840,'Analysis Date:  JD 230  08/18/2006',/device, size=2.4
 
   xyouts,494,840,'Analysis Date:  JD '+str_jd+' '+str_mo+'/'+str_dy+'/'+str_yr,/device 
 
   if ( s_w_flag eq 1 ) then begin             ; winter ice overlay

      if ( strlen(ice_fn) ne 0 ) then begin
         ifn = file_basename(ice_fn)              
         i_yr = strmid(ifn, 1, 4)
         i_jd = strmid(ifn, 5,3)
      
         i_start_jd = julday(1,0,i_yr)

         caldat, i_start_jd+i_jd, month, day, year
         ;print, month, day, year
 
         year  = strtrim(year,1)
         month = strtrim(month,1)
         day   = strtrim(day,1)
 
         xyouts, 512, 776, 'Date of last ice analysis: ' +month+'/'+day+'/'+year,/device 

         ice_arr = get_ice_concentration( raw_ice )

         ice_total = get_gl_ice_cover(land_mask, ice_arr )
         str_total = string(ice_total, format='(f5.1)')
 
         xyouts, 550, 700, 'Great Lakes Total Ice Cover: ' + str_total + '%', /device 

      endif else begin
         xyouts, 512, 776, 'Date of last ice analysis: ' + '00/00/0000',/device 
      endelse
      
   endif
 
   p_pix = nk1 / 148682. * 100.

   str_p_pix = string(p_pix, format='(f5.1)')
   ;xyouts,424,810,'Percent Pixels with Data within +/-10 Days: 99.9%',/device, size=2.4
  
   xyouts,414,810,'Percent Pixels with Data within +/-10 Days: '+str_p_pix +'%',/device 
 
   img800=tvrd(0, 109, 1024,800)
   tvlct, rr, gg, bb, /get
   ;print, 'Make ' + png_fn + ' ...'
   write_png, png_fn, img800, rr, gg, bb
   
   return
end

;-----------------------------------------------------------------------------------

pro mk_glsea_i_dat, i_dat_fn, asc_arr, water 

   ;print, 'Make ' + i_dat_fn + ' ...'
  
   openw, lun, i_dat_fn, /get_lun
 
   farr = asc_arr(water)   
 
   printf, lun, farr, format='(f7.3)' 
  
   free_lun, lun
   return
end

;-----------------------------------------------------------------------------------
 
 
work_dir = '/home/cw/opr/glsea2/idl/test/'
ice_fn = '/home/cw/test/ice/2018/10/g201830300.lce'
dat_fn = '/mnt/cwdata/p/m/lcb/2018/11/2018_305_glsea.dat'

   back_dir =   '/home/cw/opr/glsea2/bkg/'

    w_bk_fn  = back_dir + 'glsea_bkg.1024.winter'
   c_pal_fn = back_dir + 'composit.pal'

    
   mask_dir = '/home/cw/masks/1024/'
   mask_fn  = mask_dir + 'cwglsyrd.byt'

   print,format='(1x,a)','Reading over-water mask file . . .'
   lmask  = bytarr(1024,1024)
   openr,lunm,mask_fn,/get_lun
   readu,lunm,lmask
 
   close,lunm
   free_lun,lunm


   nb_fn    = mask_dir + 'ice_land_mask_neighbor_final_2.txt'

   openr,lun,dat_fn,/get_lun
   readf,lun, a, format='(f5.2)'      
   close,lun

  
              
            ;ice_fn = get_ice_fn( ice_dir, yra, jda)

            raw_ice = bytarr(1024,1024)
                                
        ;    if ( strlen(ice_fn) ne 0 ) then begin
               get_raw_ice, ice_fn, nb_fn, lmask, raw_ice     ; raw_ice will have same shoreline as lmask
            ;   asc_fill_ice, raw_ice, asc_arr               
 
          ;  end  
            
     set_plot,'z'
   device,set_colors=256,set_res=[1024,1024]
     
            mk_glsea_png, '2018_303_glsea.png', ice_fn, w_bk_fn, c_pal_fn, lmask, raw_ice, a, 100, 1

    

end
