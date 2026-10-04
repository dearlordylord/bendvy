import Base
import ./types.bend as T

# Signature canaries only: opaque owners/keys are supplied by the trusted adapter.
# These envelopes do not construct a registry, invocation authority or log.
type BeginResult<-Readers: Type, -Run: Type, -Clock: Data> is Type:
  BeginResult{readers: Readers, clock: Clock, run: Run}
type RunInfo<-Run: Type> is Type:
  RunInfo{run: Run, state: T.ReaderState, boundary: T.ReadBoundary}
type ReadResult<-Log: Type, -Run: Type, -Value: Data> is Type:
  ReadResult{log: Log, run: Run, values: List<&2,Value>}
type EventResult<-Log: Type, -Run: Type, -Ping: Data> is Type:
  EventResult{log: Log, run: Run, values: List<&2,Ping>, lagged: Bool}

def begin_join(-Readers: Type,-Run: Type,-Clock: Data,-Key: Data,-Interests: Data,
  hook: Readers -> Key -> Interests -> Clock -> BeginResult<Readers,Run,Clock>,
  readers: Readers,key: Key,interests: Interests,clock: Clock) -> BeginResult<Readers,Run,Clock>:
  hook(readers,key,interests,clock)
def complete_join(-Readers: Type,-Run: Type,hook: Readers -> Run -> T.Outcome -> Readers,
  readers: Readers,run: Run,outcome: T.Outcome) -> Readers:
  hook(readers,run,outcome)
def skip_join(-Readers: Type,-Key: Data,hook: Readers -> Key -> U32 -> Readers,
  readers: Readers,key: Key,now: U32) -> Readers:
  hook(readers,key,now)
def project_join(-Run: Type,hook: Run -> RunInfo<Run>,run: Run) -> RunInfo<Run>:
  hook(run)
def event_join(-Log: Type,-Run: Type,-Ping: Data,
  hook: Log -> Run -> EventResult<Log,Run,Ping>,log: Log,run: Run) -> EventResult<Log,Run,Ping>:
  hook(log,run)
def lifecycle_join(-Log: Type,-Run: Type,-H: Data,
  hook: Log -> Run -> ReadResult<Log,Run,H>,log: Log,run: Run) -> ReadResult<Log,Run,H>:
  hook(log,run)
def append_join(-Log: Type,-Value: Data,hook: Log -> U32 -> List<&2,Value> -> Log,
  log: Log,tick: U32,values: List<&2,Value>) -> Log:
  hook(log,tick,values)
def frame_join(-Logs: Type,-Clock: Data,-Holds: Data,
  hook: Logs -> Clock -> Holds -> Logs & Clock,logs: Logs,clock: Clock,holds: Holds) -> Logs & Clock:
  hook(logs,clock,holds)
def trim_join(-Log: Type,-Holds: Data,hook: Log -> U32 -> Holds -> Log,
  log: Log,window: U32,holds: Holds) -> Log:
  hook(log,window,holds)

# Independent observation predicates and finite perturbed observations only.
# They are neither concrete reader operations nor proved integration laws.
def state_equal(left: T.ReaderState,right: T.ReaderState) -> Bool:
  match left right:
    case T.ReaderState{a,b,c} T.ReaderState{x,y,z}:
      Bool.and(U32.is_eq(a,x),Bool.and(U32.is_eq(b,y),U32.is_eq(c,z)))
def optional_equal(left: Maybe<&2,T.ReaderState>,right: Maybe<&2,T.ReaderState>) -> Bool:
  match left right:
    case None{} None{}: True{}
    case Some{a} Some{b}: state_equal(a,b)
    case _ _: False{}
def boundary_equal(left: T.ReadBoundary,right: T.ReadBoundary) -> Bool:
  match left right:
    case T.ReadBoundary{a,b,c} T.ReadBoundary{x,y,z}:
      Bool.and(U32.is_eq(a,x),Bool.and(U32.is_eq(b,y),U32.is_eq(c,z)))
