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


function get_lat_lon, station_fn, station_id

   openr, lun, station_fn, /get_lun

   line = ''
   while not eof(lun) do begin
      readf, lun, line
      ;print, line
      s_id = strtrim(strmid(line,1,8))
      station_type = strmid(line, 0,1)
      station_name = strmid(line, 16,20)
      lat_str = strmid(line, 36,4)
      lon_str = strmid(line, 40,4)
      if (station_id eq s_id ) then begin
        ; print, line
        ; print, station_id, ', ', station_name, ', ', lat_str, ', ', lon_str
         lat = fix(lat_str, type=5) / 100.
         lon = fix(lon_str, type=5) / 100.

      endif

   endwhile

   free_lun, lun

   return, {lat:lat, lon:lon}
end

;-------------------

function get_buoy_sst_r_c, station_fn, buoy_list, mask_fn, lmd_fn, glsea3_fn, glsea3b_fn

   hr_arr = ['1140', '1150', '1200', '1210','1220']

   openr, lun, mask_fn, /get_lun                                 ;  reads land - water mask
   b_map = bytarr(1024,1024)
   readu, lun, b_map
   free_lun, lun

   water = where(b_map lt 100, nwater)
   b_map(water) = 0            ; water is 0

   land = where(b_map ne 0)

   b_map(land) = 255   ; land is 255

   b_sst_arr = fltarr(n_elements(buoy_list))
   b_row_arr = fltarr(n_elements(buoy_list))
   b_col_arr = fltarr(n_elements(buoy_list))

   b_sst_arr(*) = -1

   a3 = fltarr(nwater)
   openr, lun, glsea3_fn, /get_lun
   readf, lun, a3, format='(f5.2)'
   free_lun, lun

   img3=fltarr(1024,1024)-1
   img3(water) = a3

   a3b = fltarr(nwater)
   openr, lun, glsea3b_fn, /get_lun
   readf, lun, a3b, format='(f5.2)'
   free_lun, lun

   img3b=fltarr(1024,1024)-1
   img3b(water) = a3b

   openr, lun, lmd_fn, /get_lun
   line = ''

   sst_arr = fltarr(1024,1024)

   while not eof(lun) do begin
      readf, lun, line
      hr_str = strmid(line, 7,4)
      station_id = strtrim(strmid(line,12,8))
      sst_str = strmid(line, 67, 4)
      sst = fix(sst_str, type=5)
      lat = strtrim(strmid(line, 82, 5))
      lon = strtrim(strmid(line, 88, 5))

          for n=0, n_elements(hr_arr)-1 do begin
       if (sst lt 99 and hr_arr(n) eq hr_str  ) then begin
         if ( lat eq '' ) then begin
            point = get_lat_lon(station_fn, station_id)
            lat = point.lat
            lon = point.lon
         endif
         cwmap,ipx,jpx,lat,lon,-1
         if (ipx ge 0 and ipx lt 1024) and (jpx ge 0 and jpx lt 1024) then begin
            b_map(ipx, jpx) = 200
            sst_arr(ipx, jpx) = sst            ; i is col, j is row
         endif

                 for i=0, n_elements(buoy_list)-1 do begin
                        if ( station_id eq buoy_list(i) ) then begin
                                print, station_id, ', ', sst, ', ', img3(ipx,jpx), ',', img3b(ipx,jpx), ',', lat, ', ', lon, ', ', ipx, ', ', jpx
                                b_col_arr(i) = ipx
                                b_row_arr(i) = jpx
                                b_sst_arr(i) = sst

                        endif
                 endfor
       endif
           break
          endfor
   endwhile

   free_lun, lun

   ;water_sst_arr = sst_arr(water)

  return, {b_loc_sst:b_sst_arr, b_loc_col:b_col_arr,b_loc_row:b_row_arr}
end

;--------------------------------------------------------------------------

   mask_dir = '/home/cw/masks/1024/'
   mask_fn  = mask_dir + 'cwglsyrd.byt'
   buoy_data_dir = '/mnt/cwdata/p/s/lmd/'
   station_fn = buoy_data_dir + 'stations.lmd'

glsea3_dat_dir = '/mnt/cwdata/p/m/lcc/'
glsea3b_dat_dir = '/mnt/cwdata/p/m/lcd/'

   buoy_list = ['45001','45002','45003','45004','45005','45006', '45007','45008', '45028','45136','45014','45013','46187','46186','46174','46170','45170','45026','46168','45029','46024','45183','45143','45154','45147','45132','45167','45142','45139','45159','45012','45135']

str_yr = '2021'
mn_list = ['06', '07', '08', '09', '10', '11']

;for j=160, 334 do begin
for j=335, 365 do begin
 
  o_jd = julday(1,0,str_yr)
  caldat, o_jd+j, m1, d1, yr1

  str_mn = string(m1,format='(i2.2)')
  str_jd = string(j, format='(i3.3)')
  ;print, str_mn, ' ', str_jd
  lmd_fn = buoy_data_dir + str_yr + '/' + str_mn + '/g' + str_yr + str_jd + '00.lmd'
  print, lmd_fn

  glsea3_fn = glsea3_dat_dir + str_yr + '/' + str_mn + '/' +str_yr + '_' + str_jd + '_glsea.dat'
  glsea3b_fn = glsea3b_dat_dir + str_yr + '/' + str_mn + '/' + str_yr + '_' +str_jd + '_glsea.dat'  

  b_data = get_buoy_sst_r_c(station_fn, buoy_list, mask_fn, lmd_fn , glsea3_fn, glsea3b_fn)
  

end

  
end

