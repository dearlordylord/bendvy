import Base
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/owned-recovery-v1/staging.bend as Stage

type Invocation<-World:Type,-Payload:Type> is Type:
  Invocation{tx:T.Tx<World,Unit>,staged:Stage.Stage<Payload>}
type Returned<-World:Type,-Payload:Type,-Error:Data> is Type:
  Returned{world:World,outcome:T.Outcome<Error>,recovered:List<Payload>}
def committed(~World:Type,~Payload:Type,~Error:Data,~publish:World -> List<Payload> -> World,world:World,receipt:Stage.Committed<Payload>) -> Returned<World,Payload,Error>:
  match receipt:
    case Stage.Committed{owners}: Returned{publish(world,owners),T.Success{},[]}
def aborted(~World:Type,~Payload:Type,~Error:Data,world:World,error:Error,receipt:Stage.Aborted<Payload>) -> Returned<World,Payload,Error>:
  match receipt:
    case Stage.Aborted{owners}: Returned{world,T.Failure{error},List.tail(&1,Payload,owners)}
def finished(~World:Type,~Payload:Type,~Error:Data,~publish:World -> List<Payload> -> World,staged:Stage.Stage<Payload>,result:T.Returned<World,Error>) -> Returned<World,Payload,Error>:
  match result:
    case T.Returned{world,T.Success{}}: committed(~World,~Payload,~Error,~publish,world,Stage.commit(~Payload,staged))
    case T.Returned{world,T.Failure{error}}: aborted(~World,~Payload,~Error,world,error,Stage.abort(~Payload,staged))
def finish(~World:Type,~Payload:Type,~Error:Data,~enqueue:World -> List<(World -> World)> -> World,~publish_data:World -> List<&2,Unit> -> World,~publish_owned:World -> List<Payload> -> World,invocation:Invocation<World,Payload>,outcome:T.Outcome<Error>) -> Returned<World,Payload,Error>:
  match invocation:
    case Invocation{tx,staged}: finished(~World,~Payload,~Error,~publish_owned,staged,T.finish(~World,~Unit,~Error,~enqueue,~publish_data,tx,outcome))
