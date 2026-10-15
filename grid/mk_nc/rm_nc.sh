#!/bin/bash
# filename:  re_nc.sh

echo "	"
echo "rm_nc.sh ....."
date

yr4='2022'
mn='11'
iceDataDir="/mnt/cwdata/p/s/lic/${yr4}/"

#yr4=`date +%Y`
#mn=`date +%m`

mn_list=('01' '02' '03' '04' '05' '06' '11' '12' )
#mn_list=( '02' '03' '04' '05' '06' '11' '12' )
mn_list=('11')

for mn in ${mn_list[@]}; do
      ncDir="${iceDataDir}${mn}/"
      echo $ncDir
      ls ${ncDir}*.nc

      # uncoment following line to delete nc files
       rm ${ncDir}*.nc   
done

sstDataDir="/mnt/cwdata/p/m/lcb/${yr4}/"

mn_list=('01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' )
#mn_list=(  '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' )

for mn in ${mn_list[@]}; do
      ncDir="${sstDataDir}${mn}/"
      echo $ncDir
      ls ${ncDir}*.nc

      # uncoment following line to delete nc files
       rm ${ncDir}*.nc   
done

# makd glsea nc files

mns=('01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12')
for mn in ${mns[@]}; do
   echo $mn

    
   bash mk_glsea_nc.sh $yr4 $mn
    
done
