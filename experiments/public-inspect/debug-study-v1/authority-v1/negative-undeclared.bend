import Base
import ../consumer.bend as A
# A gameplay body cannot treat opaque H as the actual Check frame/world.
def wrong(~H:Type,owner:H) -> A.Frame():
  owner
