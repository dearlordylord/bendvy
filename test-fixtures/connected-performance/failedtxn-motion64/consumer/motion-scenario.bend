import Base
import ../method/method.bend as Method
import report-doc.bend as Doc
import motion-stream.bend as Stream
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-registration.bend as Reg
import motion-local.bend as L
import motion-reader.bend as Reader
import motion-publications.bend as Publications
import motion-dispose.bend as Dispose
import motion-systems.bend as S
import motion-schedule.bend as Schedule
import motion-program.bend as Program
import motion-boundary.bend as Boundary
import motion-render.bend as Render
import motion-owner-observe.bend as Owners
import motion-reader-owner-observe.bend as RO
import motion-runtime-observe.bend as RT
import motion-observe.bend as O
import motion-doc-world.bend as DW
import motion-family.bend as Family
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../src/ecs/event-family-routing.bend as Route

def text(~A:Type,observed:A & String) -> String:
  match observed:
    case (_,value):value
def doc(~A:Type,observed:A & Doc.Doc) -> Doc.Doc:
  match observed:
    case (_,value):value
def status(value:Program.Status) -> String:
  match value:
    case Program.Complete{}:"Complete"
    case Program.Stopped{reason}:"Stopped{" ++ O.audit_effect(reason) ++ "}"
def state_view(value:Program.State & Program.Snapshot) -> Program.State & Doc.Doc:
  match value:
    case (Program.State{app,+namespace,+boundaries,+schedules,+result},Program.Snapshot{sw,so,ids}):(Program.State{app,namespace,boundaries,schedules,result},Doc.concat([Doc.text("namespace="),Doc.text(U32.show(namespace)),Doc.text(";ids="),Doc.text(List.show(&2,U32,U32.show,ids)),Doc.text(";world={"),sw,Doc.text("};owners={"),so,Doc.text("};boundaries="),Doc.show(~Boundary.Boundary,~Boundary.render,boundaries),Doc.text(";schedules="),Doc.text(List.show(&2,String,O.audit_effect,schedules)),Doc.text(";status="),Doc.text(status(result))]))
def state(value:Program.State) -> Program.State & Doc.Doc:state_view(Program.observe(value))
type Prepared is Type:
  Prepared{prefix:Doc.Doc,state:Program.State}
  PreparationFailed{report:Doc.Doc}
def primed(prefix:Doc.Doc,iterations:U32,value:Program.State & Doc.Doc) -> Prepared:
  match value:
    case (owner,snapshot):Prepared{Doc.concat([prefix,Doc.text("primed={"),snapshot,Doc.text("}\n")]),owner}
def registered(prefix:Doc.Doc,iterations:U32,value:Program.State & Doc.Doc) -> Prepared:
  match value:
    case (owner,snapshot):primed(Doc.concat([prefix,Doc.text("registered={"),snapshot,Doc.text("}\n")]),iterations,state(Program.run_phase(0,owner)))
