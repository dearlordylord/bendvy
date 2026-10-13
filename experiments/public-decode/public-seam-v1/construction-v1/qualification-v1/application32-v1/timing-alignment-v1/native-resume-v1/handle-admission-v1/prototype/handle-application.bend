import Base
import typed.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/commands.bend as Cmd
# The native handle carries the actual schema and actual factory namespace.
# No rootless/default namespace is supplied by this adapter.
type Payload<S:Data> is Type:
  Payload{cells:Array<U32>,name:String,target:Maybe<&2,W.Handle<S>>}
type Resources<S:Data> is Type:
  Resources{value:Payload<S>,retired:List<Payload<S>>}
type Token is Data:
  Token{}
def array_join(left:Array<U32> & List<&2,D.Raw>,right:Array<U32> & List<&2,D.Raw>) -> Array<U32> & List<&2,D.Raw>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,D.Raw,a,b))
def array_project(owner:Array<U32>) -> Array<U32> & List<&2,D.Raw>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[D.Number{value}])
    case ANode{left,right}: array_join(array_project(left),array_project(right))
def projected_target(~S:Data,+name:String,cells:Array<U32>,values:List<&2,D.Raw>,target:Maybe<&2,W.Handle<S>>) -> Payload<S> & D.Raw:
  match target:
    case None{}: (Payload{cells,name,None{}},D.Object{[D.Field{"cells",D.Array{values}},D.Field{"name",D.Text{name}},D.Field{"target",D.Null{}}]})
    case Some{W.Handle{+ns,+id}}: (Payload{cells,name,Some{W.Handle{ns,id}}},D.Object{[D.Field{"cells",D.Array{values}},D.Field{"name",D.Text{name}},D.Field{"target",D.Handle{ns,id}}]})
def projected(~S:Data,name:String,target:Maybe<&2,W.Handle<S>>,result:Array<U32> & List<&2,D.Raw>) -> Payload<S> & D.Raw:
  (cells,values)=result
  projected_target(~S,name,cells,values,target)
def project(~S:Data,payload:Payload<S>) -> Payload<S> & D.Raw:
  match payload:
    case Payload{cells,name,target}: projected(~S,name,target,array_project(cells))
def codec(namespace:U32) -> D.Codec:
  D.Struct{[D.NamedCodec{"cells",D.ArrayValue{D.Integer{}}},D.NamedCodec{"name",D.StringValue{}},D.NamedCodec{"target",D.Nullable{D.HandleValue{namespace}}}]}
def take(~S:Data,column:Col.Column<S,Payload<S>>) -> Unit & Col.Column<S,Payload<S>>:
  (Unit{},column)
def put(~S:Data,unit:Unit,column:Col.Column<S,Payload<S>>) -> Col.Column<S,Payload<S>>:
  column
def family(~S:Data) -> C.Family<S,Col.Column<S,Payload<S>>,Unit,Payload<S>,D.Raw,Token,take(~S),put(~S),project(~S)>:
  C.Family{"HandlePayload"}
def empty(~S:Data,unit:Unit) -> Col.Column<S,Payload<S>>:
  Col.empty(~S,~Payload<S>)
def retired(~S:Data,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,old:Maybe<&1,Payload<S>>) -> W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>:
  match world old:
    case world None{}: world
    case W.World{ns,next,high,live,cap,depth,column,Resources{value,rest},events,pending,regs,system,clock} Some{old}: W.World{ns,next,high,live,cap,depth,column,Resources{value,old <> rest},events,pending,regs,system,clock}
def replaced(~S:Data,result:C.Replacement<W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,Payload<S>>) -> W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>:
  match result:
    case C.Replaced{world,old}: retired(~S,world,old)
    case C.ReplaceRejected{world,incoming,_}: retired(~S,world,incoming)
def populate(~S:Data,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,handle:W.Handle<S>,payload:Payload<S>) -> W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>:
  replaced(~S,C.replace(~S,~Col.Column<S,Payload<S>>,~Resources<S>,~U32,~Unit,~Payload<S>,~D.Raw,~Token,~take(~S),~put(~S),~project(~S),family(~S),world,handle,Some{payload}))
