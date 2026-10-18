import Base
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-report-doc.bend as Doc
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-doc-world.bend as DocWorld
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion.bend as F
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/types.bend as T
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/events.bend as E
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-domain.bend as D
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-systems.bend as S
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-registration.bend as Registration
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-program.bend as Program
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-render.bend as Render
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-observe.bend as O
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-reader-observe.bend as RO
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-scenario.bend as Original
import /tmp/bendvy-readers-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/motion-stream.bend as Stream
import /tmp/bendvy-readers-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-readers-matched-method/src/ecs/transaction.bend as Tx

type Prepared is Type:
  Ready{prefix:Doc.Doc,iterations:U32,state:Program.State,seed:List<&2,W.Reservation<T.MotionSchema>>}
  Stopped{text:Doc.Doc}
def initial_state(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,+iterations:U32,observed:Program.State & String) -> Prepared:
  match observed:
    case (state,text):Ready{Doc.join(prefix,Doc.text("seededRegistered={" ++ text ++ "}\n")),iterations,Program.phase(1,Program.prime(state)),seed}
def initial_named(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,namespace):initial_state(seed,prefix,iterations,Render.state(Program.start(world,owners,namespace)))
def seed_applied(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):initial_named(seed,Doc.join(prefix,Doc.text("seedApplied={" ++ text ++ "}
")),iterations,owners,W.namespace(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
def seed_pending(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):seed_applied(seed,Doc.join(prefix,Doc.text("seedPending={" ++ text ++ "}
")),iterations,owners,O.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_finished(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Doc.Doc,iterations:U32,owners:S.Owners,result:D.Frame & Tx.Returned<F.World(),Unit>) -> Prepared:
  match result:
    case (frame,Tx.Returned{world,outcome}):seed_pending(seed,Doc.concat([prefix,Doc.text("seedOutcome=" ++ O.outcome(outcome) ++ ";seedFrame={"),Render.doc_frame(frame),Doc.text("}
")]),iterations,owners,O.world(world))
def seed_reserved(prefix:Doc.Doc,count:U32,iterations:U32,owners:S.Owners,result:F.Reserved) -> Prepared:
  match result:
    case F.Reserved{tx,+reservations}:seed_finished(reservations,prefix,iterations,owners,D.finish(3,D.Frame{count,0,None{},reservations,[]},Tx.Success{},tx))
def seed_registered(prefix:Doc.Doc,+count:U32,iterations:U32,observed:Program.View & String) -> Prepared:
  match observed:
    case (Program.View{world,owners,_,_,_},text):seed_reserved(Doc.join(prefix,Doc.text("registered={" ++ text ++ "}
")),count,iterations,owners,F.seed_rows(U32.to_nat(count),0,F.Reserved{Tx.begin(~F.World(),~E.event_type(),world),[]}))
def registered_named(prefix:Doc.Doc,count:U32,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,namespace):seed_registered(prefix,count,iterations,Render.view(Program.View{world,owners,namespace,[],Program.Complete{}}))
def registered(prefix:Doc.Doc,count:U32,iterations:U32,result:Registration.Returned) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:registered_named(prefix,count,iterations,owners,W.namespace(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Registration.LocalRejected{world,owners}:Stopped{Doc.join(prefix,Doc.text(Original.local_rejected(world,owners)))}
    case Registration.FastRejected{spawn,update,dispose,result}:Stopped{Doc.join(prefix,Doc.text(Original.reader_registration_rejected("FastRegistrationRejected",Render.local(spawn),Render.local(update),Render.local(dispose),"unregistered",result)))}
    case Registration.SlowRejected{spawn,update,dispose,fast,result}:Stopped{Doc.join(prefix,Doc.text(Original.slow_registration_rejected(Render.local(spawn),Render.local(update),Render.local(dispose),RO.provider(fast),result)))}
def program(+count:U32,+iterations:U32,world:F.World()) -> Prepared:registered(Doc.text("ReadersRuntime Motion
count=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ "
"),count,iterations,Registration.run(world,count))
