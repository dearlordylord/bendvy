import Base
import motion-app.bend as EntryApp
import motion-codec-values.bend as V
import motion-buffer-codec.bend as C
import motion-domain.bend as D
import motion-systems.bend as S
import motion-program.bend as P
import motion-encode-buffer.bend as B
import ../../../../dense-runtime-v1/motion.bend as F

type OwnerView is Data:
  OwnerView{select:V.Local,reserve:V.Local,dispose:V.Local,observe:V.Local,frame:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>,calls:List<&2,S.Call>}
type StateView is Data:
  StateView{namespace:U32,ids:P.Ids,status:P.Status,world:V.World,foreign:V.World,owners:OwnerView,logs:List<&2,P.Log>}
def owners_done(+args:D.Frame,+digest:U32,+boundaries:List<&2,D.Boundary>,+calls:List<&2,S.Call>,selected:S.Instance(~S.select_runner) & V.Local,reserved:S.Instance(~S.reserve_runner) & V.Local,disposed:S.Instance(~S.dispose_runner) & V.Local,observed:S.Instance(~S.observe_runner) & V.Local) -> S.Owners & OwnerView:
  (select,ss)=selected
  (reserve,sr)=reserved
  (dispose,sd)=disposed
  (observe,so)=observed
  (S.Owners{select,reserve,dispose,observe,args,digest,boundaries,calls},OwnerView{ss,sr,sd,so,args,digest,boundaries,calls})
def owners(value:S.Owners) -> S.Owners & OwnerView:
  match value:
    case S.Owners{select,reserve,dispose,observe,args,digest,boundaries,calls}:owners_done(args,digest,boundaries,calls,S.instance(~S.select_runner,select),S.instance(~S.reserve_runner,reserve),S.instance(~S.dispose_runner,dispose),S.instance(~S.observe_runner,observe))
type StateSnapshot is Data:
  StateSnapshot{world:V.World,owners:OwnerView}
def state_snapshot_done(stage:U32,main:F.World() & V.World,registered:S.Owners & OwnerView) -> F.World() & (S.Runtime() & StateSnapshot):
  (main,sw)=main
  (owners,so)=registered
  (main,(S.with_stage(stage,S.pack(owners)),StateSnapshot{sw,so}))
def state_snapshot(main:F.World(),runtime:S.Runtime(),_:Unit) -> F.World() & (S.Runtime() & StateSnapshot):
  match runtime:
    case (((select,reserve),(dispose,observe)),S.Shared{frame,digest,boundaries,calls,stage}):state_snapshot_done(stage,V.world(main),owners(S.Owners{select,reserve,dispose,observe,frame,digest,boundaries,calls}))
def state_done(+identity:P.Ids,+namespace:U32,+logs:List<&2,P.Log>,+result:P.Status,main:EntryApp.Slot() & StateSnapshot,foreign:F.World() & V.World) -> P.State & StateView:
  (app,StateSnapshot{sw,so})=main
  (foreign,sf)=foreign
  (P.State{app,foreign,identity,namespace,logs,result},StateView{namespace,identity,result,sw,sf,so,logs})
def state(value:P.State) -> P.State & StateView:
  match value:
    case P.State{app,foreign,identity,namespace,logs,result}:state_done(identity,namespace,logs,result,EntryApp.project(~Unit,~StateSnapshot,~state_snapshot,app,Unit{}),V.world(foreign))
def list_header(~A:Data,values:List<&2,A>,buffer:B.Buffer) -> B.Buffer:C.n(List.length(&2,A,values),C.text("q",buffer))
def write_boundaries(values:List<&2,D.Boundary>) -> IO(Unit):
  match values:
    case []:IO.pure(Unit,Unit{})
    case head <> rest:IO.bind(Unit,Unit,B.write(C.boundary(head,B.empty())),_=>write_boundaries(rest))
def write_calls(values:List<&2,S.Call>) -> IO(Unit):
  match values:
    case []:IO.pure(Unit,Unit{})
    case head <> rest:IO.bind(Unit,Unit,B.write(C.call(head,B.empty())),_=>write_calls(rest))
def write_logs(values:List<&2,P.Log>) -> IO(Unit):
  match values:
    case []:IO.pure(Unit,Unit{})
    case head <> rest:IO.bind(Unit,Unit,B.write(C.log(head,B.empty())),_=>write_logs(rest))
def owners_prefix(select:V.Local,reserve:V.Local,dispose:V.Local,observe:V.Local,args:D.Frame,digest:U32,boundaries:List<&2,D.Boundary>) -> B.Buffer:list_header(~D.Boundary,boundaries,C.u(digest,C.frame(args,C.local(observe,C.local(dispose,C.local(reserve,C.local(select,C.text("N",B.empty()))))))))
def write_owners(value:OwnerView) -> IO(Unit):
  match value:
    case OwnerView{select,reserve,dispose,observe,args,digest,+boundaries,+calls}:IO.bind(Unit,Unit,B.write(owners_prefix(select,reserve,dispose,observe,args,digest,boundaries)),_=>IO.bind(Unit,Unit,write_boundaries(boundaries),_=>IO.bind(Unit,Unit,B.write(list_header(~S.Call,calls,B.empty())),_=>write_calls(calls))))
def write_body(value:StateView) -> IO(Unit):
  match value:
    case StateView{namespace,ids,result,world,foreign,registered,+logs}:IO.bind(Unit,Unit,B.write(C.status(result,C.ids(ids,C.u(namespace,B.empty())))),_=>IO.bind(Unit,Unit,B.write(C.world(world,B.empty())),_=>IO.bind(Unit,Unit,B.write(C.world(foreign,B.empty())),_=>IO.bind(Unit,Unit,write_owners(registered),_=>IO.bind(Unit,Unit,B.write(list_header(~P.Log,logs,B.empty())),_=>write_logs(logs))))))
