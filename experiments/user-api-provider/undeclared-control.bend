import Base
import full-functional.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
type Secret is Type:
  Secret{value: U32}
type SecretToken is Data:
  SecretToken{}
type SecretStore is Type:
  SecretStore{column: Col.Column<F.Game,Secret>}
def secret_take(store: SecretStore) -> Unit & Col.Column<F.Game,Secret>:
  match store:
    case SecretStore{column}: (Unit{},column)
def secret_put(rest: Unit,column: Col.Column<F.Game,Secret>) -> SecretStore:
  SecretStore{column}
def secret_project(owner: Secret) -> Secret & U32:
  match owner:
    case Secret{+value}: (Secret{value},value)
def secret_family() -> C.Family<F.Game,SecretStore,Unit,Secret,U32,SecretToken,secret_take,secret_put,secret_project>:
  C.Family{"secret"}
def bad(~H: Type,~get: H -> H & C.Access<U32>,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,ctx: H) -> H & C.Access<U32>:
  get(ctx)
def secret_world() -> W.World<F.Game,SecretStore,F.Res,F.GameEvent>:
  W.World{1,2,1,Array.new(Bool,1n,True{}),2,1n,SecretStore{Col.Column{ALeaf{Some{Secret{42}}}}},F.Res{0},[],[],[],1}
def observed(result: T.Tx<W.World<F.Game,SecretStore,F.Res,F.GameEvent>,F.GameEvent> & C.Access<U32>) -> U32:
  match result:
    case (_,C.Found{value}): value
    case _: 999
def main() -> U32:
  observed(C.tx_get(~F.Game,~SecretStore,~F.Res,~F.GameEvent,~Unit,~Secret,~U32,~SecretToken,~secret_take,~secret_put,~secret_project,secret_family(),T.begin(~W.World<F.Game,SecretStore,F.Res,F.GameEvent>,~F.GameEvent,secret_world()),W.Handle{1,1}))