def begin_known(+before: T.ReaderState,+now: U32,after: T.ReaderState,boundary: T.ReadBoundary) -> Bool:
  match before:
    case T.ReaderState{+registered,+last,+stream}:
      Bool.and(state_equal(T.ReaderState{registered,last,stream},after),boundary_equal(T.ReadBoundary{last,stream,U32.add(now,1)},boundary))
def begin_observation(before: Maybe<&2,T.ReaderState>,+now: U32,after: T.ReaderState,boundary: T.ReadBoundary) -> Bool:
  match before:
    case None{}: begin_known(T.ReaderState{now,0,0},now,after,boundary)
    case Some{state}: begin_known(state,now,after,boundary)
def complete_observation(outcome: T.Outcome,+before: T.ReaderState,+thisRun: U32,after: T.ReaderState) -> Bool:
  match outcome before:
    case T.Success{} T.ReaderState{registered,_,_}: state_equal(T.ReaderState{registered,thisRun,thisRun},after)
    case T.Failure{_} state: state_equal(state,after)
def skip_observation(before: Maybe<&2,T.ReaderState>,now: U32,after: Maybe<&2,T.ReaderState>) -> Bool:
  match before:
    case None{}: optional_equal(None{},after)
    case Some{T.ReaderState{registered,last,_}}: optional_equal(Some{T.ReaderState{registered,last,now}},after)
def maximum_case(order: Bool,a: U32,b: U32) -> U32:
  match order:
    case True{}: b
    case False{}: a
def maximum(+a: U32,+b: U32) -> U32:
  maximum_case(U32.is_lt(a,b),a,b)
def bool_equal(a: Bool,b: Bool) -> Bool:
  match a b:
    case True{} True{}: True{}
    case False{} False{}: True{}
    case _ _: False{}
def lag_observation(dropped: U32,since: U32,registered: U32,observed: Bool) -> Bool:
  bool_equal(U32.is_gt(dropped,maximum(since,registered)),observed)
def sequence_equal(left: List<&2,U32>,right: List<&2,U32>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,as} Con{b,bs}: Bool.and(U32.is_eq(a,b),sequence_equal(as,bs))
    case _ _: False{}
def retained_observation(expected: List<&2,U32>,actual: List<&2,U32>,expectedDrop: U32,actualDrop: U32) -> Bool:
  Bool.and(sequence_equal(expected,actual),U32.is_eq(expectedDrop,actualDrop))

# Small independent oracle snapshots; these are not the concrete queue/clock.
type ClockView is Data:
  ClockView{tick: U32, frameStart: U32, retainedAfter: U32, frameNo: U32}
def clock_equal(left: ClockView,right: ClockView) -> Bool:
  match left right:
    case ClockView{a,b,c,d} ClockView{w,x,y,z}:
      Bool.and(U32.is_eq(a,w),Bool.and(U32.is_eq(b,x),Bool.and(U32.is_eq(c,y),U32.is_eq(d,z))))
def tick_equal(left: Maybe<&2,U32>,right: Maybe<&2,U32>) -> Bool:
  match left right:
    case None{} None{}: True{}
    case Some{a} Some{b}: U32.is_eq(a,b)
    case _ _: False{}
def frame_case(positive: Bool,+now: U32,+oldStart: U32,+oldRetained: U32,frames: U32,
  after: ClockView,lifecycle: Maybe<&2,U32>,messages: U32) -> Bool:
  match positive:
    case True{}: Bool.and(clock_equal(ClockView{now,now,oldStart,U32.add(frames,1)},after),Bool.and(tick_equal(Some{oldStart},lifecycle),U32.is_eq(oldStart,messages)))
    case False{}: Bool.and(clock_equal(ClockView{now,now,oldRetained,U32.add(frames,1)},after),Bool.and(tick_equal(None{},lifecycle),U32.is_eq(oldRetained,messages)))
def frame_observation(before: ClockView,after: ClockView,lifecycle: Maybe<&2,U32>,messages: U32) -> Bool:
  match before:
    case ClockView{now,+oldStart,retained,frames}: frame_case(U32.is_gt(oldStart,0),now,oldStart,retained,frames,after,lifecycle,messages)
type BatchView is Data:
  BatchView{tick: U32, values: List<&2,U32>}
