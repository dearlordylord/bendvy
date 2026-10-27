import Base
import ./extended-declarations.bend as Schema
import ../parallel-machines/declarations.bend as Modes
import ./declarations.bend as O
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Basic
import ../../src/ecs/execution-save-metadata.bend as Metadata
import ../../src/ecs/execution-restore-metadata.bend as Time
import ../../src/ecs/execution-restore-admission.bend as BasicAdmission
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-restore-extended-graph.bend as GraphAdmission
import ../../src/ecs/restore-graph-validation.bend as Validation
import ../../src/ecs/restore-graph-data.bend as Graph
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/relation-failure-reader.bend as Declaration
import ../../src/ecs/execution-machine-restore.bend as Machine
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/decode-size.bend as Size
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-restore-scope-admission.bend as Scopes

def Recipes(~S:Data) -> Type:Plan.Schema<S,O.components(~S),Schema.resources(~S)>
type Reason is Data:BasicRefused{error:BasicAdmission.Error} GraphRefused{error:Graph.Error} ScopeRefused{reason:Scopes.Error} MachineShape{} MachineCodec{} MachineStamp{}
type Prepared<-S:Data> is Type:
  Prepared{schema:Recipes(~S),input:Extended.Snapshot<S>,graph:T.Graph<S>,machine:Machine.Commit<Modes.Mode>}
  Refused{schema:Recipes(~S),input:Extended.Snapshot<S>,reason:Reason}
type Decoded is Data:Decoded{current:Maybe<&2,Modes.Mode>} Invalid{}
def codec() -> D.Codec:D.LiteralValues{[D.BendvyText{"waiting"},D.BendvyText{"running"}]}
def mode(raw:D.Raw) -> Decoded:
  match raw:
    case D.BendvyText{"waiting"}:Decoded{Some{Modes.Waiting{}}}
    case D.BendvyText{"running"}:Decoded{Some{Modes.Running{}}}
    case _:Invalid{}
def checked(result:D.Checked) -> Decoded:
  match result:
    case D.Accepted{raw}:mode(raw)
    case D.Rejected{_}:Invalid{}
def decode(value:Maybe<&2,D.Raw>) -> Decoded:
  match value:
    case None{}:Decoded{None{}}
    case Some{+raw}:checked(D.validate(Size.budget(codec(),raw),D.Continue{[D.Work{codec(),raw,"$"}]},raw))
def now(~S:Data,basic:Basic.Snapshot<S>) -> Tick.Tick:
  match basic:
    case Basic.Snapshot{_,Metadata.Metadata{_,_,Clock.State{tick,_},_},_,_}:tick
def decoded(~S:Data,schema:Recipes(~S),input:Extended.Snapshot<S>,graph:T.Graph<S>,revision:Nat,stamp:Maybe<&2,Tick.Tick>,result:Decoded) -> Prepared<S>:
  match result:
    case Invalid{}:Refused{schema,input,MachineCodec{}}
    case Decoded{current}:Prepared{schema,input,graph,Machine.Commit{current,revision,stamp}}
def machine_stamp(~S:Data,schema:Recipes(~S),input:Extended.Snapshot<S>,graph:T.Graph<S>,revision:Nat,stamp:Maybe<&2,Tick.Tick>,value:Maybe<&2,D.Raw>,valid:Bool) -> Prepared<S>:
  match valid:
    case False{}:Refused{schema,input,MachineStamp{}}
    case True{}:decoded(~S,schema,input,graph,revision,stamp,decode(value))
def machine(~S:Data,schema:Recipes(~S),input:Extended.Snapshot<S>,graph:T.Graph<S>,tick:Tick.Tick,values:List<&2,Extended.Machine>) -> Prepared<S>:
  match values:
    case [Extended.Machine{"restore-mode",value,revision,+stamp}]:machine_stamp(~S,schema,input,graph,revision,stamp,value,Time.tick(stamp,tick))
    case _:Refused{schema,input,MachineShape{}}
def graph_checked(~S:Data,schema:Recipes(~S),input:Extended.Snapshot<S>,tick:Tick.Tick,machines:List<&2,Extended.Machine>,result:Graph.GraphResult<S>) -> Prepared<S>:
  match result:
    case Graph.Rejected{error}:Refused{schema,input,GraphRefused{error}}
    case Graph.Accepted{graph}:machine(~S,schema,input,graph,tick,machines)
def graph_values(~S:Data,schema:Recipes(~S),input:Extended.Snapshot<S>,+basic:Basic.Snapshot<S>,relations:List<&2,Graph.Relation>,machines:List<&2,Extended.Machine>) -> Prepared<S>:
  match basic:
    case Basic.Snapshot{_,_,entities,_}:graph_checked(~S,schema,input,now(~S,basic),machines,Validation.validate(~S,relations,GraphAdmission.keys(entities),[Declaration.Declaration{Schema.hierarchy(~S)}]))
def graphs(~S:Data,schema:Recipes(~S),+input:Extended.Snapshot<S>) -> Prepared<S>:
  match input:
    case Extended.Snapshot{+basic,+relations,+machines,_}:graph_values(~S,schema,input,basic,relations,machines)
def scopes_checked(~S:Data,schema:Recipes(~S),input:Extended.Snapshot<S>,result:Scopes.Admission) -> Prepared<S>:
  match result:
    case Scopes.Refused{reason}:Refused{schema,input,ScopeRefused{reason}}
    case Scopes.Admitted{}:graphs(~S,schema,input)
def scopes(~S:Data,schema:Recipes(~S),+input:Extended.Snapshot<S>) -> Prepared<S>:
  match input:
    case Extended.Snapshot{Basic.Snapshot{_,_,entities,_},_,_,members}:scopes_checked(~S,schema,input,Scopes.admit(members,entities))
def basic_checked(~S:Data,input:Extended.Snapshot<S>,result:Recipes(~S) & (Basic.Snapshot<S> & BasicAdmission.Admission)) -> Prepared<S>:
  match result:
    case (schema,(_,BasicAdmission.Refused{error})):Refused{schema,input,BasicRefused{error}}
    case (schema,(_,BasicAdmission.Admitted{})):scopes(~S,schema,input)
# Closed ordinary schema: graph descriptor and machine codec are tied to the
# actual protected Store/Cell layout above, not a caller access/decoder catalog.
def prepare(~S:Data,schema:Recipes(~S),+input:Extended.Snapshot<S>) -> Prepared<S>:
  match input:
    case Extended.Snapshot{+basic,relations,machines,scopes}:basic_checked(~S,Extended.Snapshot{basic,relations,machines,scopes},BasicAdmission.prepare(~S,~O.components(~S),~Schema.resources(~S),schema,basic))
