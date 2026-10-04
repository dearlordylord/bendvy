import Base
import ./types.bend as T
import ./storage.bend as W
import ./identity.bend as I
import ./commands.bend as C
import ./storage-stage-fixture.bend as F
import ./readers.bend as R
import ./reader-host.bend as H

type State<-Schema: Data,-P: Data> is Type:
  State{logs: H.Logs<Schema,P>,readers: R.Readers,clock: R.Clock,output: String}
def initial_frame(-Schema: Data,-P: Data,result: H.Framed<Schema,P>) -> State<Schema,P>:
  match result:
    case H.Framed{logs,readers,clock}: State{logs,readers,clock,""}
def initial(-Schema: Data,-P: Data) -> State<Schema,P>:
  initial_frame(Schema,P,H.frame(Schema,P,H.initial(Schema,P,1),R.initial(),R.frame(R.clock())))
def flag(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def handles(-Schema: Data,values: List<&2,W.Handle<Schema>>) -> String:
  match values:
    case Nil{}: ""
    case Con{W.Handle{namespace,id},tail}: U32.show(namespace) ++ "/" ++ U32.show(id) ++ ";" ++ handles(Schema,tail)
def motion_code(value: T.MotionPing) -> U32:
  match value:
    case T.MotionPing{code}: code
def health_code(value: T.HealthPing) -> U32:
  match value:
    case T.HealthPing{code}: code
def show_codes(~P: Data,~code: P -> U32,values: List<&2,P>) -> String:
  match values:
    case Nil{}: ""
    case Con{head,tail}: U32.show(code(head)) ++ "," ++ show_codes(P,code,tail)
def show(~Schema: Data,~P: Data,~code: P -> U32,value: H.Delivery<Schema,P>) -> String:
  match value:
    case H.Delivery{T.ReadBoundary{since,streamSince,thisRun},messages,removed,despawned,ml,rl,dl}:
      "since=" ++ U32.show(since) ++ "/" ++ U32.show(streamSince) ++ ";run=" ++ U32.show(thisRun) ++ ";messages=" ++ show_codes(P,code,messages) ++ ";removed=" ++ handles(Schema,removed) ++ ";despawned=" ++ handles(Schema,despawned) ++ ";lag=" ++ flag(ml) ++ "/" ++ flag(rl) ++ "/" ++ flag(dl)
def read_done(~Schema: Data,~P: Data,~code: P -> U32,readers: R.Readers,clock: R.Clock,output: String,label: String,outcome: T.Outcome,result: H.Read<Schema,P>) -> State<Schema,P>:
  match result:
    case H.Read{logs,run,delivery}: State{logs,R.complete(readers,run,outcome),clock,output ++ label ++ ":" ++ show(Schema,P,code,delivery) ++ "\n"}
def read_started(~Schema: Data,~P: Data,~code: P -> U32,logs: H.Logs<Schema,P>,output: String,label: String,outcome: T.Outcome,result: R.Started) -> State<Schema,P>:
  match result:
    case R.Started{readers,clock,run}: read_done(Schema,P,code,readers,clock,output,label,outcome,H.read(Schema,P,logs,run))
def read(~Schema: Data,~P: Data,~code: P -> U32,state: State<Schema,P>,key: U32,label: String,outcome: T.Outcome) -> State<Schema,P>:
  match state:
    case State{logs,readers,clock,output}: read_started(Schema,P,code,logs,output,label,outcome,R.begin(readers,key,R.Interests{True{},[0],True{}},clock))
def framed(-Schema: Data,-P: Data,output: String,result: H.Framed<Schema,P>) -> State<Schema,P>:
  match result:
    case H.Framed{logs,readers,clock}: State{logs,readers,clock,output}
def frame(-Schema: Data,-P: Data,state: State<Schema,P>) -> State<Schema,P>:
  match state:
    case State{logs,readers,clock,output}: framed(Schema,P,output,H.frame(Schema,P,logs,readers,R.frame(clock)))
def ping_at(-Schema: Data,-P: Data,logs: H.Logs<Schema,P>,readers: R.Readers,clock: R.Clock,output: String,values: List<&2,P>) -> State<Schema,P>:
  match clock:
    case R.Clock{+tick,start,retained,number}: State{H.append_ping(Schema,P,logs,tick,values),readers,R.Clock{tick,start,retained,number},output}
def publish(-Schema: Data,-P: Data,state: State<Schema,P>,values: List<&2,P>) -> State<Schema,P>:
  match state:
    case State{logs,readers,clock,output}: ping_at(Schema,P,logs,readers,R.advance(clock),output,values)
def finish(-Schema: Data,-P: Data,state: State<Schema,P>) -> String:
  match state:
    case State{_,_,_,output}: output

def motion_bundle() -> W.Bundle<T.Position,T.Velocity,T.Selected>: W.Bundle{Some{T.Position{F.vector(10),7}},Some{T.Velocity{F.vector(1),True{}}},Some{T.Selected{8}}}
def motion_applied(logs: H.Logs<T.MotionSchema,T.MotionPing>,readers: R.Readers,clock: R.Clock,output: String,+tick: U32,result: W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,W.Change<T.MotionSchema>>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & State<T.MotionSchema,T.MotionPing>:
  match result:
    case (world,changes): (world,State{H.append_changes(T.MotionSchema,T.MotionPing,logs,tick,changes),readers,clock,output})
def motion_barrier_at(world: W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,logs: H.Logs<T.MotionSchema,T.MotionPing>,readers: R.Readers,clock: R.Clock,output: String) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & State<T.MotionSchema,T.MotionPing>:
  match clock:
    case R.Clock{+tick,start,retained,number}: motion_applied(logs,readers,R.Clock{tick,start,retained,number},output,tick,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,tick))
def motion_barrier(world: W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,state: State<T.MotionSchema,T.MotionPing>) -> W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & State<T.MotionSchema,T.MotionPing>:
  match state:
    case State{logs,readers,clock,output}: motion_barrier_at(world,logs,readers,R.advance(clock),output)
def motion_observed(result: W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & State<T.MotionSchema,T.MotionPing>) -> String:
  match result:
    case (world,state):
      state = frame(T.MotionSchema,T.MotionPing,publish(T.MotionSchema,T.MotionPing,state,[T.MotionPing{11},T.MotionPing{22}]))
      state = read(T.MotionSchema,T.MotionPing,motion_code,state,9,"no-lifecycle-boundary",T.Failure{7})
      state = frame(T.MotionSchema,T.MotionPing,state)
      state = read(T.MotionSchema,T.MotionPing,motion_code,state,0,"failed",T.Failure{7})
      state = read(T.MotionSchema,T.MotionPing,motion_code,state,0,"retry",T.Success{})
      state = read(T.MotionSchema,T.MotionPing,motion_code,state,1,"late",T.Success{})
      finish(T.MotionSchema,T.MotionPing,read(T.MotionSchema,T.MotionPing,motion_code,state,0,"completed",T.Success{}))
def motion_despawned(state: State<T.MotionSchema,T.MotionPing>,result: T.CommandResult<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>) -> String:
  match result:
    case T.CommandMissing{_,_}: "UNEXPECTED_MISSING\n"
    case T.CommandQueued{world}: motion_observed(motion_barrier(world,state))
def motion_removed(state: State<T.MotionSchema,T.MotionPing>,b: W.Handle<T.MotionSchema>,result: T.CommandResult<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>) -> String:
  match result:
    case T.CommandMissing{_,_}: "UNEXPECTED_MISSING\n"
    case T.CommandQueued{world}: motion_despawned(state,C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,b))
