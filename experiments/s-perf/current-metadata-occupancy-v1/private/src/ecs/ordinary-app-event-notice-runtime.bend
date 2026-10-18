import Base
import ./event-notice-runtime.bend as Mixed
import ./relation-commands.bend as Notice
import ./event-family-routing.bend as Route
import ./ordinary-event-family.bend as Family
import ./ordinary-app-event-family-runtime.bend as App
import ./ordinary-app-schema.bend as SchemaApp
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-schema.bend as Schema
import ./world.bend as W

def start(~S:Data,~C:Type,~R:Type,~P:Data,~D:Data,~F:Type,~H:Type,~make:D -> Nat -> F,~sync:F -> Nat -> List<&2,P> -> F,~frame:F -> Nat -> F,~retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,~inventory:F -> F & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,provision:Family.Provision<S,P,D,F,make,sync,frame,retain,inventory>,events:H,capacity:Nat,value:SchemaApp.Application<S,C,R,Notice.Notice<S,P>,Owners,Rows,observe,fold>) -> App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold>:
  match provision value:
    case Family.Provision{domains} SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}:App.Application{schema,Mixed.start(~S,~C,~R,~P,~F,~H,world,make(domains,capacity),events),owners,recipe,debug}
def inventoried(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,Notice.Notice<S,P>>,Rows,observe>,debug:Bool,returned:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>> & Maybe<&2,List<&2,String>>) -> App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match returned:
    case (runtime,names):(App.Application{schema,runtime,owners,recipe,debug},names)
def inventory(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~H:Type,~inventory:F -> F & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold>) -> App.Application<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match value:
    case App.Application{schema,runtime,owners,recipe,+debug}:inventoried(~S,~C,~R,~P,~F,~H,~Owners,~Rows,~observe,~fold,schema,owners,recipe,debug,Mixed.inventory_enabled(~S,~C,~R,~P,~F,~H,~inventory,debug,runtime))
