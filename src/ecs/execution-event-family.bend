import Base
import ./owned-event-log.bend as Log

type Family<-S:Data,-P:Type,-key:String> is Type:
  Family{identity:U32,open:Bool,log:Log.Log<P>,previous:List<&2,Nat>,current:List<&2,Nat>,nextReader:U32,active:List<&2,U32>,droppedThrough:Nat}
type Reader<-S:Data,-P:Type,-key:String> is Type:
  Reader{identity:U32,id:U32,cursor:Nat}
type Creation<-S:Data,-P:Type,-key:String> is Type:
  Created{family:Family<S,P,key>}
  CreationRefused{}
type Start is Data:
  Retained{}
  Future{}
type Refusal is Data:
  Closed{}
  ForeignLog{}
  Inactive{}
  ReaderLimit{}
  MissingPayload{}
type Publication<-P:Type> is Type:
  Published{id:Nat}
  PublicationRefused{payload:P}
type Registration<-S:Data,-P:Type,-key:String> is Type:
  Registered{reader:Reader<S,P,key>}
  RegistrationRefused{reason:Refusal}
type Reading<-S:Data,-P:Type,-key:String,V:Data> is Type:
  Item{reader:Reader<S,P,key>,id:Nat,value:V,missed:Nat}
  Empty{reader:Reader<S,P,key>,missed:Nat}
  ReadRefused{reader:Reader<S,P,key>,reason:Refusal}
type Removal<-S:Data,-P:Type,-key:String> is Type:
  Removed{reader:Reader<S,P,key>}
  RemovalRefused{reader:Reader<S,P,key>,reason:Refusal}
type Snapshot is Data:
  Snapshot{identity:U32,open:Bool,next:Nat,previous:List<&2,Nat>,current:List<&2,Nat>,nextReader:U32,active:List<&2,U32>,droppedThrough:Nat}

def created(~S:Data,~P:Type,~key:String,+identity:U32,valid:Bool) -> Creation<S,P,key>:
  match valid:
    case False{}:CreationRefused{}
    case True{}:Created{Family{identity,True{},Log.empty(~P),[],[],1,[],0n}}
def allocated(~S:Data,~P:Type,~key:String,+identity:U32) -> Creation<S,P,key>:
  created(~S,~P,~key,identity,Bool.and(U32.is_lt(0,identity),U32.is_lt(identity,4294967295)))
def has(+ids:List<&2,U32>,+wanted:U32) -> Bool:
  match ids:
    case []:False{}
    case id <> rest:Bool.or(U32.is_eq(id,wanted),has(rest,wanted))
def without_selected(equal:Bool,id:U32,rest:List<&2,U32>) -> List<&2,U32>:
  match equal:
    case True{}:rest
    case False{}:id <> rest
def without(ids:List<&2,U32>,+wanted:U32) -> List<&2,U32>:
  match ids:
    case []:[]
    case +id <> rest:without_selected(U32.is_eq(id,wanted),id,without(rest,wanted))
def published(~S:Data,~P:Type,~key:String,identity:U32,previous:List<&2,Nat>,current:List<&2,Nat>,nextReader:U32,active:List<&2,U32>,dropped:Nat,result:Log.Log<P> & Nat) -> Family<S,P,key> & Publication<P>:
  match result:
    case (log,+id):(Family{identity,True{},log,previous,List.append(&2,Nat,current,[id]),nextReader,active,dropped},Published{id})
# Publication updates the owned log immediately, as Bevy Messages.write does.
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L120-L143
# A later handled body error does not stage or undo this already-authored send.
def publish(~S:Data,~P:Type,~key:String,family:Family<S,P,key>,payload:P) -> Family<S,P,key> & Publication<P>:
  match family:
    case Family{identity,False{},log,previous,current,nextReader,active,dropped}:(Family{identity,False{},log,previous,current,nextReader,active,dropped},PublicationRefused{payload})
    case Family{identity,True{},log,previous,current,nextReader,active,dropped}:published(~S,~P,~key,identity,previous,current,nextReader,active,dropped,Log.append(~P,log,payload))
def starting(start:Start,next:Nat) -> Nat:
  match start:
    case Retained{}:0n
    case Future{}:Nat.sub(next,1n)
def register_checked(~S:Data,~P:Type,~key:String,start:Start,available:Bool,family:Family<S,P,key>) -> Family<S,P,key> & Registration<S,P,key>:
  match available family:
    case False{} family:(family,RegistrationRefused{ReaderLimit{}})
    case True{} Family{+identity,open,Log.Log{+next,rows},previous,current,+nextReader,active,dropped}:(Family{identity,open,Log.Log{next,rows},previous,current,U32.add(nextReader,1),List.append(&2,U32,active,[nextReader]),dropped},Registered{Reader{identity,nextReader,starting(start,next)}})
