import Base
import ./schema-fragments.bend as Fragments
import ./relation-commands.bend as RelationWorld
import ./relation-providers.bend as RelationOps
import ./ordinary-app-relation.bend as Relation
import ./relation-failure-reader.bend as RelationDecl
import ./relation-types.bend as RelationTypes
import ./ordinary-app-observation-data.bend as DTO
import ./machine.bend as Machine
import ./ordinary-machine-declaration.bend as MachineDecl
import ./ordinary-machine-operations.bend as MachineOps
import ./inspector.bend as Inspect
import ./capabilities.bend as Cap
import ./ordinary-query-declaration.bend as Query
import ./resource-field-binding.bend as Binding
import ./resource-field.bend as Lens
import ./ordinary-resource-field-system.bend as Field
import ./ordinary-schema.bend as Schema
import ./owner-product.bend as Product
import ./world.bend as W
import ./transaction.bend as T
# Same canonical field binding drives the grant and detached owning observation.
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-V:Data> is Type:
  Declaration{ordinary:Field.Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,render:V -> String}
def read_ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:
  Field.Read<S,P,identity,H,V>
def write_ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:
  Field.Write<S,P,identity,H,V>
def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:Binding.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V,~render:V -> String) -> Declaration<S,C,R,E,read_ops(~S,~P,~identity,~V),V>:
  Declaration{Field.read(~S,~C,~R,~E,~P,~Rest,~V,~lens,~identity,~binding,~view),W.observe_resource(~S,~C,~R,~E,~V,~Lens.project(~R,~P,~Rest,~V,~lens,~view)),render}
def write(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:Binding.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V,~render:V -> String) -> Declaration<S,C,R,E,write_ops(~S,~P,~identity,~V),V>:
  Declaration{Field.Declaration{Field.Write{Lens.write_observed(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view,~render,~Schema.resource_key(~S,~P,identity))},[Query.Clause{Schema.resource_key(~S,~P,identity),Query.Write{}}]},W.observe_resource(~S,~C,~R,~E,~V,~Lens.project(~R,~P,~Rest,~V,~lens,~view)),render}
def ordinary(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> Field.Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>:
  match declaration:
    case Declaration{ordinary,_,_}:ordinary
def observer(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & V:
  match declaration:
    case Declaration{_,observe,_}:observe
def renderer(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> V -> String:
  match declaration:
    case Declaration{_,_,render}:render

def names(~S:Data,clauses:List<&2,Query.Clause<S>>) -> String:
  match clauses:
    case []:""
    case Query.Clause{key,_} <> []:key
    case Query.Clause{key,_} <> rest:key ++ "," ++ names(~S,rest)
def name(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> String:
  names(~S,Field.clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),ordinary(~S,~C,~R,~E,~Ops,~V,declaration)))
def presenter(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> V -> String:
  renderer(~S,~C,~R,~E,~Ops,~V,declaration)

# The same declared machine supplies its grant, access name and current observer.
def machine_ops(~S:Data,~K:Data,~V:Data,H:Type) -> Type:
  Cap.ValueWrite<H,Machine.QueueInput<V>,Machine.CurrentView<S,K,V>>
def machine_presented(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,result:Inspect.Frame<S,C,R,E> & Machine.CurrentView<S,K,V>) -> W.World<S,C,R,E> & Machine.CurrentView<S,K,V>:
  match result:
    case (Inspect.Frame{world,_},view):(world,view)
def machine_observe(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & Machine.Slot<S,K,V>,~machine:MachineDecl.Declaration<S,K,V,R,take>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Machine.CurrentView<S,K,V>:
  machine_presented(~S,~K,~V,~C,~R,~E,MachineDecl.get(~Inspect.Frame<S,C,R,E>,~S,~K,~V,~MachineDecl.inspect(~S,~K,~V,~C,~R,~E,~take,~machine),Inspect.Frame{world,0}))
def machine_render(~S:Data,~K:Data,~V:Data,~render:V -> String,view:Machine.CurrentView<S,K,V>) -> String:
  match view:
    case Machine.Unavailable{}:"Unavailable"
    case Machine.Current{value}:"Current:" ++ render(value)
def machine_write(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & Machine.Slot<S,K,V>,~put:R -> Machine.Slot<S,K,V> -> R,~same:V -> V -> Bool,~machine:MachineDecl.Declaration<S,K,V,R,take>,~render:V -> String) -> Declaration<S,C,R,E,machine_ops(~S,~K,~V),Machine.CurrentView<S,K,V>>:
  Declaration{Field.Declaration{MachineOps.write(~S,~K,~V,~C,~R,~E,~take,~put,~same,~machine),[Query.Clause{MachineDecl.name(~S,~K,~V,~R,~take,machine),Query.Write{}}]},machine_observe(~S,~K,~V,~C,~R,~E,~take,~machine),machine_render(~S,~K,~V,~render)}

def relation_ops(~S:Data,H:Type) -> Type:RelationOps.Writable<H,S>
def relation_name(~S:Data,declaration:RelationDecl.Declaration<S>) -> String:
  match declaration:
    case RelationDecl.Declaration{RelationTypes.Descriptor{_,name,_,_}}:name
def relation_viewed(~S:Data,~C:Type,~R:Type,~E:Data,result:Relation.World(~S,~C,~R,~E) & DTO.Observation<Relation.View<S>>) -> Relation.World(~S,~C,~R,~E) & Relation.View<S>:
  match result:
    case (world,DTO.Observation{view,_}):(world,view)
def relation_observe(~S:Data,~C:Type,~R:Type,~E:Data,~relation:RelationDecl.Declaration<S>,world:Relation.World(~S,~C,~R,~E)) -> Relation.World(~S,~C,~R,~E) & Relation.View<S>:
  relation_viewed(~S,~C,~R,~E,Relation.observe(~S,~C,~R,~E,~relation,~Relation.builtin_row(~S),world))
def relation_render(~S:Data,view:Relation.View<S>) -> String:
  match view:
    case Relation.View{descriptor,rows}:Relation.descriptor_text(~S,descriptor) ++ ":" ++ List.show(&2,Relation.Row(~S),Relation.builtin_row(~S),rows)
def relation_write(~S:Data,~C:Type,~R:Type,~E:Data,~relation:RelationDecl.Declaration<S>) -> Declaration<S,RelationWorld.Store<S,C>,R,RelationWorld.Notice<S,E>,relation_ops(~S),Relation.View<S>>:
  Declaration{Field.Declaration{RelationOps.provide_write(~S,~C,~R,~E,~Relation.descriptor(~S,relation)),[Query.Clause{relation_name(~S,relation),Query.Write{}}]},relation_observe(~S,~C,~R,~E,~relation),relation_render(~S)}
def relation_entries(~S:Data,relation:RelationDecl.Declaration<S>) -> List<&2,Fragments.Entry<S>>:
  match relation:
    case RelationDecl.Declaration{RelationTypes.Descriptor{_,+name,+inverseName,_}}:[Fragments.Entry{Fragments.Relation{},name,name},Fragments.Entry{Fragments.Relation{},inverseName,inverseName}]
