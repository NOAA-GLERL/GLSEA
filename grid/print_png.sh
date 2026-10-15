#!/usr/bin/bash  

work_dir='/home/cw/opr/glsea2/'
data_dir='/mnt/cwdata/p/m/lcb/'

cur_yr=`date +%Y`
cur_jd=`date +%j`

cur_yymm="`date -d "01/01/${cur_yr} +${cur_jd} days -2 day" +%Y/%m/ `"     # 2013/05/

date
echo "$0 ..."

fn=`ls ${data_dir}${cur_yymm}*.png | tail -1`

echo "printing $fn"

pnm_fn='/tmp/glsea.pnm'
ps_fn='/tmp/glsea.ps'

/usr/bin/pngtopnm $fn > ${pnm_fn}
/usr/bin/pnmtops -scale=0.7 ${pnm_fn} > ${ps_fn}

/usr/bin/lp -d Color-501 ${ps_fn}

 
