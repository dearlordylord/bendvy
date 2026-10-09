import Base
import ../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type Schema is Data:Schema{}
type Other is Data:Other{}
def bad(-H:Type,cap:Unit,args:Public.Args<Schema>,ctx:H) -> H & Public.Output<Schema>:
  match cap:
    case Cap.OwnedRequest{run}:run(ctx,args)
