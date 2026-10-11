import Base
import schema-families.bend as D
import runtime-owners.bend as Consumer
import core/column.bend as Col
import core/lifecycle.bend as L
import core/world.bend as W

def leaf(~T:Type,observed:T & String) -> Array<T> & String:
  (value,text)=observed
  (ALeaf{value},"leaf:" ++ text)
def node_join(~T:Type,leftObserved:Array<T> & String,rightObserved:Array<T> & String) -> Array<T> & String:
  (left,text)=leftObserved
  (right,other)=rightObserved
  (ANode{left,right},"node(" ++ text ++ "," ++ other ++ ")")
def array(~T:Type,~project:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,project(value))
    case ANode{left,right}:node_join(~T,array(~T,~project,left),array(~T,~project,right))
def u32_data(+value:U32) -> U32 & String:
  (value,U32.show(value))
def u32_value(value:U32) -> U32 & String:
  u32_data(value)
def u32_array(value:Array<U32>) -> Array<U32> & String:
  array(~U32,~u32_value,value)
def bool_data(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def bool_value(value:Bool) -> Bool & String:
  bool_data(value)
def bool_array(value:Array<Bool>) -> Array<Bool> & String:
  array(~Bool,~bool_value,value)
def stock_done(observed:Array<U32> & String) -> D.Stock & String:
  (cells,text)=observed
  (D.Stock{cells},text)
def stock(value:D.Stock) -> D.Stock & String:
  match value:
    case D.Stock{cells}:stock_done(u32_array(cells))
def title_done(observed:Array<U32> & String) -> D.Title & String:
  (cells,text)=observed
  (D.Title{cells},text)
def title(value:D.Title) -> D.Title & String:
  match value:
    case D.Title{cells}:title_done(u32_array(cells))
def active_done(observed:Array<U32> & String) -> D.Active & String:
  (cells,text)=observed
  (D.Active{cells},text)
def active(value:D.Active) -> D.Active & String:
  match value:
    case D.Active{cells}:active_done(u32_array(cells))
def count_done(observed:Array<U32> & String) -> D.Count & String:
  (cells,text)=observed
  (D.Count{cells},text)
def count(value:D.Count) -> D.Count & String:
  match value:
    case D.Count{cells}:count_done(u32_array(cells))
def optional_done(~Payload:Type,observed:Payload & String) -> Maybe<&1,Payload> & String:
  (owner,text)=observed
  (Some{owner},"some(" ++ text ++ ")")
def optional(~Payload:Type,~project:Payload -> Payload & String,value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match value:
    case None{}:(None{},"none")
    case Some{owner}:optional_done(~Payload,project(owner))
def stamp(value:L.Stamp) -> String:
  match value:
    case L.Stamp{added,changed}:U32.show(added) ++ ":" ++ U32.show(changed)
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,value}:U32.show(id) ++ ":" ++ stamp(value)
def column_done(~S:Data,~Payload:Type,+stamps:List<&2,L.Entry>,observed:Array<Maybe<&1,Payload>> & String) -> Col.Column<S,Payload> & String:
  (values,text)=observed
  (Col.Column{values,stamps},text ++ ";stamps=" ++ List.show(&2,L.Entry,entry,stamps))
def column(~S:Data,~Payload:Type,~project:Payload -> Payload & String,value:Col.Column<S,Payload>) -> Col.Column<S,Payload> & String:
  match value:
    case Col.Column{values,stamps}:column_done(~S,~Payload,stamps,array(~Maybe<&1,Payload>,~optional(~Payload,~project),values))
    case value:(value,"UNEXPECTED_NONORDINARY_COLUMN")
def store_3(~S:Data,a:Col.Column<S,D.Stock>,b:Col.Column<S,D.Title>,c:Col.Column<S,D.Active>,sa:String,sb:String,sc:String,observed:Col.Column<S,D.Count> & String) -> D.Store<S> & String:
  (d,sd)=observed
  (D.Store{a,b,c,d},"stock=" ++ sa ++ "|title=" ++ sb ++ "|active=" ++ sc ++ "|count=" ++ sd)
def store_2(~S:Data,a:Col.Column<S,D.Stock>,b:Col.Column<S,D.Title>,d:Col.Column<S,D.Count>,sa:String,sb:String,observed:Col.Column<S,D.Active> & String) -> D.Store<S> & String:
  (c,sc)=observed
  store_3(~S,a,b,c,sa,sb,sc,column(~S,~D.Count,~count,d))
def store_1(~S:Data,a:Col.Column<S,D.Stock>,c:Col.Column<S,D.Active>,d:Col.Column<S,D.Count>,sa:String,observed:Col.Column<S,D.Title> & String) -> D.Store<S> & String:
  (b,sb)=observed
  store_2(~S,a,b,d,sa,sb,column(~S,~D.Active,~active,c))
def store_0(~S:Data,b:Col.Column<S,D.Title>,c:Col.Column<S,D.Active>,d:Col.Column<S,D.Count>,observed:Col.Column<S,D.Stock> & String) -> D.Store<S> & String:
  (a,sa)=observed
  store_1(~S,a,c,d,sa,column(~S,~D.Title,~title,b))
def store(~S:Data,value:D.Store<S>) -> D.Store<S> & String:
  match value:
    case D.Store{a,b,c,d}:store_0(~S,b,c,d,column(~S,~D.Stock,~stock,a))
def extra_second(first:Array<U32>,text:String,observed:Array<U32> & String) -> Consumer.Extra & String:
  (second,other)=observed
  (Consumer.Extra{first,second},text ++ ";" ++ other)
def extra_first(second:Array<U32>,observed:Array<U32> & String) -> Consumer.Extra & String:
  (first,text)=observed
  extra_second(first,text,u32_array(second))
def extra(value:Consumer.Extra) -> Consumer.Extra & String:
  match value:
    case Consumer.Extra{first,second}:extra_first(second,u32_array(first))
def target(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,id}:U32.show(namespace) ++ ":" ++ U32.show(id)
def diagnostic(~S:Data,value:Consumer.Diagnostic<S>) -> String:
  match value:
    case Consumer.Diagnostic{targets,record,before,after,same,allowed,checks,ran}:"targets=" ++ List.show(&2,W.Handle<S>,target(~S),targets) ++ "|record=" ++ record ++ "|before=" ++ before ++ "|after=" ++ after ++ "|same=" ++ Bool.show(same) ++ "|allowed=" ++ Bool.show(allowed) ++ "|checks=" ++ U32.show(checks) ++ "|ran=" ++ U32.show(ran)
def resource_extra(~S:Data,cells:Array<U32>,text:String,+state:Consumer.Diagnostic<S>,observed:Consumer.Extra & String) -> Consumer.Resource<S> & String:
  (owner,other)=observed
  (Consumer.Resource{cells,owner,state},text ++ ";" ++ other ++ ";" ++ diagnostic(~S,state))
def resource_cells(~S:Data,owner:Consumer.Extra,state:Consumer.Diagnostic<S>,observed:Array<U32> & String) -> Consumer.Resource<S> & String:
  (cells,text)=observed
  resource_extra(~S,cells,text,state,extra(owner))
def resource(~S:Data,value:Consumer.Resource<S>) -> Consumer.Resource<S> & String:
  match value:
    case Consumer.Resource{cells,owner,state}:resource_cells(~S,owner,state,u32_array(cells))
def main() -> Unit:
  Unit{}
