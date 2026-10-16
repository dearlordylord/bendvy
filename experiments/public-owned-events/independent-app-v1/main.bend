import Base
import ./app.bend as App
import ./model.bend as M
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/owned-event-storage.bend as Store

def observed(result:WI.Creation<M.Schema,Unit,Store.Resources<Array<U32>,M.Manifest>,Nat>) -> String:
  match result:
    case WI.Created{world}: App.created(world)
    case WI.Refused{resource}: "fatal:world-creation"
def main() -> IO(Unit):
  do IO<Unit>:
    result : WI.Creation<M.Schema,Unit,Store.Resources<Array<U32>,M.Manifest>,Nat> <- WI.create(~M.Schema,~Unit,~Store.Resources<Array<U32>,M.Manifest>,~Nat,~M.empty,Store.Resources{M.array(901),Log.empty(~M.Manifest)})
    IO.print(observed(result))
