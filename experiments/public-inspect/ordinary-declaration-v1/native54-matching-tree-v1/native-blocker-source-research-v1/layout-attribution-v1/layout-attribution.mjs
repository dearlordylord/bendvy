let owner='<outside-definition>', rows=new Map(), overflow=0;
const MAX=8192;
export function context(name,work){const previous=owner;owner=name;try{return work();}finally{owner=previous;}}
export function timed(kind,work){const started=performance.now();try{return work();}finally{
 const elapsed=performance.now()-started;let row=rows.get(owner);
 if(!row){if(rows.size<MAX){row={definition:owner,metrics:{}};rows.set(owner,row);}else{overflow++;}}
 if(row){const metric=row.metrics[kind]??={calls:0,inclusiveMs:0,maximumMs:0};metric.calls++;metric.inclusiveMs+=elapsed;metric.maximumMs=Math.max(metric.maximumMs,elapsed);}
}}
export function snapshot(){return {scope:'Copied diagnostic only; inclusive nested durations not additive, instrumentation overhead unqualified; no type walks/cache changes',maximumDefinitions:MAX,overflowCalls:overflow,definitions:[...rows.values()]};}
export function current(){return owner;}
