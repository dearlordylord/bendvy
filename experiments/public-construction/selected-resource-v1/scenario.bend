import Base
import ./fixture.bend as F
import ./setup.bend as Setup
import ./observe.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App

type Session<S:Data> is Type:Session{app:F.Application(~S),context:F.Context<S>,inputs:List<F.Input<S>>,outputs:List<F.Output<S>>}
type Action is Data:Checkpoint{label:String} Enable{} Invalid{} Constructor{} Admission{} Undo{} Retry{}
def inputs_cons(~S:Data,head:F.Input<S>,text:String,value:List<F.Input<S>> & String) -> List<F.Input<S>> & String:
  match value:
    case (tail,more):(head <> tail,text ++ ";" ++ more)
def inputs_both(~S:Data,head:F.Input<S> & String,tail:List<F.Input<S>> & String) -> List<F.Input<S>> & String:
  match head:
    case (owner,text):inputs_cons(~S,owner,text,tail)
def observe_inputs(~S:Data,value:List<F.Input<S>>) -> List<F.Input<S>> & String:
  match value:
    case []:([],"[]")
    case head <> tail:inputs_both(~S,Obs.input(~S,head),observe_inputs(~S,tail))
def outputs_cons(~S:Data,head:F.Output<S>,text:String,value:List<F.Output<S>> & String) -> List<F.Output<S>> & String:
  match value:
    case (tail,more):(head <> tail,text ++ ";" ++ more)
def outputs_both(~S:Data,head:F.Output<S> & String,tail:List<F.Output<S>> & String) -> List<F.Output<S>> & String:
  match head:
    case (owner,text):outputs_cons(~S,owner,text,tail)
def observe_outputs(~S:Data,value:List<F.Output<S>>) -> List<F.Output<S>> & String:
  match value:
    case []:([],"[]")
    case head <> tail:outputs_both(~S,Obs.output(~S,head),observe_outputs(~S,tail))
def state_snapshot(~S:Data,context:F.Context<S>,inputs:List<F.Input<S>>,outputs:List<F.Output<S>>,text:String,value:F.Application(~S) & Maybe<&2,App.Description<S,F.Rows()>>) -> Session<S> & String:
  match value:
    case (app,view):(Session{app,context,inputs,outputs},text ++ "\nsnapshot=" ++ Obs.snapshot(~S,view) ++ "\n")
def state_outputs(~S:Data,app:F.Application(~S),context:F.Context<S>,inputs:List<F.Input<S>>,text:String,value:List<F.Output<S>> & String) -> Session<S> & String:
  match value:
    case (outputs,rendered):state_snapshot(~S,context,inputs,outputs,text ++ "\noutputs=" ++ rendered,F.snapshot(~S,app))
def state_inputs(~S:Data,app:F.Application(~S),context:F.Context<S>,outputs:List<F.Output<S>>,text:String,value:List<F.Input<S>> & String) -> Session<S> & String:
  match value:
    case (inputs,rendered):state_outputs(~S,app,context,inputs,text ++ "\ninputs=" ++ rendered,observe_outputs(~S,outputs))
def state_app(~S:Data,+context:F.Context<S>,inputs:List<F.Input<S>>,outputs:List<F.Output<S>>,label:String,value:F.Application(~S) & String) -> Session<S> & String:
  match value:
    case (app,text):state_inputs(~S,app,context,outputs,label ++ "\ncontext=" ++ Obs.context(~S,context) ++ "\napp=" ++ text,observe_inputs(~S,inputs))
def state(~S:Data,label:String,value:Session<S>) -> Session<S> & String:
  match value:
    case Session{app,context,inputs,outputs}:state_app(~S,context,inputs,outputs,label,Obs.app(~S,app))
def returned(~S:Data,context:F.Context<S>,inputs:List<F.Input<S>>,outputs:List<F.Output<S>>,value:F.Run<S>) -> Session<S> & String:
  match value:
    case F.Completed{app,output}:(Session{app,context,inputs,output <> outputs},"Completed\n")
    case F.Failed{app,_}:(Session{app,context,inputs,outputs},"SystemFailed\n")
    case F.Rejected{app,F.Args{_,input}}:(Session{app,context,input <> inputs,outputs},"RegistrationRejected\n")
