
### Great Lakes Surface Environmental Analysis ACSPO Processing


Algorithm for GLSEA:
1. Get GLSEA from previous day.
2. Get all SST images from +/- 10 days (20 day window).
3. Geocorrect SST images and apply cloud mask.
4. For each cell in GLSEA:
	- Get all SST values for this cell from +/- 10 days (20 day window).
	- If there are more than 2 values in +/- 10 day window, calculate mean and standard deviation, eliminate values more than 2 standard deviations away from mean.
	- If there are both a prior SST value and a subsequent SST value for this cell within +/- 10 day window, then linearly interpolate in time, else if there is at least one SST value for this cell within +/- 2 days, use it.
5. For any pixel not filled in Step 4:
	- If there are at least 6 SST values that have been filled in Step 4 in the surrounding 5×5 cells, use the average of the surrounding cells for this cell, else fill this cell with value of cell from previous day plus change in lakewide mean.
6. Calculate lakewide mean for each lake and save GLSEA


---
#### Description of GLSEA GRIDDED product code
below are just examples, I have no idea how this works! ;) so feel free to change

- glsea3_b.pro:   Main processing script: The main program to make the GLSEA files.
	input directories: 
	output directories:
	step 1: calls readascii.pro?
	step 2: modify something?
	step 3: 
	step 4: 
	step 5:

- readascii.pro: Reads ASCII data into array.
- ch_ice_fn.pro: checking the ice file
- ck_asc.pro: checking the asc file
- get_buoy_and_glsea_sst.pro: the program to get bouy and sst data.
- get_cloud.pro: the program to get cloud information
- glsea3_b.pro: the mail program to make glsea files.

# delete below files
- pp.pro: testing code
- t2.pro: testing code
- test.pro: testing code
- t.pro: testing code



- mk_acspo_glsea-temps.sh: the main script to make the acspo glsea-temps file.
- mk_geotif.sh: the main script to make geotif file.
- mk_glsea3_b.sh: the main scritp to creat the glsea files.
	- this script defines the input and output directories
	- this script also creates annual and monthly directories if needed
- mk_glsea-temps_by_year.sh: the script to make glsea-temps by year
- mk_glsea-temps.sh: the script to make glsea-temps file
- mk_sst_list.sh: the script to make the list of SST files.
- print_png.sh: the script to print png file
- re_upload.sh: the script to send the glsea file to realearth server
- run_geotif.sh: manually run code to make geotif file
- run.sh: manully run code.


---
#### Description of GLSEA STATISTICS code
