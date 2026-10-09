// Full common output is serialized inside the proposed interval. The complete
// TS debug/owner supplement remains available through observation-reference.
import {run as observe} from './observation-reference.mjs';
export function run(){return JSON.stringify(observe().map(row=>({$:row.$,operation:row.operation,name:row.name,value:row.value.public})));}
