#!/usr/bin/Rscript 
# this is mirror of update_daily.R (that's the script that routinely updates each lake)
# this is intended for actual subregions (like the straits, whitefish bay, etc.)
library(gdata)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#yrs <- 1973:2025     # set to a single year or a vector of years
#yrs <- 2023:2026     # set to a single year or a vector of years
#yrs <- 2024
#dy0 <- '11-15'  # mm-dd
#dyf <- '06-04'  # mm-dd

#griddir <-'/mnt/projects/ipemf/ice/ct_1024'         			   # the path where you keep the ct files (expects files to be organized by year)
#tabdir <- '/mnt/projects/ipemf/ice/analysis/out_subreg'              # where are the tables?
mskfn   <- 'cw1024_straights.txt' # the coastwatch "mask" with integers corresponding to sub regions 
#mskfn   <- '/mnt/projects/ipemf/ice/CW_files/special_out_porthuron28_duluth08.txt'
msk <- as.matrix(read.table(mskfn))   # mask defined at end

#sel <- msk == 
#name <- 'georgian_bay'
#name <- 'greenbay'

tab_fn <- sprintf('%s/%s.txt',tabdir,name)
#outtab <- sprintf('%s/%s.txt','out',lk)

force_overwrite <- T

#sel <- msk == 17 | msk == 27 # straits
sel <- msk == 11

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

process_yr <- function(yr){
	print(yr)

	files <- sort(list.files(full.names=T, pattern='.ct',sprintf('%s/%i/',griddir,yr)))
	for ( f in files ){
		#print(basename(f))
		# readfile and set date
		ice <- as.matrix(read.table(f,skip=7))
		dt <- strptime(substr(f,nchar(f)-10,nchar(f)-3),'%Y%m%d')
	
		# confirm only valid GLERL percentages exist
		valid <- c(-1, seq(0,100,5))
		chk = all(is.element(c(ice), valid))
		if (!chk){ inval <- setdiff(ice,valid); print('invalid values found:'); print(inval) } # quit() }
	
		# set land to NA
		ice[ice==-1] <- NA
	
		# handle dates
		yr <- 1900 + dt$year
		if ( dt$yday > 300 ) yr <- yr+1 # associate Nov/Dec with "ice year"
		ystr <- sprintf('%4i',yr)
		dstr <- strftime(dt,'%b-%d')
	
		# save to table 
	    #if( any(is.na(ice[sel])) ) cat(sprintf('found %i NAs in %s for region: %s \n', sum(is.na(ice[sel])),f,name))
		tab[dstr,ystr] <- mean(ice[sel], na.rm=T)
		

		 # save progress after each year
	    if ( lastyr != yr ) write.fwf(format(tab, nsmall=1, digits=1), file=tab_fn, width=c(6,rep(5,ncol(tab))), rownames=T, na='NA')
		lastyr <- yr

	#	cat(sprintf('%s\t%3.1f\n', dstr, mean(ice[sel])))
		
	}
	# optionally write every year
	#write.fwf(format(tab, nsmall=1, digits=1), file=tab_fn, width=c(6,rep(5,ncol(tab))), rownames=T, na='NA')
	return(tab)
}


print(tab_fn)
if (file.exists(tab_fn)){
	#read in existing table
	print('appending/overwriting the existing table')
	tab <- read.table(tab_fn, check.names=F)
	exist_yrs <- as.numeric(names(tab))
	if (any(yrs %in% exist_yrs) & !force_overwrite) stop('SELECTED YEAR OVERLAPS WITH EXISTING DATA and FORCE IS FALSE... EXITTING')
} else{
	dys <- strftime(seq(as.Date(sprintf('0003-%s',dy0)), as.Date(sprintf('0004-%s',dyf)), by='days'), '%b-%d')
	tab <- matrix(nrow=length(dys), ncol=length(yrs), dimnames=c(list(dys),list(yrs)) )
}
	

lastyr <- yrs[1]
for (yr in yrs) tab <- process_yr(yr)

# write a final time
write.fwf(format(tab, nsmall=1, digits=1), file=tab_fn, width=c(6,rep(5,ncol(tab))), rownames=T, na='NA')

# https://coastwatch.glerl.noaa.gov/ftp/masks/1024/ n

#                (2) image size 1024x1024
#                   Pixel
#                   Value   Description of Defined Region
#                   -----   -----------------------------
#
#                    00     Lake Superior
#                    01     Thunder Bay
#                    02     Black Bay
#                    03     Nipigon Bay
#                    04     Western Lake Superior
#                    05     Eastern Lake Superior
#                    06     Whitefish Bay
#                    07     St Marys River North
#
#                    10     Lake Michigan
#                    11     Green Bay
#                    12     Grand Traverse Bay
#                    13     Northern Lake Michigan
#                    14     Southern Lake Michigan
#
#                    20     Lake Huron
#                    21     Georgian Bay
#                    22     North Channel
#                    23     Saginaw Bay
#                    24     Northern Lake Huron
#                    25     Southern Lake Huron
#                    26     St Marys River South
#
#                    30     Lake St. Clair
#                    31     Detroit River North
#
#                    40     Lake Erie
#                    41     Western Lake Erie
#                    42     Central Lake Erie
#                    43     Eastern Lake Erie
#                    44     Detroit River South
#
#                    50     Lake Ontario
#                    51     Western Lake Ontario
#                    52     Eastern Lake Ontario
#
#                    255     Land
#
#
