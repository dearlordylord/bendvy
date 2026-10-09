import Base
import controls.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import adapter.bend as Adapter

type Metadata is Data: Metadata{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type EventView is Data: EventView{tag:String,cells:List<&2,U32>}
type ColumnView is Data: ColumnView{supported:Bool,slots:List<&2,Maybe<&2,List<&2,U32>>>,stamps:List<&2,L.Entry>}
type Snapshot is Data: Snapshot{metadata:Metadata,live:List<&2,Bool>,column:ColumnView,log:List<&2,EventView>,marks:List<&2,U32>,pending:U32}
def option_some(result:Array<U32> & List<&2,U32>) -> Maybe<&1,Array<U32>> & Maybe<&2,List<&2,U32>>:
  match result:
    case (owner,view): (Some{owner},Some{view})
def option(owner:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & Maybe<&2,List<&2,U32>>:
  match owner:
    case None{}: (None{},None{})
    case Some{owner}: option_some(F.project(owner))
def slot_leaf(result:Maybe<&1,Array<U32>> & Maybe<&2,List<&2,U32>>) -> Array<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,List<&2,U32>>>:
  match result:
    case (owner,view): (ALeaf{owner},[view])
def slot_join(left:Array<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,List<&2,U32>>>,right:Array<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,List<&2,U32>>>) -> Array<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,List<&2,U32>>>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,Maybe<&2,List<&2,U32>>,a,b))
def slots(owner:Array<Maybe<&1,Array<U32>>>) -> Array<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,List<&2,U32>>>:
  match owner:
    case ALeaf{owner}: slot_leaf(option(owner))
    case ANode{left,right}: slot_join(slots(left),slots(right))
def column_done(+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,List<&2,U32>>>) -> F.Store & ColumnView:
  match result:
    case (owner,view): (F.Store{Col.Column{owner,stamps}},ColumnView{True{},view,stamps})
def store(owner:F.Store) -> F.Store & ColumnView:
  match owner:
    case F.Store{Col.Column{values,stamps}}: column_done(stamps,slots(values))
    case owner: (owner,ColumnView{False{},[],[]})
def bool_join(left:Array<Bool> & List<&2,Bool>,right:Array<Bool> & List<&2,Bool>) -> Array<Bool> & List<&2,Bool>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,Bool,a,b))
def bools(owner:Array<Bool>) -> Array<Bool> & List<&2,Bool>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: bool_join(bools(left),bools(right))
def event_done(+tag:String,result:Array<U32> & List<&2,U32>) -> F.OwnedEvent & EventView:
  match result:
    case (owner,view): (F.OwnedEvent{tag,owner},EventView{tag,view})
def event(owner:F.OwnedEvent) -> F.OwnedEvent & EventView:
  match owner:
    case F.OwnedEvent{tag,cells}: event_done(tag,F.project(cells))
def events_join(head:F.OwnedEvent & EventView,tail:List<F.OwnedEvent> & List<&2,EventView>) -> List<F.OwnedEvent> & List<&2,EventView>:
  match head tail:
    case (head,a), (tail,b): (head <> tail,a <> b)
def events(owners:List<F.OwnedEvent>) -> List<F.OwnedEvent> & List<&2,EventView>:
  match owners:
    case []: ([],[])
    case head <> tail: events_join(event(head),events(tail))
def resource_done(+marks:List<&2,U32>,observed:List<F.OwnedEvent> & List<&2,EventView>) -> F.Resource & (List<&2,EventView> & List<&2,U32>):
  match observed:
    case (log,view): (F.Resource{log,marks},(view,marks))
def resource(owner:F.Resource) -> F.Resource & (List<&2,EventView> & List<&2,U32>):
  match owner:
    case F.Resource{log,marks}: resource_done(marks,events(log))
def rebuild(meta:Metadata,live:Array<Bool>,store:F.Store,resource:F.Resource,pending:List<(W.World<F.Schema,F.Store,F.Resource,Unit> -> W.World<F.Schema,F.Store,F.Resource,Unit>)>) -> W.World<F.Schema,F.Store,F.Resource,Unit>:
  match meta:
    case Metadata{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock}: W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}
def assembled(+meta:Metadata,live:Array<Bool> & List<&2,Bool>,store:F.Store & ColumnView,resource:F.Resource & (List<&2,EventView> & List<&2,U32>),pending:List<(W.World<F.Schema,F.Store,F.Resource,Unit> -> W.World<F.Schema,F.Store,F.Resource,Unit>)> & U32) -> W.World<F.Schema,F.Store,F.Resource,Unit> & Snapshot:
  match live store resource pending:
    case (live,a), (store,b), (resource,(log,marks)), (pending,count): (rebuild(meta,live,store,resource,pending),Snapshot{meta,a,b,log,marks,count})
