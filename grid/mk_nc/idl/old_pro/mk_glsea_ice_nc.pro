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
help, ice_arr
   ice_index = where(ice_arr gt 99 )
   
help, ice_arr
   ice_arr(ice_index) = (ice_arr( ice_index ) - 99) * 1000   ; 0.09 become 90%
   ice_arr(water_index) = 0
help, ice_arr
   close, lun
 
   return
end

;------------------------------------------------------------------


close,/all

fn = '/mnt/cwdata/p/m/lcb/2008/01/2008_031_glsea.asc'
print, fn
 pos=strpos(fn,'/',/reverse_search)
 yr=fix(strmid(fn,pos+1,4))
 doy=fix(strmid(fn,pos+6,3))
 print,yr,doy

openr,1,'cwglsyrd_1024.asc'

dim=1024
mask=bytarr(dim,dim)
readf,1,mask
close,1
mask=rotate(mask,7)
water=where(mask lt 255,nw)
print,nw

lat=fltarr(dim,dim)
lon=fltarr(dim,dim)

fmiss=-99999
im=dim
jm=dim
for i=0,dim-1 do begin
 for j=0,dim-1 do begin
  cwmap,i,j,alat,alon,1
  lat(i,j)=alat
  lon(i,j)=-alon
 end
end



nc_fn = strmid(fn,pos+1,15) + 'nc'



nc = ncdf_create(nc_fn,/clobber)
ncdf_control,nc,/fill
;NCDF_CONTROL, 0, /VERBOSE

nc_nx   = ncdf_dimdef(nc,'nx',im)
;nc_nx   = ncdf_dimdef(nc,'nx',1)

help, nc_nx

nc_ny   = ncdf_dimdef(nc,'ny',jm)
;nc_ny   = ncdf_dimdef(nc,'ny',1)
help, nc_ny

;nc_time = ncdf_dimdef(nc,'time',/unl)
nc_time = ncdf_dimdef(nc,'time', 1 )
help, nc_time

nc_crs = ncdf_vardef(nc, 'crs',/char)

;;;nc_lat = ncdf_vardef(nc,'lat',[nc_ny,nc_nx],/float)
;;;nc_lon = ncdf_vardef(nc,'lon',[nc_ny,nc_nx],/float)

nc_lat = ncdf_vardef(nc,'lat',[nc_ny],/double)
nc_lon = ncdf_vardef(nc,'lon',[nc_nx],/double)


nc_timev = ncdf_vardef(nc,'time',nc_time,/double)

;nc_yy=ncdf_vardef(nc,'year',nc_time,/long)
;nc_doy=ncdf_vardef(nc,'day_of_year',nc_time,/long)
;;;;;nc_temp=ncdf_vardef(nc,'temp',[nc_ny,nc_nx,nc_time],/float)

nc_temp = ncdf_vardef(nc,'temp',[nc_ny,nc_nx, nc_time],/float)
nc_ice  = ncdf_vardef(nc,'Ice',[nc_ny,nc_nx, nc_time],/float)

ncdf_attput, nc, nc_crs, 'grid_mapping_name', 'latitude_longitude', /char
ncdf_attput, nc, nc_crs, 'long_name', 'CRS definition', /string
ncdf_attput, nc, nc_crs, 'longitude_of_prime_meridian', 0., /double
ncdf_attput, nc, nc_crs, 'semi_major_axis', 6378137., /double
ncdf_attput, nc, nc_crs, 'inverse_flattening', 298.257223563, /double
ncdf_attput, nc, nc_crs, 'spatial_ref', 'GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433],AUTHORITY["EPSG","4326"]]', /string
ncdf_attput, nc, nc_crs, 'GeoTransform', '-92.24440271356065 0.0101129981888595 0 49.06733602638672 0 -0.01011460266263213', /string

ncdf_attput,nc,nc_lat,'long_name','Latitude',/char
ncdf_attput,nc,nc_lat,'units','degrees_north',/char
ncdf_attput,nc,nc_lat,'standard_name','latitude',/char

