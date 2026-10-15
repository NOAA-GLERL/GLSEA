; Convert DTX Eta lat/lon points to GLSEA array index
;
idtpt=0 & lat=0.0 & lon=0.0 & ipx=0 & jpx=0
ietaind=lonarr(1670)
ietanum=intarr(1670)
print,'Opening dtx-eta.i-j. . .'
openr,luneta,'dtx-eta.i-j',/get_lun
for i=0,1669 do begin
 readf,luneta,format='(4x,i4,5x,i3,5x,i3,6x,f7.4,6x,f7.4)',idtpt,ipx,jpx,lat,lon
; print,format='(4x,i4,5x,i3,5x,i3,6x,f7.4,6x,f7.4)',idtpt,ipx,jpx,lat,lon
 index=long(jpx)*512+ipx
 ietaind(i)=index
 ietanum(i)=idtpt
end
close,luneta

print,'Writing etadtx_pts.dat. . .'
openw,luneta,'etadtx_pts.dat',/get_lun
for i=0,1669 do begin
 printf,luneta,format='(i5,1x,i6)',ietanum(i),ietaind(i)
end
close,luneta
;;print,ietaind
;;print,' '
;;print,ietanum
end
