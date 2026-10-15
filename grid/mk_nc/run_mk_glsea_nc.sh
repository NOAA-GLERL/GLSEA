yr=2022

mns=('01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12')
#mns=('01' '02' '03' '04' '05' '06' )
mns=('11')

for mn in ${mns[@]}; do
   echo $mn

   bash mk_glsea_nc_manual.sh $yr $mn 
   #bash mk_glsea_nc.sh $yr $mn
    
done
