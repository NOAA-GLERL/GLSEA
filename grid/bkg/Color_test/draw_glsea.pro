
;--------------------------------------------------------------------------

function get_ice_concentration, raw_ice

   sicode  = ['10','20','30','40','50','60','70','80','90','91','92','93',     $
              '01','02','12','13','24','35','45','46','57','68','79','89','81',$
              '11','22','23','33','34','44','55','56','66','67','77','78','88']

                                                   ; GLSEA ice color index

   clridx  = [ 12,  14,  16,  18,  20,  22,  24,  26,  28,  29,  30,  30,      $
               11,  12,  13,  14,  16,  18,  19,  20,  22,  24,  26,  27,  28, $
               12,  14,  15,  16,  17,  18,  20,  21,  22,  23,  24,  25,  26]

;-----------------------------------------------------------------------------------
;  Color               Median Ice                  Color               Median Ice
;  index    SI Code   Concentration                index    SI Code    Concentration
;-----------------------------------------------------------------------------------
;   11          01          5                       24    68,70,77         70
;   -------------------------
;   12    02,10,11         10                       25          78         75
;                                                   26    79,80,88         80
;   13       12,15         15                       27          89         85
;                                                   -------------------------
;   14    13,20,22         20                       28       81,90         90
;   15          23         25                       29          91         95
;   16    24,30,33         30                       -------------------------
;   17          34         35                       30       92,93        100
;   -------------------------
;   18    35,40,44         40
;   19          45         45                     11-12  Off-white
;   20    46,50,55         50                     13-17  Light gray
;   21          56         55                     18-23  Medium gray
;   22    57,60,66         60                     24-29  Dark gray
;   23          67         65                     30-30  Black
;-----------------------------------------------------------------------------------

   asc_arr = bytarr(1024,1024)

   ice_index = where( (raw_ice ne 255) and (raw_ice ne 0) )  ; 0 = water,  255 = land (in lce file it is -1)
   
   c_01 = where(raw_ice eq 1, c_num)
   if (c_num ne 0 ) then asc_arr( c_01 ) = 5 
      
   c_02 = where(raw_ice eq 2, c_num)
   if (c_num ne 0 ) then asc_arr( c_02 ) = 10
   
   c_10 = where(raw_ice eq 10, c_num)
   if (c_num ne 0 ) then asc_arr( c_10 ) = 10
    
   c_11 = where(raw_ice eq 11, c_num)
   if (c_num ne 0 ) then asc_arr( c_11 ) = 10
         
   c_12 = where(raw_ice eq 12, c_num)
   if (c_num ne 0 ) then asc_arr( c_12 ) = 15
    
   c_15 = where(raw_ice eq 15, c_num)
   if (c_num ne 0 ) then asc_arr( c_15 ) = 15     
   
   c_13 = where(raw_ice eq 13, c_num)
   if (c_num ne 0 ) then asc_arr( c_13 ) = 20
   
   c_20 = where(raw_ice eq 20, c_num)
   if (c_num ne 0 ) then asc_arr( c_20 ) = 20
    
   c_22 = where(raw_ice eq 22, c_num)
   if (c_num ne 0 ) then asc_arr( c_22 ) = 20   
  
   c_23 = where(raw_ice eq 23, c_num)
   if (c_num ne 0 ) then asc_arr( c_23 ) = 25   
    
   c_24 = where(raw_ice eq 24, c_num)
   if (c_num ne 0 ) then asc_arr( c_24 ) = 30 
   
   c_30 = where(raw_ice eq 30, c_num)
   if (c_num ne 0 ) then asc_arr( c_30 ) = 30
    
   c_33 = where(raw_ice eq 33, c_num)
   if (c_num ne 0 ) then asc_arr( c_33 ) = 30   
   
   c_34 = where(raw_ice eq 34, c_num)
   if (c_num ne 0 ) then asc_arr( c_34 ) = 35  
    
   c_35 = where(raw_ice eq 35, c_num)
   if (c_num ne 0 ) then asc_arr( c_35 ) = 40
   
   c_40 = where(raw_ice eq 40, c_num)
   if (c_num ne 0 ) then asc_arr( c_40 ) = 40
    
   c_44= where(raw_ice eq 44, c_num)
   if (c_num ne 0 ) then asc_arr( c_44 ) = 40   
 
   c_45= where(raw_ice eq 45, c_num)
   if (c_num ne 0 ) then asc_arr( c_45 ) = 45   
  
   c_46 = where(raw_ice eq 46, c_num)
   if (c_num ne 0 ) then asc_arr( c_46 ) = 50
   
   c_50 = where(raw_ice eq 50, c_num)
   if (c_num ne 0 ) then asc_arr( c_50 ) = 50
    
   c_55= where(raw_ice eq 55, c_num)
   if (c_num ne 0 ) then asc_arr( c_55 ) = 50
      
   c_56= where(raw_ice eq 56, c_num)
   if (c_num ne 0 ) then asc_arr( c_56 ) = 55      
   
   c_57 = where(raw_ice eq 57, c_num)
   if (c_num ne 0 ) then asc_arr( c_57 ) = 60
   
   c_60 = where(raw_ice eq 60, c_num)
   if (c_num ne 0 ) then asc_arr( c_60 ) = 60
    
   c_66= where(raw_ice eq 66, c_num)
   if (c_num ne 0 ) then asc_arr( c_66 ) = 60
  
   c_67= where(raw_ice eq 67, c_num)
   if (c_num ne 0 ) then asc_arr( c_67 ) = 65
  
   c_68 = where(raw_ice eq 68, c_num)
   if (c_num ne 0 ) then asc_arr( c_68 ) = 70
   
   c_70 = where(raw_ice eq 70, c_num)
   if (c_num ne 0 ) then asc_arr( c_70 ) = 70
    
   c_77= where(raw_ice eq 77, c_num)
   if (c_num ne 0 ) then asc_arr( c_77 ) = 70
 
   c_78= where(raw_ice eq 78, c_num)
   if (c_num ne 0 ) then asc_arr( c_78 ) = 75
 
   c_79 = where(raw_ice eq 79, c_num)
   if (c_num ne 0 ) then asc_arr( c_79 ) = 80
   
   c_80 = where(raw_ice eq 80, c_num)
   if (c_num ne 0 ) then asc_arr( c_80 ) = 80
    
   c_88= where(raw_ice eq 88, c_num)
   if (c_num ne 0 ) then asc_arr( c_88 ) = 80

   c_89= where(raw_ice eq 89, c_num)
   if (c_num ne 0 ) then asc_arr( c_89 ) = 85 
  
   c_81 = where(raw_ice eq 81, c_num)
   if (c_num ne 0 ) then asc_arr( c_81 ) = 90
   
   c_90 = where(raw_ice eq 90, c_num)
   if (c_num ne 0 ) then asc_arr( c_90 ) = 90        
    
   c_91= where(raw_ice eq 91, c_num)
   if (c_num ne 0 ) then asc_arr( c_91 ) = 95

   c_92= where(raw_ice eq 92, c_num)
   if (c_num ne 0 ) then asc_arr( c_92 ) = 100
  
   c_93= where(raw_ice eq 93, c_num)
   if (c_num ne 0 ) then asc_arr( c_93 ) = 100
       
   return, asc_arr
