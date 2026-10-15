function match_k, a, b

   k_arr = intarr(100) -1    ; cn hold 60 buoys infor
 
   n = 0 
   for i=0, n_elements(a)-1 do begin

      for j=0, n_elements(b)-1 do begin
  
         if ( a(i) eq b(j) ) then begin
            ;print,  a(i)
           
            if ( n lt n_elements(k_arr) ) then k_arr[n] = a(i)

            n++
         endif 
      endfor
   endfor
   return, k_arr
end

a = [3,5,7,9,11] & b = [5,6,7,8,9,10]

c = match_k(a,b)
print,c
end

