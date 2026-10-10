import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import ./modules/ordinary-app-composer.bend as Build
import ./modules/ordinary-app-registration-fields.bend as Records
import ./modules/ordinary-app-observation-data.bend as DTO
# Retain the ordinary schema itself, never an extra debug declaration.
type Application<S:Data,C:Type,R:Type,E:Data,Owners:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Records.Fields<S>>> is Type:
  Application{schema:Schema.Schema<S,C,R>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold>}
type Description<S:Data,Rows:Data> is Data:
  Description{schema:List<&2,Fragment.Entry<S>>,registered:DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold>) -> Application<S,C,R,E,Owners,Rows,observe,fold>:
  Application{schema,app}
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,Owners,Rows,observe,fold>,flag:Bool) -> Application<S,C,R,E,Owners,Rows,observe,fold>:
  match value:
    case Application{schema,app}:Application{schema,Build.enabled(~S,~W.World<S,C,R,E>,~Owners,~Rows,~observe,~fold,app,flag)}
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,+schema:Schema.Schema<S,C,R>,result:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> Application<S,C,R,E,Owners,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (app,None{}):(Application{schema,app},None{})
    case (app,Some{view}):(Application{schema,app},Some{Description{Schema.entries(~S,~C,~R,schema),view}})
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,Owners,Rows,observe,fold>) -> Application<S,C,R,E,Owners,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match value:
    case Application{schema,app}:observed(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,schema,Build.snapshot(~S,~W.World<S,C,R,E>,~Owners,~Rows,~observe,~fold,app))
# Schema is part of ordinary typed setup; World factory/refusal contracts unchanged.
def create(~S:Data,~C:Type,~R:Type,~E:Data,~empty:Unit -> C,schema:Schema.Schema<S,C,R>,factory:W.Factory,resource:R) -> Schema.Schema<S,C,R> & W.Creation<S,C,R,E>:
  (schema,W.create(~S,~C,~R,~E,~empty,factory,resource))
