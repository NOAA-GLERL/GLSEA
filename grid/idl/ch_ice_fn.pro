work_dir = '/home/cw/opr/glsea2/idl/'


ice_dir = '/store/p/s/lic/2014/04/'
ice_fn  = 'g201410300.lce'
 

  
   raw_ice = bytarr(1024,1024)
   
   openr, lun, ice_dir + ice_fn, /get_lun

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
   
   r_index = where(raw_ice eq 1)
    
   raw_ice(r_index) = 0
   
   
   free_lun, lun

   raw_ice2 = intarr(1024,1024)
   raw_ice2(*,*) = raw_ice 

   land_index = where(raw_ice2 eq 255)
   raw_ice2(land_index) = -1


   openw, lun, work_dir + ice_fn, /get_lun

   printf, lun, name
   printf, lun, date
   printf, lun, ncols
   printf, lun, nrows
   printf, lun, xllcorner
   printf, lun, yllcorner
   printf, lun, cellsize
   printf, lun, NODATA_value
  

   for i=0, 1023 do begin
          printf, lun, raw_ice2(*,i),  format='(1024(i2,x))'
   endfor
 
   free_lun, lun
end

