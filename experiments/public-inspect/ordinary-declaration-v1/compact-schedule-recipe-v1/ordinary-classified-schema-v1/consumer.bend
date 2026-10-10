import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Persist
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-builtin.bend as Builtin
import schema-fragments.bend as Fragment
import ordinary-schema.bend as Schema
import ordinary-schema-provision.bend as Provision
import ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
type S is Data:
  S{}
type Mode is Data:
  PlainMode{}
  TransientMode{}
  ConstructedMode{}
  BareMode{}
def component_identity() -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Payload")
def resource_identity() -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Counter")
def project_node(left:Array<U32> & D.Raw,right:Array<U32> & D.Raw) -> Array<U32> & D.Raw:
  match left right:
    case (left,a),(right,b):(ANode{left,right},D.Array{[a,b]})
def project(value:Array<U32>) -> Array<U32> & D.Raw:
  match value:
    case ALeaf{+value}:(ALeaf{value},D.Number{value})
    case ANode{left,right}:project_node(project(left),project(right))
def component_constructed() -> Persist.Constructed<S,Array<U32>,component_identity(),project>:Persist.constructed(~S,~Array<U32>,~component_identity(),~project,D.Literal{D.Number{42}})
def resource_constructed() -> Persist.Constructed<S,Array<U32>,resource_identity(),project>:Persist.constructed(~S,~Array<U32>,~resource_identity(),~project,D.Literal{D.Number{42}})
def component(mode:Mode) -> Provision.Provision<S,Col.Column<S,Array<U32>>,Unit,Provision.component_empty(~S,~Array<U32>),Provision.component_count(~S,~Array<U32>)>:
  match mode:
    case PlainMode{}:Provision.component_plain(~S,~Array<U32>,~component_identity(),Persist.plain(~S,~Array<U32>,~component_identity()))
    case TransientMode{}:Provision.component_transient(~S,~Array<U32>,~component_identity(),Persist.transient(~S,~Array<U32>,~component_identity()))
    case ConstructedMode{}:Provision.component_constructed(~S,~Array<U32>,~component_identity(),~project,component_constructed())
    case BareMode{}:Provision.component(~S,~Array<U32>,component_identity())
def resource(mode:Mode) -> Provision.Provision<S,Unit,Array<U32>,Provision.resource_empty,Provision.resource_count(~S)>:
  match mode:
    case PlainMode{}:Provision.resource_plain(~S,~Array<U32>,~resource_identity(),Persist.plain(~S,~Array<U32>,~resource_identity()))
    case TransientMode{}:Provision.resource_transient(~S,~Array<U32>,~resource_identity(),Persist.transient(~S,~Array<U32>,~resource_identity()))
    case ConstructedMode{}:Provision.resource_constructed(~S,~Array<U32>,~resource_identity(),~project,resource_constructed())
    case BareMode{}:Provision.resource(~S,~Array<U32>,Schema.resource(~S,~Array<U32>,"Counter"))
def C() -> Type:Product.Owner<Col.Column<S,Array<U32>>,Unit>
def R() -> Type:Product.Owner<Unit,Array<U32>>
def World() -> Type:W.World<S,C(),R(),U32>
def count() -> C() -> List<&2,W.Handle<S>> -> C() & List<&2,Maybe<&2,U32>>:Provision.product_count(~S,~Col.Column<S,Array<U32>>,~Unit,~Provision.component_count(~S,~Array<U32>),~Provision.resource_count(~S))
def empty() -> Unit -> C():Provision.product_empty(~Col.Column<S,Array<U32>>,~Unit,~Provision.component_empty(~S,~Array<U32>),~Provision.resource_empty)
def setup(+mode:Mode) -> Provision.Provision<S,C(),R(),empty(),count()>:Provision.product(~S,~Col.Column<S,Array<U32>>,~Unit,~Unit,~Array<U32>,~Provision.component_empty(~S,~Array<U32>),~Provision.component_count(~S,~Array<U32>),~Provision.resource_empty,~Provision.resource_count(~S),component(mode),resource(mode))
def Application() -> Type:App.Application<S,C(),R(),U32,Unit,Unit,Build.empty_observe(~World()),Leaf.empty(~S)>
def classification(value:Fragment.PersistenceKind) -> String:
  match value:
    case Fragment.Plain{}:"Plain"
    case Fragment.Transient{}:"Transient"
    case Fragment.Constructed{}:"Constructed"
