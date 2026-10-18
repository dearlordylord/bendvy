import Base
import ./world.bend as W
import ./ordinary-app-schedule.bend as Schedule
import ./ordinary-app-schema.bend as SchemaApp
import ./ordinary-app-composer.bend as Build
import ./ordinary-schema.bend as Schema
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-app-access.bend as Access
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
# Retained operational Plan selects actual registry identity; no parallel catalog.
type Index is Data:
  Index{namespace:U32,name:String,entries:List<&2,Access.Entry>}
def selected(~S:Data,found:Bool,record:Fields.Fields<S>,rest:List<&2,Fields.Fields<S>>) -> List<&2,Fields.Fields<S>>:
  match found:
    case True{}:record <> rest
    case False{}:rest
def identified(~S:Data,namespace:U32,id:U32,+record:Fields.Fields<S>,rest:List<&2,Fields.Fields<S>>) -> List<&2,Fields.Fields<S>>:
  match record:
    case Fields.Fields{otherNamespace,otherId,_,_,_,_,_,_}:selected(~S,Bool.and(U32.is_eq(namespace,otherNamespace),U32.is_eq(id,otherId)),record,rest)
def matching(~S:Data,+namespace:U32,+id:U32,records:List<&2,Fields.Fields<S>>) -> List<&2,Fields.Fields<S>>:
  match records:
    case []:[]
    case +record <> rest:identified(~S,namespace,id,record,matching(~S,namespace,id,rest))
def step(~S:Data,namespace:U32,records:List<&2,Fields.Fields<S>>,planned:Schedule.PlannedStep<S>) -> List<&2,Fields.Fields<S>>:
  match planned:
    case Schedule.PlannedStep{Sch.System{id,_},_}:matching(~S,namespace,id,records)
    case _ :[]
def placed(~S:Data,steps:List<&2,Schedule.PlannedStep<S>>,+namespace:U32,+records:List<&2,Fields.Fields<S>>) -> List<&2,Fields.Fields<S>>:
  match steps:
    case []:[]
    case first <> rest:List.append(&2,Fields.Fields<S>,step(~S,namespace,records,first),placed(~S,rest,namespace,records))
def folded(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,+plan:SP.Plan<S>,+namespace:U32,+name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:H & List<&2,Fields.Fields<S>>) -> Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Index>:
  match result:
    case (owners,records):(Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,True{}}},plan,namespace,name,steps,needs},Some{Index{namespace,name,Access.grouped(Access.fields(~S,placed(~S,Schedule.planned(~S,plan),namespace,records)),[])}})
def index(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,value:Schedule.Application<S,C,R,E,H,Rows,observe,fold>) -> Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Index>:
  match value:
    case Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,False{}}},plan,namespace,name,steps,needs}:(Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,False{}}},plan,namespace,name,steps,needs},None{})
    case Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,True{}}},plan,namespace,name,steps,needs}:folded(~S,~C,~R,~E,~H,~Rows,~observe,~fold,schema,world,recipe,plan,namespace,name,steps,needs,fold(owners))
