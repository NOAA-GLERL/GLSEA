fn = 'glsea30_step_a.pall' 
fn = 'glsea30_step7_b.pal' 

openr, lun, fn, /get_lun

line=' '

line_arr = strarr(257)

   readf, lun, line
 
for i=0, 256 do begin
 
 
   readf, lun, line
   line_arr(i) = line
   ;print, line_arr(i)
  
endfor

close, lun

;for i=200, 51, -1 do begin
;   print, line_arr(i)
;endfor

t_arr = strarr(25)
 
for i=50, 199 do begin

   if ~(i mod 25) then begin     
      j = 0
   end    
      
   t_arr(j) = line_arr(i)
   j = j + 1
      
   if (j eq 25 ) then begin
      for j=24, 0, -1 do begin
        print, t_arr(j)
      endfor
   end
    
endfor

end
