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
a1    = 1023. / (!dtor * ( elon-wlon ) )
y0    = a1 * alog(tan (!dtor * (45.0 + slat / 2.) ))

; Calculate latitude and longitude if conv = -1, else calculate ipx and jpx

if(conv eq -1) then begin
 ipx=fix(a1*!dtor*(alon0-lon)+0.5)
 jpx=fix(f1*(a1*alog(tan(!dtor*(45.+lat/2.)))-y0)+0.5)
;print, a1*!dtor*(alon0-lon)+0.5
; print, ipx, jpx
end else begin
 lat = 2.0 * ((( atan ( exp ( (jpx/f1 + y0) / a1) )) / !dtor) - 45.0)
 lon = -1.0*((ipx / (a1 * !dtor)) - alon0)
; print, lat, lon
end

return
end

;----------------------------------------------------------------------


pro ch_shoreline, nb_fn, land_mask


openr, lun, nb_fn, /get_lun

line = ' '
readf, lun, line, line, line,line, line, line

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
   land_mask(o_col, o_row) = land_mask(n_col, n_row) 

end
  
   return
end


;-----------------------------------------------------------------------------------


work_dir = '/cwops/home/cw/opr/glsea2/'
mask_dir = '/cwops/home/cw/masks/1024/'
idl_dir  = work_dir + 'idl/'
necp_dir = work_dir + 'ncep/'

mask_fn    = mask_dir + 'cwglsyrd.byt'
nb_fn      = mask_dir + 'ice_land_mask_neighbor_final.txt'
lat_lon_fn    = necp_dir + 'ncep_latlon.dat'
ch_lat_lon_fn = necp_dir + 'ch_ncep_latlon.dat'

indx_len = 287

lat_arr = fltarr(indx_len)
lon_arr = fltarr(indx_len)
ind_arr = lonarr(indx_len)

line = ' '
openr, lun, lat_lon_fn, /get_lun
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

land_mask = bytarr(1024,1024)
openr, lun, mask_fn, /get_lun
readu, lun, land_mask
free_lun,lun

ch_shoreline, nb_fn, land_mask

water = where( land_mask ne 255, num )
;land_mask = 0   ; release mem

 
index_arr = lonarr(indx_len)
 
for k=0, indx_len-1 do begin
   index_arr(k) = ipx(k) + 1024L * jpx(k)
end

openw, lun, 'index-lat-lon.txt', /get_lun
printf, lun, '           ncep-inx  row     col   lat     lon   cw-index lake/land'
    
printf, lun,  ' ' 
for k=0, indx_len-1 do begin
       
   print, k, ind_arr(k), jpx(k), ipx(k), lat_arr(k), lon_arr(k), index_arr(k), land_mask(index_arr(k))
   printf, lun, k, ind_arr(k), jpx(k), ipx(k), lat_arr(k), lon_arr(k), index_arr(k), land_mask(index_arr(k)), $
     format='(4i8, f8.2, f8.2, i8, i4)'

end
free_lun, lun


a =  land_mask(index_arr)
b = where(a eq 255)
openw, lun, 'pix.dat', /get_lun
print, 'i', 'j', b, format='(2a2,22i4.3)'
printf, lun, 0, 0, b, format='(2i2,22i4.3)'

for i=-5, 5 do begin
  for j=-5, 5 do begin
     print, i, j, land_mask(ipx(b)+i, jpx(b)+j), format='(2i2,22i4.3)'
     printf, lun, i, j, land_mask(ipx(b)+i, jpx(b)+j), format='(2i2,22i4.3)'
  end
end
free_lun, lun

indx = 0
c_i = 0
c_j = 0
line = ' '
openr, lun, ch_lat_lon_fn, /get_lun
 readf, lun, line
for k=0, 21 do begin
   readf, lun, line
  ; print, line
   reads, line, indx, c_i, c_j
   ipx(indx) = ipx(indx) + c_i
   jpx(indx) = jpx(indx) + c_j
end
  ; ind_arr(k) = indx
  ; lon_arr(k) = 360 - lon  
  ; lat_arr(k) = lat



end


