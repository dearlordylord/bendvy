// Fresh public-API checkpoint: failed spawn publication versus consumed reservation.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
import {Descriptor, Fx, Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

const reference = '/workspace/formal-proofs/bendvy/.references/bevy-ts';
const manifest = JSON.parse(readFileSync(new URL('../../.references/sources.json',import.meta.url),'utf8'));
const referenceCommit = execFileSync('git',['-C',reference,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim();
assert.equal(referenceCommit,manifest.sources['bevy-ts'].commit);
const Payload = Descriptor.Component()('Payload');
const G = Schema.bind(Schema.fragment({components:{Payload}}));
const runtime = G.Runtime.make({services:G.Runtime.services(),resources:{}});
const ReadRows = G.Query({selection:{payload:G.Query.read(Payload)}});
const WriteRows = G.Query({selection:{payload:G.Query.write(Payload)}});
const ids = new Map();
const handles = new Map();
const actions = [];
const checkpoints = [];
let tailRuns = 0;
function reserve(commands,label,payload) {
  const id = commands.spawn(G.Command.spawn([Payload,payload]));
  const handle = G.Entity.handle(id);
  ids.set(label,id);
  handles.set(label,handle); // Intentional escaped reference; host state is not ECS rollback.
  actions.push({operation:'commands.spawn',label,payload,rawReservationId:id.value,rawHandleId:handle.value});
  return id;
}
const Bootstrap = G.System('Bootstrap',{},({commands})=>{reserve(commands,'seed',10);});
const A = G.System('A',{queries:{rows:WriteRows}},({queries,commands})=>{
  const seed = queries.rows.get(ids.get('seed'));
  assert.equal(seed.ok,true);
  seed.value.data.payload.update(value=>value+1);
  actions.push({operation:'A.write',seedId:ids.get('seed').value,readYourWrites:seed.value.data.payload.get()});
  reserve(commands,'earlier',20);
});
const B = G.System('B',{queries:{rows:WriteRows}},({queries,commands,lookup})=>{
  const seed = queries.rows.get(ids.get('seed'));
  assert.equal(seed.ok,true);
  seed.value.data.payload.set(99);
  actions.push({operation:'B.write',seedId:ids.get('seed').value,readYourWrites:seed.value.data.payload.get()});
  reserve(commands,'failed',30);
  const pending = lookup.getHandle(handles.get('failed'),ReadRows);
  assert.equal(pending.ok,false);
  actions.push({operation:'B.lookup-reserved',rawHandleId:handles.get('failed').value,result:pending.error._tag});
  return Fx.fail({code:7});
});
const Tail = G.System('Tail',{},()=>{tailRuns+=1;});
const Subsequent = G.System('Subsequent',{},({commands})=>{reserve(commands,'subsequent',40);});
function observe(name,priorResult) {
  let observation;
  const Observe = G.System('Observe:'+name,{queries:{rows:ReadRows}},({queries,lookup})=>{
    const rows = queries.rows.each().map(row=>({rawEntityId:row.entity.id.value,payload:row.data.payload.get()}));
    const lookups = {};
    for (const [label,handle] of handles) {
      const result = lookup.getHandle(handle,ReadRows);
      lookups[label] = result.ok ? {result:'Found',rawEntityId:result.value.entity.id.value,payload:result.value.data.payload.get()}
        : {result:result.error._tag,rawHandleId:handle.value};
    }
    observation = {name,rows,lookups,tailRuns,
      priorResult:priorResult.ok ? {result:'Success'} : {result:'Failure',system:priorResult.error.system,code:priorResult.error.error.code}};
  });
  assert.equal(runtime.tick(G.Schedule(Observe)).ok,true);
  checkpoints.push(observation);
  return observation;
}
let result = runtime.tick(G.Schedule(Bootstrap,G.Schedule.applyDeferred()));
assert.equal(result.ok,true);
const initial = observe('initial-live',result);
assert.deepEqual(initial.rows,[{rawEntityId:ids.get('seed').value,payload:10}]);
result = runtime.tick(G.Schedule(A,B,Tail));
assert.equal(result.ok,false);
assert.equal(result.error.system,'B');
assert.equal(result.error.error.code,7);
const failed = observe('after-A-commit-B-failure',result);
assert.deepEqual(failed.rows,[{rawEntityId:ids.get('seed').value,payload:11}]);
assert.equal(failed.lookups.earlier.result,'MissingEntity');
assert.equal(failed.lookups.failed.result,'MissingEntity');
assert.equal(tailRuns,0);
const pending = observe('empty-schedule-no-implicit-flush',runtime.tick(G.Schedule()));
assert.deepEqual(pending.rows,failed.rows);
assert.equal(pending.lookups.earlier.result,'MissingEntity');
const applied = observe('explicit-barrier-after-failure',runtime.tick(G.Schedule(G.Schedule.applyDeferred())));
assert.deepEqual(applied.rows,[{rawEntityId:ids.get('seed').value,payload:11},{rawEntityId:ids.get('earlier').value,payload:20}]);
assert.equal(applied.lookups.failed.result,'MissingEntity');
const afterReserve = observe('subsequent-reservation-pending',runtime.tick(G.Schedule(Subsequent)));
assert.equal(afterReserve.lookups.subsequent.result,'MissingEntity');
assert.deepEqual(afterReserve.rows,applied.rows);
const emptyAfterReserve = observe('subsequent-empty-schedule-no-implicit-flush',runtime.tick(G.Schedule()));
assert.deepEqual(emptyAfterReserve.rows,applied.rows);
assert.equal(emptyAfterReserve.lookups.subsequent.result,'MissingEntity');
const final = observe('subsequent-explicit-barrier',runtime.tick(G.Schedule(G.Schedule.applyDeferred())));
assert.deepEqual(final.rows,[...applied.rows,{rawEntityId:ids.get('subsequent').value,payload:40}]);
assert.equal(final.lookups.failed.result,'MissingEntity');
const rawIds = Object.fromEntries([...ids].map(([label,id])=>[label,id.value]));
assert.equal(new Set(Object.values(rawIds)).size,ids.size);
assert.equal(rawIds.failed,rawIds.earlier+1);
assert.equal(rawIds.subsequent,rawIds.failed+1);
assert.notEqual(rawIds.subsequent,handles.get('failed').value);
function sha256(path) { return createHash('sha256').update(readFileSync(path)).digest('hex'); }
const sourceFiles = ['index.ts','Entity.ts','Command.ts','System.ts','Runtime.ts','Schedule.ts','Schema.ts','Query.ts','Fx.ts','internal/world.ts'];
console.log(JSON.stringify({status:'PASS: fresh public TS allocation checkpoint',node:process.version,
  reference:{path:reference,commit:referenceCommit,files:Object.fromEntries(sourceFiles.map(name=>[name,sha256(reference+'/packages/core/src/'+name)]))},
  adapterSha256:sha256(fileURLToPath(import.meta.url)),rawReservationIds:rawIds,
  conclusion:{earlierCommitRetained:true,failedComponentWriteRestored:true,failedSpawnDiscarded:true,
    failedReservationConsumed:true,escapedFailedHandleNeverReissued:true,explicitBarrierRequired:true,tailSkipped:true},
  actions,checkpoints,limits:{runtimeSeconds:5,scope:'One schema and scalar component; reference prerequisite only. No Bend integration or universal allocator policy claim.'}},null,2));