def motion_seeded(a: W.Handle<T.MotionSchema>,b: W.Handle<T.MotionSchema>,result: W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & State<T.MotionSchema,T.MotionPing>) -> String:
  match result:
    case (world,state): motion_removed(read(T.MotionSchema,T.MotionPing,motion_code,state,0,"added-not-removed",T.Success{}),b,C.remove_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,a))
def motion_reserved_b(a: W.Handle<T.MotionSchema>,result: T.Reservation<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,W.Handle<T.MotionSchema>,W.Bundle<T.Position,T.Velocity,T.Selected>>) -> String:
  match result:
    case T.ReserveRejected{_,_}: "UNEXPECTED_RESERVE_REJECTION\n"
    case T.Reserved{world,b}: motion_seeded(a,b,motion_barrier(world,initial(T.MotionSchema,T.MotionPing)))
def motion_reserved_a(result: T.Reservation<W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,W.Handle<T.MotionSchema>,W.Bundle<T.Position,T.Velocity,T.Selected>>) -> String:
  match result:
    case T.ReserveRejected{_,_}: "UNEXPECTED_RESERVE_REJECTION\n"
    case T.Reserved{world,a}: motion_reserved_b(a,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,motion_bundle()))
def motion_created(result: T.Creation<W.Factory,W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> String:
  match result:
    case T.CreateRejected{_}: "UNEXPECTED_CREATE_REJECTION\n"
    case T.Created{factory,world}: motion_reserved_a(C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,motion_bundle()))
