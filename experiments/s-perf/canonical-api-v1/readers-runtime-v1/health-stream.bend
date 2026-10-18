import Base
import health.bend as F
import types.bend as T
import health-domain.bend as D
import health-systems.bend as S
import health-program.bend as P
import health-render.bend as R
import health-reader.bend as Reader
import health-reader-observe.bend as RO
import health-family.bend as Family
import health-observe.bend as O
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import health-events.bend as E

type OwnerView is Data:
  OwnerView{tick:Nat,args:D.Frame,phase:U32,ids:S.IDs,spawn:String,update:String,dispose:String,fast:String,slow:String,meta:String,locals:List<&2,S.LocalCall>,reads:List<&2,S.ReadCall>}
type StateView is Data:
  StateView{namespace:U32,status:P.Status,world:String,owners:OwnerView,logs:List<&2,P.Log>}
def owners_join(+tick:Nat,+args:D.Frame,+phase:U32,+id:S.IDs,+locals:List<&2,S.LocalCall>,+reads:List<&2,S.ReadCall>,spawn:S.Instance() & String,update:S.Instance() & String,dispose:S.Instance() & String,fast:Reader.Provider() & String,slow:Reader.Provider() & String,meta:Mixed.State<T.HealthSchema,E.Publication,Family.Family,Unit> & String) -> S.Owners & OwnerView:
  (spawn,ss)=spawn
  (update,su)=update
  (dispose,sd)=dispose
  (fast,sf)=fast
  (slow,sl)=slow
  (meta,sm)=meta
  (S.Owners{spawn,update,dispose,fast,slow,meta,tick,args,phase,id,locals,reads},OwnerView{tick,args,phase,id,ss,su,sd,sf,sl,sm,locals,reads})
def owners(value:S.Owners) -> S.Owners & OwnerView:
  match value:
    case S.Owners{spawn,update,dispose,fast,slow,meta,tick,args,phase,id,locals,reads}:owners_join(tick,args,phase,id,locals,reads,R.local(spawn),R.local(update),R.local(dispose),RO.provider(fast),RO.provider(slow),RO.meta(meta))
def state_join(+namespace:U32,+logs:List<&2,P.Log>,+status:P.Status,world:F.World() & String,owner:S.Owners & OwnerView) -> P.State & StateView:
  (world,sw)=world
  (owner,so)=owner
  (P.State{world,owner,namespace,logs,status},StateView{namespace,status,sw,so,logs})
def state(value:P.State) -> P.State & StateView:
  match value:
    case P.State{world,owner,namespace,logs,status}:state_join(namespace,logs,status,O.world(world),owners(owner))
def locals_go(values:List<&2,S.LocalCall>) -> IO(Unit):
  match values:
    case []:IO.write("]")
    case head <> rest:IO.bind(Unit,Unit,IO.write(", "),_=>IO.bind(Unit,Unit,IO.write(R.local_call(head)),_=>locals_go(rest)))
def write_locals(values:List<&2,S.LocalCall>) -> IO(Unit):
  match values:
    case []:IO.write("[]")
    case head <> rest:IO.bind(Unit,Unit,IO.write("["),_=>IO.bind(Unit,Unit,IO.write(R.local_call(head)),_=>locals_go(rest)))
def reads_go(values:List<&2,S.ReadCall>) -> IO(Unit):
  match values:
    case []:IO.write("]")
    case head <> rest:IO.bind(Unit,Unit,IO.write(", "),_=>IO.bind(Unit,Unit,IO.write(R.read_call(head)),_=>reads_go(rest)))
def write_reads(values:List<&2,S.ReadCall>) -> IO(Unit):
  match values:
    case []:IO.write("[]")
    case head <> rest:IO.bind(Unit,Unit,IO.write("["),_=>IO.bind(Unit,Unit,IO.write(R.read_call(head)),_=>reads_go(rest)))
def logs_go(values:List<&2,P.Log>) -> IO(Unit):
  match values:
    case []:IO.write("]")
    case head <> rest:IO.bind(Unit,Unit,IO.write(", "),_=>IO.bind(Unit,Unit,IO.write(R.log(head)),_=>logs_go(rest)))
def write_logs(values:List<&2,P.Log>) -> IO(Unit):
  match values:
    case []:IO.write("[]")
    case head <> rest:IO.bind(Unit,Unit,IO.write("["),_=>IO.bind(Unit,Unit,IO.write(R.log(head)),_=>logs_go(rest)))
def owners_prefix(value:OwnerView) -> (List<&2,S.LocalCall> & List<&2,S.ReadCall>) & String:
  match value:
    case OwnerView{tick,args,phase,id,spawn,update,dispose,fast,slow,meta,locals,reads}:((locals,reads),"ids={" ++ R.ids(id) ++ "};tick=" ++ Nat.show(tick) ++ ";phase=" ++ U32.show(phase) ++ ";frame={" ++ R.frame(args) ++ "};spawn={" ++ spawn ++ "};update={" ++ update ++ "};dispose={" ++ dispose ++ "};fast={" ++ fast ++ "};slow={" ++ slow ++ "};runtimeMeta={" ++ meta ++ "};localCalls=")
def write_owners_observed(observed:(List<&2,S.LocalCall> & List<&2,S.ReadCall>) & String) -> IO(Unit):
  match observed:
    case ((locals,reads),prefix):IO.bind(Unit,Unit,IO.write(prefix),_=>IO.bind(Unit,Unit,write_locals(locals),_=>IO.bind(Unit,Unit,IO.write(";readerCalls="),_=>write_reads(reads))))
def write_owners(value:OwnerView) -> IO(Unit):write_owners_observed(owners_prefix(value))
def write_state(value:StateView) -> IO(Unit):
  match value:
    case StateView{namespace,status,world,owners,logs}:IO.bind(Unit,Unit,IO.write("namespace=" ++ U32.show(namespace) ++ ";status=" ++ R.status_text(status) ++ ";world={" ++ world ++ "};owners={"),_=>IO.bind(Unit,Unit,write_owners(owners),_=>IO.bind(Unit,Unit,IO.write("};schedules="),_=>write_logs(logs))))
