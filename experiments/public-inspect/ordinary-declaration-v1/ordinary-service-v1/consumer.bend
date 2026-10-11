import Base
import declaration.bend as D
import application.bend as ServiceApp
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
type S is Data:
  S{}
type Resources is Type:
  Resources{active:D.Slot<Array<U32>>,unused:D.Slot<Array<U32>>,held:Maybe<&1,Array<U32>>,sibling:Array<U32>,barriers:U32}
type ActiveRest is Type:
  ActiveRest{unused:D.Slot<Array<U32>>,held:Maybe<&1,Array<U32>>,sibling:Array<U32>,barriers:U32}
type UnusedRest is Type:
  UnusedRest{active:D.Slot<Array<U32>>,held:Maybe<&1,Array<U32>>,sibling:Array<U32>,barriers:U32}
def active_take(value:Resources) -> ActiveRest & D.Slot<Array<U32>>:
  match value:
    case Resources{active,unused,held,sibling,barriers}:(ActiveRest{unused,held,sibling,barriers},active)
def active_put(rest:ActiveRest,active:D.Slot<Array<U32>>) -> Resources:
  match rest:
    case ActiveRest{unused,held,sibling,barriers}:Resources{active,unused,held,sibling,barriers}
def unused_take(value:Resources) -> UnusedRest & D.Slot<Array<U32>>:
  match value:
    case Resources{active,unused,held,sibling,barriers}:(UnusedRest{active,held,sibling,barriers},unused)
def unused_put(rest:UnusedRest,unused:D.Slot<Array<U32>>) -> Resources:
  match rest:
    case UnusedRest{active,held,sibling,barriers}:Resources{active,unused,held,sibling,barriers}
def called(value:Array<U32> & U32) -> Array<U32>:
  match value:
    case (owner,n):Array.set(U32,owner,0,U32.add(n,1))
def call(owner:Array<U32>) -> Array<U32>:
  called(Array.get(U32,owner,0))
def active() -> D.Declaration<S,Resources,Array<U32>,ActiveRest,active_take,active_put,call>:D.declare(~S,~Resources,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,1,"Clock")
def unused() -> D.Declaration<S,Resources,Array<U32>,UnusedRest,unused_take,unused_put,call>:D.declare(~S,~Resources,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,2,"Unused")
def World() -> Type:W.World<S,Unit,Resources,U32>
def Application() -> Type:ServiceApp.Application<S,Unit,Resources,U32,D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused()))>
def Setup() -> Data:D.Setup<S,Unit,Resources,U32,D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused()))>
def setup() -> Setup():D.append(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused()),D.single(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),D.single(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,~unused()))
def empty(_:Unit) -> Unit:Unit{}
def resources() -> Resources:Resources{D.Ready{ANode{ALeaf{11},ALeaf{12}}},D.Ready{ANode{ALeaf{21},ALeaf{22}}},None{},ANode{ALeaf{91},ALeaf{92}},0}
def barrier(world:World()) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Resources{active,unused,held,sibling,barriers},events,pending,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,Resources{active,unused,held,sibling,U32.add(barriers,1)},events,pending,regs,system,clock}
def slot_restored(value:Array<U32> & String) -> D.Slot<Array<U32>> & String:
  match value:
    case (owner,text):(D.Ready{owner},"Ready(" ++ text ++ ")")
def slot_text(value:D.Slot<Array<U32>>) -> D.Slot<Array<U32>> & String:
  match value:
    case D.Missing{}:(D.Missing{},"Missing")
    case D.Ready{owner}:slot_restored(O.u32_array(owner))
def held_restored(value:Array<U32> & String) -> Maybe<&1,Array<U32>> & String:
  match value:
    case (owner,text):(Some{owner},"Some(" ++ text ++ ")")
