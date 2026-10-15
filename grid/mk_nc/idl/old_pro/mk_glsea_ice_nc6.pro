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

;slat = 38.7221
;wlon = -92.511
;elon = -75.9515

f1 = 0.99664  ; N-S scale adjustment for WGS-84

; Constants

alon0 = -wlon
a1    = 1023. / (!dtor * ( elon-wlon ) )
y0    = a1 * alog(tan (!dtor * (45.0 + slat / 2.) ))

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

;------------------------------------------------------------------

pro get_temp, fn, sst_arr

   sst_arr = fltarr(1024,1024)
   openr, lun, fn, /get_lun

   ncols         = ''
   nrows         = ''
   xllcorner     = ''
   yllcorner     = ''
   cellsize      = ''
   NODATA_value  = ''

   readf,lun,ncols,nrows,xllcorner,yllcorner,cellsize,NODATA_value
   readf,lun, sst_arr

   sst_arr( where(sst_arr eq 255.0) ) = -99999

   sst_arr( where(sst_arr gt 99) ) = 0.2
   close, lun
 
   return
end

;------------------------------------------------------------------

pro get_ice, fn, ice_arr

   ice_arr = fltarr(1024,1024)
   openr, lun, fn, /get_lun

   ncols         = ''
   nrows         = ''
   xllcorner     = ''
   yllcorner     = ''
   cellsize      = ''
   NODATA_value  = ''

   readf,lun,ncols,nrows,xllcorner,yllcorner,cellsize,NODATA_value
   readf,lun, ice_arr

   water_index = where(ice_arr lt 99)

   ice_arr( where(ice_arr eq 255.0) ) = -99999
   ice_index = where(ice_arr gt 99 )
   
;help, ice_arr
   ice_arr(ice_index) = (ice_arr( ice_index ) - 99) * 1000   ; 0.09 become 90%
   ice_arr(water_index) = 0
;help, ice_arr
   close, lun
 
   return
end

;------------------------------------------------------------------
 
close,/all

fn = '/mnt/cwdata/p/m/lcb/2008/01/2008_031_glsea.asc'
print, fn

pos = strpos(fn,'/',/reverse_search)
yr = fix(strmid(fn,pos+1,4))
doy = fix(strmid(fn,pos+6,3))
print,yr,doy

dim = 1024

;fmiss=-99999
;im=dim
;jm=dim
;for i=0,dim-1 do begin
; for j=0,dim-1 do begin
;  cwmap,i,j,alat,alon,1
;  lat(i,j)=alat
;  lon(i,j)=-alon
; end
;end

lat = fltarr(dim)
lon = fltarr(dim)

fmiss = -99999
im = dim
jm = dim
for i=0,dim-1 do begin
 for j=0,dim-1 do begin
  cwmap,i,j,alat,alon,1   ; convert i, j to lat, lon
  lat(j) = alat
  lon(i) = -alon
 end
end
 
nc_fn = strmid(fn,pos+1,15) + 'nc'

print, nc_fn

nc = ncdf_create(nc_fn,/clobber)
ncdf_control, nc, /fill

nc_ny_d   = ncdf_dimdef(nc,'lat',jm)
nc_nx_d  = ncdf_dimdef(nc,'lon',im)
;nc_time_d = ncdf_dimdef(nc,'time',/unl)
nc_time_d = ncdf_dimdef(nc,'time', 1 )

nc_crs_v = ncdf_vardef(nc, 'crs',/char)
 
ncdf_attput, nc, nc_crs_v, 'grid_mapping_name', 'latitude_longitude', /string
ncdf_attput, nc, nc_crs_v, 'long_name', 'CRS definition', /string
ncdf_attput, nc, nc_crs_v, 'longitude_of_prime_meridian', 0.d
ncdf_attput, nc, nc_crs_v, 'semi_major_axis', 6378137.d
ncdf_attput, nc, nc_crs_v, 'inverse_flattening', 298.257223563d

;ncdf_attput, nc, nc_crs_v, 'crs', 'GEOGCS["unknown",DATUM["unknown",SPHEROID["Spheroid",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]]]', /string

nc_lat_v = ncdf_vardef(nc,'lat',[nc_ny_d],/double)

ncdf_attput,nc,nc_lat_v,'long_name','Latitude',/string
ncdf_attput,nc,nc_lat_v,'units','degrees_north',/string
ncdf_attput,nc,nc_lat_v,'axis','Y',/string
ncdf_attput,nc,nc_lat_v,'standard_name','latitude',/string
ncdf_attput,nc,nc_lat_v,'bounds', "38.8744, 50.6027",/string

