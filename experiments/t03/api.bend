import Base

# Experimental explicit schemas. Storage is affine; payloads are Data.
type Motion is Type:
  MotionStore{x: U32, velocity: U32}
type Health is Type:
  HealthStore{hp: U32, damage: U32, armor: U32}
type MotionToken is Data:
  Position{}
type HealthToken is Data:
  HitPoints{}
type ReadMotion is Type:
  MotionRead{x: U32}
type WriteMotion is Type:
  MotionWrite{x: U32}
type ReadHealth is Type:
  HealthRead{hp: U32}
type WriteHealth is Type:
  HealthWrite{hp: U32}

def read(c: ReadMotion, token: MotionToken) -> U32:
  match c token:
    case MotionRead{x} Position{}: x

def write(c: WriteMotion, token: MotionToken, x: U32) -> WriteMotion:
  match c token:
    case MotionWrite{_} Position{}: MotionWrite{x}

def motion_return(c: WriteMotion, v: U32) -> Motion:
  match c:
    case MotionWrite{x}: MotionStore{x, v}

def health_return(c: WriteHealth, d: U32, a: U32) -> Health:
  match c:
    case HealthWrite{hp}: HealthStore{hp, d, a}

# Closed templates repeat without duplicating an affine closure.
def motion(~system: U32 -> WriteMotion -> WriteMotion, world: Motion) -> Motion:
  match world:
    case MotionStore{x, +v}:
      motion_return(system(v, MotionWrite{x}), v)

def health(~system: U32 -> WriteHealth -> WriteHealth, world: Health) -> Health:
  match world:
    case HealthStore{hp, +damage, armor}:
      health_return(system(damage, HealthWrite{hp}), damage, armor)

def move(v: U32, c: WriteMotion) -> WriteMotion:
  match c:
    case MotionWrite{x}: MotionWrite{(x + v : U32)}

def hurt(d: U32, c: WriteHealth) -> WriteHealth:
  match c:
    case HealthWrite{hp}: HealthWrite{(hp - d : U32)}

def show_motion(world: Motion) -> String:
  match world:
    case MotionStore{x, v}: U32.show(x) ++ "," ++ U32.show(v)

def show_health(world: Health) -> String:
  match world:
    case HealthStore{hp, d, a}: U32.show(hp) ++ "," ++ U32.show(d) ++ "," ++ U32.show(a)
