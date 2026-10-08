import Base
import removal-publication.bend as P
import removal-log.bend as L
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/reader-domains.bend as D
import ../../../src/ecs/event-runtime.bend as Ev

type Collected<S:Data,Store:Type,R:Type,E:Data,Logs:Type> is Type:
  Collected{world:W.World<S,Store,R,E>,events:D.Events<S,E>,logs:Logs}
def selected(~S:Data,~F:Data,value:Maybe<&2,P.Notice<S,F>>,rest:List<&2,P.Notice<S,F>>) -> List<&2,P.Notice<S,F>>:
  match value:
    case None{}:rest
    case Some{notice}:notice <> rest
def notices(~S:Data,~F:Data,~E:Data,~select:E -> Maybe<&2,P.Notice<S,F>>,values:List<&2,E>) -> List<&2,P.Notice<S,F>>:
  match values:
    case []:[]
    case value <> rest:selected(~S,~F,select(value),notices(~S,~F,~E,~select,rest))
def append(~S:Data,~F:Data,~H:Type,log:L.Log<S,F,H>,fresh:List<&2,P.Notice<S,F>>) -> L.Log<S,F,H>:
  match log:
    case L.Log{holders,old,dropped,capacity}:L.Log{holders,Ev.append(~P.Notice<S,F>,old,fresh),dropped,capacity}
# Exclusive new-domain adapter. The closed absorb callback receives the complete
# Data inbox and owns an arbitrary heterogeneous record of declared stream logs.
# It must distribute notices to every declared family/despawn stream. No Type
# log owner or World owner is copied. Production offset readers remain unchanged.
def absorbed(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~absorb_values:Logs -> List<&2,E> -> Logs,events:D.Events<S,E>,logs:Logs,view:W.World<S,Store,R,E> & List<&2,E>) -> Collected<S,Store,R,E,Logs>:
  (world,values)=view
  Collected{W.events_replace(~S,~Store,~R,~E,world,[]),events,absorb_values(logs,values)}
def absorb(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~absorb_values:Logs -> List<&2,E> -> Logs,events:D.Events<S,E>,logs:Logs,world:W.World<S,Store,R,E>) -> Collected<S,Store,R,E,Logs>:
  absorbed(~S,~Store,~R,~E,~Logs,~absorb_values,events,logs,W.events_view(~S,~Store,~R,~E,world))
def collect(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~is_event:E -> Bool,~absorb_values:Logs -> List<&2,E> -> Logs,events:D.Events<S,E>,logs:Logs,world:W.World<S,Store,R,E>) -> Collected<S,Store,R,E,Logs>:
  D.drive(~S,~Store,~R,~E,~Logs,~Collected<S,Store,R,E,Logs>,~is_event,~(eventOwner => logOwner => w => absorb(~S,~Store,~R,~E,~Logs,~absorb_values,eventOwner,logOwner,w)),events,logs,world)
def recovered(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~absorb_values:Logs -> List<&2,E> -> Logs,logs:Logs,result:D.Detached<S,Store,R,E>) -> Collected<S,Store,R,E,Logs>:
  match result:
    case D.Detached{world,events}:absorb(~S,~Store,~R,~E,~Logs,~absorb_values,events,logs,world)
def recover(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~is_event:E -> Bool,~absorb_values:Logs -> List<&2,E> -> Logs,runtime:Ev.Runtime<S,Store,R,E>,logs:Logs) -> Collected<S,Store,R,E,Logs>:
  recovered(~S,~Store,~R,~E,~Logs,~absorb_values,logs,D.recover(~S,~Store,~R,~E,~is_event,runtime,[]))
