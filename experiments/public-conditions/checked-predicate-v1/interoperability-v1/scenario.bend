import Base
import fixture.bend as F
import observe.bend as Obs
import /tmp/bendvy-checked-predicate/experiments/public-conditions/checked-predicate-v1/observe.bend as Prior
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

type State<S:Data> is Type:State{app:F.Application(~S),text:String}
def snapshot_returned(~S:Data,label:String,before:String,text:String,result:F.Application(~S) & Maybe<&2,Checked.Description<S,F.Rows()>>) -> State<S>:
  (app,view)=result
  State{app,before ++ label ++ "|" ++ text ++ "\nsnapshot=" ++ Obs.snapshot(~S,view) ++ "\n"}
def observed(~S:Data,label:String,before:String,result:F.Application(~S) & String) -> State<S>:
  (app,text)=result
  snapshot_returned(~S,label,before,text,F.snapshot(~S,app))
def snapshot(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{app,text}:observed(~S,label,text,Obs.app(~S,app))
def ran(~S:Data,label:String,before:String,result:Single.RunResult<F.Application(~S),S,Error.Error<String>>) -> State<S>:
  match result:
    case Single.Finished{app,observations}:snapshot(~S,label ++ ":Finished:" ++ Prior.run_observations(observations),State{app,before})
    case Single.Failed{app,error,observations}:snapshot(~S,label ++ ":Failed:" ++ Prior.run_error(error) ++ ":" ++ Prior.run_observations(observations),State{app,before})
    case Single.Rejected{app}:snapshot(~S,label ++ ":Rejected",State{app,before})
    case Single.Missing{app,requirements}:snapshot(~S,label ++ ":Missing:" ++ List.show(&2,SP.Requirement<S>,Prior.requirement(~S),requirements),State{app,before})
def run(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{app,text}:ran(~S,label,text,F.run(~S,app))
def insert(~S:Data,+value:U32,state:State<S>) -> State<S>:
  match state:
    case State{app,text}:snapshot(~S,"insert:" ++ U32.show(value),State{F.insert_app(~S,app,value),text})
def enabled(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{app,text}:snapshot(~S,"enabled",State{F.enabled(~S,app,True{}),text})
def removed(~S:Data,text:String,result:F.Application(~S) & Bool) -> State<S>:
  (app,removed)=result
  snapshot(~S,"remove-actual-condition:" ++ Bool.show(removed),State{app,text})
def stale(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{app,text}:removed(~S,text,F.stale(~S,app))
def finish(~S:Data,state:State<S>) -> String:
  match state:
    case State{_,text}:text
def sequence(~S:Data,app:F.Application(~S)) -> String:
  finish(~S,run(~S,"stale-lifted-registration",stale(~S,run(~S,"changed-again",insert(~S,1,run(~S,"unchanged-A-skips-B-runs",run(~S,"changed-A-and-B",insert(~S,0,run(~S,"missing-machine-A-skips-B-runs",enabled(~S,snapshot(~S,"disabled",State{app,""})))))))))))
def start(~S:Data,value:Maybe<&1,F.Application(~S)>) -> String:
  match value:
    case None{}:"registration-refused\n"
    case Some{app}:sequence(~S,app)
