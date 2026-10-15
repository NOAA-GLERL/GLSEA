y1=4677774.158d
y2=6519174.158d

x1=-10288021.955d
x2=-8446621.955d

fn = 'glsea_xy_coord.dat'

openw, lun, fn, /get_lun 

n=0
for i=y1, y2, 1800 do begin
  
   
   print, n, x1, y1, format='(i4.4,f13.3, f12.3)'

   printf, lun, x1, y1, format='(f13.3, f12.3)'

   y1 = y1 + 1800.0
   x1=x1 + 1800
   n = n + 1
endfor

close, lun  

end
