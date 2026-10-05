import Base
import ./types.bend as T
import ./storage.bend as W
import ./identity.bend as I
import ./commands.bend as C
import ./payload.bend as P
import ./storage-stage-fixture.bend as F
import ./host.bend as H
import ./host-observations.bend as E
import ./dispatcher.bend as D
import ./schedule.bend as K
import ./readers.bend as R
import ./reader-host.bend as RH
import ./transaction.bend as X

# Private E11 provisioner. Request is authored input, never expected output.
# Runtime setup requires fresh factory/world, <=65537 spawns and <=131074 values.
# Actual reservations live in Host.bindings; E11 observes them as an ordered range,
# avoiding a quadratic full-component TraceEvent append per reservation.
type RetActor is Data:
  RetFast{}
  RetB{}
  RetLate{}
type RetOp is Data:
  RetSpawn{count: U32,firstPayload: U32}
  RetEmit{first: U32,count: U32}
  RetRead{actor: RetActor,fails: Bool}
  RetRemoveAll{}
  RetDespawnAll{}
  RetRemoveFirstDespawnSecond{}
  RetWriteMain0{value: U32}
  RetBarrier{}

type Batch<-Host:Type> is Type:
  Batch{host:Host,request:RetOp}
def wrap_presence(-Host:Type,request:RetOp,pair:Host & D.Presence) -> Batch<Host> & D.Presence:
  match pair:
    case (host,value): (Batch{host,request},value)
def wrap_clock(-Host:Type,request:RetOp,pair:Host & R.Clock) -> Batch<Host> & R.Clock:
  match pair:
    case (host,clock): (Batch{host,request},clock)
def wrap_frame(-Host:Type,request:RetOp,pair:Host & (R.Readers & R.Clock)) -> Batch<Host> & (R.Readers & R.Clock):
  match pair:
    case (host,others): (Batch{host,request},others)
def wrap_invoked(-Host:Type,-Handle:Data,request:RetOp,result:D.Invoked<Host,Handle>) -> D.Invoked<Batch<Host>,Handle>:
  match result:
    case D.Invoked{host,audit,run,outcome,clock,escaped,observations}: D.Invoked{Batch{host,request},audit,run,outcome,clock,escaped,observations}

def motion_bundle(x:U32) -> W.Bundle<T.Position,T.Velocity,T.Selected>:
  W.Bundle{Some{T.Position{F.vector(x),7}},Some{T.Velocity{F.vector(1),True{}}},Some{T.Selected{8}}}
type MotionBuild is Type:
  MotionBuild{world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,commands:List<W.Command<T.Position,T.Velocity,T.Selected>>,bindings:List<&2,E.Binding<T.MotionSchema>>}
def motion_reserved(x:U32,commands:List<W.Command<T.Position,T.Velocity,T.Selected>>,bindings:List<&2,E.Binding<T.MotionSchema>>,pair:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,W.Handle<T.MotionSchema>>) -> MotionBuild:
  match pair:
    case (world,None{}): MotionBuild{world,commands,bindings}
    case (world,Some{W.Handle{+namespace,+id}}): MotionBuild{world,W.Spawn{id,motion_bundle(x)} <> commands,E.Binding{U32.show(id),W.Handle{namespace,id}} <> bindings}
def motion_reserve_step(x:U32,build:MotionBuild) -> MotionBuild:
  match build:
    case MotionBuild{world,commands,bindings}: motion_reserved(x,commands,bindings,I.reserve_id(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world))
def motion_reserve_many(fuel:Nat,+x:U32,build:MotionBuild) -> MotionBuild:
  match fuel:
    case 0n: build
    case 1n+n: motion_reserve_many(n,U32.add(x,1),motion_reserve_step(x,build))
def motion_spawn_return(logs: RH.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,build:MotionBuild) -> H.MotionHost():
  match build:
    case MotionBuild{world,commands,newBindings}:
      H.Host{W.publish(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,commands),logs,List.append(&2,E.Binding<T.MotionSchema>,bindings,List.reverse(&2,E.Binding<T.MotionSchema>,newBindings)),worldName,step,prior,events}
def motion_spawn(count:U32,x:U32,owner:H.MotionHost()) -> H.MotionHost():
  match owner:
    case H.Host{world,logs,bindings,worldName,step,prior,events}:
      motion_spawn_return(logs,bindings,worldName,step,prior,events,motion_reserve_many(U32.to_nat(count),x,MotionBuild{world,[],[]}))
