import Base
import ./fixture.bend as F
import ./observer.bend as O
import ../../../../src/ecs/ordinary-app-schedules.bend as N
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch

type Action<S:Data> is Data:
  Insert{label:String,plan:SP.Plan<S>}
  Remove{label:String}
  Get{label:String}
  Run{label:String}
  FailureMode{enabled:Bool}
  Snapshot{}
def one(~S:Data,id:U32) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.System{id,0},[]},SP.Sequence{SP.Entry{Sch.System{3,0},[]},SP.Entry{Sch.Barrier{},[]}}}
def actions(~S:Data) -> List<&2,Action<S>>:
  [Insert{"First",one(~S,1)},Insert{"Second",one(~S,1)},Insert{"Separate",one(~S,2)},Insert{"First",one(~S,99)},Insert{"Separate",SP.Sequence{one(~S,2),one(~S,2)}},Run{"First"},Run{"Second"},Run{"First"},Run{"Separate"},FailureMode{True{}},Run{"First"},FailureMode{False{}},Run{"Second"},Insert{"First",one(~S,2)},Run{"First"},Remove{"Second"},Run{"Second"},Get{"First"},Get{"Missing"},Remove{"Missing"},Insert{"Skip",SP.Sequence{SP.Entry{Sch.System{1,1},[]},SP.Entry{Sch.System{3,0},[]}}},Run{"Skip"},Remove{"Skip"},Snapshot{},Run{"First"},Snapshot{}]
def continued(~S:Data,next:F.application(~S) -> String -> List<&2,String>,message:String,result:F.application(~S) & String) -> List<&2,String>:
  match result:
    case (app,physical):next(app,message++","++physical++"}")
def record(~S:Data,next:F.application(~S) -> String -> List<&2,String>,message:String,app:F.application(~S)) -> List<&2,String>:
  continued(~S,next,message,O.state(~S,app))
def inserted(~S:Data,next:F.application(~S) -> String -> List<&2,String>,label:String,result:N.Insertion<F.application(~S),S>) -> List<&2,String>:
  match result:
    case N.Invalid{app}:record(~S,next,"\"op\":"++O.quoted("insert:"++label)++",\"result\":\"invalid\",\"view\":null",app)
    case N.Inserted{app,previous}:record(~S,next,"\"op\":"++O.quoted("insert:"++label)++",\"result\":"++O.maybe_plan(~S,previous)++",\"view\":null",app)
def looked(~S:Data,next:F.application(~S) -> String -> List<&2,String>,operation:String,result:F.application(~S) & Maybe<&2,SP.Plan<S>>) -> List<&2,String>:
  match result:
    case (app,plan):record(~S,next,"\"op\":"++O.quoted(operation)++",\"result\":"++O.maybe_plan(~S,plan)++",\"view\":null",app)
def executed(~S:Data,next:F.application(~S) -> String -> List<&2,String>,label:String,result:Single.RunResult<F.application(~S),S,String>) -> List<&2,String>:
  match result:
    case Single.Finished{app,observations}:record(~S,next,"\"op\":"++O.quoted("run:"++label)++",\"result\":"++O.outcome("finished",observations)++",\"view\":null",app)
    case Single.Failed{app,error,observations}:record(~S,next,"\"op\":"++O.quoted("run:"++label)++",\"result\":"++O.outcome("failed:"++error,observations)++",\"view\":null",app)
    case Single.Rejected{app}:record(~S,next,"\"op\":"++O.quoted("run:"++label)++",\"result\":\"rejected\",\"view\":null",app)
    case Single.Missing{app,requirements}:record(~S,next,"\"op\":"++O.quoted("run:"++label)++",\"result\":\"missing\",\"view\":null",app)
def ran(~S:Data,next:F.application(~S) -> String -> List<&2,String>,+label:String,result:N.RunResult<F.application(~S),S,String>) -> List<&2,String>:
  match result:
    case N.Unknown{app}:record(~S,next,"\"op\":"++O.quoted("run:"++label)++",\"result\":\"unknown\",\"view\":null",app)
    case N.Executed{result}:executed(~S,next,label,result)
