import Base
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import ./fixture.bend as F
import ./observe.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

def state_snapshot(~S:Data,label:String,probes:F.Probes(~S),text:String,result:F.Application(~S) & Maybe<&2,Checked.Description<S,F.Rows()>>) -> (F.Application(~S) & F.Probes(~S)) & String:
  match result:
    case (app,view):((app,probes),label ++ text ++ "\nsnapshot=" ++ Obs.snapshot(~S,view) ++ "\n")
def state_probes(~S:Data,label:String,app:F.Application(~S),text:String,result:F.Probes(~S) & String) -> (F.Application(~S) & F.Probes(~S)) & String:
  match result:
    case (probes,observed):state_snapshot(~S,label,probes,text ++ "\nprobes=" ++ observed,F.snapshot(~S,app))
def state_app(~S:Data,label:String,probes:F.Probes(~S),result:F.Application(~S) & String) -> (F.Application(~S) & F.Probes(~S)) & String:
  match result:
    case (app,text):state_probes(~S,label,app,text,Obs.probes(~S,probes))
def state(~S:Data,label:String,app:F.Application(~S),probes:F.Probes(~S)) -> (F.Application(~S) & F.Probes(~S)) & String:state_app(~S,label,probes,Obs.app(~S,app))
def run_result(~S:Data,result:Single.RunResult<F.Application(~S),S,Error.Error<String>>) -> F.Application(~S) & String:
  match result:
    case Single.Finished{app,observations}:(app,"Finished:" ++ Obs.run_observations(observations))
    case Single.Failed{app,error,observations}:(app,"Failed:" ++ Obs.run_error(error) ++ ":" ++ Obs.run_observations(observations))
    case Single.Rejected{app}:(app,"Rejected")
    case Single.Missing{app,requirements}:(app,"AuthoredPlanMissing:" ++ Nat.show(List.length(&2,SP.Requirement<S>,requirements)))
def finished_state(~S:Data,before:String,result:(F.Application(~S) & F.Probes(~S)) & String) -> String:
  match result:
    case ((_,_),text):before ++ text

def terminal_probe(~S:Data,before:String,result:F.Application(~S) & (F.Probes(~S) & List<&2,F.ProbeResult>)) -> String:
  match result:
    case (app,(probes,results)):finished_state(~S,before ++ "final-probe-results=" ++ Obs.probe_results(results) ++ "\n",state(~S,"terminal\n",app,probes))
def second_state(~S:Data,before:String,result:(F.Application(~S) & F.Probes(~S)) & String) -> String:
  match result:
    case ((app,probes),text):terminal_probe(~S,before ++ text,F.probe(~S,app,probes))
def second_run(~S:Data,before:String,probes:F.Probes(~S),result:F.Application(~S) & String) -> String:
  match result:
    case (app,text):second_state(~S,before ++ "run2=" ++ text ++ "\n",state(~S,"after-run2\n",app,probes))
def after_first_probe(~S:Data,before:String,result:F.Application(~S) & (F.Probes(~S) & List<&2,F.ProbeResult>)) -> String:
  match result:
    case (app,(probes,results)):second_run(~S,before ++ "after-run1-probe-results=" ++ Obs.probe_results(results) ++ "\n",probes,run_result(~S,F.run(~S,app)))
def first_state(~S:Data,before:String,result:(F.Application(~S) & F.Probes(~S)) & String) -> String:
  match result:
    case ((app,probes),text):after_first_probe(~S,before ++ text,F.probe(~S,app,probes))
def first_run(~S:Data,before:String,probes:F.Probes(~S),result:F.Application(~S) & String) -> String:
  match result:
    case (app,text):first_state(~S,before ++ "run1=" ++ text ++ "\n",state(~S,"after-run1\n",app,probes))
def initial_probe(~S:Data,before:String,result:F.Application(~S) & (F.Probes(~S) & List<&2,F.ProbeResult>)) -> String:
  match result:
    case (app,(probes,results)):first_run(~S,before ++ "initial-probe-results=" ++ Obs.probe_results(results) ++ "\n",probes,run_result(~S,F.run(~S,app)))
def repeated_state(~S:Data,before:String,result:(F.Application(~S) & F.Probes(~S)) & String) -> String:
  match result:
    case ((app,probes),text):initial_probe(~S,before ++ text,F.probe(~S,app,probes))
def enabled_state(~S:Data,before:String,result:(F.Application(~S) & F.Probes(~S)) & String) -> String:
  match result:
    case ((app,probes),text):repeated_state(~S,before ++ text,state(~S,"enabled-repeat\n",app,probes))
def disabled_state(~S:Data,result:(F.Application(~S) & F.Probes(~S)) & String) -> String:
  match result:
    case ((app,probes),text):enabled_state(~S,text,state(~S,"enabled\n",F.enable(~S,app,True{}),probes))
def run(~S:Data,value:Maybe<&1,F.Application(~S)>) -> String:
  match value:
    case None{}:"creation-or-registration-refused\n"
    case Some{app}:disabled_state(~S,state(~S,"disabled\n",app,F.probes(~S)))
