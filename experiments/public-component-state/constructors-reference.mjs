import {Descriptor} from '../../.references/bevy-ts/packages/core/src/index.ts';
const Phase=Descriptor.State('State/Phase',['ready','windup','active'],{transitions:{ready:['windup'],windup:['active','ready'],active:['ready']}});
const Mode=Descriptor.State('State/Mode',[0,1,2]);
const code=(d,raw)=>{const r=Descriptor.constructorOf(d).result(raw);return r.ok?d.states.indexOf(r.value):'invalid';};
console.log('phase|'+['ready','windup','active','sleeping',''].map(raw=>code(Phase,raw)).join(','));
console.log('mode|'+[0,1,2,3,9].map(raw=>code(Mode,raw)).join(','));
console.log('edges|'+Object.entries(Phase.transitions).flatMap(([from,tos])=>tos.map(to=>Phase.states.indexOf(from)+':'+Phase.states.indexOf(to))).join(','));
