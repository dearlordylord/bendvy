import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {makeWorld} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/internal/world.ts';
const P=Descriptor.Component()('Position');const G=Schema.bind(Schema.fragment({components:{P}}));
for(const kind of ['removed','despawned']){
 const w=makeWorld(G.schema,3),ordinal=w.ordinalOf(P),cursor={lastRun:0},ids=[],labels=new Map();
 w.registerRemovedReader(ordinal,cursor);w.registerDespawnedReader(cursor);
 w.advanceTick();for(let i=0;i<4;i++){const id=w.allocateEntity();ids.push(id);labels.set(id.value,i);w.spawnEntity(id,[[P,{x:i}]]);}
 w.advanceTick();w.advanceTick();for(const id of ids){if(kind==='removed')w.removeComponent(id.value,P);else w.destroyEntity(id.value);}
 w.advanceFrame();w.advanceFrame();
 const read=(name,last,reg=0)=>{const xs=kind==='removed'?w.removedSince(ordinal,last):w.despawnedSince(last);const lag=kind==='removed'?w.removedLagged(ordinal,last,reg):w.despawnedLagged(last,reg);const out=name+':'+xs.map(id=>{if(!labels.has(id))throw Error('unmapped');return labels.get(id)+',';}).join('')+':'+lag;return out;};
 const lines=[read('overflow',0),read('retry',0),read('caught-up',3),read('new-reader',0,3)].join('\n');
 if(kind==='removed')console.log(lines);else if(lines!==globalThis.removed)throw Error('removed/despawned mismatch');
 if(kind==='removed')globalThis.removed=lines;
}
