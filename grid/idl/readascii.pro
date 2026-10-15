pro readascii,filename,lines

; procedure to read all the lines from an ASCII formatted file
;  into a string array

; find size of file and read into byte array

openr,lun,filename,/get_lun
a=fstat(lun)
lines=bytarr(a.size)
readu,lun,lines
close,lun
free_lun,lun

; find linefeeds

k=where(lines eq 10,nlines)

; read lines

lines=strarr(nlines)
openr,lun,filename,/get_lun
readf,lun,lines
free_lun,lun

return
end
