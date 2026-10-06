function consume(pair){{const pair={fst:9}; return pair.fst;}}
function edge(array,index){return consume({$:'Tuple',fst:array,snd:array[index%array.length]});}
