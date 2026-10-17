import Base
import ../../../../src/ecs/event-stream.bend as Stream
import ../../basic-world-statefree-v1/model.bend as Model
import ../../basic-world-statefree-v1/events.bend as Events
import ../../../../src/ecs/event-publication.bend as Publication
import ./core/restore-graph-runtime.bend as Runtime
import ../../../../src/ecs/restore-graph-raw-owner.bend as RawOwner
import ../../../../src/ecs/restore-graph-raw.bend as Raw
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/restore-events.bend as RestoreEvents
import ../../../../src/ecs/owned-event-family-catalog.bend as Catalog
import ../../../../src/ecs/owned-event-log.bend as Log
import ./schema.bend as Original
import ../../basic-world-statefree-v1/save.bend as OriginalSave
import ../../../../src/ecs/restore-graph-save.bend as GraphSave
import ../../../../src/ecs/snapshot.bend as Save
import ../../../../src/ecs/snapshot-data.bend as Snapshot
import ../../basic-world-statefree-v1/factory.bend as Factory
import ../../../../src/ecs/restore-graph-data.bend as Data
import ../../../../src/ecs/restore-graph-schema.bend as Lift
import ../../../../src/ecs/restore-graph-public.bend as Public
import ../../../../src/ecs/restore-graph-machine.bend as Machine
import ../../../../src/ecs/restore-schema.bend as BasicSchema
import ../../../../src/ecs/restore-public.bend as Basic
import ../../../../src/ecs/restore-data.bend as R
import ../../../../src/ecs/restore-leaf.bend as Stage
import ../../../../src/ecs/decode-data.bend as D
import ../../../../src/ecs/restore-raw-number.bend as Number
import ../../../../src/ecs/relation-commands.bend as Relation
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-failure-reader.bend as Decl
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/world.bend as W

type Mode is Data:Mode{}
type Weather is Data:Weather{}
def Components(~S:Data) -> Type:Original.UserStore(~S)
def UserResources(~S:Data) -> Type:Original.FullResources(~S)
def Machines(~S:Data) -> Type:Product.Owner<Init.State<S,Mode,U32>,Init.State<S,Weather,U32>>
def Store(~S:Data) -> Type:Relation.Store<S,Components(~S)>
def Resources(~S:Data) -> Type:Product.Owner<UserResources(~S),Machines(~S)>
def Events(~S:Data) -> Data:Relation.Notice<S,Model.Events(~S)>
def World(~S:Data) -> Type:W.World<S,Store(~S),Resources(~S),Events(~S)>
def State(~S:Data) -> Type:Original.UserState(~S)
def Recovery(~S:Data) -> Type:Original.UserRecovery(~S)
def encode(value:U32) -> D.Raw:D.Number{value}
def number(result:Number.Checked) -> Maybe<&2,U32>:
  match result:
    case Number.Invalid{}:None{}
    case Number.Value{value}:Some{value}
def decode(raw:D.Raw) -> Maybe<&2,U32>:number(Number.checked(raw))
def same(a:U32,b:U32) -> Bool:U32.is_eq(a,b)
def mode_take(~S:Data,resources:Resources(~S)) -> Resources(~S) & Init.State<S,Mode,U32>:
  match resources:
    case Product.Owner{user,Product.Owner{+mode,weather}}:(Product.Owner{user,Product.Owner{mode,weather}},mode)
def mode_put(~S:Data,resources:Resources(~S),mode:Init.State<S,Mode,U32>) -> Resources(~S):
  match resources:
    case Product.Owner{user,Product.Owner{_,weather}}:Product.Owner{user,Product.Owner{mode,weather}}
def weather_take(~S:Data,resources:Resources(~S)) -> Resources(~S) & Init.State<S,Weather,U32>:
  match resources:
    case Product.Owner{user,Product.Owner{mode,+weather}}:(Product.Owner{user,Product.Owner{mode,weather}},weather)
def weather_put(~S:Data,resources:Resources(~S),weather:Init.State<S,Weather,U32>) -> Resources(~S):
  match resources:
    case Product.Owner{user,Product.Owner{mode,_}}:Product.Owner{user,Product.Owner{mode,weather}}
def mode_declaration(~S:Data) -> OD.Declaration<S,Mode,U32,Resources(~S),Init.take_slot(~S,~Mode,~U32,~Resources(~S),~mode_take(~S),~mode_put(~S))>:
  Init.declared(~S,~Mode,~U32,~Resources(~S),~mode_take(~S),~mode_put(~S),"Mode",[0,1,2])
