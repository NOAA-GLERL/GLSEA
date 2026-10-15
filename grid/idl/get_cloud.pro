function get_viirs_img, fn
   sd_interface_id = hdf_sd_start(fn, /read)    ; reading hdf file

   hdf_sd_fileinfo, sd_interface_id, datasets, attributes

   for i=0, datasets-1 do begin
      sd_dataset_id = hdf_sd_select(sd_interface_id, i)

      hdf_sd_getinfo, sd_dataset_id, natts=n_atts, ndims=n_dims, dims=dims_v, coordsys=coor, $
                   name=data_set_name, hdf_type=data_type,label=label, unit=data_unit

      ; print,i, sd_dataset_id,' ', data_set_name

      if ( data_set_name eq 'sst_regression' ) then begin
         hdf_sd_getdata, sd_dataset_id, img
         img_arr = img
      endif

      if ( data_set_name eq 'acspo_mask' ) then begin
         hdf_sd_getdata, sd_dataset_id, img
         cloud_arr = img
      endif

     HDF_SD_ENDACCESS, sd_dataset_id
   endfor

   hdf_sd_end, sd_interface_id

   return, {img:rotate(img_arr,7), cloud:rotate(cloud_arr,7)}
end

;---------------------------------------------------------

function get_avhrr_img, fn
   sd_interface_id = hdf_sd_start(fn, /read)    ; reading hdf file

   hdf_sd_fileinfo, sd_interface_id, datasets, attributes

   img_miss_v = -1
   cloud_miss_v = 100
   for i=0, datasets-1 do begin
      sd_dataset_id = hdf_sd_select(sd_interface_id, i)

      hdf_sd_getinfo, sd_dataset_id, natts=n_atts, ndims=n_dims, dims=dims_v, coordsys=coor, $
                   fill=miss_v, name=data_set_name, hdf_type=data_type,label=label, unit=data_unit

      if ( data_set_name eq 'sst' ) then begin
         hdf_sd_getdata, sd_dataset_id, img
         img_arr = img
         img_miss_v = miss_v

      endif

      if ( data_set_name eq 'cloud' ) then begin
         hdf_sd_getdata, sd_dataset_id, img
         cloud_arr = img
         cloud_miss_v = miss_v
      endif

     HDF_SD_ENDACCESS, sd_dataset_id
   endfor

   hdf_sd_end, sd_interface_id

   return, {img:rotate(img_arr,7), img_miss_v:img_miss_v, cloud:rotate(cloud_arr,7), cloud_miss_v:cloud_miss_v}
end

;---------------------------------------------------------

pro read_fn, fn, v_arr

   openr, lun, fn, /get_lun
   readu, lun, v_arr
   v_arr = rotate(v_arr, 7)
   
   free_lun, lun
   ;close, lun, /force
 
   return
end

;---------------

function get_fns, fns_list, yr_jd

   n_lines = file_lines(fns_list)

   lines = strarr(n_lines)

   openr, lun, fns_list, /get_lun

   readf, lun, lines
   free_lun, lun
  ; close, lun, /force

;print, lines

;cm_base_fn = file_basename(lines)

;print, cm_base_fn


   fns = lines( where(strmatch(lines, '*'+yr_jd+'*') eq 1, n_fn)) ; get all files in yr_jd days
   return, fns
end
;-------------------
function get_cloud, yr_jd

data_dir1 = '/mnt/cwdata/o/i/vrl/'
data_dir2 = '/mnt/cwdata/o/i/rhd/'

work_dir = '/home/cw/opr/glsea2/'

fn_fns = work_dir + 'fn_list'
cloud_free_pct_fn = work_dir + 'output/cloud_free_pct.dat'
;yr_jd = '2020_217'


 mask_dir = '/home/cw/masks/1024/'
 mask_fn  = mask_dir + 'cwglsyrd.byt'
 lmask=bytarr(1024,1024)

 openr,lun,mask_fn,/get_lun
 readu,lun,lmask
 free_lun,lun

water = where(lmask lt 100,nwater)
lake = fix(lmask(water)/10)    ; array lake get value of 0, 1, 2, 3, 4, 5
;help, lake
lmask(water) = lake
;help, lmask
s_water = where(lmask eq 0, n_s)
m_water = where(lmask eq 1, n_m)
h_water = where(lmask eq 2, n_h)
c_water = where(lmask eq 3, n_c)
e_water = where(lmask eq 4, n_e)
o_water = where(lmask eq 5, n_o)

;print, n_s, n_m, n_h, n_c, n_e, n_o
;print,n_s + n_m + n_h + n_c + n_e + n_o


 land  = where(lmask ge 100)
