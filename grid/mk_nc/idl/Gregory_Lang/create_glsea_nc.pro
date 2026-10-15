vclose,/all
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
for i=0,im-1 do begin
 for j=0,jm-1 do begin
   cwmap,i,j,alat,alon,1
   lat(i,j)=alat
   lon(i,j)=-alon
 end
end

;for yr=2000,2003 do begin
;for yr=2013,2013 do begin
;for yr=2014,2014 do begin
;for yr=2015,2015 do begin
;;;for yr=2016,2016 do begin
;for yr=2017,2017 do begin
for yr=2018,2018 do begin

 leap='n'
 if yr mod 4. ne 0. then leap='n' else begin
  if yr mod 4. eq 0. then begin
   if yr mod 100. ne 0. then leap='y' else $
   if yr mod 100. eq 0. and yr mod 400. ne 0. then leap='n' else leap='y'
  end
 end

 ndays=365
 if leap eq 'y' then ndays=366.
 print,yr,ndays,'   ',leap
;stop
;if yr eq 2016 then ndays=252
;if yr eq 2017 then ndays=262
;if yr eq 2018 then ndays=150
if yr eq 2018 then ndays=255

 yrs=string(yr,format='(i4.4)')

 nc_fn='glsea'+yrs+'.nc'
 print,nc_fn
; check if output file exists
 if(file_test(nc_fn)) then begin
  file_delete,nc_fn
 end
 ncid=ncdf_create(nc_fn,/clobber)
 nx_id=ncdf_dimdef(ncid,'nx',im)
 ny_id=ncdf_dimdef(ncid,'ny',jm)
 ntime_id=ncdf_dimdef(ncid,'time',/UNLIMITED)
 v2=[nx_id,ny_id]
 v2t=[nx_id,ny_id,ntime_id]
 time_vid=ncdf_vardef(ncid,'time',ntime_id,/long)
  ncdf_attput,ncid,time_vid,'long_name','UTC'
  ncdf_attput,ncid,time_vid,'axis','T'
  ncdf_attput,ncid,time_vid,'units','seconds since 1970-01-01 00:00:00 +00:00'
  ncdf_attput,ncid,time_vid,'base_date','1970,1,1,0'
  ncdf_attput,ncid,time_vid,'standard_name','time'
 lon_vid=ncdf_vardef(ncid,'lon',v2)
  ncdf_attput,ncid,lon_vid,'long_name','Longitude'
  ncdf_attput,ncid,lon_vid,'units','degrees_east'
  ncdf_attput,ncid,lon_vid,'standard_name','longitude'
 lat_vid=ncdf_vardef(ncid,'lat',v2)
  ncdf_attput,ncid,lat_vid,'long_name','Latitude'
  ncdf_attput,ncid,lat_vid,'units','degrees_north'
  ncdf_attput,ncid,lat_vid,'standard_name','latitude'
 t_vid=ncdf_vardef(ncid,'temp',v2t)
  ncdf_attput,ncid,t_vid,'long_name','Temperature'
  ncdf_attput,ncid,t_vid,'units','Celsius'
  ncdf_attput,ncid,t_vid,'missing_value',fmiss
  ncdf_attput,ncid,t_vid,'standard_name','sea_water_temperature'
  ncdf_attput,ncid,t_vid,'coordinates','lon lat'

 ncdf_attput,ncid,/Global,'institution','NOAA/GLERL/COASTWATCH'
 ncdf_attput,ncid,/Global,'comment','Great Lakes GLSEA'
 ncdf_attput,ncid,/Global,'author','gregory.lang@noaa.gov'
 ncdf_attput,ncid,/Global,'references','http://coastwatch.glerl.noaa.gov/'
 ncdf_attput,ncid,/Global,'creation_date',systime()+' GMT'
 ncdf_attput,ncid,/Global,'disclaimer','https://www.glerl.noaa.gov/home/notice.html'

 ncdf_control,ncid,/endef

 secperday=Long(24L*60L*60L)
 caldat,julday(1,0,yr)+indgen(ndays)+1,mon,day,year
 stime=long((julday(mon,day,year,12.)-julday(1,1,1970,0))*secperday)

 ncdf_varput,ncid,time_vid,stime
 ncdf_varput,ncid,lon_vid,lon
 ncdf_varput,ncid,lat_vid,lat

; openw,2,'glsea'+yrs+'-tmp2.dat'

 for jd=1,ndays do begin

 jds=string(jd,format='(i3.3)')
; these dat files are from Dave Schwab. For the early years, he converted 512x512 to 1024x1024
; seem to have lost these...
;  fname='glsea_dat_files/'+yrs+'/'+yrs+'_'+string(jd,format='(i3.3)')+'_glsea.dat'
;  fname='GLSEA-ICE/'+yrs+'/'+yrs+'_'+string(jd,format='(i3.3)')+'_glsea.dat'


; 2014, could also use '/Volumes/CW_Ops/store/p/m/lcb/'+yrs+'/'
; 2014, could also use '/mnt/cwops/store/p/m/lcb/'+yrs+'/'
;  fname=file_search('/mnt/cwops/store/p/m/lcb/'+yrs+'/??/'+yrs+'_'+jds+'_glsea.dat')
; new
; mountatoz
  fname=file_search('/mnt/atoz/cwdata/p/m/lcb/'+yrs+'/??/'+yrs+'_'+jds+'_glsea.dat')

  print,fname
  a=fltarr(nw)
  openr,1,fname
  readf,1,a
  close,1
  b=fltarr(dim,dim)+fmiss
  b(water)=a
;  help,b,lat,lon
  print,jd,total(b(water))/nw,nw
  print,jd,b(602,289)               ; at 45147, i=602, j=289
;  printf,2,jd,total(b(water))/nw

  ncdf_varput,ncid,t_vid,b,offset=[0,0,jd-1]

 end
; close,2

 print,'glsea2.pro successfully completed'

 ncdf_close,ncid

; these work outside of idl.
; print,'converting classic nc to netCDF-4 classic model...'
; spawn,'/opt/local/bin/ncks -O --fl_fmt=netcdf4_classic glsea'+yrs+'.nc glsea'+yrs+'.nc4'
; spawn,'/opt/local/bin/ncks -O --deflate=2 glsea'+yrs+'.nc4 glsea'+yrs+'.nc'
; spawn,'rm glsea'+yrs+'.nc4'
; spawn,'ls -la glsea'+yrs+'.nc'

end

print,''
spawn,'ls -la glsea*.nc'

end

; get temps at a grid cell...
;ncea -O -d time,100,125 -d nx,600 -d ny,600 glsea2012.nc test.nc
;ncea -O -d nx,600 -d ny,600 glsea2012.nc test.nc
;ncdump -v temp test.nc
