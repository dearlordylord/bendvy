import Base
import ./change-tick.bend as Tick

# Administrative time and captured execution ticks. Payloads never live here.
# Nested execution restores its enclosing tick without rewinding World time.
type State is Data:
  State{now:Tick.Tick,scopes:List<&2,Tick.Tick>}

def empty() -> State:
  State{Tick.zero(),[]}

def now(state:State) -> Tick.Tick:
  match state:
    case State{tick,_}:tick

def entered(+tick:Tick.Tick,scopes:List<&2,Tick.Tick>) -> State & Tick.Tick:
  (State{tick,tick <> scopes},tick)

# Every admitted system execution captures exactly one new change tick.
def enter(state:State) -> State & Tick.Tick:
  match state:
    case State{tick,scopes}:entered(Tick.next(tick),scopes)

def left(tick:Tick.Tick,scopes:List<&2,Tick.Tick>) -> State:
  match scopes:
    case []:State{tick,[]}
    case _ <> rest:State{tick,rest}

# Complete an execution scope; administrative time is retained on failure too.
def leave(state:State) -> State:
  match state:
    case State{tick,scopes}:left(tick,scopes)

def advanced(+tick:Tick.Tick,scopes:List<&2,Tick.Tick>) -> State & Tick.Tick:
  (State{tick,scopes},tick)

# Advance an explicit direct/deferred boundary without opening a system scope.
def advance(state:State) -> State & Tick.Tick:
  match state:
    case State{tick,scopes}:advanced(Tick.next(tick),scopes)

def write_scoped(tick:Tick.Tick,scopes:List<&2,Tick.Tick>) -> State & Tick.Tick:
  match scopes:
    case []:advanced(Tick.next(tick),[])
    case +active <> rest:(State{tick,active <> rest},active)

# Writes in a system reuse its captured tick; standalone writes get a new tick.
def write(state:State) -> State & Tick.Tick:
  match state:
    case State{tick,scopes}:write_scoped(tick,scopes)

# Captured tick of the enclosing execution, or administrative time outside a run.
def current_scoped(tick:Tick.Tick,scopes:List<&2,Tick.Tick>) -> Tick.Tick:
  match scopes:
    case []:tick
    case active <> _:active
def current(state:State) -> Tick.Tick:
  match state:
    case State{tick,scopes}:current_scoped(tick,scopes)

# Lower query execution reuses an admitted scope, opening one only when direct.
def ensured(+tick:Tick.Tick,scopes:List<&2,Tick.Tick>) -> State & Bool:
  match scopes:
    case []:(State{Tick.next(tick),[Tick.next(tick)]},True{})
    case active <> rest:(State{tick,active <> rest},False{})
def ensure(state:State) -> State & Bool:
  match state:
    case State{tick,scopes}:ensured(tick,scopes)
def finish(owned:Bool,state:State) -> State:
  match owned:
    case False{}:state
    case True{}:leave(state)