nc_lon_v = ncdf_vardef(nc,'lon',[nc_nx_d],/double)

ncdf_attput,nc,nc_lon_v,'long_name','Longitude',/string
ncdf_attput,nc,nc_lon_v,'units','degrees_east',/string
ncdf_attput,nc,nc_lon_v,'axis','X',/string
ncdf_attput,nc,nc_lon_v,'standard_name','longitude',/string
ncdf_attput,nc,nc_lon_v,'bounds', "-92.4106, -75.8690",/string


nc_time_v = ncdf_vardef(nc,'time',nc_time_d,/double)

ncdf_attput,nc,nc_time_v,'long_name','Easten Time',/char
ncdf_attput,nc,nc_time_v,'axis','T',/char
ncdf_attput,nc,nc_time_v,'units','seconds since 1970-01-01 00:00:00 +00:00',/char
ncdf_attput,nc,nc_time_v,'base_date','1970,1,1,0',/char
ncdf_attput,nc,nc_time_v,'standard_name','time',/char


nc_temp_v = ncdf_vardef(nc,'Temperature', [nc_nx_d,nc_ny_d,nc_time_d], /float)

ncdf_attput,nc,nc_temp_v,'long_name','Temperature',/char
ncdf_attput,nc,nc_temp_v,'units','Celsius',/char
ncdf_attput,nc,nc_temp_v,'standard_name','sea_water_temperature',/char
ncdf_attput,nc,nc_temp_v,'missing_value',fmiss,/float
ncdf_attput,nc,nc_temp_v,'coordinates','lat lon',/char
ncdf_attput,nc,nc_temp_v,'grid_mapping','crs',/char
ncdf_attput,nc,nc_temp_v,'cell_methods','area: mean',/char


nc_ice_v  = ncdf_vardef(nc,'Ice_Concentration',[nc_nx_d,nc_ny_d, nc_time_d],/float)

ncdf_attput,nc,nc_ice_v,'long_name','Ice Consentration',/char
ncdf_attput,nc,nc_ice_v,'units','%',/char
ncdf_attput,nc,nc_ice_v,'standard_name','Ice_Consentration',/char
ncdf_attput,nc,nc_ice_v,'missing_value',fmiss,/float
ncdf_attput,nc,nc_ice_v,'coordinates','lat lon',/char
ncdf_attput,nc,nc_ice_v,'grid_mapping','crs',/char
ncdf_attput,nc,nc_ice_v,'cell_methods','area: mean',/char

;;ncdf_attput,nc,nc_ice,'coordinates','lon lat',/char
;ncdf_attput,nc,nc_ice,'comment','negative values indicate ice fraction (0-1)',/char

ncdf_attput,nc,/Global,'institution','NOAA/GLERL/COASTWATCH'
ncdf_attput,nc,/Global,'comment','Great Lakes GLSEA & NIC Ice'
ncdf_attput,nc,/Global,'author','songzhi.liu@noaa.gov'
ncdf_attput,nc,/Global,'references','https://coastwatch.glerl.noaa.gov/'
ncdf_attput,nc,/Global,'creation_date',systime()+' GMT'
ncdf_attput,nc,/Global,'disclaimer','https://coastwatch.glerl.noaa.gov/notice.html'
ncdf_attput,nc,/Global,'Conventions', "CF-1.4" ;

ncdf_control,nc,/endef
;;;;print,'endef'


ncdf_varput, nc, nc_crs_v, " "

ncdf_varput, nc, nc_lat_v, lat
ncdf_varput, nc, nc_lon_v, lon

t = 3600*24L*(doy-1+julday(1,1,yr)-julday(1,1,1970))

ncdf_varput, nc, nc_time_v, t 
 
get_temp, fn, sst_arr
get_ice, fn, ice_arr

 ;sst_arr2 = rotate(sst_arr, 1)
 ;ice_arr2 = rotate(ice_arr, 1)

; sst_arr2 = rotate(sst_arr, 7)
; ice_arr2 = rotate(ice_arr, 7)

 sst_arr2 = rotate(sst_arr, 7)
 ice_arr2 = rotate(ice_arr, 7)

 ncdf_varput,nc,nc_temp_v, sst_arr2
 ncdf_varput,nc,nc_ice_v, ice_arr2

ncdf_close,nc
 
end
