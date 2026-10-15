   asc_arr1 = fltarr(1024,1024)
   asc_arr2 = fltarr(1024,1024)

   openr, 1, '/store/p/m/lcb/2014/01/2014_024_glsea.asc'

   openr, 2, '/home/cw/opr/glsea2_1024/output/2014_024_glsea.asc'
 
line1 = ' '
line2 = ' '

v_arr1 = fltarr(1024)
v_arr2 = fltarr(1024)
v1 = 0.0
v2 = 0.0

for i=0, 1024 do begin
  readf, 1, line1
  readf, 2, line2
 if (line1 ne line2) then begin
   print, i
   
   for j=0, 1023 do begin
      reads, line1, v_arr1
   end
  
   for j=0, 1023 do begin
      reads, line2, v_arr2
   end
   
   for j=0, 1023 do begin
      if ( v_arr1(j) ne v_arr2(j) ) then print,  j, v_arr1(j) , v_arr2(j)
   end

  end
end

close, 1
close, 2
end
