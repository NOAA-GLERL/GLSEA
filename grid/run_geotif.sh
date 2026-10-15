begin_n=32
end_n=176

year=2024

for i in `seq ${begin_n} ${end_n}`; do
   echo $i

   if [[ $i -lt 10 ]]; then
         str_i="00$i"
   elif [[ $i -lt 100 ]]; then
         str_i="0$i"
   else
         str_i=$i
   fi

   bash mk_geotif_manual.sh $str_i $year
done

