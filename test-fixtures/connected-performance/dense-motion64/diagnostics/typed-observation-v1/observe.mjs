import {inspect} from 'node:util';
import {typedObservationFold} from '../../../lifecycle-motion64/diagnostics/typed-observation-prototype-v1/reference.mjs';

export const versionLine='TYPED-OBSERVATION:v1:codec-fields\n';
export const mix=(acc,value)=>(Math.imul(acc,33)+value)>>>0;
export function natural(value,acc){
  if(!Number.isSafeInteger(value)||value<0||value>281474976710655)throw new TypeError('typed Nat outside pinned representation');
  do{acc=mix(acc,value%4294967296);value=Math.floor(value/4294967296);}while(value!==0);
  return mix(acc,0xffffffff);
}
function u32(value){if(!Number.isInteger(value)||value<0||value>0xffffffff)throw new TypeError('typed U32 outside representation');return value;}
const scalar=(value,acc)=>mix(acc,u32(value));
function sequence(values,fold,acc){acc=natural(values.length,acc);for(const value of values)acc=fold(value,acc);return acc;}
function four(values,acc){if(values.length!==4)throw new TypeError('typed Four arity');for(const v of values)acc=scalar(v,acc);return acc;}
function main(schema,v,acc){acc=four(schema==='Motion'?v.coordinates:v.levels,acc);return schema==='Motion'?scalar(v.frame,acc):scalar(v.class,scalar(v.reserve,acc));}
function aux(schema,v,acc){acc=four(schema==='Motion'?v.rates:v.layers,acc);if(schema==='Health')return scalar(v.grade,acc);if(typeof v.moving!=='boolean')throw new TypeError('typed moving Bool');return mix(acc,v.moving?1:0);}
function access(value,fold,acc){return value===null?mix(acc,1):fold(value,mix(acc,2));}
function row(schema,v,acc){acc=natural(v.rawId,acc);acc=main(schema,v.main,mix(acc,2));acc=access(v.aux,(v,a)=>aux(schema,v,a),acc);return access(v.flag,(v,a)=>scalar(v.group,a),acc);}
function reject(error,cause){process.stderr.write('Nonqualifying typed observation: '+String(error)+'\n'+inspect(cause,{depth:null,maxArrayLength:null,maxStringLength:null})+'\n');throw error;}
export function detachedCommon(value){
  try{
    const copy=structuredClone(value),active=new WeakSet(),done=new WeakSet();
    const freeze=v=>{if(v!==null&&typeof v==='object'){if(active.has(v))throw new TypeError('cyclic typed observation');if(done.has(v))return;active.add(v);for(const child of Object.values(v))freeze(child);active.delete(v);done.add(v);Object.freeze(v);}};
    freeze(copy);return copy;
  }catch(error){return reject(error,value);}
}
function errorFold(value,acc){
  const active=new WeakSet();
  const check=v=>{if(v===null||typeof v==='boolean'||typeof v==='string'||typeof v==='number')return;if(typeof v!=='object')throw new TypeError('unsupported typed error scalar');if(active.has(v))throw new TypeError('cyclic typed error');active.add(v);if(Array.isArray(v)){for(let i=0;i<v.length;i++){if(!Object.hasOwn(v,i))throw new TypeError('sparse typed error');check(v[i]);}}else{if(Object.getPrototypeOf(v)!==Object.prototype&&Object.getPrototypeOf(v)!==null)throw new TypeError('unsupported typed error object');for(const child of Object.values(v))check(child);}active.delete(v);};
  try{check(value);return typedObservationFold(value,acc);}catch(error){return reject(error,value);}
}
export function status(value,acc){if(value.ok===true)return mix(acc,0);if(value.ok!==false)throw new TypeError('typed tick result lacks Bool ok');return errorFold(value.error,mix(acc,3));}
export function typedCommonFold(schema,value){
  if(schema!=='Motion'&&schema!=='Health')throw new TypeError('unknown typed schema');
  let acc=sequence(value.rows,(v,a)=>row(schema,v,a),0);acc=four(value.ledger.totals,acc);acc=scalar(value.ledger.epoch,acc);
  acc=sequence(value.audits,(v,a)=>natural(v.updated,scalar(v.readsum,sequence(v.values,scalar,a))),acc);
  return sequence(value.statuses,status,acc);
}