type Outcome<S:Data> is Type:
  Outcome{world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,incoming:Maybe<&1,Payload<S>>,decoded:D.Checked,host:Maybe<&2,W.Status>}
def spawn_reserved(~S:Data,payload:Payload<S>,+decoded:D.Checked,result:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32> & W.Reservation<S>) -> Outcome<S>:
  match result:
    case (world,W.ReservationRejected{error}): Outcome{world,Some{payload},decoded,Some{W.Rejected{error}}}
    case (world,W.Reserved{+handle}): Outcome{W.enqueue(~S,~Col.Column<S,Payload<S>>,~Resources<S>,~U32,world,w => Cmd.spawn_apply(~S,~Col.Column<S,Payload<S>>,~Resources<S>,~U32,~Payload<S>,~populate(~S),w,handle,payload)),None{},decoded,Some{W.Accepted{}}}
def spawn_decoded(~S:Data,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,receipt:D.Receipt<Payload<S>>) -> Outcome<S>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}: Outcome{world,Some{owner},D.Rejected{error},None{}}
    case D.Receipt{owner,checked}: spawn_reserved(~S,owner,checked,W.reserve_id(~S,~Col.Column<S,Payload<S>>,~Resources<S>,~U32,world))
def insert_checked(~S:Data,+target:W.Handle<S>,owner:Payload<S>,+decoded:D.Checked,result:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32> & Bool) -> Outcome<S>:
  match result:
    case (world,False{}): Outcome{world,Some{owner},decoded,Some{W.Rejected{W.MissingEntity{}}}}
    case (world,True{}): Outcome{W.enqueue(~S,~Col.Column<S,Payload<S>>,~Resources<S>,~U32,world,w => populate(~S,w,target,owner)),None{},decoded,Some{W.Accepted{}}}
def insert_decoded(~S:Data,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,+target:W.Handle<S>,receipt:D.Receipt<Payload<S>>) -> Outcome<S>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}: Outcome{world,Some{owner},D.Rejected{error},None{}}
    case D.Receipt{owner,checked}: insert_checked(~S,target,owner,checked,W.valid(~S,~Col.Column<S,Payload<S>>,~Resources<S>,~U32,world,target))
def resource_replace(~S:Data,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,owner:Payload<S>) -> W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,column,Resources{old,rest},events,pending,regs,system,clock}: W.World{ns,next,high,live,cap,depth,column,Resources{owner,old <> rest},events,pending,regs,system,clock}
def resource_decoded(~S:Data,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,receipt:D.Receipt<Payload<S>>) -> Outcome<S>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}: Outcome{world,Some{owner},D.Rejected{error},None{}}
    case D.Receipt{owner,checked}: Outcome{resource_replace(~S,world,owner),None{},checked,Some{W.Accepted{}}}
# Read namespace from the ACTUAL owned world before validating the input.
def namespace(~S:Data,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>) -> W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32> & U32:
  match world:
    case W.World{+ns,next,high,live,cap,depth,column,resource,events,pending,regs,system,clock}: (W.World{ns,next,high,live,cap,depth,column,resource,events,pending,regs,system,clock},ns)
def admitted(~S:Data,route:U32,+target:W.Handle<S>,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,receipt:D.Receipt<Payload<S>>) -> Outcome<S>:
  match route:
    case 0: spawn_decoded(~S,world,receipt)
    case 1: insert_decoded(~S,world,target,receipt)
    case _: resource_decoded(~S,world,receipt)
def described(~S:Data,+route:U32,+target:W.Handle<S>,owner:Payload<S>,observed:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32> & U32) -> Outcome<S>:
  match observed:
    case (world,ns): admitted(~S,route,target,world,D.decode_owner(~Payload<S>,~project(~S),128n,codec(ns),owner))
def admit(~S:Data,route:U32,target:W.Handle<S>,world:W.World<S,Col.Column<S,Payload<S>>,Resources<S>,U32>,owner:Payload<S>) -> Outcome<S>:
  described(~S,route,target,owner,namespace(~S,world))
