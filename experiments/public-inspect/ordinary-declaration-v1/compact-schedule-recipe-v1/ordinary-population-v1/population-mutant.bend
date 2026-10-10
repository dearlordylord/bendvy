import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Provision
# Existing Schema/App types remain unchanged. There is one retained Schema.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>,-count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>> is Type:
  Application{app:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>}
type ComponentCount is Data:
  ComponentCount{key:String,count:U32}
type Population is Data:
  Population{alive:U32,components:List<&2,ComponentCount>}
# Ordinary component/resource/product builders make entries and slots together.
# Raw manually forged Provision values are trusted setup, not validated adapters.
def rows(~S:Data,pairs:List<&1,Fragment.Entry<S> & Maybe<&2,U32>>) -> List<&2,ComponentCount>:
  match pairs:
    case []:[]
    case (Fragment.Entry{Fragment.Component{},key,_},Some{count}) <> rest:ComponentCount{key,count} <> rows(~S,rest)
    case _ <> rest:rows(~S,rest)
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,provision:Provision.Provision<S,C,R,empty,count>,app:Build.Registered<S,W.World<S,C,R,E>,H,Rows,observe,fold>) -> Application<S,C,R,E,H,Rows,observe,fold,count>:
  match provision:
    case Provision.Provision{schema}:Application{SchemaApp.attached(~S,~C,~R,~E,~H,~Rows,~observe,~fold,schema,app)}
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,app:Application<S,C,R,E,H,Rows,observe,fold,count>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold,count>:
  match app:
    case Application{app}:Application{SchemaApp.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,flag)}
def counted(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,+schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,alive:U32,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:R,events:List<&2,E>,pending:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,result:C & List<&2,Maybe<&2,U32>>) -> Application<S,C,R,E,H,Rows,observe,fold,count> & Maybe<&2,Population>:
  match result:
    case (store,slots):(Application{SchemaApp.Application{schema,Build.Registered{W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},owners,recipe,True{}}}},Some{Population{alive,rows(~S,List.zip(&2,Fragment.Entry<S>,&2,Maybe<&2,U32>,Schema.entries(~S,~C,~R,schema),slots))}})
def scanned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> Application<S,C,R,E,H,Rows,observe,fold,count> & Maybe<&2,Population>:
  match result:
    case (W.World{+namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},+handles):counted(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,schema,owners,recipe,U32.from_nat(List.length(&2,W.Handle<S>,handles)),namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,count(store,W.Handle{namespace,3} <> handles))
def population(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,app:Application<S,C,R,E,H,Rows,observe,fold,count>) -> Application<S,C,R,E,H,Rows,observe,fold,count> & Maybe<&2,Population>:
  match app:
    case Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,False{}}}}:(Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,False{}}}},None{})
    case Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,True{}}}}:scanned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,schema,owners,recipe,W.handles(~S,~C,~R,~E,world))

def returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,result:Application<S,C,R,E,H,Rows,observe,fold,count> & Maybe<&2,Population>) -> SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Population>:
  match result:
    case (Application{app},view):(app,view)
def schema_population(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,app:SchemaApp.Application<S,C,R,E,H,Rows,observe,fold>) -> SchemaApp.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Population>:
  returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,population(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~count,Application{app}))
