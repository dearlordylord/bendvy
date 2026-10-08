import Base
import ../joint.bend as J
import ../../../../src/ecs/inspector.bend as I
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/reader-domains.bend as D

# A declared lookup returns detached Data and the complete joint owner.
# This adapter preserves the existing Component Access verdicts; query-specific
# mismatch interpretation belongs to the declared query consumer.
def joined(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~V:Data,events:D.Events<S,E>,logs:Logs,registered:U32,ec:Nat,er:Nat,result:I.Frame<S,Store,R,E> & I.Value<V>) -> J.Frame<S,Store,R,E,Logs> & I.Value<V>:
  match result:
    case (I.Frame{world,cursor},value):(J.Frame{world,events,logs,cursor,registered,ec,er},value)
def get(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,frame:J.Frame<S,Store,R,E,Logs>,target:W.Handle<S>) -> J.Frame<S,Store,R,E,Logs> & I.Value<V>:
  match frame:
    case J.Frame{world,events,logs,cursor,registered,ec,er}:joined(~S,~Store,~R,~E,~Logs,~V,events,logs,registered,ec,er,I.family_get(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,I.Frame{world,cursor},target))
def grant(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>) -> I.Lookup<J.Frame<S,Store,R,E,Logs>,S,V>:
  I.Lookup{frame => target => get(~S,~Store,~R,~E,~Logs,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,frame,target)}
