function consume(pair){return pair.fst;}
function edge(array,index){return consume({$:'Tuple',fst:array,snd:array[index%array.length]});}
consume = x=>x;
