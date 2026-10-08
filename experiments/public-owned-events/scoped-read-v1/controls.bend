import Base
import read.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type Payload is Type: Payload{cells:Array<U32>,sentinel:Array<U32>}
def read_result(sentinel:Array<U32>,result:Array<U32> & U32) -> Payload & U32:
  match result:
    case (cells,value): (Payload{cells,sentinel},value)
def at(owner:Payload,index:U32) -> Payload & U32:
  match owner:
    case Payload{cells,sentinel}: read_result(sentinel,Array.get(U32,cells,index))
def prepend(~H:Type,head:U32,result:H & List<&2,U32>) -> H & List<&2,U32>:
  match result:
    case (owner,tail): (owner,head <> tail)
def scanned(~H:Type,next:H -> H & List<&2,U32>,result:H & U32) -> H & List<&2,U32>:
  match result:
    case (owner,value): prepend(~H,value,next(owner))
def scan(~H:Type,~read:Cap.Request<H,U32,U32>,indices:List<&2,U32>,owner:H) -> H & List<&2,U32>:
  match indices:
    case []: (owner,[])
    case index <> rest: scanned(~H,owner => scan(~H,~read,rest,owner),Read.at(~H,~read,owner,index))
def first_reader(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & List<&2,U32>:
  scan(~H,~read,[0,1,2,3],owner)
def second_reader(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & List<&2,U32>:
  scan(~H,~read,[0,1,2,3],owner)
def joined(first:List<&2,U32>,second:Payload & List<&2,U32>) -> Payload & (List<&2,U32> & List<&2,U32>):
  match second:
    case (owner,view): (owner,(first,view))
def again(first:Payload & List<&2,U32>) -> Payload & (List<&2,U32> & List<&2,U32>):
  match first:
    case (owner,view): joined(view,Read.provide(~Payload,~List<&2,U32>,~at,~second_reader,owner))
def full() -> Payload & (List<&2,U32> & List<&2,U32>):
  again(Read.provide(~Payload,~List<&2,U32>,~at,~first_reader,Payload{ANode{ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{13},ALeaf{14}}},ANode{ALeaf{111},ALeaf{222}}}))

# A reader may build its own affine output; no mandatory Data-only observation.
def owned_result(~H:Type,result:H & U32) -> H & Array<U32>:
  match result:
    case (owner,value): (owner,ALeaf{value})
def owned_reader(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & Array<U32>:
  owned_result(~H,Read.at(~H,~read,owner,2))
def owned_control(owner:Payload) -> Payload & Array<U32>:
  Read.provide(~Payload,~Array<U32>,~at,~owned_reader,owner)
