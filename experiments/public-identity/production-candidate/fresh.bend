import Base

# Host identity allocation is an IO effect, not a mathematical ECS proof.
def fresh() -> IO(U32):
  import "./fresh.c"
  import "./fresh.js"
