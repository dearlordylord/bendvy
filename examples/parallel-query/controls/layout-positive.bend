import Base
import ./layout-case.bend as Case
import ../payloads.bend as Payload
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-composer-layout.bend as Layout
def positive() -> D.Compilation<Case.Schema,Case.Store(),Case.Store(),Unit,Query.Ops(~Case.Schema,~String)>:
  Case.compiled(~Case.actual(),~Layout.AtLeaf{},~{==},~{==},~{==},~Case.body)
