// Concrete field ownership, capture-once and exception-order witness.
const events=[];
let failPrefix=false, failRead=false, raw=11;
function prefix(){events.push('prefix');if(failPrefix)throw Error('prefix-failure');return 'tag';}
function consume(tag,pair){
  const owner=pair['fst'];
  const old=pair['snd'];
  events.push('receiver');
  owner[0]=old+1;
  const now=owner[0];
  return {tag,old,now,rest:owner.slice(1)};
}
function edge(array,index){return consume(prefix(),{$:'Tuple',fst:array,snd:array[index%array.length]});}
const array=[0,12,13,14];
Object.defineProperty(array,'0',{get(){events.push('read');if(failRead)throw Error('read-failure');return raw;},set(value){events.push('write');raw=value;}});
const retained=array.slice();events.length=0;
const result=edge(array,0);
console.log(JSON.stringify({kind:'retained-fields',result,retained,events:[...events]}));
events.length=0;failPrefix=true;
try{edge(array,0);}catch(e){console.log(JSON.stringify({kind:'prefix-throw',error:e.message,events:[...events]}));}
events.length=0;failPrefix=false;failRead=true;
try{edge(array,0);}catch(e){console.log(JSON.stringify({kind:'read-throw',error:e.message,events:[...events]}));}
