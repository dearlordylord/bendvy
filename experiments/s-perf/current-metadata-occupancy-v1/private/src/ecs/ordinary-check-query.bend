import Base
import ./ordinary-check-declaration.bend as D
import ./ordinary-component-binding.bend as B
import ./ordinary-declaration.bend as Identity
import ./ordinary-query-selections.bend as Leaves
import ./inspector-query-families.bend as Families
import ./inspector-query-projection.bend as Q
import ./inspector-query.bend as Query
import ./inspector-query-world.bend as Traverse
import ./check.bend as K
import ./column.bend as Col
import ./component.bend as C
import ./world.bend as W

# Operational selection and description are produced from the same bindings.
# Required component selection means row membership, never World admission.
type Selection<-H:Type,-S:Data,-V:Data> is Type:
  Selection{selection:Q.DeclaredSelection<H,S,V>,uses:List<&2,D.Use>}
type Predicate<-H:Type,-S:Data> is Type:
  Predicate{predicate:Q.Predicate<H,S>,uses:List<&2,D.Use>}
def selected(~H:Type,~S:Data,~V:Data,value:Selection<H,S,V>) -> Q.DeclaredSelection<H,S,V>:
  match value:
    case Selection{selection,_}:selection
def uses(~H:Type,~S:Data,~V:Data,value:Selection<H,S,V>) -> List<&2,D.Use>:
  match value:
    case Selection{_,uses}:uses
def predicate(~H:Type,~S:Data,value:Predicate<H,S>) -> Q.Predicate<H,S>:
  match value:
    case Predicate{predicate,_}:predicate
def predicate_uses(~H:Type,~S:Data,value:Predicate<H,S>) -> List<&2,D.Use>:
  match value:
    case Predicate{_,uses}:uses
def read(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Selection<K.Frame<S,Store,R,E>,S,C.Access<V>>:
  Selection{Leaves.check_slot(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~binding,~Families.Required{}),[D.Use{D.Component{D.Required{}},Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Read{},False{}}]}
def optional(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Selection<K.Frame<S,Store,R,E>,S,C.Access<V>>:
  Selection{Leaves.check_slot(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~binding,~Families.Optional{}),[D.Use{D.Component{D.Optional{}},Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Read{},False{}}]}
def with_component(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Predicate<K.Frame<S,Store,R,E>,S>:
  Predicate{Leaves.check_with(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~binding),[D.Use{D.Component{D.With{}},Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Read{},False{}}]}
def without_component(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Predicate<K.Frame<S,Store,R,E>,S>:
  Predicate{Leaves.check_without(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~binding),[D.Use{D.Component{D.Without{}},Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Read{},False{}}]}
def empty(~H:Type,~S:Data) -> Selection<H,S,Unit>:Selection{Q.empty(~H,~S),[]}
def pair(~H:Type,~S:Data,~A:Data,~B:Data,~left:Selection<H,S,A>,~right:Selection<H,S,B>) -> Selection<H,S,Q.Product<A,B>>:
  Selection{Q.pair(~H,~S,~A,~B,~selected(~H,~S,~A,left),~selected(~H,~S,~B,right)),List.append(&2,D.Use,uses(~H,~S,~A,left),uses(~H,~S,~B,right))}
def both(~H:Type,~S:Data,~left:Predicate<H,S>,~right:Predicate<H,S>) -> Predicate<H,S>:
  Predicate{Q.both(~H,~S,~predicate(~H,~S,left),~predicate(~H,~S,right)),List.append(&2,D.Use,predicate_uses(~H,~S,left),predicate_uses(~H,~S,right))}
def constrain(~H:Type,~S:Data,~V:Data,~source:Selection<H,S,V>,~filter:Predicate<H,S>) -> Selection<H,S,V>:
  Selection{Q.constrain(~H,~S,~V,~selected(~H,~S,~V,source),~predicate(~H,~S,filter)),List.append(&2,D.Use,uses(~H,~S,~V,source),predicate_uses(~H,~S,filter))}
def map(~H:Type,~S:Data,~A:Data,~B:Data,~source:Selection<H,S,A>,~view:A -> B) -> Selection<H,S,B>:
  Selection{Q.map(~H,~S,~A,~B,~selected(~H,~S,~A,source),~view),uses(~H,~S,~A,source)}
# The only gameplay-facing operation is the existing confined readonly query.
type Read<-S:Data,-V:Data,-H:Type> is Type:
  Read{query:Query.ComposedReadQuery<H,S,V>}
def Ops(~S:Data,~V:Data,H:Type) -> Type:Read<S,V,H>
def query(~S:Data,~V:Data,~H:Type,value:Read<S,V,H>) -> Query.ComposedReadQuery<H,S,V>:
  match value:
    case Read{query}:query
def each(~S:Data,~V:Data,~H:Type,~caps:Read<S,V,H>,owner:H) -> H & List<&2,Query.ProjectedRow<S,V>>:
  Query.each_composed(~H,~S,~V,~query(~S,~V,~H,caps),owner)
def declaration(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~source:Selection<K.Frame<S,Store,R,E>,S,V>) -> D.Declaration<S,Store,R,E,Ops(~S,~V)>:
  D.Declaration{K.Plan{D.provided(~S,~Store,~R,~E),Read{Query.grant_composed(~K.Frame<S,Store,R,E>,~S,~V,~selected(~K.Frame<S,Store,R,E>,~S,~V,source),~Traverse.check_world(~S,~Store,~R,~E))}},uses(~K.Frame<S,Store,R,E>,~S,~V,source)}
