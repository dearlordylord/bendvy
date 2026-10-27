import Base
import ./extended-declarations.bend as Schema
import ./declarations.bend as O
import ../parallel-machines/declarations.bend as Modes
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Basic
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/restore-graph-save.bend as GraphSave
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/relation-failure-reader.bend as Declaration
import ../../src/ecs/execution-relation-store.bend as Graph
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/machine.bend as M
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/world.bend as W

def mode(value:Modes.Mode) -> D.Raw:
  match value:
    case Modes.Waiting{}:D.BendvyText{"waiting"}
    case Modes.Running{}:D.BendvyText{"running"}
def current(~S:Data,slot:M.Slot<S,Modes.Key,Modes.Mode>) -> Maybe<&2,D.Raw>:
  match slot:
    case M.Missing{}:None{}
    case M.Present{value,_,_,_}:Some{mode(value)}
def project(~S:Data,resources:Schema.Resources(~S)) -> Schema.Resources(~S) & (T.Graph<S> & Extended.Machine):
  match resources:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{Graph.Store{+namespace,+graph,failures,sequence,nextReader},view},stamp},Layout.ResourceSlot{Layout.Viewed{Cell.Cell{+slot,+stream,+revision,+cellStamp,+nextStamp,+cellSequence,+initialPending,+cellNamespace,+intent},cellView},resourceStamp}}:(Product.Owner{Layout.ResourceSlot{Layout.Viewed{Graph.Store{namespace,graph,failures,sequence,nextReader},view},stamp},Layout.ResourceSlot{Layout.Viewed{Cell.Cell{slot,stream,revision,cellStamp,nextStamp,cellSequence,initialPending,cellNamespace,intent},cellView},resourceStamp}},(graph,Extended.Machine{"restore-mode",current(~S,slot),revision,cellStamp}))
def projected(~S:Data,schema:Plan.Schema<S,O.components(~S),Schema.resources(~S)>,basic:Basic.Snapshot<S>,result:Schema.World(~S) & (T.Graph<S> & Extended.Machine)) -> Plan.Schema<S,O.components(~S),Schema.resources(~S)> & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (world,(graph,machine)):(schema,(world,Gate.Saved{Extended.Snapshot{basic,GraphSave.relations(~S,[Declaration.Declaration{Schema.hierarchy(~S)}],graph),[machine]}}))
def saved(~S:Data,result:Plan.Schema<S,O.components(~S),Schema.resources(~S)> & (Schema.World(~S) & Gate.Outcome<Basic.Snapshot<S>,Recipe.Refusal>)) -> Plan.Schema<S,O.components(~S),Schema.resources(~S)> & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (schema,(world,Gate.Saved{basic})):projected(~S,schema,basic,W.observe_resource(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~(T.Graph<S> & Extended.Machine),~project(~S),world))
    case (schema,(world,Gate.RefusedPending{})):(schema,(world,Gate.RefusedPending{}))
    case (schema,(world,Gate.Refused{error})):(schema,(world,Gate.Refused{error}))
# Trusted World continuation after actual Scheduled pending gating. Both graph
# and committed Cell projection occur only after the complete basic save succeeds.
def save(~S:Data,schema:Plan.Schema<S,O.components(~S),Schema.resources(~S)>,world:Schema.World(~S)) -> Plan.Schema<S,O.components(~S),Schema.resources(~S)> & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>):saved(~S,Save.save(~S,~O.components(~S),~Schema.resources(~S),~Unit,schema,world))
