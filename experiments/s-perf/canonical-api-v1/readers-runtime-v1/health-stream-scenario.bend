import Base
import health.bend as F
import types.bend as T
import health-events.bend as E
import health-domain.bend as D
import health-systems.bend as S
import health-registration.bend as Registration
import health-program.bend as Program
import health-render.bend as Render
import health-observe.bend as O
import health-reader-observe.bend as RO
import health-scenario.bend as Original
import health-stream.bend as Stream
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as Tx

type Prepared is Data:
  Ready{prefix:String,view:Stream.StateView,logical:String,after:String}
  Stopped{text:String}
def after_logical(prefix:String,view:Stream.StateView,rows:String,observed:F.World() & String) -> Prepared:
  match observed:
    case (_,text):Ready{prefix,view,rows,text}
def logical(prefix:String,view:Stream.StateView,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,rows):after_logical(prefix,view,rows,O.world(world))
def final_state(prefix:String,observed:Program.State & Stream.StateView) -> Prepared:
  match observed:
    case (state,view):logical(prefix,view,O.rows(Program.finish_world(state)))
def initial_state(prefix:String,iterations:U32,observed:Program.State & String) -> Prepared:
  match observed:
    case (state,text):final_state(prefix ++ "seededRegistered={" ++ text ++ "}
",Stream.state(Program.drain(Program.loops(U32.to_nat(iterations),Program.phase(1,Program.prime(state))))))
def initial_named(prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,namespace):initial_state(prefix,iterations,Render.state(Program.start(world,owners,namespace)))
def seed_applied(prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):initial_named(prefix ++ "seedApplied={" ++ text ++ "}
",iterations,owners,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
def seed_pending(prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):seed_applied(prefix ++ "seedPending={" ++ text ++ "}
",iterations,owners,O.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_finished(prefix:String,iterations:U32,owners:S.Owners,result:D.Frame & Tx.Returned<F.World(),Unit>) -> Prepared:
  match result:
    case (frame,Tx.Returned{world,outcome}):seed_pending(prefix ++ "seedOutcome=" ++ O.outcome(outcome) ++ ";seedFrame={" ++ Render.frame(frame) ++ "}
",iterations,owners,O.world(world))
def seed_reserved(prefix:String,count:U32,iterations:U32,owners:S.Owners,result:F.Reserved) -> Prepared:
  match result:
    case F.Reserved{tx,reservations}:seed_finished(prefix,iterations,owners,D.finish(3,D.Frame{count,0,None{},reservations,[]},Tx.Success{},tx))
def seed_registered(prefix:String,+count:U32,iterations:U32,observed:Program.View & String) -> Prepared:
  match observed:
    case (Program.View{world,owners,_,_,_},text):seed_reserved(prefix ++ "registered={" ++ text ++ "}
",count,iterations,owners,F.seed_rows(U32.to_nat(count),0,F.Reserved{Tx.begin(~F.World(),~E.event_type(),world),[]}))
def registered_named(prefix:String,count:U32,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,namespace):seed_registered(prefix,count,iterations,Render.view(Program.View{world,owners,namespace,[],Program.Complete{}}))
def registered(prefix:String,count:U32,iterations:U32,result:Registration.Returned) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:registered_named(prefix,count,iterations,owners,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Registration.LocalRejected{world,owners}:Stopped{prefix ++ Original.local_rejected(world,owners)}
    case Registration.FastRejected{spawn,update,dispose,result}:Stopped{prefix ++ Original.reader_registration_rejected("FastRegistrationRejected",Render.local(spawn),Render.local(update),Render.local(dispose),"unregistered",result)}
    case Registration.SlowRejected{spawn,update,dispose,fast,result}:Stopped{prefix ++ Original.slow_registration_rejected(Render.local(spawn),Render.local(update),Render.local(dispose),RO.provider(fast),result)}
def program(+count:U32,+iterations:U32,world:F.World()) -> Prepared:registered("ReadersRuntime Health
count=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ "
",count,iterations,Registration.run(world,count))
def write(value:Prepared) -> IO(Unit):
  match value:
    case Stopped{text}:IO.print(text)
    case Ready{prefix,view,logical,after}:IO.bind(Unit,Unit,IO.write(prefix ++ "final={"),_=>IO.bind(Unit,Unit,Stream.write_state(view),_=>IO.bind(Unit,Unit,IO.write("};finalLogicalRows=" ++ logical),_=>IO.write(";afterLogicalWorld={" ++ after ++ "}

"))))
