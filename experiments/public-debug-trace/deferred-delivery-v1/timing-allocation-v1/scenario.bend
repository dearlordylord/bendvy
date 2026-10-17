import Base
import ../reader-query-context-v1/fixture.bend as F
import ../reader-query-context-v1/scenario.bend as Scene
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/checked-condition-schedule.bend as Engine

def step_20(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"after-reset-empty-read",state),Scene.terminal(~S))
def step_19(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.reset(~S,state),step_20(~S,~mode))
def step_18(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"enabled-empty-read",Scene.enabled(~S,state,mode)),step_19(~S,~mode))
def step_17(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"disabled-read",Scene.guarded(~S,state,True{})),step_18(~S,~mode))
def step_16(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"disabled-skip",state),step_17(~S,~mode))
def step_15(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.publish(~S,"publish-fifty",Scene.guarded(~S,state,False{}),50),step_16(~S,~mode))
def step_14(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.checkpoint(~S,"disabled",Scene.enabled(~S,state,mode)),step_15(~S,~mode))
def step_13(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"retry-returned-args",Scene.failing(~S,state,False{})),step_14(~S,~mode))
def step_12(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"semantic-failure",Scene.failing(~S,state,True{})),step_13(~S,~mode))
def step_11(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.publish(~S,"publish-forty",state,40),step_12(~S,~mode))
def step_10(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"lagged-read",Scene.guarded(~S,state,True{})),step_11(~S,~mode))
def step_9(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"false-unread",state),step_10(~S,~mode))
def step_8(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.frame(~S,"frame-thirty",state),step_9(~S,~mode))
def step_7(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.publish(~S,"publish-thirty",state,30),step_8(~S,~mode))
def step_6(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.frame(~S,"frame-twenty",state),step_7(~S,~mode))
def step_5(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.publish(~S,"publish-twenty",Scene.guarded(~S,state,False{}),20),step_6(~S,~mode))
def step_4(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"first-read",Scene.guarded(~S,state,True{})),step_5(~S,~mode))
def step_3(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.perform(~S,"false-before-read",state),step_4(~S,~mode))
def step_2(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.publish(~S,"publish-ten",state,10),step_3(~S,~mode))
def step_1(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.checkpoint(~S,"enabled",Scene.enabled(~S,state,mode)),step_2(~S,~mode))
def step_0(~S:Data,~mode:Bool,state:Scene.State<S>) -> String:Scene.chain(~S,Scene.checkpoint(~S,"initial",state),step_1(~S,~mode))
def run_mode(~S:Data,~mode:Bool,value:F.SetupResult<S>) -> String:
  match value:
    case F.Ready{app}:step_0(~S,~mode,Scene.State{F.enabled(~S,app,mode),Trace.subscribe(~F.Collector,~Engine.Error<String>,~F.step,F.collector(100,200)),[],[],[]})
    case value:Scene.rejected(~S,value)
