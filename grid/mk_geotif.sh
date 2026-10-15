#!/bin/bash

# filename: mk_geotif.sh

#-------------------------------------------------------------------------------

function mk_asc_fn {

   str_yr=${1}
   str_jd=${2}

   i_jd=`echo $str_jd | awk '{ printf "%3d", $0 }' `  # from JJJ to J (eg. 008 to 8)
   i_yr=`echo $str_yr | awk '{ printf "%4d", $0 }' `  

   #echo $i_jd "dddd" $i_yr

   if [[ i_jd -eq 1 ]]; then

      let "i_yr = i_yr - 1"
      str_yr="$i_yr"

      if [[ $(( $i_yr % 4 )) -eq 0 ]]; then   
         str_jd=366
      else
         str_jd=365
      fi 
   else
      let "i_jd = i_jd - 1"
 
      if [[ $i_jd -lt 10 ]]; then
         str_jd="00$i_jd"
      elif [[ $i_jd -lt 100 ]]; then
         str_jd="0$i_jd"
      else
         str_jd=$i_jd
      fi
 
   fi

   echo $str_yr $str_jd
   str_yymm="`date -d "01/01/${str_yr} +${str_jd} days -1 day" +%Y/%m/ `"

   asc_fn="${data_dir}${str_yymm}${str_yr}_${str_jd}_glsea.asc"
   echo "$asc_fn"
}

#-------------------------------------------------------------------------------


PATH=/usr/share/centrifydc/bin:$PATH

work_dir='/home/cw/opr/glsea3_b/'
#asc_dir='/home/cw/opr/glsea2/output/'
data_dir='/mnt/cwdata/p/m/lcd/'

web_dir='cw@cwweb.dmz:/var/www/html/real-earth/tif_img/'

husky_web_dir='cw@husky.dmz:/hump/cwdata/webdata/real-earth/tif_img/'

mk_geotif_exe='/home/cw/opr/glsea3_b/mk_geotif/mk_glsea_geotif.exe'

glsea_in="${work_dir}glsea.in"

echo "	"
echo "mk_geotif.sh ....."
date

cd $work_dir

data_stamp=`cat $glsea_in`
#echo $data_stamp
 
ago10_yr=`echo $data_stamp | head -1 | cut -c1-4`  
ago10_jd=`echo $data_stamp | head -1 | cut -c6-8`	# ago10_jd is 10 day ago
cur_yr=`echo $data_stamp | head -1 | cut -c10-13`
cur_jd=`echo $data_stamp | head -1 | cut -c15-17`       # cur_jd is today


echo $ago10_yr $ago10_jd
echo $cur_yr $cur_jd

##### processing 10 day ago asc file

mk_asc_fn ${ago10_yr} ${ago10_jd}

${mk_geotif_exe} ${asc_fn}

base_fn=${asc_fn##*/}
tif_fn="${base_fn%.*}.tif"
#echo ${tif_fn}

if [[ -e "${work_dir}${tif_fn}" ]]; then

  yr4=( $( echo ${tif_fn} | cut -c1-4 ))
  jd=( $( echo ${tif_fn} | cut -c6-8 ))
  echo $yr4 $jd
  yymm="`date -d "01/01/${yr4} +${jd} days -1 day" +%Y/%m/ `"
#  echo ${data_dir}${yymm}
#  yymmdd="`date -d "01/01/${yr4} +${jd} days -1 day" +%Y%m%d `"
  
#  realEarth_fn="GLERL-GLSEAimage_${yymmdd}_000000.tif"
#  echo $realEarth_fn
  
  
#  cp ${work_dir}${tif_fn} ${work_dir}${realEarth_fn}

#  bash re_upload.sh ${work_dir}${realEarth_fn}

  echo "Move ${work_dir}${tif_fn} to ${data_dir}${yymm}"
  mv ${work_dir}${tif_fn} ${data_dir}${yymm}

#  echo "rsync ${work_dir}${realEarth_fn} to ${web_dir}"
#  rsync --remove-source-files ${work_dir}${realEarth_fn} ${web_dir}

fi



##### processing current asc file

mk_asc_fn ${cur_yr} ${cur_jd}

${mk_geotif_exe} ${asc_fn}

base_fn=${asc_fn##*/}
tif_fn="${base_fn%.*}.tif"
#echo ${tif_fn}

if [[ -e "${work_dir}${tif_fn}" ]]; then

  yr4=( $( echo ${tif_fn} | cut -c1-4 ))
  jd=( $( echo ${tif_fn} | cut -c6-8 ))
  echo $yr4 $jd
  yymm="`date -d "01/01/${yr4} +${jd} days -1 day" +%Y/%m/ `"
#  echo ${data_dir}${yymm}
  yymmdd="`date -d "01/01/${yr4} +${jd} days -1 day" +%Y%m%d `"
  
  realEarth_fn="GLERL-GLSEAimage_${yymmdd}_000000.tif"
#  echo $realEarth_fn
  
  
  cp ${work_dir}${tif_fn} ${work_dir}${realEarth_fn}

  bash re_upload.sh ${work_dir}${realEarth_fn}

  echo "Move ${work_dir}${tif_fn} to ${data_dir}${yymm}"
  mv ${work_dir}${tif_fn} ${data_dir}${yymm}

  echo "rsync ${work_dir}${realEarth_fn}  ${web_dir}"
  rsync  ${work_dir}${realEarth_fn} ${web_dir}

  echo "rsync --remove-source-files -e 'ssh -p 7722' ${work_dir}${realEarth_fn} to ${husky_web_dir}"
  rsync --remove-source-files -e 'ssh -p 7722' ${work_dir}${realEarth_fn} ${husky_web_dir}

fi
