import Base
import adapter.bend as Adapter
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/owned-recovery-v1/staging.bend as Stage
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Schema is Data: Schema{}
type Token is Data: Token{}
type Store is Type: Store{column:Col.Column<Schema,Array<U32>>}
type OwnedEvent is Type: OwnedEvent{tag:String,cells:Array<U32>}
type Resource is Type: Resource{log:List<OwnedEvent>,marks:List<&2,U32>}
type Input is Type: Input{handle:W.Handle<Schema>,incoming:Array<U32>}
def take(store:Store) -> Unit & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{column}: (Unit{},column)
def put(_:Unit,column:Col.Column<Schema,Array<U32>>) -> Store: Store{column}
def projected_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,U32,a,b))
def project(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: projected_join(project(left),project(right))
def family() -> C.Family<Schema,Store,Unit,Array<U32>,List<&2,U32>,Token,take,put,project>:
  C.Family{"cells"}
def world() -> W.World<Schema,Store,Resource,Unit>:
  W.World{1,3,2,ANode{ANode{ALeaf{False{}},ALeaf{True{}}},ANode{ALeaf{True{}},ALeaf{False{}}}},4,2n,Store{Col.Column{ANode{ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}}},[]}},Resource{[OwnedEvent{"existing",ANode{ALeaf{71},ALeaf{72}}}],[7]},[],[],[],1,0}
type Owners is Type: Owners{seedPrevious:List<Maybe<&1,Array<U32>>>,rejected:List<Array<U32>>,errors:List<&2,W.WorldError>}
type Seeded is Type: Seeded{world:W.World<Schema,Store,Resource,Unit>,owners:Owners}
def seed_result(owners:Owners,result:C.Replacement<W.World<Schema,Store,Resource,Unit>,Array<U32>>) -> Seeded:
  match owners result:
    case Owners{previous,rejected,errors}, C.Replaced{world,owner}: Seeded{world,Owners{List.append(&1,Maybe<&1,Array<U32>>,previous,[owner]),rejected,errors}}
    case Owners{previous,rejected,errors}, C.ReplaceRejected{world,Some{incoming},error}: Seeded{world,Owners{previous,List.append(&1,Array<U32>,rejected,[incoming]),List.append(&2,W.WorldError,errors,[error])}}
    case Owners{previous,rejected,errors}, C.ReplaceRejected{world,None{},error}: Seeded{world,Owners{previous,rejected,List.append(&2,W.WorldError,errors,[error])}}
def seed_one(handle:W.Handle<Schema>,incoming:Array<U32>,seed:Seeded) -> Seeded:
  match seed:
    case Seeded{world,owners}: seed_result(owners,C.replace(~Schema,~Store,~Resource,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),world,handle,Some{incoming}))
def seeded() -> Seeded:
  seed_one(W.Handle{1,2},ANode{ALeaf{21},ALeaf{22}},seed_one(W.Handle{1,1},ANode{ALeaf{11},ALeaf{12}},Seeded{world(),Owners{[],[],[]}}))
def written(result:C.SetResult<T.Tx<W.World<Schema,Store,Resource,Unit>,Unit>,Array<U32>>) -> T.Tx<W.World<Schema,Store,Resource,Unit>,Unit> & Owners:
  match result:
    case C.Written{tx}: (tx,Owners{[],[],[]})
    case C.WriteRejected{tx,incoming,error}: (tx,Owners{[],[incoming],[error]})
    case C.WriteFailure{tx,error}: (tx,Owners{[],[],[error]})
def set(tx:T.Tx<W.World<Schema,Store,Resource,Unit>,Unit>,input:Input) -> T.Tx<W.World<Schema,Store,Resource,Unit>,Unit> & Owners:
  match input:
    case Input{handle,incoming}: written(C.tx_set(~Schema,~Store,~Resource,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),tx,handle,incoming))
def gameplay(~H:Type,~write:Cap.OwnedRequest<H,Input,Owners>,input:Input,owner:H) -> H & Owners:
  Cap.owned_request(~H,~Input,~Owners,~write,owner,input)
def authorized(tx:T.Tx<W.World<Schema,Store,Resource,Unit>,Unit>,input:Input) -> T.Tx<W.World<Schema,Store,Resource,Unit>,Unit> & Owners:
  gameplay(~T.Tx<W.World<Schema,Store,Resource,Unit>,Unit>,~Cap.OwnedRequest{set},input,tx)
