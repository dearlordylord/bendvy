import Base
# Host effects are harness-only. Begin returns before any authored application
# invocation. Capture materializes and hashes complete UTF-8 output in-region.
# End stops time before flushing retained output. No ECS owner crosses this seam.
def begin() -> IO(Unit):
  import "./timing.c"
  import "./timing.js"
def capture(text:String) -> IO(Unit):
  import "./timing.c"
  import "./timing.js"
def end() -> IO(Unit):
  import "./timing.c"
  import "./timing.js"
