import Base
import ./canonical-component-declaration.bend as Definition
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q

type Token<-S:Data,-P:Type,-declaration:Definition.Declaration<S,P>> is Data:
  Token{}
type Owner<-S:Data,-P:Type,-declaration:Definition.Declaration<S,P>> is Type:
  Owner{column:Col.Column<S,P>}
type Query<-S:Data,-P:Type,-declaration:Definition.Declaration<S,P>> is Data:
  Query{slot:String,selection:Q.Selection}
type Description is Data:
  Description{key:String,name:String,id:U32,slot:String,selection:Q.Selection}
def component(~S:Data,~P:Type,key:String) -> Definition.Declaration<S,P>:
  Definition.component(~S,~P,key)
def bootstrap(~S:Data,~P:Type,~declaration:Definition.Declaration<S,P>,column:Col.Column<S,P>) -> Owner<S,P,declaration>:
  Owner{column}
def take(~S:Data,~P:Type,~declaration:Definition.Declaration<S,P>,owner:Owner<S,P,declaration>) -> Unit & Col.Column<S,P>:
  match owner:
    case Owner{column}:(Unit{},column)
def put(~S:Data,~P:Type,~declaration:Definition.Declaration<S,P>,rest:Unit,column:Col.Column<S,P>) -> Owner<S,P,declaration>:
  Owner{column}
def query(~S:Data,~P:Type,~declaration:Definition.Declaration<S,P>,slot:String,selection:Q.Selection) -> Query<S,P,declaration>:
  Query{slot,selection}
def key(~S:Data,~P:Type,declaration:Definition.Declaration<S,P>) -> String:
  Definition.key(~S,~P,declaration)
def describe(~S:Data,~P:Type,~declaration:Definition.Declaration<S,P>,value:Query<S,P,declaration>) -> Description:
  match value:
    case Query{slot,selection}:Description{key(~S,~P,declaration),key(~S,~P,declaration),U32.add(0,1),slot,selection}
def selection(~S:Data,~P:Type,~declaration:Definition.Declaration<S,P>,value:Query<S,P,declaration>) -> Q.Selection:
  match value:
    case Query{_,selection}:selection

def grant(~S:Data,~P:Type,~R:Type,~E:Data,~declaration:Definition.Declaration<S,P>,~V:Data,~show:P -> P & V,~spec:Query<S,P,declaration>) -> Cap.ValueRead<I.Frame<S,Owner<S,P,declaration>,R,E>,List<&2,Q.Row<S,V>>>:
  Cap.ValueRead{frame => Q.scan(~S,~Owner<S,P,declaration>,~R,~E,~Unit,~P,~V,~Token<S,P,declaration>,~(owner => take(~S,~P,~declaration,owner)),~(rest => column => put(~S,~P,~declaration,rest,column)),~show,~(C.define(~S,~Owner<S,P,declaration>,~R,~E,~Unit,~P,~V,~Token<S,P,declaration>,~(owner => take(~S,~P,~declaration,owner)),~(rest => column => put(~S,~P,~declaration,rest,column)),~show,key(~S,~P,declaration))),~selection(~S,~P,~declaration,spec),frame)}
