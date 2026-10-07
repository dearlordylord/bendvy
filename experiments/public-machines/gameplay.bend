import Base
import machine.bend as M
import provider.bend as P
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/transaction.bend as Tx

type Operation is Data:
  Seed{}
  Queue{}
  OldPending{}
  FailingPublisher{error: String}
  Reset{}
  MarkerQueues{}
  SameSet{}
  SameSkip{}
  OverwriteSkip{}
  PauseRequest{}
  PlayRequest{}
  Noop{}

type SpawnPayload is Type:
  Empty{}
  SeedCells{owner: Array<U32>}

type HookOperation is Data:
  FlowEnter{}
  LevelEnter{}
type HookWork<S: Data,-H: Type> is Type:
  HookWork{flow: Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,level: Cap.ValueWrite<H,M.QueueInput<P.Level>,M.NextView<S,P.LevelToken,P.Level>>}

def hook_flow(~S: Data,~H: Type,caps: HookWork<S,H>) -> Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>:
  match caps:
    case HookWork{cap,_}: cap
def hook_level(~S: Data,~H: Type,caps: HookWork<S,H>) -> Cap.ValueWrite<H,M.QueueInput<P.Level>,M.NextView<S,P.LevelToken,P.Level>>:
  match caps:
    case HookWork{_,cap}: cap

# Transition hooks are actual opaque gameplay bodies, with only their declared
# next-machine capabilities. Registry owners remain in the engine catalog.
def hook_body(~S: Data,~H: Type,~caps: HookWork<S,H>,operation: HookOperation,ctx: H) -> H & Tx.Outcome<String>:
  match operation:
    case FlowEnter{}:
      ctx=Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~hook_flow(~S,~H,caps),ctx,M.Set{P.Boot{},False{}})
      (Cap.value_set(~H,~M.QueueInput<P.Level>,~M.NextView<S,P.LevelToken,P.Level>,~hook_level(~S,~H,caps),ctx,M.Set{P.High{},False{}}),Tx.Success{})
    case LevelEnter{}:
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~hook_flow(~S,~H,caps),ctx,M.Set{P.Boot{},False{}}),Tx.Success{})

type Work<S: Data,-H: Type> is Type:
  Work{readFlow: Cap.ValueRead<H,M.CurrentView<S,P.FlowToken,P.Flow>>,flow: Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,alias: Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,level: Cap.ValueWrite<H,M.QueueInput<P.Level>,M.NextView<S,P.LevelToken,P.Level>>,cells: Cap.Send<H,Array<U32>>,owned: Cap.Send<H,Array<U32>>,spawn: Cap.Send<H,SpawnPayload>}

