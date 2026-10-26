import Base
import ./execution-event-family.bend as Family
import ./owned-event-log.bend as Log

type Row<-V:Data> is Data:Row{id:Nat,value:V}
type View<-V:Data> is Data:
  View{identity:U32,open:Bool,next:Nat,active:List<&2,U32>,droppedThrough:Nat,rows:List<&2,Row<V>>}
def projected(~P:Type,~V:Data,+id:Nat,tail:List<Log.Row<P>>,views:List<&2,Row<V>>,result:P & V) -> List<Log.Row<P>> & List<&2,Row<V>>:
  match result:
    case (payload,value):(Log.Row{id,payload} <> tail,Row{id,value} <> views)
def row_returned(~P:Type,~V:Data,~project:P -> P & V,id:Nat,payload:P,result:List<Log.Row<P>> & List<&2,Row<V>>) -> List<Log.Row<P>> & List<&2,Row<V>>:
  match result:
    case (tail,views):projected(~P,~V,id,tail,views,project(payload))
def rows(~P:Type,~V:Data,~project:P -> P & V,source:List<Log.Row<P>>) -> List<Log.Row<P>> & List<&2,Row<V>>:
  match source:
    case []:([],[])
    case Log.Row{id,payload} <> tail:row_returned(~P,~V,~project,id,payload,rows(~P,~V,~project,tail))
def refreshed(~S:Data,~P:Type,~key:String,~V:Data,+identity:U32,+open:Bool,+next:Nat,previous:List<&2,Nat>,current:List<&2,Nat>,nextReader:U32,+active:List<&2,U32>,+dropped:Nat,result:List<Log.Row<P>> & List<&2,Row<V>>) -> Family.Family<S,P,key> & View<V>:
  match result:
    case (owners,views):(Family.Family{identity,open,Log.Log{next,owners},previous,current,nextReader,active,dropped},View{identity,open,next,active,dropped,views})
# Only a schema's Writable refresh traverses the payload owners.
# Ordinary reads consume the stored Data view and their own affine reader token.
def refresh(~S:Data,~P:Type,~key:String,~V:Data,~project:P -> P & V,family:Family.Family<S,P,key>) -> Family.Family<S,P,key> & View<V>:
  match family:
    case Family.Family{identity,open,Log.Log{next,source},previous,current,nextReader,active,dropped}:refreshed(~S,~P,~key,~V,identity,open,next,previous,current,nextReader,active,dropped,rows(~P,~V,~project,source))
def first_selected(~V:Data,selected:Bool,id:Nat,value:V,fallback:Maybe<&2,Row<V>>) -> Maybe<&2,Row<V>>:
  match selected:
    case True{}:Some{Row{id,value}}
    case False{}:fallback
def first_after(~V:Data,source:List<&2,Row<V>>,+cursor:Nat) -> Maybe<&2,Row<V>>:
  match source:
    case []:None{}
    case Row{+id,value} <> tail:first_selected(~V,Nat.is_lt(cursor,id),id,value,first_after(~V,tail,cursor))
def selected(~S:Data,~P:Type,~key:String,~V:Data,identity:U32,id:U32,cursor:Nat,missed:Nat,item:Maybe<&2,Row<V>>) -> Family.Reading<S,P,key,V>:
  match item:
    case None{}:Family.Empty{Family.Reader{identity,id,cursor},missed}
    case Some{Row{+next,value}}:Family.Item{Family.Reader{identity,id,next},next,value,missed}
def admitted(~S:Data,~P:Type,~key:String,~V:Data,refusal:Maybe<&2,Family.Refusal>,view:View<V>,reader:Family.Reader<S,P,key>) -> Family.Reading<S,P,key,V>:
  match refusal view reader:
    case Some{reason} _ reader:Family.ReadRefused{reader,reason}
    case None{} View{_,_,_,_,+dropped,source} Family.Reader{identity,id,+cursor}:selected(~S,~P,~key,~V,identity,id,Nat.max(cursor,dropped),Nat.sub(dropped,cursor),first_after(~V,source,Nat.max(cursor,dropped)))
# Bevy's iterator advances for every yielded message, including before a later error.
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/iterators.rs#L54-L99
# The returned token retains that progress; completion does not acknowledge it again.
def read(~S:Data,~P:Type,~key:String,~V:Data,view:View<V>,reader:Family.Reader<S,P,key>) -> Family.Reading<S,P,key,V>:
  match view reader:
    case View{+identity,+open,next,+active,dropped,source} Family.Reader{+actual,+id,cursor}:admitted(~S,~P,~key,~V,Family.admission(open,identity,actual,id,active),View{identity,open,next,active,dropped,source},Family.Reader{actual,id,cursor})
