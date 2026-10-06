import Base
import ./cache.bend as CC
import ./cached-payload.bend as CP
import ./types.bend as T
import ./storage.bend as W
import ./readers.bend as R
import ./streams.bend as S

# Trusted host internals; public callbacks receive abstract declared operations.
# Clock mutation belongs to dispatcher/host. Every supplied stamp is actual.
type Logs<-Schema: Data,-P: Data> is Type:
  Logs{ping: S.PingLog<P>,removed: S.LifeLog<W.Handle<Schema>>,despawned: S.LifeLog<W.Handle<Schema>>}
type Framed<-Schema: Data,-P: Data> is Type:
  Framed{logs: Logs<Schema,P>,readers: R.Readers,clock: R.Clock}
type Delivery<-Schema: Data,-P: Data> is Data:
  Delivery{boundary: T.ReadBoundary,messages: List<&2,P>,removed: List<&2,W.Handle<Schema>>,despawned: List<&2,W.Handle<Schema>>,
    messageLag: Bool,removedLag: Bool,despawnedLag: Bool}
type Read<-Schema: Data,-P: Data> is Type:
  Read{logs: Logs<Schema,P>,run: R.Run,delivery: Delivery<Schema,P>}

def initial(-Schema: Data,-P: Data,+capacity: U32) -> Logs<Schema,P>:
  Logs{S.initial(P,capacity),S.life_initial(W.Handle<Schema>,capacity),S.life_initial(W.Handle<Schema>,capacity)}
def append_ping(-Schema: Data,-P: Data,logs: Logs<Schema,P>,tick: U32,values: List<&2,P>) -> Logs<Schema,P>:
  match logs:
    case Logs{ping,removed,despawned}: Logs{S.append(P,ping,tick,values),removed,despawned}
def append_change(-Schema: Data,-P: Data,logs: Logs<Schema,P>,tick: U32,change: W.Change<Schema>) -> Logs<Schema,P>:
  match logs change:
    case Logs{ping,removed,despawned} W.MainRemoved{handle}: Logs{ping,S.append_lifecycle(W.Handle<Schema>,removed,tick,[handle]),despawned}
    case Logs{ping,removed,despawned} W.Despawned{handle}: Logs{ping,removed,S.append_lifecycle(W.Handle<Schema>,despawned,tick,[handle])}
    case saved _: saved
def append_all(-Schema: Data,-P: Data,changes: List<&2,W.Change<Schema>>,+tick: U32,logs: Logs<Schema,P>) -> Logs<Schema,P>:
  match changes:
    case Nil{}: logs
    case Con{head,tail}: append_all(Schema,P,tail,tick,append_change(Schema,P,logs,tick,head))
def append_changes(-Schema: Data,-P: Data,logs: Logs<Schema,P>,tick: U32,changes: List<&2,W.Change<Schema>>) -> Logs<Schema,P>:
  append_all(Schema,P,changes,tick,logs)
def life_trim(-Schema: Data,log: S.LifeLog<W.Handle<Schema>>,window: Maybe<&2,U32>,holds: List<&2,U32>) -> S.LifeLog<W.Handle<Schema>>:
  match window:
    case None{}: log
    case Some{tick}: S.trim_lifecycle(W.Handle<Schema>,log,tick,holds)
def frame_despawned(-Schema: Data,-P: Data,ping: S.PingLog<P>,removed: S.LifeLog<W.Handle<Schema>>,despawned: S.LifeLog<W.Handle<Schema>>,
  clock: R.Clock,window: Maybe<&2,U32>,result: R.Readers & List<&2,U32>) -> Framed<Schema,P>:
  match result:
    case (readers,holds): Framed{Logs{ping,removed,life_trim(Schema,despawned,window,holds)},readers,clock}
def frame_removed(-Schema: Data,-P: Data,ping: S.PingLog<P>,removed: S.LifeLog<W.Handle<Schema>>,despawned: S.LifeLog<W.Handle<Schema>>,
  clock: R.Clock,+window: Maybe<&2,U32>,result: R.Readers & List<&2,U32>) -> Framed<Schema,P>:
  match result:
    case (readers,holds): frame_despawned(Schema,P,ping,life_trim(Schema,removed,window,holds),despawned,clock,window,R.holders(readers,R.Despawned{}))
