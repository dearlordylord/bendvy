import Base
import ../consumer-public-pruned.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
type Schema is Data:Schema{}
def read_result(~Owner:Type,result:Owner & M.CurrentView<Schema,T.MachineKey,T.State>) -> Consumer.ordinary_application(~Schema) & String:
  (owner,_)=result
  Consumer.ordinary_marker(~Schema,owner)
def invoke(~Owner:Type,grant:Cap.ValueRead<Owner,M.CurrentView<Schema,T.MachineKey,T.State>>,owner:Owner) -> Consumer.ordinary_application(~Schema) & String:
  read_result(~Owner,Cap.invoke(~Owner,~M.CurrentView<Schema,T.MachineKey,T.State>,grant,owner))
def main() -> Unit:Unit{}
