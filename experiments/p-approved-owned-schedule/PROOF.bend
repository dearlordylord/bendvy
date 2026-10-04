import Base
import ./LAWS.bend as L
import ./endpoint.bend as E
import ./capture.bend as C

# ---- owned_runtime_schedule_correspondence ----
def L.owned_runtime_schedule_correspondence(limit,world,steps):
  E.captured(limit,world,steps,C.capture_world(world))