end

;-----------------------------------------------------------------------------------

function get_year_month_day, yra, jda
   
   n_yr = fix(yra)                  ; float to int
   n_jd = fix(jda)

   total_jd = julday( 1, 0, n_yr )
   total_jd = total_jd + n_jd

   caldat, total_jd, month, day, year
   year  = strtrim(year,1) 			; leading blanks are removed
   month = strtrim(month,1)
   day   = strtrim(day,1)
   
   y_m_d = string(year, format='(i4)') + string(month,format='(i2.2)') +string(day,format='(i2.2)')  
   return, y_m_d
end

;-----------------------------------------------------------------------------------

function get_ice_fn, ice_dir, yra, jda

   n_yr = fix(yra)                  ; float to int
   n_jd = fix(jda)
      
   num = 0                          ; no ice file
   loop = 5                         ; check till 5 days back if no ice file

   while ( (num eq 0) and (loop ge 0) ) do begin
         total_jd = julday( 1, 0, n_yr )
         total_jd = total_jd + n_jd
   
         caldat, total_jd, month, day, year
         year  = strtrim(year,1) 			; leading blanks are removed
         month = strtrim(month,1)
         day   = strtrim(day,1)
 
         mn_arr = [ '00', '01','02','03' ,'04','05','06','07','08','09','10','11','12' ]
 
         s_yr = string(n_yr,format='(i4)')     
         s_jd = string(n_jd,format='(i3.3)')
         ice_fn = ice_dir + year + '/' + mn_arr(month) + '/g' + s_yr + s_jd + '00.lce'

         rt = file_search( ice_fn, count=num)
         if ( num eq 0 ) then begin
            n_jd = n_jd - 1
            if ( n_jd le 0 ) then begin
               
               n_yr = n_yr - 1

              if ( n_yr mod 4 ) then begin
                  n_jd = 365
              endif else begin
                  n_jd = 366
              endelse
            end
         end
         loop = loop - 1
            print, ice_fn, ' loop = ', loop, ' n_jd= ', n_jd

   endwhile
  
   if ( num eq 0 ) then begin
        ice_fn = ''
   end

   return, ice_fn
