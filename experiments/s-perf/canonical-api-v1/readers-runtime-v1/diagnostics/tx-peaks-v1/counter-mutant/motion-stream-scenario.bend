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
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/transaction.bend as Tx

type Prepared is Data:
  Ready{prefix:Doc.Doc,view:Stream.StateView,logical:String,after:Doc.Doc,seed:List<&2,D.TxFacts>}
  Stopped{text:Doc.Doc}
def seed_facts(frame:D.Frame) -> List<&2,D.TxFacts>:
  match frame:
    case D.Frame{_,_,_,_,facts}:facts
def with_seed(seed:List<&2,D.TxFacts>,value:Prepared) -> Prepared:
  match value:
    case Ready{prefix,view,rows,after,_}:Ready{prefix,view,rows,after,seed}
    case Stopped{text}:Stopped{text}
def after_logical(prefix:Doc.Doc,view:Stream.StateView,rows:String,observed:F.World() & Doc.Doc) -> Prepared:
  match observed:
    case (_,text):Ready{prefix,view,rows,text,[]}
def logical(prefix:Doc.Doc,view:Stream.StateView,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,rows):after_logical(prefix,view,rows,DocWorld.world(world))
def final_state(prefix:Doc.Doc,observed:Program.State & Stream.StateView) -> Prepared:
  match observed:
    case (state,view):logical(prefix,view,O.rows(Program.finish_world(state)))
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
    case (+frame,Tx.Returned{world,outcome}):with_seed(seed_facts(frame),seed_pending(Doc.concat([prefix,Doc.text("seedOutcome=" ++ O.outcome(outcome) ++ ";seedFrame={"),Render.doc_frame(frame),Doc.text("}
")]),iterations,owners,O.world(world)))
def seed_reserved(prefix:Doc.Doc,count:U32,iterations:U32,owners:S.Owners,result:F.Reserved) -> Prepared:
  match result:
    case F.Reserved{tx,reservations}:seed_finished(prefix,iterations,owners,D.finish(3,D.Frame{count,0,None{},reservations,[]},Tx.Success{},tx))
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
def write(value:Prepared) -> IO(Unit):
  match value:
    case Stopped{text}:Doc.write(Doc.join(text,Doc.text("
")))
    case Ready{prefix,view,logical,after,_}:IO.bind(Unit,Unit,Doc.write(Doc.join(prefix,Doc.text("final={"))),_=>IO.bind(Unit,Unit,Stream.write_state(view),_=>IO.bind(Unit,Unit,IO.write("};finalLogicalRows=" ++ logical),_=>Doc.write(Doc.concat([Doc.text(";afterLogicalWorld={"),after,Doc.text("}

")])))))
