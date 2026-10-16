import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Ctor
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Construction
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Persist
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field.bend as AppField
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-observation.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-run.bend as Transport

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Mode is Data:Valid{} ConstructorReject{} AdmissionReject{}
type Custom is Data:ConstructorStopped{}
type Input<S:Data> is Type:Input{raw:D.Raw,mode:Mode,owned:Array<U32>}
type Payload<S:Data> is Type:Payload{raw:D.Raw,origin:D.Raw,mode:Mode,owned:Array<U32>}
type Other is Type:Other{owned:Array<Bool>,label:String}
def Siblings(~S:Data) -> Type:Product.Owner<Payload<S>,Other>
def Resources(~S:Data) -> Type:Product.Owner<Payload<S>,Siblings(~S)>
def World(~S:Data) -> Type:W.World<S,Array<U32>,Resources(~S),Unit>
def target_identity(~S:Data) -> Schema.Resource<S,Payload<S>>:Schema.resource(~S,~Payload<S>,"Target")
def sibling_identity(~S:Data) -> Schema.Resource<S,Payload<S>>:Schema.resource(~S,~Payload<S>,"Sibling")
def other_identity(~S:Data) -> Schema.Resource<S,Other>:Schema.resource(~S,~Other,"Other")
def SiblingIndex(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Payload<S>,Schema.Resource<S,Payload<S>>>,Binding.Built<S,Other,Schema.Resource<S,Other>>>
def Index(~S:Data) -> Data:Binding.Branch<Binding.Built<S,Payload<S>,Schema.Resource<S,Payload<S>>>,Binding.Built<S,Siblings(~S),SiblingIndex(~S)>>
def schema(~S:Data) -> Binding.Built<S,Resources(~S),Index(~S)>:Binding.joined(~S,~Payload<S>,~Siblings(~S),~Schema.Resource<S,Payload<S>>,~SiblingIndex(~S),Binding.leaf(~S,~Payload<S>,target_identity(~S)),Binding.joined(~S,~Payload<S>,~Other,~Schema.Resource<S,Payload<S>>,~Schema.Resource<S,Other>,Binding.leaf(~S,~Payload<S>,sibling_identity(~S)),Binding.leaf(~S,~Other,other_identity(~S))))
def lens(~S:Data) -> Product.Lens<Resources(~S),Payload<S>,Unit & Siblings(~S)>:Binding.left_lens(~Resources(~S),~Payload<S>,~Siblings(~S),~Unit,~Binding.whole(~Resources(~S)))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(~S),Payload<S>,Unit & Siblings(~S),Schema.Resource<S,Payload<S>>,lens(~S)>:Binding.left(~S,~Resources(~S),~Payload<S>,~Siblings(~S),~Unit,~Schema.Resource<S,Payload<S>>,~SiblingIndex(~S),~Binding.whole(~Resources(~S)),Binding.root(~S,~Resources(~S),~Index(~S),schema(~S)))
def binding(~S:Data) -> Binding.Binding<S,Resources(~S),Payload<S>,Unit & Siblings(~S),lens(~S),target_identity(~S)>:Binding.bind(~S,~Resources(~S),~Payload<S>,~(Unit & Siblings(~S)),~lens(~S),~cursor(~S))
# Construction identity comes from the very same ordinary resource key.
def identity(~S:Data) -> Identity.Declaration<S,Payload<S>>:Identity.component(~S,~Payload<S>,Schema.resource_key(~S,~Payload<S>,target_identity(~S)))
def project(~S:Data,value:Payload<S>) -> Payload<S> & D.Raw:
  match value:
    case Payload{+raw,origin,mode,owned}:(Payload{raw,origin,mode,owned},raw)
def incoming(~S:Data,value:Input<S>) -> Input<S> & D.Raw:
  match value:
    case Input{+raw,mode,owned}:(Input{raw,mode,owned},raw)
def undo(~S:Data,value:Payload<S>) -> Input<S>:
  match value:
    case Payload{_,origin,mode,owned}:Input{origin,mode,owned}
def raw_field(name:String,value:D.Raw) -> D.Raw:
  match value:
    case D.Object{fields}:D.field(name,fields)
    case _:D.Missing{}
def stored_bad(+canonical:D.Raw) -> D.Raw:D.Object{[D.Field{"value",D.Text{"invalid-stored"}},D.Field{"handle",raw_field("handle",canonical)}]}
def construct_mode(~S:Data,raw:D.Raw,mode:Mode,owned:Array<U32>,canonical:D.Raw) -> Construction.Construction<Input<S>,Payload<S>,Custom>:
  match mode:
    case ConstructorReject{}:Construction.Invalid{Input{raw,ConstructorReject{},owned},ConstructorStopped{}}
    case AdmissionReject{}:Construction.Constructed{Payload{stored_bad(canonical),raw,AdmissionReject{},owned},undo(~S)}
    case Valid{}:Construction.Constructed{Payload{canonical,raw,Valid{},owned},undo(~S)}
def construct(~S:Data,value:Input<S>,canonical:D.Raw) -> Construction.Construction<Input<S>,Payload<S>,Custom>:
  match value:
    case Input{raw,mode,owned}:construct_mode(~S,raw,mode,owned,canonical)
def codec(namespace:U32) -> D.Codec:D.Struct{[D.NamedCodec{"value",D.Integer{}},D.NamedCodec{"handle",D.HandleValue{namespace}}]}
def Factory(~S:Data) -> Data:Ctor.FallibleFactory<S,Input<S>,Payload<S>,Custom,identity(~S),project(~S),incoming(~S),construct(~S)>
type Context<S:Data> is Data:Context{namespace:U32,factory:Factory(~S)}
def context(~S:Data,+namespace:U32) -> Context<S>:Context{namespace,Ctor.fallible_factory(~S,~Input<S>,~Payload<S>,~Custom,~identity(~S),~project(~S),~incoming(~S),~construct(~S),Persist.constructed(~S,~Payload<S>,~identity(~S),~project(~S),codec(namespace)))}
def retained_declaration(~S:Data,value:Context<S>) -> Persist.Constructed<S,Payload<S>,identity(~S),project(~S)>:
  match value:
    case Context{_,Ctor.FallibleFactory{declaration,_}}:declaration
# Input and expected decoder namespace are separate owners/values.
type Args<S:Data> is Type:Args{context:Context<S>,input:Input<S>}
type Output<S:Data> is Type:
  Refused{input:Input<S>,error:Ctor.Error<Custom>}
  AdmissionRefused{cooked:Payload<S>,undo:Payload<S> -> Input<S>,error:D.Error}
  Applied{canonical:D.Raw,undo:Payload<S> -> Input<S>}
def number(value:D.Raw) -> U32:
  match value:
    case D.Number{value}:value
    case _:0
def view(~S:Data,value:Payload<S>) -> Payload<S> & U32:
  match value:
    case Payload{+raw,origin,mode,owned}:(Payload{raw,origin,mode,owned},number(raw_field("value",raw)))
def Ops(~S:Data) -> Type -> Type:Decl.write_ops(~S,~Payload<S>,~target_identity(~S),~U32)
def declaration(~S:Data) -> Decl.Declaration<S,Array<U32>,Resources(~S),Unit,Ops(~S),U32>:Decl.write(~S,~Array<U32>,~Resources(~S),~Unit,~Payload<S>,~(Unit & Siblings(~S)),~U32,~lens(~S),~target_identity(~S),~binding(~S),~view(~S),~U32.show)
def raw(~S:Data) -> Field.Declaration<S,T.Tx<World(~S),Unit>,Ops(~S)(T.Tx<World(~S),Unit>)>:Decl.ordinary(~S,~Array<U32>,~Resources(~S),~Unit,~Ops(~S),~U32,declaration(~S))
def admitted(~S:Data,~H:Type,~caps:Ops(~S)(H),owner:H,undo:Payload<S> -> Input<S>,value:D.Receipt<Payload<S>>) -> H & (T.Outcome<Unit> & Output<S>):
  match value:
    case D.Receipt{cooked,D.Rejected{error}}:(owner,(T.Success{},AdmissionRefused{cooked,undo,error}))
    case D.Receipt{cooked,D.Accepted{canonical}}:(Field.set(~S,~Payload<S>,~target_identity(~S),~H,~U32,~caps,owner,cooked),(T.Success{},Applied{canonical,undo}))
def constructed(~S:Data,~H:Type,~caps:Ops(~S)(H),owner:H,context:Context<S>,value:Construction.Construction<Input<S>,Payload<S>,Ctor.Error<Custom>>) -> H & (T.Outcome<Unit> & Output<S>):
  match value:
    case Construction.Invalid{input,error}:(owner,(T.Success{},Refused{input,error}))
    case Construction.Constructed{cooked,undo}:admitted(~S,~H,~caps,owner,undo,Persist.validate(~S,~Payload<S>,~identity(~S),~project(~S),retained_declaration(~S,context),cooked))
def retained_factory(~S:Data,value:Context<S>) -> Factory(~S):
  match value:
    case Context{_,factory}:factory
# Ordinary gameplay example: public construction + final validate + field set.
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),args:Args<S>,owner:H) -> H & (T.Outcome<Unit> & Output<S>):
  match args:
    case Args{+context,input}:constructed(~S,~H,~caps,owner,context,Ctor.fallible_construct(~S,~Input<S>,~Payload<S>,~Custom,~identity(~S),~project(~S),~incoming(~S),~construct(~S),retained_factory(~S,context),input))

