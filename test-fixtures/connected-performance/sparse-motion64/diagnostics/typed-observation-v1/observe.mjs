import {mix,natural,status,detachedCommon,versionLine} from '../../../dense-motion64/diagnostics/typed-observation-v1/observe.mjs';
export {detachedCommon,versionLine};
const scalar=(value,acc)=>{if(!Number.isInteger(value)||value<0||value>0xffffffff)throw new TypeError('typed U32 outside representation');return mix(acc,value);};
function sequence(values,fold,acc){acc=natural(values.length,acc);for(const value of values)acc=fold(value,acc);return acc;}
function four(values,acc){if(values.length!==4)throw new TypeError('typed Four arity');for(const value of values)acc=scalar(value,acc);return acc;}
function row(value,acc){acc=natural(value.rawId,acc);acc=scalar(value.main.frame,four(value.main.coordinates,mix(acc,2)));if(value.aux===null)acc=mix(acc,1);else{if(typeof value.aux.moving!=='boolean')throw new TypeError('typed moving Bool');acc=mix(four(value.aux.rates,mix(acc,2)),value.aux.moving?1:0);}return value.flag===null?mix(acc,1):scalar(value.flag.group,mix(acc,2));}
function scan(value,acc){return scalar(value.score,sequence(value.included,row,sequence(value.rows,row,acc)));}
export function typedCommonFold(schema,value){
 if(schema!=='Motion')throw new TypeError('Sparse typed schema');
 let acc=sequence(value.rows,row,0);acc=scalar(value.ledger.epoch,four(value.ledger.totals,acc));
 acc=sequence(value.audits,(v,a)=>{a=natural(v.updated,scalar(v.readsum,sequence(v.values,scalar,a)));a=scan(v.scans.absent,scan(v.scans.present,scan(v.scans.all,a)));return scalar(v.cumulative,scalar(v.scans.weighted,a));},acc);
 return scalar(value.cumulative,sequence(value.statuses,status,acc));
}
