import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as FamilyRuntime
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
# Family is retained opaquely, including actual streams, journal and reader owners.
# Debug round-trips the sole World without synchronization, trim, frame or dispatch.
type Application<S:Data,C:Type,R:Type,P:Data,F:Type,Owners:Type,Rows:Data,-observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Records.Fields<S>>> is Type:
  Application{schema:Schema.Schema<S,C,R>,runtime:Route.Runtime<S,C,R,P,F>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,P>,Rows,observe>,debug:Bool}
def attached(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,family:F,tick:Nat,value:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold>) -> Application<S,C,R,P,F,Owners,Rows,observe,fold>:
  match value:
    case SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}:Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}
def returned(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~Out:Type,family:F,tick:Nat,result:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold> & Out) -> Application<S,C,R,P,F,Owners,Rows,observe,fold> & Out:
  match result:
    case (SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},output):(Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug},output)
def with_previous(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~Out:Type,action:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold> -> SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold> & Out,value:Application<S,C,R,P,F,Owners,Rows,observe,fold>) -> Application<S,C,R,P,F,Owners,Rows,observe,fold> & Out:
  match value:
    case Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:returned(~S,~C,~R,~P,~F,~Owners,~Rows,~observe,~fold,~Out,family,tick,action(SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}))
def snapshot(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,P,F,Owners,Rows,observe,fold>) -> Application<S,C,R,P,F,Owners,Rows,observe,fold> & Maybe<&2,SchemaApp.Description<S,Rows>>:
  with_previous(~S,~C,~R,~P,~F,~Owners,~Rows,~observe,~fold,~Maybe<&2,SchemaApp.Description<S,Rows>>,SchemaApp.snapshot(~S,~C,~R,~P,~Owners,~Rows,~observe,~fold),value)
def start(~S:Data,~C:Type,~R:Type,~P:Data,~Domains:Data,~Leaves:Type,~EventOwners:Type,~make:Domains -> Nat -> Leaves,~sync:Leaves -> Nat -> List<&2,P> -> Leaves,~frame:Leaves -> Nat -> Leaves,~retain:Leaves -> Nat -> List<&2,P> -> Leaves & List<&2,P>,~inventory:Leaves -> Leaves & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,provision:Family.Provision<S,P,Domains,Leaves,make,sync,frame,retain,inventory>,events:EventOwners,capacity:Nat,value:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold>) -> Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold>:
  match value:
    case SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}:Application{schema,FamilyRuntime.setup(~S,~C,~R,~P,~Domains,~Leaves,~EventOwners,~make,~sync,~frame,~retain,~inventory,world,provision,events,capacity),owners,recipe,debug}
def enabled(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,P,F,Owners,Rows,observe,fold>,flag:Bool) -> Application<S,C,R,P,F,Owners,Rows,observe,fold>:
  match value:
    case Application{schema,runtime,owners,recipe,_}:Application{schema,runtime,owners,recipe,flag}
def inventory_returned(~S:Data,~C:Type,~R:Type,~P:Data,~Leaves:Type,~EventOwners:Type,~inventory:Leaves -> Leaves & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,P>,Rows,observe>,debug:Bool,result:Route.Runtime<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>> & Maybe<&2,List<&2,String>>) -> Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match result:
    case (runtime,names):(Application{schema,runtime,owners,recipe,debug},names)
def inventory(~S:Data,~C:Type,~R:Type,~P:Data,~Leaves:Type,~EventOwners:Type,~inventory:Leaves -> Leaves & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold>) -> Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match value:
    case Application{schema,runtime,owners,recipe,+debug}:inventory_returned(~S,~C,~R,~P,~Leaves,~EventOwners,~inventory,~Owners,~Rows,~observe,~fold,schema,owners,recipe,debug,FamilyRuntime.inventory_enabled(~S,~C,~R,~P,~Leaves,~EventOwners,~inventory,debug,runtime))
