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

;for yyyy0=1995,1995 do begin
;for yyyy0=1999,2007 do begin
;for yyyy0=2006,2007 do begin
;for yyyy0=1996,1999 do begin
;for yyyy0=2008,2008 do begin
;for yyyy0=2009,2009 do begin
;for yyyy0=2005,2005 do begin
;for yyyy0=2006,2006 do begin
;for yyyy0=2016,2016 do begin
;for yyyy0=2017,2017 do begin
for yyyy0=2018,2018 do begin

nc_fn=string(yyyy0,format='(i4.4)')+'_glsea_ice.nc'
print,nc_fn, ' song'
;nc_fn = '1995_031_glsea.nc'

;;if(file_test(nc_fn)) then begin
;; file_delete,nc_fn
;;end

nc=ncdf_create(nc_fn,/clobber)
ncdf_control,nc,/fill
nc_nx=ncdf_dimdef(nc,'nx',im)
nc_ny=ncdf_dimdef(nc,'ny',jm)
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
ncdf_attput,nc,nc_temp,'missing_value',fmiss,/float
ncdf_attput,nc,nc_temp,'coordinates','lon lat',/char
ncdf_attput,nc,nc_temp,'comment','negative values indicate ice fraction (0-1)',/char
ncdf_attput,nc,nc_time,'long_name','UTC',/char
ncdf_attput,nc,nc_time,'axis','T',/char
ncdf_attput,nc,nc_time,'units','seconds since 1970-01-01 00:00:00 +00:00',/char
ncdf_attput,nc,nc_time,'base_date','1970,1,1,0',/char
ncdf_attput,nc,nc_time,'standard_name','time',/char

ncdf_attput,nc,/Global,'institution','NOAA/GLERL/COASTWATCH'
ncdf_attput,nc,/Global,'comment','Great Lakes GLSEA & NIC Ice'
ncdf_attput,nc,/Global,'author','gregory.lang@noaa.gov'
ncdf_attput,nc,/Global,'references','https://coastwatch.glerl.noaa.gov/'
ncdf_attput,nc,/Global,'creation_date',systime()+' GMT'
ncdf_attput,nc,/Global,'disclaimer','https://www.glerl.noaa.gov/home/notice.html'

ncdf_control,nc,/endef
print,'endef'

ncdf_varput,nc,nc_lat,lat
ncdf_varput,nc,nc_lon,lon

;1995-2007
if yyyy0 le 2007 then files=file_search(string(yyyy0,format='(i4.4)')+'/*.dat',count=nf)
;2008-
if yyyy0 ge 2008 then files=file_search('/mnt/cwdata/p/m/lcb/'+string(yyyy0,format='(i4.4)')+'/??/*.dat',count=nf)

;sort by basename. needed when files are from different dirs.
basenames=file_basename(files,'.dat')
print, basenames, ' ddd'
index_basename_sorted=sort(basenames)
files=files(index_basename_sorted)
;print,transpose(files)
print,nf

; find 'ice' files
k=where(strmid(files,4,5,/reverse_offset) eq 'i.dat',nk)
print,nk

; remove corresponding 'no ice' files (file preceding the ice file)
;this code assumes that *glsea.dat and *glsea_i.dat both exist, and are next to each other (*glsea.dat followed by *glsea_i.dat
files(k-1)='*'
files=files(where(files ne '*',nf))
print,transpose(files)
print,nk
;stop

for n=0,nf-1 do begin
 pos=strpos(files(n),'/',/reverse_search)
 yr=fix(strmid(files(n),pos+1,4))
 doy=fix(strmid(files(n),pos+6,3))
; print,yr,doy
;stop
 t=3600*24L*(doy-1+julday(1,1,yr)-julday(1,1,1970))
 ncdf_varput,nc,nc_timev,t,offset=n
 ncdf_varput,nc,nc_yy,yr,offset=n
 ncdf_varput,nc,nc_doy,doy,offset=n
 temp=fltarr(dim,dim)+fmiss
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

; these work outside of idl.
; print,'converting classic nc to netCDF-4 classic model...'
; spawn,'/opt/local/bin/ncks -O --fl_fmt=netcdf4_classic 2007_glsea_ice.nc 2007_glsea_ice.nc4'
; spawn,'/opt/local/bin/ncks -O --deflate=2 2007_glsea_ice.nc4 2007_glsea_ice.nc'
; spawn,'rm 2007_glsea_ice.nc4'
; spawn,'ls -la 2007_glsea_ice.nc'

end

end
