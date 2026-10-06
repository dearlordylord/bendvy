function consume(pair){return pair;}
function edge(array,index){return consume({$:'Tuple',fst:array,snd:array[index%array.length]});}
