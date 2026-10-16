import Base
import ./world.bend as W
import ./column.bend as Col
import ./component.bend as C
import ./lifecycle.bend as Life
import ./recoverable-component.bend as RC
# Existing Family lenses remain trusted schema provisioning, not gameplay grants.
# No caller-authored inverse or recovery pack callback is introduced.
def replaced(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,handle:W.Handle<S>,stamp:Life.Stamp,result:C.Replacement<W.World<S,Store,R,E>,P>) -> RC.Replacement<W.World<S,Store,R,E>,S,P>:
  match result:
    case C.Replaced{world,previous}:RC.Applied{world,RC.Record{handle,stamp,previous}}
    case C.ReplaceRejected{world,incoming,error}:RC.Refused{world,incoming,error}
def stamped(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,family:C.Family<S,Store,Rest,P,V,Token,take,put,view>,+handle:W.Handle<S>,incoming:Maybe<P>,observed:W.World<S,Store,R,E> & Life.Stamp) -> RC.Replacement<W.World<S,Store,R,E>,S,P>:
  match observed:
    case (world,stamp):replaced(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,handle,stamp,C.replace(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,family,world,handle,incoming))
def replace(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,+family:C.Family<S,Store,Rest,P,V,Token,take,put,view>,world:W.World<S,Store,R,E>,+handle:W.Handle<S>,incoming:Maybe<P>) -> RC.Replacement<W.World<S,Store,R,E>,S,P>:
  stamped(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,family,handle,incoming,C.lifecycle(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,family,world,handle))
def column_returned(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,rest:Rest,result:Col.Column<S,P> & RC.Record<S,P>) -> Store & RC.Record<S,P>:
  match result:
    case (column,released):(put(rest,column),released)
def column_taken(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,record:RC.Record<S,P>,taken:Rest & Col.Column<S,P>) -> Store & RC.Record<S,P>:
  match record taken:
    case RC.Record{handle,stamp,payload}, (rest,column):column_returned(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,rest,RC.undo_column(~S,~P,handle,stamp,payload,column))
def undone(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,ns:U32,next:U32,high:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:R,events:List<&2,E>,pending:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,regs:List<&2,W.RegistrationMeta>,sid:U32,clock:U32,result:Store & RC.Record<S,P>) -> W.World<S,Store,R,E> & RC.Record<S,P>:
  match result:
    case (store,released):(W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock},released)
# Canonical undo_column restores the saved stamp and returns the displaced
# payload with its pre-undo stamp. Neither clocks nor unrelated owners rewind.
def undo_valid(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,record:RC.Record<S,P>,world:W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & RC.Record<S,P>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,sid,clock}:undone(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,ns,next,high,live,capacity,depth,resource,events,pending,regs,sid,clock,column_taken(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,record,take(store)))
def undo_checked(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,record:RC.Record<S,P>,checked:W.World<S,Store,R,E> & Bool) -> W.World<S,Store,R,E> & RC.Record<S,P>:
  match checked:
    case (world,False{}):(world,record)
    case (world,True{}):undo_valid(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,record,world)
def undo(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~family:C.Family<S,Store,Rest,P,V,Token,take,put,view>,record:RC.Record<S,P>,world:W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & RC.Record<S,P>:
  match record:
    case RC.Record{+handle,stamp,payload}:undo_checked(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,RC.Record{handle,stamp,payload},W.valid(~S,~Store,~R,~E,world,handle))
