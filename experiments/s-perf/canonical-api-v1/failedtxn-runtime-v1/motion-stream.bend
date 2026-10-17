import Base
import motion-dispose.bend as Dispose
import motion-program.bend as P
import motion-systems.bend as S
import motion-registration.bend as Reg
import motion-owner-observe.bend as O
import motion-observe.bend as W
import motion-boundary.bend as B
import motion-schedule.bend as Schedule
import motion.bend as F
import ../../../../src/ecs/world.bend as World
import ../dense-runtime-v1/types.bend as T

def prepend(values:List<&2,String>,acc:List<&2,String>) -> List<&2,String>:
  match values:
    case []:acc
    case head <> rest:prepend(rest,head <> acc)
def append(left:List<&2,String>,right:List<&2,String>) -> List<&2,String>:prepend(List.reverse(&2,String,left),right)
def shown_next(~A:Data,~render:A -> String,values:List<&2,A>) -> List<&2,String>:
  match values:
    case []:["]"]
    case head <> rest:", " <> render(head) <> shown_next(~A,~render,rest)
def shown(~A:Data,~render:A -> String,values:List<&2,A>) -> List<&2,String>:
  match values:
    case []:["]"]
    case head <> rest:render(head) <> shown_next(~A,~render,rest)
def status(value:P.Status) -> String:
  match value:
    case P.Complete{}:"Complete"
    case P.Stopped{reason}:"Stopped{" ++ W.audit_effect(reason) ++ "}"
def frames(value:S.Frame) -> List<&2,String>:
  match value:
    case S.Frame{first,second,iteration,phase,pending,retry,failed,calls}:append(["first=" ++ W.handle(first) ++ ";second=" ++ W.handle(second) ++ ";iteration=" ++ U32.show(iteration) ++ ";phase=" ++ U32.show(phase) ++ ";pendingA=" ++ O.maybe_handle(pending) ++ ";retryB=" ++ O.maybe_handle(retry) ++ ";failed=" ++ List.show(&2,World.Handle<T.MotionSchema>,W.handle,failed) ++ ";calls=["],shown(~String,~W.audit_effect,calls))
def owners_join(left:Reg.Owners & String,right:Dispose.Registry() & String,frame:S.Frame) -> List<&2,String>:
  (_,registered)=left
  (_,dispose)=right
  append(["registered={" ++ registered ++ "};dispose={" ++ dispose ++ "};frame={"],append(frames(frame),["}"]))
def owners(value:S.Owners) -> List<&2,String>:
  match value:
    case S.Owners{registered,dispose,frame}:owners_join(O.registered(registered),O.registry(dispose),frame)
def world_text(value:F.World() & String) -> String:
  match value:
    case (_,text):text
def final(prefix:String,value:P.State) -> List<&2,String>:
  match value:
    case P.State{world,owner,ids,namespace,boundaries,schedules,result}:append([prefix ++ "final={namespace=" ++ U32.show(namespace) ++ ";ids=" ++ List.show(&2,U32,U32.show,Schedule.ids(ids)) ++ ";world={" ++ world_text(W.world(world)) ++ "};owners={"],append(owners(owner),append(["};boundaries=["],append(shown(~B.Boundary,~B.render,boundaries),append([";schedules=["],append(shown(~String,~W.audit_effect,schedules),[";status=" ++ status(result) ++ "}\n"]))))))
def write(values:List<&2,String>) -> IO(Unit):
  match values:
    case []:IO.pure(Unit,Unit{})
    case head <> rest:IO.bind(Unit,Unit,IO.write(head),_=>write(rest))
