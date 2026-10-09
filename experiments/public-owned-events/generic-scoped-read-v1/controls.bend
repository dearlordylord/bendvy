import Base
import read.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Payload is Type: Payload{cells:Array<Bool>,label:String,sentinel:Array<U32>}
type Query is Type: Query{index:U32,markers:Array<U32>}
type Projection is Data: Projection{value:Bool,label:String,markers:List<&2,U32>}
type Args is Type: Args{index:U32,queryMarkers:Array<U32>,scratch:Array<Bool>,sentinel:Array<U32>}
type Observation is Type: Observation{projection:Projection,scratch:Array<Bool>,sentinel:Array<U32>}
def append_u32(head:List<&2,U32>,tail:List<&2,U32>) -> List<&2,U32>: List.append(&2,U32,head,tail)
def u32_cells(owner:Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: append_u32(u32_cells(left),u32_cells(right))
def projected(+label:String,sentinel:Array<U32>,markers:List<&2,U32>,result:Array<Bool> & Bool) -> Payload & Projection:
  match result:
    case (cells,value): (Payload{cells,label,sentinel},Projection{value,label,markers})
def at(owner:Payload,input:Query) -> Payload & Projection:
  match owner input:
    case Payload{cells,label,sentinel}, Query{index,markers}: projected(label,sentinel,u32_cells(markers),Array.get(Bool,cells,index))
def observed(~H:Type,scratch:Array<Bool>,sentinel:Array<U32>,result:H & Projection) -> H & Observation:
  match result:
    case (owner,view): (owner,Observation{view,scratch,sentinel})
def reader(~H:Type,~read:Cap.Request<H,Query,Projection>,owner:H,args:Args) -> H & Observation:
  match args:
    case Args{index,markers,scratch,sentinel}: observed(~H,scratch,sentinel,Read.request(~H,~Query,~Projection,~read,owner,Query{index,markers}))
def initial() -> Payload:
  Payload{ANode{ANode{ALeaf{True{}},ALeaf{False{}}},ANode{ALeaf{False{}},ALeaf{True{}}}},"flags",ANode{ALeaf{111},ALeaf{222}}}
def first_args() -> Args:
  Args{1,ANode{ALeaf{41},ALeaf{42}},ANode{ALeaf{True{}},ALeaf{False{}}},ANode{ALeaf{311},ALeaf{312}}}
def second_args() -> Args:
  Args{3,ANode{ALeaf{51},ALeaf{52}},ANode{ALeaf{False{}},ALeaf{True{}}},ANode{ALeaf{411},ALeaf{412}}}
def provide(owner:Payload,args:Args) -> Payload & Observation:
  Read.provide(~Payload,~Query,~Projection,~Args,~Observation,~at,~reader,owner,args)
def join(first:Observation,second:Payload & Observation) -> Payload & (Observation & Observation):
  match second:
    case (owner,view): (owner,(first,view))
def again(first:Payload & Observation) -> Payload & (Observation & Observation):
  match first:
    case (owner,view): join(view,provide(owner,second_args()))
def full() -> Payload & (Observation & Observation): again(provide(initial(),first_args()))
