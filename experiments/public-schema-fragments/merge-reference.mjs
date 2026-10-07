import {Schema,Descriptor} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const c=(name)=>Descriptor.Component()(name);const r=(name)=>Descriptor.Resource()(name);
const e=(name)=>Descriptor.Event()(name);
const cases=[ [{},{}], [{components:{a:c('A')}},{components:{b:c('B')}}], [{components:{a:c('A')}},{components:{a:c('B')}}], [{components:{a:c('A')}},{components:{b:c('A')}}], [{},{components:{a:c('A'),b:c('A')}}], [{components:{a:c('A')}},{components:{a:c('A')}}], [{components:{a:c('A')}},{resources:{a:r('A')}}], [{components:{k:c('A')},events:{e1:e('E'),e2:e('E')}},{components:{k:c('B')}}], [{components:{k:c('A')}},{components:{k:c('B')},events:{e1:e('E'),e2:e('E')}}] ];
for(const root of ['Workshop','Other']) for(const [left,right] of cases) {
 try {Schema.merge(Schema.fragment(left),Schema.fragment(right));console.log('ok:10,99:20,99');}
 catch(e){const s=e.message;console.log((s.startsWith('Duplicate schema key: ')?'key:'+s.slice(22):'name:'+s.slice(27))+':10,99:20,99');}
}