def register(~S:Data,~P:Type,~key:String,start:Start,family:Family<S,P,key>) -> Family<S,P,key> & Registration<S,P,key>:
  match family:
    case Family{identity,False{},log,previous,current,nextReader,active,dropped}:(Family{identity,False{},log,previous,current,nextReader,active,dropped},RegistrationRefused{Closed{}})
    case Family{identity,True{},log,previous,current,+nextReader,active,dropped}:register_checked(~S,~P,~key,start,U32.is_lt(nextReader,4294967295),Family{identity,True{},log,previous,current,nextReader,active,dropped})
def admission_identity(same:Bool,active:Bool) -> Maybe<&2,Refusal>:
  match same active:
    case False{} _:Some{ForeignLog{}}
    case True{} False{}:Some{Inactive{}}
    case True{} True{}:None{}
def admission(open:Bool,identity:U32,actual:U32,id:U32,active:List<&2,U32>) -> Maybe<&2,Refusal>:
  match open:
    case False{}:Some{Closed{}}
    case True{}:admission_identity(U32.is_eq(identity,actual),has(active,id))
def remove_admitted(~S:Data,~P:Type,~key:String,refusal:Maybe<&2,Refusal>,family:Family<S,P,key>,reader:Reader<S,P,key>) -> Family<S,P,key> & Removal<S,P,key>:
  match refusal family reader:
    case Some{reason} family reader:(family,RemovalRefused{reader,reason})
    case None{} Family{identity,open,log,previous,current,nextReader,active,dropped} Reader{actual,+id,cursor}:(Family{identity,open,log,previous,current,nextReader,without(active,id),dropped},Removed{Reader{actual,id,cursor}})
def remove(~S:Data,~P:Type,~key:String,family:Family<S,P,key>,reader:Reader<S,P,key>) -> Family<S,P,key> & Removal<S,P,key>:
  match family reader:
    case Family{+identity,+open,log,previous,current,nextReader,+active,dropped} Reader{+actual,+id,cursor}:remove_admitted(~S,~P,~key,admission(open,identity,actual,id,active),Family{identity,open,log,previous,current,nextReader,active,dropped},Reader{actual,id,cursor})
def highest(ids:List<&2,Nat>,+initial:Nat) -> Nat:
  match ids:
    case []:initial
    case id <> rest:highest(rest,Nat.max(initial,id))
def updated(~S:Data,~P:Type,~key:String,identity:U32,current:List<&2,Nat>,nextReader:U32,active:List<&2,U32>,dropped:Nat,result:Log.Log<P> & List<Log.Row<P>>) -> Family<S,P,key> & List<Log.Row<P>>:
  match result:
    case (log,retired):(Family{identity,True{},log,current,[],nextReader,active,dropped},retired)
# Messages.update_drain returns the previous generation's actual payload owners.
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L187-L218
# Bend returns retained rows explicitly instead of claiming an automatic IO finalizer.
def update(~S:Data,~P:Type,~key:String,family:Family<S,P,key>) -> Family<S,P,key> & List<Log.Row<P>>:
  match family:
    case Family{identity,False{},log,previous,current,nextReader,active,dropped}:(Family{identity,False{},log,previous,current,nextReader,active,dropped},[])
    case Family{identity,True{},log,previous,+current,nextReader,active,dropped}:updated(~S,~P,~key,identity,current,nextReader,active,highest(previous,dropped),Log.retain(~P,log,current))
def shutdown_returned(~S:Data,~P:Type,~key:String,identity:U32,nextReader:U32,dropped:Nat,result:Log.Log<P> & List<Log.Row<P>>) -> Family<S,P,key> & List<Log.Row<P>>:
  match result:
    case (log,rows):(Family{identity,False{},log,[],[],nextReader,[],dropped},rows)
def shutdown(~S:Data,~P:Type,~key:String,family:Family<S,P,key>) -> Family<S,P,key> & List<Log.Row<P>>:
  match family:
    case Family{identity,_,log,previous,current,nextReader,_,dropped}:shutdown_returned(~S,~P,~key,identity,nextReader,highest(List.append(&2,Nat,previous,current),dropped),Log.drain(~P,log))
def snapshot(~S:Data,~P:Type,~key:String,family:Family<S,P,key>) -> Family<S,P,key> & Snapshot:
  match family:
    case Family{+identity,+open,Log.Log{+next,rows},+previous,+current,+nextReader,+active,+dropped}:(Family{identity,open,Log.Log{next,rows},previous,current,nextReader,active,dropped},Snapshot{identity,open,next,previous,current,nextReader,active,dropped})