def kind(value:Fragment.RegistryKind) -> String:
  match value:
    case Fragment.Component{}:"component"
    case Fragment.Resource{}:"resource"
    case Fragment.Event{}:"event"
    case Fragment.Relation{}:"relation"
    case Fragment.Service{}:"service"
def entry(value:Fragment.Entry<S>) -> String:
  match value:
    case Fragment.Entry{tag,key,name}:kind(tag) ++ ":" ++ key ++ ":" ++ name ++ ":unclassified"
    case Fragment.Classified{tag,key,name,persistence}:kind(tag) ++ ":" ++ key ++ ":" ++ name ++ ":" ++ classification(persistence)
def description(value:Maybe<&2,App.Description<S,Unit>>) -> String:
  match value:
    case None{}:"description=None"
    case Some{App.Description{schema,_}}:"description=" ++ List.show(~&2,~Fragment.Entry<S>,~entry,schema)
def observed(schema:Schema.Schema<S,C(),R()>,flag:Bool,text:String,result:World() & String) -> Application() & String:
  match result:
    case (world,physical):(App.Application{schema,Build.enabled(~S,~World(),~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~S),Build.empty(~S,~World(),world),flag)},text ++ "|" ++ physical)
def snapshot_world(result:Application() & Maybe<&2,App.Description<S,Unit>>) -> Application() & String:
  match result:
    case (App.Application{schema,Build.Registered{world,_,_,flag}},view):observed(schema,flag,description(view),O.mixed_world(~S,~Array<U32>,~R(),~U32,~Builtin.array,~O.mixed_resource,~U32.show,world))
def snapshot(app:Application(),flag:Bool) -> Application() & String:snapshot_world(App.snapshot(~S,~C(),~R(),~U32,~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~S),App.enabled(~S,~C(),~R(),~U32,~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~S),app,flag)))
def checked(value:D.Checked) -> String:
  match value:
    case D.Accepted{_}:"Accepted"
    case D.Rejected{_}:"Rejected"
def prepared_resource(result:Persist.Constructed<S,Array<U32>,resource_identity(),project> & D.Receipt<Array<U32>>) -> R() & String:
  match result:
    case (_,D.Receipt{owner,result}):(Product.Owner{Unit{},owner},checked(result))
def prepare_resource(value:R()) -> R() & String:
  match value:
    case Product.Owner{_,owner}:prepared_resource(Persist.prepare(~S,~Array<U32>,~resource_identity(),~project,resource_constructed(),owner))
def repair_resource(value:R()) -> R() & Unit:
  match value:
    case Product.Owner{_,owner}:(Product.Owner{Unit{},owner[0] <- 42},Unit{})
def operation_returned(schema:Schema.Schema<S,C(),R()>,flag:Bool,result:World() & String) -> Application() & String:
  match result:
    case (world,text):(App.Application{schema,Build.enabled(~S,~World(),~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~S),Build.empty(~S,~World(),world),flag)},text)
def prepare(app:Application()) -> Application() & String:
  match app:
    case App.Application{schema,Build.Registered{world,_,_,flag}}:operation_returned(schema,flag,W.observe_resource(~S,~C(),~R(),~U32,~String,~prepare_resource,world))
def repaired_world(schema:Schema.Schema<S,C(),R()>,flag:Bool,result:World() & Unit) -> Application():
  match result:
    case (world,_):App.Application{schema,Build.enabled(~S,~World(),~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~S),Build.empty(~S,~World(),world),flag)}
def repair(app:Application()) -> Application():
  match app:
    case App.Application{schema,Build.Registered{world,_,_,flag}}:repaired_world(schema,flag,W.observe_resource(~S,~C(),~R(),~U32,~Unit,~repair_resource,world))
def complete(result:Application() & String) -> List<&2,String>:
  match result:
    case (_,text):[text]
