import Base
import ../consumer/motion-domain.bend as D
import ../consumer/motion-observation.bend as Observation
import ../consumer/motion-registration.bend as Registration
import ../consumer/motion-program.bend as Program
import ../../../consumer/dense-runtime-v1/motion.bend as F
import ../../../consumer/dense-runtime-v1/types.bend as T
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/commands.bend as Cmd
import ../../../../../../src/ecs/transaction.bend as Tx

type Prepared is Type:
  Ready{iterations:U32,state:Program.State,seed:List<&2,W.Reservation<T.MotionSchema>>}
  Stopped{}
def registered(seed:List<&2,W.Reservation<T.MotionSchema>>,iterations:U32,foreign:D.World(),result:Registration.Registration) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:Ready{iterations,Program.initial(world,foreign,owners),seed}
    case Registration.Stopped{_,_}:Stopped{}
def foreign_checked(seed:List<&2,W.Reservation<T.MotionSchema>>,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.MotionSchema>,observed:D.World() & U32) -> Prepared:
  match observed:
    case (other,2):registered(seed,iterations,other,Registration.run(world,count,foreign))
    case _:Stopped{}
def foreign_applied(seed:List<&2,W.Reservation<T.MotionSchema>>,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.MotionSchema>,other:D.World()) -> Prepared:
  match reservation:
    case W.Reserved{+foreign}:foreign_checked(seed,count,iterations,world,foreign,Observation.lookup(other,Some{foreign}))
    case _:Stopped{}
def foreign_finished(seed:List<&2,W.Reservation<T.MotionSchema>>,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.MotionSchema>,result:Tx.Returned<D.World(),Unit>) -> Prepared:
  match result:
    case Tx.Returned{other,_}:foreign_applied(seed,count,iterations,world,reservation,W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,other))
def foreign_reserved(seed:List<&2,W.Reservation<T.MotionSchema>>,count:U32,iterations:U32,world:D.World(),result:Tx.Tx<D.World(),Nat> & W.Reservation<T.MotionSchema>) -> Prepared:
  match result:
    case (tx,reservation):foreign_finished(seed,count,iterations,world,reservation,Cmd.tx_finish(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Unit,tx,Tx.Success{}))
def foreign_seed(seed:List<&2,W.Reservation<T.MotionSchema>>,count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:foreign_reserved(seed,count,iterations,world,Cmd.tx_spawn(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~T.Position,~D.populate,Tx.begin(~D.World(),~Nat,foreign),T.Position{F.quad(999,1000,1001,1002),7}))
def main_seeded(+count:U32,iterations:U32,foreign:D.World(),result:F.Seeded) -> Prepared:
  match result:
    case F.Seeded{world,seed,_}:foreign_seed(seed,count,iterations,W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,world),foreign)
def program(+count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:main_seeded(count,iterations,foreign,F.seed(count,world))
