import Base
import ./fixture.bend as F
import ./observe.bend as Obs
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/ordinary-recoverable-array-resource.bend as O
import ../../../src/ecs/recoverable-array.bend as A
import ../../../src/ecs/transaction.bend as T
type State<S:Data> is Type:
  State{world:W.World<S,Unit,Array<Array<U32>>,Unit>,foreign:W.World<S,Unit,Array<Array<U32>>,Unit>,registry:F.Registry(~S),foreignRegistry:F.Registry(~S),text:String}
def status(value:T.Outcome<F.Error>) -> String:
  match value:
    case T.Success{}:"success"
    case T.Failure{F.Failed{}}:"failed"
def observed(~S:Data,label:String,text:String,a:W.World<S,Unit,Array<Array<U32>>,Unit> & String,b:W.World<S,Unit,Array<Array<U32>>,Unit> & String,c:F.Registry(~S) & String,d:F.Registry(~S) & String) -> State<S>:
  match a b c d:
    case (world,wt),(foreign,ft),(registry,rt),(foreignRegistry,frt):State{world,foreign,registry,foreignRegistry,text ++ label ++ "|" ++ wt ++ "|" ++ ft ++ "|" ++ rt ++ "|" ++ frt ++ "\n"}
def snapshot(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,registry,foreignRegistry,text}:observed(~S,label,text,Obs.world(~S,world),Obs.world(~S,foreign),Obs.registry(~S,registry),Obs.registry(~S,foreignRegistry))
# The caller observes every returned owner before explicitly releasing it here.
def completed(~S:Data,label:String,state:State<S>,out:F.Output & String,records:List<A.Record<Array<U32>>> & String) -> State<S>:
  match out records:
    case (_,otext),(_,rtext):snapshot(~S,label ++ "|returned=" ++ otext ++ "|recovered=" ++ rtext,state)
def refused(~S:Data,label:String,state:State<S>,args:F.Args & String) -> State<S>:
  match args:
    case (_,text):snapshot(~S,label ++ "|args-returned=" ++ text,state)
def returned(~S:Data,label:String,foreign:W.World<S,Unit,Array<Array<U32>>,Unit>,foreignRegistry:F.Registry(~S),text:String,result:O.Run<W.World<S,Unit,Array<Array<U32>>,Unit>,F.Registry(~S),F.Args,F.Error,F.Output,Array<U32>>) -> State<S>:
  match result:
    case O.Completed{world,registry,outcome,output,recovered}:completed(~S,label ++ ":" ++ status(outcome),State{world,foreign,registry,foreignRegistry,text},Obs.output(output),Obs.records(recovered))
    case O.RegistrationRejected{world,registry,args}:refused(~S,label ++ ":refused",State{world,foreign,registry,foreignRegistry,text},Obs.args(args))
    case O.TransportFailed{world,registry}:snapshot(~S,label ++ ":BUG-transport",State{world,foreign,registry,foreignRegistry,text})
def arguments(~S:Data,+label:String,state:State<S>,args:F.Args & String) -> State<S>:
  match state args:
    case State{world,foreign,registry,foreignRegistry,text},(args,at):returned(~S,label,foreign,foreignRegistry,text ++ "input:" ++ label ++ "|" ++ at ++ "\n",F.run(~S,registry,world,args))
def run(~S:Data,label:String,seed:U32,fail:Bool,state:State<S>) -> State<S>:
  arguments(~S,label,state,Obs.args(F.args(seed,fail)))
def foreign_returned(~S:Data,world:W.World<S,Unit,Array<Array<U32>>,Unit>,foreignRegistry:F.Registry(~S),text:String,result:O.Run<W.World<S,Unit,Array<Array<U32>>,Unit>,F.Registry(~S),F.Args,F.Error,F.Output,Array<U32>>) -> State<S>:
  match result:
    case O.RegistrationRejected{foreign,registry,args}:refused(~S,"foreign:refused",State{world,foreign,registry,foreignRegistry,text},Obs.args(args))
    case O.Completed{foreign,registry,outcome,output,recovered}:completed(~S,"BUG:foreign-entered:" ++ status(outcome),State{world,foreign,registry,foreignRegistry,text},Obs.output(output),Obs.records(recovered))
    case O.TransportFailed{foreign,registry}:snapshot(~S,"BUG:foreign-transport",State{world,foreign,registry,foreignRegistry,text})
def foreign_arguments(~S:Data,state:State<S>,args:F.Args & String) -> State<S>:
  match state args:
    case State{world,foreign,registry,foreignRegistry,text},(args,at):foreign_returned(~S,world,foreignRegistry,text ++ "input:foreign|" ++ at ++ "\n",F.run(~S,registry,foreign,args))
def finish(~S:Data,state:State<S>) -> String:
  match state:
    case State{_,_,_,_,text}:text
def sequence(~S:Data,state:State<S>) -> String:
  finish(~S,foreign_arguments(~S,run(~S,"retry-success",400,False{},run(~S,"retry-failed",300,True{},run(~S,"failed",200,True{},run(~S,"commit",100,False{},snapshot(~S,"registered",state))))),Obs.args(F.args(500,False{}))))
def foreign_defined(~S:Data,world:W.World<S,Unit,Array<Array<U32>>,Unit>,registry:F.Registry(~S),result:Sys.RegistrationResult<S,Unit,Array<Array<U32>>,Unit,F.Args,Unit,O.Reply<F.Error,F.Output,Array<U32>>,O.runner(~S,~Unit,~Array<U32>,~Unit,~F.identity(~S),~F.Args,~F.Error,~F.Output,~F.body(~S))>) -> String:
  match result:
    case Sys.Registered{foreign,foreignRegistry}:sequence(~S,State{world,foreign,registry,foreignRegistry,""})
    case _:"BUG:foreign-register"
def defined(~S:Data,foreign:W.World<S,Unit,Array<Array<U32>>,Unit>,result:Sys.RegistrationResult<S,Unit,Array<Array<U32>>,Unit,F.Args,Unit,O.Reply<F.Error,F.Output,Array<U32>>,O.runner(~S,~Unit,~Array<U32>,~Unit,~F.identity(~S),~F.Args,~F.Error,~F.Output,~F.body(~S))>) -> String:
  match result:
    case Sys.Registered{world,registry}:foreign_defined(~S,world,registry,F.define(~S,foreign))
    case _:"BUG:register"
def start(~S:Data,world:W.World<S,Unit,Array<Array<U32>>,Unit>,foreign:W.World<S,Unit,Array<Array<U32>>,Unit>) -> String:
  defined(~S,foreign,F.define(~S,world))
