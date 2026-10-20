import Base
import ./world.bend as W
import ./ordinary-schema.bend as Schema
import ./schema-fragments.bend as Fragment
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
# Retain the ordinary schema itself, never an extra debug declaration.
# Schema-scoped App retaining the ordinary schema and registered owner
# collection. Construct via attached; raw fields remain trusted setup and
# cannot replace runtime namespace/registration validation.
type Application<S:Data,C:Type,R:Type,E:Data,Owners:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Records.Fields<S>>> is Type:
  Application{schema:Schema.Schema<S,C,R>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold>}
# Detached ordinary schema entries and registered application observations.
# This enabled-debug view contains no live owners and is not a restorable
# runtime checkpoint or a replacement for typed registration authority.
type Description<S:Data,Rows:Data> is Data:
  Description{schema:List<&2,Fragment.Entry<S>>,registered:DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>}
# Pair a matching schema with registered World/system owners. Does not
# validate raw metadata/storage consistency, execute systems or build a schedule.
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold>) -> Application<S,C,R,E,Owners,Rows,observe,fold>:
  Application{schema,app}
# Toggle declaration-derived debug observation, returning the retained App.
# Does not immediately invoke folds or World projections.
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,Owners,Rows,observe,fold>,flag:Bool) -> Application<S,C,R,E,Owners,Rows,observe,fold>:
  match value:
    case Application{schema,app}:Application{schema,Build.enabled(~S,~W.World<S,C,R,E>,~Owners,~Rows,~observe,~fold,app,flag)}
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,+schema:Schema.Schema<S,C,R>,result:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> Application<S,C,R,E,Owners,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (app,None{}):(Application{schema,app},None{})
    case (app,Some{view}):(Application{schema,app},Some{Description{Schema.entries(~S,~C,~R,schema),view}})
# Return App and Some schema/registration observation when enabled, or
# None when disabled. Uses existing owner-threading folds/projections; does not
# run systems or consume their reader cursors. Not a restorable World save.
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,Owners,Rows,observe,fold>) -> Application<S,C,R,E,Owners,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match value:
    case Application{schema,app}:observed(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,schema,Build.snapshot(~S,~W.World<S,C,R,E>,~Owners,~Rows,~observe,~fold,app))
# Schema is part of ordinary typed setup; World factory/refusal contracts unchanged.
# Trusted factory-based World creation returning schema and Creation.
# Actual empty storage comes from the supplied callback; refusal retains the
# caller resource owner. Prefer world-io.create for independent IO namespaces.
def create(~S:Data,~C:Type,~R:Type,~E:Data,~empty:Unit -> C,schema:Schema.Schema<S,C,R>,factory:W.Factory,resource:R) -> Schema.Schema<S,C,R> & W.Creation<S,C,R,E>:
  (schema,W.create(~S,~C,~R,~E,~empty,factory,resource))
