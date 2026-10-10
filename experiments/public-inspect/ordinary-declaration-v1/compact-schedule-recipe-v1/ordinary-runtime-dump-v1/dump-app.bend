import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-eligibility.bend as Eligible
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-render.bend as Render
# Ordinary provisioning generates the erased presence/presentation operations.
# The schema is retained once; forged raw index bridges remain trusted setup.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>,-count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,-components:C -> U32 -> C & List<&2,Maybe<&2,String>>,-resources:R -> R & List<&2,Maybe<&2,String>>> is Type:
  Application{schema:Schema.Schema<S,C,R>,app:Build.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold>}
type Dump<S:Data> is Data:
  Dump{alive:U32,rows:List<&2,Filter.Row<S>>,resources:List<&2,Filter.Value>}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,schema:Schema.Schema<S,C,R>,app:Build.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold>) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources>:
  Application{schema,app}
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,value:Application<S,C,R,E,H,Rows,observe,fold,count,components,resources>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources>:
  match value:
    case Application{schema,Build.Registered{world,owners,recipe,_}}:Application{schema,Build.Registered{world,owners,recipe,flag}}
def create(~S:Data,~C:Type,~R:Type,~E:Data,~empty:Unit -> C,schema:Schema.Schema<S,C,R>,factory:W.Factory,resource:R) -> Schema.Schema<S,C,R> & W.Creation<S,C,R,E>:
  SchemaApp.create(~S,~C,~R,~E,~empty,schema,factory,resource)
def resource_returned(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:C,events:List<&2,E>,pending:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,result:R & List<&2,Maybe<&2,String>>) -> W.World<S,C,R,E> & List<&2,Maybe<&2,String>>:
  match result:
    case (resource,slots):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},slots)
def resource_world(~S:Data,~C:Type,~R:Type,~E:Data,~read:R -> R & List<&2,Maybe<&2,String>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Maybe<&2,String>>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:resource_returned(~S,~C,~R,~E,namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock,read(resource))
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,+schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,alive:U32,rows:List<&2,Filter.Row<S>>,result:W.World<S,C,R,E> & List<&2,Maybe<&2,String>>) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources> & Maybe<&2,Dump<S>>:
  match result:
    case (world,slots):(Application{schema,Build.Registered{world,owners,recipe,True{}}},Some{Dump{alive,rows,Render.resources(~S,List.zip(&2,Fragment.Entry<S>,&2,Maybe<&2,String>,Schema.entries(~S,~C,~R,schema),slots))}})
def rendered(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,alive:U32,result:W.World<S,C,R,E> & List<&2,Filter.Row<S>>) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources> & Maybe<&2,Dump<S>>:
  match result:
    case (world,rows):finished(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,schema,owners,recipe,alive,rows,resource_world(~S,~C,~R,~E,~resources,world))
def selected(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,+schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,alive:U32,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources> & Maybe<&2,Dump<S>>:
  match result:
    case (world,handles):rendered(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,schema,owners,recipe,alive,W.with_store(~S,~C,~R,~E,~List<&2,Filter.Row<S>>,store => Render.rows(~S,~C,~components,handles,Schema.entries(~S,~C,~R,schema),store),world))
def handled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,+schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,ids:Maybe<&2,List<&2,U32>>,required:List<&2,Filter.Component<S>>,limit:Maybe<&2,Nat>,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources> & Maybe<&2,Dump<S>>:
  match result:
    case (world,+handles):selected(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,schema,owners,recipe,U32.from_nat(List.length(&2,W.Handle<S>,handles)),W.with_store(~S,~C,~R,~E,~List<&2,W.Handle<S>>,store => Eligible.scan(~S,~C,~count,handles,Schema.entries(~S,~C,~R,schema),ids,required,limit,store),world))
def scanned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,+schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,criteria:Filter.Filter<S>,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources> & Maybe<&2,Dump<S>>:
  match criteria:
    case Filter.Filter{ids,required,limit}:handled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,schema,owners,recipe,ids,required,limit,result)
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,criteria:Filter.Filter<S>,value:Application<S,C,R,E,H,Rows,observe,fold,count,components,resources>) -> Application<S,C,R,E,H,Rows,observe,fold,count,components,resources> & Maybe<&2,Dump<S>>:
  match value:
    case Application{schema,Build.Registered{world,owners,recipe,False{}}}:(Application{schema,Build.Registered{world,owners,recipe,False{}}},None{})
    case Application{schema,Build.Registered{world,owners,recipe,True{}}}:scanned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,schema,owners,recipe,criteria,W.handles(~S,~C,~R,~E,world))

def schema_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,result:Application<S,C,R,E,H,Rows,observe,fold,count,components,resources> & Maybe<&2,Dump<S>>) -> SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Dump<S>>:
  match result:
    case (Application{schema,app},view):(SchemaApp.Application{schema,app},view)
def schema_snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,criteria:Filter.Filter<S>,value:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>) -> SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Dump<S>>:
  match value:
    case SchemaApp.Application{schema,app}:schema_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,~components,~resources,criteria,Application{schema,app}))
