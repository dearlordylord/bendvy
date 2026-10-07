import Base
import ../../../src/ecs/relation-providers.bend as P
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
def replace_inverse(-H: Type,-S: Data,cap: Cap.ValueWrite<H,List<&2,W.Handle<S>>,Maybe<&2,List<&2,W.Handle<S>>>>,owner: H) -> H:
  match cap:
    case Cap.ValueWrite{_,set}: set(owner,[])
def bad(~S: Data,-H: Type,caps: P.ReadOnly<H,S>,owner: H) -> H:
  match caps:
    case P.ReadOnly{inverse}: replace_inverse(H,S,inverse,owner)
