// Supplementary INTERNAL C3 diagnostic: never public capacity configurability.
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {make as makeStreams} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/internal/streams.ts';
import {makeWorld} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/internal/world.ts';
const reference='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const commit='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334';
const manifest='/workspace/formal-proofs/bendvy/.references/sources.json';
const self=fileURLToPath(import.meta.url);
const sha=p=>createHash('sha256').update(readFileSync(p)).digest('hex');
assert.equal(JSON.parse(readFileSync(manifest,'utf8')).sources['bevy-ts'].commit,commit);
assert.equal(execFileSync('git',['-C',reference,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim(),commit);
if(process.argv[2]==='--all'){
  const results=[];
  for(const args of [['streams'],['Motion','removed'],['Motion','despawned'],['Health','removed'],['Health','despawned']]){
    const started=performance.now();
    try{results.push({...JSON.parse(execFileSync(process.execPath,[self,...args],{timeout:5000,encoding:'utf8',maxBuffer:1024*1024})),wallMilliseconds:performance.now()-started});}
    catch(error){results.push({args,status:error.code==='ETIMEDOUT'?'UNRESOLVED_TIMEOUT':'FAILED_EXECUTION',wallMilliseconds:performance.now()-started,error:String(error),stdout:String(error.stdout??''),stderr:String(error.stderr??'')});}
  }
  const evidence={provenance:'supplementary internal API only; not public runtime capacity coverage',node:process.version,reference:{commit,manifestSha256:sha(manifest),files:Object.fromEntries(['internal/streams.ts','internal/world.ts','Schema.ts','Descriptor.ts'].map(f=>[f,sha(reference+'/packages/core/src/'+f)]))},adapterSha256:sha(self),traceSha256:sha(new URL('../../docs/design/s-integrate-trace.md',import.meta.url)),limitSecondsPerInvocation:5,results};
  writeFileSync(new URL('internal-retention-evidence.json',import.meta.url),JSON.stringify(evidence,null,2)+'\n');
  console.log(JSON.stringify(results.map(({schema,lane,status,wallMilliseconds,firstDifference})=>({schema,lane,status,wallMilliseconds,firstDifference})),null,2));
  process.exit(results.every(r=>r.status==='PASS')?0:1);
}
const schema=process.argv[2],lane=schema==='streams'?'streams':process.argv[3];
const observations=[],operations=[];let firstDifference=null;
const check=(name,actual,expected)=>{try{assert.deepEqual(actual,expected);}catch{if(!firstDifference)firstDifference={name,actual,expected};}};
try{
  if(lane==='streams'){
    const key=Symbol('Ping'),s=makeStreams(3),fast={streamLastRun:0},slow={streamLastRun:0};
    s.register(key,fast);s.register(key,slow);
    const read=(name,since,registeredAt,values,lagged)=>{const actual={values:[...s.since(key,since)],lagged:s.lagged(key,since,registeredAt)};check(name,actual,{values,lagged});observations.push({name,api:'Streams.since/lagged',since,registeredAt,...actual});};
    s.append(key,1,[1,2]);s.append(key,3,[3,4]);s.trim(0);operations.push({api:'Streams.make/register/append/trim',capacity:3,batches:[{tick:1,values:[1,2]},{tick:3,values:[3,4]}],trimBoundary:0,heldBoundaries:[0,0]});
    read('old-cursor0',0,0,[3,4],true);read('cursor2',2,0,[3,4],false);read('repeat-old-cursor0',0,0,[3,4],true);
    s.append(key,5,[5,6,7,8]);s.trim(0);operations.push({api:'Streams.append/trim',tick:5,values:[5,6,7,8],trimBoundary:0});
    read('oversized-old0',0,0,[],true);read('oversized-cursor2',2,0,[],true);read('oversized-cursor4',4,0,[],true);read('oversized-late-registration',0,5,[],false);
    const zero=makeStreams(0);zero.register(key,{streamLastRun:0});zero.append(key,1,[1]);zero.trim(0);
    const actual={values:[...zero.since(key,0)],lagged:zero.lagged(key,0,0)};check('capacity0',actual,{values:[],lagged:true});observations.push({name:'capacity0',api:'Streams.make(0)/register/append/trim/since/lagged',tick:1,trimBoundary:0,...actual});
  }else{
    assert.ok(['Motion','Health'].includes(schema));assert.ok(['removed','despawned'].includes(lane));
    const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals');
    const G=Schema.bind(Schema.fragment({components:{Main}}));
    const w=makeWorld(G.schema,3),ordinal=w.ordinalOf(Main),cursor={lastRun:0},ids=[];
    w.registerRemovedReader(ordinal,cursor);w.registerDespawnedReader(cursor);
    w.advanceTick();
    for(let i=0;i<4;i++){
      const id=w.allocateEntity();ids.push(id);
      const x=10+i,value=schema==='Motion'?{coordinates:[x,x+1,x+2,x+3],frame:7}:{levels:[x,x+1,x+2,x+3],reserve:9,class:2};
      w.spawnEntity(id,[[Main,value]]);
      check('full-internal-seed-'+i,w.records.get(id.value).values[ordinal],value);
    }
    const rawIds=ids.map(id=>id.value);check('actual-allocated-ids',rawIds,[1,2,3,4]);
    w.advanceTick();w.advanceTick();const deletionTick=w.currentTick();
    for(const id of ids)if(lane==='removed')w.removeComponent(id.value,Main);else w.destroyEntity(id.value);
    check('same-deletion-tick',w.currentTick(),deletionTick);
    const before={removed:[...w.removedSince(ordinal,0)],despawned:[...w.despawnedSince(0)]};
    check('before-frame-trim',before,{removed:rawIds,despawned:lane==='despawned'?rawIds:[]});
    operations.push({api:'makeWorld(schema,3)/registerRemovedReader/registerDespawnedReader/allocateEntity/spawnEntity/'+(lane==='removed'?'removeComponent':'destroyEntity'),capacity:3,actualRawReservationIds:rawIds,heldReaderLastRun:cursor.lastRun,deletionTick,beforeFrameTrim:before});
    w.advanceFrame();w.advanceFrame();operations.push({api:'World.advanceFrame',calls:2,currentTick:w.currentTick()});
    for(const [name,since,registeredAt] of [['old',0,0],['repeat-old',0,0],['caught-up',deletionTick,0],['late-registration',0,deletionTick]]){
      const actual={removed:[...w.removedSince(ordinal,since)],despawned:[...w.despawnedSince(since)],removedLagged:w.removedLagged(ordinal,since,registeredAt),despawnedLagged:w.despawnedLagged(since,registeredAt)};
      const retained=since<deletionTick?rawIds.slice(1):[],missed=since<deletionTick&&registeredAt<deletionTick;
      check(name,actual,{removed:retained,despawned:lane==='despawned'?retained:[],removedLagged:missed,despawnedLagged:lane==='despawned'&&missed});
      observations.push({name,api:'World.removedSince/despawnedSince/removedLagged/despawnedLagged',since,registeredAt,...actual});
    }
    check('holder-not-advanced',cursor.lastRun,0);
  }
}catch(error){if(!firstDifference)firstDifference={name:'execution',error:String(error),stack:error.stack};}
console.log(JSON.stringify({schema,lane,status:firstDifference?'FAIL':'PASS',firstDifference,provenance:'internal supplementary diagnostic; no public dispatcher or capacity API claim',operations,observations}));
