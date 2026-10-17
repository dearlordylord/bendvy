import Base
import ../reader-query-context-v1/fixture.bend as F
import ../reader-query-context-v1/observe.bend as Observe
import ../../../../src/ecs/ordinary-owned-event-declaration.bend as D
import ../../../../src/ecs/ordinary-owned-event-family-write.bend as Write
import ../../../../src/ecs/ordinary-owned-event-family-publisher.bend as Publisher
import ../../../../src/ecs/ordinary-app-owned-event-publisher.bend as App
import ../../../../src/ecs/ordinary-owned-event-binding.bend as Binding
import ../../../../src/ecs/owned-event-key-route.bend as Key
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-records.bend as Pair
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-description.bend as Description
import ../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/world.bend as W

def Ops(~S:Data) -> Type -> Type:Write.Ops(~S,~Array<U32>,~F.identity(~S))
def builder(~S:Data) -> D.Builder(~F.World(~S),~List<Array<U32>>,~Ops(~S)):Write.grant(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~F.path(),~Key.inject_leaf,~F.identity(~S))
def canonical(~S:Data) -> D.Declaration<S,F.World(~S),List<Array<U32>>,Ops(~S),builder(~S)>:Write.declaration(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Array<U32>,~Unit,~Nat,~F.path(),~Key.inject_leaf,~Key.select_leaf,~F.identity(~S),~Binding.leaf(~S,~Array<U32>,~F.identity(~S)))
def raw_value(~S:Data,value:D.Declaration<S,F.World(~S),List<Array<U32>>,Ops(~S),builder(~S)>) -> D.Declaration<S,F.World(~S),List<Array<U32>>,Ops(~S),builder(~S)>:
  match value:
    case D.Described{empty,access,_}:D.Declaration{empty,access}
    case value:value
def raw(~S:Data) -> D.Declaration<S,F.World(~S),List<Array<U32>>,Ops(~S),builder(~S)>:raw_value(~S,canonical(~S))
def partial_builder(~S:Data) -> D.Builder(~F.World(~S),~Product.Owner<List<Array<U32>>,List<Array<U32>>>,~D.PairOps(~Ops(~S),~Ops(~S))):D.pair_grant(~S,~F.World(~S),~List<Array<U32>>,~List<Array<U32>>,~Ops(~S),~Ops(~S),~builder(~S),~builder(~S))
def partial(~S:Data) -> D.Declaration<S,F.World(~S),Product.Owner<List<Array<U32>>,List<Array<U32>>>,D.PairOps(~Ops(~S),~Ops(~S)),partial_builder(~S)>:D.both(~S,~F.World(~S),~List<Array<U32>>,~List<Array<U32>>,~Ops(~S),~Ops(~S),~builder(~S),~builder(~S),~canonical(~S),~raw(~S))
def idle(~Ops:Type -> Type,~H:Type,~caps:Ops(H),input:Unit,owner:H) -> H & (T.Outcome<String> & Unit):(owner,(T.Success{},input))
def observe(~S:Data,world:F.World(~S)) -> F.World(~S) & DTO.Observation<Unit>:(world,DTO.Observation{Unit{},[]})
def fold(~S:Data,array:Array<U32>) -> Array<U32> & List<&2,Fields.Fields<S>>:(array,[])
def Before(~S:Data) -> Type:Build.Registered<S,F.World(~S),Array<U32>,Unit,observe(~S),fold(~S)>
def After(~S:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~F.World(~S),~Recovery,~Ops),~declaration:D.Declaration<S,F.World(~S),Recovery,Ops,builder>) -> Type:Build.Registered<S,F.World(~S),Array<U32> & Pair.Record<S,Fields.Token<Publisher.Registry(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Nat,~Recovery,~Ops,~builder,~declaration,~Unit,~String,~Unit,~idle(~Ops))>>,Unit,observe(~S),Pair.fold_pair(~S,~Array<U32>,~Pair.Record<S,Fields.Token<Publisher.Registry(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Nat,~Recovery,~Ops,~builder,~declaration,~Unit,~String,~Unit,~idle(~Ops))>>,~fold(~S),~Pair.observed(~S,~Fields.Token<Publisher.Registry(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Nat,~Recovery,~Ops,~builder,~declaration,~Unit,~String,~Unit,~idle(~Ops))>))>
def attempt(~S:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~F.World(~S),~Recovery,~Ops),~declaration:D.Declaration<S,F.World(~S),Recovery,Ops,builder>,app:Before(~S),name:String) -> App.Appended<Before(~S),After(~S,~Recovery,~Ops,~builder,~declaration)>:App.register(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Nat,~Recovery,~Ops,~builder,~declaration,~Unit,~String,~Unit,~idle(~Ops),~Array<U32>,~Unit,~observe(~S),~fold(~S),app,name)
def before_join(~S:Data,recipe:Tree.Recipe<F.World(~S),Unit,observe(~S)>,+debug:Bool,a:F.World(~S) & String,b:Array<U32> & String) -> Before(~S) & String:
  match a b:
    case (world,wt),(owner,ot):(Build.Registered{world,owner,recipe,debug},"Registered{debug=" ++ Bool.show(debug) ++ ";world=" ++ wt ++ ";prior=" ++ ot ++ ";recipe=Recipe}")
def before_observe(~S:Data,app:Before(~S)) -> Before(~S) & String:
  match app:
    case Build.Registered{world,owner,recipe,debug}:before_join(~S,recipe,debug,Observe.world(~S,world),Observe.u32_array(owner))
