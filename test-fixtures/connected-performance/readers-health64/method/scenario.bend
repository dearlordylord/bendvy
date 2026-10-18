import Base
import ../consumer/health.bend as F
import ../consumer/types.bend as T
import ../consumer/health-events.bend as E
import ../consumer/health-domain.bend as D
import ../consumer/health-systems.bend as S
import ../consumer/health-registration.bend as Registration
import ../consumer/health-program.bend as Program
import ../consumer/health-render.bend as Render
import ../consumer/health-observe.bend as O
import ../consumer/health-reader-observe.bend as RO
import ../consumer/health-scenario.bend as Original
import ../consumer/health-stream.bend as Stream
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as Tx

type Prepared is Type:
  Ready{prefix:String,iterations:U32,state:Program.State,seed:List<&2,W.Reservation<T.HealthSchema>>}
  Stopped{text:String}
def initial_state(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,+iterations:U32,observed:Program.State & String) -> Prepared:
  match observed:
    case (state,text):Ready{prefix ++ "seededRegistered={" ++ text ++ "}\n",iterations,Program.phase(1,Program.prime(state)),seed}
def initial_named(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,namespace):initial_state(seed,prefix,iterations,Render.state(Program.start(world,owners,namespace)))
def seed_applied(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):initial_named(seed,prefix ++ "seedApplied={" ++ text ++ "}
",iterations,owners,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
def seed_pending(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,iterations:U32,owners:S.Owners,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):seed_applied(seed,prefix ++ "seedPending={" ++ text ++ "}
",iterations,owners,O.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def seed_finished(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:String,iterations:U32,owners:S.Owners,result:D.Frame & Tx.Returned<F.World(),Unit>) -> Prepared:
  match result:
    case (frame,Tx.Returned{world,outcome}):seed_pending(seed,prefix ++ "seedOutcome=" ++ O.outcome(outcome) ++ ";seedFrame={" ++ Render.frame(frame) ++ "}
",iterations,owners,O.world(world))
def seed_reserved(prefix:String,count:U32,iterations:U32,owners:S.Owners,result:F.Reserved) -> Prepared:
  match result:
    case F.Reserved{tx,+reservations}:seed_finished(reservations,prefix,iterations,owners,D.finish(3,D.Frame{count,0,None{},reservations,[]},Tx.Success{},tx))
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
