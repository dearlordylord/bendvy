import Base
import full-provider.bend as P
import full-context.bend as Ctx
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as Tx
import ../../../src/ecs/capabilities.bend as Cap
import ../../public-machines/machine.bend as M

type SeedWork<F:Type> is Type:
  SeedWork{spawn:Cap.Send<F,Array<U32>>}
def send(-F:Type,cap:Cap.Send<F,Array<U32>>,owner:F,value:Array<U32>) -> F:
  match cap:
    case Cap.Send{send}: send(owner,value)
def seeded(-F:Type,caps:SeedWork<F>,owner:F) -> F & Tx.Outcome<String>:
  match caps:
    case SeedWork{spawn}: (send(F,spawn,owner,ANode{ANode{ALeaf{1},ALeaf{10}},ANode{ALeaf{0},ALeaf{0}}}),Tx.Success{})
def seed_runner(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,_:Unit) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  Ctx.finish(~S,seeded(Ctx.Frame<S>,SeedWork{Cap.Send{frame => value => Ctx.spawn_seed(~S,frame,value)}},Ctx.Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,~P.Ping,P.pulse(~S,world)),None{}}))
type QueueWork<S:Data,F:Type> is Type:
  QueueWork{spawn:Cap.Send<F,Array<U32>>,flow:Cap.ValueWrite<F,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,level:Cap.ValueWrite<F,M.QueueInput<P.Level>,M.NextView<S,P.LevelToken,P.Level>>}
def queued(-S:Data,-F:Type,spawn:Cap.Send<F,Array<U32>>,flow:Cap.ValueWrite<F,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,level:Cap.ValueWrite<F,M.QueueInput<P.Level>,M.NextView<S,P.LevelToken,P.Level>>,owner:F) -> F & Tx.Outcome<String>:
  match flow level:
    case Cap.ValueWrite{_,flow}, Cap.ValueWrite{_,level}:
      owner=flow(owner,M.Set{P.Play{},False{}})
      owner=level(owner,M.Set{P.Middle{},False{}})
      (send(F,spawn,owner,ANode{ANode{ALeaf{90},ALeaf{900}},ANode{ALeaf{0},ALeaf{0}}}),Tx.Success{})
def queue_body(-S:Data,-F:Type,caps:QueueWork<S,F>,owner:F) -> F & Tx.Outcome<String>:
  match caps:
    case QueueWork{spawn,flow,level}: queued(S,F,spawn,flow,level,owner)
def queue_runner(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,_:Unit) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  Ctx.finish(~S,queue_body(S,Ctx.Frame<S>,QueueWork{Cap.Send{frame => value => Ctx.spawn_seed(~S,frame,value)},Cap.ValueWrite{frame => Ctx.flow_pending(~S,frame),frame => value => Ctx.flow_next(~S,frame,value)},Cap.ValueWrite{frame => Ctx.level_pending(~S,frame),frame => value => Ctx.level_next(~S,frame,value)}},Ctx.Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,~P.Ping,P.pulse(~S,world)),None{}}))