def motion() -> String:
  motion_created(I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,F.motion_ledger,I.factory(),T.MotionOn{}))

def health_bundle() -> W.Bundle<T.Vitals,T.Armor,T.Tracked>: W.Bundle{Some{T.Vitals{F.vector(10),9,2}},Some{T.Armor{F.vector(1),3}},Some{T.Tracked{8}}}
def health_applied(logs: H.Logs<T.HealthSchema,T.HealthPing>,readers: R.Readers,clock: R.Clock,output: String,+tick: U32,result: W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,W.Change<T.HealthSchema>>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & State<T.HealthSchema,T.HealthPing>:
  match result:
    case (world,changes): (world,State{H.append_changes(T.HealthSchema,T.HealthPing,logs,tick,changes),readers,clock,output})
def health_barrier_at(world: W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,logs: H.Logs<T.HealthSchema,T.HealthPing>,readers: R.Readers,clock: R.Clock,output: String) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & State<T.HealthSchema,T.HealthPing>:
  match clock:
    case R.Clock{+tick,start,retained,number}: health_applied(logs,readers,R.Clock{tick,start,retained,number},output,tick,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,tick))
def health_barrier(world: W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,state: State<T.HealthSchema,T.HealthPing>) -> W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & State<T.HealthSchema,T.HealthPing>:
  match state:
    case State{logs,readers,clock,output}: health_barrier_at(world,logs,readers,R.advance(clock),output)
def health_observed(result: W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & State<T.HealthSchema,T.HealthPing>) -> String:
  match result:
    case (world,state):
      state = frame(T.HealthSchema,T.HealthPing,publish(T.HealthSchema,T.HealthPing,state,[T.HealthPing{11},T.HealthPing{22}]))
      state = read(T.HealthSchema,T.HealthPing,health_code,state,9,"no-lifecycle-boundary",T.Failure{7})
      state = frame(T.HealthSchema,T.HealthPing,state)
      state = read(T.HealthSchema,T.HealthPing,health_code,state,0,"failed",T.Failure{7})
      state = read(T.HealthSchema,T.HealthPing,health_code,state,0,"retry",T.Success{})
      state = read(T.HealthSchema,T.HealthPing,health_code,state,1,"late",T.Success{})
      finish(T.HealthSchema,T.HealthPing,read(T.HealthSchema,T.HealthPing,health_code,state,0,"completed",T.Success{}))
def health_despawned(state: State<T.HealthSchema,T.HealthPing>,result: T.CommandResult<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>) -> String:
  match result:
    case T.CommandMissing{_,_}: "UNEXPECTED_MISSING\n"
    case T.CommandQueued{world}: health_observed(health_barrier(world,state))
def health_removed(state: State<T.HealthSchema,T.HealthPing>,b: W.Handle<T.HealthSchema>,result: T.CommandResult<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>) -> String:
  match result:
    case T.CommandMissing{_,_}: "UNEXPECTED_MISSING\n"
    case T.CommandQueued{world}: health_despawned(state,C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,b))
def health_seeded(a: W.Handle<T.HealthSchema>,b: W.Handle<T.HealthSchema>,result: W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & State<T.HealthSchema,T.HealthPing>) -> String:
  match result:
    case (world,state): health_removed(read(T.HealthSchema,T.HealthPing,health_code,state,0,"added-not-removed",T.Success{}),b,C.remove_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,a))
def health_reserved_b(a: W.Handle<T.HealthSchema>,result: T.Reservation<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,W.Handle<T.HealthSchema>,W.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> String:
  match result:
    case T.ReserveRejected{_,_}: "UNEXPECTED_RESERVE_REJECTION\n"
    case T.Reserved{world,b}: health_seeded(a,b,health_barrier(world,initial(T.HealthSchema,T.HealthPing)))
def health_reserved_a(result: T.Reservation<W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,W.Handle<T.HealthSchema>,W.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> String:
  match result:
    case T.ReserveRejected{_,_}: "UNEXPECTED_RESERVE_REJECTION\n"
    case T.Reserved{world,a}: health_reserved_b(a,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,health_bundle()))
def health_created(result: T.Creation<W.Factory,W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> String:
  match result:
    case T.CreateRejected{_}: "UNEXPECTED_CREATE_REJECTION\n"
    case T.Created{factory,world}: health_reserved_a(C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,health_bundle()))
def health() -> String:
  health_created(I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,F.health_ledger,I.factory(),T.HealthOn{}))

def main() -> IO(Unit): IO.print("Motion\n" ++ motion() ++ "Health\n" ++ health())