def runner(~S:Data) -> World(~S) -> Args<S> -> Sys.Outcome<World(~S),Unit,Output<S>>:Field.runner(~S,~Array<U32>,~Resources(~S),~Unit,~Ops(~S),~Args<S>,~Unit,~Output<S>,~raw(~S),~body(~S))
def Registry(~S:Data) -> Type:Sys.Registry<S,Array<U32>,Resources(~S),Unit,Args<S>,Unit,Output<S>,runner(~S)>
def Owner(~S:Data) -> Type:Leaf.Record<S,Records.Token<Registry(~S)>>
def Owners(~S:Data) -> Type:Unit & Owner(~S)
def Rows() -> Data:DTO.Product<Unit,U32>
def observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<Rows()>:Tree.observe_pair(~World(~S),~Unit,~U32,~Build.empty_observe(~World(~S)),~Leaves.resource_observe(~S,~Array<U32>,~Resources(~S),~Unit,~Ops(~S),~U32,~declaration(~S)))
def fold(~S:Data) -> Owners(~S) -> Owners(~S) & List<&2,Records.Fields<S>>:Leaf.fold_pair(~S,~Unit,~Owner(~S),~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Registry(~S)>))
def Before(~S:Data) -> Type:Build.Registered<S,World(~S),Unit,Unit,Build.empty_observe(~World(~S)),Leaf.empty(~S)>
def Registered(~S:Data) -> Type:Build.Registered<S,World(~S),Owners(~S),Rows(),observe(~S),fold(~S)>
def Application(~S:Data) -> Type:App.Application<S,Array<U32>,Resources(~S),Unit,Owners(~S),Rows(),observe(~S),fold(~S)>
def registered(~S:Data,app:Registered(~S)) -> Maybe<&1,Application(~S)>:Some{App.Application{Schema.Schema{Binding.entries(~S,~Resources(~S),~Index(~S),schema(~S))},app}}
def registration_failed(~S:Data,_:Before(~S)) -> Maybe<&1,Application(~S)>:None{}
def register(~S:Data,world:World(~S)) -> Maybe<&1,Application(~S)>:AppField.register(~S,~Array<U32>,~Resources(~S),~Unit,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),~Ops(~S),~Args<S>,~Unit,~Output<S>,~U32,~declaration(~S),~body(~S),~Maybe<&1,Application(~S)>,registered(~S),registration_failed(~S),Build.empty(~S,~World(~S),world),"construct-target","constructed")
type Run<S:Data> is Type:
  Completed{app:Application(~S),output:Output<S>}
  Failed{app:Application(~S),error:Unit}
  Rejected{app:Application(~S),args:Args<S>}
