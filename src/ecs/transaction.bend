import Base
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts

# Engine-owned transaction state; gameplay receives abstract providers instead.
# The journal owns replacement values inside affine inverse closures.
# Lower-level affine transaction owner with inverse journal, staged commands
# and Data events. Raw fields/inverses are trusted engine setup; normal gameplay
# uses declared opaque capabilities. Does not automatically journal arbitrary
# mutations or make host IO reversible.
type Tx<W: Type, E: Data> is Type:
  Tx{world: W, undo: List<&1, (W -> W)>, commands:List<&1, Deferred.Command<W>>, events: List<&2, E>,trace:TraceFacts.State}

# System transaction decision: Success makes finish commit recorded effects;
# Failure makes it run recorded inverses. Does not own a World itself.
type Outcome<Error: Data> is Data:
  Success{}
  Failure{error: Error}

# Finished transaction returns its World and decision on either path.
# Contains no body output or automatic recovery receipt for rejected payloads.
type Returned<W: Type, Error: Data> is Type:
  Returned{world: W, outcome: Outcome<Error>}

# Consume World into a transaction with empty journal/queues and tracing off.
# Does not clone World; return it through finish, including on system failure.
def begin(~W: Type, ~E: Data, world: W) -> Tx<W, E>:
  Tx{world, [], [], [],TraceFacts.Off{}}

# Trusted lower-level operation: push an affine inverse onto the journal.
# Caller must ensure it restores the matching change and preserves other
# owners. Inverses execute newest first on failure, not on successful commit.
def add_undo(~W: Type, ~E: Data, tx: Tx<W, E>, inverse: W -> W) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events,trace}:
      Tx{world, inverse <> undo, commands, events,trace}

# Commands and events are accumulated in reverse and reversed once at commit.
# Stage an owned deferred command without executing it. Commit enqueues
# commands in authored order; failure discards them. Visibility follows the
# command queue's explicit barrier, not transaction completion itself.
def stage_command(~W:Type,~E:Data,tx:Tx<W,E>,command:Deferred.Command<W>) -> Tx<W,E>:
  match tx:
    case Tx{world,undo,commands,events,trace}:Tx{world,undo,command <> commands,events,trace}
# Trusted adapter staging a raw World-transforming callback as a command.
# It is not executed here; callbacks must obey their own authority/ownership
# contracts. Prefer declared commands for ordinary gameplay.
def stage(~W: Type, ~E: Data, tx: Tx<W, E>, command: W -> W) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events,trace}:
      Tx{world, undo, Deferred.Raw{command} <> commands, events,trace}

# Stage one Data event, retaining publication order for successful commit.
# Failure publishes none of this transaction's staged events. For affine
# Type payload ownership/recovery use the separate owned-event APIs.
def emit(~W: Type, ~E: Data, tx: Tx<W, E>, event: E) -> Tx<W, E>:
  match tx:
    case Tx{world, undo, commands, events,trace}:
      Tx{world, undo, commands, event <> events,trace}

# Trusted lower-level journal execution: apply inverse closures head first
# and return World. Only recorded changes are undone; no general mutation or
# external-effect rollback is inferred from calling this function.
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

# Consume the transaction and return World with its decision. Success
# enqueues commands then publishes Data events in authored order; failure
# runs the inverse journal newest first and publishes/enqueues neither.
# enqueue/publish are trusted callbacks; arbitrary external effects are outside
# this guarantee. This function does not execute the deferred command barrier.
def finish(~W: Type, ~E: Data, ~Error: Data,
  ~enqueue: W -> List<&1,Deferred.Command<W>> -> W,
  ~publish: W -> List<&2, E> -> W,
  tx: Tx<W, E>, outcome: Outcome<Error>
) -> Returned<W, Error>:
  match tx:
    case Tx{world, undo, commands, events,trace}:
      finish_world(~W, ~E, ~Error, ~enqueue, ~publish, world, undo, commands, events, outcome)

# Begin a transaction with operation tracing enabled and an empty fact list.
# Tracing observes operations; it does not strengthen rollback guarantees.
def begin_observed(~W:Type,~E:Data,world:W) -> Tx<W,E>:
  Tx{world,[],[],[],TraceFacts.On{[]}}
# Return the transaction owner and its trace-enabled flag without emitting
# a fact, invoking gameplay or changing journal/queue contents.
def trace_enabled(~W:Type,~E:Data,tx:Tx<W,E>) -> Tx<W,E> & Bool:
  match tx:
    case Tx{world,undo,commands,events,+trace}:(Tx{world,undo,commands,events,trace},TraceFacts.enabled(trace))
# Append an operation observation through the current tracing state.
# Disabled tracing retains its disabled state; facts confer no write authority.
def record(~W:Type,~E:Data,tx:Tx<W,E>,fact:TraceFacts.Fact) -> Tx<W,E>:
  match tx:
    case Tx{world,undo,commands,events,trace}:Tx{world,undo,commands,events,TraceFacts.append(trace,fact)}
def committed(~Error:Data,outcome:Outcome<Error>) -> Bool:
  match outcome:
    case Success{}:True{}
    case Failure{_}:False{}
# Finish with the same commit/rollback behavior as finish, also returning
# trace facts settled with the actual transaction decision. Returned facts are
# observations, not additional changes to apply or undo.
def finish_observed(~W:Type,~E:Data,~Error:Data,~enqueue:W -> List<&1,Deferred.Command<W>> -> W,~publish:W -> List<&2,E> -> W,tx:Tx<W,E>,+outcome:Outcome<Error>) -> Returned<W,Error> & TraceFacts.State:
  match tx:
    case Tx{world,undo,commands,events,trace}:(finish_world(~W,~E,~Error,~enqueue,~publish,world,undo,commands,events,outcome),TraceFacts.settle(trace,committed(~Error,outcome)))

# Trusted integration entry beginning an empty transaction with supplied
# tracing state. Consumes World once; no previous journal or command state is
# imported or inferred from trace facts.
def begin_with_trace(~W:Type,~E:Data,world:W,trace:TraceFacts.State) -> Tx<W,E>:
  Tx{world,[],[],[],trace}
# Advanced trace adapter adding detached before/after values to the newest
# operation fact. Does not modify World, journal semantics or publication order.
def annotate_newest(~W:Type,~E:Data,tx:Tx<W,E>,before:TraceFacts.Value,after:TraceFacts.Value) -> Tx<W,E>:
  match tx:
    case Tx{world,undo,commands,events,trace}:Tx{world,undo,commands,events,TraceFacts.annotate_newest(trace,before,after)}
