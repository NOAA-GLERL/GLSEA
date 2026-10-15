#!/bin/bash  

# filename: mk_glsea-temps.sh
# input:  /home/cw/opr/glsea3_b/output/stats.in
# output: /cwops/store/scratch/webdata/avgtemps/glsea-temps_1024.dat

date
echo "mk_glsea_temps.sh ..."

workDir='/home/cw/opr/glsea3_b/'
dataDir='/mnt/cwdata/ftp-export/glsea/avgtemps/'

#heraWebDir='cw@hera:/web.coastwatch/'
#heraDataDir="${heraWebDir}ftp/glsea/avgtemps/"

#cwwebWebDir='cw@cwweb:/var/www/html/'
cwwebWebDir='cw@cwweb.dmz:/mnt/cwdata/'
cwwebDataDir="${cwwebWebDir}ftp/glsea/avgtemps/"

husky_cwwebWebDir='cw@husky.dmz:/hump/cwdata/'
husky_cwwebDataDir="${husky_cwwebWebDir}ftp/glsea/avgtemps/"


inFn="${workDir}output/stats.in"
hdFn="${workDir}avgtemp_data/glsea-temps.hd"
tmpFn="${workDir}avgtemp_data/glsea-temps_1024.tmp"

outFn1="${dataDir}glsea-temps_1024_3.dat"
 
cat ${inFn} | tail -365 | awk '{  printf "%d %3.3d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n", $1,$2,$7,$8,$9,$11,$12,$10}' > ${tmpFn}

echo "Update ${outFn1} ..."
cat ${hdFn} ${tmpFn}   > ${outFn1}

cp ${outFn1} ${dataDir}glsea-temps_3.dat      # for NCEP

#echo "rsync  ${outFn1} to ${heraDataDir} ..."
#rsync  ${outFn1}  ${heraDataDir}

#echo "rsync  ${dataDir}glsea-temps.dat ${heraDataDir} ..."
#rsync  ${dataDir}glsea-temps.dat ${heraDataDir}

echo "rsync  ${outFn1} to ${cwwebDataDir} ..."
rsync  ${outFn1}  ${cwwebDataDir}

echo "rsync  ${dataDir}glsea-temps_3.dat ${cwwebDataDir} ..."
rsync  ${dataDir}glsea-temps_3.dat ${cwwebDataDir}

echo "rsync -e 'ssh -p 7722' ${outFn1} to ${husky_cwwebDataDir} ..."
rsync -e 'ssh -p 7722' ${outFn1}  ${husky_cwwebDataDir}

echo "rsync -e 'ssh -p 7722' ${dataDir}glsea-temps_3.dat ${husky_cwwebDataDir} ..."
rsync -e 'ssh -p 7722' ${dataDir}glsea-temps_3.dat ${husky_cwwebDataDir}

##### copy data to cwops


## for glsea-temps_1024.dat
#echo "rsync ${outFn1} to cw@hera:/web.root/ftp/coastwatch/glsea/avgtemps"
#rsync ${outFn1} cw@hera:/web.root/ftp/coastwatch/glsea/avgtemps

## for glsea-temps.dat
#echo "rsync ${outFn1} to cw@hera:/web.root/ftp/coastwatch/glsea/avgtemps/glsea-temps.dat"
#rsync ${outFn1} cw@hera:/web.root/ftp/coastwatch/glsea/avgtemps/glsea-temps.dat     # for NCEP

 
