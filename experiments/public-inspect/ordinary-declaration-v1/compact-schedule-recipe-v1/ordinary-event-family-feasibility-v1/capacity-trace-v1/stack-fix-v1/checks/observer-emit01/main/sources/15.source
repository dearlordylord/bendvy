import Base

# Engine-owned transaction state; gameplay receives abstract providers instead.
# The journal owns replacement values inside affine inverse closures.
type Tx<W: Type, E: Data> is Type:
  Tx{world: W, undo: List<&1, (W -> W)>, commands: List<&1, (W -> W)>, events: List<&2, E>}

type Outcome<Error: Data> is Data:
  Success{}
  Failure{error: Error}

type Returned<W: Type, Error: Data> is Type:
  Returned{world: W, outcome: Outcome<Error>}

def begin(~W: Type, ~E: Data, world: W) -> Tx<W, E>:
  Tx{world, [], [], []}

def add_undo(~W: Type, ~E: Data, tx: Tx<W, E>, inverse: W -> W) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events}:
      Tx{world, inverse <> undo, commands, events}

# Commands and events are accumulated in reverse and reversed once at commit.
def stage(~W: Type, ~E: Data, tx: Tx<W, E>, command: W -> W) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events}:
      Tx{world, undo, command <> commands, events}

def emit(~W: Type, ~E: Data, tx: Tx<W, E>, event: E) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events}:
      Tx{world, undo, commands, event <> events}

def rollback(~W: Type, undo: List<&1, (W -> W)>, world: W) -> W:
  match undo:
    case Nil{}:
      world
    case Con{inverse, rest}:
      rollback(~W, rest, inverse(world))

def finish_world(~W: Type, ~E: Data, ~Error: Data,
  ~enqueue: W -> List<&1, (W -> W)> -> W,
  ~publish: W -> List<&2, E> -> W,
  world: W, undo: List<&1, (W -> W)>, commands: List<&1, (W -> W)>, events: List<&2, E>, outcome: Outcome<Error>
) -> Returned<W, Error>:
  match outcome:
    case Success{}:
      committed = enqueue(world, List.reverse(&1, (W -> W), commands))
      Returned{publish(committed, List.reverse(&2, E, events)), Success{}}
    case Failure{error}:
      Returned{rollback(~W, undo, world), Failure{error}}

def finish(~W: Type, ~E: Data, ~Error: Data,
  ~enqueue: W -> List<&1, (W -> W)> -> W,
  ~publish: W -> List<&2, E> -> W,
  tx: Tx<W, E>, outcome: Outcome<Error>
) -> Returned<W, Error>:
  match tx:
    case Tx{world, undo, commands, events}:
      finish_world(~W, ~E, ~Error, ~enqueue, ~publish, world, undo, commands, events, outcome)
