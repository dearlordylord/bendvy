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
  C.tx_get(~F.Game,~SecretStore,~F.Res,~F.GameEvent,~Unit,~Secret,~U32,~SecretToken,~secret_take,~secret_put,~secret_project,secret_family(),ctx,W.Handle{1,1})
def main() -> U32:
  0
