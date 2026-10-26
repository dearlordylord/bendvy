import Base
import ./ordinary-declaration.bend as Identity
import ./ordinary-schema.bend as Resource
import ./schema-fragments.bend as Fragment
import ./execution-composer-layout.bend as Layout
import ./persistence-declaration.bend as Persist
import ./decode-data.bend as Decode
import ./world.bend as W

type FragmentSchema<-S:Data,-C:Type,-R:Type> is Data:
  FragmentSchema{entries:List<&2,Fragment.Entry<S>>}
def component(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,identity:Identity.Declaration<S,P>) -> Layout.Layout:
  Layout.LayoutLeaf{P,V,refresh,Identity.key(~S,~P,identity)}
def resource(~S:Data,~P:Type,~V:Data,~refresh:P -> P & V,identity:Resource.Resource<S,P>) -> Layout.Layout:
  Layout.LayoutLeaf{P,V,refresh,Resource.resource_key(~S,~P,identity)}
def plain(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~V:Data,~refresh:P -> P & V,extension:Persist.Plain<S,P,identity>) -> Layout.Layout:
  Layout.ClassifiedLayoutLeaf{P,V,refresh,Identity.key(~S,~P,identity),Fragment.Plain{}}
def transient(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~V:Data,~refresh:P -> P & V,extension:Persist.Transient<S,P,identity>) -> Layout.Layout:
  Layout.ClassifiedLayoutLeaf{P,V,refresh,Identity.key(~S,~P,identity),Fragment.Transient{}}
def constructed(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & Decode.Raw,~V:Data,~refresh:P -> P & V,extension:Persist.Constructed<S,P,identity,project>) -> Layout.Layout:
  Layout.ClassifiedLayoutLeaf{P,V,refresh,Identity.key(~S,~P,identity),Fragment.Constructed{}}
def layout_entries(~S:Data,+kind:Fragment.RegistryKind,layout:Layout.Layout) -> List<&2,Fragment.Entry<S>>:
  match layout:
    case Layout.EmptyLayout{}:[]
    case Layout.LayoutLeaf{_,_,_,+key}:[Fragment.Entry{kind,key,key}]
    case Layout.ClassifiedLayoutLeaf{_,_,_,+key,persistence}:[Fragment.Classified{kind,key,key,persistence}]
    case Layout.LayoutPair{left,right}:List.append(&2,Fragment.Entry<S>,layout_entries(~S,kind,left),layout_entries(~S,kind,right))
def inventory(~S:Data,~components:Layout.Layout,~resources:Layout.Layout) -> List<&2,Fragment.Entry<S>>:
  List.append(&2,Fragment.Entry<S>,layout_entries(~S,Fragment.Component{},components),layout_entries(~S,Fragment.Resource{},resources))
def declared(~S:Data,~components:Layout.Layout,~resources:Layout.Layout) -> FragmentSchema<S,Layout.columns(~S,components),Layout.resources(~S,resources)>:
  FragmentSchema{inventory(~S,~components,~resources)}
def entries(~S:Data,~C:Type,~R:Type,value:FragmentSchema<S,C,R>) -> List<&2,Fragment.Entry<S>>:
  match value:
    case FragmentSchema{entries}:entries
def fragment(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~Provisions:Type,provisions:Provisions) -> Fragment.Fragment<S,Provisions>:
  Fragment.Fragment{inventory(~S,~components,~resources),provisions}
def validate(~S:Data,~components:Layout.Layout,~resources:Layout.Layout) -> Fragment.Validation:
  Fragment.validate(~S,inventory(~S,~components,~resources))
def empty_columns(~S:Data,~components:Layout.Layout,_:Unit) -> Layout.columns(~S,components):
  Layout.empty_columns(~S,components)
type Initialized<-S:Data,-Components:Layout.Layout,-Resources:Layout.Layout,-E:Data> is Type:
  SchemaCreated{factory:W.Factory,world:W.World<S,Layout.columns(~S,Components),Layout.resources(~S,Resources),E>}
  SchemaRefused{factory:W.Factory,resources:Layout.resources(~S,Resources),error:Fragment.Error}
  NamespaceRefused{factory:W.Factory,resources:Layout.resources(~S,Resources)}
def initialized_world(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,world:W.World<S,Layout.columns(~S,components),Layout.resources(~S,resources),E>) -> W.World<S,Layout.columns(~S,components),Layout.resources(~S,resources),E>:
  match world:
    case W.World{namespace,allocator,store,owners,events,pending,registrations,next,clock}:W.World{namespace,allocator,store,Layout.normalize_resources(~S,resources,owners),events,pending,registrations,next,clock}
def created(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,result:W.Creation<S,Layout.columns(~S,components),Layout.resources(~S,resources),E>) -> Initialized<S,components,resources,E>:
  match result:
    case W.Created{factory,world}:SchemaCreated{factory,initialized_world(~S,~components,~resources,~E,world)}
    case W.CreateRejected{factory,resource}:NamespaceRefused{factory,resource}
def create_checked(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,result:Fragment.Validation,factory:W.Factory,owners:Layout.resources(~S,resources)) -> Initialized<S,components,resources,E>:
  match result:
    case Fragment.Invalid{error}:SchemaRefused{factory,owners,error}
    case Fragment.Valid{}:created(~S,~components,~resources,~E,W.create(~S,~Layout.columns(~S,components),~Layout.resources(~S,resources),~E,~empty_columns(~S,~components),factory,owners))
def create(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,factory:W.Factory,owners:Layout.resources(~S,resources)) -> Initialized<S,components,resources,E>:
  create_checked(~S,~components,~resources,~E,validate(~S,~components,~resources),factory,owners)
# The closed seed constructs initial storage and never receives runtime authority.
def create_seeded_checked(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,~seed:Unit -> Layout.columns(~S,components),result:Fragment.Validation,factory:W.Factory,owners:Layout.resources(~S,resources)) -> Initialized<S,components,resources,E>:
  match result:
    case Fragment.Invalid{error}:SchemaRefused{factory,owners,error}
    case Fragment.Valid{}:created(~S,~components,~resources,~E,W.create(~S,~Layout.columns(~S,components),~Layout.resources(~S,resources),~E,~seed,factory,owners))
def create_seeded(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,~seed:Unit -> Layout.columns(~S,components),factory:W.Factory,owners:Layout.resources(~S,resources)) -> Initialized<S,components,resources,E>:
  create_seeded_checked(~S,~components,~resources,~E,~seed,validate(~S,~components,~resources),factory,owners)
