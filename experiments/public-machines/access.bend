import Base
import machine.bend as M
import provider.bend as P
import context.bend as Ctx
import observe.bend as O
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/transaction.bend as Tx
import ../../src/ecs/world.bend as W

def is_pair(~S: Data,~K: Data,~V: Data,~H: Type,~same: V -> V -> Bool,value: V,pair: H & M.CurrentView<S,K,V>) -> H & Bool:
  (ctx,view)=pair
  (ctx,M.is_current(~S,~K,~V,~same,view,value))
def current_is(~S: Data,~K: Data,~V: Data,~H: Type,~same: V -> V -> Bool,~read: Cap.ValueRead<H,M.CurrentView<S,K,V>>,ctx: H,value: V) -> H & Bool:
  is_pair(~S,~K,~V,~H,~same,value,Cap.value_read(~H,~M.CurrentView<S,K,V>,~read,ctx))
def pending_pair(~S: Data,~H: Type,wasCurrent: Bool,pair: H & M.NextView<S,P.FlowToken,P.Flow>) -> H & Bool:
  match pair:
    case (ctx,M.Next{P.Play{}}): (ctx,wasCurrent)
    case (ctx,_): (ctx,False{})
def current_pair(~S: Data,~H: Type,~next: Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,pair: H & Bool) -> H & Bool:
  (ctx,wasCurrent)=pair
  pending_pair(~S,~H,wasCurrent,Cap.value_get(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~next,ctx))
def body(~S: Data,~H: Type,~read: Cap.ValueRead<H,M.CurrentView<S,P.FlowToken,P.Flow>>,~next: Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,ctx: H) -> H & Bool:
  ctx=Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~next,ctx,M.Set{P.Play{},False{}})
  current_pair(~S,~H,~next,current_is(~S,~P.FlowToken,~P.Flow,~H,~P.flow_same,~read,ctx,P.Boot{}))
def shown(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & String,passed: Bool) -> String:
  (_,view)=pair
  "passed=" ++ O.bool(passed) ++ "|" ++ view
def checked(~S: Data,pair: Ctx.Frame<S> & Bool) -> String:
  match pair:
    case (Ctx.Frame{Tx.Tx{world,_,_,_},_},passed): shown(~S,O.world(~S,world),passed)
def created(~S: Data,result: W.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> String:
  match result:
    case W.CreateRejected{_,_}: "create-rejected"
    case W.Created{_,world}:
      checked(~S,body(~S,~Ctx.Frame<S>,~Cap.ValueRead{frame => Ctx.flow_current(~S,frame)},~Cap.ValueWrite{frame => Ctx.flow_pending(~S,frame),frame => value => Ctx.flow_next(~S,frame,value)},Ctx.Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,world),None{}}))
def scenario(~S: Data) -> String:
  created(~S,W.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),W.factory(),P.initial_resources(~S)))
def main() -> IO(Unit):
  IO.print("A=" ++ scenario(~P.SchemaA) ++ "\nB=" ++ scenario(~P.SchemaB))