def batch_equal(left: BatchView,right: BatchView) -> Bool:
  match left right:
    case BatchView{a,x} BatchView{b,y}: Bool.and(U32.is_eq(a,b),sequence_equal(x,y))
def batches_equal(left: List<&2,BatchView>,right: List<&2,BatchView>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,as} Con{b,bs}: Bool.and(batch_equal(a,b),batches_equal(as,bs))
    case _ _: False{}
def append_observation(before: List<&2,BatchView>,at: U32,values: List<&2,U32>,after: List<&2,BatchView>) -> Bool:
  match values:
    case Nil{}: batches_equal(before,after)
    case Con{v,vs}: batches_equal(List.append(&2,BatchView,before,[BatchView{at,v <> vs}]),after)

# Each pair is a positive oracle observation followed by rejection of a deliberate
# perturbation. Retention fixtures are the pinned C3 source cases, not adapters.
def checks() -> List<&2,Bool>:
  [begin_observation(None{},8,T.ReaderState{8,0,0},T.ReadBoundary{0,0,9}),
   Bool.not(begin_observation(None{},8,T.ReaderState{9,9,9},T.ReadBoundary{9,9,9})),
   complete_observation(T.Failure{7},T.ReaderState{8,0,0},9,T.ReaderState{8,0,0}),
   Bool.not(optional_equal(Some{T.ReaderState{8,0,0}},None{})),
   begin_observation(Some{T.ReaderState{8,0,0}},9,T.ReaderState{8,0,0},T.ReadBoundary{0,0,10}),
   Bool.not(begin_observation(Some{T.ReaderState{8,0,0}},9,T.ReaderState{9,0,0},T.ReadBoundary{0,0,10})),
   complete_observation(T.Success{},T.ReaderState{8,0,0},10,T.ReaderState{8,10,10}),
   Bool.not(complete_observation(T.Success{},T.ReaderState{8,0,0},10,T.ReaderState{8,11,11})),
   complete_observation(T.Failure{7},T.ReaderState{1,2,3},4,T.ReaderState{1,2,3}),
   Bool.not(complete_observation(T.Failure{7},T.ReaderState{1,2,3},4,T.ReaderState{1,4,4})),
   skip_observation(Some{T.ReaderState{1,2,3}},7,Some{T.ReaderState{1,2,7}}),
   Bool.not(skip_observation(Some{T.ReaderState{1,2,3}},7,Some{T.ReaderState{1,7,7}})),
   skip_observation(None{},7,None{}),
   Bool.not(skip_observation(None{},7,Some{T.ReaderState{7,0,7}})),
   retained_observation([3,4],[3,4],1,1),
   Bool.not(retained_observation([3,4],[2,3,4],1,1)),
   retained_observation([],[],5,5),
   Bool.not(retained_observation([],[6,7,8],5,5)),
   retained_observation([2,3,4],[2,3,4],3,3),
   Bool.not(retained_observation([2,3,4],[],3,3)),
   lag_observation(5,0,5,False{}),
   Bool.not(lag_observation(5,0,5,True{})),
   lag_observation(5,0,0,True{}),
   Bool.not(lag_observation(5,0,0,False{})),
   append_observation([BatchView{1,[1,2]}],3,[3,4],[BatchView{1,[1,2]},BatchView{3,[3,4]}]),
   Bool.not(append_observation([BatchView{1,[1,2]}],3,[3,4],[BatchView{3,[3,4]}])),
   append_observation([BatchView{1,[1,2]}],3,[],[BatchView{1,[1,2]}]),
   Bool.not(append_observation([BatchView{1,[1,2]}],3,[],[BatchView{1,[1,2]},BatchView{3,[]}])),
   frame_observation(ClockView{8,3,1,4},ClockView{8,8,3,5},Some{3},3),
   Bool.not(frame_observation(ClockView{8,3,1,4},ClockView{9,8,3,5},Some{3},3)),
   frame_observation(ClockView{0,0,0,0},ClockView{0,0,0,1},None{},0),
   Bool.not(frame_observation(ClockView{0,0,0,0},ClockView{0,0,0,1},Some{0},0))]
def main() -> List<&2,Bool>:
  checks()
