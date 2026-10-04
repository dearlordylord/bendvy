import Base
import ./types.bend as T

# Trusted adapter-owned registry. Keys are allocated by actual base construction;
# gated copies retain the key. Each runtime owns a separate registry.
# Setup must bound all tick/frame increments below U32.MAX before execution.
type Clock is Data:
  Clock{tick: U32, frameStart: U32, retainedAfter: U32, frameNo: U32}
type Interests is Data:
  Interests{messages: Bool, removed: List<&2,U32>, despawned: Bool}
type Slot is Data:
  Slot{key: U32, interests: Interests, state: T.ReaderState}
type Readers is Type:
  Readers{slots: List<&2,Slot>}
type Run is Type:
  Run{key: U32, interests: Interests, state: T.ReaderState, boundary: T.ReadBoundary}
type Started is Type:
  Started{readers: Readers, clock: Clock, run: Run}
type RunInfo is Type:
  RunInfo{run: Run, state: T.ReaderState, boundary: T.ReadBoundary}
type ReadKind is Data:
  Messages{}
  Removed{component: U32}
  Despawned{}
type Frame is Data:
  Frame{clock: Clock, lifecycle: Maybe<&2,U32>, messages: U32}

def initial() -> Readers: Readers{[]}
def clock() -> Clock: Clock{0,0,0,0}
def find_case(hit: Bool,head: Slot,rest: Maybe<&2,Slot>) -> Maybe<&2,Slot>:
  match hit:
    case True{}: Some{head}
    case False{}: rest
def find(+key: U32,slots: List<&2,Slot>) -> Maybe<&2,Slot>:
  match slots:
    case Nil{}: None{}
    case Con{Slot{+id,interests,state},tail}: find_case(U32.is_eq(key,id),Slot{id,interests,state},find(key,tail))
def replace_case(hit: Bool,head: Slot,tail: List<&2,Slot>,+value: Slot) -> List<&2,Slot>:
  match hit:
    case True{}: value <> tail
    case False{}: head <> tail
def replace(+key: U32,+value: Slot,slots: List<&2,Slot>) -> List<&2,Slot>:
  match slots:
    case Nil{}: []
    case Con{Slot{+id,interests,state},tail}: replace_case(U32.is_eq(key,id),Slot{id,interests,state},replace(key,value,tail),value)
def started(+key: U32,+interests: Interests,+state: T.ReaderState,slots: List<&2,Slot>,clock: Clock) -> Started:
  match state clock:
    case T.ReaderState{+at,+last,+stream} Clock{now,frame,retained,number}:
      +next = U32.add(now,1)
      Started{Readers{slots},Clock{next,frame,retained,number},Run{key,interests,T.ReaderState{at,last,stream},T.ReadBoundary{last,stream,next}}}
def begin_slot(+key: U32,+interests: Interests,+now: U32,slots: List<&2,Slot>,clock: Clock,found: Maybe<&2,Slot>) -> Started:
  match found:
    case None{}:
      +entry = {Slot{key,interests,T.ReaderState{now,0,0}} : Slot}
      started(key,interests,T.ReaderState{now,0,0},entry <> slots,clock)
    case Some{Slot{_,+saved,state}}: started(key,saved,state,slots,clock)
def begin_clock(readers: Readers,+key: U32,interests: Interests,clock: Clock) -> Started:
  match readers clock:
    case Readers{+slots} Clock{+now,+frame,+retained,+number}:
      begin_slot(key,interests,now,slots,Clock{now,frame,retained,number},find(key,slots))
def begin(readers: Readers,key: U32,interests: Interests,clock: Clock) -> Started:
  begin_clock(readers,key,interests,clock)
def project(run: Run) -> RunInfo:
  match run:
    case Run{key,interests,+state,+boundary}: RunInfo{Run{key,interests,state,boundary},state,boundary}
def completed(readers: Readers,run: Run) -> Readers:
  match readers run:
    case Readers{slots} Run{+key,interests,T.ReaderState{registered,_,_},T.ReadBoundary{_,_,+thisRun}}:
      Readers{replace(key,Slot{key,interests,T.ReaderState{registered,thisRun,thisRun}},slots)}
def complete(readers: Readers,run: Run,outcome: T.Outcome) -> Readers:
  match outcome:
    case T.Failure{_}: readers
    case T.Success{}: completed(readers,run)

def skip_found(+key: U32,now: U32,slots: List<&2,Slot>,found: Maybe<&2,Slot>) -> Readers:
  match found:
    case None{}: Readers{slots}
    case Some{Slot{_,interests,T.ReaderState{registered,last,_}}}:
      Readers{replace(key,Slot{key,interests,T.ReaderState{registered,last,now}},slots)}
def skip(readers: Readers,+key: U32,now: U32) -> Readers:
  match readers:
    case Readers{+slots}: skip_found(key,now,slots,find(key,slots))
def observe(readers: Readers) -> Readers & List<&2,Slot>:
  match readers:
    case Readers{+slots}: (Readers{slots},slots)
def contains(+key: U32,values: List<&2,U32>) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{head,tail}: Bool.or(U32.is_eq(key,head),contains(key,tail))
def interested(kind: ReadKind,interests: Interests) -> Bool:
  match kind interests:
    case Messages{} Interests{yes,_,_}: yes
    case Removed{component} Interests{_,components,_}: contains(component,components)
    case Despawned{} Interests{_,_,yes}: yes
def position(kind: ReadKind,state: T.ReaderState) -> U32:
  match kind state:
    case Messages{} T.ReaderState{_,_,stream}: stream
    case _ T.ReaderState{_,last,_}: last
def held(yes: Bool,value: U32,tail: List<&2,U32>) -> List<&2,U32>:
  match yes:
    case True{}: value <> tail
    case False{}: tail
def collect(+kind: ReadKind,slots: List<&2,Slot>) -> List<&2,U32>:
  match slots:
    case Nil{}: []
    case Con{Slot{_,interests,state},tail}: held(interested(kind,interests),position(kind,state),collect(kind,tail))
def holders(readers: Readers,kind: ReadKind) -> Readers & List<&2,U32>:
  match readers:
    case Readers{+slots}: (Readers{slots},collect(kind,slots))
def frame_case(old: Bool,+now: U32,+start: U32,+retained: U32,number: U32) -> Frame:
  match old:
    case True{}: Frame{Clock{now,now,start,U32.add(number,1)},Some{start},start}
    case False{}: Frame{Clock{now,now,retained,U32.add(number,1)},None{},retained}
def frame(clock: Clock) -> Frame:
  match clock:
    case Clock{now,+start,retained,number}: frame_case(U32.is_gt(start,0),now,start,retained,number)
def advance(clock: Clock) -> Clock:
  match clock:
    case Clock{now,frame,retained,number}: Clock{U32.add(now,1),frame,retained,number}