def repeat_last(previous:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):List.append(&2,String,previous,[text])
def repeat_again(previous:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):repeat_last(List.append(&2,String,previous,[text]),snapshot(app,False{}))
def repeat_first(previous:List<&2,String>,result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):repeat_again(List.append(&2,String,previous,[text]),snapshot(app,True{}))
def repeat(result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):repeat_first([text],snapshot(app,True{}))
type Vacancy is Type:
  Vacancy{namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:C(),events:List<&2,U32>,pending:List<(World() -> World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type Retry is Type:
  Retry{context:Persist.Context<S,Array<U32>,resource_identity(),project>,vacancy:Maybe<&1,Vacancy>,rows:List<&2,String>}
# Test observation returns the complete retained list; no missing owner is synthesized.
def retained_join(head:Array<U32> & String,tail:List<Array<U32>> & String) -> List<Array<U32>> & String:
  match head tail:
    case (owner,a),(owners,b):(owner <> owners,a ++ ";" ++ b)
def retained(owners:List<Array<U32>>) -> List<Array<U32>> & String:
  match owners:
    case []:([],"empty")
    case owner <> rest:retained_join(Builtin.array(owner),retained(rest))
def retry_finished(context:Persist.Context<S,Array<U32>,resource_identity(),project>,vacancy:Maybe<&1,Vacancy>,rows:List<&2,String>) -> Retry:Retry{context,vacancy,rows}
def retry_world(schema:Schema.Schema<S,C(),R()>,flag:Bool,declaration:Persist.Constructed<S,Array<U32>,resource_identity(),project>,rest:List<Array<U32>>,text:String,world:Vacancy,owner:Array<U32>) -> Retry:
  match world:
    case Vacancy{namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock}:retry_finished(Persist.Context{declaration,rest},None{},repeat_first([text],snapshot(App.Application{schema,Build.enabled(~S,~World(),~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~S),Build.empty(~S,~World(),W.World{namespace,nextId,highWater,live,capacity,depth,store,Product.Owner{Unit{},owner},events,pending,registrations,nextSystemId,clock}),flag)},True{})))
def retry_observed(schema:Schema.Schema<S,C(),R()>,flag:Bool,world:Vacancy,declaration:Persist.Constructed<S,Array<U32>,resource_identity(),project>,result:D.Checked,owners:List<Array<U32>> & String) -> Retry:
  match owners:
    case ([],text):retry_finished(Persist.Context{declaration,[]},Some{world},["request=" ++ checked(result) ++ "|retained=" ++ text ++ "|empty=True"])
    case (owner <> rest,text):retry_world(schema,flag,declaration,rest,"request=" ++ checked(result) ++ "|retained=" ++ text ++ "|empty=False",world,owner)
def retry_context(schema:Schema.Schema<S,C(),R()>,flag:Bool,world:Vacancy,result:Persist.Context<S,Array<U32>,resource_identity(),project> & D.Checked) -> Retry:
  match result:
    case (Persist.Context{declaration,owners},result):retry_observed(schema,flag,world,declaration,result,retained(owners))
def request(app:Application()) -> Retry:
  match app:
    case App.Application{schema,Build.Registered{W.World{namespace,nextId,highWater,live,capacity,depth,store,Product.Owner{_,owner},events,pending,registrations,nextSystemId,clock},_,_,flag}}:retry_context(schema,flag,Vacancy{namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock},Persist.request(~S,~Array<U32>,~resource_identity(),~project,Persist.Context{resource_constructed(),[]},owner))
def validation_retry(previous:List<&2,String>,result:Retry) -> List<&2,String>:
  match result:
    case Retry{_,_,rows}:List.append(&2,String,previous,rows)
def validation_failed(result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):validation_retry(["prepare=" ++ text],request(repair(app)))
def observed_constructed(result:Application() & String) -> List<&2,String>:
  match result:
    case (app,text):List.append(&2,String,[text],validation_failed(prepare(app)))
def observed_initial(mode:Mode,result:Application() & String) -> List<&2,String>:
  match mode:
    case ConstructedMode{}:observed_constructed(result)
    case _:repeat(result)
type Seeded is Type:
  Seeded{world:World(),previous:Maybe<&1,Array<U32>>,incoming:Maybe<&1,Array<U32>>,note:String}
def seed_swapped(namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:R(),events:List<&2,U32>,pending:List<(World() -> World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,result:Col.SwapOutcome<S,Array<U32>>) -> Seeded:
  match result:
    case Col.Accepted{column,previous}:Seeded{W.World{namespace,nextId,highWater,live,capacity,depth,Product.Owner{column,Unit{}},resource,events,pending,registrations,nextSystemId,clock},previous,None{},"component=Accepted"}
    case Col.Rejected{column,incoming}:Seeded{W.World{namespace,nextId,highWater,live,capacity,depth,Product.Owner{column,Unit{}},resource,events,pending,registrations,nextSystemId,clock},None{},incoming,"component=SwapRejected"}
def seed_receipt(namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:R(),events:List<&2,U32>,pending:List<(World() -> World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,column:Col.Column<S,Array<U32>>,result:Persist.Constructed<S,Array<U32>,component_identity(),project> & D.Receipt<Array<U32>>) -> Seeded:
  match result:
    case (_,D.Receipt{owner,D.Accepted{_}}):seed_swapped(namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,Col.swap(~S,~Array<U32>,column,1,Some{owner}))
    case (_,D.Receipt{owner,D.Rejected{_}}):Seeded{W.World{namespace,nextId,highWater,live,capacity,depth,Product.Owner{column,Unit{}},resource,events,pending,registrations,nextSystemId,clock},None{},Some{owner},"component=ValidationRejected"}
def seed_mode(mode:Mode,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:R(),events:List<&2,U32>,pending:List<(World() -> World())>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,column:Col.Column<S,Array<U32>>) -> Seeded:
  match mode:
    case ConstructedMode{}:seed_receipt(namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,column,Persist.prepare(~S,~Array<U32>,~component_identity(),~project,component_constructed(),ALeaf{42}))
    case _:seed_swapped(namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,Col.swap(~S,~Array<U32>,column,1,Some{ALeaf{42}}))
def seed(mode:Mode,world:World()) -> Seeded:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,Product.Owner{column,_},resource,events,pending,registrations,nextSystemId,clock}:seed_mode(mode,namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,column)
def seed_recorded(mode:Mode,schema:Schema.Schema<S,C(),R()>,world:World(),note:String,left:Maybe<&1,Array<U32>> & String,right:Maybe<&1,Array<U32>> & String) -> List<&2,String>:
  match left right:
    case (_,a),(_,b):List.append(&2,String,[note ++ "|previous=" ++ a ++ "|incoming=" ++ b],observed_initial(mode,snapshot(App.attached(~S,~C(),~R(),~U32,~Unit,~Unit,~Build.empty_observe(~World()),~Leaf.empty(~S),schema,Build.empty(~S,~World(),world)),False{})))
def seeded_initial(mode:Mode,schema:Schema.Schema<S,C(),R()>,result:Seeded) -> List<&2,String>:
  match result:
    case Seeded{world,previous,incoming,note}:seed_recorded(mode,schema,world,note,O.optional(~Array<U32>,~Builtin.array,previous),O.optional(~Array<U32>,~Builtin.array,incoming))
def initial(+mode:Mode,schema:Schema.Schema<S,C(),R()>,result:W.Creation<S,C(),R(),U32>) -> List<&2,String>:
  match result:
    case W.CreateRejected{_,_}:["CreateRejected"]
    case W.Created{_,world}:seeded_initial(mode,schema,seed(mode,world))
def created(mode:Mode,result:Provision.Provision<S,C(),R(),empty(),count()> & W.Creation<S,C(),R(),U32>) -> List<&2,String>:
  match result:
    case (Provision.Provision{schema},result):initial(mode,schema,result)
def scenario(+mode:Mode) -> List<&2,String>:created(mode,Provision.create(~S,~C(),~R(),~U32,~empty(),~count(),setup(mode),W.factory(),Product.Owner{Unit{},ALeaf{7}}))
def main() -> List<&2,List<&2,String>>:[scenario(PlainMode{}),scenario(TransientMode{}),scenario(ConstructedMode{}),scenario(BareMode{})]
