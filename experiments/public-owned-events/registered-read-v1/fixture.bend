import Base
import log.bend as Log
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as Payload
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

type Schema is Data: Schema{}
type PacketView is Data: PacketView{key:U32,cells:List<&2,U32>}
type Request is Data: Request{name:String,fail:Bool}
type View is Data: View{name:String,keys:List<&2,U32>,packets:List<&2,PacketView>,lagged:Bool,errors:List<&2,Log.Refusal>}
type ReadError is Data: ReadFailed{view:View}
type WorldMeta is Data: WorldMeta{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,U32>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type Visited is Type: Visited{log:Log.Log<Payload.Payload>,packets:List<&2,PacketView>,errors:List<&2,Log.Refusal>}
def prepend_packet(key:U32,head:Maybe<&1,List<&2,U32>>,errors:List<&2,Log.Refusal>,tail:Visited) -> Visited:
  match head tail:
    case None{}, Visited{log,packets,rest}: Visited{log,packets,List.append(&2,Log.Refusal,errors,rest)}
    case Some{cells}, Visited{log,packets,rest}: Visited{log,PacketView{key,cells} <> packets,List.append(&2,Log.Refusal,errors,rest)}
def visited_head(key:U32,next:Log.Log<Payload.Payload> -> Visited,head:Log.Reading<Payload.Payload,List<&2,U32>>) -> Visited:
  match head:
    case Log.Reading{log,value,errors}: prepend_packet(key,value,errors,next(log))
def visit(keys:List<&2,U32>,log:Log.Log<Payload.Payload>) -> Visited:
  match keys:
    case []: Visited{log,[],[]}
    case +key <> rest: visited_head(key,log => visit(rest,log),Log.read(~Payload.Payload,~List<&2,U32>,~Payload.at,~Payload.first_reader,log,key))
def rebuild(meta:WorldMeta,live:Array<Bool>,store:Unit,log:Log.Log<Payload.Payload>,pending:List<(W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>)>) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>:
  match meta:
    case WorldMeta{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock}: W.World{namespace,nextId,highWater,live,capacity,depth,store,log,events,pending,registrations,nextSystemId,clock}
def outcome(fail:Bool,world:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>,view:View) -> Sy.Outcome<W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>,ReadError,View>:
  match fail:
    case True{}: Sy.Failed{world,ReadFailed{view}}
    case False{}: Sy.Succeeded{world,view}
def read_done(meta:WorldMeta,live:Array<Bool>,store:Unit,pending:List<(W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>)>,+keys:List<&2,U32>,+lagged:Bool,request:Request,visited:Visited) -> Sy.Outcome<W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>,ReadError,View>:
  match request visited:
    case Request{name,fail}, Visited{log,packets,errors}: outcome(fail,rebuild(meta,live,store,log,pending),View{name,keys,packets,lagged,errors})
def read_input(world:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>,+keys:List<&2,U32>,lagged:Bool,request:Request) -> Sy.Outcome<W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>,ReadError,View>:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,log,events,pending,registrations,nextSystem,clock}: read_done(WorldMeta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock},live,store,pending,keys,lagged,request,visit(keys,log))
def read_runner(world:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>,input:Ev.Input<U32,Request>) -> Sy.Outcome<W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>,ReadError,View>:
  match input:
    case Ev.Input{keys,lagged,request}: read_input(world,keys,lagged,request)

type Host is Type:
  Host{runtime:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32>,fast:Ev.Reader<Schema>,fastReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,slow:Ev.Reader<Schema>,slowReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,reads:List<&2,View>,retired:List<Log.Row<Payload.Payload>>,refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool}
def host_read(which:Bool,runtime:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32>,reader:Ev.Reader<Schema>,registry:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,other:Ev.Reader<Schema>,otherReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,reads:List<&2,View>,retired:List<Log.Row<Payload.Payload>>,refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool) -> Host:
  match which:
    case True{}: Host{runtime,reader,registry,other,otherReg,reads,retired,refused,errors,ok}
    case False{}: Host{runtime,other,otherReg,reader,registry,reads,retired,refused,errors,ok}
