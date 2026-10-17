import Base
import ../../../src/ecs/world.bend as W
import ../generational-reuse-v1/fixture.bend as Identity
def pair(+n:U32) -> Array<U32>:ANode{ALeaf{n},ALeaf{(n + 1 : U32)}}
def callbacks_join(~P:Type,callback:P -> P,result:List<(P -> P)> & Nat) -> List<(P -> P)> & Nat:
  (values,count)=result
  (callback <> values,1n+count)
def callbacks(~P:Type,values:List<(P -> P)>) -> List<(P -> P)> & Nat:
  match values:
    case []:([],0n)
    case head <> tail:callbacks_join(~P,head,callbacks(~P,tail))
def handle(~S:Data,value:W.Handle<S>) -> String:Identity.handle_text(~S,value)
