;openr,lun,'/home/cw/opr/glsea2/bkg/composit.pal',/get_lun

color_fn = '/home/cw/opr/glsea2/bkg/Color_test/glsea3.pal'
dat_fn = '/home/cw/opr/glsea2/output/2019_315_glsea.dat'
mask_fn = '/home/cw/masks/1024/cwglsyrd.byt'

w_bk_fn = '/home/cw/opr/glsea2/bkg/glsea_bkg.1024.winter'


   bk_img = bytarr(1024,1024)
   openr, blun, w_bk_fn, /get_lun
   readu, blun, bk_img
   free_lun,blun

   lmask  = bytarr(1024,1024)

   openr,lunm,mask_fn,/get_lun
   readu,lunm,lmask
   free_lun,lunm

 
   ;water=where(lmask lt 100,nwater)
 water=where(lmask ne 255,nwater)

   ;asc_arr = fltarr(1024,1024)

   dat_v = fltarr(nwater)
   openr,dlun, dat_fn, /get_lun
   readf,dlun, dat_v, format='(f5.2)'      
   free_lun,dlun

;asc_arr = fltarr(1024,1024)
;asc_arr(water) = dat_v

scale1 = (200-51)/256.

bk_img(water) = (dat_v /30. * 150)  +50

openr,lun,color_fn,/get_lun


a=' '
b=bytarr(3,256)
readf, lun,a,format='(a)' 
readf, lun,b,format='(3z2.2)'
free_lun, lun

red=bytarr(256)                   ; Color map
grn=bytarr(256)
blu=bytarr(256)

red(*)=b(0,*)      ; for GLSEA img
grn(*)=b(1,*)
blu(*)=b(2,*)

device,decomp=0,pseudo=8,retain=2
window,xs=1024,ys=1024;,colors=256

tvlct,b(0,*),b(1,*),b(2,*)

;loadct, 25
;loadct, 13
;loadct, 34
;loadct, 33

;tvlct,200,200,200,254             ; Color 254 to gray
;;;tvlct,215,239,255,254             ; Color 254 to light blue

tvlct, 255,255,255,0
a=bytarr(1024,1024)
a(*,*)=0
tv,a        ; write white background
 


; Temperature scale

bar_w = 28
bar_h = 420
;bar_h = 256

bar_x = 75
bar_y = 135 

scale = 256/420.

d=bytarr(1,bar_h)
;d(0,*)=byte(5.*findgen(bar_h)/14.+50)
d(0,*)=byte( scale * findgen(bar_h) )
d=rebin(d,bar_w,bar_h,/sample)	

;tv, asc_arr*10
tv, bk_img

;tv, d, bar_x, bar_y

!p.color = 0   ; draw black
!X.ticks = 0
!X.minor = 0
;!p.charthick=1.2   ; font will be darker
!p.font = 0        ; vector font

plots, [bar_x, bar_x+bar_w, bar_x+bar_w, bar_x, bar_x], $
       [bar_y, bar_y, bar_y+bar_h, bar_y+bar_h, bar_y], /device 


axis_arr = findgen(256)

plot, axis_arr, /nodata, xrange=[0,1], yrange=[0,30],  $
	   position=[bar_x, bar_y, bar_x+bar_w, bar_y+bar_h],   $
	   /device, xstyle=4, ystyle=4, /noerase	   
 ; Centigrade
 x_aj = 10
 y_aj = 15
 axis, ticklen=-.3, yaxis=1, ystyle=1, yrange=[0,30],  $
          /nodata, charsize=1.2 
 xyouts, bar_x+bar_w+x_aj, bar_y+bar_h+y_aj, '!9%!XC', /device, $
           charsize=1.2, align=0.0, font=0

 ;Fahrenheit
 axis, ticklen=-.3, yaxis=0, ystyle=1, yrange=[32,86], $
           /nodata, charsize=1.2 
 xyouts, bar_x-x_aj, bar_y+bar_h+y_aj, '!9%!XF', /device,  $
          charsize=1.2, align=1.0, font=0
  
 
xyouts,0,605,'Water Temperature',/dev,size=1.6, font=0, charthick=1 
  
  
;---------------------------------------------------------------------------
 


; Save to output files
 
fn='glsea_bkg.2019'
a=tvrd(0,0,1024,1024)
print,'Writing output file ',fn+'. . .'
openw,lun,fn,/get_lun
writeu,lun,a
free_lun,lun

tvlct, rr, gg, bb, /get
write_gif, 'bk.gif', a, rr, gg, bb
 
 
done:
end