def held_text(value:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{owner}:held_restored(O.u32_array(owner))
def resource_join(a:D.Slot<Array<U32>> & String,b:D.Slot<Array<U32>> & String,h:Maybe<&1,Array<U32>> & String,s:Array<U32> & String,+barriers:U32) -> Resources & String:
  match a b h s:
    case (a,x),(b,y),(h,z),(s,t):(Resources{a,b,h,s,barriers},"resources{active=" ++ x ++ ";unused=" ++ y ++ ";held=" ++ z ++ ";sibling=" ++ t ++ ";barriers=" ++ U32.show(barriers) ++ "}")
def resource_text(value:Resources) -> Resources & String:
  match value:
    case Resources{a,b,h,s,n}:resource_join(slot_text(a),slot_text(b),held_text(h),O.u32_array(s),n)
def pending_join(head:World() -> World(),value:List<(World() -> World())> & Nat) -> List<(World() -> World())> & Nat:
  match value:
    case (rest,n):(head <> rest,1n+n)
def pending(values:List<(World() -> World())>) -> List<(World() -> World())> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:pending_join(head,pending(rest))
def world_join(+ns:U32,+next:U32,+high:U32,+cap:U32,+depth:Nat,+events:List<&2,U32>,+regs:List<&2,W.RegistrationMeta>,+system:U32,+clock:U32,live:Array<Bool> & String,resource:Resources & String,queue:List<(World() -> World())> & Nat) -> World() & String:
  match live resource queue:
    case (live,l),(resource,r),(queue,n):(W.World{ns,next,high,live,cap,depth,Unit{},resource,events,queue,regs,system,clock},"world{" ++ U32.show(ns) ++ ";next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";live=" ++ l ++ ";capacity=" ++ U32.show(cap) ++ ";depth=" ++ Nat.show(depth) ++ ";store=Unit;" ++ r ++ ";events=" ++ List.show(&2,U32,U32.show,events) ++ ";pending=" ++ Nat.show(n) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,regs) ++ ";nextSystem=" ++ U32.show(system) ++ ";clock=" ++ U32.show(clock) ++ "}")
def physical(world:World()) -> World() & String:
  match world:
    case W.World{ns,next,high,live,cap,depth,_,resource,events,queue,regs,system,clock}:world_join(ns,next,high,cap,depth,events,regs,system,clock,O.bool_array(live),resource_text(resource),pending(queue))
def checkpoint_restored(label:String,view:Maybe<&2,ServiceApp.Inventory<S>>,setup:Setup(),+plan:SP.Plan<S>,+flag:Bool,scheduled:SP.Provisioned<S,Unit,Resources,U32,Sys.Registry<S,Unit,Resources,U32,Unit,Unit,Unit,D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active())>>,value:World() & String) -> Application() & String:
  match scheduled value:
    case SP.Provisioned{Sch.Schedule{+ns,+name,+steps,Sys.Registry{+registryNs,+id,+registryName,+access,+cursor}},+needs}, (world,text):(ServiceApp.Application{setup,plan,SP.Provisioned{Sch.Schedule{ns,name,steps,Sys.Registry{registryNs,id,registryName,access,cursor}},needs},world,flag},label ++ "|" ++ ServiceApp.text(~S,view) ++ "|scheduled{" ++ U32.show(ns) ++ ":" ++ name ++ ";registry=" ++ U32.show(registryNs) ++ ":" ++ U32.show(id) ++ ":" ++ registryName ++ ":" ++ List.show(&2,String,s => s,access) ++ ":" ++ U32.show(cursor) ++ ";steps=" ++ List.show(&2,Sch.Step,ServiceApp.step_text,steps) ++ ";needs=" ++ List.show(&2,SP.Requirement<S>,ServiceApp.requirement_text(~S),needs) ++ ";debug=" ++ Bool.show(flag) ++ "}|" ++ text)
def captured(label:String,value:Application() & Maybe<&2,ServiceApp.Inventory<S>>) -> Application() & String:
  match value:
    case (ServiceApp.Application{setup,plan,scheduled,world,flag},view):checkpoint_restored(label,view,setup,plan,flag,scheduled,physical(world))
def capture(label:String,app:Application()) -> Application() & String:
  captured(label,ServiceApp.snapshot(~S,~Unit,~Resources,~U32,~D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),~D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused())),app))
def remove_resource(value:Resources) -> Resources:
  match value:
    case Resources{D.Ready{owner},unused,None{},sibling,barriers}:Resources{D.Missing{},unused,Some{owner},sibling,barriers}
    case value:value
def restore_resource(value:Resources) -> Resources:
  match value:
    case Resources{D.Missing{},unused,Some{owner},sibling,barriers}:Resources{D.Ready{owner},unused,None{},sibling,barriers}
    case value:value
def remove_world(world:World()) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}:W.enqueue(~S,~Unit,~Resources,~U32,W.World{ns,next,high,live,cap,depth,store,remove_resource(resource),events,pending,regs,system,clock},barrier)
def restore_world(world:World()) -> World():
  match world:
    case W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,restore_resource(resource),events,pending,regs,system,clock}
def remove(app:Application()) -> Application():
  match app:
    case ServiceApp.Application{setup,plan,scheduled,world,flag}:ServiceApp.Application{setup,plan,scheduled,remove_world(world),flag}
