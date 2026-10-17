import Base
import ./entity-key.bend as Key
import ./snapshot-data.bend as Basic
import ./decode-data.bend as D
import ./relation-types.bend as G

type Group is Data:
  Group{target:Key.Key,sources:List<&2,Key.Key>}
type Relation is Data:
  Relation{name:String,groups:List<&2,Group>}
type Snapshot is Data:
  Snapshot{basic:Basic.Snapshot,relations:List<&2,Relation>,machines:List<&2,D.Field>}
type Error is Data:
  UnknownRelation{name:String}
  InvalidRelation{name:String,source:Key.Key,target:Key.Key}
  UnknownMachine{name:String}
  InvalidMachineState{name:String,value:D.Raw}
type GraphResult<S:Data> is Data:
  Accepted{graph:G.Graph<S>}
  Rejected{error:Error}
