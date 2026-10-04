import Base
import ./types.bend as T
import ./readers.bend as R
import ./streams.bend as S

type Op is Data:
  PublishOp{first: U32, count: U32}
  DeleteOp{first: U32, count: U32}
  FrameOp{}
  SkipOp{key: U32}
  PingOp{key: U32, success: Bool, first: U32, count: U32, lag: Bool, label: String}
  LifeOp{key: U32, success: Bool, first: U32, count: U32, lag: Bool, label: String}
type World<-P: Data> is Type:
  World{readers: R.Readers, clock: R.Clock, ping: S.PingLog<P>, life: S.LifeLog<U32>, output: String}

def motion(value: U32) -> T.MotionPing: T.MotionPing{value}
def health(value: U32) -> T.HealthPing: T.HealthPing{value}
def motion_code(value: T.MotionPing) -> U32:
  match value:
    case T.MotionPing{code}: code
def health_code(value: T.HealthPing) -> U32:
  match value:
    case T.HealthPing{code}: code
def identity(value: U32) -> U32: value
def make_values(~P: Data,~wrap: U32 -> P,count: Nat,+first: U32,acc: List<&2,P>) -> List<&2,P>:
  match count:
    case 0n: List.reverse(&2,P,acc)
    case 1n+n: make_values(P,wrap,n,U32.add(first,1),wrap(first) <> acc)
def check_values(~P: Data,~code: P -> U32,values: List<&2,P>,+first: U32,+count: U32,ok: Bool) -> Bool:
  match values:
    case Nil{}: Bool.and(ok,U32.is_eq(count,0))
    case Con{head,tail}: check_values(P,code,tail,U32.add(first,1),U32.sub(count,1),Bool.and(ok,Bool.and(U32.is_gt(count,0),U32.is_eq(code(head),first))))
def values_match(~P: Data,~code: P -> U32,values: List<&2,P>,first: U32,count: U32) -> Bool:
  check_values(P,code,values,first,count,True{})
def bool_equal(left: Bool,right: Bool) -> Bool:
  match left right:
    case True{} True{}: True{}
    case False{} False{}: True{}
    case _ _: False{}
def text(ok: Bool) -> String:
  match ok:
    case True{}: "PASS"
    case False{}: "FAIL"
def outcome(success: Bool) -> T.Outcome:
  match success:
    case True{}: T.Success{}
    case False{}: T.Failure{7}
def ping_done(~P: Data,~code: P -> U32,readers: R.Readers,clock: R.Clock,life: S.LifeLog<U32>,output: String,
  success: Bool,first: U32,count: U32,lag: Bool,label: String,result: S.PingRead<P>) -> World<P>:
  match result:
    case S.PingRead{log,run,values,actualLag}:
      ok = Bool.and(values_match(P,code,values,first,count),bool_equal(lag,actualLag))
      World{R.complete(readers,run,outcome(success)),clock,log,life,output ++ label ++ ":" ++ text(ok) ++ "\n"}
def ping_started(~P: Data,~code: P -> U32,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,
  success: Bool,first: U32,count: U32,lag: Bool,label: String,started: R.Started) -> World<P>:
  match started:
    case R.Started{readers,clock,run}: ping_done(P,code,readers,clock,life,output,success,first,count,lag,label,S.read_ping(P,ping,run))
def life_done(-P: Data,readers: R.Readers,clock: R.Clock,ping: S.PingLog<P>,output: String,
  success: Bool,first: U32,count: U32,lag: Bool,label: String,actualLag: Bool,result: S.LifeRead<U32>) -> World<P>:
  match result:
    case S.LifeRead{log,run,values}:
      ok = Bool.and(values_match(U32,identity,values,first,count),bool_equal(lag,actualLag))
      World{R.complete(readers,run,outcome(success)),clock,ping,log,output ++ label ++ ":" ++ text(ok) ++ "\n"}
def life_missed(-P: Data,readers: R.Readers,clock: R.Clock,ping: S.PingLog<P>,output: String,
  success: Bool,first: U32,count: U32,lag: Bool,label: String,result: S.LifeLog<U32> & (R.Run & Bool)) -> World<P>:
  match result:
    case (log,(run,actualLag)): life_done(P,readers,clock,ping,output,success,first,count,lag,label,actualLag,S.read_lifecycle(U32,log,run))
