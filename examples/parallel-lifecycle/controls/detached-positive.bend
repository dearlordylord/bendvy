import Base
import ./authority-case.bend as Case
import ../../../src/ecs/execution-parallel-system.bend as Task

def restored(result:Task.Meta<Case.Owner(~Unit)> & Unit) -> Case.Owner(~Unit):
  match result:
    case (meta,local):Task.restored(~Case.Schema,~Unit,~Unit,~Unit,~Unit,~Case.Ops,~Unit,~String,~Unit,~Case.declaration(~Unit),~Case.body,meta,local)
def roundtrip(owner:Case.Owner(~Unit)) -> Case.Owner(~Unit):
  restored(Task.detached(~Case.Schema,~Unit,~Unit,~Unit,~Unit,~Case.Ops,~Unit,~String,~Unit,~Case.declaration(~Unit),~Case.body,owner))