def indexed(~S:Data,next:F.application(~S) -> String -> List<&2,String>,schedules:String,result:F.application(~S) & Maybe<&2,N.Index>) -> List<&2,String>:
  match result:
    case (app,access):record(~S,next,"\"op\":\"snapshot\",\"result\":null,\"view\":"++O.view(schedules,O.index(access)),app)
def snapshot(~S:Data,next:F.application(~S) -> String -> List<&2,String>,result:F.application(~S) & Maybe<&2,N.Description<S,F.Rows()>>) -> List<&2,String>:
  match result:
    case (app,view):indexed(~S,next,O.debug(~S,view),N.index(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app))
def execute(~S:Data,actions:List<&2,Action<S>>,app:F.application(~S),history:List<&2,String>) -> List<&2,String>:
  match actions:
    case []:history
    case Insert{+label,plan} <> rest:inserted(~S,a => message => execute(~S,rest,a,List.append(&2,String,history,["{"++message])),label,N.insert(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,label,plan))
    case Remove{+label} <> rest:looked(~S,a => message => execute(~S,rest,a,List.append(&2,String,history,["{"++message])),"remove:"++label,N.remove(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,label))
    case Get{+label} <> rest:looked(~S,a => message => execute(~S,rest,a,List.append(&2,String,history,["{"++message])),"get:"++label,N.get(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,label))
    case Run{+label} <> rest:ran(~S,a => message => execute(~S,rest,a,List.append(&2,String,history,["{"++message])),label,N.run(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),~String,~F.dispatch(~S),~F.condition(~S),~F.provision(~S),app,label))
    case FailureMode{+flag} <> rest:record(~S,a => message => execute(~S,rest,a,List.append(&2,String,history,["{"++message])),"\"op\":\"failure-mode\",\"result\":"++O.quoted(O.bool(flag))++",\"view\":null",F.mode(~S,app,flag))
    case Snapshot{} <> rest:snapshot(~S,a => message => execute(~S,rest,a,List.append(&2,String,history,["{"++message])),N.snapshot(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app))
def created(~S:Data,+schema:String,+debug:Bool,result:Maybe<&1,F.application(~S)>) -> String:
  match result:
    case None{}:"{\"creationFailure\":true}"
    case Some{app}:"{\"schema\":"++O.quoted(schema)++",\"debug\":"++O.bool(debug)++",\"records\":["++O.join(execute(~S,actions(~S),N.enabled(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,debug),[]))++"]}"
def scene(~S:Data,+schema:String,+debug:Bool) -> IO(String):
  IO.bind(Maybe<&1,F.application(~S)>,String,F.create(~S),value => IO.pure(String,created(~S,schema,debug,value)))
def scenes() -> IO(List<&2,String>):
  IO.bind(String,List<&2,String>,scene(~F.Workshop,"Workshop",False{}),a => IO.bind(String,List<&2,String>,scene(~F.Workshop,"Workshop",True{}),b => IO.bind(String,List<&2,String>,scene(~F.Garden,"Garden",False{}),c => IO.bind(String,List<&2,String>,scene(~F.Garden,"Garden",True{}),d => IO.pure(List<&2,String>,[a,b,c,d])))))
def loops(count:Nat) -> IO(List<&2,String>):
  match count:
    case 0n:IO.pure(List<&2,String>,[])
    case 1n+rest:IO.bind(List<&2,String>,List<&2,String>,scenes(),head => IO.bind(List<&2,String>,List<&2,String>,loops(rest),tail => IO.pure(List<&2,String>,List.append(&2,String,head,tail))))
def run(count:Nat) -> IO(String):
  IO.bind(List<&2,String>,String,loops(count),items => IO.pure(String,"["++O.join(items)++"]"))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(1n),IO.print)
