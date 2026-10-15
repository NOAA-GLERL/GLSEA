 bk_fn='glsea_bkg.1024.summer'
 bk_fn='glsea_bkg.1024.winter'
bk_fn='glsea_bkg.2007'

!p.color=255
 bk_img = bytarr(1024,1024)
    openr, lun, bk_fn, /get_lun
    readu, lun, bk_img
    free_lun,lun
window,xs=1024, ys=1024
  tv, bk_img
  xyouts,200, 200,'Analysis Date:  JD 230  08/18/2006',/device, size=2.4
 
end