end


;-----------------------------------------------------------------------------------


; img get the color index based on the ice code

pro ice_overlay, raw_ice, img


   sicode  = ['10','20','30','40','50','60','70','80','90','91','92','93',     $
              '01','02','12','13','24','35','45','46','57','68','79','89','81',$
              '11','22','23','33','34','44','55','56','66','67','77','78','88']

                                                   ; GLSEA ice color index

   clridx  = [ 12,  14,  16,  18,  20,  22,  24,  26,  28,  29,  30,  30,      $
               11,  12,  13,  14,  16,  18,  19,  20,  22,  24,  26,  27,  28, $
               12,  14,  15,  16,  17,  18,  20,  21,  22,  23,  24,  25,  26]

;-----------------------------------------------------------------------------------
;  Color               Median Ice                  Color               Median Ice
;  index    SI Code   Concentration                index    SI Code    Concentration
;-----------------------------------------------------------------------------------
;   11          01          5                       24    68,70,77         70
;   -------------------------
;   12    02,10,11         10                       25          78         75
;                                                   26    79,80,88         80
;   13       12,15         15                       27          89         85
;                                                   -------------------------
;   14    13,20,22         20                       28       81,90         90
;   15          23         25                       29          91         95
;   16    24,30,33         30                       -------------------------
;   17          34         35                       30       92,93        100
;   -------------------------
;   18    35,40,44         40
;   19          45         45                     11-12  Off-white
;   20    46,50,55         50                     13-17  Light gray
;   21          56         55                     18-23  Medium gray
;   22    57,60,66         60                     24-29  Dark gray
;   23          67         65                     30-30  Black
;-----------------------------------------------------------------------------------
 
   if ( max(raw_ice gt 0) ne 0) then begin
      for sigrid=0,n_elements(sicode)-1 do begin
          ; print, sigrid, ' ', sicode(sigrid)
         nice=0 & ice_index=where(raw_ice eq sicode(sigrid),nice)
         if (nice gt 0) then img(ice_index)=clridx(sigrid)
      end
   end   
  
   return
end
 
;-----------------------------------------------------------------------------------

