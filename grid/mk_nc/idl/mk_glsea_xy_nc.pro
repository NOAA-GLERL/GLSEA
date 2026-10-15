 
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

   sst_arr( where(sst_arr eq 255.0) ) = -99999    ; land

   sst_arr( where(sst_arr gt 99) ) = 0.2          ; ice
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
;help, ice_arr
   ice_index = where(ice_arr gt 99 )
   
;help, ice_arr
   ice_arr(ice_index) = (ice_arr( ice_index ) - 99) * 1000   ; 0.09 become 90%
   ice_arr(water_index) = 0
;help, ice_arr
   close, lun
 
   return
end

;------------------------------------------------------------------

function get_x_y, fn
;print, fn
   openr, lun, fn, /get_lun

   line = ''
   readf, lun, line
   ;print, line

   d_arr = dblarr(2,1024)
   x = 0d
   y = 0d

   i = 0
   while ~ eof( lun ) do begin

      readf, lun, x, y
;print, x, y, format='(f13.3, f12.3)'
      d_arr(0,i) = x
      d_arr(1,i) = y
      ;print, d_arr(i), i
      i = i + 1
   end
   
   return, d_arr
end

;------------------------------------------------------------------


;close,/all

pro main

;fn = '/mnt/cwdata/p/m/lcb/2008/01/2008_029_glsea.asc'
;fn = '/mnt/cwdata/p/m/lcb/2008/07/2008_184_glsea.asc'
;fn = '/mnt/cwdata/p/m/lcb/2019/03/2019_060_glsea.asc'
;print, fn

 ;work_dir = '/home/cw/opr/glsea2/mk_nc/'
 ;xy_fn = '/home/cw/opr/glsea2/mk_nc/idl/glsea_xy_coord.dat'

  work_dir = getenv("WORK_DIR")
  fn = getenv("ASC_FN")
 
 print, fn
 print, work_dir

 out_dir = work_dir + 'output/'

 xy_fn = work_dir + 'idl/glsea_xy_coord.dat'

 pos=strpos(fn,'/',/reverse_search)
 yr=fix(strmid(fn,pos+1,4))
 doy=fix(strmid(fn,pos+6,3))
 print,yr,doy

;t = 3600*24L*(doy-1+julday(1,1,yr)-julday(1,1,1970))

; 3600*12 is half day, t wil point the noon of the day
t = 3600*24L*(doy+julday(1,1,yr)-julday(1,1,1970)) - 3600*12L

dim=1024
 
y=fltarr(dim,dim)
x=fltarr(dim,dim)

fmiss=-99999

xy_arr = get_x_y(xy_fn)

y_min = xy_arr(1,0)     - 900
y_max = xy_arr(1,dim-1) + 900

x_min = xy_arr(0,0)     - 900
x_max = xy_arr(0,dim-1) + 900

y_min_str = (string(y_min, format='(f20.3)')).trim()
y_max_str = (string(y_max, format='(f20.3)')).trim()
x_min_str = (string(x_min, format='(f20.3)')).trim()
x_max_str = (string(x_max, format='(f20.3)')).trim()


y_bounds = y_min_str + ',' + y_max_str
x_bounds = x_min_str + ',' + x_max_str

print, y_bounds, ', ', x_bounds , ' sss'
 
nc_fn = out_dir + strmid(fn,pos+1,15) + 'nc'

nc = ncdf_create(nc_fn,/clobber)
ncdf_control,nc,/fill

nc_time_d = ncdf_dimdef(nc,'time', 1 )   ; ncdf_dimdef(nc,'time',/unl)
nc_ny_d   = ncdf_dimdef(nc,'y',dim)
nc_nx_d   = ncdf_dimdef(nc,'x',dim)

nc_mercator_v = ncdf_vardef(nc, 'mercator',/char)      ;name mercator is required by CF 1.6

ncdf_attput, nc, nc_mercator_v, 'grid_mapping_name', 'mercator', /char
ncdf_attput, nc, nc_mercator_v, 'longitude_of_projection_origin', 0, /double
ncdf_attput, nc, nc_mercator_v, 'false_easting', 0, /double
ncdf_attput, nc, nc_mercator_v, 'false_northing', 0, /double
ncdf_attput, nc, nc_mercator_v, 'scale_factor_at_projection_origin', 1, /double
ncdf_attput, nc, nc_mercator_v, 'long_name', 'CRS definition', /string
ncdf_attput, nc, nc_mercator_v, 'longitude_of_prime_meridian', 0, /double
ncdf_attput, nc, nc_mercator_v, 'semi_major_axis', 6378137., /double
ncdf_attput, nc, nc_mercator_v, 'inverse_flattening', 298.257223563, /double
;ncdf_attput, nc, nc_mercator_v, 'spatial_ref','PROJCS["unnamed",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],PROJECTION["Mercator_1SP"],PARAMETER["central_meridian",0],PARAMETER["scale_factor",1],PARAMETER["false_easting",0],PARAMETER["false_northing",0],UNIT["METERS",1]]', /string
ncdf_attput, nc, nc_mercator_v, 'spatial_ref','PROJCS["Mercator",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433],AUTHORITY["EPSG","4326"]],PROJECTION["Mercator_1SP"],PARAMETER["central_meridian",0],PARAMETER["scale_factor",1],PARAMETER["false_easting",0],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]]]', /string

