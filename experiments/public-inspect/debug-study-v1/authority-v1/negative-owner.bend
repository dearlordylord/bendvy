import Base
import ../consumer.bend as A
def wrong(world:A.World()) -> A.World() & A.World():
  (world,world)
