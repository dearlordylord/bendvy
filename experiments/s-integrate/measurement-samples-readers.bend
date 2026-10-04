import Base
import ./measurement-readers.bend as Q
import ./measurement-lifecycle.bend as L
import ./measurement-bend.bend as M
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./host-observations.bend as E
import ./dispatcher.bend as D
import ./schedule.bend as K

def motion_store(batches:List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>,pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>) -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>:
  match pair:
    case (runtime,events): (runtime,Con{events,batches})
def motion_continue(next:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> -> List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>> -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>),dispose:K.System,pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>):
  match pair:
    case (runtime,batches):
      do IO<D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>>:
        disposed : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- Q.motion_tick([K.Call{dispose,K.Normal{}},K.Deferred{}],runtime)
        next(L.runtime_map(L.MotionState,S.Handle<T.MotionSchema>,L.motion_next,disposed),batches)
def motion_loops(fuel:Nat,+systems:Q.Systems,runtime:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>,batches:List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>):
  match fuel systems:
    case 0n _: IO.pure(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>,(runtime,batches))
    case 1n+rest Q.Systems{spawn,dispose,_,_,_}:
      do IO<D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>>:
        seeded : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- Q.motion_tick([K.Call{spawn,K.Normal{}},K.Deferred{}],runtime)
        updated : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- Q.motion_iteration_nodes(systems,L.runtime_read(L.MotionState,S.Handle<T.MotionSchema>,U32,Q.motion_iteration,seeded))
        motion_continue(runtime => batches => motion_loops(rest,systems,runtime,batches),dispose,motion_store(batches,L.runtime_read(L.MotionState,S.Handle<T.MotionSchema>,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,Q.motion_drain_owner,updated)))
def motion_emit(batches:List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>) -> IO(Unit):
  match batches:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{events,tail}:
      do IO<Unit>:
        Q.motion_events(events)
        motion_emit(tail)
def motion_finished(start:Nat,systems:Q.Systems,pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>>) -> IO(Unit):
  match pair:
    case (runtime,batches):
      do IO<Unit>:
        end : Nat <- IO.now()
        motion_emit(List.reverse(&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,batches))
        read : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- Q.motion_final_drain(systems,runtime)
        clean : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- Q.motion_drain(read)
        checked : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- L.motion_checkpoint("final",clean)
        L.motion_finish(checked)
        IO.print("{\"timingMilliseconds\":" ++ Nat.show(Nat.sub(end,start)) ++ "}")
def motion_run(pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & Q.Systems) -> IO(Unit):
  match pair:
    case (state,+systems):
      do IO<Unit>:
        primed : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- Q.motion_final_drain(systems,state)
        initial : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- Q.motion_drain(primed)
        start : Nat <- IO.now()
        finished : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>> <- motion_loops(64n,systems,initial,[])
        motion_finished(start,systems,finished)
def motion_start(count:U32) -> IO(Unit):
  IO.bind(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),Unit,L.motion_created(count,I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,M.motion_ledger,I.factory(),T.MotionOn{})),pair => motion_run(Q.motion_register(pair)))

def health_store(batches:List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>,pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>) -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>:
  match pair:
    case (runtime,events): (runtime,Con{events,batches})
def health_continue(next:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> -> List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>> -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>),dispose:K.System,pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>):
  match pair:
    case (runtime,batches):
      do IO<D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>>:
        disposed : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- Q.health_tick([K.Call{dispose,K.Normal{}},K.Deferred{}],runtime)
        next(L.runtime_map(L.HealthState,S.Handle<T.HealthSchema>,L.health_next,disposed),batches)
def health_loops(fuel:Nat,+systems:Q.Systems,runtime:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>,batches:List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>):
  match fuel systems:
    case 0n _: IO.pure(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>,(runtime,batches))
    case 1n+rest Q.Systems{spawn,dispose,_,_,_}:
      do IO<D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>>:
        seeded : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- Q.health_tick([K.Call{spawn,K.Normal{}},K.Deferred{}],runtime)
        updated : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- Q.health_iteration_nodes(systems,L.runtime_read(L.HealthState,S.Handle<T.HealthSchema>,U32,Q.health_iteration,seeded))
        health_continue(runtime => batches => health_loops(rest,systems,runtime,batches),dispose,health_store(batches,L.runtime_read(L.HealthState,S.Handle<T.HealthSchema>,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,Q.health_drain_owner,updated)))
def health_emit(batches:List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>) -> IO(Unit):
  match batches:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{events,tail}:
      do IO<Unit>:
        Q.health_events(events)
        health_emit(tail)
def health_finished(start:Nat,systems:Q.Systems,pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>>) -> IO(Unit):
  match pair:
    case (runtime,batches):
      do IO<Unit>:
        end : Nat <- IO.now()
        health_emit(List.reverse(&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,batches))
        read : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- Q.health_final_drain(systems,runtime)
        clean : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- Q.health_drain(read)
        checked : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- L.health_checkpoint("final",clean)
        L.health_finish(checked)
        IO.print("{\"timingMilliseconds\":" ++ Nat.show(Nat.sub(end,start)) ++ "}")
def health_run(pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & Q.Systems) -> IO(Unit):
  match pair:
    case (state,+systems):
      do IO<Unit>:
        primed : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- Q.health_final_drain(systems,state)
        initial : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- Q.health_drain(primed)
        start : Nat <- IO.now()
        finished : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>> <- health_loops(64n,systems,initial,[])
        health_finished(start,systems,finished)
def health_start(count:U32) -> IO(Unit):
  IO.bind(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),Unit,L.health_created(count,I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,M.health_ledger,I.factory(),T.HealthOn{})),pair => health_run(Q.health_register(pair)))

def choose_bool(motion:Bool,count:U32) -> IO(Unit):
  match motion:
    case True{}: motion_start(count)
    case False{}: health_start(count)
def choose(schema:U32,count:U32) -> IO(Unit): choose_bool(U32.is_eq(schema,0),count)
def run(+schema:U32,+count:U32) -> IO(Unit):
  do IO<Unit>:
    choose(schema,count)
    choose(schema,count)
def parsed(schema:Maybe<&2,U32>,count:Maybe<&2,U32>) -> IO(Unit):
  match schema count:
    case Some{schema} Some{count}: run(schema,count)
    case _ _: IO.die(Unit,2,"schema count required")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,_}}}: parsed(U32.read(schema),U32.read(count))
    case _: IO.die(Unit,2,"schema count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
