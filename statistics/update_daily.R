#!/usr/bin/Rscript 
library(gdata)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

yrs <- 2026     # set to a single year or a vector of years
#yrs <- 2008:2010
#dy0 <- '11-10'  # mm-dd
#dyf <- '06-05'  # mm-dd

griddir <-'/mnt/projects/ipemf/ice/ct_1024'          			   # the path where you keep the ct files (expects files to be organized by year)
mskfn   <- 'cw1024_straights.txt' # the coastwatch "mask" with integers corresponding to sub regions 


force_overwrite <- F

msk <- as.matrix(read.table(mskfn))   # mask defined at end
if (lk=='bas') sel <- msk != 255           # basin
if (lk=='sup') sel <- msk >= 0  & msk < 10 # sup
if (lk=='mic') sel <- msk >= 10 & msk < 20 # mich
if (lk=='hur') sel <- msk >= 20 & msk < 30 # huron
if (lk=='eri') sel <- msk >= 40 & msk < 50 # erie (does NOT include st clair)
if (lk=='ont') sel <- msk >= 50 & msk < 60 # ont

#sel <- msk == 17 | msk == 27 # straits

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

process_data <- function(yr){

	files <- sort(list.files(full.names=T, pattern='.ct',sprintf('%s/%i/',griddir,yr)))
	for ( f in files ){
		if(grepl('01.ct',f)) print(f)
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
	    if( any(is.na(ice[sel])) ) cat(sprintf('found %i NAs in %s for region: %s \n', sum(is.na(ice[sel])),f,lk))
		tab[dstr,ystr] <- mean(ice[sel], na.rm=T)
		
	#	cat(sprintf('%s\t%3.1f\n', dstr, mean(ice[sel])))
		
	}
	return(tab)
}


#read in existing table

write.fwf(round(tab, digits=1), file=outtab, width=c(6,rep(5,ncol(tab))), rownames=T, na='NA')

# https://coastwatch.glerl.noaa.gov/ftp/masks/1024/ n


#                (2) image size 1024x1024
#                   Pixel
#                   Value   Description of Defined Region
#                   -----  -----------------------------
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