def restored(~S:Data,schema:Schema.Schema<S,Array<U32>,Resources(~S)>,prior:Unit,recipe:Tree.Recipe<World(~S),Rows(),observe(~S)>,debug:Bool,token:Records.Token<Registry(~S)>,fields:Records.Fields<S>,world:World(~S)) -> Application(~S):App.Application{schema,Build.Registered{world,(prior,Leaf.Record{token,fields}),recipe,debug}}
def returned(~S:Data,schema:Schema.Schema<S,Array<U32>,Resources(~S)>,prior:Unit,recipe:Tree.Recipe<World(~S),Rows(),observe(~S)>,debug:Bool,value:Transport.TransportResult<S,World(~S),Args<S>,Unit,Output<S>,Records.Token<Registry(~S)>>) -> Run<S>:
  match value:
    case Transport.Completed{token,fields,Sys.Succeeded{world,output}}:Completed{restored(~S,schema,prior,recipe,debug,token,fields,world),output}
    case Transport.Completed{token,fields,Sys.Failed{world,error}}:Failed{restored(~S,schema,prior,recipe,debug,token,fields,world),error}
    case Transport.RegistrationRejected{token,fields,world,args}:Rejected{restored(~S,schema,prior,recipe,debug,token,fields,world),args}
def run(~S:Data,app:Application(~S),args:Args<S>) -> Run<S>:
  match app:
    case App.Application{schema,Build.Registered{world,(prior,Leaf.Record{token,fields}),recipe,debug}}:returned(~S,schema,prior,recipe,debug,Transport.run(~S,~Array<U32>,~Resources(~S),~Unit,~Args<S>,~Unit,~Output<S>,~runner(~S),token,fields,world,args))
def enabled(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):App.enabled(~S,~Array<U32>,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,App.Description<S,Rows()>>:App.snapshot(~S,~Array<U32>,~Resources(~S),~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),app)
