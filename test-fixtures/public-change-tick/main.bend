import Base
import ../../src/ecs/change-tick.bend as T
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/lifecycle.bend as Life

# Finite epoch arithmetic controls; not a universal proof or integrated World test.
type Case is Data:
  Next{tick:T.Tick}
  Compare{stamp:T.Tick,last:T.Tick,this:T.Tick}
  Age{stamp:T.Tick,this:T.Tick}
  Total{tick:T.Tick}

def tick(t:T.Tick) -> String:
  match t:
    case T.Tick{epoch,low}:Nat.show(epoch) ++ ":" ++ U32.show(low)

def render(item:Case) -> String:
  match item:
    case Next{+t}:"next:" ++ tick(t) ++ "=" ++ tick(T.next(t))
    case Compare{+s,+l,+t}:"new:" ++ tick(s) ++ "/" ++ tick(l) ++ "/" ++ tick(t) ++ "=" ++ Bool.show(T.newer(s,l,t))
    case Age{+s,+t}:"age:" ++ tick(s) ++ "/" ++ tick(t) ++ "=" ++ U32.show(T.age(s,t)) ++ ":valid=" ++ Bool.show(T.not_future(s,t))
    case Total{+t}:"total:" ++ tick(t) ++ "=" ++ Nat.show(T.total(t)) ++ ":low=" ++ U32.show(T.low(t))

def rows(items:List<&2,Case>) -> String:
  match items:
    case []:""
    case item <> []:render(item)
    case item <> rest:render(item) ++ "\n" ++ rows(rest)

# Clock dependencies are root-owned snapshots; these controls exercise their API.
type Action is Data:
  Enter{}
  Write{}
  Leave{}
  Advance{}

def state_text(state:Clock.State) -> String:
  match state:
    case Clock.State{now,scopes}:tick(now) ++ "/" ++ List.show(&2,T.Tick,tick,scopes)

def operation(label:String,result:Clock.State & T.Tick) -> Clock.State & String:
  match result:
    case (+state,value):(state,label ++ "=" ++ tick(value) ++ ":state=" ++ state_text(state))

def left(state:Clock.State) -> Clock.State & String:
  (state,"leave")

def apply(action:Action,state:Clock.State) -> Clock.State & String:
  match action:
    case Enter{}:operation("enter",Clock.enter(state))
    case Write{}:operation("write",Clock.write(state))
    case Leave{}:left(Clock.leave(state))
    case Advance{}:operation("advance",Clock.advance(state))

def stepped(result:Clock.State & String,next:Clock.State -> String) -> String:
  match result:
    case (state,line):line ++ "\n" ++ next(state)

def steps(actions:List<&2,Action>,state:Clock.State) -> String:
  match actions:
    case []:"final=" ++ state_text(state)
    case action <> rest:stepped(apply(action,state),returned => steps(rest,returned))

def lifecycle(name:String,+stamp:Life.Stamp,+cursor:Maybe<&2,T.Tick>,+this:T.Tick) -> String:
  name ++ ":added=" ++ Bool.show(Life.added(stamp,cursor,this)) ++ ":changed=" ++ Bool.show(Life.changed(stamp,cursor,this))

def integration() -> String:
  steps([Enter{},Write{},Write{},Enter{},Write{},Leave{},Write{},Advance{},Write{},Leave{},Write{},Write{}],Clock.empty()) ++ "\n" ++
  steps([Enter{},Write{},Leave{},Write{}],Clock.State{T.Tick{0n,4294967295},[]}) ++ "\n" ++
  lifecycle("absent",Life.Stamp{None{},None{}},None{},T.Tick{1n,0}) ++ "\n" ++
  lifecycle("present-zero-first",Life.Stamp{Some{T.Tick{1n,0}},Some{T.Tick{1n,0}}},None{},T.Tick{1n,0}) ++ "\n" ++
  lifecycle("present-zero-equal",Life.Stamp{Some{T.Tick{1n,0}},Some{T.Tick{1n,0}}},Some{T.Tick{1n,0}},T.Tick{1n,0}) ++ "\n" ++
  lifecycle("ancient-first",Life.Stamp{Some{T.Tick{0n,4294967295}},Some{T.Tick{0n,4294967295}}},None{},T.Tick{3n,0}) ++ "\n" ++
  lifecycle("partial-first",Life.Stamp{None{},Some{T.Tick{1n,0}}},None{},T.Tick{1n,1}) ++ "\n" ++
  lifecycle("future-first",Life.Stamp{Some{T.Tick{2n,0}},Some{T.Tick{2n,0}}},None{},T.Tick{1n,1})

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("zero=" ++ tick(T.zero()) ++ ":max=" ++ U32.show(T.max_change_age()) ++ "\n" ++ rows([Next{T.Tick{0n,0}},Next{T.Tick{0n,4294967295}},Next{T.Tick{2n,4294967295}},Compare{T.Tick{0n,10},T.Tick{0n,9},T.Tick{0n,10}},Compare{T.Tick{0n,10},T.Tick{0n,10},T.Tick{0n,10}},Compare{T.Tick{1n,0},T.Tick{0n,4294967295},T.Tick{1n,0}},Compare{T.Tick{0n,4294967295},T.Tick{1n,0},T.Tick{1n,1}},Compare{T.Tick{0n,0},T.Tick{1n,0},T.Tick{3n,0}},Compare{T.Tick{2n,4294967295},T.Tick{0n,0},T.Tick{3n,0}},Compare{T.Tick{4n,0},T.Tick{0n,0},T.Tick{3n,0}},Compare{T.Tick{3n,0},T.Tick{4n,0},T.Tick{3n,0}},Compare{T.Tick{3n,1},T.Tick{3n,0},T.Tick{3n,0}},Age{T.Tick{0n,0},T.Tick{0n,3258167295}},Age{T.Tick{0n,0},T.Tick{0n,3258167296}},Age{T.Tick{0n,0},T.Tick{0n,3258167297}},Age{T.Tick{0n,4294967295},T.Tick{1n,0}},Age{T.Tick{0n,1036800000},T.Tick{1n,0}},Age{T.Tick{0n,1036799999},T.Tick{1n,0}},Age{T.Tick{0n,0},T.Tick{1n,0}},Age{T.Tick{0n,4294967295},T.Tick{2n,0}},Age{T.Tick{3n,0},T.Tick{3n,0}},Age{T.Tick{4n,0},T.Tick{3n,0}},Total{T.Tick{0n,0}},Total{T.Tick{2n,7}}]) ++ "\n" ++ integration())
