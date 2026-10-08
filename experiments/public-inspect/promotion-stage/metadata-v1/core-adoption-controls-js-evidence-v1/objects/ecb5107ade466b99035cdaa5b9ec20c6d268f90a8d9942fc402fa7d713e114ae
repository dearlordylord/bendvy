import Base
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/capabilities.bend as Cap

type Schema is Data:
  Workshop{}
type OtherSchema is Data:
  Garden{}
type Payload is Type:
  Payload{cells:Array<U32>}
type Resource is Type:
  Resource{cells:Array<U32>}
type Store is Type:
  Store{column:Col.Column<Schema,Payload>}
type Token is Data:
  Token{}
type Reads<-H:Type> is Type:
  Reads{stock:I.Lookup<H,Schema,List<&2,U32>>,score:Cap.ValueRead<H,List<&2,U32>>}
type Args is Data:
  Args{target:W.Handle<Schema>,fail:Bool}
type Snapshot is Data:
  Snapshot{stock:I.Value<List<&2,U32>>,score:List<&2,U32>}

def array_four(a:U32,b:U32,c:U32,observed:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (cells,d) = observed
  (cells,[a,b,c,d])
def array_three(a:U32,b:U32,observed:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (cells,c) = observed
  array_four(a,b,c,Array.get(U32,cells,3))
def array_two(a:U32,observed:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (cells,b) = observed
  array_three(a,b,Array.get(U32,cells,2))
def array_one(observed:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  (cells,a) = observed
  array_two(a,Array.get(U32,cells,1))
def array_project(cells:Array<U32>) -> Array<U32> & List<&2,U32>:
  array_one(Array.get(U32,cells,0))
def payload_join(observed:Array<U32> & List<&2,U32>) -> Payload & List<&2,U32>:
  (cells,values) = observed
  (Payload{cells},values)
def project(owner:Payload) -> Payload & List<&2,U32>:
  match owner:
    case Payload{cells}:payload_join(array_project(cells))
def resource_join(observed:Array<U32> & List<&2,U32>) -> Resource & List<&2,U32>:
  (cells,values) = observed
  (Resource{cells},values)
def project_resource(owner:Resource) -> Resource & List<&2,U32>:
  match owner:
    case Resource{cells}:resource_join(array_project(cells))
def take(store:Store) -> Unit & Col.Column<Schema,Payload>:
  match store:
    case Store{column}:(Unit{},column)
def put(rest:Unit,column:Col.Column<Schema,Payload>) -> Store:
  Store{column}
def empty(unit:Unit) -> Store:
  Store{Col.empty(~Schema,~Payload)}
def family() -> C.Family<Schema,Store,Unit,Payload,List<&2,U32>,Token,take,put,project>:
  C.Family{"Stock"}
def Ops(H:Type) -> Type:
  Reads<H>
def plan() -> I.Plan<Schema,Store,Resource,U32,Ops>:
  I.Plan{Reads{I.read_family(~Schema,~Store,~Resource,~U32,~Unit,~Payload,~List<&2,U32>,~Token,~take,~put,~project,~family()),I.read_resource(~Schema,~Store,~Resource,~U32,~List<&2,U32>,~project_resource)}}
def stock(~H:Type,cap:Reads<H>) -> I.Lookup<H,Schema,List<&2,U32>>:
  match cap:
    case Reads{stock,_}:stock
def score(~H:Type,cap:Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match cap:
    case Reads{_,score}:score

def concluded(~H:Type,fail:Bool,ctx:H,value:Snapshot) -> H & Result<&2,&2,Snapshot,Snapshot>:
  match fail:
    case True{}:(ctx,Fail{value})
    case False{}:(ctx,Done{value})
def with_score(~H:Type,fail:Bool,value:I.Value<List<&2,U32>>,observed:H & List<&2,U32>) -> H & Result<&2,&2,Snapshot,Snapshot>:
  (ctx,score) = observed
  concluded(~H,fail,ctx,Snapshot{value,score})
def with_stock(~H:Type,~caps:Reads<H>,fail:Bool,observed:H & I.Value<List<&2,U32>>) -> H & Result<&2,&2,Snapshot,Snapshot>:
  (ctx,value) = observed
  with_score(~H,fail,value,Cap.value_read(~H,~List<&2,U32>,~score(~H,caps),ctx))
def projected(~H:Type,~caps:Reads<H>,args:Args,ctx:H) -> H & Result<&2,&2,Snapshot,Snapshot>:
  match args:
    case Args{target,fail}:with_stock(~H,~caps,fail,I.lookup(~H,~Schema,~List<&2,U32>,~stock(~H,caps),ctx,target))

def bool(value:Bool) -> String:
  Bool.show(value)
def access(value:C.Access<List<&2,U32>>) -> String:
  match value:
    case C.Found{values}:List.show(&2,U32,U32.show,values)
    case C.ComponentAbsent{}:"absent"
    case C.MissingEntity{}:"missing"
def snapshot(value:Snapshot) -> String:
  match value:
    case Snapshot{I.Value{value,added,changed},score}:access(value) ++ "/" ++ bool(added) ++ "/" ++ bool(changed) ++ "|" ++ List.show(&2,U32,U32.show,score)
def result(value:Result<&2,&2,Snapshot,Snapshot>) -> String:
  match value:
    case Fail{value}:"fail:" ++ snapshot(value)
    case Done{value}:"success:" ++ snapshot(value)
def instance(value:I.Instance<Schema>) -> I.Instance<Schema> & String:
  match value:
    case I.Fresh{}:(I.Fresh{},"fresh")
    case I.Active{+cursor,+registeredAt}:(I.Active{cursor,registeredAt},U32.show(cursor) ++ "/" ++ U32.show(registeredAt))
def observation_clock(state:I.Instance<Schema>,text:String,observed:W.World<Schema,Store,Resource,U32> & U32) -> (W.World<Schema,Store,Resource,U32> & I.Instance<Schema>) & String:
  (world,clock) = observed
  ((world,state),text ++ "|clock=" ++ U32.show(clock))
def observation_instance(world:W.World<Schema,Store,Resource,U32>,text:String,observed:I.Instance<Schema> & String) -> (W.World<Schema,Store,Resource,U32> & I.Instance<Schema>) & String:
  (state,stateText) = observed
  observation_clock(state,text ++ "|cursor=" ++ stateText,W.clock(~Schema,~Store,~Resource,~U32,world))
def observed(value:I.Observed<Schema,Store,Resource,U32,Snapshot,Snapshot>) -> (W.World<Schema,Store,Resource,U32> & I.Instance<Schema>) & String:
  match value:
    case I.Observed{world,state,value}:observation_instance(world,result(value),instance(state))

def next(target:W.Handle<Schema>,stage:U32,lines:String,continue:W.World<Schema,Store,Resource,U32> -> I.Instance<Schema> -> String -> String,observed:(W.World<Schema,Store,Resource,U32> & I.Instance<Schema>) & String) -> String:
  match observed:
    case ((world,state),text):continue(world,state,lines ++ text ++ "\n")
def steps(remaining:Nat,+target:W.Handle<Schema>,+stage:U32,world:W.World<Schema,Store,Resource,U32>,state:I.Instance<Schema>,lines:String) -> String:
  match remaining:
    case 0n:lines
    case 1n+rest:
      next(target,stage,lines,(world => state => lines => steps(rest,target,(stage + 1 : U32),world,state,lines)),observed(I.run(~Schema,~Store,~Resource,~U32,~Ops,~Args,~Snapshot,~Snapshot,~plan(),~projected,state,Args{target,Bool.or(U32.is_eq(stage,0),U32.is_eq(stage,3))},world)))
# The recursion receives its decreasing argument in the continuation.
def seeded_replaced(handle:W.Handle<Schema>,replacement:C.Replacement<W.World<Schema,Store,Resource,U32>,Payload>) -> String:
  match replacement:
    case C.Replaced{world,_}:steps(4n,handle,0,world,I.Fresh{},"")
    case C.ReplaceRejected{_,_,_}:"setup replacement rejected"
def seeded(+handle:W.Handle<Schema>,activated:W.World<Schema,Store,Resource,U32> & W.Status) -> String:
  (world,_) = activated
  seeded_replaced(handle,C.replace(~Schema,~Store,~Resource,~U32,~Unit,~Payload,~List<&2,U32>,~Token,~take,~put,~project,family(),world,handle,Some{Payload{Array.set(U32,Array.new(U32,2n,11),3,14)}}))
def reserved(observed:W.World<Schema,Store,Resource,U32> & W.Reservation<Schema>) -> String:
  match observed:
    case (world,W.Reserved{+handle}):seeded(handle,W.activate(~Schema,~Store,~Resource,~U32,world,handle))
    case (_,W.ReservationRejected{_}):"setup reservation rejected"
def created(creation:W.Creation<Schema,Store,Resource,U32>) -> String:
  match creation:
    case W.Created{_,world}:reserved(W.reserve_id(~Schema,~Store,~Resource,~U32,world))
    case W.CreateRejected{_,_}:"setup creation rejected"
def main() -> String:
  created(W.create(~Schema,~Store,~Resource,~U32,~empty,W.factory(),Resource{Array.set(U32,Array.new(U32,2n,21),3,24)}))
