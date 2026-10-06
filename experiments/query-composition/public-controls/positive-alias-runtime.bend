import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp

type Payload is Type:
  Payload{owned: Array<U32>,scalar: U32}
type Owner is Type:
  Owner{payload: Payload}
type Aliases<-H: Type> is Type:
  Aliases{a: Cap.Write<H,Payload,U32>,b: Cap.Write<H,Payload,U32>,r: Cap.Read<H,U32>,fourth: Cap.Read<H,U32>,fifth: Cap.Read<H,U32>}
def Ops(H: Type) -> Type:
  Aliases<H>
def value(+n: U32) -> Payload:
  Payload{ANode{ALeaf{n},ANode{ALeaf{(n + 1 : U32)},ALeaf{(n + 2 : U32)}}},n}
def get(ctx: Owner) -> Owner & Cmp.Access<U32>:
  match ctx:
    case Owner{Payload{owned,+scalar}}: (Owner{Payload{owned,scalar}},Cmp.Found{scalar})
def set(ctx: Owner,payload: Payload) -> Owner:
  Owner{payload}
def scalar(value: Cmp.Access<U32>) -> U32:
  match value:
    case Cmp.Found{value}: value
    case _: 999

def after_final(~H: Type,first: U32,observed: H & Cmp.Access<U32>) -> H & List<&2,U32>:
  (ctx,last) = observed
  (ctx,first <> scalar(last) <> [])
def after_first(~H: Type,~b: Cap.Write<H,Payload,U32>,~r: Cap.Read<H,U32>,observed: H & Cmp.Access<U32>) -> H & List<&2,U32>:
  (ctx,first) = observed
  after_final(~H,scalar(first),Cap.read(~H,~U32,~r,Cap.set(~H,~Payload,~U32,~b,ctx,value(71))))
def first(~H: Type,caps: Aliases<H>) -> Cap.Write<H,Payload,U32>:
  match caps:
    case Aliases{a,_,_,_,_}: a
def second(~H: Type,caps: Aliases<H>) -> Cap.Write<H,Payload,U32>:
  match caps:
    case Aliases{_,b,_,_,_}: b
def third(~H: Type,caps: Aliases<H>) -> Cap.Read<H,U32>:
  match caps:
    case Aliases{_,_,r,_,_}: r
def body(~H: Type,~caps: Ops(H),args: Unit,ctx: H) -> H & List<&2,U32>:
  after_first(~H,~second(~H,caps),~third(~H,caps),Cap.get(~H,~Payload,~U32,~second(~H,caps),Cap.set(~H,~Payload,~U32,~first(~H,caps),ctx,value(70))))
def array_view(owner: Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}: value <> []
    case ANode{left,right}: List.append(&2,U32,array_view(left),array_view(right))
def finish(observed: Owner & List<&2,U32>) -> List<&2,U32>:
  match observed:
    case (Owner{Payload{owned,_}},seen): List.append(&2,U32,seen,array_view(owned))
def main() -> List<&2,U32>:
  finish(Cap.invoke(~Ops,~Unit,~List<&2,U32>,~body,~Owner,~Aliases{Cap.Write{get,set},Cap.Write{get,set},Cap.Read{get},Cap.Read{get},Cap.Read{get}},Unit{},Owner{value(10)}))
