import Base
import ./types.bend as T
import ./readers.bend as R
import ./host-observations.bend as E
import ./storage.bend as S
import ./host.bend as H
import ./host-render.bend as J
import ./dispatcher.bend as D
import ./schedule.bend as K
import ./measurement-lifecycle.bend as L
import ./measurement-failure-host.bend as F
import ./measurement-failure-fixture.bend as I
import ./measurement-failure-observe.bend as O

def quiet_audit(owner:Maybe<D.Audit>) -> IO(Unit):
  match owner:
    case None{}: IO.print("FAILURE-AUDIT-COUNT:0")
    case Some{D.Console{}}: IO.die(Unit,26,"recording Audit required")
    case Some{D.Recorded{effects}}: IO.print("FAILURE-AUDIT-COUNT:" ++ Nat.show(List.length(&2,String,effects)))

def node_case(mode:K.Mode,found:Maybe<&2,K.System>) -> List<&2,K.Node>:
  match found:
    case Some{system}: [K.Call{system,mode}]
    case None{}: []
def node(name:String,mode:K.Mode,systems:List<&2,K.System>) -> List<&2,K.Node>:
  node_case(mode,I.find(name,systems))

def kept(-Schema:Data,keep:Bool,binding:E.Binding<Schema>,rest:List<&2,E.Binding<Schema>>) -> List<&2,E.Binding<Schema>>:
  match keep:
    case True{}: binding <> rest
    case False{}: rest
def clear_retry(-Schema:Data,bindings:List<&2,E.Binding<Schema>>) -> List<&2,E.Binding<Schema>>:
  match bindings:
    case Nil{}: []
    case Con{E.Binding{+name,handle},rest}: kept(Schema,Bool.not(String.eq(name,"r")),E.Binding{name,handle},clear_retry(Schema,rest))
def motion_result(label:String,outcome:D.DispatchOutcome,owner:F.MotionFailure) -> F.MotionFailure:
  match owner:
    case F.MotionFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: F.MotionFailure{H.Host{world,logs,bindings,name,step,prior,List.append(&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>,events,[E.FailureResult{label,outcome}])},i,failed}
def motion_accept(valid:Bool,label:String,runtime:D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>,outcome:D.DispatchOutcome) -> IO(D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match valid:
    case True{}: IO.pure(D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>,L.runtime_map(F.MotionFailure,S.Handle<T.MotionSchema>,owner => motion_result(label,outcome,owner),runtime))
    case False{}: IO.die(D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>,11,"unexpected dispatch outcome")
def motion_checked(failing:Bool,label:String,result:D.Dispatched<F.MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match failing result:
    case True{} D.Dispatched{runtime,D.SystemFailure{+name,+code}}: motion_accept(Bool.and(String.eq(name,"B"),U32.is_eq(code,7)),label,runtime,D.SystemFailure{name,code})
    case False{} D.Dispatched{runtime,D.Complete{}}: motion_accept(True{},label,runtime,D.Complete{})
    case _ D.Dispatched{runtime,outcome}: motion_accept(False{},label,runtime,outcome)
def motion_phase(+phase:String,owner:F.MotionFailure) -> F.MotionFailure:
  match owner:
    case F.MotionFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: F.MotionFailure{H.Host{world,logs,bindings,name,phase,prior,events},i,failed}
def motion_step(failing:Bool,+label:String,nodes:List<&2,K.Node>,runtime:D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>):
  IO.bind(D.Dispatched<F.MotionFailure,S.Handle<T.MotionSchema>>,D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>,O.motion_tick(nodes,L.runtime_map(F.MotionFailure,S.Handle<T.MotionSchema>,owner => motion_phase(label,owner),runtime)),result => motion_checked(failing,label,result))
def motion_next(owner:F.MotionFailure) -> F.MotionFailure:
  match owner:
    case F.MotionFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: F.MotionFailure{H.Host{world,logs,clear_retry(T.MotionSchema,bindings),name,step,prior,events},U32.add(i,1),failed}
def motion_loops(fuel:Nat,+systems:List<&2,K.System>,runtime:D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match fuel:
    case 0n: IO.pure(D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>,runtime)
    case 1n+rest:
      do IO<D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>>:
        failed : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(True{},"fail",List.append(&2,K.Node,node("A",K.Normal{},systems),node("B",K.BFail{},systems)),runtime)
        seen : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"failed-before-barrier",node("Observe",K.Normal{},systems),failed)
        read : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"failed-publications",node("PublicationObserver",K.Observe{},systems),seen)
        retry : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"retry",node("B",K.Retry{},systems),read)
        seen : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"retry-before-barrier",node("Observe",K.Normal{},systems),retry)
        read : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"retry-publications",node("PublicationObserver",K.Observe{},systems),seen)
        applied : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"apply",[K.Deferred{}],read)
        seen : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"applied-FIFO",node("Observe",K.Normal{},systems),applied)
        disposed : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"dispose",List.append(&2,K.Node,node("DisposeTransient",K.Normal{},systems),[K.Deferred{}]),seen)
        seen : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"disposed",node("Observe",K.Normal{},systems),disposed)
        motion_loops(rest,systems,L.runtime_map(F.MotionFailure,S.Handle<T.MotionSchema>,motion_next,seen))