def mode_read(~S:Data) -> (Init.State<S,Mode,U32> -> Init.State<S,Mode,U32> & List<&2,D.Field>):Machine.read(~S,~Mode,~U32,~encode,~Resources(~S),~Init.take_slot(~S,~Mode,~U32,~Resources(~S),~mode_take(~S),~mode_put(~S)),~mode_declaration(~S))
def mode_check(~S:Data) -> (D.Field -> Machine.Dispatch):Machine.check(~S,~Mode,~U32,~D.Integer{},~decode,~same,~Resources(~S),~Init.take_slot(~S,~Mode,~U32,~Resources(~S),~mode_take(~S),~mode_put(~S)),~mode_declaration(~S))
def mode_clear(~S:Data) -> (Init.State<S,Mode,U32> -> Init.State<S,Mode,U32>):Machine.clear(~S,~Mode,~U32)
def mode_install(~S:Data) -> (Init.State<S,Mode,U32> -> List<&2,D.Field> -> Init.State<S,Mode,U32>):Machine.install(~S,~Mode,~U32,~decode,~Resources(~S),~Init.take_slot(~S,~Mode,~U32,~Resources(~S),~mode_take(~S),~mode_put(~S)),~mode_declaration(~S))
def mode_schema(~S:Data) -> Machine.Schema<Init.State<S,Mode,U32>,mode_read(~S),mode_check(~S),mode_clear(~S),mode_install(~S)>:
  Machine.machine(~S,~Mode,~U32,~D.Integer{},~encode,~decode,~same,~Resources(~S),~Init.take_slot(~S,~Mode,~U32,~Resources(~S),~mode_take(~S),~mode_put(~S)),~mode_declaration(~S))
def weather_declaration(~S:Data) -> OD.Declaration<S,Weather,U32,Resources(~S),Init.take_slot(~S,~Weather,~U32,~Resources(~S),~weather_take(~S),~weather_put(~S))>:
  OD.Declaration{"Weather"}
def weather_read(~S:Data) -> (Init.State<S,Weather,U32> -> Init.State<S,Weather,U32> & List<&2,D.Field>):Machine.read(~S,~Weather,~U32,~encode,~Resources(~S),~Init.take_slot(~S,~Weather,~U32,~Resources(~S),~weather_take(~S),~weather_put(~S)),~weather_declaration(~S))
def weather_check(~S:Data) -> (D.Field -> Machine.Dispatch):Machine.check(~S,~Weather,~U32,~D.Integer{},~decode,~same,~Resources(~S),~Init.take_slot(~S,~Weather,~U32,~Resources(~S),~weather_take(~S),~weather_put(~S)),~weather_declaration(~S))
def weather_clear(~S:Data) -> (Init.State<S,Weather,U32> -> Init.State<S,Weather,U32>):Machine.clear(~S,~Weather,~U32)
def weather_install(~S:Data) -> (Init.State<S,Weather,U32> -> List<&2,D.Field> -> Init.State<S,Weather,U32>):Machine.install(~S,~Weather,~U32,~decode,~Resources(~S),~Init.take_slot(~S,~Weather,~U32,~Resources(~S),~weather_take(~S),~weather_put(~S)),~weather_declaration(~S))
def weather_schema(~S:Data) -> Machine.Schema<Init.State<S,Weather,U32>,weather_read(~S),weather_check(~S),weather_clear(~S),weather_install(~S)>:
  Machine.machine(~S,~Weather,~U32,~D.Integer{},~encode,~decode,~same,~Resources(~S),~Init.take_slot(~S,~Weather,~U32,~Resources(~S),~weather_take(~S),~weather_put(~S)),~weather_declaration(~S))
