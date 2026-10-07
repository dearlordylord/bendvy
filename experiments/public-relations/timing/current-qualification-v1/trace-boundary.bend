import Base
# Harness-only completion effect, not a timer or ECS API.
# The host demands all three primitive walk controls before marking completion.
def begin() -> IO(Unit):
  import "./trace-boundary.c"
  import "./trace-boundary.js"
def complete(nodes:U32,characters:U32,sum:U32) -> IO(Unit):
  import "./trace-boundary.c"
  import "./trace-boundary.js"
