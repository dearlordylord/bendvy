import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WIO
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as Machine
import ../../description-v1/state-metadata.bend as State
import ../../description-v1/full-dto-v1/owner-observation.bend as Owner
import ./multi-registered.bend as Application
import ./consumer.bend as Consumer
# Concrete IO endpoint only. The actual namespace is allocated by WIO.create.
# Affine owners reach the terminal result; this endpoint ends their lifetime.
def empty_store(args:Unit) -> Array<U32>:
  ANode{ALeaf{19},ALeaf{23}}
def owner() -> Owner.Owner:
  Owner.Owner{Some{ALeaf{7}},None{},None{},None{},Machine.Missing{},Machine.Present{State.NumberBits{0,1073217536,"1.5"},Machine.Queued{State.NumberBits{0,0,"0"},False{}},Some{State.NumberBits{0,2147483648,"0"}},True{}},7}
def identity(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>:
  world
def configured(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,regs,system,clock}:W.World{ns,next,high,live,capacity,depth,store,resource,[17],[identity,identity],regs,system,41}
def observed(result:Consumer.ObservationResult) -> String:
  match result:
    case Consumer.Complete{world,main,again,text}:text
def scheduled(result:Application.Schedules) -> String:
  match result:
    case Application.Scheduled{world,main,again}:observed(Consumer.observe_complete(world,main,again))
    case other:"schedule-refused"
def registered(result:Application.Prepared) -> String:
  match result:
    case Application.Prepared{world,owners}:scheduled(Application.schedules(world,owners))
    case other:"registration-refused"
def created(result:WIO.Creation<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> String:
  match result:
    case WIO.Created{world}:registered(Application.prepare(configured(world)))
    case WIO.Refused{resource}:"creation-refused"
def main() -> IO(Unit):
  IO.bind(WIO.Creation<Owner.Schema,Array<U32>,Owner.Owner,U32>,Unit,WIO.create(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~empty_store,owner()),value => IO.print(created(value)))
