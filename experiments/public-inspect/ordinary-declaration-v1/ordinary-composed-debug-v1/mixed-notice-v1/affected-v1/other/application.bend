import Base
import ./runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Notice
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def start(~S:Data,~C:Type,~R:Type,~P:Data,~D:Data,~F:Type,~H:Type,~make:D -> Nat -> F,~sync:F -> Nat -> List<&2,P> -> F,~frame:F -> Nat -> F,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,~inventory:F -> F & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,provision:Family.Provision<S,P,D,F,make,sync,frame,retain,inventory>,events:H,capacity:Nat,value:SchemaApp.Application<S,C,R,Notice.Notice<S,P>,Owners,Rows,observe,fold>) -> App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold>:
  match provision value:
    case Family.Provision{domains} SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}:App.Application{schema,Mixed.start(~S,~C,~R,~P,~F,~H,world,make(domains,capacity),events),owners,recipe,debug}
def inventoried(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,Notice.Notice<S,P>>,Rows,observe>,debug:Bool,returned:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & Maybe<&2,List<&2,String>>) -> App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match returned:
    case (runtime,names):(App.Application{schema,runtime,owners,recipe,debug},names)
def inventory(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~inventory:F -> F & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold>) -> App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match value:
    case App.Application{schema,runtime,owners,recipe,+debug}:inventoried(~S,~C,~R,~P,~F,~H,~Owners,~Rows,~observe,~fold,schema,owners,recipe,debug,Mixed.inventory_enabled(~S,~C,~R,~P,~F,~H,~inventory,debug,runtime))
