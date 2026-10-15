import Base
import ./common.bend as C
import ../../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
# An actual Workshop owner cannot be supplied to a Garden projection.
def wrong(owner:C.Owner(~C.Workshop)) -> C.Owner(~C.Garden) & Fields.Fields<C.Garden>:
  LF.fields(~C.Garden,~C.Cell,~C.Cell,~Unit,~C.Cell,~C.Cell,~String,~C.Cell,~C.Ops,~C.declaration(~C.Garden,"Counter"),~C.body,owner)