def named(method:Method.State,prefix:Doc.Doc,iterations:U32,owners:Reg.Owners,dispose:Dispose.Registry(),first:W.Handle<T.MotionSchema>,second:W.Handle<T.MotionSchema>,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,ns):registered(prefix,iterations,state(Program.start(world,S.Owners{owners,dispose,S.Frame{first,second,0,0,None{},None{},[],[],method}},ns)))
def dispose_registered(method:Method.State,prefix:Doc.Doc,iterations:U32,owners:Reg.Owners,first:W.Handle<T.MotionSchema>,second:W.Handle<T.MotionSchema>,value:Sys.RegistrationResult<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.MotionSchema>>,Empty,Dispose.Output,Dispose.runner>) -> Prepared:
  match value:
    case Sys.Registered{world,registry}:named(method,prefix,iterations,owners,registry,first,second,W.namespace(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Sys.RegistrationFailed{world}:PreparationFailed{Doc.concat([prefix,Doc.text("DisposeRegistrationFailed;world={"),doc(~F.World(),DW.world(world)),Doc.text("};owners={"),Doc.text(text(~Reg.Owners,Owners.registered(owners))),Doc.text("}\n")])}
def optional_instance(value:Maybe<&1,L.Instance()>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~L.Instance(),Render.instance(owner)) ++ "}"
def optional_reader(value:Maybe<&1,Reader.Provider()>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~Reader.Provider(),RO.provider(owner)) ++ "}"
def optional_publications(value:Maybe<&1,Publications.Provider()>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~Publications.Provider(),RO.publications(owner)) ++ "}"
def optional_local(value:Maybe<&1,L.State>) -> String:
  match value:
    case None{}:"None"
    case Some{owner}:"Some{" ++ text(~L.State,Render.local(owner)) ++ "}"
def setup(method:Method.State,prefix:Doc.Doc,iterations:U32,first:W.Handle<T.MotionSchema>,second:W.Handle<T.MotionSchema>,value:Reg.Registration) -> Prepared:
  match value:
    case Reg.Ready{world,owners}:dispose_registered(method,prefix,iterations,owners,first,second,Sys.register(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,W.Handle<T.MotionSchema>>,~Empty,~Dispose.Output,~Dispose.runner,world,"FailedTxn/DisposeTransient",[Identity.key(~T.MotionSchema,~T.Position,F.main_identity()),Identity.key(~T.MotionSchema,~T.Velocity,F.aux_identity()),Identity.key(~T.MotionSchema,~T.Selected,F.flag_identity())]))
    case Reg.Stopped{context,stage,a,reader,pub,local}:PreparationFailed{Doc.concat([prefix,Doc.text("RegistrationStopped{stage="),Doc.text(U32.show(stage)),Doc.text(";context={"),Doc.text(text(~Family.Context(),RT.context(context))),Doc.text("};a="),Doc.text(optional_instance(a)),Doc.text(";reader="),Doc.text(optional_reader(reader)),Doc.text(";publications="),Doc.text(optional_publications(pub)),Doc.text(";local="),Doc.text(optional_local(local)),Doc.text("}\n")])}
def targets(prefix:Doc.Doc,iterations:U32,world:F.World(),+reservations:List<&2,W.Reservation<T.MotionSchema>>) -> Prepared:
  match reservations:
    case W.Reserved{first} <> W.Reserved{second} <> _:setup(Method.start(reservations),prefix,iterations,first,second,Reg.run(world))
    case _:PreparationFailed{Doc.concat([prefix,Doc.text("MissingSeedTargets;world={"),doc(~F.World(),DW.world(world)),Doc.text("}\n")])}
def seed_applied(prefix:Doc.Doc,iterations:U32,reservations:List<&2,W.Reservation<T.MotionSchema>>,observed:F.World() & Doc.Doc) -> Prepared:
  match observed:
    case (world,snapshot):targets(Doc.concat([prefix,Doc.text("seedApplied={"),snapshot,Doc.text("}\n")]),iterations,world,reservations)
def seed_pending(prefix:Doc.Doc,iterations:U32,reservations:List<&2,W.Reservation<T.MotionSchema>>,observed:F.World() & Doc.Doc) -> Prepared:
  match observed:
    case (world,snapshot):seed_applied(Doc.concat([prefix,Doc.text("seedPending={"),snapshot,Doc.text("}\n")]),iterations,reservations,DW.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure(Unit)"
def seeded(prefix:Doc.Doc,iterations:U32,value:F.Seeded) -> Prepared:
  match value:
    case F.Seeded{world,+reservations,outcome}:seed_pending(Doc.concat([prefix,Doc.text("seedOutcome="),Doc.text(seed_outcome(outcome)),Doc.text(";reservations="),Doc.text(List.show(&2,W.Reservation<T.MotionSchema>,O.reservation,reservations)),Doc.text("\n")]),iterations,reservations,DW.world(world))
def created(+count:U32,+iterations:U32,observed:F.World() & Doc.Doc) -> Prepared:
  match observed:
    case (world,snapshot):seeded(Doc.concat([Doc.text("count="),Doc.text(U32.show(count)),Doc.text(";iterations="),Doc.text(U32.show(iterations)),Doc.text(";created={"),snapshot,Doc.text("}\n")]),iterations,F.seed(count,world))
def prepare(count:U32,iterations:U32,world:F.World()) -> Prepared:created(count,iterations,DW.world(world))
def completed(iterations:U32,value:Prepared) -> Doc.Doc:
  match value:
    case Prepared{prefix,state}:Stream.final(prefix,Program.loops(U32.to_nat(iterations),0,state))
    case PreparationFailed{report}:report
def program(count:U32,+iterations:U32,world:F.World()) -> Doc.Doc:completed(iterations,prepare(count,iterations,world))