def machine_read(~S:Data) -> (Machines(~S) -> Machines(~S) & List<&2,D.Field>):Machine.product_read(~Init.State<S,Mode,U32>,~Init.State<S,Weather,U32>,~mode_read(~S),~weather_read(~S))
def machine_check(~S:Data) -> (D.Field -> Machine.Dispatch):Machine.product_check(~mode_check(~S),~weather_check(~S))
def machine_clear(~S:Data) -> (Machines(~S) -> Machines(~S)):Machine.product_clear(~Init.State<S,Mode,U32>,~Init.State<S,Weather,U32>,~mode_clear(~S),~weather_clear(~S))
def machine_install(~S:Data) -> (Machines(~S) -> List<&2,D.Field> -> Machines(~S)):Machine.product_install(~Init.State<S,Mode,U32>,~Init.State<S,Weather,U32>,~mode_install(~S),~weather_install(~S))
def MachineSchema(~S:Data) -> Data:Machine.Schema<Machines(~S),machine_read(~S),machine_check(~S),machine_clear(~S),machine_install(~S)>
def machine_schema(~S:Data) -> MachineSchema(~S):
  Machine.product(~Init.State<S,Mode,U32>,~Init.State<S,Weather,U32>,~mode_read(~S),~mode_check(~S),~mode_clear(~S),~mode_install(~S),~weather_read(~S),~weather_check(~S),~weather_clear(~S),~weather_install(~S),mode_schema(~S),weather_schema(~S))
def link(~S:Data) -> Decl.Declaration<S>:Decl.relation(~S,G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}})
def parent(~S:Data) -> Decl.Declaration<S>:Decl.relation(~S,G.Descriptor{2,"Parent","Children",G.Hierarchy{}})
def declarations(~S:Data) -> List<&2,Decl.Declaration<S>>:[link(~S),parent(~S)]
def clear(~S:Data) -> (Store(~S) -> W.Handle<S> -> Store(~S) & List<&2,R.Change<S>>):Lift.clear(~S,~Components(~S),~Original.User_clear(~S))
def insert(~S:Data) -> (Store(~S) -> Resources(~S) -> State(~S) -> List<&2,R.Binding<S>> -> U32 -> (Store(~S) & Resources(~S)) & State(~S)):Lift.insert(~S,~Components(~S),~UserResources(~S),~Machines(~S),~State(~S),~String,~Original.User_stage(~S),~Original.User_release(~S),~Original.User_clear(~S),~Original.Full_insert(~S))
def Schema(~S:Data) -> Data:BasicSchema.Schema<S,Store(~S),Resources(~S),State(~S),String,Original.User_stage(~S),Original.User_release(~S),clear(~S),insert(~S),Recovery(~S),Original.User_commit(~S),Original.User_take(~S)>
def schema(~S:Data) -> Schema(~S):Lift.lift(~S,~Components(~S),~UserResources(~S),~Machines(~S),~State(~S),~String,~Original.User_stage(~S),~Original.User_release(~S),~Original.User_clear(~S),~Original.Full_insert(~S),~Recovery(~S),~Original.User_commit(~S),~Original.User_take(~S),Original.Full_schema(~S))
def Owned(~S:Data) -> Type:Public.Owner<S,Components(~S),UserResources(~S),Machines(~S),Events(~S),State(~S),String,Original.User_stage(~S),Original.User_release(~S),clear(~S),insert(~S),Recovery(~S),Original.User_commit(~S),Original.User_take(~S),machine_read(~S),machine_check(~S),machine_clear(~S),machine_install(~S)>
def Returned(~S:Data) -> Type:Public.Returned<S,World(~S),Owned(~S),Recovery(~S),String>
def emit(~S:Data,change:R.Change<S>) -> Events(~S):Relation.Original{Publication.Publication{[],[change]}}
def owned(~S:Data,state:State(~S)) -> Owned(~S):Public.owned(~S,~Components(~S),~UserResources(~S),~Machines(~S),~Events(~S),~State(~S),~String,~Original.User_stage(~S),~Original.User_release(~S),~clear(~S),~insert(~S),~Recovery(~S),~Original.User_commit(~S),~Original.User_take(~S),~machine_read(~S),~machine_check(~S),~machine_clear(~S),~machine_install(~S),Basic.Owner{schema(~S),state},declarations(~S),machine_schema(~S))
def restore(~S:Data,owner:Owned(~S),world:World(~S),input:Data.Snapshot) -> Returned(~S):Public.run(~S,~Components(~S),~UserResources(~S),~Machines(~S),~Events(~S),~State(~S),~String,~Original.User_stage(~S),~Original.User_release(~S),~clear(~S),~insert(~S),~Recovery(~S),~Original.User_commit(~S),~Original.User_take(~S),~machine_read(~S),~machine_check(~S),~machine_clear(~S),~machine_install(~S),~emit(~S),owner,world,input)
def basic_save(~S:Data,world:World(~S)) -> World(~S) & Snapshot.Snapshot:
  Save.save(~S,~Store(~S),~Resources(~S),~Events(~S),~Lift.save_components(~S,~Components(~S),~OriginalSave.User_components(~S)),~Lift.save_resources(~UserResources(~S),~Machines(~S),~OriginalSave.full_resources(~S)),Lift.save_schema(~S,~Components(~S),~UserResources(~S),~Machines(~S),~OriginalSave.User_components(~S),~OriginalSave.full_resources(~S),OriginalSave.schema(~S)),world)