pro get_raw_ice, ice_fn, nb_fn, land_mask, raw_ice

   land = where(land_mask ge 100)

   openr, lun, ice_fn, /get_lun

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
   raw_ice = rotate(temporary(raw_ice),7)

   openr, lun, nb_fn, /get_lun

   line = ' '
   readf, lun, line, line, line,line, line, line

   while not eof(lun) do begin
      readf, lun, line
           ; print, line
      o_col = 0
      o_row = 0
      red = 0
      n_col = 0
      n_row = 0
      blue = 0
      flag = 0
   
      reads, line, o_col, o_row, red, n_col, n_row, blue, flag 
   
           ;print, o_col, o_row, red, n_col, n_row, blue, flag 
      raw_ice(o_col, o_row) = raw_ice(n_col, n_row) 
   end
   
   free_lun, lun
   
   raw_ice(land) = -1.0    ; change ice to land (cw is land, nic is ice)

   return
end

 
;-----------------------------------------------------------------------------------


function get_gl_ice_cover, land_mask, raw_ice 
 
   water = where( land_mask ne 255, water_pix_num )
   gl_ice_pix_value = raw_ice(water)
   gl_sum = total(gl_ice_pix_value)   ; total ice contration over water
 
   return, gl_sum / water_pix_num

end

;-----------------------------------------------------------------------------------

color_fn = '/home/cw/opr/glsea2/bkg/Color_test/glsea5.pal'

dat_fn = '/home/cw/opr/glsea2/output/2020_001_glsea.dat'

mask_fn = '/home/cw/masks/1024/cwglsyrd.byt'
nb_fn = '/home/cw/masks/1024/ice_land_mask_neighbor_final.txt'

ice_dir  = '/mnt/cwdata/p/s/lic/'

w_bk_fn = '/home/cw/opr/glsea2/bkg/glsea_bkg.1024.winter'
s_bk_fn = '/home/cw/opr/glsea2/bkg/glsea_bkg.1024.summer'

begin_ice = 318
end_ice   = 158


   fn = file_basename(dat_fn)    ; fn = 2014_029_glsea.dat
   str_yr = strmid(fn, 0, 4)
   str_jd = strmid(fn, 5, 3)

   jda = fix(str_jd)
   
   bk_img = bytarr(1024,1024)

   if ( jda le end_ice or jda ge begin_ice) then begin                   ; ice season

      s_w_flag = 1 ; 1 - winter, 0 - summer
      openr, blun, w_bk_fn, /get_lun
   endif else begin
      s_w_flag = 0
      openr, blun, s_bk_fn, /get_lun
   endelse

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


bk_img(water) = (dat_v /30. * 150) + 50
;bk_img(water) = (dat_v /30. * 256)  

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


 
new_b = bytarr(3,256)

for i=200, 255 do begin
   new_b(*, i) = 255
endfor

index = 0
n = 0L
for i=49, 199 do begin
   ;print, index, n, 255/150., n*255/150.
   new_b(*, i) = b(*, index)  
   index = fix( n*255/150.)  
   n = n + 1
   ;new_b(*,199) = b(*,255)
endfor

 

device,decomp=0,pseudo=8,retain=2
window,xs=1024,ys=1024,colors=255

;;;tvlct,b(0,*),b(1,*),b(2,*)
tvlct,new_b(0,*),new_b(1,*),new_b(2,*)

;loadct, 25
;loadct, 13
;loadct, 34
;loadct, 33


;tvlct,200,200,200,254             ; Color 254 to gray
;tvlct,215,239,255,254             ; Color 254 to light blue

   tvlct,215,239,255,254             ; Color 254 to light blue

   tvlct,  0, 71,153,1               ; for NOAA logo
   tvlct,  0,189,236,2
   tvlct,255,255,255,3

;tvlct, 255,255,255,0
a=bytarr(1024,1024)
a(*,*)=0
tv,a        ; write white background
 


; Temperature scale

