function consume(pair){pair.fst = 0; return pair.snd;}
function edge(array,index){return consume({$:'Tuple',fst:array,snd:array[index%array.length]});}