def dispatch(~S:Data,app:F.Application(~S),+context:F.Context<S>,inputs:List<F.Input<S>>,outputs:List<F.Output<S>>,input:F.Input<S>) -> Session<S> & String:returned(~S,context,inputs,outputs,F.run(~S,app,F.Args{context,input}))
def undo(~S:Data,app:F.Application(~S),context:F.Context<S>,inputs:List<F.Input<S>>,outputs:List<F.Output<S>>) -> Session<S> & String:
  match outputs:
    case F.AdmissionRefused{cooked,undo,_} <> tail:(Session{app,context,undo(cooked) <> inputs,tail},"ActualUndoApplied\n")
    case outputs:(Session{app,context,inputs,outputs},"UnexpectedUndoShape\n")
def retry_input(~S:Data,value:F.Input<S>) -> F.Input<S>:
  match value:
    case F.Input{raw,_,owned}:F.Input{raw,F.Valid{},owned}
def retry(~S:Data,app:F.Application(~S),context:F.Context<S>,inputs:List<F.Input<S>>,outputs:List<F.Output<S>>) -> Session<S> & String:
  match inputs:
    case input <> tail:dispatch(~S,app,context,tail,outputs,retry_input(~S,input))
    case []:(Session{app,context,[],outputs},"UnexpectedRetryShape\n")
def action(~S:Data,step:Action,value:Session<S>) -> Session<S> & String:
  match step value:
    case Checkpoint{label} value:state(~S,label,value)
    case Enable{} Session{app,context,inputs,outputs}:(Session{F.enabled(~S,app,True{}),context,inputs,outputs},"Enabled\n")
    case Invalid{} Session{app,+context,inputs,outputs}:dispatch(~S,app,context,inputs,outputs,Setup.invalid_input(~S,context,ANode{ALeaf{10},ALeaf{11}}))
    case Constructor{} Session{app,+context,inputs,outputs}:dispatch(~S,app,context,inputs,outputs,Setup.input(~S,context,20,F.ConstructorReject{},ANode{ALeaf{20},ALeaf{21}}))
    case Admission{} Session{app,+context,inputs,outputs}:dispatch(~S,app,context,inputs,outputs,Setup.input(~S,context,30,F.AdmissionReject{},ANode{ALeaf{30},ALeaf{31}}))
    case Undo{} Session{app,context,inputs,outputs}:undo(~S,app,context,inputs,outputs)
    case Retry{} Session{app,context,inputs,outputs}:retry(~S,app,context,inputs,outputs)
def continued(~S:Data,next:Session<S> -> String,value:Session<S> & String) -> String:
  match value:
    case (session,text):text ++ next(session)
def actions(~S:Data,steps:List<&2,Action>,session:Session<S>) -> String:
  match steps:
    case []:""
    case step <> tail:continued(~S,(session=>actions(~S,tail,session)),action(~S,step,session))
def program() -> List<&2,Action>:[Checkpoint{"disabled"},Enable{},Checkpoint{"enabled"},Invalid{},Checkpoint{"invalid-input-returned"},Constructor{},Checkpoint{"constructor-refused-input-returned"},Admission{},Checkpoint{"stored-admission-refused-cooked-before-undo"},Undo{},Checkpoint{"actual-original-input-after-undo"},Retry{},Checkpoint{"actual-returned-owner-retry-success"},Checkpoint{"terminal-repeat-snapshot"}]
def registered(~S:Data,context:F.Context<S>,value:Maybe<&1,F.Application(~S)>) -> String:
  match value:
    case None{}:"registration-refused\n"
    case Some{app}:actions(~S,program(),Session{app,context,[],[]})
def prepared(~S:Data,value:F.World(~S) & F.Context<S>) -> String:
  match value:
    case (world,context):registered(~S,context,F.register(~S,world))
def run(~S:Data,world:F.World(~S)) -> String:prepared(~S,Setup.prepare(~S,world))