def life_started(-P: Data,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,
  success: Bool,first: U32,count: U32,lag: Bool,label: String,started: R.Started) -> World<P>:
  match started:
    case R.Started{readers,clock,run}: life_missed(P,readers,clock,ping,output,success,first,count,lag,label,S.missed(U32,life,run))
def trim_life(boundary: Maybe<&2,U32>,life: S.LifeLog<U32>,holders: List<&2,U32>) -> S.LifeLog<U32>:
  match boundary:
    case None{}: life
    case Some{window}: S.trim_lifecycle(U32,life,window,holders)
def frame_life_result(-P: Data,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,clock: R.Clock,boundary: Maybe<&2,U32>,result: R.Readers & List<&2,U32>) -> World<P>:
  match result:
    case (readers,holds): World{readers,clock,ping,trim_life(boundary,life,holds),output}
def frame_life(-P: Data,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,frame: R.Frame,result: R.Readers & List<&2,U32>) -> World<P>:
  match frame:
    case R.Frame{clock,boundary,_}: frame_life_result(P,ping,life,output,clock,boundary,result)
def frame_ping_result(-P: Data,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,frame: R.Frame,window: U32,result: R.Readers & List<&2,U32>) -> World<P>:
  match result:
    case (readers,holds): frame_life(P,S.trim(P,ping,window,holds),life,output,frame,R.holders(readers,R.Removed{0}))
def frame_ping(-P: Data,clock: R.Clock,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,+frame: R.Frame,result: R.Readers & List<&2,U32>) -> World<P>:
  match frame:
    case R.Frame{_,_,window}: frame_ping_result(P,ping,life,output,frame,window,result)
def emit_at(-P: Data,readers: R.Readers,clock: R.Clock,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,values: List<&2,P>) -> World<P>:
  match clock:
    case R.Clock{+tick,frame,retained,number}: World{readers,R.Clock{tick,frame,retained,number},S.append(P,ping,tick,values),life,output}
def delete_at(-P: Data,readers: R.Readers,clock: R.Clock,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String,values: List<&2,U32>) -> World<P>:
  match clock:
    case R.Clock{+tick,frame,retained,number}: World{readers,R.Clock{tick,frame,retained,number},ping,S.append_lifecycle(U32,life,tick,values),output}
def skip_at(-P: Data,readers: R.Readers,+key: U32,clock: R.Clock,ping: S.PingLog<P>,life: S.LifeLog<U32>,output: String) -> World<P>:
  match clock:
    case R.Clock{+tick,frame,retained,number}: World{R.skip(readers,key,tick),R.Clock{tick,frame,retained,number},ping,life,output}
def step(~P: Data,~wrap: U32 -> P,~code: P -> U32,op: Op,world: World<P>) -> World<P>:
  match op world:
    case PublishOp{first,count} World{readers,clock,ping,life,output}: emit_at(P,readers,R.advance(R.advance(clock)),ping,life,output,make_values(P,wrap,U32.to_nat(count),first,[]))
    case DeleteOp{first,count} World{readers,clock,ping,life,output}: delete_at(P,readers,R.advance(clock),ping,life,output,make_values(U32,identity,U32.to_nat(count),first,[]))
    case FrameOp{} World{readers,+clock,ping,life,output}: frame_ping(P,clock,ping,life,output,R.frame(clock),R.holders(readers,R.Messages{}))
    case SkipOp{key} World{readers,clock,ping,life,output}: skip_at(P,readers,key,clock,ping,life,output)
    case PingOp{+key,success,first,count,lag,label} World{readers,clock,ping,life,output}: ping_started(P,code,ping,life,output,success,first,count,lag,label,R.begin(readers,key,R.Interests{True{},[0],True{}},clock))
    case LifeOp{+key,success,first,count,lag,label} World{readers,clock,ping,life,output}: life_started(P,ping,life,output,success,first,count,lag,label,R.begin(readers,key,R.Interests{True{},[0],True{}},clock))
def run(~P: Data,~wrap: U32 -> P,~code: P -> U32,ops: List<&2,Op>,world: World<P>) -> World<P>:
  match ops:
    case Nil{}: world
    case Con{head,tail}: run(P,wrap,code,tail,step(P,wrap,code,head,world))
def output(-P: Data,world: World<P>) -> String:
  match world:
    case World{_,_,_,_,result}: result
