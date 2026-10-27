import Base
import ./ordinary-unsupported.bend as C
import ./schema.bend as S
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-state.bend as State

def grants(value:D.Compilation<S.SchemaA,C.WC(),C.LocalStore(),Unit,C.Ops>) -> C.Ops(State.Scope<S.SchemaA,C.LocalStore(),Unit>):
  D.grants(~S.SchemaA,~C.LocalStore(),~Unit,~C.Ops,value)
