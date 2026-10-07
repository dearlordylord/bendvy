// Erased structurally authored input: intentionally bypasses Schema.fragment validation.
import {Schema,Descriptor} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const c=(name)=>Descriptor.Component()(name);const r=(name)=>Descriptor.Resource()(name);
const e=(name)=>Descriptor.Event()(name);
const cases=[ [{},{}], [{components:{a:c('A')}},{components:{b:c('B')}}], [{components:{a:c('A')}},{components:{a:c('B')}}], [{components:{a:c('A')}},{components:{b:c('A')}}], [{},{components:{a:c('A'),b:c('A')}}], [{components:{a:c('A')}},{components:{a:c('A')}}], [{components:{a:c('A')}},{resources:{a:r('A')}}], [{components:{k:c('A')},events:{e1:e('E'),e2:e('E')}},{components:{k:c('B')}}], [{components:{k:c('A')}},{components:{k:c('B')},events:{e1:e('E'),e2:e('E')}}] ];
for(const root of ['Workshop','Other']) for(const [left,right] of cases.slice(-2)) {
 try {Schema.merge({components:{},resources:{},events:{},relations:{},...left},{components:{},resources:{},events:{},relations:{},...right});console.log(JSON.stringify({root,status:'accepted'}));}
 catch(e){console.log(JSON.stringify({root,status:'rejected',error:e.message}));}
}
