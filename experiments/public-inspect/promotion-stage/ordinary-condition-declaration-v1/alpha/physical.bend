import Base
import state.bend as F
import event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Domain
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as FR
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Pub
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
def first(value:F.FirstEvent) -> String:
  match value:
    case F.FirstEvent{value}:"First:" ++ U32.show(value)
def second(value:F.SecondEvent) -> String:
  match value:
    case F.SecondEvent{value}:"Second:" ++ Bool.show(value)
def unused(value:F.UnusedEvent) -> String:
  match value:
    case F.UnusedEvent{value}:"Unused:" ++ U32.show(value)
def pair(value:F.PairEvents()) -> String:
  match value:
    case Pub.Publication{firstValues,secondValues}:"Pair(" ++ List.show(&2,F.FirstEvent,first,firstValues) ++ ";" ++ List.show(&2,F.SecondEvent,second,secondValues) ++ ")"
def publication(value:F.Events()) -> String:
  match value:
    case Pub.Publication{pairs,unusedValues}:"Publication(" ++ List.show(&2,F.PairEvents(),pair,pairs) ++ ";" ++ List.show(&2,F.UnusedEvent,unused,unusedValues) ++ ")"
def batch(~E:Data,~show:E -> String,value:Ev.Batch<E>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,E,show,values)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def stream(~E:Data,~show:E -> String,value:Stream.Stream<F.S,E>) -> String:
  match value:
    case Stream.Stream{Domain.Domain{key},batches,positions,nextReader,frameStart,boundary,capacity,dropped}:key ++ ";batches=" ++ List.show(&2,Ev.Batch<E>,batch(~E,~show),batches) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";nextReader=" ++ U32.show(nextReader) ++ ";frameStart=" ++ Nat.show(frameStart) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped)
def metadata(value:Events.Metadata()) -> Events.Metadata() & String:
  match value:
    case P.Owner{P.Owner{+a,+b},+c}:(P.Owner{P.Owner{a,b},c},"family{" ++ stream(~F.FirstEvent,~first,a) ++ ";" ++ stream(~F.SecondEvent,~second,b) ++ ";" ++ stream(~F.UnusedEvent,~unused,c) ++ "}")
def family_join(+journal:List<&2,Ev.Batch<F.Events()>>,+start:Nat,metadata:Events.Metadata() & String,owners:Array<U32> & String) -> Events.State() & String:
  match metadata owners:
    case (family,m),(owners,o):(FR.State{family,owners,journal,start},m ++ ";eventOwners=" ++ o ++ ";journal=" ++ List.show(&2,Ev.Batch<F.Events()>,batch(~F.Events(),~publication),journal) ++ ";frameStart=" ++ Nat.show(start))
def family(value:Events.State()) -> Events.State() & String:
  match value:
    case FR.State{family,owners,journal,start}:family_join(journal,start,metadata(family),O.u32_array(owners))
def slot_ready(result:Array<U32> & String) -> D.Slot<Array<U32>> & String:
  match result:
    case (owner,text):(D.Ready{owner},"Ready:" ++ text)
def service(value:D.Slot<Array<U32>>) -> D.Slot<Array<U32>> & String:
  match value:
    case D.Missing{}:(D.Missing{},"Missing")
    case D.Ready{owner}:slot_ready(O.u32_array(owner))
def next(value:M.Pending<U32>) -> String:
  match value:
    case M.NoPending{}:"NoPending"
    case M.Queued{value,skip}:"Queued:" ++ U32.show(value) ++ ":" ++ Bool.show(skip)
def previous_text(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some:" ++ U32.show(value)
def machine(value:M.Slot<F.S,F.Mode,U32>) -> String:
  match value:
    case M.Missing{}:"Missing"
    case M.Present{current,pending,previous,changed}:U32.show(current) ++ ":" ++ next(pending) ++ ":" ++ previous_text(previous) ++ ":" ++ Bool.show(changed)
def resources_join(+mode:M.Slot<F.S,F.Mode,U32>,+barriers:U32,clock:D.Slot<Array<U32>> & String,inventory:Array<U32> & String,sibling:Array<U32> & String) -> F.Resources & String:
  match clock inventory sibling:
    case (clock,a),(inventory,b),(sibling,c):(F.Resources{clock,mode,inventory,sibling,barriers},"resources{" ++ a ++ ";machine=" ++ machine(mode) ++ ";inventory=" ++ b ++ ";sibling=" ++ c ++ ";barriers=" ++ U32.show(barriers) ++ "}")
def resources(value:F.Resources) -> F.Resources & String:
  match value:
    case F.Resources{clock,mode,inventory,sibling,barriers}:resources_join(mode,barriers,service(clock),O.u32_array(inventory),O.u32_array(sibling))
def stores_join(a:Col.Column<F.S,Array<U32>> & String,b:Col.Column<F.S,Array<U32>> & String,c:Array<U32> & String) -> F.Store & String:
  match a b c:
    case (a,x),(b,y),(c,z):(F.Store{a,b,c},"store{" ++ x ++ ";" ++ y ++ ";sibling=" ++ z ++ "}")
def observe_store(value:F.Store) -> F.Store & String:
  match value:
    case F.Store{a,b,c}:stores_join(O.column(~F.S,~Array<U32>,~O.u32_array,a),O.column(~F.S,~Array<U32>,~O.u32_array,b),O.u32_array(c))
def world_join(+ns:U32,+id:U32,+high:U32,+cap:U32,+depth:Nat,+events:List<&2,F.Events()>,+regs:List<&2,W.RegistrationMeta>,+sys:U32,+clock:U32,live:Array<Bool> & String,store:F.Store & String,resources:F.Resources & String,pending:List<(F.World() -> F.World())> & Nat) -> F.World() & String:
  match live store resources pending:
    case (live,a),(store,b),(resource,c),(pending,n):(W.World{ns,id,high,live,cap,depth,store,resource,events,pending,regs,sys,clock},"world{" ++ U32.show(ns) ++ ";next=" ++ U32.show(id) ++ ";high=" ++ U32.show(high) ++ ";live=" ++ a ++ ";capacity=" ++ U32.show(cap) ++ ";depth=" ++ Nat.show(depth) ++ ";" ++ b ++ ";" ++ c ++ ";events=" ++ List.show(&2,F.Events(),publication,events) ++ ";pending=" ++ Nat.show(n) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,regs) ++ ";nextSystem=" ++ U32.show(sys) ++ ";clock=" ++ U32.show(clock) ++ "}")
def world(value:F.World()) -> F.World() & String:
  match value:
    case W.World{ns,id,high,live,cap,depth,store,resource,events,pending,regs,sys,clock}:world_join(ns,id,high,cap,depth,events,regs,sys,clock,O.bool_array(live),observe_store(store),resources(resource),O.callbacks(~F.World(),~F.World(),pending))
def runtime_join(+tick:Nat,world:F.World() & String,family:Events.State() & String) -> Events.Runtime() & String:
  match world family:
    case (world,a),(family,b):(Route.Runtime{world,family,tick},a ++ ";" ++ b ++ ";tick=" ++ Nat.show(tick))
def runtime(value:Events.Runtime()) -> Events.Runtime() & String:
  match value:
    case Route.Runtime{w,f,t}:runtime_join(t,world(w),family(f))
