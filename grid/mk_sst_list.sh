#!/bin/bash 

# Making a file containing sst file names and 
# file containg cm file names

echo "$0 ..."

work_dir='/home/cw/opr/glsea3_b/'
data_dir='/mnt/cwdata/p/p/all/'
output_dir="${work_dir}output"

count_days=20

fn_list_fn="${work_dir}fn_list"
glsea_in="${work_dir}glsea.in"

data_stamp=`cat $glsea_in`
echo $data_stamp
 
 
middle_yr=`echo $data_stamp | head -1 | cut -c1-4`
middle_jd=`echo $data_stamp | head -1 | cut -c6-8`

middle_jd_n=`echo $middle_jd 0 | awk '{print $1 + $2}'`  # form 008 to 8

echo $middle_yr $middle_jd
echo liu
echo $middle_jd_n

if [[ $middle_jd_n -gt 10 ]]; then
 
   first_jd=$(( $middle_jd_n - 10 ))
   first_yr=$(( $middle_yr ))
   num_yr=$middle_yr
else

   num_yr=$(( $middle_yr - 1 ))
 
   if [[ $(($num_yr % 4)) -eq 0 ]]; then
       
      first_jd=$(( 366 + $middle_jd_n - 10 ))            
   else
 
      first_jd=$(( 365 + $middle_jd_n - 10 ))      
   fi 

echo $middle_jd  $middle_jd_n   
echo $first_jd
   first_yr=$num_yr
fi


str_yr=$first_yr
str_jd=$first_jd

echo $str_yr " " $str_jd
echo aa

if [[ -e $fn_list_fn ]]; then
   rm $fn_list_fn
fi


str_jd_n=`echo $str_jd 0 | awk '{print $1 + $2 }'`     # from 008 to 8

num_jd=$str_jd_n  
num=0
while [[ $num -le $count_days ]]; do
         
   if [[ $(($num_yr % 4)) -eq 0 ]]; then    # leap year
      if [[ $num_jd -gt 366 ]]; then
         num_jd=$(( $num_jd % 366 ))                
         num_yr=$(( $num_yr + 1 ))
         str_yr=$num_yr          
      fi
   else
      if [[ $num_jd -gt 365 ]]; then         
         num_jd=$(( $num_jd % 365 ))                
         num_yr=$(( $num_yr + 1 ))
         str_yr=$num_yr       
      fi   
   fi 
       
   if [[ $num_jd -lt 10 ]]; then
       str_jd="00$num_jd"
   elif [[ $num_jd -lt 100 ]]; then
       str_jd="0$num_jd"
   else
      str_jd=$num_jd
   fi
    
    
   #sst_list=`ls ${data_dir}${str_yr}_${str_jd}_*_gr_d1.raw ${data_dir}${str_yr}_${str_jd}_*_gr_s7.raw`    
yr_mn="`date -d "01/01/${str_yr} +${str_jd} days -1 day" +%Y/%m/ `"
yr_mn_dy="`date -d "01/01/${str_yr} +${str_jd} days -1 day" +%Y%m%d `"
echo ${yr_mn}
echo ${yr_mn_dy}
echo song
echo ${data_dir}${yr_mn}gl_${yr_mn_dy}

echo ${data_dir}${str_yr}_${str_jd}
   
   sst_list=( $( ls  ${data_dir}${yr_mn}gl_${yr_mn_dy}*.hdf 2> /dev/null ) )    

   if [[ ${#sst_list[@]} -ne 0 ]]; then
      for sst_fn in  ${sst_list[@]};  do
         echo $sst_fn
     
         echo $sst_fn >> $fn_list_fn
     
      done #forech
   fi 
   
   num=$(( $num + 1 ))             # double parentheses no space
   
   num_yr=$str_yr 

   str_jd_n=`echo $str_jd 0 | awk '{print $1 + $2 }'`     # from 008 to 8
   num_jd=$(( $str_jd_n + 1 ))

done #while
echo $num

echo "Done $0 ..."
