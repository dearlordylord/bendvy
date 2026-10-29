import Base
import ../../src/ecs/world.bend as W
import ./ordinary-sparse.bend as Run
import ./ordinary-snapshot.bend as Snapshot

def main() -> IO(Unit):
  IO.bind(Run.SeedRun,Unit,Run.run(W.factory()),result => Snapshot.printed("baseline=",result))
