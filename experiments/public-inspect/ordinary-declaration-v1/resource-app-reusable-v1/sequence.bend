import Base
import ../resource-app-observation-v1/bridge.bend as B
import ../resource-app-observation-v1/fixture.bend as C
import ./input.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
type Action is Data:
  Snapshot{}
  Enable{flag:Bool}
  Invoke{flag:Bool}
def appended(prefix:Maybe<&2,String>,text:String) -> Maybe<&2,String>:
  match prefix:
    case None{}:Some{text}
    case Some{prior}:Some{prior ++ "\n" ++ text}
def finished(prefix:Maybe<&2,String>) -> String:
  match prefix:
    case None{}:"EMPTY_SEQUENCE"
    case Some{text}:text
def snap_joined(~A:Type,next:List<(A -> A & String)> -> A -> String -> String,remaining:List<(A -> A & String)>,result:A & String) -> String:
  match result:
    case (app,text):next(remaining,app,text)
def snap(~A:Type,next:List<(A -> A & String)> -> A -> String -> String,app:A,callbacks:List<(A -> A & String)>) -> String:
  match callbacks:
    case []:"MISSING_SNAPSHOT_CALLBACK"
    case observe <> remaining:snap_joined(~A,next,remaining,observe(app))
def enabled(~A:Type,next:List<(A -> Bool -> A)> -> A -> String,app:A,flag:Bool,callbacks:List<(A -> Bool -> A)>) -> String:
  match callbacks:
    case []:"MISSING_ENABLE_CALLBACK"
    case enable <> remaining:next(remaining,enable(app,flag))
def rejected_flag(~A:Type,next:A -> String -> String,app:A,result:Array<Bool> & Bool) -> String:
  match result:
    case (_,flag):next(app,"RegistrationRejected{arg=" ++ Bool.show(flag) ++ "}")
def rejected(~A:Type,next:A -> String -> String,app:A,args:Input.Args) -> String:
  match args:
    case Input.Args{flags}:rejected_flag(~A,next,app,Array.get(Bool,flags,0))
def outcome(~A:Type,next:A -> String -> String,app:A,result:Sys.Outcome<Unit,C.Error,C.Output>) -> String:
  match result:
    case Sys.Succeeded{_,output}:next(app,C.output(output))
    case Sys.Failed{_,C.RolledBack{prior}}:next(app,"Failure{prior=" ++ U32.show(prior) ++ "}")
def invoked(~A:Type,next:A -> String -> String,result:B.RunResult<A,Input.Args,C.Error,C.Output>) -> String:
  match result:
    case B.Completed{app,result}:outcome(~A,next,app,result)
    case B.RegistrationRejected{app,args}:rejected(~A,next,app,args)
def invoke(~A:Type,next:List<(A -> Input.Args -> B.RunResult<A,Input.Args,C.Error,C.Output>)> -> A -> String -> String,app:A,flag:Bool,callbacks:List<(A -> Input.Args -> B.RunResult<A,Input.Args,C.Error,C.Output>)>) -> String:
  match callbacks:
    case []:"MISSING_INVOKE_CALLBACK"
    case call <> remaining:invoked(~A,next(remaining),call(app,Input.Args{Array.new(Bool,0n,flag)}))
# Only the opaque App type is static. Fixed test callbacks are affine runtime values,
# consumed once per corresponding action; no operational capability is duplicated.
def go(~A:Type,actions:List<&2,Action>,app:A,snapshots:List<(A -> A & String)>,enables:List<(A -> Bool -> A)>,invocations:List<(A -> Input.Args -> B.RunResult<A,Input.Args,C.Error,C.Output>)>,prefix:Maybe<&2,String>) -> String:
  match actions:
    case []:finished(prefix)
    case Snapshot{} <> rest:snap(~A,remaining=>app=>text=>go(~A,rest,app,remaining,enables,invocations,appended(prefix,text)),app,snapshots)
    case Enable{flag} <> rest:enabled(~A,remaining=>app=>go(~A,rest,app,snapshots,remaining,invocations,prefix),app,flag,enables)
    case Invoke{flag} <> rest:invoke(~A,remaining=>app=>text=>go(~A,rest,app,snapshots,enables,remaining,appended(prefix,text)),app,flag,invocations)
