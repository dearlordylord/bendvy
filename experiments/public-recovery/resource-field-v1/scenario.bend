import Base
import ./fixture.bend as F
import ./observe.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array.bend as A

type State<S:Data> is Type:
  State{world:F.World(~S),owner:F.Owned(~S),retry:Maybe<F.Args>,text:String}
  Stopped{text:String}
def status(value:T.Outcome<F.Error>) -> String:
  match value:
    case T.Success{}:"success"
    case T.Failure{F.Failed{}}:"failed"
def observed(~S:Data,label:String,text:String,retry:Maybe<F.Args>,observedWorld:F.World(~S) & String,observedOwner:F.Owned(~S) & String) -> State<S>:
  (world,wt)=observedWorld
  (owner,ot)=observedOwner
  State{world,owner,retry,text ++ label ++ "|world={" ++ wt ++ "}|owner={" ++ ot ++ "}\n"}
def snapshot(~S:Data,label:String,value:State<S>) -> State<S>:
  match value:
    case State{world,owner,retry,text}:observed(~S,label,text,retry,Obs.world(~S,world),Obs.owned(~S,owner))
    case Stopped{text}:Stopped{text}
def stop(~S:Data,label:String,text:String,world:F.World(~S) & String,owner:F.Owned(~S) & String) -> State<S>:
  (_,wt)=world
  (_,ot)=owner
  Stopped{text ++ label ++ "|world={" ++ wt ++ "}|owner={" ++ ot ++ "}\n"}
def retry_observed(~S:Data,label:String,text:String,world:F.World(~S),owner:F.Owned(~S),value:F.Args & String) -> State<S>:
  (args,at)=value
  snapshot(~S,label ++ "|retryOwners={" ++ at ++ "}",State{world,owner,Some{args},text})
# These are the actual rollback records and rejected input owners, not new values.
def recover_retry(~S:Data,label:String,text:String,world:F.World(~S),owner:F.Owned(~S),output:F.Output,recovery:F.Recovery()) -> State<S>:
  match output recovery:
    case F.Output{[],[rejected]}, A.Replaced{first} <> A.Swapped{1,element} <> A.Replaced{second} <> []:retry_observed(~S,label,text,world,owner,Obs.args(F.Args{first,element,second,rejected,True{}}))
    case _, _:stop(~S,label ++ ":BUG-retry-shape",text,Obs.world(~S,world),Obs.owned(~S,owner))
def completed_outcome(~S:Data,label:String,text:String,world:F.World(~S),owner:F.Owned(~S),outcome:T.Outcome<F.Error>,output:F.Output,recovery:F.Recovery()) -> State<S>:
  match outcome:
    case T.Success{}:snapshot(~S,label ++ ":success",State{world,owner,None{},text})
    case T.Failure{F.Failed{}}:recover_retry(~S,label ++ ":failed",text,world,owner,output,recovery)
# Returned owners are fully observed before either reconstruction or explicit release.
def completed(~S:Data,+label:String,text:String,world:F.World(~S),owner:F.Owned(~S),outcome:T.Outcome<F.Error>,observedOutput:F.Output & String,observedRecords:F.Recovery() & String) -> State<S>:
  (output,ot)=observedOutput
  (recovery,rt)=observedRecords
  completed_outcome(~S,label,text ++ "returned:" ++ label ++ "|output={" ++ ot ++ "}|recovered={" ++ rt ++ "}\n",world,owner,outcome,output,recovery)
def rejected(~S:Data,label:String,text:String,world:F.World(~S),owner:F.Owned(~S),observedArgs:F.Args & String) -> State<S>:
  (args,at)=observedArgs
  snapshot(~S,label ++ ":refused|returnedArgs={" ++ at ++ "}",State{world,owner,Some{args},text})
def unexpected_transport(~S:Data,label:String,text:String,value:F.World(~S) & String) -> State<S>:
  (_,wt)=value
  Stopped{text ++ label ++ ":BUG-transport|world={" ++ wt ++ "}\n"}
def returned(~S:Data,label:String,text:String,value:System.Run<F.World(~S),F.Owned(~S),F.Args,F.Error,F.Output,F.Recovery()>) -> State<S>:
  match value:
    case System.Completed{world,owner,outcome,output,recovery}:completed(~S,label,text,world,owner,outcome,Obs.output(output),Obs.records(recovery))
    case System.RegistrationRejected{world,owner,args}:rejected(~S,label,text,world,owner,Obs.args(args))
    case System.TransportFailed{world}:unexpected_transport(~S,label,text,Obs.world(~S,world))
def arguments(~S:Data,+label:String,text:String,owner:F.Owned(~S),world:F.World(~S),observedArgs:F.Args & String) -> State<S>:
  (args,at)=observedArgs
  returned(~S,label,text ++ "input:" ++ label ++ "|" ++ at ++ "\n",F.run(~S,owner,world,args))
def run_fresh(~S:Data,label:String,seed:U32,fail:Bool,value:State<S>) -> State<S>:
  match value:
    case State{world,owner,_,text}:arguments(~S,label,text,owner,world,Obs.args(F.args(seed,fail)))
    case Stopped{text}:Stopped{text}
def retry_args(value:F.Args,fail:Bool) -> F.Args:
  match value:
    case F.Args{first,element,second,rejected,_}:F.Args{first,element,second,rejected,fail}
def selected_retry(~S:Data,label:String,fail:Bool,text:String,owner:F.Owned(~S),world:F.World(~S),value:Maybe<F.Args>) -> State<S>:
  match value:
    case Some{args}:arguments(~S,label,text,owner,world,Obs.args(retry_args(args,fail)))
    case None{}:stop(~S,label ++ ":BUG-no-retry",text,Obs.world(~S,world),Obs.owned(~S,owner))
def run_retry(~S:Data,label:String,fail:Bool,value:State<S>) -> State<S>:
  match value:
    case State{world,owner,retry,text}:selected_retry(~S,label,fail,text,owner,world,retry)
    case Stopped{text}:Stopped{text}
def finish_observed(~S:Data,text:String,world:F.World(~S) & String,owner:F.Owned(~S) & String) -> String:
  (_,wt)=world
  (_,ot)=owner
  text ++ "terminal|world={" ++ wt ++ "}|owner={" ++ ot ++ "}\n"
def finish(~S:Data,value:State<S>) -> String:
  match value:
    case State{world,owner,_,text}:finish_observed(~S,text,Obs.world(~S,world),Obs.owned(~S,owner))
    case Stopped{text}:text
def sequence(~S:Data,value:State<S>) -> String:
  finish(~S,run_retry(~S,"retry-success",False{},run_retry(~S,"retry-failed",True{},run_fresh(~S,"failed",200,True{},run_fresh(~S,"commit",100,False{},snapshot(~S,"registered",value))))))
def definition_refused(~S:Data,world:F.World(~S) & String,capture:Array<U32> & String) -> String:
  (_,wt)=world
  (_,ct)=capture
  "BUG:definition-refused|world={" ++ wt ++ "}|capture=" ++ ct ++ "\n"
def defined(~S:Data,value:System.Defined<F.World(~S),F.Owned(~S),Array<U32>>) -> String:
  match value:
    case System.Defined{world,owner}:sequence(~S,State{world,owner,None{},""})
    case System.DefinitionRejected{world,capture}:definition_refused(~S,Obs.world(~S,world),Obs.element(capture))
def start(~S:Data,world:F.World(~S)) -> String:
  defined(~S,F.define(~S,world,F.pair(700)))