ncdf_attput, nc, nc_mercator_v, 'GeoTransform', '-10288921.955 1800 0 6520074.158 0 -1800', /string

;GeoTransform[0] /* top left x */
;GeoTransform[1] /* w-e pixel resolution */
;GeoTransform[2] /* rotation, 0 if image is "north up" */
;GeoTransform[3] /* top left y */
;GeoTransform[4] /* rotation, 0 if image is "north up" */
;GeoTransform[5] /* n-s pixel resolution */


nc_time_v = ncdf_vardef(nc,'time',nc_time_d,/double)

ncdf_attput,nc,nc_time_v,'long_name','Easten Time',/char
ncdf_attput,nc,nc_time_v,'standard_name','time',/char
ncdf_attput,nc,nc_time_v,'units','seconds since 1970-01-01 00:00:00 0:00',/char
ncdf_attput,nc,nc_time_v,'calendar','Gregorian',/char
ncdf_attput,nc,nc_time_v,'axis','T',/char

str_t = string(t)
str_bounds = str_t.trim() +',' + str_t.trim()       ; trim head and tail's white space
ncdf_attput,nc,nc_time_v,'bounds', str_bounds, /char


nc_y_v = ncdf_vardef(nc,'y',[nc_ny_d],/double)

ncdf_attput,nc,nc_y_v,'long_name','y coordinate of projection',/string
ncdf_attput,nc,nc_y_v,'standard_name','projection_y_coordinate',/string
ncdf_attput,nc,nc_y_v,'units','m',/string
ncdf_attput,nc,nc_y_v,'axis','Y',/string
ncdf_attput,nc,nc_y_v,'bounds', y_bounds,/string


nc_x_v = ncdf_vardef(nc,'x',[nc_nx_d],/double)

ncdf_attput,nc,nc_x_v,'long_name','x coordinate of projection',/string
ncdf_attput,nc,nc_x_v,'standard_name','projection_x_coordinate',/string
ncdf_attput,nc,nc_x_v,'units','m',/string
ncdf_attput,nc,nc_x_v,'axis','X',/string
ncdf_attput,nc,nc_x_v,'bounds', x_bounds,/string



nc_temp_v = ncdf_vardef(nc,'Temperature', [nc_nx_d,nc_ny_d,nc_time_d], /float)

ncdf_attput,nc,nc_temp_v,'long_name','Temperature',/char
ncdf_attput,nc,nc_temp_v,'units','Celsius',/char
ncdf_attput,nc,nc_temp_v,'standard_name','sea_water_temperature',/char
ncdf_attput,nc,nc_temp_v,'missing_value',fmiss,/float
;ncdf_attput,nc,nc_temp_v,'coordinates','lat lon',/char
ncdf_attput,nc,nc_temp_v,'grid_mapping','mercator',/char
ncdf_attput,nc,nc_temp_v,'cell_methods','area: mean',/char


nc_ice_v  = ncdf_vardef(nc,'Ice_Concentration',[nc_nx_d,nc_ny_d, nc_time_d],/float)

ncdf_attput,nc,nc_ice_v,'long_name','Ice Concentration',/char
ncdf_attput,nc,nc_ice_v,'units','%',/char
ncdf_attput,nc,nc_ice_v,'standard_name','Ice_Concentration',/char
ncdf_attput,nc,nc_ice_v,'missing_value',fmiss,/float
;ncdf_attput,nc,nc_ice_v,'coordinates','lat lon',/char
ncdf_attput,nc,nc_ice_v,'grid_mapping','mercator',/char
ncdf_attput,nc,nc_ice_v,'cell_methods','area: mean',/char

ncdf_attput,nc,/Global,'ncei_template_version','NCEI_NetCDF_Grid_Template_v2.0'

ncdf_attput,nc,/Global,'institution','NOAA/GLERL/COASTWATCH'
ncdf_attput,nc,/Global,'source','CosatWatch Great Lakes GLSEA & NIC Ice'
;ncdf_attput,nc,/Global,'comment','Approximate WGS-84 Mercator Projection - DJS 2007'
ncdf_attput,nc,/Global,'author','songzhi.liu@noaa.gov'
ncdf_attput,nc,/Global,'references','https://coastwatch.glerl.noaa.gov/'
ncdf_attput,nc,/Global,'creation_date',systime()+' GMT'
ncdf_attput,nc,/Global,'disclaimer','https://coastwatch.glerl.noaa.gov/notice.html'
ncdf_attput,nc,/Global,'Conventions', "CF-1.5, COARDS, ACDD-1.3" ;
;ncdf_attput,nc,/Global,'Conventions', "CF-1.4" ;

ncdf_control,nc,/endef

print,'endef'

ncdf_varput, nc, nc_mercator_v, " "

ncdf_varput,nc,nc_time_v,t 

;xy_arr = get_x_y(xy_fn)

x_arr = dblarr(dim)
y_arr = dblarr(dim)

x_arr(*) = xy_arr(0,*)
y_arr(*) = xy_arr(1,*)


ncdf_varput,nc,nc_y_v, y_arr
ncdf_varput,nc,nc_x_v, x_arr
 
get_temp, fn, sst_arr
get_ice,  fn, ice_arr

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
