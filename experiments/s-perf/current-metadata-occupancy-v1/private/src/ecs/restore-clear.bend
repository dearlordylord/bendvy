import Base
import ./restore-data.bend as R
import ./snapshot-leaf.bend as Leaf
import ./ordinary-declaration.bend as Identity
import ./persistence-declaration.bend as Decl
import ./decode-data.bend as D
import ./column.bend as Col
import ./world.bend as W
import ./owner-product.bend as Product

# Called only after complete staging and capacity admission. Old payloads leave
# scope here; no inverse, destructor or finalizer callback is executed.
def component_cleared(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,+handle:W.Handle<S>,observed:Col.SwapOutcome<S,P>) -> Leaf.Component<S,P,identity,project> & List<&2,R.Change<S>>:
  match observed:
    case Col.Accepted{column,Some{owner}}:(Leaf.Component{column,declaration},[R.Removed{handle,Identity.key(~S,~P,identity)}])
    case Col.Accepted{column,None{}}:(Leaf.Component{column,declaration},[])
    case Col.Rejected{column,_}:(Leaf.Component{column,declaration},[])
def component(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,owner:Leaf.Component<S,P,identity,project>,+handle:W.Handle<S>) -> Leaf.Component<S,P,identity,project> & List<&2,R.Change<S>>:
  match owner:
    case Leaf.Component{column,declaration}:component_cleared(~S,~P,~identity,~project,declaration,handle,Col.clear(~S,~P,column,W.handle_index(~S,handle)))
def transient_cleared(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,declaration:Decl.Transient<S,P,identity>,+handle:W.Handle<S>,observed:Col.SwapOutcome<S,P>) -> Leaf.TransientComponent<S,P,identity> & List<&2,R.Change<S>>:
  match observed:
    case Col.Accepted{column,Some{owner}}:(Leaf.TransientComponent{column,declaration},[R.Removed{handle,Identity.key(~S,~P,identity)}])
    case Col.Accepted{column,None{}}:(Leaf.TransientComponent{column,declaration},[])
    case Col.Rejected{column,_}:(Leaf.TransientComponent{column,declaration},[])
def transient_component_owned(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,owner:Leaf.TransientComponent<S,P,identity>,+handle:W.Handle<S>) -> Leaf.TransientComponent<S,P,identity> & List<&2,R.Change<S>>:
  match owner:
    case Leaf.TransientComponent{column,declaration}:transient_cleared(~S,~P,~identity,declaration,handle,Col.clear(~S,~P,column,W.handle_index(~S,handle)))
def transient_component(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,owner:Leaf.TransientComponent<S,P,identity>,handle:W.Handle<S>) -> Leaf.TransientComponent<S,P,identity> & List<&2,R.Change<S>>:
  transient_component_owned(~S,~P,~identity,owner,handle)
def unit(~S:Data,owner:Unit,handle:W.Handle<S>) -> Unit & List<&2,R.Change<S>>:(owner,[])
def product_join(~S:Data,~LC:Type,~RC:Type,left:LC,events:List<&2,R.Change<S>>,observed:RC & List<&2,R.Change<S>>) -> Product.Owner<LC,RC> & List<&2,R.Change<S>>:
  match observed:
    case (right,more):(Product.Owner{left,right},List.append(&2,R.Change<S>,events,more))
def product_left(~S:Data,~LC:Type,~RC:Type,~right:RC -> W.Handle<S> -> RC & List<&2,R.Change<S>>,owner:RC,handle:W.Handle<S>,observed:LC & List<&2,R.Change<S>>) -> Product.Owner<LC,RC> & List<&2,R.Change<S>>:
  match observed:
    case (left,events):product_join(~S,~LC,~RC,left,events,right(owner,handle))
def product(~S:Data,~LC:Type,~RC:Type,~left:LC -> W.Handle<S> -> LC & List<&2,R.Change<S>>,~right:RC -> W.Handle<S> -> RC & List<&2,R.Change<S>>,owner:Product.Owner<LC,RC>,+handle:W.Handle<S>) -> Product.Owner<LC,RC> & List<&2,R.Change<S>>:
  match owner:
    case Product.Owner{a,b}:product_left(~S,~LC,~RC,~right,b,handle,left(a,handle))