def snapshot(world:W.World<F.Schema,F.Store,F.Resource,Unit>) -> W.World<F.Schema,F.Store,F.Resource,Unit> & Snapshot:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,owner,owned,events,pending,registrations,nextSystemId,clock}: assembled(Metadata{namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock},bools(live),store(owner),resource(owned),W.pending_length(~F.Schema,~F.Store,~F.Resource,~Unit,pending))

# Report retains full final world, recovery payload owners and any rejected inputs.
type Report is Type: Report{world:W.World<F.Schema,F.Store,F.Resource,Unit>,outcome:T.Outcome<String>,recovered:List<F.OwnedEvent>,rejected:F.Owners,beforeFlush:Snapshot,afterFlush:Snapshot}
def after(outcome:T.Outcome<String>,recovered:List<F.OwnedEvent>,rejected:F.Owners,before:Snapshot,result:W.World<F.Schema,F.Store,F.Resource,Unit> & Snapshot) -> Report:
  match result:
    case (world,view): Report{world,outcome,recovered,rejected,before,view}
def flushed(outcome:T.Outcome<String>,recovered:List<F.OwnedEvent>,rejected:F.Owners,result:W.World<F.Schema,F.Store,F.Resource,Unit> & Snapshot) -> Report:
  match result:
    case (world,before): after(outcome,recovered,rejected,before,snapshot(W.barrier(~F.Schema,~F.Store,~F.Resource,~Unit,world)))
def observe(result:Adapter.Returned<W.World<F.Schema,F.Store,F.Resource,Unit>,F.OwnedEvent,String> & F.Owners) -> Report:
  match result:
    case (Adapter.Returned{world,outcome,recovered},rejected): flushed(outcome,recovered,rejected,snapshot(world))
def success() -> Report: observe(F.success())
def failure() -> Report: observe(F.failure())
def foreign() -> Report: observe(F.foreign())
type OwnersView is Data: OwnersView{seedPrevious:List<&2,Maybe<&2,List<&2,U32>>>,rejected:List<&2,List<&2,U32>>,errors:List<&2,W.WorldError>}
type RunView is Data: RunView{outcome:T.Outcome<String>,owners:OwnersView,recovered:List<&2,EventView>,beforeFlush:Snapshot,afterFlush:Snapshot,final:Snapshot}
type SeedView is Data: SeedView{world:Snapshot,owners:OwnersView}
def payload_only(result:Array<U32> & List<&2,U32>) -> List<&2,U32>:
  match result:
    case (_,view): view
def payloads(owners:List<Array<U32>>) -> List<&2,List<&2,U32>>:
  match owners:
    case []: []
    case head <> tail: payload_only(F.project(head)) <> payloads(tail)
def option_only(result:Maybe<&1,Array<U32>> & Maybe<&2,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match result:
    case (_,view): view
def options(owners:List<Maybe<&1,Array<U32>>>) -> List<&2,Maybe<&2,List<&2,U32>>>:
  match owners:
    case []: []
    case head <> tail: option_only(option(head)) <> options(tail)
def ownership(owners:F.Owners) -> OwnersView:
  match owners:
    case F.Owners{previous,rejected,errors}: OwnersView{options(previous),payloads(rejected),errors}
def events_only(result:List<F.OwnedEvent> & List<&2,EventView>) -> List<&2,EventView>:
  match result:
    case (_,view): view
def result(outcome:T.Outcome<String>,owners:OwnersView,recovered:List<&2,EventView>,before:Snapshot,after:Snapshot,last:W.World<F.Schema,F.Store,F.Resource,Unit> & Snapshot) -> RunView:
  match last:
    case (_,final): RunView{outcome,owners,recovered,before,after,final}
# Only fixture observation consumes the final owners; this is not a release API.
def dto(report:Report) -> RunView:
  match report:
    case Report{world,outcome,recovered,rejected,before,after}: result(outcome,ownership(rejected),events_only(events(recovered)),before,after,snapshot(world))
def seed_done(owners:OwnersView,world:W.World<F.Schema,F.Store,F.Resource,Unit> & Snapshot) -> SeedView:
  match world:
    case (_,view): SeedView{view,owners}
def seed_dto(seed:F.Seeded) -> SeedView:
  match seed:
    case F.Seeded{world,owners}: seed_done(ownership(owners),snapshot(world))
