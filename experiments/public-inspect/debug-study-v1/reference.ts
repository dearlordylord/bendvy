import { Descriptor, Schema } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import { normalizeLimit, normalizedDigits } from './normalize-limit.js';
const Left = Descriptor.Component<readonly number[]>()('left');
const Right = Descriptor.Component<readonly number[]>()('right');
const Resource = Descriptor.Resource<readonly number[]>()('resource');
const Game = Schema.bind(Schema.fragment({components:{Left,Right},resources:{resource:Resource}}));
const runtime = Game.Runtime.make({resources:{resource:[19,23]},debug:true});
const Setup = Game.System('setup',{},({commands}) => {
  for (let id=1;id<=10;id++) {
    const left = ({1:[7,9],3:[11],10:[13,17]} as Record<number,number[]>)[id];
    const right = ({3:[29],10:[31]} as Record<number,number[]>)[id];
    commands.spawn(left && right ? Game.Command.spawn([Left,left],[Right,right]) : left ? Game.Command.spawn([Left,left]) : Game.Command.spawn());
  }
});
const All = Game.Query({selection:{}});
const Cleanup = Game.System('cleanup',{queries:{all:All}},({queries,commands})=>{for(const row of queries.all.each())if([2,4,5,7,8,9].includes(row.entity.id.value))commands.despawn(row.entity.id);});
const Pending = Game.System('pending',{},({commands})=>{commands.spawn(Game.Command.spawn());commands.spawn(Game.Command.spawn());});
runtime.tick(Game.Schedule(Setup,Game.Schedule.applyDeferred()));
runtime.tick(Game.Schedule(Cleanup,Game.Schedule.applyDeferred()));
runtime.tick(Game.Schedule(Pending));
const cases = [
 ['disabled',undefined,undefined,undefined],['omitted',undefined,undefined,undefined],['emptyWhitelist',[],undefined,undefined],['emptyWith',undefined,[],undefined],['conjunctionTag',undefined,[Right],undefined],['whitelistUnsortedDuplicatesMissing',[10,3,10,0,77],undefined,undefined],['zero',undefined,undefined,0],['negativeZero',undefined,undefined,-0],['negativeFinite',undefined,undefined,-1.5],['negativeInfinity',undefined,undefined,-Infinity],['fraction0.25',undefined,undefined,.25],['fraction1.5WithTag',undefined,[Right],1.5],['nan',undefined,undefined,NaN],['positiveInfinity',undefined,undefined,Infinity],['finite2Power53',undefined,undefined,2**53]
] as const;
const idsByName:Record<string,number[]>={disabled:[1,3,6,10],omitted:[1,3,6,10],emptyWhitelist:[],emptyWith:[1,3,6,10],conjunctionTag:[3,10],whitelistUnsortedDuplicatesMissing:[3,10],zero:[],negativeZero:[],negativeFinite:[],negativeInfinity:[], 'fraction0.25':[1],'fraction1.5WithTag':[3,10],nan:[1,3,6,10],positiveInfinity:[1,3,6,10],finite2Power53:[1,3,6,10]};
const entityOracle:Record<number,unknown>={1:{id:1,components:{left:[7,9]},relations:{}},3:{id:3,components:{left:[11],right:[29]},relations:{}},6:{id:6,components:{},relations:{}},10:{id:10,components:{left:[13,17],right:[31]},relations:{}}};
const normalizedOracle:Record<string,unknown>={disabled:{tag:'Unbounded'},omitted:{tag:'Unbounded'},emptyWhitelist:{tag:'Unbounded'},emptyWith:{tag:'Unbounded'},conjunctionTag:{tag:'Unbounded'},whitelistUnsortedDuplicatesMissing:{tag:'Unbounded'},zero:{tag:'BoundedNat',count:'0'},negativeZero:{tag:'BoundedNat',count:'0'},negativeFinite:{tag:'BoundedNat',count:'0'},negativeInfinity:{tag:'BoundedNat',count:'0'},'fraction0.25':{tag:'BoundedNat',count:'1'},'fraction1.5WithTag':{tag:'BoundedNat',count:'2'},nan:{tag:'Unbounded'},positiveInfinity:{tag:'Unbounded'},finite2Power53:{tag:'BoundedNat',count:'9007199254740992'}};
const digitOracle:Record<string,unknown>={zero:{tag:"BoundedDecimal",digits:[]},negativeZero:{tag:"BoundedDecimal",digits:[]},negativeFinite:{tag:"BoundedDecimal",digits:[]},negativeInfinity:{tag:"BoundedDecimal",digits:[]},"fraction0.25":{tag:"BoundedDecimal",digits:[1]},"fraction1.5WithTag":{tag:"BoundedDecimal",digits:[2]},finite2Power53:{tag:"BoundedDecimal",digits:[2,9,9,0,4,7,4,5,2,9,9,1,7,0,0,9]}};
const baseline=JSON.stringify(runtime.debug.dump());
for(const [name,entities,withComponents,limit] of cases){
 const before=runtime.debug.dump();
 // adapter-disabled means no dump call here; debug:true runtime stays enabled.
 const observed=name==='disabled'?undefined:runtime.debug.dump({entities,with:withComponents,limit});
 const after=runtime.debug.dump();
 const normalized=normalizeLimit(limit);
 const digits=normalizedDigits(normalized);
 if(JSON.stringify(digits)!==JSON.stringify(digitOracle[name]??{tag:"Unbounded"}))throw new Error(name+": digit transfer oracle");
 if(JSON.stringify(normalized)!==JSON.stringify(normalizedOracle[name]))throw new Error(name+': normalized-limit oracle');
 if(JSON.stringify(before)!==baseline || JSON.stringify(after)!==baseline)throw new Error(name+': noninterference');
 if(observed && (JSON.stringify(observed.entities)!==JSON.stringify(idsByName[name].map(id=>entityOracle[id])) || observed.entityCount!==4 || JSON.stringify(observed.resources)!=='{"resource":[19,23]}'))throw new Error(name+': full scoped oracle');
 // Every raw pinned-runtime field is retained separately from scoped comparison.
 console.log(JSON.stringify({name,control:name==='disabled'?'adapter-disabled-no-call':'actual-debug-dump',normalized,digits,observed:observed??'Disabled',before,after}));
}
console.log(JSON.stringify({name:'foreignSameIdGet',scope:'Bend MissingEntity boundary; TS debug only local numeric IDs',before:runtime.debug.dump(),after:runtime.debug.dump()}));
