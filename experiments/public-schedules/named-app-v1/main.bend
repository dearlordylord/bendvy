import Base
import ./fixture.bend as F
import ./observer.bend as O
import ../../../src/ecs/ordinary-app-schedules.bend as N
import ../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/schedule.bend as Sch

type Action<S:Data> is Data:
  Insert{label:String,plan:SP.Plan<S>}
  Remove{label:String}
  Get{label:String}
  Run{label:String}
  Debug{enabled:Bool}
  Advance{}
  FailureMode{enabled:Bool}
  Index{}
  Snapshot{}
def one(~S:Data,id:U32) -> SP.Plan<S>:
  SP.Sequence{SP.Entry{Sch.Phase{"Tick"},[]},SP.Sequence{SP.Entry{Sch.System{id,0},[]},SP.Sequence{SP.Entry{Sch.System{3,0},[]},SP.Entry{Sch.Barrier{},[]}}}}
def actions(~S:Data) -> List<&2,Action<S>>:
  [Insert{"First",one(~S,1)},Insert{"Second",one(~S,1)},Insert{"Separate",one(~S,2)},Insert{"First",one(~S,99)},Insert{"Separate",SP.Sequence{one(~S,2),one(~S,2)}},Advance{},Run{"First"},Advance{},Run{"Second"},Run{"First"},Run{"Separate"},Advance{},FailureMode{True{}},Run{"First"},FailureMode{False{}},Run{"Second"},Insert{"First",one(~S,2)},Run{"First"},Remove{"Second"},Run{"Second"},Get{"First"},Get{"Missing"},Remove{"Missing"},Insert{"Skip",SP.Sequence{SP.Entry{Sch.System{1,1},[]},SP.Entry{Sch.System{3,0},[]}}},Run{"Skip"},Remove{"Skip"},Snapshot{},Debug{True{}},Index{},Snapshot{},Debug{False{}},Run{"First"},Index{},Snapshot{}]
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"entered("++O.quoted(name)++")"
    case Sch.Ran{id}:"ran("++U32.show(id)++")"
    case Sch.Skipped{id}:"skipped("++U32.show(id)++")"
    case Sch.Applied{}:"applied"
def continued(~S:Data,next:F.application(~S) -> String -> String,message:String,result:F.application(~S) & String) -> String:
  match result:
    case (app,physical):next(app,message++"|"++physical)
def record(~S:Data,next:F.application(~S) -> String -> String,message:String,app:F.application(~S)) -> String:
  continued(~S,next,message,O.physical(~S,app))
def inserted(~S:Data,next:F.application(~S) -> String -> String,label:String,result:N.Insertion<F.application(~S),S>) -> String:
  match result:
    case N.Invalid{app}:record(~S,next,"insert("++O.quoted(label)++")=invalid",app)
    case N.Inserted{app,previous}:record(~S,next,"insert("++O.quoted(label)++")="++O.maybe_plan(~S,previous),app)
def looked(~S:Data,next:F.application(~S) -> String -> String,operation:String,result:F.application(~S) & Maybe<&2,SP.Plan<S>>) -> String:
  match result:
    case (app,plan):record(~S,next,operation++"="++O.maybe_plan(~S,plan),app)
def indexed(~S:Data,next:F.application(~S) -> String -> String,result:F.application(~S) & Maybe<&2,N.Index>) -> String:
  match result:
    case (app,view):record(~S,next,"index="++O.index(view),app)
def executed(~S:Data,next:F.application(~S) -> String -> String,label:String,result:Single.RunResult<F.application(~S),S,String>) -> String:
  match result:
    case Single.Finished{app,observations}:record(~S,next,"run("++O.quoted(label)++")=finished"++List.show(&2,Sch.Observation,observation,observations),app)
    case Single.Failed{app,error,observations}:record(~S,next,"run("++O.quoted(label)++")=failed("++O.quoted(error)++")"++List.show(&2,Sch.Observation,observation,observations),app)
    case Single.Rejected{app}:record(~S,next,"run("++O.quoted(label)++")=rejected",app)
    case Single.Missing{app,requirements}:record(~S,next,"run("++O.quoted(label)++")=missing"++O.requirements(~S,requirements),app)
def ran(~S:Data,next:F.application(~S) -> String -> String,+label:String,result:N.RunResult<F.application(~S),S,String>) -> String:
  match result:
    case N.Unknown{app}:record(~S,next,"run("++O.quoted(label)++")=unknown",app)
    case N.Executed{result}:executed(~S,next,label,result)
def snapshot(~S:Data,next:F.application(~S) -> String -> String,result:F.application(~S) & Maybe<&2,N.Description<S,F.Rows()>>) -> String:
  match result:
    case (app,view):record(~S,next,"snapshot="++O.debug(~S,view),app)
def execute(~S:Data,actions:List<&2,Action<S>>,app:F.application(~S),history:String) -> String:
  match actions:
    case []:history
    case Insert{+label,plan} <> rest:inserted(~S,a => message => execute(~S,rest,a,history++message++"\n"),label,N.insert(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,label,plan))
    case Remove{+label} <> rest:looked(~S,a => message => execute(~S,rest,a,history++message++"\n"),"remove("++O.quoted(label)++")",N.remove(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,label))
    case Get{+label} <> rest:looked(~S,a => message => execute(~S,rest,a,history++message++"\n"),"get("++O.quoted(label)++")",N.get(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,label))
    case Run{+label} <> rest:ran(~S,a => message => execute(~S,rest,a,history++message++"\n"),label,N.run(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),~String,~F.dispatch(~S),~F.condition(~S),~F.provision(~S),app,label))
    case Debug{+flag} <> rest:record(~S,a => message => execute(~S,rest,a,history++message++"\n"),"debug="++O.bool_show(flag),N.enabled(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app,flag))
    case Advance{} <> rest:record(~S,a => message => execute(~S,rest,a,history++message++"\n"),"advance-clock",F.advance(~S,app))
    case FailureMode{+flag} <> rest:record(~S,a => message => execute(~S,rest,a,history++message++"\n"),"failure-mode="++O.bool_show(flag),F.mode(~S,app,flag))
    case Index{} <> rest:indexed(~S,a => message => execute(~S,rest,a,history++message++"\n"),N.index(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app))
    case Snapshot{} <> rest:snapshot(~S,a => message => execute(~S,rest,a,history++message++"\n"),N.snapshot(~S,~F.Store,~F.Resources,~Unit,~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),app))
def created(~S:Data,result:Maybe<&1,F.application(~S)>) -> String:
  match result:
    case None{}:"creation-failed\n"
    case Some{app}:execute(~S,actions(~S),app,"")
def garden(workshop:String,result:Maybe<&1,F.application(~F.Garden)>) -> IO(Unit):
  IO.print("Workshop\n"++workshop++"Garden\n"++created(~F.Garden,result))
def workshop(result:Maybe<&1,F.application(~F.Workshop)>) -> IO(Unit):
  IO.bind(Maybe<&1,F.application(~F.Garden)>,Unit,F.create(~F.Garden),value => garden(created(~F.Workshop,result),value))
def main() -> IO(Unit):
  IO.bind(Maybe<&1,F.application(~F.Workshop)>,Unit,F.create(~F.Workshop),workshop)
