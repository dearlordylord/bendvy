import Base

type Counts is Data:
  Counts{undo:Nat,commands:Nat,events:Nat}
type Boundary is Data:
  Boundary{site:String,delta:Counts,current:Counts,peak:Counts}
type State is Data:
  State{current:Counts,peak:Counts,reverseBoundaries:List<&2,Boundary>,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>}
type Witness is Data:
  Witness{namespace:U32,tick:U32,pending:U32,events:Nat}
type Report is Data:
  Report{boundaries:List<&2,Boundary>,terminal:Counts,consistent:Bool,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>,returned:Maybe<&2,Witness>}
def empty(_:Unit) -> State:State{Counts{0n,0n,0n},Counts{0n,0n,0n},[],None{},None{},None{}}
def maximum_chosen(a:Nat,b:Nat,result:Bool) -> Nat:
  match result:
    case True{}:b
    case False{}:a
def maximum(+a:Nat,+b:Nat) -> Nat:maximum_chosen(a,b,Nat.is_lt(a,b))
def maxima(value:Counts,peak:Counts) -> Counts:
  match value peak:
    case Counts{a,b,c} Counts{x,y,z}:Counts{maximum(a,x),maximum(b,y),maximum(c,z)}
def recorded_peak(site:String,delta:Counts,+current:Counts,rows:List<&2,Boundary>,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>,+peak:Counts) -> State:State{current,peak,Boundary{site,delta,current,peak} <> rows,namespace,beginTick,endTick}
def recorded(site:String,delta:Counts,+current:Counts,prior:Counts,rows:List<&2,Boundary>,namespace:Maybe<&2,U32>,beginTick:Maybe<&2,U32>,endTick:Maybe<&2,U32>) -> State:recorded_peak(site,delta,current,rows,namespace,beginTick,endTick,maxima(current,prior))
def append(state:State,site:String,+du:Nat,+dc:Nat,+de:Nat) -> State:
  match state:
    case State{Counts{u,c,e},peak,rows,namespace,beginTick,endTick}:recorded(site,Counts{du,dc,de},Counts{Nat.add(u,du),Nat.add(c,dc),Nat.add(e,de)},peak,rows,namespace,beginTick,endTick)
def transfer_commands(state:State,site:String) -> State:
  match state:
    case State{Counts{u,c,e},peak,rows,namespace,beginTick,endTick}:recorded(site,Counts{0n,0n,0n},Counts{u,0n,e},peak,rows,namespace,beginTick,endTick)
def report(state:State,+nu:Nat,+nc:Nat,+ne:Nat) -> Report:
  match state:
    case State{Counts{u,c,e},_,rows,namespace,beginTick,endTick}:Report{List.reverse(&2,Boundary,rows),Counts{nu,nc,ne},Bool.and(Nat.is_eq(u,nu),Bool.and(Nat.is_eq(c,nc),Nat.is_eq(e,ne))),namespace,beginTick,endTick,None{}}
def started(state:State,namespace:U32,tick:U32) -> State:
  match state:
    case State{current,peak,rows,_,_,_}:State{current,peak,rows,Some{namespace},Some{tick},None{}}
def ended(state:State,tick:U32) -> State:
  match state:
    case State{current,peak,rows,namespace,beginTick,_}:State{current,peak,rows,namespace,beginTick,Some{tick}}
def optional(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"null"
    case Some{value}:U32.show(value)
def counts(value:Counts) -> String:
  match value:
    case Counts{u,c,e}:"[" ++ Nat.show(u) ++ "," ++ Nat.show(c) ++ "," ++ Nat.show(e) ++ "]"
def boundary(value:Boundary) -> String:
  match value:
    case Boundary{site,delta,current,peak}:"{\"site\":\"" ++ site ++ "\",\"delta\":" ++ counts(delta) ++ ",\"current\":" ++ counts(current) ++ ",\"peak\":" ++ counts(peak) ++ "}"
def tail(rows:List<&2,Boundary>) -> String:
  match rows:
    case []:"]"
    case row <> rest:"," ++ boundary(row) ++ tail(rest)
def rows(values:List<&2,Boundary>) -> String:
  match values:
    case []:"[]"
    case row <> rest:"[" ++ boundary(row) ++ tail(rest)
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def witness(value:Maybe<&2,Witness>) -> String:
  match value:
    case None{}:"null"
    case Some{Witness{namespace,tick,pending,events}}:"{\"namespace\":" ++ U32.show(namespace) ++ ",\"tick\":" ++ U32.show(tick) ++ ",\"pending\":" ++ U32.show(pending) ++ ",\"events\":" ++ Nat.show(events) ++ "}"
def settled(report:Report,value:Witness) -> Report:
  match report:
    case Report{boundaries,terminal,consistent,namespace,beginTick,endTick,_}:Report{boundaries,terminal,consistent,namespace,beginTick,endTick,Some{value}}
def render(kind:String,value:Report) -> String:
  match value:
    case Report{boundaries,terminal,consistent,namespace,beginTick,endTick,returned}:"{\"kind\":\"" ++ kind ++ "\",\"namespace\":" ++ optional(namespace) ++ ",\"beginTick\":" ++ optional(beginTick) ++ ",\"endTick\":" ++ optional(endTick) ++ ",\"appendTick\":null,\"boundaries\":" ++ rows(boundaries) ++ ",\"terminal\":" ++ counts(terminal) ++ ",\"consistent\":" ++ boolean(consistent) ++ ",\"returnedWorld\":" ++ witness(returned) ++ "}"

type Sample is Data:
  Sample{kind:String,iteration:Maybe<&2,U32>,phase:Maybe<&2,U32>,ordinal:Nat,committed:Bool,report:Report}
def sample(kind:String,iteration:U32,phase:U32,ordinal:Nat,committed:Bool,report:Report) -> Sample:Sample{kind,Some{iteration},Some{phase},ordinal,committed,report}
def sample_render(value:Sample) -> String:
  match value:
    case Sample{+kind,iteration,phase,ordinal,committed,report}:"{\"kind\":\"" ++ kind ++ "\",\"iteration\":" ++ optional(iteration) ++ ",\"phase\":" ++ optional(phase) ++ ",\"ordinal\":" ++ Nat.show(ordinal) ++ ",\"committed\":" ++ boolean(committed) ++ ",\"tx\":" ++ render(kind,report) ++ "}"
def samples_tail(values:List<&2,Sample>) -> String:
  match values:
    case []:"]"
    case value <> rest:"," ++ sample_render(value) ++ samples_tail(rest)
def samples_render(values:List<&2,Sample>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"[" ++ sample_render(value) ++ samples_tail(rest)
