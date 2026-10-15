import {Schema,Descriptor,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

// Public TS operations only. Affine ownership and physical Bend clocks remain
// separate; active TS condition skips intentionally discard unread messages.
const observations=[];
for (const root of ['ReadersAlpha','ReadersBeta']) {
  const Stock=Descriptor.Component()('Stock');
  const Ping=Descriptor.Event()('Ping');
  const {relation:Parent}=Descriptor.Hierarchy('Parent','Children');
  const G=Schema.bind(Schema.fragment({components:{Stock},events:{Ping},relations:{Parent}}),Schema.defineRoot(root));
  const runtime=G.Runtime.make({debug:true});
  const plain=G.Query({selection:{stock:G.Query.read(Stock)}});
  const added=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.added(Stock)]});
  const changed=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.changed(Stock)]});
  let source,target,doomed,phase='setup',enabled=true,failSlow=false;
  let deliveries=[];
  const encode=f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error});
  const condition=G.Condition.check('enabled',{},()=>enabled);
  const makeReader=(name,when)=>G.System(name,{
    queries:{plain,added,changed},events:{ping:G.System.readEvent(Ping),attempted:G.System.writeEvent(Ping)},
    removed:{stock:G.System.readRemoved(Stock)},relationFailures:{parent:G.System.readRelationFailures(Parent)},when
  },ctx=>{
    deliveries.push({phase,reader:name,rows:ctx.queries.plain.each().map(row=>({id:row.entity.id.value,payload:row.data.stock.get()})),
      added:ctx.queries.added.each().map(row=>row.entity.id.value),changed:ctx.queries.changed.each().map(row=>row.entity.id.value),
      removed:ctx.removed.stock.all().map(id=>id.value),events:[...ctx.events.ping.all()],eventLag:ctx.events.ping.lagged(),
      failures:ctx.relationFailures.parent.all().map(encode),relationLag:ctx.relationFailures.parent.lagged()});
    if(name==='slow'&&failSlow){ctx.events.attempted.emit(999);return Fx.fail(77);}
  });
  const fast=makeReader('fast',[condition]),slow=makeReader('slow',[]);
  const flush=G.Schedule.applyDeferred();
  const capture=(operation,result)=>{observations.push({root,phase,operation,ok:result.ok,deliveries:structuredClone(deliveries),world:structuredClone(runtime.debug.dump()),streams:structuredClone(runtime.debug.streams())});deliveries=[];};
  const step=(label,...systems)=>{phase=label;const result=runtime.tick(G.Schedule(...systems));capture(label,result);return result;};
  step('seed',G.System('seed',{},({commands})=>{source=commands.spawn(G.Command.spawn([Stock,42]));target=commands.spawn(G.Command.spawn([Stock,43]));}),flush);
  step('warm-readers',fast,slow);
  step('remove-target',G.System('remove-target',{},({commands})=>{commands.remove(target,Stock);}),flush);
  step('read-removed',fast,slow);
  step('reinsert-target',G.System('reinsert-target',{},({commands})=>{commands.insert(target,[Stock,44]);}),flush);
  step('read-reinserted',fast,slow);
  step('spawn-doomed',G.System('spawn-doomed',{},({commands})=>{doomed=commands.spawn(G.Command.spawn());}),flush);
  step('despawn-doomed',G.System('despawn-doomed',{},({commands})=>{commands.despawn(doomed);}),flush);
  step('writer-queued',G.System('writer',{events:{ping:G.System.writeEvent(Ping)}},({commands,events})=>{commands.relate(source,Parent,source);commands.relate(source,Parent,doomed);events.ping.emit(31);events.ping.emit(32);}));
  step('writer-published',flush);
  enabled=false;step('fast-active-skip',fast);
  failSlow=true;step('slow-failed',slow);
  failSlow=false;step('slow-retry',slow);
  enabled=true;step('fast-success',fast);
  step('fast-repeat',fast);
  step('slow-repeat',slow);
}
console.log(JSON.stringify({scope:'Public actual-operation shared scenario; backend-specific complete debug retained, no affine/clock equality claim',observations}));
