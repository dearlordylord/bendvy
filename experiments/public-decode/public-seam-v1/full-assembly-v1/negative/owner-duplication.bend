import Base
import ../public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type Schema is Data:Schema{}
type Other is Data:Other{}
def duplicated(-H:Type,result:H & Public.Output<Schema>,args:Public.Args<Schema>) -> H & (Public.Output<Schema> & Public.Args<Schema>):
  match result:
    case (ctx,output):(ctx,(output,args))
def bad(-H:Type,cap:Cap.OwnedRequest<H,Public.Args<Schema>,Public.Output<Schema>>,args:Public.Args<Schema>,ctx:H) -> H & (Public.Output<Schema> & Public.Args<Schema>):
  match cap:
    case Cap.OwnedRequest{run}:duplicated(H,run(ctx,args),args)
