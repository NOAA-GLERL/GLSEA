#!/bin/bash  

# filename: mk_glsea-temps.sh
# input:  /home/cw/opr/glsea3_b/output/stats.in
# output: /cwops/store/scratch/webdata/avgtemps/glsea-temps_1024.dat

date
echo "mk_glsea_temps.sh ..."

workDir='/home/cw/opr/glsea3_b/'
dataDir='/mnt/cwdata/ftp-export/glsea/avgtemps/'


#cwwebWebDir='cw@cwweb.dmz:/mnt/cwdata/'
#cwwebDataDir="${cwwebWebDir}ftp/glsea/avgtemps/"

husky_cwwebWebDir='cw@husky.dmz:/hump/cwdata/'
husky_cwwebDataDir="${husky_cwwebWebDir}ftp/glsea/avgtemps/"




inFn="${workDir}output/stats.in"
hdFn="${workDir}avgtemp_data/glsea-temps.hd"
tmpFn="${workDir}avgtemp_data/glsea-temps_1024_3.tmp"

#outFn01="${dataDir}glsea-temps"
#outFn02="_1024_3.dat"

if [[ ${1} == "-h" ]] || [[ ${1} == "--h" ]]; then
  echo " "
  echo "Usage: ${0} yyyy"
  echo " "
  exit
fi


if [[ ${1} == "" ]]; then
   yr=`date  --date="today" +%Y`                              # Year (4 digits)
else
   yr="${1}"                                  # Year (4 digits)
fi

echo $yr
echo ${inFn}

outFn01="${dataDir}${yr}/glsea-temps"
outFn02="_1024_3.dat"

cat ${inFn} | grep "    ${yr}     " | awk '{  printf "%d %3.3d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n", $1,$2,$7,$8,$9,$11,$12,$10}' > ${tmpFn}

outFn1=${outFn01}${yr}${outFn02}

echo "Update ${outFn1} ..."

cat ${hdFn} ${tmpFn}   > ${outFn1}

#cp ${outFn1} ${dataDir}glsea-temps_3.dat      # for NCEP

#echo "rsync  ${outFn1} to ${cwwebDataDir}${yr}/ ..."
#rsync  ${outFn1}  ${cwwebDataDir}${yr}/

echo "rsync -e 'ssh -p 7722'  ${outFn1} to ${husky_cwwebDataDir}${yr}/ ..."
rsync -e 'ssh -p 7722'  ${outFn1}  ${husky_cwwebDataDir}${yr}/



#echo "rsync  ${dataDir}glsea-temps_3.dat ${cwwebDataDir} ..."
#rsync  ${dataDir}glsea-temps_3.dat ${cwwebDataDir}

