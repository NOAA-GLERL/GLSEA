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
end else begin
 lat = 2.0 * ((( atan ( exp ( (jpx/f1 + y0) / a1) )) / !dtor) - 45.0)
 lon = -1.0*((ipx / (a1 * !dtor)) - alon0)
end

return
end
;------------------------------------------------------------------
close,/all
openr,1,'/Users/sliu/Glsea/Glsea_netCDF/cwglsyrd_1024.asc'
dim=1024
;mask=bytarr(dim,dim)
mask=fltarr(dim,dim)
readf,1,mask
close,1
mask=rotate(mask,7)
water=where(mask lt 255,nw)
print,nw
;stop
lat=fltarr(dim,dim)
lon=fltarr(dim,dim)
for i=0,dim-1 do begin
 for j=0,dim-1 do begin
  cwmap,i,j,alat,alon,0
  lat(i,j)=alat
  lon(i,j)=-alon
 end
end

nc=ncdf_create('H:GLSEA\DSchwab\glsea.nc',/clobber)
ncdf_control,nc,/fill
nc_nx=ncdf_dimdef(nc,'nx',1024)
nc_ny=ncdf_dimdef(nc,'ny',1024)
nc_time=ncdf_dimdef(nc,'time',/unl)
nc_lat=ncdf_vardef(nc,'lat',[nc_ny,nc_nx],/float)
nc_lon=ncdf_vardef(nc,'lon',[nc_ny,nc_nx],/float)
nc_timev=ncdf_vardef(nc,'time',nc_time,/long)
nc_yy=ncdf_vardef(nc,'year',nc_time,/long)
nc_doy=ncdf_vardef(nc,'day_of_year',nc_time,/long)
nc_temp=ncdf_vardef(nc,'temp',[nc_ny,nc_nx,nc_time],/float)
ncdf_attput,nc,nc_lat,'long_name','Latitude',/char
ncdf_attput,nc,nc_lat,'units','degrees_north',/char
ncdf_attput,nc,nc_lat,'standard_name','latitude',/char
ncdf_attput,nc,nc_lon,'long_name','Longitude',/char
ncdf_attput,nc,nc_lon,'units','degrees_east',/char
ncdf_attput,nc,nc_lon,'standard_name','longitude',/char
ncdf_attput,nc,nc_temp,'long_name','Temperature',/char
ncdf_attput,nc,nc_temp,'units','Celsius',/char
ncdf_attput,nc,nc_temp,'standard_name','sea_water_temperature',/char
ncdf_attput,nc,nc_temp,'missing_value',-99999,/float
ncdf_attput,nc,nc_temp,'coordinates','lon lat',/char
ncdf_attput,nc,nc_temp,'comment','negative values indicate ice fraction (0-1)',/char
ncdf_attput,nc,nc_time,'long_name','UTC',/char
ncdf_attput,nc,nc_time,'axis','T',/char
ncdf_attput,nc,nc_time,'units','seconds since 1970-01-01 00:00:00 +00:00',/char
ncdf_attput,nc,nc_time,'base_date','1970,1,1,0',/char
ncdf_attput,nc,nc_time,'standard_name','time',/char
ncdf_control,nc,/endef
print,'endef'

ncdf_varput,nc,nc_lat,lat
ncdf_varput,nc,nc_lon,lon

files=file_search('glsea_files/*',count=nf)
print,nf
; find 'ice' files
k=where(strmid(files,27,1) eq 'i',nk)
; remove corresponding 'no ice' files
files(k-1)='*'
files=files(where(files ne '*',nf))

for n=0,nf-1 do begin 
 yr=fix(strmid(files(n),12,4))
 doy=fix(strmid(files(n),17,3))
 t=3600*24L*(doy-1+julday(1,1,yr)-julday(1,1,1970))
 ncdf_varput,nc,nc_timev,t,offset=n
 ncdf_varput,nc,nc_yy,yr,offset=n
 ncdf_varput,nc,nc_doy,doy,offset=n
 temp=fltarr(dim,dim)-99999
 a=fltarr(nw)
 openr,1,files(n)
 readf,1,a
 close,1
; look for ice
 k=where(a gt 99,nk)
; convert to negative ice fraction
 if(nk gt 0) then a(k)=-(a(k)-99.)*10
 temp(water)=float(a)
 print,n,yr,doy,nk,t,' ',files(n)
 ncdf_varput,nc,nc_temp,temp,offset=[0,0,n],count=[dim,dim,1]
end
ncdf_close,nc

end
