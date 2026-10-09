// Closed selected32 observer, not a host Raw API or arbitrary schema serializer.
const some=value=>({$: 'Some',value}), none=()=>({$: 'None'});
const exact=(value,keys)=>{if(!value||typeof value!=='object'||Object.keys(value).sort().join('|')!==[...keys].sort().join('|'))throw Error('unexpected observer fields');};
export function raw(value){
 if(value===undefined||(value&&Object.keys(value).length===1&&value.undefined===true))return {$:'Missing'};
 if(value===null)return {$:'Null'};
 if(typeof value==='number'){if(!Number.isInteger(value)||value<0||value>0xffffffff)throw Error('outside selected U32 Raw domain');return {$:'Number',value};}
 if(typeof value==='string')return {$:'Text',value};
 if(typeof value==='boolean')return {$:'Boolean',value};
 if(Array.isArray(value))return {$:'Array',items:value.map(raw)};
 if(value&&typeof value==='object')return {$:'Object',fields:Object.entries(value).map(([name,value])=>({$:'Field',name,value:raw(value)}))};
 throw Error('outside selected Raw domain');
}
export function owner(value){exact(value,['value','original','sentinel','flags']);return {$:'View',raw:raw(value.value),original:raw(value.original),words:[...value.sentinel],flags:[...value.flags]};}
export function input(value){exact(value,['value','original','sentinel','flags']);return {$:'InputView',raw:raw(value.value),words:[...value.sentinel],flags:[...value.flags]};}
export function state(dump,receipts){
 const pending=receipts.map(entry=>({$:'Pending',kind:entry.kind,system:entry.system,target:entry.target,payload:entry.payload}));
 // Real debug commands independently bind receipt FIFO tags/origins; no closure reflection.
 const agrees=dump.pendingCommands.length===receipts.length&&dump.pendingCommands.every((entry,i)=>entry.tag===receipts[i].kind&&entry.system===receipts[i].system);
 return {$:'State',entities:dump.entities.map(entity=>{
  for(const key of Object.keys(entity.components))if(key!=='Value'&&key!=='Marker')throw Error('unobserved component');
  if(Object.keys(entity.relations).length)throw Error('unobserved relation');
  return {$:'Entity',id:entity.id,value:Object.hasOwn(entity.components,'Value')?some(owner(entity.components.Value)):none(),marker:Object.hasOwn(entity.components,'Marker')?some(entity.components.Marker):none()};
 }),resource:owner(dump.resources.Resource),pending,pendingCount:dump.pendingCommands.length,receiptCountMatches:agrees};
}
function checked(trace){
 if(!trace.checked.ok){
  const error=trace.checked.error;exact(error,['_tag','path','expected','actual']);if(error._tag!=='DecodeError')throw Error('unexpected construction error');
  return {$:'Refused',input:some(input(trace.incomingAfter)),error:{$:'Validation',error:{$:'Invalid',path:error.path,expected:error.expected,actual:raw(error.actual)}}};
 }
 let canonical;
 if(trace.operation==='spawn')canonical=trace.checked.value[1].value;
 else if(trace.operation==='resource')canonical=trace.after.resources.Resource.value;
 else canonical=trace.after.entities.find(entity=>entity.id===trace.target).components.Value.value;
 return {$:'Accepted',target:trace.operation==='resource'?none():some(trace.target),spawned:trace.operation==='spawn',canonical:raw(canonical)};
}
export function observe(trace){
 return {public:{$:'View',original:input(trace.original),before:state(trace.before,trace.beforeReceipts),committed:state(trace.after,trace.afterReceipts),barrier:state(trace.flushed,trace.flushedReceipts),checked:checked(trace)},ts:trace};
}
