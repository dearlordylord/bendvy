import Base
import ./restore-data.bend as R
import ./restore-leaf.bend as Stage
import ./snapshot-leaf.bend as Leaf
import ./ordinary-declaration.bend as Identity
import ./decode-data.bend as D
import ./column.bend as Col
import ./world.bend as W
import ./entity-key.bend as Key
import ./persistence-declaration.bend as Decl

def inserted(~S:Data,~Context:Type,~I:Type,~P:Type,+position:R.Position,undo:P -> I,context:Context,records:List<Stage.Record<I,P>>,returned:List<I>,removed:List<P>,applied:List<Stage.Applied<I,P>>,+target:W.Handle<S>,tick:U32,result:Col.SwapOutcome<S,P>) -> Col.Column<S,P> & Stage.State<Context,I,P>:
  match result:
    case Col.Accepted{column,None{}}:(Col.mark(~S,~P,column,W.handle_index(~S,target),True{},False{},tick),Stage.State{context,records,returned,removed,Stage.Applied{position,undo} <> applied})
    case Col.Accepted{column,Some{old}}:(Col.mark(~S,~P,column,W.handle_index(~S,target),True{},True{},tick),Stage.State{context,records,returned,old <> removed,Stage.Applied{position,undo} <> applied})
    case Col.Rejected{column,Some{owner}}:(column,Stage.State{context,Stage.Record{position,owner,undo} <> records,returned,removed,applied})
    case Col.Rejected{column,None{}}:(column,Stage.State{context,records,returned,removed,Stage.Applied{position,undo} <> applied})
def mapped(~S:Data,~Context:Type,~I:Type,~P:Type,+saved:Key.Key,owner:P,undo:P -> I,state:Stage.State<Context,I,P>,column:Col.Column<S,P>,tick:U32,target:Maybe<&2,W.Handle<S>>) -> Col.Column<S,P> & Stage.State<Context,I,P>:
  match state target:
    case Stage.State{context,records,returned,removed,applied} None{}:(column,Stage.State{context,Stage.Record{R.Component{saved},owner,undo} <> records,returned,removed,applied})
    case Stage.State{context,records,returned,removed,applied} Some{+target}:inserted(~S,~Context,~I,~P,R.Component{saved},undo,context,records,returned,removed,applied,target,tick,Col.swap(~S,~P,Col.ensure(~S,~P,column,W.handle_index(~S,target)),W.handle_index(~S,target),Some{owner}))
def component_record(~S:Data,~Context:Type,~I:Type,~P:Type,record:Stage.Record<I,P>,state:Stage.State<Context,I,P>,column:Col.Column<S,P>,+bindings:List<&2,R.Binding<S>>,tick:U32) -> Col.Column<S,P> & Stage.State<Context,I,P>:
  match record state:
    case Stage.Record{R.Component{+saved},owner,undo} state:mapped(~S,~Context,~I,~P,saved,owner,undo,state,column,tick,R.lookup(~S,saved,bindings))
    case record Stage.State{context,records,returned,removed,applied}:(column,Stage.State{context,record <> records,returned,removed,applied})
def components_next(~S:Data,~Context:Type,~I:Type,~P:Type,next:Col.Column<S,P> -> Stage.State<Context,I,P> -> Col.Column<S,P> & Stage.State<Context,I,P>,observed:Col.Column<S,P> & Stage.State<Context,I,P>) -> Col.Column<S,P> & Stage.State<Context,I,P>:
  match observed:
    case (column,state):next(column,state)
def component_records(~S:Data,~Context:Type,~I:Type,~P:Type,records:List<Stage.Record<I,P>>,state:Stage.State<Context,I,P>,column:Col.Column<S,P>,+bindings:List<&2,R.Binding<S>>,+tick:U32) -> Col.Column<S,P> & Stage.State<Context,I,P>:
  match records:
    case []:(column,state)
    case record <> rest:components_next(~S,~Context,~I,~P,column => state => component_records(~S,~Context,~I,~P,rest,state,column,bindings,tick),component_record(~S,~Context,~I,~P,record,state,column,bindings,tick))
def component_join(~S:Data,~Context:Type,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,observed:Col.Column<S,P> & Stage.State<Context,I,P>) -> Leaf.Component<S,P,identity,project> & Stage.State<Context,I,P>:
  match observed:
    case (column,state):(Leaf.Component{column,declaration},state)
def components(~S:Data,~Context:Type,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,owner:Leaf.Component<S,P,identity,project>,state:Stage.State<Context,I,P>,bindings:List<&2,R.Binding<S>>,tick:U32) -> Leaf.Component<S,P,identity,project> & Stage.State<Context,I,P>:
  match owner state:
    case Leaf.Component{column,declaration} Stage.State{context,records,returned,removed,applied}:component_join(~S,~Context,~I,~P,~identity,~project,declaration,component_records(~S,~Context,~I,~P,List.reverse(&1,Stage.Record<I,P>,records),Stage.State{context,[],returned,removed,applied},column,bindings,tick))
def resource_record(~Context:Type,~I:Type,~P:Type,record:Stage.Record<I,P>,state:Stage.State<Context,I,P>,previous:P) -> P & Stage.State<Context,I,P>:
  match record state:
    case Stage.Record{R.Resource{},owner,undo} Stage.State{context,records,returned,removed,applied}:(owner,Stage.State{context,records,returned,previous <> removed,Stage.Applied{R.Resource{},undo} <> applied})
    case record Stage.State{context,records,returned,removed,applied}:(previous,Stage.State{context,record <> records,returned,removed,applied})
def resource_next(~Context:Type,~I:Type,~P:Type,next:P -> Stage.State<Context,I,P> -> P & Stage.State<Context,I,P>,observed:P & Stage.State<Context,I,P>) -> P & Stage.State<Context,I,P>:
  match observed:
    case (owner,state):next(owner,state)
def resource_records(~Context:Type,~I:Type,~P:Type,records:List<Stage.Record<I,P>>,state:Stage.State<Context,I,P>,owner:P) -> P & Stage.State<Context,I,P>:
  match records:
    case []:(owner,state)
    case record <> rest:resource_next(~Context,~I,~P,owner => state => resource_records(~Context,~I,~P,rest,state,owner),resource_record(~Context,~I,~P,record,state,owner))
def resource_join(~S:Data,~Context:Type,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,observed:P & Stage.State<Context,I,P>) -> Leaf.Resource<S,P,identity,project> & Stage.State<Context,I,P>:
  match observed:
    case (owner,state):(Leaf.Resource{owner,declaration},state)
def resources(~S:Data,~Context:Type,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,owner:Leaf.Resource<S,P,identity,project>,state:Stage.State<Context,I,P>) -> Leaf.Resource<S,P,identity,project> & Stage.State<Context,I,P>:
  match owner state:
    case Leaf.Resource{owner,declaration} Stage.State{context,records,returned,removed,applied}:resource_join(~S,~Context,~I,~P,~identity,~project,declaration,resource_records(~Context,~I,~P,List.reverse(&1,Stage.Record<I,P>,records),Stage.State{context,[],returned,removed,applied},owner))
