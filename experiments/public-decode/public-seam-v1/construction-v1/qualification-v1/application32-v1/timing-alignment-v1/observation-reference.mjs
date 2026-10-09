// No execution on import; existing timer/capture may later invoke this complete32 lifecycle.
import {run as actual} from './reference.mjs';
import {observe} from './public.mjs';
export function run(){return actual().map(trace=>({$:trace.root,operation:trace.operation,name:trace.name,value:observe(trace)}));}
