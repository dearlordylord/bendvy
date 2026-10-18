import Base
import schema.bend as S
import consumers.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/component.bend as Cmp

type Request is Data:
  Request{op: U32,value: U32,count: U32,second: Maybe<&2,U32>,fail: Bool}
def outcome(fail: Bool) -> T.Outcome<C.Failure>:
  match fail:
    case False{}: T.Success{}
    case True{}: T.Failure{C.Failed{"publisher"}}
def finished(result: T.Returned<S.World(),C.Failure>) -> Sys.Outcome<S.World(),C.Failure,String>:
  match result:
    case T.Returned{world,T.Success{}}: Sys.Succeeded{world,""}
    case T.Returned{world,T.Failure{error}}: Sys.Failed{world,error}
def emit(remaining: Nat,+value: U32,tx: S.Tx()) -> S.Tx():
  match remaining:
    case 0n: tx
    case 1n+rest: emit(rest,value,T.emit(~S.World(),~S.Notice,tx,S.Ping{value}))
def second(value: Maybe<&2,U32>,tx: S.Tx()) -> S.Tx():
  match value:
    case None{}: tx
    case Some{value}: T.emit(~S.World(),~S.Notice,tx,S.Ping{value})
def despawned(result: S.Tx() & W.Status) -> S.Tx():
  (tx,_) = result
  tx
def spawned(result: S.Tx() & W.Reservation<S.Schema>) -> S.Tx():
  (tx,_) = result
  tx
def handle(+namespace: U32,+id: U32) -> W.Handle<S.Schema>:
  W.Handle{namespace,id}
def seed_bundle(+value: U32,+aux: U32) -> S.Bundle:
  S.Bundle{Some{S.stock_payload(value)},None{},Some{S.Queue{aux,S.payload_array([aux,(aux + 1 : U32)]),2n}},Some{S.Enabled{}},None{}}
def run_request(request: Request,+namespace: U32,world: S.World()) -> Sys.Outcome<S.World(),C.Failure,String>:
  match request:
    case Request{1,+value,+count,secondValue,+fail}: finished(Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Failure,S.remove_aux(second(secondValue,emit(U32.to_nat(count),value,T.begin(~S.World(),~S.Notice,world))),handle(namespace,1)),outcome(fail)))
    case Request{2,_,_,_,+fail}: finished(Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Failure,S.remove_aux(S.queue_stock(T.emit(~S.World(),~S.Notice,T.begin(~S.World(),~S.Notice,world),S.Ping{5}),handle(namespace,1),Some{S.stock_owner(S.StockView{50,[50,51,52,53]})}),handle(namespace,1)),outcome(fail)))
    case Request{3,_,_,_,+fail}: finished(Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Failure,despawned(Cmd.tx_despawn_observed(~S.Schema,~S.Store,~Unit,~S.Notice,~S.cleanup,~S.gone,S.remove_stock(T.begin(~S.World(),~S.Notice,world),handle(namespace,1)),handle(namespace,2))),outcome(fail)))
    case Request{4,_,_,_,+fail}: finished(Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Failure,spawned(Cmd.tx_spawn(~S.Schema,~S.Store,~Unit,~S.Notice,~S.Bundle,~S.populate,spawned(Cmd.tx_spawn(~S.Schema,~S.Store,~Unit,~S.Notice,~S.Bundle,~S.populate,T.begin(~S.World(),~S.Notice,world),seed_bundle(10,20))),seed_bundle(30,40))),outcome(fail)))
    case Request{_,_,_,_,_}: Sys.Failed{world,C.Failed{"unknown-operation"}}
def named(request: Request,named: S.World() & U32) -> Sys.Outcome<S.World(),C.Failure,String>:
  (world,+namespace) = named
  run_request(request,namespace,world)
def runner(world: S.World(),request: Request) -> Sys.Outcome<S.World(),C.Failure,String>:
  named(request,W.namespace(~S.Schema,~S.Store,~Unit,~S.Notice,world))
def condition_value(slot: U32,result: S.World() & Cmp.Access<S.Enabled>) -> S.World() & Bool:
  match result:
    case (world,Cmp.Found{_}): (world,True{})
    case (world,_): (world,U32.is_eq(slot,1))
def condition_named(+slot: U32,named: S.World() & U32) -> S.World() & Bool:
  (world,+namespace) = named
  condition_value(slot,S.get_enabled(world,handle(namespace,1)))
def condition(world: S.World(),slot: U32) -> S.World() & Bool:
  condition_named(slot,W.namespace(~S.Schema,~S.Store,~Unit,~S.Notice,world))
def enabled_value(enabled: Bool) -> Maybe<&1,S.Enabled>:
  match enabled:
    case True{}: Some{S.Enabled{}}
    case False{}: None{}
def condition_set_named(enabled: Bool,named: S.World() & U32) -> S.World():
  (world,+namespace) = named
  S.populate_enabled(world,handle(namespace,1),enabled_value(enabled))
def condition_set(world: S.World(),enabled: Bool) -> S.World():
  condition_set_named(enabled,W.namespace(~S.Schema,~S.Store,~Unit,~S.Notice,world))
