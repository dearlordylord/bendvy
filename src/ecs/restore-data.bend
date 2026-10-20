import Base
import ./entity-key.bend as Key
import ./world.bend as W
import ./decode-data.bend as D
import ./decode-construction.bend as Constructor
import ./snapshot-data.bend as Snapshot

type Binding<S:Data> is Data:
  Binding{saved:Key.Key,target:W.Handle<S>}
type Change<S:Data> is Data:
  Removed{target:W.Handle<S>,name:String}
  Despawned{target:W.Handle<S>}
  Spawned{target:W.Handle<S>}
type Position is Data:
  Component{saved:Key.Key}
  Resource{}
type Error<Custom:Data> is Data:
  InvalidSnapshot{path:String}
  UnsupportedVersion{version:D.Raw}
  DuplicateEntity{saved:Key.Key}
  UnknownComponent{saved:Key.Key,name:String}
  UnknownResource{name:String}
  InvalidComponent{saved:Key.Key,name:String,error:Constructor.Error<Custom>}
  InvalidResource{name:String,error:Constructor.Error<Custom>}
  UnvalidatedDescriptor{name:String}
  Capacity{nextEntity:U32}
type Dispatch<Custom:Data> is Data:
  Unhandled{}
  Staged{}
  Rejected{error:Constructor.Error<Custom>}
type Prepared<State:Type,Custom:Data> is Type:
  BendvyReady{state:State,snapshot:Snapshot.Snapshot}
  Refused{state:State,input:Snapshot.Snapshot,error:Error<Custom>}
def lookup_choose(~S:Data,equal:Bool,target:W.Handle<S>,next:Unit -> Maybe<&2,W.Handle<S>>) -> Maybe<&2,W.Handle<S>>:
  match equal:
    case True{}:Some{target}
    case False{}:next(Unit{})
def lookup(~S:Data,+saved:Key.Key,bindings:List<&2,Binding<S>>) -> Maybe<&2,W.Handle<S>>:
  match bindings:
    case []:None{}
    case Binding{+key,+target} <> rest:
      lookup_choose(~S,Key.equal(saved,key),target,_ => lookup(~S,saved,rest))
