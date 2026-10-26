import Base
import ../execution-lifecycle-notices.bend as Notice
import ../change-tick.bend as Tick
import ../clock-state.bend as Clock
import ../world.bend as W
import ../entity-allocator.bend as A
import ../transaction.bend as T
import ../trace-facts.bend as Facts
import ../deferred-command.bend as Deferred
import ../compose.bend as Q
import ../component.bend as C
import ../column.bend as Col
import ./query-read-session.bend as Session

# Read operations retain this affine shell without inspecting its fields.
type Shell<-S:Data,-Store:Type,-R:Type,-E:Data> is Type:
  Shell{resource:R,worldEvents:List<&2,E>,pending:List<Deferred.Command<W.World<S,Store,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events:List<&2,E>,trace:Facts.State,lifecycle:Notice.Journal<S>}
type Frame<-S:Data,-Store:Type,-R:Type,-E:Data> is Type:
  Frame{namespace:U32,allocator:A.Allocator,store:Store,handle:W.Handle<S>,error:Maybe<&2,W.WorldError>,cursor:Maybe<&2,Tick.Tick>,shell:Shell<S,Store,R,E>}
def extract(~S:Data,~Store:Type,~R:Type,~E:Data,frame:Q.Frame<S,Store,R,E>) -> Frame<S,Store,R,E>:
  match frame:
    case Q.Frame{T.Tx{W.World{namespace,allocator,store,resource,worldEvents,pending,registrations,nextSystemId,clock,lifecycle},undo,commands,events,trace},handle,error,cursor}:Frame{namespace,allocator,store,handle,error,cursor,Shell{resource,worldEvents,pending,registrations,nextSystemId,clock,undo,commands,events,trace,lifecycle}}
def restore(~S:Data,~Store:Type,~R:Type,~E:Data,frame:Frame<S,Store,R,E>) -> Q.Frame<S,Store,R,E>:
  match frame:
    case Frame{namespace,allocator,store,handle,error,cursor,Shell{resource,worldEvents,pending,registrations,nextSystemId,clock,undo,commands,events,trace,lifecycle}}:Q.Frame{T.Tx{W.World{namespace,allocator,store,resource,worldEvents,pending,registrations,nextSystemId,clock,lifecycle},undo,commands,events,trace},handle,error,cursor}

def extract_value(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,observed:Q.Frame<S,Store,R,E> & V) -> Frame<S,Store,R,E> & V:
  match observed:
    case (frame,value):(extract(~S,~Store,~R,~E,frame),value)
def bridge_get(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~get:Q.Frame<S,Store,R,E> -> Q.Frame<S,Store,R,E> & V,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & V:
  extract_value(~S,~Store,~R,~E,~V,get(restore(~S,~Store,~R,~E,frame)))
def bridge_set(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~set:Q.Frame<S,Store,R,E> -> P -> Q.Frame<S,Store,R,E>,frame:Frame<S,Store,R,E>,value:P) -> Frame<S,Store,R,E>:
  extract(~S,~Store,~R,~E,set(restore(~S,~Store,~R,~E,frame),value))

def read_returned(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,handle:W.Handle<S>,error:Maybe<&2,W.WorldError>,shell:Shell<S,Store,R,E>,observed:Session.Owner<S,Store> & C.Access<V>) -> Frame<S,Store,R,E> & C.Access<V>:
  match observed:
    case (Session.Owner{namespace,allocator,store,cursor},value):(Frame{namespace,allocator,store,handle,error,cursor,shell},value)
def read(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & C.Access<V>:
  match frame:
    case Frame{namespace,allocator,store,+handle,error,cursor,shell}:read_returned(~S,~Store,~R,~E,~V,handle,error,shell,Session.read(~S,~Store,~Rest,~P,~V,~take,~put,~view,Session.Owner{namespace,allocator,store,cursor},handle))
def selected(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,mode:Q.Selection,observed:Frame<S,Store,R,E> & C.Access<V>) -> Frame<S,Store,R,E> & Bool:
  match observed:
    case (frame,value):(frame,Q.selected_value(~V,mode,value))
def family_match(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~mode:Q.Selection,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  selected(~S,~Store,~R,~E,~V,mode,read(~S,~Store,~R,~E,~Rest,~P,~V,~take,~put,~view,frame))
def all(~S:Data,~Store:Type,~R:Type,~E:Data,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  (frame,True{})
def and_selected(~S:Data,~Store:Type,~R:Type,~E:Data,~right:Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,observed:Frame<S,Store,R,E> & Bool) -> Frame<S,Store,R,E> & Bool:
  match observed:
    case (frame,False{}):(frame,False{})
    case (frame,True{}):right(frame)
def both(~S:Data,~Store:Type,~R:Type,~E:Data,~left:Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,~right:Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,frame:Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  and_selected(~S,~Store,~R,~E,~right,left(frame))
