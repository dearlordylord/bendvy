import Base
import ../private/src/ecs/world.bend as W
import ../private/src/ecs/column.bend as Col
import ../private/src/ecs/component.bend as C
import ../private/src/ecs/ordinary-declaration.bend as Identity
import ../private/src/ecs/ordinary-bundle.bend as Bundle
import ../private/src/ecs/bundle-batch.bend as Batch
import ../private/src/ecs/bundle-delivery.bend as Delivery
import ../private/src/ecs/bundle-insert-adapter.bend as Adapter
import ../private/src/ecs/bundle-construction.bend as Construction
import ../private/src/ecs/bundle-requests.bend as Request
import ../private/src/ecs/transaction.bend as T
import ../private/src/ecs/resource.bend as Resource
import ../private/src/ecs/capabilities.bend as Cap

type Schema is Data:Schema{}
type Token is Data:Token{}
type Packet is Type:Packet{value:Array<U32>,undo:Array<U32> -> Array<U32>}
def Store() -> Type:Col.Column<Schema,Array<U32>>
def World() -> Type:W.World<Schema,Store(),Array<U32>,U32>
def Owner() -> Type:Adapter.Owner<Schema,Store(),Array<U32>,U32,Packet,Unit>
def Input() -> Type:Request.Input<Schema,Array<U32>>
def Output() -> Type:Request.Output<Schema,Array<U32>,Unit>
def take(column:Store()) -> Unit & Store():(Unit{},column)
def put(_:Unit,column:Store()) -> Store():column
def project_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,a),(right,b):(ANode{left,right},List.append(&2,U32,a,b))
def project(value:Array<U32>) -> Array<U32> & List<&2,U32>:
  match value:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:project_join(project(left),project(right))
def identity() -> Identity.Declaration<Schema,Array<U32>>:Identity.component(~Schema,~Array<U32>,"Payload")
def family() -> C.Family<Schema,Store(),Unit,Array<U32>,List<&2,U32>,Token,take,put,project>:C.Family{Identity.key(~Schema,~Array<U32>,identity())}
def construct(context:Unit,raw:Array<U32>) -> Construction.Staged<Unit,Array<U32>,Array<U32>,Unit>:Construction.Valid{context,raw,owner=>owner,[]}
def pack(value:Array<U32>,undo:Array<U32> -> Array<U32>) -> Packet:Packet{value,undo}
def unpack(value:Packet) -> Array<U32>:
  match value:
    case Packet{value,undo}:undo(value)
def request(owner:Owner(),input:Input()) -> Owner() & Output():Bundle.request(~Schema,~Store(),~Array<U32>,~U32,~Packet,~Unit,~Array<U32>,~Array<U32>,~Unit,~construct,~pack,~unpack,Bundle.component(~Schema,~Array<U32>,~Array<U32>,identity()),owner,input)
def installed(undo:Array<U32> -> Array<U32>,result:C.Replacement<World(),Array<U32>>) -> Delivery.Delivery<World(),Packet>:
  match result:
    case C.Replaced{world,_}:Delivery.Delivered{world}
    case C.ReplaceRejected{world,Some{value},error}:Delivery.Undelivered{world,Packet{value,undo},error}
    case C.ReplaceRejected{world,None{},error}:Delivery.Delivered{world}
def attempt(world:World(),handle:W.Handle<Schema>,packet:Packet) -> Delivery.Delivery<World(),Packet>:
  match packet:
    case Packet{value,undo}:installed(undo,C.replace(~Schema,~Store(),~Array<U32>,~U32,~Unit,~Array<U32>,~List<&2,U32>,~Token,~take,~put,~project,family(),world,handle,Some{value}))
def recover(world:World(),_:Packet,_:W.WorldError) -> World():world
def owner_read(context:Unit,prepared:List<Batch.Prepared<Schema,Packet>>,observed:T.Tx<World(),U32> & List<&2,U32>) -> Owner() & List<&2,U32>:
  match observed:
    case (tx,value):(Adapter.Owner{Batch.Batch{tx,prepared},context},value)
def read(owner:Owner()) -> Owner() & List<&2,U32>:
  match owner:
    case Adapter.Owner{Batch.Batch{tx,prepared},context}:owner_read(context,prepared,Resource.tx_get(~Schema,~Store(),~Array<U32>,~U32,~List<&2,U32>,~project,tx))
def set(owner:Owner(),value:Array<U32>) -> Owner():
  match owner:
    case Adapter.Owner{Batch.Batch{tx,prepared},context}:Adapter.Owner{Batch.Batch{Resource.tx_replace(~Schema,~Store(),~Array<U32>,~U32,tx,value),prepared},context}
def send(owner:Owner(),value:U32) -> Owner():
  match owner:
    case Adapter.Owner{Batch.Batch{tx,prepared},context}:Adapter.Owner{Batch.Batch{T.emit(~World(),~U32,tx,value),prepared},context}
def Ops(H:Type) -> Type:Cap.ValueWrite<H,Array<U32>,List<&2,U32>> & (Cap.Send<H,U32> & Cap.OwnedRequest<H,Input(),Output()>)
def resource_cap(~H:Type,caps:Ops(H)) -> Cap.ValueWrite<H,Array<U32>,List<&2,U32>>:
  match caps:
    case (resource,_):resource
def send_cap(~H:Type,caps:Ops(H)) -> Cap.Send<H,U32>:
  match caps:
    case (_,(send,_)):send
def request_cap(~H:Type,caps:Ops(H)) -> Cap.OwnedRequest<H,Input(),Output()>:
  match caps:
    case (_,(_,request)):request