def read_flow(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueRead<H,M.CurrentView<S,P.FlowToken,P.Flow>>:
  match caps:
    case Work{cap,_,_,_,_,_,_}: cap
def flow(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>:
  match caps:
    case Work{_,cap,_,_,_,_,_}: cap
def alias(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>:
  match caps:
    case Work{_,_,cap,_,_,_,_}: cap
def level(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.ValueWrite<H,M.QueueInput<P.Level>,M.NextView<S,P.LevelToken,P.Level>>:
  match caps:
    case Work{_,_,_,cap,_,_,_}: cap
def cells(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.Send<H,Array<U32>>:
  match caps:
    case Work{_,_,_,_,cap,_,_}: cap
def owned(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.Send<H,Array<U32>>:
  match caps:
    case Work{_,_,_,_,_,cap,_}: cap
def spawn(~S: Data,~H: Type,caps: Work<S,H>) -> Cap.Send<H,SpawnPayload>:
  match caps:
    case Work{_,_,_,_,_,_,cap}: cap

def queue_observed(~S: Data,~H: Type,~spawn: Cap.Send<H,SpawnPayload>,current: M.CurrentView<S,P.FlowToken,P.Flow>,pair: H & M.NextView<S,P.FlowToken,P.Flow>) -> H & Tx.Outcome<String>:
  match current pair:
    case M.Current{P.Boot{}}, (ctx,M.Next{P.Pause{}}):
      (Cap.send(~H,~SpawnPayload,~spawn,ctx,Empty{}),Tx.Success{})
    case _, (ctx,_): (ctx,Tx.Failure{"AliasObservationMismatch"})
def queue_current(~S: Data,~H: Type,~next: Cap.ValueWrite<H,M.QueueInput<P.Flow>,M.NextView<S,P.FlowToken,P.Flow>>,~spawn: Cap.Send<H,SpawnPayload>,pair: H & M.CurrentView<S,P.FlowToken,P.Flow>) -> H & Tx.Outcome<String>:
  (ctx,current)=pair
  queue_observed(~S,~H,~spawn,current,Cap.value_get(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~next,ctx))

def reset_observed(~S: Data,~H: Type,pair: H & M.NextView<S,P.FlowToken,P.Flow>) -> H & Tx.Outcome<String>:
  match pair:
    case (ctx,M.NoNext{}): (ctx,Tx.Success{})
    case (ctx,_): (ctx,Tx.Failure{"ResetObservationMismatch"})

# H is opaque at the gameplay boundary. Repeated closed capability aliases do
# not own separate component/machine stores: each operation returns the same H.
def body(~S: Data,~H: Type,~caps: Work<S,H>,operation: Operation,ctx: H) -> H & Tx.Outcome<String>:
  match operation:
    case Seed{}:
      (Cap.send(~H,~SpawnPayload,~spawn(~S,~H,caps),ctx,SeedCells{ANode{ALeaf{10},ALeaf{99}}}),Tx.Success{})
    case Queue{}:
      ctx=Cap.value_set(~H,~M.QueueInput<P.Level>,~M.NextView<S,P.LevelToken,P.Level>,~level(~S,~H,caps),ctx,M.Set{P.Middle{},False{}})
      ctx=Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Play{},False{}})
      ctx=Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~alias(~S,~H,caps),ctx,M.Set{P.Pause{},False{}})
      queue_current(~S,~H,~alias(~S,~H,caps),~spawn(~S,~H,caps),Cap.value_read(~H,~M.CurrentView<S,P.FlowToken,P.Flow>,~read_flow(~S,~H,caps),ctx))
    case OldPending{}:
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Boot{},False{}}),Tx.Success{})
    case FailingPublisher{error}:
      ctx=Cap.send(~H,~Array<U32>,~cells(~S,~H,caps),ctx,ANode{ALeaf{88},ALeaf{188}})
      ctx=Cap.send(~H,~Array<U32>,~owned(~S,~H,caps),ctx,ANode{ALeaf{77},ALeaf{177}})
      ctx=Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Play{},False{}})
      ctx=Cap.value_set(~H,~M.QueueInput<P.Level>,~M.NextView<S,P.LevelToken,P.Level>,~level(~S,~H,caps),ctx,M.Set{P.High{},False{}})
      (Cap.send(~H,~SpawnPayload,~spawn(~S,~H,caps),ctx,Empty{}),Tx.Failure{error})
    case Reset{}:
      ctx=Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Play{},False{}})
      reset_observed(~S,~H,Cap.value_get(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~alias(~S,~H,caps),Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~alias(~S,~H,caps),ctx,M.Reset{})))
    case MarkerQueues{}:
      ctx=Cap.value_set(~H,~M.QueueInput<P.Level>,~M.NextView<S,P.LevelToken,P.Level>,~level(~S,~H,caps),ctx,M.Set{P.Middle{},False{}})
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Pause{},False{}}),Tx.Success{})
    case SameSet{}:
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Pause{},False{}}),Tx.Success{})
    case SameSkip{}:
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Pause{},True{}}),Tx.Success{})
    case OverwriteSkip{}:
      ctx=Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Pause{},True{}})
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~alias(~S,~H,caps),ctx,M.Set{P.Pause{},False{}}),Tx.Success{})
    case PauseRequest{}:
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Pause{},False{}}),Tx.Success{})
    case PlayRequest{}:
      (Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<S,P.FlowToken,P.Flow>,~flow(~S,~H,caps),ctx,M.Set{P.Play{},False{}}),Tx.Success{})
    case Noop{}: (ctx,Tx.Success{})