def read_finished(which:Bool,runtime:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32>,reader:Ev.Reader<Schema>,registry:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,other:Ev.Reader<Schema>,otherReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,reads:List<&2,View>,retired:List<Log.Row<Payload.Payload>>,refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>,completion:Ev.Completion<ReadError,View,Request>) -> Host:
  match completion:
    case Ev.Succeeded{view}: host_read(which,runtime,reader,registry,other,otherReg,List.append(&2,View,reads,[view]),retired,refused,errors,True{})
    case Ev.Failed{ReadFailed{view}}: host_read(which,runtime,reader,registry,other,otherReg,List.append(&2,View,reads,[view]),retired,refused,errors,False{})
    case Ev.Rejected{_}: host_read(which,runtime,reader,registry,other,otherReg,reads,retired,refused,errors,False{})
def read_completed(which:Bool,result:Ev.RunResult<Schema,Unit,Log.Log<Payload.Payload>,U32,Request,ReadError,View,read_runner>,other:Ev.Reader<Schema>,otherReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,reads:List<&2,View>,retired:List<Log.Row<Payload.Payload>>,refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>) -> Host:
  match result:
    case Ev.Ran{runtime,reader,registry,completion}: read_finished(which,runtime,reader,registry,other,otherReg,reads,retired,refused,errors,completion)
def read(host:Host,which:Bool,fail:Bool) -> Host:
  match host which:
    case Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}, True{}: read_completed(True{},Ev.run(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,~Request,~ReadError,~View,~read_runner,runtime,fast,fastReg,Request{"fast",fail}),slow,slowReg,reads,retired,refused,errors)
    case Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}, False{}: read_completed(False{},Ev.run(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,~Request,~ReadError,~View,~read_runner,runtime,slow,slowReg,Request{"slow",fail}),fast,fastReg,reads,retired,refused,errors)
def skipped(joined:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32> & Ev.Reader<Schema>,fastReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,slow:Ev.Reader<Schema>,slowReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,reads:List<&2,View>,retired:List<Log.Row<Payload.Payload>>,refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool) -> Host:
  match joined:
    case (runtime,fast): Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok}
def skip(host:Host) -> Host:
  match host:
    case Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok}: skipped(Ev.skip(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,runtime,fast),fastReg,slow,slowReg,reads,retired,refused,errors,ok)

type Publication is Type: Publication{refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>}
def publication_done(meta:WorldMeta,live:Array<Bool>,store:Unit,pending:List<(W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>)>,+key:U32,result:Log.Published<Payload.Payload>) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication:
  match result:
    case Log.Published{log}: (W.event_publish(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,rebuild(meta,live,store,log,pending),[key]),Publication{[],[]})
    case Log.Refused{log,incoming,error}: (rebuild(meta,live,store,log,pending),Publication{[Log.Row{key,incoming}],[error]})
def publish_one(+key:U32,payload:Payload.Payload,world:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,log,events,pending,registrations,nextSystem,clock}: publication_done(WorldMeta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock},live,store,pending,key,Log.publish(~Payload.Payload,key,log,payload))
def published_merge(head:Publication,tail:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication:
  match head tail:
    case Publication{first,a}, (world,Publication{second,b}): (world,Publication{List.append(&1,Log.Row<Payload.Payload>,first,second),List.append(&2,Log.Refusal,a,b)})
def published_head(next:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication,head:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication:
  match head:
    case (world,result): published_merge(result,next(world))
def publish_rows(rows:List<Log.Row<Payload.Payload>>,world:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication:
  match rows:
    case []: (world,Publication{[],[]})
    case Log.Row{key,payload} <> tail: published_head(world => publish_rows(tail,world),publish_one(key,payload,world))
def publication_ok(errors:List<&2,Log.Refusal>) -> Bool:
  match errors:
    case []: True{}
    case _: False{}
def published(joined:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32> & Publication,fast:Ev.Reader<Schema>,fastReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,slow:Ev.Reader<Schema>,slowReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,reads:List<&2,View>,retired:List<Log.Row<Payload.Payload>>,refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>) -> Host:
  match joined:
    case (runtime,Publication{incoming,+failures}): Host{runtime,fast,fastReg,slow,slowReg,reads,retired,List.append(&1,Log.Row<Payload.Payload>,refused,incoming),List.append(&2,Log.Refusal,errors,failures),publication_ok(failures)}
def publish(host:Host,rows:List<Log.Row<Payload.Payload>>) -> Host:
  match host:
    case Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}: published(Ev.with_world(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,~Publication,world => publish_rows(rows,world),runtime),fast,fastReg,slow,slowReg,reads,retired,refused,errors)
def retirement_done(meta:WorldMeta,live:Array<Bool>,store:Unit,pending:List<(W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>)>,result:Log.Retirement<Payload.Payload>) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & List<Log.Row<Payload.Payload>>:
  match result:
    case Log.Retirement{log,owners}: (rebuild(meta,live,store,log,pending),owners)
def reconcile(world:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32>) -> W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & List<Log.Row<Payload.Payload>>:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,log,+events,pending,registrations,nextSystem,clock}: retirement_done(WorldMeta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock},live,store,pending,Log.retire(~Payload.Payload,log,events))
def runtime_reconciled(result:W.World<Schema,Unit,Log.Log<Payload.Payload>,U32> & List<Log.Row<Payload.Payload>>,+namespace:U32,+batches:List<&2,Ev.Batch<U32>>,+positions:List<&2,Ev.Position>,+nextReader:U32,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,+dropped:Nat) -> Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32> & List<Log.Row<Payload.Payload>>:
  match result:
    case (world,retired): (Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},retired)
