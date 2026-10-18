import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend as Meter
import Base
import health-dispose.bend as Dispose
import health-program.bend as P
import health-app.bend as EntryApp
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-app-registration-fields.bend as Fields
import health-systems.bend as S
import health-registration.bend as Reg
import health-owner-observe.bend as O
import health-observe.bend as W
import health-boundary.bend as B
import health-schedule.bend as Schedule
import health.bend as F
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as World
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
    case S.Frame{first,second,iteration,phase,pending,retry,failed,calls,metrics}:append(["first=" ++ W.handle(first) ++ ";second=" ++ W.handle(second) ++ ";iteration=" ++ U32.show(iteration) ++ ";phase=" ++ U32.show(phase) ++ ";pendingA=" ++ O.maybe_handle(pending) ++ ";retryB=" ++ O.maybe_handle(retry) ++ ";failed=" ++ List.show(&2,World.Handle<T.HealthSchema>,W.handle,failed) ++ ";calls=["],shown(~String,~W.audit_effect,calls))
def owners_join(left:Reg.Owners & String,right:Dispose.Registry() & String,+frame:S.Frame) -> S.Owners & List<&2,String>:
  (registered,registeredText)=left
  (dispose,disposeText)=right
  (S.Owners{registered,dispose,frame},append(["registered={" ++ registeredText ++ "};dispose={" ++ disposeText ++ "};frame={"],append(frames(frame),["}"])))
def owners(value:S.Owners) -> S.Owners & List<&2,String>:
  match value:
    case S.Owners{registered,dispose,frame}:owners_join(O.registered(registered),O.registry(dispose),frame)
def world_text(value:F.World() & String) -> String:
  match value:
    case (_,text):text
type FinalInput is Data:
  FinalInput{prefix:String,namespace:U32,boundaries:List<&2,B.Boundary>,schedules:List<&2,String>,result:P.Status}
def final_join(ids:List<&2,U32>,input:FinalInput,observedWorld:F.World() & String,observedOwners:S.Owners & List<&2,String>) -> F.World() & (S.Runtime() & List<&2,String>):
  match input observedWorld observedOwners:
    case FinalInput{prefix,namespace,boundaries,schedules,result},(world,worldText),(owner,ownerChunks):(world,(S.pack(owner),append([prefix ++ "final={namespace=" ++ U32.show(namespace) ++ ";ids=" ++ List.show(&2,U32,U32.show,ids) ++ ";world={" ++ worldText ++ "};owners={"],append(ownerChunks,append(["};boundaries=["],append(shown(~B.Boundary,~B.render,boundaries),append([";schedules=["],append(shown(~String,~W.audit_effect,schedules),[";status=" ++ status(result) ++ "}\n"]))))))))
def final_folded(world:F.World(),input:FinalInput,value:S.Runtime() & List<&2,Fields.Fields<T.HealthSchema>>) -> F.World() & (S.Runtime() & List<&2,String>):
  match input value:
    case FinalInput{prefix,namespace,boundaries,schedules,result},(runtime,fields):final_join(Schedule.ids(fields),FinalInput{prefix,namespace,boundaries,schedules,result},W.world(world),owners(S.unpack(runtime)))
def final_projection(world:F.World(),runtime:S.Runtime(),input:FinalInput) -> F.World() & (S.Runtime() & List<&2,String>):
  final_folded(world,input,Schedule.fold(runtime))
def final_projected(value:EntryApp.Slot() & List<&2,String>) -> List<&2,String>:
  match value:
    case (_,chunks):chunks
def final(prefix:String,value:P.State) -> List<&2,String>:
  match value:
    case P.State{app,namespace,boundaries,schedules,result}:final_projected(EntryApp.project(~FinalInput,~List<&2,String>,~final_projection,app,FinalInput{prefix,namespace,boundaries,schedules,result}))
def write(values:List<&2,String>) -> IO(Unit):
  match values:
    case []:IO.pure(Unit,Unit{})
    case head <> rest:IO.bind(Unit,Unit,IO.write(head),_=>write(rest))

def final_profiled(prefix:String,result:P.State & List<&2,Meter.Sample>) -> List<&2,String> & List<&2,Meter.Sample>:
  (owner,metrics)=result
  (final(prefix,owner),metrics)
def final_profile(prefix:String,owner:P.State) -> List<&2,String> & List<&2,Meter.Sample>:final_profiled(prefix,P.metrics(owner))
