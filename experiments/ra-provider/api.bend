import Base

type MotionToken is Data:
  Position{}
type OtherToken is Data:
  OtherPosition{}
type PositionCell is Type:
  PositionCell{x: U32}
type VelocityCell is Type:
  VelocityCell{v: U32}
type Motion is Type:
  Motion{p: PositionCell, v: VelocityCell}

# Concrete provisioning paths are public, but cannot consume abstract handles.
def position_read(p: PositionCell, token: MotionToken) -> PositionCell & U32:
  match p token:
    case PositionCell{+x} Position{}: (PositionCell{x}, x)
def position_write(p: PositionCell, token: MotionToken, x: U32) -> PositionCell:
  match p token:
    case PositionCell{_} Position{}: PositionCell{x}
def velocity_read(v: VelocityCell) -> VelocityCell & U32:
  match v:
    case VelocityCell{+x}: (VelocityCell{x}, x)
def restore(result: PositionCell & VelocityCell) -> Motion:
  match result:
    case (p, v): Motion{p, v}

# Rank-2 callback: every application must check for arbitrary P and V.
def step(~system: @-P: Type -> @-V: Type -> (P -> MotionToken -> P & U32) -> (P -> MotionToken -> U32 -> P) -> (V -> V & U32) -> P -> V -> P & V, world: Motion) -> Motion:
  match world:
    case Motion{p, v}:
      restore(system(PositionCell, VelocityCell, position_read, position_write, velocity_read, p, v))
def observe(world: Motion) -> Motion & U32:
  match world:
    case Motion{PositionCell{+x}, v}: (Motion{PositionCell{x}, v}, x)

def restore_read(result: PositionCell & U32, v: VelocityCell) -> Motion:
  match result:
    case (p, _): Motion{p, v}
def readonly(~system: @-P: Type -> (P -> MotionToken -> P & U32) -> P -> P & U32, world: Motion) -> Motion:
  match world:
    case Motion{p, v}: restore_read(system(PositionCell, position_read, p), v)