;write_png, 'land.png', lmask 

;print, water

;k=where(cmask ne 0,nk)
;print, fns(0)
;print, nwater, nk

raw_fns = get_fns( fn_fns,yr_jd)


base_raw_fns = file_basename(raw_fns)
;base_raw_fns = '2020_217_0630_n99_gr_s7.raw'

;print, base__raw_fns

max_cloud_free_pct = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

s_arr = fltarr(n_elements(raw_fns))
m_arr = fltarr(n_elements(raw_fns))
h_arr = fltarr(n_elements(raw_fns))
e_arr = fltarr(n_elements(raw_fns))
o_arr = fltarr(n_elements(raw_fns))
c_arr = fltarr(n_elements(raw_fns))
g_arr = fltarr(n_elements(raw_fns))

openw, lun, cloud_free_pct_fn, /get_lun, /append

foreach fn, base_raw_fns, i do begin
;   print, fn
   yr_jd_tm = strmid(fn,0,13)

   filter = yr_jd_tm + '*.hdf'
   hdf_fns =  file_search( [data_dir1,data_dir2], filter, count=f_num)
   ;print, hdf_fns

   if ( f_num ne 0 ) then begin
      sensor = strmid(hdf_fns(0), 16, 3)
      ;print, sensor

      if ( sensor eq 'rhd' ) then begin
         pack = get_avhrr_img(hdf_fns(0))

         img = pack.img
         img_miss_v = pack.img_miss_v

         img = pack.img
         cloud = pack.cloud       ; cloud array
         data_miss_v = pack.cloud_miss_v
         ; print, img_miss_v, data_miss_v
          
         miss_index = where(img eq img_miss_v, m_num)
         if ( m_num ne 0 ) then begin
            cloud(miss_index) = 100  ; pix with miss value are 100% cloud cover
         endif

         cloud_index = where(cloud ne 0, c_num)
         if ( c_num ne 0 ) then begin
            cloud(cloud_index) = 100;        ; pix with non zero are 100% cloud cover
         endif

         s_cloud = cloud(s_water)
         m_cloud = cloud(m_water)
         h_cloud = cloud(h_water)
         e_cloud = cloud(e_water)
         o_cloud = cloud(o_water)
         c_cloud = cloud(c_water)

         ;write_png, file_basename(hdf_fns(0)) + 'cm.png', img
      endif else begin
         pack = get_viirs_img(hdf_fns(0))
	 cloud = pack.cloud
        
         cloud_index = where(cloud ge 128, c_num)
         if ( c_num ne 0 ) then begin
            cloud(cloud_index) = 100;        ; pix with non zero are 100% cloud cover
         endif

         s_cloud = cloud(s_water)
         m_cloud = cloud(m_water)
         h_cloud = cloud(h_water)
         e_cloud = cloud(e_water)
         o_cloud = cloud(o_water)
         c_cloud = cloud(c_water)
      endelse

      g_cloud = cloud(water)

      s_arr(i) = 100 - mean(s_cloud)
      m_arr(i) = 100 - mean(m_cloud)
      h_arr(i) = 100 - mean(h_cloud)
      e_arr(i) = 100 - mean(e_cloud)
      o_arr(i) = 100 - mean(o_cloud)
      c_arr(i) = 100 - mean(c_cloud)
      g_arr(i) = 100 - mean(g_cloud)

      ; cloud free percent
      cloud_free_pert = 100 - [mean(s_cloud),mean(m_cloud),mean(h_cloud),mean(e_cloud),mean(o_cloud),mean(c_cloud),mean(g_cloud)]

            
      ;print,file_basename(hdf_fns(0)), cloud_free_pert, format='(a, 7f7.2)' 
      printf, lun, file_basename(hdf_fns(0)), cloud_free_pert, format='(a, 7f7.2)'
;      print,file_basename(hdf_fns(0)), max(s_arr),max(m_arr),max(h_arr),max(e_arr),max(c_arr),max(g_arr), format='(a, 7f7.2)'

   endif
endforeach

free_lun, lun

print, yr_jd, max(s_arr),max(m_arr),max(h_arr),max(e_arr),max(o_arr),max(c_arr),max(g_arr), format='(a, 7f7.2)'

;img =i intarr(1024,1024)
;read_fn, img_fns(0), img

;write_png, 'img.png', img
;gl_cloud_pct = [max(s_arr),max(m_arr),max(h_arr),max(e_arr),max(o_arr),max(c_arr),max(g_arr)]
gl_cloud_pct = [mean(s_arr),mean(m_arr),mean(h_arr),mean(e_arr),mean(o_arr),mean(c_arr),mean(g_arr)]

return, gl_cloud_pct
end 
