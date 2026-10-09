import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/schema.bend as Schema
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/app.bend as Core
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/declaration.bend as Query
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
# Normal App takes one declared schema, not an extra debug registry.
type Owners<S:Data,C:Type,R:Type,H:Type> is Type:
  Owners{core:Core.Owners<S,C,R,H>,relations:List<&2,Relation.Descriptor<S>>,machines:List<&2,Schema.MachineEntry<S>>}
type Application<S:Data,C:Type,R:Type,E:Data,H:Type> is Type:
  Application{core:Core.Application<S,C,R,E,H>,relations:List<&2,Relation.Descriptor<S>>,machines:List<&2,Schema.MachineEntry<S>>}
type Built<S:Data,C:Type,R:Type,E:Data,H:Type> is Type:
  Built{app:Application<S,C,R,E,H>}
  Rejected{owners:H,relations:List<&2,Relation.Descriptor<S>>,machines:List<&2,Schema.MachineEntry<S>>}
type Description<S:Data> is Data:
  Description{ordinary:Core.Description<S>,relations:List<&2,Relation.Descriptor<S>>,machines:List<&2,Schema.MachineEntry<S>>}
def built(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,relations:List<&2,Relation.Descriptor<S>>,machines:List<&2,Schema.MachineEntry<S>>,got:Core.Built<S,C,R,E,H>) -> Built<S,C,R,E,H>:
  match got:
    case Core.Invalid{owners}:Rejected{owners,relations,machines}
    case Core.Built{app}:Built{Application{app,relations,machines}}
def empty(~S:Data,~C:Type,~R:Type,namespace:U32,debug:Core.Debug,declaration:Schema.Declaration<S,C,R>) -> Owners<S,C,R,Unit>:
  match declaration:
    case Schema.Declaration{ordinary,relations,machines}:Owners{Core.empty(~S,~C,~R,namespace,debug,ordinary),relations,machines}
def add(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),~H:Type,collected:Owners<S,C,R,H>,owner:System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>) -> Owners<S,C,R,H & System.Owner<S,Sys.Registry<S,C,R,E,A & U32,Q.Error<U>,List<&2,Out>,System.runner(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body)>>>:
  match collected:
    case Owners{core,relations,machines}:Owners{Core.add(~S,~C,~R,~E,~Ops,~A,~U,~Out,~query,~body,~H,core,owner),relations,machines}
def build(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,name:String,plan:SP.Plan<S>,collected:Owners<S,C,R,H>) -> Built<S,C,R,E,H>:
  match collected:
    case Owners{core,relations,machines}:built(~S,~C,~R,~E,~H,relations,machines,Core.build(~S,~C,~R,~E,~H,name,plan,core))
def empty_build(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,debug:Core.Debug,name:String,plan:SP.Plan<S>,declaration:Schema.Declaration<S,C,R>) -> Built<S,C,R,E,Unit>:
  build(~S,~C,~R,~E,~Unit,name,plan,empty(~S,~C,~R,namespace,debug,declaration))
def described(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,+relations:List<&2,Relation.Descriptor<S>>,+machines:List<&2,Schema.MachineEntry<S>>,got:Core.Application<S,C,R,E,H> & Maybe<&2,Core.Description<S>>) -> Application<S,C,R,E,H> & Maybe<&2,Description<S>>:
  match got:
    case (app,None{}):(Application{app,relations,machines},None{})
    case (app,Some{description}):(Application{app,relations,machines},Some{Description{description,relations,machines}})
def describe(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,app:Application<S,C,R,E,H>) -> Application<S,C,R,E,H> & Maybe<&2,Description<S>>:
  match app:
    case Application{core,relations,machines}:described(~S,~C,~R,~E,~H,relations,machines,Core.describe(~S,~C,~R,~E,~H,core))
def disable(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,app:Application<S,C,R,E,H>) -> Application<S,C,R,E,H>:
  match app:
    case Application{Core.Application{schema,_,bindings,schedule},relations,machines}:Application{Core.Application{schema,Core.Disabled{},bindings,schedule},relations,machines}
