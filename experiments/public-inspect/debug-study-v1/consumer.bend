import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import dump.bend as D
import skeleton.bend as F

type Schema is Data:
  Schema{}
type Token is Data:
  Left{}
  Right{}
type Store is Type:
  Store{left:Col.Column<Schema,Array<U32>>,right:Col.Column<Schema,Array<U32>>}
type Resource is Type:
  Resource{cells:Array<U32>,projectionCalls:U32,cursor:U32,refused:List<Array<U32>>}
type Values is Data:
  Values{left:C.Access<List<&2,U32>>,right:C.Access<List<&2,U32>>}
def World() -> Type:W.World<Schema,Store,Resource,U32>
def Frame() -> Type:Check.Frame<Schema,Store,Resource,U32>
def empty(unit:Unit) -> Store:Store{Col.empty(~Schema,~Array<U32>),Col.empty(~Schema,~Array<U32>)}
def projected(a:Array<U32> & List<&2,U32>,b:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match a b:
    case (left,+xs), (right,+ys):(ANode{left,right},List.append(&2,U32,xs,ys))
def project_array(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{a,b}:projected(project_array(a),project_array(b))
def take_left(store:Store) -> Col.Column<Schema,Array<U32>> & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{left,right}:(right,left)
def put_left(right:Col.Column<Schema,Array<U32>>,left:Col.Column<Schema,Array<U32>>) -> Store:Store{left,right}
def take_right(store:Store) -> Col.Column<Schema,Array<U32>> & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{left,right}:(left,right)
def put_right(left:Col.Column<Schema,Array<U32>>,right:Col.Column<Schema,Array<U32>>) -> Store:Store{left,right}
def left_family() -> C.Family<Schema,Store,Col.Column<Schema,Array<U32>>,Array<U32>,List<&2,U32>,Token,take_left,put_left,project_array>:C.Family{"left"}
def right_family() -> C.Family<Schema,Store,Col.Column<Schema,Array<U32>>,Array<U32>,List<&2,U32>,Token,take_right,put_right,project_array>:C.Family{"right"}
def left_grant() -> Cap.ValueRead<Frame(),List<&2,Check.Row<Schema,List<&2,U32>>>>:
  Check.query_grant(~Schema,~Store,~Resource,~U32,~Col.Column<Schema,Array<U32>>,~Array<U32>,~List<&2,U32>,~Token,~take_left,~put_left,~project_array,~left_family(),~Check.Optional{})
def right_grant() -> Cap.ValueRead<Frame(),List<&2,Check.Row<Schema,List<&2,U32>>>>:
  Check.query_grant(~Schema,~Store,~Resource,~U32,~Col.Column<Schema,Array<U32>>,~Array<U32>,~List<&2,U32>,~Token,~take_right,~put_right,~project_array,~right_family(),~Check.Optional{})
def projected_resource(calls:U32,cursor:U32,refused:List<Array<U32>>,result:Array<U32> & List<&2,U32>) -> Resource & List<&2,U32>:
  (cells,view)=result
  (Resource{cells,calls,cursor,refused},view)
def project_resource(owner:Resource) -> Resource & List<&2,U32>:
  match owner:
    case Resource{cells,calls,cursor,refused}:projected_resource(calls,cursor,refused,project_array(cells))
def resource_grant() -> Cap.ValueRead<Frame(),List<&2,U32>>:
  Check.resource_grant(~Schema,~Store,~Resource,~U32,~List<&2,U32>,~project_resource)
def token_equal(a:Token,b:Token) -> Bool:
  match a b:
    case Left{}, Left{}:True{}
    case Right{}, Right{}:True{}
    case _, _:False{}
def tokens(token:Token,value:C.Access<List<&2,U32>>) -> List<&2,Token>:
  match value:
    case C.Found{_}:[token]
    case _:[]
def paired(left:Check.Row<Schema,List<&2,U32>>,right:Check.Row<Schema,List<&2,U32>>) -> D.Row<Schema,Token,Values>:
  match left right:
    case Check.Row{entity,+a}, Check.Row{_,+b}:D.Row{entity,List.append(&2,Token,tokens(Left{},a),tokens(Right{},b)),Values{a,b}}
def rows(left:List<&2,Check.Row<Schema,List<&2,U32>>>,right:List<&2,Check.Row<Schema,List<&2,U32>>>) -> List<&2,D.Row<Schema,Token,Values>>:
  match left right:
    case [], _:[]
    case _, []:[]
    case a <> xs, b <> ys:paired(a,b) <> rows(xs,ys)
def resource_done(+left:List<&2,Check.Row<Schema,List<&2,U32>>>,right:List<&2,Check.Row<Schema,List<&2,U32>>>,result:Frame() & List<&2,U32>) -> Frame() & D.Observed<Schema,Token,Values,List<&2,U32>>:
  (frame,resource)=result
  (frame,D.Observed{List.length(&2,Check.Row<Schema,List<&2,U32>>,left),rows(left,right),resource})
def right_done(left:List<&2,Check.Row<Schema,List<&2,U32>>>,result:Frame() & List<&2,Check.Row<Schema,List<&2,U32>>>) -> Frame() & D.Observed<Schema,Token,Values,List<&2,U32>>:
  (frame,right)=result
  resource_done(left,right,Cap.value_read(~Frame(),~List<&2,U32>,~resource_grant(),frame))
def left_done(result:Frame() & List<&2,Check.Row<Schema,List<&2,U32>>>) -> Frame() & D.Observed<Schema,Token,Values,List<&2,U32>>:
  (frame,left)=result
  right_done(left,Cap.value_read(~Frame(),~List<&2,Check.Row<Schema,List<&2,U32>>>,~right_grant(),frame))
def observe(frame:Frame()) -> Frame() & D.Observed<Schema,Token,Values,List<&2,U32>>:
  left_done(Cap.value_read(~Frame(),~List<&2,Check.Row<Schema,List<&2,U32>>>,~left_grant(),frame))
def grant() -> Cap.ValueRead<Frame(),D.Observed<Schema,Token,Values,List<&2,U32>>>:Cap.ValueRead{observe}
def run(active:Bool,filter:F.Filter<Schema,Token>,world:World()) -> Frame() & F.Output<D.Dump<Schema,Values,List<&2,U32>>>:
  D.dump(~Frame(),~Schema,~Token,~Values,~List<&2,U32>,~token_equal,~grant(),active,filter,Check.Frame{world})

# Application-authored setup only: reserve genuine handles, activate selected IDs.
def live_id(+id:U32) -> Bool:Bool.or(U32.is_eq(id,1),Bool.or(U32.is_eq(id,3),Bool.or(U32.is_eq(id,6),U32.is_eq(id,10))))
def activation_done(result:World() & W.Status) -> World():
  (world,status)=result
  world
def reserved_live(world:World(),handle:W.Handle<Schema>,live:Bool) -> World():
  match live:
    case False{}:world
    case True{}:activation_done(W.activate(~Schema,~Store,~Resource,~U32,world,handle))
def reserved_handle(world:World(),+handle:W.Handle<Schema>) -> World():
  match handle:
    case W.Handle{+namespace,+id}:reserved_live(world,W.Handle{namespace,id},live_id(id))
def reserved(result:World() & W.Reservation<Schema>) -> World():
  match result:
    case (world,W.Reserved{+handle}):reserved_handle(world,handle)
    case (world,_):world
def reserve_many(count:Nat,world:World()) -> World():
  match count:
    case 0n:world
    case 1n++n:reserve_many(n,reserved(W.reserve_id(~Schema,~Store,~Resource,~U32,world)))
type Cell is Type:
  Cell{id:U32,owner:Array<U32>}
type Filled is Type:
  Filled{column:Col.Column<Schema,Array<U32>>,refused:List<Array<U32>>,failed:Bool}
def failure_owner(incoming:Maybe<&1,Array<U32>>,result:Filled) -> Filled:
  match incoming result:
    case None{}, result:result
    case Some{owner}, Filled{column,refused,_}:Filled{column,owner <> refused,True{}}
def fill_step(rest:Col.Column<Schema,Array<U32>> -> Filled,result:Col.SwapOutcome<Schema,Array<U32>>) -> Filled:
  match result:
    case Col.Accepted{column,previous}:failure_owner(previous,rest(column))
    case Col.Rejected{column,incoming}:failure_owner(incoming,rest(column))
def fill(cells:List<Cell>,column:Col.Column<Schema,Array<U32>>) -> Filled:
  match cells:
    case []:Filled{column,[],False{}}
    case Cell{+id,owner} <> tail:fill_step(c => fill(tail,c),Col.swap(~Schema,~Array<U32>,Col.ensure(~Schema,~Array<U32>,column,id),id,Some{owner}))
def configured_failure(ns:U32,next:U32,high:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:Store,resource:Resource,events:List<&2,U32>,pending:List<(World() -> World())>,registrations:List<&2,W.RegistrationMeta>,system:U32,failed:Bool) -> World():
  match resource failed:
    case Resource{cells,_,cursor,refused}, True{}:W.World{ns,next,high,live,capacity,depth,store,Resource{cells,99,cursor,refused},events,pending,registrations,system,41}
    case resource, False{}:W.World{ns,next,high,live,capacity,depth,store,resource,events,(w => w) <> (w => w) <> pending,registrations,system,41}
def configured_columns(ns:U32,next:U32,high:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:Resource,events:List<&2,U32>,pending:List<(World() -> World())>,registrations:List<&2,W.RegistrationMeta>,system:U32,left:Filled,right:Filled) -> World():
  match resource left right:
    case Resource{cells,calls,cursor,old}, Filled{a,xs,+leftFailed}, Filled{b,ys,+rightFailed}:configured_failure(ns,next,high,live,capacity,depth,Store{a,b},Resource{cells,calls,cursor,List.append(&1,Array<U32>,xs,List.append(&1,Array<U32>,ys,old))},events,pending,registrations,system,Bool.or(leftFailed,rightFailed))
def configured_store(ns:U32,next:U32,high:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:Resource,events:List<&2,U32>,pending:List<(World() -> World())>,registrations:List<&2,W.RegistrationMeta>,system:U32,store:Store) -> World():
  match store:
    case Store{left,right}:configured_columns(ns,next,high,live,capacity,depth,resource,events,pending,registrations,system,fill([Cell{1,ANode{ALeaf{7},ALeaf{9}}},Cell{3,ALeaf{11}},Cell{10,ANode{ALeaf{13},ALeaf{17}}}],left),fill([Cell{3,ALeaf{29}},Cell{10,ALeaf{31}}],right))
def configured(world:World()) -> World():
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,_}:configured_store(ns,next,high,live,capacity,depth,resource,events,pending,registrations,system,store)
# A poisoned read grant makes an accidental disabled projection observable.
def poison_frame(frame:Frame()) -> Frame():
  match frame:
    case Check.Frame{W.World{ns,next,high,live,capacity,depth,store,Resource{cells,_,cursor,refused},events,pending,registrations,system,clock}}:Check.Frame{W.World{ns,next,high,live,capacity,depth,store,Resource{cells,1,cursor,refused},events,pending,registrations,system,clock}}
def poison_observe(frame:Frame()) -> Frame() & D.Observed<Schema,Token,Values,List<&2,U32>>:
  observe(poison_frame(frame))
def disabled(filter:F.Filter<Schema,Token>,world:World()) -> Frame() & F.Output<D.Dump<Schema,Values,List<&2,U32>>>:
  D.dump(~Frame(),~Schema,~Token,~Values,~List<&2,U32>,~token_equal,~Cap.ValueRead{poison_observe},False{},filter,Check.Frame{world})