def initial(-P: Data,+capacity: U32) -> World<P>: World{R.initial(),R.clock(),S.initial(P,capacity),S.life_initial(U32,capacity),""}
def ping_ops(+c: U32) -> List<&2,Op>:
  [FrameOp{},PingOp{0,True{},0,0,False{},"fast-prime"},PingOp{1,True{},0,0,False{},"b-prime"},
   PublishOp{0,c},PingOp{0,True{},0,c,False{},"fast-full"},PublishOp{c,1},FrameOp{},
   PingOp{1,False{},c,1,True{},"b-first-failure"},PingOp{1,True{},c,1,True{},"b-retry"},PingOp{0,True{},c,1,False{},"fast-independent"},
   PublishOp{U32.add(c,1),U32.add(c,1)},FrameOp{},PingOp{0,True{},0,0,True{},"fast-oversized"},PingOp{1,True{},0,0,True{},"b-oversized"},PingOp{2,True{},0,0,False{},"late-registration"}]
def life_ops(+c: U32) -> List<&2,Op>:
  [FrameOp{},LifeOp{0,True{},0,0,False{},"life-fast-prime"},LifeOp{1,True{},0,0,False{},"life-b-prime"},
   DeleteOp{1,U32.add(c,1)},LifeOp{0,True{},1,U32.add(c,1),False{},"life-before-trim"},FrameOp{},FrameOp{},
   LifeOp{1,False{},2,c,True{},"life-first-failure"},LifeOp{1,True{},2,c,True{},"life-retry"},LifeOp{0,True{},0,0,False{},"life-independent"},LifeOp{2,True{},2,c,False{},"life-late"}]
def skip_ops() -> List<&2,Op>:
  [FrameOp{},PingOp{0,True{},0,0,False{},"skip-prime"},PublishOp{3,1},DeleteOp{8,1},SkipOp{0},FrameOp{},FrameOp{},FrameOp{},
   PingOp{0,False{},0,0,False{},"skip-drops-message-before-success"},LifeOp{0,False{},8,1,False{},"skip-keeps-life-failure"},LifeOp{0,True{},8,1,False{},"skip-keeps-life-retry"},PingOp{0,True{},0,0,False{},"skip-drops-message"}]
def first_failure_ops() -> List<&2,Op>:
  [PingOp{3,False{},0,0,False{},"first-invocation-fails"},PublishOp{7,1},DeleteOp{9,1},FrameOp{},FrameOp{},FrameOp{},
   PingOp{3,False{},7,1,False{},"failed-registration-holds-message"},LifeOp{3,True{},9,1,False{},"failed-registration-holds-life"}]
def unheld_ops() -> List<&2,Op>:
  [SkipOp{4},PublishOp{7,1},DeleteOp{9,1},FrameOp{},FrameOp{},FrameOp{},
   PingOp{4,False{},0,0,False{},"unheld-message-expiry-late"},LifeOp{4,True{},0,0,False{},"unheld-life-expiry-late"}]
def suite(~P: Data,~wrap: U32 -> P,~code: P -> U32,+c: U32) -> String:
  output(P,run(P,wrap,code,ping_ops(c),initial(P,c))) ++ output(P,run(P,wrap,code,life_ops(c),initial(P,c))) ++ output(P,run(P,wrap,code,skip_ops(),initial(P,c))) ++ output(P,run(P,wrap,code,first_failure_ops(),initial(P,c))) ++ output(P,run(P,wrap,code,unheld_ops(),initial(P,c)))
# Trusted fixture setup enforces finite arithmetic bounds before any mutation:
# c<=65536; each listed schedule has <32 steps and <=2c+2 resident values.
def bounded(+c: U32,ok: Bool) -> IO(Unit):
  match ok:
    case False{}: IO.print("SETUP_REJECTED\n")
    case True{}: IO.print("Motion3\n" ++ suite(T.MotionPing,motion,motion_code,3) ++ "Health3\n" ++ suite(T.HealthPing,health,health_code,3) ++ "Motion65536\n" ++ suite(T.MotionPing,motion,motion_code,c) ++ "Health65536\n" ++ suite(T.HealthPing,health,health_code,c))
def setup(+c: U32) -> IO(Unit):
  bounded(c,Bool.and(U32.is_le(c,65536),U32.is_gt(c,0)))
def main() -> IO(Unit): setup(65536)
