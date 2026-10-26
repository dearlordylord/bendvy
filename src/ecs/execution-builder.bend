import Base
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./execution-access.bend as A
import ./execution-projection.bend as Projection
import ./owner-product.bend as Product
import ./ordinary-declaration.bend as Identity
import ./ordinary-schema.bend as Schema
import ./chunk-column.bend as Col
import ./execution-query.bend as Q

type Book is Type:
  Book{access:List<&2,D.Access>}
def ComponentRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-P:Type -> @-Rest:Type -> @-V:Data -> @-lens:Product.Lens<C,Col.Column<S,P>,Rest> -> @-project:(P -> P & V) -> Projection.Affine<P,V,project> -> Identity.Declaration<S,P> -> B -> B & A.ComponentRead<S,H,V>
def ComponentWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-P:Type -> @-Rest:Type -> @-V:Data -> @-lens:Product.Lens<C,Col.Column<S,P>,Rest> -> @-project:(P -> P & V) -> Projection.Affine<P,V,project> -> Identity.Declaration<S,P> -> B -> B & A.ComponentWrite<S,H,P,V>
def ResourceRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-P:Type -> @-Rest:Type -> @-V:Data -> @-lens:Product.Lens<R,P,Rest> -> @-project:(P -> P & V) -> Projection.Affine<P,V,project> -> Schema.Resource<S,P> -> B -> B & A.ResourceRead<H,V>
def ResourceWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-P:Type -> @-Rest:Type -> @-V:Data -> @-lens:Product.Lens<R,P,Rest> -> @-project:(P -> P & V) -> Projection.Affine<P,V,project> -> Schema.Resource<S,P> -> B -> B & A.ResourceWrite<H,P,V>
def Query(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Input:Type -> @-Output:Type -> @-Rest:Type -> @-V:Data -> @-Error:Data -> @-lens:Product.Lens<C,Product.Owner<Col.Column<S,Input>,Col.Column<S,Output>>,Rest> -> @-project:(Input -> Input & V) -> @-body:(U32 -> V -> Output -> Output & Maybe<&2,Error>) -> Projection.Affine<Input,V,project> -> Q.Mode -> Identity.Declaration<S,Input> -> Identity.Declaration<S,Output> -> B -> B & Q.Each<S,H,Error>
def Selection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-component_read:ComponentRead(~S,~C,~R,~H,~B) -> @-component_write:ComponentWrite(~S,~C,~R,~H,~B) -> @-resource_read:ResourceRead(~S,~C,~R,~H,~B) -> @-resource_write:ResourceWrite(~S,~C,~R,~H,~B) -> @-query:Query(~S,~C,~R,~H,~B) -> B -> B & Ops(H)
def Builder(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:Selection(~S,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)
def Program(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type) -> Type:
  @-H:Type -> @-B:Type -> @-builder:Builder(~S,~C,~R,~H,~B) -> B -> B & Ops(H)
def accumulate(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,book:Book,value:D.Declaration<S,C,R,Ops>) -> Book & Ops(State.Scope<S,C,R>):
  match book value:
    case Book{previous} D.Declaration{caps,access}:(Book{List.append(&2,D.Access,previous,access)},caps)
def component_read_build(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Identity.Declaration<S,P>,book:Book) -> Book & A.ComponentRead<S,State.Scope<S,C,R>,V>:
  accumulate(~S,~C,~R,~A.ComponentReads(~S,~V),book,A.component_read(~S,~C,~R,~P,~Rest,~V,~lens,~project,projection,identity))
def component_write_build(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<C,Col.Column<S,P>,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Identity.Declaration<S,P>,book:Book) -> Book & A.ComponentWrite<S,State.Scope<S,C,R>,P,V>:
  accumulate(~S,~C,~R,~A.ComponentWrites(~S,~P,~V),book,A.component_write(~S,~C,~R,~P,~Rest,~V,~lens,~project,projection,identity))
def resource_read_build(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Schema.Resource<S,P>,book:Book) -> Book & A.ResourceRead<State.Scope<S,C,R>,V>:
  accumulate(~S,~C,~R,~A.ResourceReads(~V),book,A.resource_read(~S,~C,~R,~P,~Rest,~V,~lens,~project,projection,identity))
def resource_write_build(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~project:P -> P & V,projection:Projection.Affine<P,V,project>,identity:Schema.Resource<S,P>,book:Book) -> Book & A.ResourceWrite<State.Scope<S,C,R>,P,V>:
  accumulate(~S,~C,~R,~A.ResourceWrites(~P,~V),book,A.resource_write(~S,~C,~R,~P,~Rest,~V,~lens,~project,projection,identity))
def query_build(~S:Data,~C:Type,~R:Type,~Input:Type,~Output:Type,~Rest:Type,~V:Data,~Error:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,Input>,Col.Column<S,Output>>,Rest>,~project:Input -> Input & V,~body:U32 -> V -> Output -> Output & Maybe<&2,Error>,projection:Projection.Affine<Input,V,project>,mode:Q.Mode,read:Identity.Declaration<S,Input>,write:Identity.Declaration<S,Output>,book:Book) -> Book & Q.Each<S,State.Scope<S,C,R>,Error>:
  accumulate(~S,~C,~R,~Q.Ops(~S,~Error),book,Q.declaration(~S,~C,~R,~Input,~Output,~Rest,~V,~Error,~lens,~project,~body,projection,mode,read,write))
def provision(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,~selection:Selection(~S,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(component_read_build(~S,~C,~R),component_write_build(~S,~C,~R),resource_read_build(~S,~C,~R),resource_write_build(~S,~C,~R),query_build(~S,~C,~R),book)
def compiled(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,result:Book & Ops(State.Scope<S,C,R>)) -> D.Declaration<S,C,R,Ops>:
  match result:
    case (Book{access},caps):D.Declaration{caps,access}
def compile(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,~program:Program(~S,~C,~R,~Ops)) -> D.Declaration<S,C,R,Ops>:
  compiled(~S,~C,~R,~Ops,program(State.Scope<S,C,R>,Book,provision(~S,~C,~R),Book{[]}))