ncdf_attput,nc,nc_lon,'long_name','Longitude',/char
ncdf_attput,nc,nc_lon,'units','degrees_east',/char
ncdf_attput,nc,nc_lon,'standard_name','longitude',/char

ncdf_attput,nc,nc_temp,'long_name','Temperature',/char
ncdf_attput,nc,nc_temp,'units','Celsius',/char
ncdf_attput,nc,nc_temp,'standard_name','sea_water_temperature',/char
ncdf_attput,nc,nc_temp,'missing_value',fmiss,/float
ncdf_attput,nc,nc_temp,'grid_mapping','crs',/char

;ncdf_attput,nc,nc_temp,'coordinates','lon lat',/char
;ncdf_attput,nc,nc_temp,'comment','negative values indicate ice fraction (0-1)',/char

;;;ncdf_attput,nc,nc_ice,'long_name','Ice Consentration',/string
;;;ncdf_attput,nc,nc_ice,'units','%',/char
;;;ncdf_attput,nc,nc_ice,'standard_name','Ice_Consentration',/char
;;;ncdf_attput,nc,nc_ice,'missing_value',fmiss,/float
;;;ncdf_attput,nc,nc_ice,'grid_mapping','crs',/char

;ncdf_attput,nc,nc_ice,'coordinates','lon lat',/char
;ncdf_attput,nc,nc_ice,'comment','negative values indicate ice fraction (0-1)',/char

ncdf_attput,nc,nc_time,'long_name','Easten Time',/string
;;ncdf_attput,nc,nc_time,'axis','T',/string
ncdf_attput,nc,nc_time,'units','seconds since 1970-01-01 00:00:00 +00:00',/string
;;;ncdf_attput,nc,nc_time,'base_date','1970,1,1,0',/char
ncdf_attput,nc,nc_time,'standard_name','time',/char

ncdf_attput,nc,/Global,'institution','NOAA/GLERL/COASTWATCH'
ncdf_attput,nc,/Global,'comment','Great Lakes GLSEA & NIC Ice'
ncdf_attput,nc,/Global,'author','songzhi.liu@noaa.gov'
ncdf_attput,nc,/Global,'references','https://coastwatch.glerl.noaa.gov/'
ncdf_attput,nc,/Global,'creation_date',systime()+' GMT'
ncdf_attput,nc,/Global,'disclaimer','https://www.glerl.noaa.gov/home/notice.html'

ncdf_control,nc,/endef
;;;;print,'endef'

;;;;ncdf_varput,nc,nc_lat,lat
;;;ncdf_varput,nc,nc_lon,lon

t=3600*24L*(doy-1+julday(1,1,yr)-julday(1,1,1970))
ncdf_varput,nc,nc_timev,t 


ncdf_varput, nc, nc_crs, '' 

lat_arr = fltarr(im)
lat_arr(*) = lat(0,*)

lon_arr = fltarr(im)
lon_arr(*) = lon(*,0)

ncdf_varput,nc,nc_lat,lat_arr
ncdf_varput,nc,nc_lon,lon_arr



 
;;; ncdf_varput,nc,nc_yy,yr 
;;; ncdf_varput,nc,nc_doy,doy 




 get_temp, fn, sst_arr
get_ice, fn, ice_arr

 sst_arr2 = rotate(sst_arr, 7)
 ice_arr2 = rotate(ice_arr, 7)

 ncdf_varput,nc,nc_temp, sst_arr2
 ncdf_varput,nc,nc_ice, ice_arr2

;;;end
ncdf_close,nc

; these work outside of idl.
; print,'converting classic nc to netCDF-4 classic model...'
; spawn,'/opt/local/bin/ncks -O --fl_fmt=netcdf4_classic 2007_glsea_ice.nc 2007_glsea_ice.nc4'
; spawn,'/opt/local/bin/ncks -O --deflate=2 2007_glsea_ice.nc4 2007_glsea_ice.nc'
; spawn,'rm 2007_glsea_ice.nc4'
; spawn,'ls -la 2007_glsea_ice.nc'

;;;end

end