def motion_counts(clock:R.Clock,pair:K.Registry & List<&2,E.Count>) -> IO(Unit):
  match pair:
    case (_,counts): IO.print("FAILURE-COUNTS:" ++ J.render_list(E.Count,J.render_count,counts) ++ ":" ++ U32.show(H.clock_frame(clock)))
def audit_lines(values:List<&2,String>) -> IO(Unit):
  match values:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.print(head)
        audit_lines(tail)
def audit_records(value:Maybe<D.Audit>) -> IO(Unit):
  match value:
    case Some{D.Recorded{effects}}: audit_lines(List.reverse(&2,String,effects))
    case _: IO.die(Unit,26,"quiet actual Audit recording owner required")
def motion_events(events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>) -> IO(Unit):
  match events:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.write("FAILURE-DEFERRED:")
        J.write_motion(head)
        motion_events(tail)
def motion_final(runtime:D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match runtime:
    case D.Runtime{F.MotionFailure{H.Host{_,_,_,_,_,_,events},_,_},registry,_,+clock,audit,_,_,_,_}:
      do IO<Unit>:
        quiet_audit(audit)
        IO.print("FAILURE-EVENT-COUNT:" ++ Nat.show(List.length(&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>,events)))
        motion_counts(clock,H.count_registry(registry))
def motion_ready(count:U32,fuel:Nat,ready:I.Ready<F.MotionFailure,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match ready:
    case I.Ready{runtime,+systems}:
      do IO<Unit>:
        seeded : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- IO.bind(D.Dispatched<F.MotionFailure,S.Handle<T.MotionSchema>>,D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>,F.motion_seed_tick(count,List.append(&2,K.Node,node("Seed",K.Normal{},systems),[K.Deferred{}]),runtime),result => motion_checked(False{},"seed",result))
        prime : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_step(False{},"prime",List.append(&2,K.Node,node("B",K.Observe{},systems),node("PublicationObserver",K.Observe{},systems)),seeded)
        start : Nat <- IO.now()
        final : D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>> <- motion_loops(fuel,systems,prime)
        end : Nat <- IO.now()
        IO.print("FAILURE-TIMING:" ++ Nat.show(Nat.sub(end,start)))
        motion_final(final)
def motion_start(+count:U32,fuel:Nat) -> IO(Unit):
  IO.bind(I.Ready<F.MotionFailure,S.Handle<T.MotionSchema>>,Unit,I.motion_initial(count),ready => motion_ready(count,fuel,ready))

def health_result(label:String,outcome:D.DispatchOutcome,owner:F.HealthFailure) -> F.HealthFailure:
  match owner:
    case F.HealthFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: F.HealthFailure{H.Host{world,logs,bindings,name,step,prior,List.append(&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>,events,[E.FailureResult{label,outcome}])},i,failed}
def health_accept(valid:Bool,label:String,runtime:D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>,outcome:D.DispatchOutcome) -> IO(D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match valid:
    case True{}: IO.pure(D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>,L.runtime_map(F.HealthFailure,S.Handle<T.HealthSchema>,owner => health_result(label,outcome,owner),runtime))
    case False{}: IO.die(D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>,11,"unexpected dispatch outcome")
def health_checked(failing:Bool,label:String,result:D.Dispatched<F.HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match failing result:
    case True{} D.Dispatched{runtime,D.SystemFailure{+name,+code}}: health_accept(Bool.and(String.eq(name,"B"),U32.is_eq(code,7)),label,runtime,D.SystemFailure{name,code})
    case False{} D.Dispatched{runtime,D.Complete{}}: health_accept(True{},label,runtime,D.Complete{})
    case _ D.Dispatched{runtime,outcome}: health_accept(False{},label,runtime,outcome)
def health_phase(+phase:String,owner:F.HealthFailure) -> F.HealthFailure:
  match owner:
    case F.HealthFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: F.HealthFailure{H.Host{world,logs,bindings,name,phase,prior,events},i,failed}
def health_step(failing:Bool,+label:String,nodes:List<&2,K.Node>,runtime:D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>):
  IO.bind(D.Dispatched<F.HealthFailure,S.Handle<T.HealthSchema>>,D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>,O.health_tick(nodes,L.runtime_map(F.HealthFailure,S.Handle<T.HealthSchema>,owner => health_phase(label,owner),runtime)),result => health_checked(failing,label,result))
def health_next(owner:F.HealthFailure) -> F.HealthFailure:
  match owner:
    case F.HealthFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: F.HealthFailure{H.Host{world,logs,clear_retry(T.HealthSchema,bindings),name,step,prior,events},U32.add(i,1),failed}
def health_loops(fuel:Nat,+systems:List<&2,K.System>,runtime:D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match fuel:
    case 0n: IO.pure(D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>,runtime)
    case 1n+rest:
      do IO<D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>>:
        failed : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(True{},"fail",List.append(&2,K.Node,node("A",K.Normal{},systems),node("B",K.BFail{},systems)),runtime)
        seen : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"failed-before-barrier",node("Observe",K.Normal{},systems),failed)
        read : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"failed-publications",node("PublicationObserver",K.Observe{},systems),seen)
        retry : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"retry",node("B",K.Retry{},systems),read)
        seen : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"retry-before-barrier",node("Observe",K.Normal{},systems),retry)
        read : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"retry-publications",node("PublicationObserver",K.Observe{},systems),seen)
        applied : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"apply",[K.Deferred{}],read)
        seen : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"applied-FIFO",node("Observe",K.Normal{},systems),applied)
        disposed : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"dispose",List.append(&2,K.Node,node("DisposeTransient",K.Normal{},systems),[K.Deferred{}]),seen)
        seen : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"disposed",node("Observe",K.Normal{},systems),disposed)
        health_loops(rest,systems,L.runtime_map(F.HealthFailure,S.Handle<T.HealthSchema>,health_next,seen))