def resource_publish(owners:List<OwnedEvent>,resource:Resource) -> Resource & Unit:
  match resource:
    case Resource{log,marks}: (Resource{List.append(&1,OwnedEvent,log,owners),marks},Unit{})
def resource_mark(resource:Resource) -> Resource & Unit:
  match resource:
    case Resource{log,marks}: (Resource{log,List.append(&2,U32,marks,[8,9])},Unit{})
def changed(result:W.World<Schema,Store,Resource,Unit> & Unit) -> W.World<Schema,Store,Resource,Unit>:
  match result:
    case (world,_): world
# Same schema-owned affine World storage, changed only after canonical success.
def publish(world:W.World<Schema,Store,Resource,Unit>,owners:List<OwnedEvent>) -> W.World<Schema,Store,Resource,Unit>:
  match world:
    case W.World{namespace,next,highWater,live,capacity,depth,store,Resource{log,marks},events,pending,registrations,nextSystem,clock}: W.World{namespace,next,highWater,live,capacity,depth,store,Resource{List.append(&1,OwnedEvent,log,owners),marks},events,pending,registrations,nextSystem,clock}
def mark(world:W.World<Schema,Store,Resource,Unit>) -> W.World<Schema,Store,Resource,Unit>:
  changed(W.observe_resource(~Schema,~Store,~Resource,~Unit,~Unit,~resource_mark,world))
def merge(left:Owners,right:Owners) -> Owners:
  match left right:
    case Owners{a,b,c}, Owners{x,y,z}: Owners{List.append(&1,Maybe<&1,Array<U32>>,a,x),List.append(&1,Array<U32>,b,y),List.append(&2,W.WorldError,c,z)}
def terminal(outcome:T.Outcome<String>,rejected:Owners,tx:T.Tx<W.World<Schema,Store,Resource,Unit>,Unit>) -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  (Adapter.finish(~W.World<Schema,Store,Resource,Unit>,~OwnedEvent,~String,~Commands.enqueue(~Schema,~Store,~Resource,~Unit),~Commands.publish(~Schema,~Store,~Resource,~Unit),~publish,Adapter.Invocation{T.emit(~W.World<Schema,Store,Resource,Unit>,~Unit,T.stage(~W.World<Schema,Store,Resource,Unit>,~Unit,tx,mark),Unit{}),Stage.Stage{[OwnedEvent{"second",ANode{ALeaf{51},ALeaf{52}}},OwnedEvent{"first",ANode{ALeaf{41},ALeaf{42}}}]}},outcome),rejected)
def second_done(outcome:T.Outcome<String>,first_rejected:Owners,second:T.Tx<W.World<Schema,Store,Resource,Unit>,Unit> & Owners) -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  match second:
    case (tx,rejected): terminal(outcome,merge(first_rejected,rejected),tx)
def first_done(outcome:T.Outcome<String>,seed_owners:Owners,first:T.Tx<W.World<Schema,Store,Resource,Unit>,Unit> & Owners) -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  match first:
    case (tx,rejected): second_done(outcome,merge(seed_owners,rejected),authorized(tx,Input{W.Handle{1,2},ANode{ALeaf{201},ALeaf{202}}}))
def run_seed(outcome:T.Outcome<String>,seed:Seeded) -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  match seed:
    case Seeded{world,owners}: first_done(outcome,owners,authorized(T.begin(~W.World<Schema,Store,Resource,Unit>,~Unit,world),Input{W.Handle{1,1},ANode{ALeaf{101},ALeaf{102}}}))
def run(outcome:T.Outcome<String>) -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  run_seed(outcome,seeded())
def success() -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  run(T.Success{})
def failure() -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  run(T.Failure{"failed"})
def foreign_seed(seed:Seeded) -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  match seed:
    case Seeded{world,owners}: second_done(T.Failure{"foreign"},owners,authorized(T.begin(~W.World<Schema,Store,Resource,Unit>,~Unit,world),Input{W.Handle{999,1},ANode{ALeaf{301},ALeaf{302}}}))
def foreign() -> Adapter.Returned<W.World<Schema,Store,Resource,Unit>,OwnedEvent,String> & Owners:
  foreign_seed(seeded())
def seed_refused() -> Seeded:
  seed_one(W.Handle{999,1},ANode{ALeaf{31},ALeaf{32}},seeded())
