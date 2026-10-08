import Base
import ./legacy-fixture.bend as F
import ../../../../../../src/ecs/declared-family.bend as Family
import ../../../../../../src/ecs/schema-fragments.bend as SF
def identity(owner:Unit) -> Unit:
  owner
def required() -> SF.Entry<F.Workshop>:
  SF.entry(~F.Workshop,~F.Workshop,~F.Payload,Family.descriptor(~F.Workshop,~F.Payload,~F.Workshop,~F.declaration(~F.Workshop)))
def observe(result:SF.Bound<F.Workshop,Unit,Unit>) -> Bool:
  match result:
    case SF.BindRejected{SF.UndeclaredDescriptor{SF.Component{},key,name},_}:Bool.and(String.eq(key,"Payload"),String.eq(name,"Payload"))
    case _:False{}
def main() -> Bool:
  observe(SF.bind_declared(~F.Workshop,~Unit,~Unit,~identity,SF.empty(~F.Workshop,Unit{}),[required()]))
