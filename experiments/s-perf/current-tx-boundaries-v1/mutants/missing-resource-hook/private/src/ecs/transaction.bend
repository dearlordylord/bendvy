import ../../../meter.bend as Meter
import Base
import deferred-command.bend as Deferred
import trace-facts.bend as TraceFacts

# Engine-owned transaction state; gameplay receives abstract providers instead.
# The journal owns replacement values inside affine inverse closures.
type Tx<W: Type, E: Data> is Type:
  Tx{world: W, undo: List<&1, (W -> W)>, commands:List<&1, Deferred.Command<W>>, events: List<&2, E>,trace:TraceFacts.State,meter:Meter.State}

type Outcome<Error: Data> is Data:
  Success{}
  Failure{error: Error}

type Returned<W: Type, Error: Data> is Type:
  Returned{world: W, outcome: Outcome<Error>}

def begin(~W: Type, ~E: Data, world: W) -> Tx<W, E>:
  Tx{world, [], [], [],TraceFacts.Off{},Meter.empty(Unit{})}

def add_undo(~W: Type, ~E: Data, tx: Tx<W, E>, inverse: W -> W) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events,trace,meter}:
      Tx{world, inverse <> undo, commands, events,trace,Meter.append(meter,"transaction.add_undo",1n,0n,0n)}

# Commands and events are accumulated in reverse and reversed once at commit.
def stage_command(~W:Type,~E:Data,tx:Tx<W,E>,command:Deferred.Command<W>) -> Tx<W,E>:
  match tx:
    case Tx{world,undo,commands,events,trace,meter}:Tx{world,undo,command <> commands,events,trace,Meter.append(meter,"transaction.stage_command",0n,1n,0n)}
def stage(~W: Type, ~E: Data, tx: Tx<W, E>, command: W -> W) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events,trace,meter}:
      Tx{world, undo, Deferred.Raw{command} <> commands, events,trace,Meter.append(meter,"transaction.stage",0n,1n,0n)}

def emit(~W: Type, ~E: Data, tx: Tx<W, E>, event: E) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events,trace,meter}:
      Tx{world, undo, commands, event <> events,trace,Meter.append(meter,"transaction.emit",0n,0n,1n)}

def rollback(~W: Type, undo: List<&1, (W -> W)>, world: W) -> W:
  match undo:
    case Nil{}:
      world
    case Con{inverse, rest}:
      rollback(~W, rest, inverse(world))

def finish_world(~W: Type, ~E: Data, ~Error: Data,
  ~enqueue: W -> List<&1,Deferred.Command<W>> -> W,
  ~publish: W -> List<&2, E> -> W,
  world: W, undo: List<&1, (W -> W)>, commands:List<&1, Deferred.Command<W>>, events: List<&2, E>, outcome: Outcome<Error>
) -> Returned<W, Error>:
  match outcome:
    case Success{}:
      committed = enqueue(world, List.reverse(&1,Deferred.Command<W>,commands))
      Returned{publish(committed, List.reverse(&2, E, events)), Success{}}
    case Failure{error}:
      Returned{rollback(~W, undo, world), Failure{error}}

def finish(~W: Type, ~E: Data, ~Error: Data,
  ~enqueue: W -> List<&1,Deferred.Command<W>> -> W,
  ~publish: W -> List<&2, E> -> W,
  tx: Tx<W, E>, outcome: Outcome<Error>
) -> Returned<W, Error>:
  match tx:
    case Tx{world, undo, commands, events,trace,meter}:
      finish_world(~W, ~E, ~Error, ~enqueue, ~publish, world, undo, commands, events, outcome)

def begin_observed(~W:Type,~E:Data,world:W) -> Tx<W,E>:
  Tx{world,[],[],[],TraceFacts.On{[]},Meter.empty(Unit{})}
def trace_enabled(~W:Type,~E:Data,tx:Tx<W,E>) -> Tx<W,E> & Bool:
  match tx:
    case Tx{world,undo,commands,events,+trace,meter}:(Tx{world,undo,commands,events,trace,meter},TraceFacts.enabled(trace))
def record(~W:Type,~E:Data,tx:Tx<W,E>,fact:TraceFacts.Fact) -> Tx<W,E>:
  match tx:
    case Tx{world,undo,commands,events,trace,meter}:Tx{world,undo,commands,events,TraceFacts.append(trace,fact),meter}
def committed(~Error:Data,outcome:Outcome<Error>) -> Bool:
  match outcome:
    case Success{}:True{}
    case Failure{_}:False{}
def finish_observed(~W:Type,~E:Data,~Error:Data,~enqueue:W -> List<&1,Deferred.Command<W>> -> W,~publish:W -> List<&2,E> -> W,tx:Tx<W,E>,+outcome:Outcome<Error>) -> Returned<W,Error> & TraceFacts.State:
  match tx:
    case Tx{world,undo,commands,events,trace,meter}:(finish_world(~W,~E,~Error,~enqueue,~publish,world,undo,commands,events,outcome),TraceFacts.settle(trace,committed(~Error,outcome)))

def begin_with_trace(~W:Type,~E:Data,world:W,trace:TraceFacts.State) -> Tx<W,E>:
  Tx{world,[],[],[],trace,Meter.empty(Unit{})}
def annotate_newest(~W:Type,~E:Data,tx:Tx<W,E>,before:TraceFacts.Value,after:TraceFacts.Value) -> Tx<W,E>:
  match tx:
    case Tx{world,undo,commands,events,trace,meter}:Tx{world,undo,commands,events,TraceFacts.annotate_newest(trace,before,after),meter}
