#!/bin/bash

num=295

while [ $num -lt 334 ]; do 
    /bin/bash /home/cw/opr/glsea3_b/mk_glsea3_b.sh
    let num=num+1
    echo "working on $num &&&&&&"
done
