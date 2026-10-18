import Base
import ./ordinary-app-schema.bend as SchemaApp
import ./ordinary-app-composer.bend as Build
import ./event-family-routing.bend as Route
import ./world.bend as W
import ./ordinary-app-event-family-runtime.bend as App
import ./ordinary-app-dump.bend as Dump
import ./ordinary-dump-filter.bend as Filter
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Records
# Reuses the schema-derived dump while preserving the actual family/tick/readers.
def snapshot(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,criteria:Filter.Filter<S>,value:App.Application<S,C,R,P,F,Owners,Rows,observe,fold>) -> App.Application<S,C,R,P,F,Owners,Rows,observe,fold> & Maybe<&2,Dump.Dump<S>>:
  match value:
    case App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:App.returned(~S,~C,~R,~P,~F,~Owners,~Rows,~observe,~fold,~Maybe<&2,Dump.Dump<S>>,family,tick,Dump.schema_snapshot(~S,~C,~R,~P,~Owners,~Rows,~observe,~fold,~count,~components,~resources,criteria,SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}))
