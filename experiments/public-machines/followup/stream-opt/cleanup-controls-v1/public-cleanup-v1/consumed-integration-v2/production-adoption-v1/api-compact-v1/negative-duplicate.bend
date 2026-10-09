import Base
import positive.bend as P
import system-instance.bend as Managed

def duplicate(instance:Managed.Instance<P.SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,P.body(~P.SchemaA),P.Ports,P.validate,P.remove(~P.SchemaA)>) -> Managed.Instance<P.SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,P.body(~P.SchemaA),P.Ports,P.validate,P.remove(~P.SchemaA)> & Managed.Instance<P.SchemaA,Unit,Unit,Unit,Unit,Unit,Unit,P.body(~P.SchemaA),P.Ports,P.validate,P.remove(~P.SchemaA)>:
  (instance,instance)
def main() -> Unit:
  Unit{}
