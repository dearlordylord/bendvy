import Base
import ./execution-save-data.bend as Basic
import ./execution-restore-extended-data.bend as Extended
import ./restore-graph-data.bend as Graph
import ./restore-graph-validation.bend as Validation
import ./restore-graph-mapping.bend as Mapping
import ./restore-data.bend as Restore
import ./snapshot-data.bend as Detached
import ./relation-failure-reader.bend as Declaration
import ./relation-types.bend as T

# The old graph algorithm needs only source key membership here. No old World,
# schema, transaction, lifecycle, resource owner or runtime adapter is invoked.
def keys(values:List<&2,Basic.Entity>) -> List<&2,Detached.Entity>:
  match values:
    case []:[]
    case Basic.Entity{key,_} <> rest:Detached.Entity{key,[]} <> keys(rest)
# Internal detached admission: declarations must come from the receiver's closed
# protected bindings. This function grants no resource access or publication.
def prepared(~S:Data,input:Extended.Snapshot<S>,basic:Basic.Snapshot<S>,relations:List<&2,Graph.Relation>,declarations:List<&2,Declaration.Declaration<S>>) -> Extended.Snapshot<S> & Graph.GraphResult<S>:
  match basic:
    case Basic.Snapshot{_,_,entities,_}:(input,Validation.validate(~S,relations,keys(entities),declarations))
def prepare(~S:Data,input:Extended.Snapshot<S>,declarations:List<&2,Declaration.Declaration<S>>) -> Extended.Snapshot<S> & Graph.GraphResult<S>:
  match input:
    case Extended.Snapshot{+basic,+relations,+machines}:prepared(~S,Extended.Snapshot{basic,relations,machines},basic,relations,declarations)
# Bindings must be returned by actual fresh receiver publication. Source keys
# stay detached; the existing mapper rebuilds target edges and inverse ordering.
def remap(~S:Data,graph:T.Graph<S>,bindings:List<&2,Restore.Binding<S>>) -> Mapping.Mapped<S>:
  Mapping.remap(~S,graph,bindings)