def reconcile_runtime(runtime:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32>) -> Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32> & List<Log.Row<Payload.Payload>>:
  match runtime:
    case Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}: runtime_reconciled(reconcile(world),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)
def framed(result:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32> & List<Log.Row<Payload.Payload>>,fast:Ev.Reader<Schema>,fastReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,slow:Ev.Reader<Schema>,slowReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>,reads:List<&2,View>,retired:List<Log.Row<Payload.Payload>>,refused:List<Log.Row<Payload.Payload>>,errors:List<&2,Log.Refusal>,ok:Bool) -> Host:
  match result:
    case (runtime,owners): Host{runtime,fast,fastReg,slow,slowReg,reads,List.append(&1,Log.Row<Payload.Payload>,retired,owners),refused,errors,ok}
def frame(host:Host) -> Host:
  match host:
    case Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok}: framed(reconcile_runtime(Ev.frame(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,runtime)),fast,fastReg,slow,slowReg,reads,retired,refused,errors,ok)

type Started is Type:
  Started{host:Host}
  StartRefused{runtime:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32>}
  SlowRefused{runtime:Ev.Runtime<Schema,Unit,Log.Log<Payload.Payload>,U32>,fast:Ev.Reader<Schema>,registry:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>}
def slow_setup(registered:Ev.Registered<Schema,Unit,Log.Log<Payload.Payload>,U32,Request,ReadError,View,read_runner>,fast:Ev.Reader<Schema>,fastReg:Sy.Registry<Schema,Unit,Log.Log<Payload.Payload>,U32,Ev.Input<U32,Request>,ReadError,View,read_runner>) -> Started:
  match registered:
    case Ev.RegisterFailed{runtime}: SlowRefused{runtime,fast,fastReg}
    case Ev.Registered{runtime,slow,slowReg}: Started{Host{runtime,fast,fastReg,slow,slowReg,[],[],[],[],True{}}}
def fast_setup(registered:Ev.Registered<Schema,Unit,Log.Log<Payload.Payload>,U32,Request,ReadError,View,read_runner>) -> Started:
  match registered:
    case Ev.RegisterFailed{runtime}: StartRefused{runtime}
    case Ev.Registered{runtime,fast,fastReg}: slow_setup(Ev.register(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,~Request,~ReadError,~View,~read_runner,runtime,"slow",["event:read"]),fast,fastReg)
def start(capacity:Nat) -> Started:
  fast_setup(Ev.register(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,~Request,~ReadError,~View,~read_runner,Ev.start(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,W.World{1,1,0,ALeaf{False{}},1,0n,Unit{},Log.Log{[],[]},[],[],[],1,0},capacity),"fast",["event:read"]))
def packet(key:U32,+base:U32) -> Log.Row<Payload.Payload>:
  Log.Row{key,Payload.Payload{ANode{ANode{ALeaf{base},ALeaf{U32.add(base,1)}},ANode{ALeaf{U32.add(base,2)},ALeaf{U32.add(base,3)}}},ANode{ALeaf{U32.add(base,100)},ALeaf{U32.add(base,101)}}}}
def foreign_reader(owner:Ev.Reader<Schema>) -> Ev.Reader<Schema>:
  match owner:
    case Ev.Reader{_,id,registryId}: Ev.Reader{999,id,registryId}
def refuse_reader(host:Host) -> Host:
  match host:
    case Host{runtime,fast,fastReg,slow,slowReg,reads,retired,refused,errors,_}: read_completed(True{},Ev.run(~Schema,~Unit,~Log.Log<Payload.Payload>,~U32,~Request,~ReadError,~View,~read_runner,runtime,foreign_reader(fast),fastReg,Request{"fast",False{}}),slow,slowReg,reads,retired,refused,errors)
