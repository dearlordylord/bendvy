const labels=['activate-fast','activate-slow','activate-second','publish','fast-read','publish-abort','second-failed','second-retry','publish-retry','slow-failed','slow-retry','fast-read-again','second-read-again','frame','frame-again','fast-empty','second-empty'];
let active=false,ready=false,start,elapsed=0n,count=0,chunks=[],bytes=0,digest=2166136261;
const require=ok=>{if(!ok)throw Error('interval timer protocol failure');};
export function reset(){require(!active&&!ready);ready=true;elapsed=0n;count=0;chunks=[];bytes=0;digest=2166136261;}
export function begin(label){require(ready&&!active&&label===labels[count]);start=process.hrtime.bigint();active=true;}
export function end(){require(ready&&active);elapsed+=process.hrtime.bigint()-start;active=false;count++;}
export function capture(text){require(ready&&!active);if(typeof text!=='string')throw Error('full output must be materialized');const b=Buffer.from(text+'\n','utf8');for(const x of b)digest=Math.imul(digest^x,16777619)>>>0;bytes+=b.length;chunks.push(b);}
export function finish(){require(ready&&!active&&count===17);process.stderr.write(JSON.stringify({elapsedNs:elapsed.toString(),bytes,digest,intervals:count})+'\n');for(const b of chunks)process.stdout.write(b);ready=false;chunks=[];}