def frame_ping(-Schema: Data,-P: Data,ping: S.PingLog<P>,removed: S.LifeLog<W.Handle<Schema>>,despawned: S.LifeLog<W.Handle<Schema>>,
  clock: R.Clock,window: Maybe<&2,U32>,messageWindow: U32,result: R.Readers & List<&2,U32>) -> Framed<Schema,P>:
  match result:
    case (readers,holds): frame_removed(Schema,P,S.trim(P,ping,messageWindow,holds),removed,despawned,clock,window,R.holders(readers,R.Removed{0}))
def frame(-Schema: Data,-P: Data,logs: Logs<Schema,P>,readers: R.Readers,frame: R.Frame) -> Framed<Schema,P>:
  match logs frame:
    case Logs{ping,removed,despawned} R.Frame{clock,window,messageWindow}: frame_ping(Schema,P,ping,removed,despawned,clock,window,messageWindow,R.holders(readers,R.Messages{}))

def read_despawned(-Schema: Data,-P: Data,ping: S.PingLog<P>,removed: S.LifeLog<W.Handle<Schema>>,boundary: T.ReadBoundary,
  messages: List<&2,P>,removedValues: List<&2,W.Handle<Schema>>,messageLag: Bool,removedLag: Bool,despawnedLag: Bool,
  result: S.LifeRead<W.Handle<Schema>>) -> Read<Schema,P>:
  match result:
    case S.LifeRead{despawned,run,values}: Read{Logs{ping,removed,despawned},run,Delivery{boundary,messages,removedValues,values,messageLag,removedLag,despawnedLag}}
def read_despawned_missed(-Schema: Data,-P: Data,ping: S.PingLog<P>,removed: S.LifeLog<W.Handle<Schema>>,boundary: T.ReadBoundary,
  messages: List<&2,P>,removedValues: List<&2,W.Handle<Schema>>,messageLag: Bool,removedLag: Bool,
  result: S.LifeLog<W.Handle<Schema>> & (R.Run & Bool)) -> Read<Schema,P>:
  match result:
    case (despawned,(run,lag)): read_despawned(Schema,P,ping,removed,boundary,messages,removedValues,messageLag,removedLag,lag,S.read_lifecycle(W.Handle<Schema>,despawned,run))
def read_removed(-Schema: Data,-P: Data,ping: S.PingLog<P>,despawned: S.LifeLog<W.Handle<Schema>>,boundary: T.ReadBoundary,
  messages: List<&2,P>,messageLag: Bool,removedLag: Bool,result: S.LifeRead<W.Handle<Schema>>) -> Read<Schema,P>:
  match result:
    case S.LifeRead{removed,run,values}: read_despawned_missed(Schema,P,ping,removed,boundary,messages,values,messageLag,removedLag,S.missed(W.Handle<Schema>,despawned,run))
def read_removed_missed(-Schema: Data,-P: Data,ping: S.PingLog<P>,despawned: S.LifeLog<W.Handle<Schema>>,boundary: T.ReadBoundary,
  messages: List<&2,P>,messageLag: Bool,result: S.LifeLog<W.Handle<Schema>> & (R.Run & Bool)) -> Read<Schema,P>:
  match result:
    case (removed,(run,lag)): read_removed(Schema,P,ping,despawned,boundary,messages,messageLag,lag,S.read_lifecycle(W.Handle<Schema>,removed,run))
def read_ping(-Schema: Data,-P: Data,removed: S.LifeLog<W.Handle<Schema>>,despawned: S.LifeLog<W.Handle<Schema>>,boundary: T.ReadBoundary,
  result: S.PingRead<P>) -> Read<Schema,P>:
  match result:
    case S.PingRead{ping,run,messages,lag}: read_removed_missed(Schema,P,ping,despawned,boundary,messages,lag,S.missed(W.Handle<Schema>,removed,run))
def read_info(-Schema: Data,-P: Data,logs: Logs<Schema,P>,info: R.RunInfo) -> Read<Schema,P>:
  match logs info:
    case Logs{ping,removed,despawned} R.RunInfo{run,_,boundary}: read_ping(Schema,P,removed,despawned,boundary,S.read_ping(P,ping,run))
def read(-Schema: Data,-P: Data,logs: Logs<Schema,P>,run: R.Run) -> Read<Schema,P>:
  read_info(Schema,P,logs,R.project(run))
