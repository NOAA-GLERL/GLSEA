fn = '/home/cw/opr/glsea2/mk_nc/idl/glsea_1024_lat.dat'
;fn = '/home/cw/opr/glsea2/mk_nc/idl/glsea_1024_lon.dat'

openr, lun, fn, /get_lun

line = ''
readf, lun, line
print, line

lat_arr = dblarr(1024)
i = 1023
while ~ eof( lun ) do begin

   readf, lun, lat
   lat_arr(i) = lat
   print, lat_arr(i), i
   i = i - 1
end

end