def category(value:Fields.UseCategory) -> String:
  match value:
    case Fields.ComponentUse{}:"Component"
    case Fields.ResourceUse{}:"Resource"
    case Fields.EventUse{}:"Event"
def source(value:Fields.ReaderSource) -> String:
  match value:
    case Fields.QuerySource{}:"Query"
    case Fields.MessageSource{}:"Message"
    case Fields.RemovalSource{}:"Removal"
    case Fields.RelationFailureSource{}:"RelationFailure"
def use(value:Fields.DeclaredUse) -> String:
  match value:
    case Fields.DeclaredUse{cat,src,key,mode}:category(cat) ++ ":" ++ source(src) ++ ":" ++ key ++ ":" ++ Observe.mode(mode)
def kind(value:Fields.RegistrationKind) -> String:
  match value:
    case Fields.ComponentKind{}:"ComponentKind"
    case Fields.ResourceKind{mode}:"ResourceKind" ++ Observe.mode(mode)
    case Fields.FieldKind{}:"FieldKind"
    case Fields.ServiceKind{}:"ServiceKind"
    case Fields.EventKind{}:"EventKind"
    case Fields.MixedKind{uses}:"MixedKind" ++ List.show(&2,Fields.DeclaredUse,use,uses)
def fields(~S:Data,+value:Fields.Fields<S>) -> String:
  match value:
    case Fields.Fields{namespace,id,name,access,cursor,slot,clauses,registrationKind}:Observe.dto_binding(~S,DTO.Binding{namespace,id,name,access,cursor,slot,clauses}) ++ ";kind=" ++ kind(registrationKind)
def unexpected_join(~S:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~F.World(~S),~Recovery,~Ops),~declaration:D.Declaration<S,F.World(~S),Recovery,Ops,builder>,+debug:Bool,recordFields:Fields.Fields<S>,a:F.World(~S) & String,b:Array<U32> & String) -> String:
  match a b:
    case (_,wt),(_,ot):"UnexpectedAppended{debug=" ++ Bool.show(debug) ++ ";world=" ++ wt ++ ";prior=" ++ ot ++ ";record=" ++ fields(~S,recordFields) ++ ";token=Token;recipe=Recipe}\n"
def unexpected(~S:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~F.World(~S),~Recovery,~Ops),~declaration:D.Declaration<S,F.World(~S),Recovery,Ops,builder>,app:After(~S,~Recovery,~Ops,~builder,~declaration)) -> String:
  match app:
    case Build.Registered{world,(owner,Pair.Record{_,fields}),_,debug}:unexpected_join(~S,~Recovery,~Ops,~builder,~declaration,debug,fields,Observe.world(~S,world),Observe.u32_array(owner))
type Returned<S:Data> is Type:
  Kept{app:Before(~S),text:String}
  Unexpected{text:String}
def refused_join(~S:Data,label:String,value:Before(~S) & String) -> Returned<S>:
  match value:
    case (app,text):Kept{app,label ++ "=AppendRejected;" ++ text ++ "\n"}
def attempted(~S:Data,~Recovery:Type,~Ops:Type -> Type,~builder:D.Builder(~F.World(~S),~Recovery,~Ops),~declaration:D.Declaration<S,F.World(~S),Recovery,Ops,builder>,label:String,value:App.Appended<Before(~S),After(~S,~Recovery,~Ops,~builder,~declaration)>) -> Returned<S>:
  match value:
    case App.AppendRejected{app}:refused_join(~S,label,before_observe(~S,app))
    case App.Appended{app}:Unexpected{label ++ "=" ++ unexpected(~S,~Recovery,~Ops,~builder,~declaration,app)}
def finish(~S:Data,prefix:String,value:Returned<S>) -> String:
  match value:
    case Kept{app,text}:prefix ++ text
    case Unexpected{text}:prefix ++ text
def raw_returned(~S:Data,prefix:String,value:Returned<S>) -> String:
  match value:
    case Kept{app,text}:finish(~S,prefix ++ text,attempted(~S,~Product.Owner<List<Array<U32>>,List<Array<U32>>>,~D.PairOps(~Ops(~S),~Ops(~S)),~partial_builder(~S),~partial(~S),"partial",attempt(~S,~Product.Owner<List<Array<U32>>,List<Array<U32>>>,~D.PairOps(~Ops(~S),~Ops(~S)),~partial_builder(~S),~partial(~S),app,"partial")))
    case Unexpected{text}:prefix ++ text
def initial_observed(~S:Data,value:Before(~S) & String) -> String:
  match value:
    case (app,text):raw_returned(~S,"before=" ++ text ++ "\n",attempted(~S,~List<Array<U32>>,~Ops(~S),~builder(~S),~raw(~S),"raw",attempt(~S,~List<Array<U32>>,~Ops(~S),~builder(~S),~raw(~S),app,"raw")))
def run(~S:Data,world:F.World(~S)) -> String:initial_observed(~S,before_observe(~S,Build.Registered{W.enqueue(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Nat,world,F.advance(~S)),ANode{ALeaf{600},ALeaf{601}},Tree.Recipe{},True{}}))

def positive_registration(~S:Data,app:Before(~S)) -> App.Appended<Before(~S),After(~S,~List<Array<U32>>,~Ops(~S),~builder(~S),~canonical(~S))>:attempt(~S,~List<Array<U32>>,~Ops(~S),~builder(~S),~canonical(~S),app,"canonical")
