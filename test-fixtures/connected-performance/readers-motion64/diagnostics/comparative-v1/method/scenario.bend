import Base
import ../consumer/motion-systems.bend as S
import ../consumer/motion-program.bend as P
import ../consumer/motion-registration.bend as Reg
import ../consumer/motion-domain.bend as D
import ../../../consumer/motion.bend as F
import ../../../consumer/types.bend as T
import ../../../consumer/events.bend as E
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/transaction.bend as Tx
import ../../../method/json.bend as J
import values.bend as V

type Prepared is Type:
  Ready{iterations:U32,state:P.State,seed:List<&2,W.Reservation<T.MotionSchema>>,seedOutcome:J.Value}
  Stopped{}
def outcome(value:Tx.Outcome<Unit>) -> J.Value:
  match value:
    case Tx.Success{}:J.object([J.Field{"kind",J.Text{"Success"}}])
    case Tx.Failure{_}:J.object([J.Field{"kind",J.Text{"Failure"}}])
def started(iterations:U32,seed:List<&2,W.Reservation<T.MotionSchema>>,seedOutcome:J.Value,owners:S.Owners,result:F.World() & U32) -> Prepared:
  match result:
    case (world,namespace):Ready{iterations,P.phase(1,P.prime(P.start(world,owners,namespace))),seed,seedOutcome}
def seeded(iterations:U32,seed:List<&2,W.Reservation<T.MotionSchema>>,owners:S.Owners,result:D.Frame & Tx.Returned<F.World(),Unit>) -> Prepared:
  match result:
    case (_,Tx.Returned{world,result}):started(iterations,seed,outcome(result),owners,W.namespace(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),world)))
def reserved(iterations:U32,count:U32,owners:S.Owners,value:F.Reserved) -> Prepared:
  match value:
    case F.Reserved{tx,+seed}:seeded(iterations,seed,owners,D.finish(3,D.Frame{count,0,None{},seed},Tx.Success{},tx))
def registered(+count:U32,iterations:U32,result:Reg.Returned) -> Prepared:
  match result:
    case Reg.Ready{world,owners}:reserved(iterations,count,owners,F.seed_rows(U32.to_nat(count),0,F.Reserved{Tx.begin(~F.World(),~E.event_type(),world),[]}))
    case _:Stopped{}
def program(+count:U32,iterations:U32,world:F.World()) -> Prepared:registered(count,iterations,Reg.run(world,count))