def save(~S:Data,world:World(~S)) -> World(~S) & Data.Snapshot:
  GraphSave.save(~S,~Components(~S),~UserResources(~S),~Machines(~S),~Events(~S),~machine_read(~S),~basic_save(~S),declarations(~S),world)
def Receipt() -> Type:Product.Owner<List<Log.Row<Array<U32>>>,Unit>
def retain_logs(~S:Data) -> (Model.Logs() -> List<&2,Model.Events(~S)> -> Model.Logs() & Receipt()):Catalog.pair_retain(~Nat,~R.Change<S>,~Log.Log<Array<U32>>,~Unit,~List<Log.Row<Array<U32>>>,~Unit,~Log.retain(~Array<U32>),~RestoreEvents.data_retain(~R.Change<S>))
def drain_logs() -> (Model.Logs() -> Model.Logs() & Receipt()):Catalog.pair_drain(~Log.Log<Array<U32>>,~Unit,~List<Log.Row<Array<U32>>>,~Unit,~Log.drain(~Array<U32>),~RestoreEvents.data_drain)
def clear_streams(~S:Data) -> (Events.FamilyOwner(~S) -> Events.FamilyOwner(~S)):Catalog.pair_clear(~Stream.Stream<S,Nat>,~Stream.Stream<S,R.Change<S>>,~Catalog.leaf_clear(~S),~RestoreEvents.data_clear(~S,~R.Change<S>))
def CatalogType(~S:Data) -> Data:Catalog.Catalog<Model.Events(~S),Model.Logs(),Events.FamilyOwner(~S),Receipt(),retain_logs(~S),drain_logs(),clear_streams(~S)>
def catalog(~S:Data) -> CatalogType(~S):Catalog.both(~Nat,~Log.Log<Array<U32>>,~Stream.Stream<S,Nat>,~List<Log.Row<Array<U32>>>,~Log.retain(~Array<U32>),~Log.drain(~Array<U32>),~Catalog.leaf_clear(~S),~R.Change<S>,~Unit,~Stream.Stream<S,R.Change<S>>,~Unit,~RestoreEvents.data_retain(~R.Change<S>),~RestoreEvents.data_drain,~RestoreEvents.data_clear(~S,~R.Change<S>),~Catalog.leaf(~S,~Array<U32>),~RestoreEvents.data_catalog(~S,~R.Change<S>,Events.lifecycle(~S)))
def RuntimeType(~S:Data) -> Type:Route.Runtime<S,Store(~S),Resources(~S),Events(~S),Mixed.State<S,Model.Events(~S),Events.FamilyOwner(~S),Array<U32>>>
def RuntimeReturned(~S:Data) -> Type:Runtime.Returned<S,RuntimeType(~S),Owned(~S),Recovery(~S),Receipt(),String>
def RawReturned(~S:Data) -> Type:RawOwner.Returned<Owned(~S),RuntimeType(~S),RuntimeReturned(~S)>
def restore_runtime(~S:Data,owner:Owned(~S),runtime:RuntimeType(~S),input:Data.Snapshot) -> RuntimeReturned(~S):Runtime.run(~S,~Components(~S),~Original.UserResources(~S),~Model.Logs(),~Machines(~S),~Model.Events(~S),~Events.FamilyOwner(~S),~Array<U32>,~Receipt(),~State(~S),~String,~Original.User_stage(~S),~Original.User_release(~S),~clear(~S),~insert(~S),~Recovery(~S),~Original.User_commit(~S),~Original.User_take(~S),~machine_read(~S),~machine_check(~S),~machine_clear(~S),~machine_install(~S),~emit(~S),~retain_logs(~S),~drain_logs(),~clear_streams(~S),~catalog(~S),~Events.sync(~S),owner,runtime,input)
def restore_raw(~S:Data,owner:Owned(~S),runtime:RuntimeType(~S),input:D.Raw) -> RawReturned(~S):RawOwner.run(~Owned(~S),~RuntimeType(~S),~RuntimeReturned(~S),~restore_runtime(~S),owner,runtime,input)
