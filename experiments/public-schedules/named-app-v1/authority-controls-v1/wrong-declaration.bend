import Base
import ./common.bend as C
import ../../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
# Same schema and U32 payload; a different declared key is not this owner.
def wrong(owner:C.Owner(~C.Workshop)) -> C.Owner(~C.Workshop) & Fields.Fields<C.Workshop>:
  LF.fields(~C.Workshop,~C.Cell,~C.Cell,~Unit,~C.Cell,~C.Cell,~String,~C.Cell,~C.Ops,~C.declaration(~C.Workshop,"Other"),~C.body,owner)