bar_w = 28
bar_h = 420
bar_x = 75
bar_y = 135 

scale = 256/420.

d=bytarr(1,bar_h)
;d(0,*)=byte(5.*findgen(bar_h)/14.+50)
d(0,*)=byte( scale * findgen(bar_h) )
d=rebin(d,bar_w,bar_h,/sample)	

         raw_ice = bytarr(1024,1024)              ; need for both ice season and non ice season


   if ( s_w_flag eq 1 ) then begin             ; winter ice overlay

      tvlct, 220,220,220,11			; color for ice  scale

      for i=12, 17 do begin
         tvlct, 190,190,190, i
      end

      for i=18, 23 do begin			
         tvlct, 160,160,160, i
      end
 
      for i=24, 27 do begin
         tvlct, 110,110,110, i
      end

      for i=28, 29 do begin
         tvlct, 70,70,70, i
      end

      tvlct, 0,0,0,30
  
       get_raw_ice, ice_fn, nb_fn, lmask, raw_ice     ; raw_ice will have same shoreline as lmask 
    
      ice_overlay, raw_ice, bk_img


   endif

tv, bk_img,/ device

;tv, d, bar_x, bar_y
   !p.color=0
   !p.font=1   ; true font
   !p.charthick=0.5   ; font will be darker
   !p.charsize=2.5

   fn = file_basename(dat_fn)    ; fn = 2014_029_glsea.dat
   str_yr = strmid(fn, 0, 4)
   str_jd = strmid(fn, 5, 3)

   start_jd = julday(1,0, str_yr)
   n_jd = start_jd + str_jd
   caldat, n_jd, mo, dy

   str_mo = string(mo, format='(i2.2)')
   str_dy = string(dy, format='(i2.2)')
   ;xyouts,494,840,'Analysis Date:  JD 230  08/18/2006',/device, size=2.4
 
   xyouts,494,840,'Analysis Date:  JD '+str_jd+' '+str_mo+'/'+str_dy+'/'+str_yr,/device 
 

   if ( s_w_flag eq 1 ) then begin             ; winter ice overlay

      ice_fn = get_ice_fn( ice_dir, str_yr, str_jd)

      if ( strlen(ice_fn) ne 0 ) then begin
         ifn = file_basename(ice_fn)              
         i_yr = strmid(ifn, 1, 4)
         i_jd = strmid(ifn, 5,3)
      
         i_start_jd = julday(1,0,i_yr)

         caldat, i_start_jd+i_jd, month, day, year
         print, month, day, year
 
         year  = strtrim(year,1)
         month = strtrim(month,1)
         day   = strtrim(day,1)
 
         xyouts, 512, 776, 'Date of last ice analysis: ' +month+'/'+day+'/'+year,/device 


         ice_arr = get_ice_concentration( raw_ice )

         ice_total = get_gl_ice_cover(lmask, ice_arr )
         str_total = string(ice_total, format='(f5.1)')
 
         xyouts, 550, 700, 'Great Lakes Total Ice Cover: ' + str_total + '%', /device 

      endif else begin
         xyouts, 512, 776, 'Date of last ice analysis: ' + '00/00/0000',/device 
      endelse
      
   endif

   ;p_pix = nk1 / 148682. * 100.
   p_pix = 99

   str_p_pix = string(p_pix, format='(f5.1)')
   ;xyouts,424,810,'Percent Pixels with Data within +/-10 Days: 99.9%',/device, size=2.4
  
   xyouts,414,810,'Percent Pixels with Data within +/-10 Days: '+str_p_pix +'%',/device 
 
   img800=tvrd(0, 109, 1024,800, /true)
   ;tvlct, rr, gg, bb, /get
  
   png_fn = fn+'.2.png'
   print, 'Make ' + png_fn + ' ...'
   write_png, png_fn, img800;, rr, gg, bb
  ;;; write_png, png_fn, tvrd(0, 109, 1024,800, /true)
 
end