def health_counts(clock:R.Clock,pair:K.Registry & List<&2,E.Count>) -> IO(Unit):
  match pair:
    case (_,counts): IO.print("FAILURE-COUNTS:" ++ J.render_list(E.Count,J.render_count,counts) ++ ":" ++ U32.show(H.clock_frame(clock)))
def health_events(events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>) -> IO(Unit):
  match events:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.write("FAILURE-DEFERRED:")
        J.write_health(head)
        health_events(tail)
def health_final(runtime:D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match runtime:
    case D.Runtime{F.HealthFailure{H.Host{_,_,_,_,_,_,events},_,_},registry,_,+clock,audit,_,_,_,_}:
      do IO<Unit>:
        quiet_audit(audit)
        IO.print("FAILURE-EVENT-COUNT:" ++ Nat.show(List.length(&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>,events)))
        health_counts(clock,H.count_registry(registry))
def health_ready(count:U32,fuel:Nat,ready:I.Ready<F.HealthFailure,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match ready:
    case I.Ready{runtime,+systems}:
      do IO<Unit>:
        seeded : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- IO.bind(D.Dispatched<F.HealthFailure,S.Handle<T.HealthSchema>>,D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>,F.health_seed_tick(count,List.append(&2,K.Node,node("Seed",K.Normal{},systems),[K.Deferred{}]),runtime),result => health_checked(False{},"seed",result))
        prime : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_step(False{},"prime",List.append(&2,K.Node,node("B",K.Observe{},systems),node("PublicationObserver",K.Observe{},systems)),seeded)
        start : Nat <- IO.now()
        final : D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>> <- health_loops(fuel,systems,prime)
        end : Nat <- IO.now()
        IO.print("FAILURE-TIMING:" ++ Nat.show(Nat.sub(end,start)))
        health_final(final)
def health_start(+count:U32,fuel:Nat) -> IO(Unit):
  IO.bind(I.Ready<F.HealthFailure,S.Handle<T.HealthSchema>>,Unit,I.health_initial(count),ready => health_ready(count,fuel,ready))

def choose(schema:U32,count:U32,iterations:U32) -> IO(Unit):
  match schema:
    case 0: motion_start(count,U32.to_nat(iterations))
    case _: health_start(count,U32.to_nat(iterations))
def parsed(schema:Maybe<&2,U32>,count:Maybe<&2,U32>,iterations:Maybe<&2,U32>) -> IO(Unit):
  match schema count iterations:
    case Some{schema} Some{count} Some{iterations}: choose(schema,count,iterations)
    case _ _ _: IO.die(Unit,12,"invalid arguments")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,Con{iterations,_}}}}: parsed(U32.read(schema),U32.read(count),U32.read(iterations))
    case _: IO.die(Unit,12,"schema count iterations required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
