import Base
import entity-key.bend as Key
import ./world.bend as W
import ./string-equality.bend as Text

# Lifetime metadata is separate from component owners and never proves liveness.
type Scope<-S:Data> is Data:
  Scope{namespace:U32,name:String}
type Member is Data:
  Member{name:String,id:Key.Key}
type Store<-S:Data,C:Type> is Type:
  Store{components:C,members:List<&2,Member>}
def empty(~S:Data,~C:Type,components:C) -> Store<S,C>:
  Store{components,[]}
def without(members:List<&2,Member>,+id:Key.Key) -> List<&2,Member>:
  match members:
    case []:[]
    case Member{+name,+mid} <> rest:
      +remaining = without(rest,id)
      Bool.pick(List<&2,Member>,Key.equal(mid,id),remaining,Member{name,mid} <> remaining)
def select(members:List<&2,Member>,+name:String) -> List<&2,Key.Key>:
  match members:
    case []:[]
    case Member{+key,+id} <> rest:
      +remaining = select(rest,name)
      Bool.pick(List<&2,Key.Key>,Text.equal(key,name),id <> remaining,remaining)
type SpawnResult<S:Data,P:Type> is Type:
  Spawned{handle:W.Handle<S>}
  SpawnRejected{payload:P,error:W.WorldError}
