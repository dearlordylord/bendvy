import Base
import ./execution-save-data.bend as Basic
import ./restore-graph-data.bend as Graph
import ./decode-data.bend as D
import ./change-tick.bend as Tick

# Detached world-save extension only. Reader positions, callback owners, pending
# transitions, resource namespaces and failure channels are receiver-owned.
type Machine is Data:
  Machine{name:String,current:Maybe<&2,D.Raw>,revision:Nat,stamp:Maybe<&2,Tick.Tick>}
type Snapshot<-S:Data> is Data:
  Snapshot{basic:Basic.Snapshot<S>,relations:List<&2,Graph.Relation>,machines:List<&2,Machine>}
