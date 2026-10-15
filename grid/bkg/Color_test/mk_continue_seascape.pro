openr, lun, 'seascapes_31.txt', /get_lun

line=' '
readf, lun, line

r=0
g=0
b=0
i=0

r_arr = intarr(31) 
g_arr = intarr(31)
b_arr = intarr(31)

while ~eof(lun) do begin
 
   readf, lun, line
   
 
   
   reads, line, r,g,b

   print, r,g,b  
   r_arr(i) = r  
   g_arr(i) = g  
   b_arr(i) = b  
 
  ;print, r,g,b,format='(3z2.2)'
 
 
   
 i = i + 1
endwhile

close, lun
print, 'AAA'
for n=0, 29 do begin
   
   r_inc = (r_arr(n+1)- r_arr(n)) / 6.
   g_inc = (g_arr(n+1)- g_arr(n)) / 6.
   b_inc = (b_arr(n+1)- b_arr(n)) / 6.

   ;print, g_arr(n+1), g_arr(n), g_arr(n+1)- g_arr(n), g_inc
   for m=1, 5 do begin
       print, ceil(r_arr(n) + m * r_inc), ceil(g_arr(n) + m * g_inc), ceil(b_arr(n) + m * b_inc), format='(3z2.2)'
   endfor
endfor

end
