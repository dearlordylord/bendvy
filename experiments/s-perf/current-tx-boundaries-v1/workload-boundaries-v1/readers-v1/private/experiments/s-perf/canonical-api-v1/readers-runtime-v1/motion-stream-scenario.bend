import metric-collect.bend as Collect
import metric-output.bend as MetricOut
import ../../../../../profile.bend as Profile
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/commands.bend as Cmd
import Base
import motion-report-doc.bend as Doc
import motion-doc-world.bend as DocWorld
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-domain.bend as D
import motion-systems.bend as S
import motion-registration.bend as Registration
import motion-program.bend as Program
import motion-render.bend as Render
import motion-observe.bend as O
import motion-reader-observe.bend as RO
import motion-scenario.bend as Original
import motion-stream.bend as Stream
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/transaction.bend as Tx

type Prepared is Data:
  Ready{prefix:Doc.Doc,view:Stream.StateView,logical:String,after:Doc.Doc,samples:List<&2,Profile.Sample>}
  Stopped{text:Doc.Doc,samples:List<&2,Profile.Sample>}
def with_samples(samples:List<&2,Profile.Sample>,value:Prepared) -> Prepared:
  match value:
    case Ready{prefix,view,logical,after,old}:Ready{prefix,view,logical,after,List.append(&2,Profile.Sample,samples,old)}
    case Stopped{text,old}:Stopped{text,List.append(&2,Profile.Sample,samples,old)}
def after_logical(prefix:Doc.Doc,view:Stream.StateView,rows:String,observed:F.World() & Doc.Doc) -> Prepared:
  match observed:
    case (_,text):Ready{prefix,view,rows,text,[]}
def logical(prefix:Doc.Doc,view:Stream.StateView,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,rows):after_logical(prefix,view,rows,DocWorld.world(world))
def measured_final(prefix:Doc.Doc,view:Stream.StateView,observed:Program.State & List<&2,Profile.Sample>) -> Prepared:
  match observed:
    case (state,samples):with_samples(samples,logical(prefix,view,O.rows(Program.finish_world(state))))
def final_state(prefix:Doc.Doc,observed:Program.State & Stream.StateView) -> Prepared:
  match observed:
    case (state,view):measured_final(prefix,view,Program.inspect(~List<&2,Profile.Sample>,~Collect.view,state))
def initial_state(prefix:Doc.Doc,iterations:U32,observed:Program.State & String) -> Prepared:
  match observed:
    case (state,text):final_state(Doc.join(prefix,Doc.text("seededRegistered={" ++ text ++ "}
")),Stream.state(Program.drain(Program.loops(U32.to_nat(iterations),Program.phase(1,Program.prime(state))))))
def initial_named(prefix:Doc.Doc,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,namespace):initial_state(prefix,iterations,Render.state(Program.start(world,owners,namespace)))
def seed_applied(prefix:Doc.Doc,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):initial_named(Doc.join(prefix,Doc.text("seedApplied={" ++ text ++ "}
")),iterations,owners,W.namespace(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
def seed_pending(prefix:Doc.Doc,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):seed_applied(Doc.join(prefix,Doc.text("seedPending={" ++ text ++ "}
")),iterations,owners,O.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_finished(prefix:Doc.Doc,iterations:U32,owners:S.Owners,result:D.Frame & Tx.Returned<F.World(),Unit>) -> Prepared:
  match result:
    case (+frame,Tx.Returned{world,outcome,_}):with_samples(Collect.seed(frame),seed_pending(Doc.concat([prefix,Doc.text("seedOutcome=" ++ O.outcome(outcome) ++ ";seedFrame={"),Render.doc_frame(frame),Doc.text("}
")]),iterations,owners,O.world(world)))
def seed_reserved(prefix:Doc.Doc,count:U32,iterations:U32,owners:S.Owners,result:F.Reserved) -> Prepared:
  match result:
    case F.Reserved{tx,reservations}:seed_finished(prefix,iterations,owners,D.finish(3,D.Frame{count,0,None{},reservations,[]},Tx.Success{},tx))
def seed_registered(prefix:Doc.Doc,+count:U32,iterations:U32,observed:Program.View & String) -> Prepared:
  match observed:
    case (Program.View{world,owners,_,_,_},text):seed_reserved(Doc.join(prefix,Doc.text("registered={" ++ text ++ "}
")),count,iterations,owners,F.seed_rows(U32.to_nat(count),0,F.Reserved{Cmd.tx_begin(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world),[]}))
def registered_named(prefix:Doc.Doc,count:U32,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,namespace):seed_registered(prefix,count,iterations,Render.view(Program.View{world,owners,namespace,[],Program.Complete{}}))
def registered(prefix:Doc.Doc,count:U32,iterations:U32,result:Registration.Returned) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:registered_named(prefix,count,iterations,owners,W.namespace(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Registration.LocalRejected{world,owners}:Stopped{Doc.join(prefix,Doc.text(Original.local_rejected(world,owners))),[]}
    case Registration.FastRejected{spawn,update,dispose,result}:Stopped{Doc.join(prefix,Doc.text(Original.reader_registration_rejected("FastRegistrationRejected",Render.local(spawn),Render.local(update),Render.local(dispose),"unregistered",result))),[]}
    case Registration.SlowRejected{spawn,update,dispose,fast,result}:Stopped{Doc.join(prefix,Doc.text(Original.slow_registration_rejected(Render.local(spawn),Render.local(update),Render.local(dispose),RO.provider(fast),result))),[]}
def program(+count:U32,+iterations:U32,world:F.World()) -> Prepared:registered(Doc.text("ReadersRuntime Motion
count=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ "
"),count,iterations,Registration.run(world,count))
def write_original(value:Prepared) -> IO(Unit):
  match value:
    case Stopped{text,_}:Doc.write(Doc.join(text,Doc.text("
")))
    case Ready{prefix,view,logical,after,_}:IO.bind(Unit,Unit,Doc.write(Doc.join(prefix,Doc.text("final={"))),_=>IO.bind(Unit,Unit,Stream.write_state(view),_=>IO.bind(Unit,Unit,IO.write("};finalLogicalRows=" ++ logical),_=>Doc.write(Doc.concat([Doc.text(";afterLogicalWorld={"),after,Doc.text("}

")])))))

def samples(value:Prepared) -> List<&2,Profile.Sample>:
  match value:
    case Ready{_,_,_,_,values}:values
    case Stopped{_,values}:values
def write(path:String,value:Prepared) -> IO(Unit):
  match value:
    case Ready{prefix,view,logical,after,values}:IO.bind(Unit,Unit,write_original(Ready{prefix,view,logical,after,[]}),_=>MetricOut.write(path,values))
    case Stopped{text,values}:IO.bind(Unit,Unit,write_original(Stopped{text,[]}),_=>MetricOut.write(path,values))
