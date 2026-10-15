; Create a file in IDL's current working directory
filename = FILEPATH('nc_groupdef_file.nc')
id = NCDF_CREATE(filename, /NETCDF4_FORMAT, /CLOBBER)
; Create two groups at the root level of the file
g1 = NCDF_GROUPDEF(id, 'group1')
g2 = NCDF_GROUPDEF(id, 'group2')
; Create a child group inside of the two
; previously-created groups
g11 = NCDF_GROUPDEF(g1, 'group1-sub1')
g21 = NCDF_GROUPDEF(g2, 'group2-sub1')
NCDF_CLOSE, id

end
