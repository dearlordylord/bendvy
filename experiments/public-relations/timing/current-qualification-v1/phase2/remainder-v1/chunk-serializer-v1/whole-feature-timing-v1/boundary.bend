import Base
# Harness-only whole-feature clock, no ECS/public contract change.
def begin() -> IO(Unit):
  import "./boundary.c"
  import "./boundary.js"
def complete(nodes:U32,characters:U32,sum:U32) -> IO(Unit):
  import "./boundary.c"
  import "./boundary.js"
