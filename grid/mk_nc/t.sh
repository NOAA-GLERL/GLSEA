mn=( '07' '08' '09' '10')



for m in ${mn[@]}; do
  echo $m
  if [[ $m != '07' ]] && [[ $m != '08' ]] && [[ $m != '09' ]] && [[ $m != '10' ]]; then
     echo ok
  fi
done
