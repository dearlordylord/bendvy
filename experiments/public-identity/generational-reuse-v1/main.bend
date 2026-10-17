import Base
import fixture.bend as F
import scenario.bend as Scenario
import ../../../src/ecs/world-io.bend as WI

def sender_created(~S:Data,world:F.World(~S),created:WI.Creation<S,F.Store<S>,Array<U32>,F.Notice<S>>) -> IO(Unit):
  match created:
    case WI.Refused{_}:IO.print("sender-creation-refused")
    case WI.Created{sender}:IO.print(Scenario.start(~S,world,F.spawn(~S,sender,700)))
def receiver_created(~S:Data,created:WI.Creation<S,F.Store<S>,Array<U32>,F.Notice<S>>) -> IO(Unit):
  match created:
    case WI.Refused{_}:IO.print("receiver-creation-refused")
    case WI.Created{world}:IO.bind(WI.Creation<S,F.Store<S>,Array<U32>,F.Notice<S>>,Unit,WI.create(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~F.empty(~S),ANode{ALeaf{71},ALeaf{72}}),created=>sender_created(~S,world,created))
def main() -> IO(Unit):
  IO.bind(WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>,Unit,WI.create(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,~F.empty(~F.Workshop),ANode{ALeaf{61},ALeaf{62}}),created=>receiver_created(~F.Workshop,created))
