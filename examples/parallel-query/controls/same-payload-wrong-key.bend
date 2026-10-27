import Base
import ./layout-case.bend as Case
import ../payloads.bend as Payload
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-composer-layout.bend as Layout
def wrong_key() -> D.Compilation<Case.Schema,Case.Store(),Case.Store(),Unit,Case.Ops>:
  Case.compiled(~Case.wrong_keys(),~Layout.AtLeaf{},~{==},~{==},~{==},~Case.body)