def motion_queued(result:T.CommandResult<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match result:
    case T.CommandQueued{world}: world
    case T.CommandMissing{world,_}: world
def motion_delete(despawn:Bool,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,handle:W.Handle<T.MotionSchema>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match despawn:
    case True{}: motion_queued(C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle))
    case False{}: motion_queued(C.remove_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle))
def motion_delete_all(bindings:List<&2,E.Binding<T.MotionSchema>>,+despawn:Bool,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match bindings:
    case Nil{}: world
    case Con{E.Binding{_,handle},tail}: motion_delete_all(tail,despawn,motion_delete(despawn,world,handle))
def motion_mixed(bindings:List<&2,E.Binding<T.MotionSchema>>,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match bindings:
    case Con{E.Binding{_,a},Con{E.Binding{_,b},_}}: motion_delete(True{},motion_delete(False{},world,a),b)
    case _: world
def motion_removed(request:RetOp,bindings:List<&2,E.Binding<T.MotionSchema>>,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match request:
    case RetRemoveAll{}: motion_delete_all(bindings,False{},world)
    case RetDespawnAll{}: motion_delete_all(bindings,True{},world)
    case RetRemoveFirstDespawnSecond{}: motion_mixed(bindings,world)
    case _: world
def motion_remove(request:RetOp,owner:H.MotionHost()) -> H.MotionHost():
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: H.Host{motion_removed(request,bindings,world),logs,bindings,worldName,step,prior,events}
def motion_write_result(handle:W.Handle<T.MotionSchema>,tick:U32,pair:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<U32>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match pair:
    case (world,T.Found{_}): W.mark_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle,tick)
    case (world,_): world
def motion_write_all(bindings:List<&2,E.Binding<T.MotionSchema>>,+tick:U32,+value:U32,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match bindings:
    case Nil{}: world
    case Con{E.Binding{_,+handle},tail}: motion_write_all(tail,tick,value,motion_write_result(handle,tick,X.storage_set_main0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.position_swap,world,handle,value)))
def motion_write(tick:U32,value:U32,owner:H.MotionHost()) -> H.MotionHost():
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: H.Host{motion_write_all(bindings,tick,value,world),logs,bindings,worldName,step,prior,events}
def motion_ping_values(fuel:Nat,+value:U32,reverse:List<&2,T.MotionPing>) -> List<&2,T.MotionPing>:
  match fuel:
    case 0n: List.reverse(&2,T.MotionPing,reverse)
    case 1n+n: motion_ping_values(n,U32.add(value,1),T.MotionPing{value} <> reverse)
def motion_request(request:RetOp,+clock:R.Clock,owner:H.MotionHost()) -> H.MotionHost() & R.Clock:
  match request:
    case RetSpawn{count,x}: (motion_spawn(count,x,owner),clock)
    case RetEmit{first,count}: H.publish(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,owner,clock,motion_ping_values(U32.to_nat(count),first,[]))
    case RetWriteMain0{value}: (motion_write(D.clock_tick(clock),value,owner),clock)
    case other: (motion_remove(other,owner),clock)
def motion_batch_done(request:RetOp,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:H.MotionHost() & R.Clock) -> D.Invoked<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>:
  match pair:
    case (owner,clock): D.Invoked{Batch{owner,request},audit,run,T.Success{},clock,None{},[]}
def motion_invoke_kind(kind:K.BodyKind,system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:Batch<H.MotionHost()>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>):
  match kind owner:
    case K.Seed{} Batch{host,+request}: IO.pure(D.Invoked<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>,motion_batch_done(request,audit,run,motion_request(request,clock,host)))
    case _ Batch{host,request}: IO.bind(D.Invoked<H.MotionHost(),W.Handle<T.MotionSchema>>,D.Invoked<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>,H.motion_invoke(system,mode,count,clock,host,audit,run),result => IO.pure(D.Invoked<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>,wrap_invoked(H.MotionHost(),W.Handle<T.MotionSchema>,request,result)))
def motion_invoke_project(+system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:Batch<H.MotionHost()>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,_,kind,_,_,_,_}: motion_invoke_kind(kind,system,mode,count,clock,owner,audit,run)
def motion_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:Batch<H.MotionHost()>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>):
  motion_invoke_project(system,mode,count,clock,owner,audit,run)
def motion_presence(owner:Batch<H.MotionHost()>) -> Batch<H.MotionHost()> & D.Presence:
  match owner:
    case Batch{host,request}: wrap_presence(H.MotionHost(),request,H.motion_presence(host))
def motion_barrier(owner:Batch<H.MotionHost()>,clock:R.Clock) -> IO(Batch<H.MotionHost()> & R.Clock):
  match owner:
    case Batch{host,request}: IO.bind(H.MotionHost() & R.Clock,Batch<H.MotionHost()> & R.Clock,H.motion_barrier(host,clock),pair => IO.pure(Batch<H.MotionHost()> & R.Clock,wrap_clock(H.MotionHost(),request,pair)))
def motion_transition(owner:Batch<H.MotionHost()>,pending:Maybe<&2,Bool>,clock:R.Clock) -> Batch<H.MotionHost()> & R.Clock:
  match owner:
    case Batch{host,request}: wrap_clock(H.MotionHost(),request,H.motion_transition(host,pending,clock))
def motion_frame(owner:Batch<H.MotionHost()>,readers:R.Readers,boundary:R.Frame) -> Batch<H.MotionHost()> & (R.Readers & R.Clock):
  match owner:
    case Batch{host,request}: wrap_frame(H.MotionHost(),request,H.motion_frame(host,readers,boundary))
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>):
  D.tick(Batch<H.MotionHost()>,W.Handle<T.MotionSchema>,motion_presence,motion_invoke,motion_barrier,motion_transition,motion_frame,nodes,"MotionLedger","MotionMode",runtime)

def health_bundle(x:U32) -> W.Bundle<T.Vitals,T.Armor,T.Tracked>:
  W.Bundle{Some{T.Vitals{F.vector(x),9,2}},Some{T.Armor{F.vector(1),3}},Some{T.Tracked{8}}}
type HealthBuild is Type:
  HealthBuild{world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,commands:List<W.Command<T.Vitals,T.Armor,T.Tracked>>,bindings:List<&2,E.Binding<T.HealthSchema>>}
def health_reserved(x:U32,commands:List<W.Command<T.Vitals,T.Armor,T.Tracked>>,bindings:List<&2,E.Binding<T.HealthSchema>>,pair:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,W.Handle<T.HealthSchema>>) -> HealthBuild:
  match pair:
    case (world,None{}): HealthBuild{world,commands,bindings}
    case (world,Some{W.Handle{+namespace,+id}}): HealthBuild{world,W.Spawn{id,health_bundle(x)} <> commands,E.Binding{U32.show(id),W.Handle{namespace,id}} <> bindings}
def health_reserve_step(x:U32,build:HealthBuild) -> HealthBuild:
  match build:
    case HealthBuild{world,commands,bindings}: health_reserved(x,commands,bindings,I.reserve_id(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world))
def health_reserve_many(fuel:Nat,+x:U32,build:HealthBuild) -> HealthBuild:
  match fuel:
    case 0n: build
    case 1n+n: health_reserve_many(n,U32.add(x,1),health_reserve_step(x,build))
def health_spawn_return(logs: RH.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,build:HealthBuild) -> H.HealthHost():
  match build:
    case HealthBuild{world,commands,newBindings}:
      H.Host{W.publish(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,commands),logs,List.append(&2,E.Binding<T.HealthSchema>,bindings,List.reverse(&2,E.Binding<T.HealthSchema>,newBindings)),worldName,step,prior,events}
def health_spawn(count:U32,x:U32,owner:H.HealthHost()) -> H.HealthHost():
  match owner:
    case H.Host{world,logs,bindings,worldName,step,prior,events}:
      health_spawn_return(logs,bindings,worldName,step,prior,events,health_reserve_many(U32.to_nat(count),x,HealthBuild{world,[],[]}))
def health_queued(result:T.CommandResult<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match result:
    case T.CommandQueued{world}: world
    case T.CommandMissing{world,_}: world
def health_delete(despawn:Bool,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,handle:W.Handle<T.HealthSchema>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match despawn:
    case True{}: health_queued(C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle))
    case False{}: health_queued(C.remove_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle))
def health_delete_all(bindings:List<&2,E.Binding<T.HealthSchema>>,+despawn:Bool,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match bindings:
    case Nil{}: world
    case Con{E.Binding{_,handle},tail}: health_delete_all(tail,despawn,health_delete(despawn,world,handle))
def health_mixed(bindings:List<&2,E.Binding<T.HealthSchema>>,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match bindings:
    case Con{E.Binding{_,a},Con{E.Binding{_,b},_}}: health_delete(True{},health_delete(False{},world,a),b)
    case _: world
def health_removed(request:RetOp,bindings:List<&2,E.Binding<T.HealthSchema>>,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match request:
    case RetRemoveAll{}: health_delete_all(bindings,False{},world)
    case RetDespawnAll{}: health_delete_all(bindings,True{},world)
    case RetRemoveFirstDespawnSecond{}: health_mixed(bindings,world)
    case _: world
def health_remove(request:RetOp,owner:H.HealthHost()) -> H.HealthHost():
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: H.Host{health_removed(request,bindings,world),logs,bindings,worldName,step,prior,events}
def health_write_result(handle:W.Handle<T.HealthSchema>,tick:U32,pair:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<U32>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match pair:
    case (world,T.Found{_}): W.mark_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle,tick)
    case (world,_): world
def health_write_all(bindings:List<&2,E.Binding<T.HealthSchema>>,+tick:U32,+value:U32,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match bindings:
    case Nil{}: world
    case Con{E.Binding{_,+handle},tail}: health_write_all(tail,tick,value,health_write_result(handle,tick,X.storage_set_main0(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,P.vitals_swap,world,handle,value)))
def health_write(tick:U32,value:U32,owner:H.HealthHost()) -> H.HealthHost():
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: H.Host{health_write_all(bindings,tick,value,world),logs,bindings,worldName,step,prior,events}
def health_ping_values(fuel:Nat,+value:U32,reverse:List<&2,T.HealthPing>) -> List<&2,T.HealthPing>:
  match fuel:
    case 0n: List.reverse(&2,T.HealthPing,reverse)
    case 1n+n: health_ping_values(n,U32.add(value,1),T.HealthPing{value} <> reverse)
def health_request(request:RetOp,+clock:R.Clock,owner:H.HealthHost()) -> H.HealthHost() & R.Clock:
  match request:
    case RetSpawn{count,x}: (health_spawn(count,x,owner),clock)
    case RetEmit{first,count}: H.publish(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,owner,clock,health_ping_values(U32.to_nat(count),first,[]))
    case RetWriteMain0{value}: (health_write(D.clock_tick(clock),value,owner),clock)
    case other: (health_remove(other,owner),clock)
def health_batch_done(request:RetOp,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:H.HealthHost() & R.Clock) -> D.Invoked<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>:
  match pair:
    case (owner,clock): D.Invoked{Batch{owner,request},audit,run,T.Success{},clock,None{},[]}
def health_invoke_kind(kind:K.BodyKind,system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:Batch<H.HealthHost()>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>):
  match kind owner:
    case K.Seed{} Batch{host,+request}: IO.pure(D.Invoked<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>,health_batch_done(request,audit,run,health_request(request,clock,host)))
    case _ Batch{host,request}: IO.bind(D.Invoked<H.HealthHost(),W.Handle<T.HealthSchema>>,D.Invoked<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>,H.health_invoke(system,mode,count,clock,host,audit,run),result => IO.pure(D.Invoked<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>,wrap_invoked(H.HealthHost(),W.Handle<T.HealthSchema>,request,result)))
def health_invoke_project(+system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:Batch<H.HealthHost()>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,_,kind,_,_,_,_}: health_invoke_kind(kind,system,mode,count,clock,owner,audit,run)
def health_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:Batch<H.HealthHost()>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>):
  health_invoke_project(system,mode,count,clock,owner,audit,run)
def health_presence(owner:Batch<H.HealthHost()>) -> Batch<H.HealthHost()> & D.Presence:
  match owner:
    case Batch{host,request}: wrap_presence(H.HealthHost(),request,H.health_presence(host))
def health_barrier(owner:Batch<H.HealthHost()>,clock:R.Clock) -> IO(Batch<H.HealthHost()> & R.Clock):
  match owner:
    case Batch{host,request}: IO.bind(H.HealthHost() & R.Clock,Batch<H.HealthHost()> & R.Clock,H.health_barrier(host,clock),pair => IO.pure(Batch<H.HealthHost()> & R.Clock,wrap_clock(H.HealthHost(),request,pair)))
def health_transition(owner:Batch<H.HealthHost()>,pending:Maybe<&2,Bool>,clock:R.Clock) -> Batch<H.HealthHost()> & R.Clock:
  match owner:
    case Batch{host,request}: wrap_clock(H.HealthHost(),request,H.health_transition(host,pending,clock))
def health_frame(owner:Batch<H.HealthHost()>,readers:R.Readers,boundary:R.Frame) -> Batch<H.HealthHost()> & (R.Readers & R.Clock):
  match owner:
    case Batch{host,request}: wrap_frame(H.HealthHost(),request,H.health_frame(host,readers,boundary))
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>) -> IO(D.Dispatched<Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>):
  D.tick(Batch<H.HealthHost()>,W.Handle<T.HealthSchema>,health_presence,health_invoke,health_barrier,health_transition,health_frame,nodes,"HealthLedger","HealthMode",runtime)
