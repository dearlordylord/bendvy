import Base
import trace-facts.bend as Facts

# Each staged command owns its payload once. Trusted raw callbacks stay opaque.
type Command<W:Type> is Type:
  Raw{apply:W -> W}
  Observed{apply:Facts.State -> W -> W & Facts.State}
def run(~W:Type,command:Command<W>,world:W,trace:Facts.State) -> W & Facts.State:
  match command:
    case Raw{apply}:(apply(world),trace)
    case Observed{apply}:apply(trace,world)
def world_only(~W:Type,result:W & Facts.State) -> W:
  match result:
    case (world,_):world
def run_disabled(~W:Type,command:Command<W>,world:W) -> W:
  world_only(~W,run(~W,command,world,Facts.Off{}))
