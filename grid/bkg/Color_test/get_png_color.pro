png_fn = '/home/cw/opr/glsea2/bkg/Color_test/2019_336_hsl256.png/'
col_fn = 'HSL256.pal'

   ok = QUERY_PNG(png_fn,s)
   IF (ok) THEN BEGIN
      HELP,s,/STRUCTURE
      IF (s.HAS_PALETTE) THEN BEGIN
         img = READ_PNG(png_fn,rpal,gpal,bpal)
         HELP,img,rpal,gpal,bpal
      ENDIF ELSE BEGIN
         img = READ_PNG(png_fn)
         HELP,img
 
      ENDELSE
   ENDIF ELSE BEGIN
      PRINT,png_fn,' is not a PNG file'
   ENDELSE


new_image=COLOR_QUAN(img, 1, r, g, b, COLORS=256)

print,'Writing output file ',col_fn+'. . .'
openw,lun,col_fn,/get_lun

printf, lun, 'GLERL Composite 30 Degrees -- HSL256'

for i=0, 255 do begin
   print, r(i), g(i), b(i) 
   printf, lun, r(i), g(i), b(i), format='(3Z02)'
endfor

close, lun

end
