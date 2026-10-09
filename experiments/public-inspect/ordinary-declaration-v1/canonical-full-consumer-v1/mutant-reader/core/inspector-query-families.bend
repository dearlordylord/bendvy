import Base
import inspector-query-projection.bend as Q
import inspector.bend as I
import check.bend as K
import world.bend as W
import component.bend as C
import column.bend as Col
import compose.bend as P
import lifecycle.bend as L

# Closed nominal-family adapters; Check has no cursor/lifecycle factory.
type SlotMode is Data:
  Required{}
  Optional{}
def slot_mode(value:SlotMode) -> P.Selection:
  match value:
    case Required{}:P.Required{}
    case Optional{}:P.Optional{}
def inspect_joined(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,cursor:U32,observed:W.World<S,Store,R,E> & C.Access<V>) -> I.Frame<S,Store,R,E> & C.Access<V>:
  (world,value)=observed
  (I.Frame{world,cursor},value)
# Same reached mutation as retained full23 reader: keep C.get and World;
# replace only detached Inspector projection with ComponentAbsent.
def omitted_read(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,cursor:U32,observed:W.World<S,Store,R,E> & C.Access<V>) -> I.Frame<S,Store,R,E> & C.Access<V>:
  match observed:
    case (world,_):(I.Frame{world,cursor},C.ComponentAbsent{})
def inspect_read(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,frame:I.Frame<S,Store,R,E>,target:W.Handle<S>) -> I.Frame<S,Store,R,E> & C.Access<V>:
  match frame:
    case I.Frame{world,cursor}:omitted_read(~S,~Store,~R,~E,~V,cursor,C.get(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,family,world,target))
def inspect_matched(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,mode:P.Selection,observed:I.Frame<S,Store,R,E> & C.Access<V>) -> I.Frame<S,Store,R,E> & Bool:
  (frame,value)=observed
  (frame,P.selected_value(~V,mode,value))
# Membership uses the built-in identity-preserving presence projection.
def inspect_presence(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,frame:I.Frame<S,Store,R,E>,+target:W.Handle<S>) -> I.Frame<S,Store,R,E> & C.Access<Bool>:
  match frame:
    case I.Frame{world,cursor}:inspect_joined(~S,~Store,~R,~E,~Bool,cursor,C.get_allowed(~S,~Store,~R,~E,~Rest,~Payload,~Bool,~Token,~take,~put,~Col.present(~Payload),W.valid(~S,~Store,~R,~E,world,target),target))
def inspect_matches(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:P.Selection,frame:I.Frame<S,Store,R,E>,target:W.Handle<S>) -> I.Frame<S,Store,R,E> & Bool:
  inspect_matched(~S,~Store,~R,~E,~Bool,mode,inspect_presence(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,frame,target))
def inspect_slot(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:SlotMode) -> Q.DeclaredSelection<I.Frame<S,Store,R,E>,S,C.Access<V>>:
  Q.DeclaredSelection{frame => target => inspect_matches(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~slot_mode(mode),frame,target),frame => target => inspect_read(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,frame,target)}
def inspect_with(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<I.Frame<S,Store,R,E>,S>:
  Q.Predicate{frame => target => inspect_matches(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~P.Present{},frame,target)}
def inspect_without(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<I.Frame<S,Store,R,E>,S>:
  Q.Predicate{frame => target => inspect_matches(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~P.Absent{},frame,target)}
def check_joined(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,observed:W.World<S,Store,R,E> & C.Access<V>) -> K.Frame<S,Store,R,E> & C.Access<V>:
  (world,value)=observed
  (K.Frame{world},value)
def check_read(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,frame:K.Frame<S,Store,R,E>,target:W.Handle<S>) -> K.Frame<S,Store,R,E> & C.Access<V>:
  match frame:
    case K.Frame{world}:check_joined(~S,~Store,~R,~E,~V,C.get(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,family,world,target))
def check_matched(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,mode:P.Selection,observed:K.Frame<S,Store,R,E> & C.Access<V>) -> K.Frame<S,Store,R,E> & Bool:
  (frame,value)=observed
  (frame,P.selected_value(~V,mode,value))
# Membership uses the built-in identity-preserving presence projection.
def check_presence(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,frame:K.Frame<S,Store,R,E>,+target:W.Handle<S>) -> K.Frame<S,Store,R,E> & C.Access<Bool>:
  match frame:
    case K.Frame{world}:check_joined(~S,~Store,~R,~E,~Bool,C.get_allowed(~S,~Store,~R,~E,~Rest,~Payload,~Bool,~Token,~take,~put,~Col.present(~Payload),W.valid(~S,~Store,~R,~E,world,target),target))
def check_matches(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:P.Selection,frame:K.Frame<S,Store,R,E>,target:W.Handle<S>) -> K.Frame<S,Store,R,E> & Bool:
  check_matched(~S,~Store,~R,~E,~Bool,mode,check_presence(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,frame,target))
def check_slot(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:SlotMode) -> Q.DeclaredSelection<K.Frame<S,Store,R,E>,S,C.Access<V>>:
  Q.DeclaredSelection{frame => target => check_matches(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~slot_mode(mode),frame,target),frame => target => check_read(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,frame,target)}
def check_with(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<K.Frame<S,Store,R,E>,S>:
  Q.Predicate{frame => target => check_matches(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~P.Present{},frame,target)}
def check_without(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<K.Frame<S,Store,R,E>,S>:
  Q.Predicate{frame => target => check_matches(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~P.Absent{},frame,target)}
def lifecycle_join(~S:Data,~Store:Type,~R:Type,~E:Data,~mode:P.LifecycleSelection,+cursor:U32,observed:W.World<S,Store,R,E> & L.Stamp) -> I.Frame<S,Store,R,E> & Bool:
  (world,stamp)=observed
  (I.Frame{world,cursor},P.lifecycle_selected(mode,stamp,cursor))
def inspect_lifecycle(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:P.LifecycleSelection,frame:I.Frame<S,Store,R,E>,target:W.Handle<S>) -> I.Frame<S,Store,R,E> & Bool:
  match frame:
    case I.Frame{world,cursor}:lifecycle_join(~S,~Store,~R,~E,~mode,cursor,C.lifecycle(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,family,world,target))
def inspect_filter(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:P.LifecycleSelection) -> Q.Predicate<I.Frame<S,Store,R,E>,S>:
  Q.both(~I.Frame<S,Store,R,E>,~S,~inspect_with(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family),~Q.Predicate{frame => target => inspect_lifecycle(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~mode,frame,target)})
