function run_clo(j) {
  const f = (x) => run_loop(j(x));
  f.j = j;
  j.f = f;
  return f;
}
function run_loop(x) {throw "provider must not execute";}
function mainRead(owner,token) {throw "read must not execute";}
function auxRead(owner) {throw "aux read must not execute";}
function client(get,ag,handle,flag,owner,aux) { return {$:"Tuple",fst:owner,snd:{$:"Tuple",fst:aux,snd:handle}}; }
const log=[];let stop=false;
function observe(label,value) { log.push(label);if(stop&&label==="flag")throw "expected";return value; }
function caller(owner,aux,handle,run_clo) {
 return client(run_clo((x)=>{return run_clo((y)=>{return mainRead(x,y);});}),run_clo((z)=>{return auxRead(z);}),observe("handle",handle),observe("flag",null),observe("owner",owner),observe("aux",aux));
}
const view=Object.freeze({kind:"Data",a:11,b:12,c:13,d:14,stamp:15});
const raw={kind:"Type",a:21,b:22,c:23,d:24,stamp:25};const owner={kind:"Type",main:[raw],ledger:{kind:"Type",a:31,b:32,c:33,d:34,stamp:35},view};const aux={kind:"Type",a:41,b:42,c:43,d:44,stamp:45};const handle={namespace:7,id:1};const got=caller(owner,aux,handle);stop=true;try {caller(owner,aux,handle);}catch(e){if(e!=="expected")throw e;}
console.log(JSON.stringify({owner:got.fst,aux:got.snd.fst,handle:got.snd.snd,sameOwner:got.fst===owner,sameAux:got.snd.fst===aux,sameHandle:got.snd.snd===handle,view,raw,log}));