def restore(app:Application()) -> Application():
  match app:
    case ServiceApp.Application{setup,plan,scheduled,world,flag}:ServiceApp.Application{setup,plan,scheduled,restore_world(world),flag}
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered:" ++ name
    case Sch.Ran{id}:"Ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"Skipped:" ++ U32.show(id)
    case Sch.Applied{}:"Applied"
def run_returned(value:ServiceApp.RunResult<Application(),S>) -> Application() & String:
  match value:
    case ServiceApp.Finished{app,observations}:(app,"Finished:" ++ List.show(&2,Sch.Observation,observation,observations))
    case ServiceApp.Failed{app,_,observations}:(app,"Failed:" ++ List.show(&2,Sch.Observation,observation,observations))
    case ServiceApp.Rejected{app}:(app,"Rejected")
    case ServiceApp.Missing{app,missing}:(app,"Missing:" ++ List.show(&2,SP.Requirement<S>,ServiceApp.requirement_text(~S),missing))
def finished(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match factory value:
    case W.Factory{next}, (app,text):List.append(&2,String,log,[text,"factory=" ++ U32.show(next)])
def stage10(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  finished(factory,log,capture("disabled-final",ServiceApp.enabled(~S,~Unit,~Resources,~U32,~D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),~D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused())),app,False{})))
def stage10_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage10(factory,List.append(&2,String,log,[text]),app)
def stage9(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage10_captured(factory,log,capture("after-retry",app))
def stage9_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage9(factory,List.append(&2,String,log,[text]),app)
def stage8(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage9_captured(factory,log,run_returned(ServiceApp.run(~S,~Unit,~Resources,~U32,~D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),~D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused())),restore(app))))
def stage8_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage8(factory,List.append(&2,String,log,[text]),app)
def stage7(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage8_captured(factory,log,capture("missing-after",app))
def stage7_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage7(factory,List.append(&2,String,log,[text]),app)
def stage6(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage7_captured(factory,log,run_returned(ServiceApp.run(~S,~Unit,~Resources,~U32,~D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),~D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused())),app)))
def stage6_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage6(factory,List.append(&2,String,log,[text]),app)
def stage5(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage6_captured(factory,log,capture("missing-before",remove(app)))
def stage5_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage5(factory,List.append(&2,String,log,[text]),app)
def stage4(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage5_captured(factory,log,capture("after-run",app))
def stage4_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage4(factory,List.append(&2,String,log,[text]),app)
def stage3(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage4_captured(factory,log,run_returned(ServiceApp.run(~S,~Unit,~Resources,~U32,~D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),~D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused())),app)))
def stage3_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage3(factory,List.append(&2,String,log,[text]),app)
def stage2(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage3_captured(factory,log,capture("repeat",app))
def stage2_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage2(factory,List.append(&2,String,log,[text]),app)
def stage1(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage2_captured(factory,log,capture("enabled",ServiceApp.enabled(~S,~Unit,~Resources,~U32,~D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active()),~D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused())),app,True{})))
def stage1_captured(factory:W.Factory,log:List<&2,String>,value:Application() & String) -> List<&2,String>:
  match value:
    case (app,text):stage1(factory,List.append(&2,String,log,[text]),app)
def stage0(factory:W.Factory,log:List<&2,String>,app:Application()) -> List<&2,String>:
  stage1_captured(factory,log,capture("disabled",app))
def installed(factory:W.Factory,value:ServiceApp.Installation<Application(),World(),Setup(),Sys.Registry<S,Unit,Resources,U32,Unit,Unit,Unit,D.runner(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active())>>) -> List<&2,String>:
  match value:
    case ServiceApp.InstallRejected{world,setup,owner}:["install-rejected"]
    case ServiceApp.Installed{app}:stage0(factory,[],app)
def created(value:W.Creation<S,Unit,Resources,U32>) -> List<&2,String>:
  match value:
    case W.CreateRejected{factory,resource}:["create-rejected"]
    case W.Created{factory,world}:installed(factory,ServiceApp.install(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,~active(),~D.scan_pair(~S,~Unit,~Resources,~U32,~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~ActiveRest,~active_take,~active_put,~call,active()),~D.world_observed(~S,~Unit,~Resources,~U32,~Array<U32>,~UnusedRest,~unused_take,~unused_put,~call,unused())),setup(),W.enqueue(~S,~Unit,~Resources,~U32,world,barrier),"service-call"))
def main() -> List<&2,String>:
  created(W.create(~S,~Unit,~Resources,~U32,~empty,W.factory(),resources()))
