openr, lun, 'seascapes.txt', /get_lun

line=' '
readf, lun, line

r=0
g=0
b=0
i=0
 
while ~eof(lun) do begin
 
   readf, lun, line
  ; print, line
   reads, line, r,g,b
  ; print, r,g,b,format='(3z2.2)'
;if (i mod 5) eq 0 then begin
     
 
  print, r,g,b,format='(3z2.2)'
  print, r,g,b,format='(3z2.2)'
  print, r,g,b,format='(3z2.2)'
  print, r,g,b,format='(3z2.2)'
  print, r,g,b,format='(3z2.2)'
 
;endif

  i = i + 1
 
endwhile

close, lun

end
