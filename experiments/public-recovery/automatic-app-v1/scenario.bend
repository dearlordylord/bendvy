import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-capture-query-fields.bend as PriorApp
import ./fixture.bend as F
import ./observe.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recovery.bend as Bridge
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-access.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-component.bend as RC
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array.bend as RA

type State<S:Data> is Type:
  State{app:F.Application(~S),retry:Maybe<F.Args<S>>,text:String}
  Stopped{text:String}
def raw_snapshot(~S:Data,label:String,text:String,retry:Maybe<F.Args<S>>,view:String,index:String,value:F.Application(~S) & String) -> State<S>:
  (app,at)=value
  State{app,retry,text ++ label ++ "|debug=" ++ view ++ "|index=" ++ index ++ "|actual={" ++ at ++ "}\n"}

def indexed(~S:Data,label:String,text:String,retry:Maybe<F.Args<S>>,view:String,value:F.Application(~S) & Maybe<&2,List<&2,Access.Entry>>) -> State<S>:
  (app,index)=value
  raw_snapshot(~S,label,text,retry,view,Obs.access_view(index),Obs.app(~S,app))

def debugged(~S:Data,label:String,text:String,retry:Maybe<F.Args<S>>,value:F.Application(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Unit>>>) -> State<S>:
  (app,view)=value
  indexed(~S,label,text,retry,Obs.debug_view(~S,view),F.access_index(~S,app))

def snapshot(~S:Data,label:String,value:State<S>) -> State<S>:
  match value:
    case State{app,retry,text}:debugged(~S,label,text,retry,F.snapshot(~S,app))
    case Stopped{text}:Stopped{text}

def enabled(~S:Data,flag:Bool,value:State<S>) -> State<S>:
  match value:
    case State{app,retry,text}:State{F.enabled(~S,app,flag),retry,text}
    case Stopped{text}:Stopped{text}

def stop(~S:Data,label:String,text:String,value:F.Application(~S) & String) -> State<S>:
  (_,at)=value
  Stopped{text ++ label ++ "|actual={" ++ at ++ "}\n"}

def retry_observed(~S:Data,label:String,text:String,app:F.Application(~S),value:F.Args<S> & String) -> State<S>:
  (args,at)=value
  snapshot(~S,label ++ "|retryOwners={" ++ at ++ "}",State{app,Some{args},text})
# Reconstruct each incoming owner from the actual rollback receipt, after observation.

def recover_retry(~S:Data,label:String,text:String,app:F.Application(~S),output:F.Output,recovery:F.Recovery(~S)) -> State<S>:
  match output recovery:
    case F.Output{[],[],[],[]},Product.Owner{RC.Record{target,_,Some{component}} <> [],Product.Owner{RA.Replaced{resource} <> RA.Swapped{1,re} <> [],RA.Replaced{capture} <> RA.Swapped{1,ce} <> []}}:retry_observed(~S,label,text,app,Obs.args(~S,F.Args{target,component,resource,re,capture,ce,True{}}))
    case _,_:stop(~S,label ++ ":BUG-retry-shape",text,Obs.app(~S,app))

def outcome(~S:Data,label:String,text:String,app:F.Application(~S),value:T.Outcome<F.Error>,output:F.Output,recovery:F.Recovery(~S)) -> State<S>:
  match value:
    case T.Success{}:snapshot(~S,label ++ ":success",State{app,None{},text})
    case T.Failure{F.Failed{}}:recover_retry(~S,label ++ ":failed",text,app,output,recovery)

def completed(~S:Data,+label:String,text:String,app:F.Application(~S),value:T.Outcome<F.Error>,observedOutput:F.Output & String,observedRecovery:F.Recovery(~S) & String) -> State<S>:
  (output,ot)=observedOutput
  (recovery,rt)=observedRecovery
  outcome(~S,label,text ++ "returned:" ++ label ++ "|output={" ++ ot ++ "}|recovery={" ++ rt ++ "}\n",app,value,output,recovery)

def rejected(~S:Data,label:String,text:String,app:F.Application(~S),value:F.Args<S> & String) -> State<S>:
  (args,at)=value
  snapshot(~S,label ++ ":refused|returnedArgs={" ++ at ++ "}",State{app,Some{args},text})

def transport_observed(~S:Data,label:String,text:String,debug:Bool,value:F.World(~S) & String,prior:F.Previous(~S) & String) -> State<S>:
  (_,wt)=value
  (_,pt)=prior
  Stopped{text ++ label ++ ":BUG-transport|world={" ++ wt ++ "}|previous={" ++ pt ++ "}|debug=" ++ Bool.show(debug) ++ "\n"}

def retry_args(~S:Data,value:F.Args<S>,fail:Bool) -> F.Args<S>:
  match value:
    case F.Args{target,component,resource,re,capture,ce,_}:F.Args{target,component,resource,re,capture,ce,fail}

def finish_observed(~S:Data,text:String,value:F.Application(~S) & String) -> String:
  (_,at)=value
  text ++ "terminal|actual={" ++ at ++ "}\n"

def finish(~S:Data,value:State<S>) -> String:
  match value:
    case State{app,_,text}:finish_observed(~S,text,Obs.app(~S,app))
    case Stopped{text}:text

def define_rejected_observed(~S:Data,debug:Bool,world:F.World(~S) & String,capture:Array<Array<U32>> & String,prior:F.Previous(~S) & String) -> String:
  (_,wt)=world
  (_,ct)=capture
  (_,pt)=prior
  "BUG:define-refused|world={" ++ wt ++ "}|capture=" ++ ct ++ "|previous={" ++ pt ++ "}|debug=" ++ Bool.show(debug) ++ "\n"

def preparation_failed(~S:Data,value:F.World(~S) & String) -> String:
  (_,wt)=value
  "BUG:prepare|world={" ++ wt ++ "}\n"

def prior_rejected_observed(~S:Data,world:F.World(~S) & String,capture:Array<U32> & String,debug:Bool) -> String:
  (_,wt)=world
  (_,ct)=capture
  "BUG:prior-refused|world={" ++ wt ++ "}|capture=" ++ ct ++ "|debug=" ++ Bool.show(debug) ++ "\n"

def prior_rejected(~S:Data,app:F.Initial(~S),capture:Array<U32>) -> String:
  match app:
    case Build.Registered{world,Unit{},_,debug}:prior_rejected_observed(~S,Obs.world(~S,world),Obs.element(capture),debug)

def transport_failed(~S:Data,label:String,text:String,app:F.Before(~S)) -> State<S>:
  match app:
    case Build.Registered{world,previous,_,debug}:transport_observed(~S,label,text,debug,Obs.world(~S,world),Obs.previous(~S,previous))

def returned(~S:Data,label:String,text:String,value:F.Run(~S)) -> State<S>:
  match value:
    case Bridge.Completed{app,value,output,recovery}:completed(~S,label,text,app,value,Obs.output(output),Obs.recovery(~S,recovery))
    case Bridge.RegistrationRejected{app,args}:rejected(~S,label,text,app,Obs.args(~S,args))
    case Bridge.TransportFailed{app}:transport_failed(~S,label,text,app)

def arguments(~S:Data,+label:String,text:String,app:F.Application(~S),value:F.Args<S> & String) -> State<S>:
  (args,at)=value
  returned(~S,label,text ++ "input:" ++ label ++ "|" ++ at ++ "\n",F.run(~S,app,args))

def run_fresh(~S:Data,label:String,target:W.Handle<S>,seed:U32,fail:Bool,value:State<S>) -> State<S>:
  match value:
    case State{app,_,text}:arguments(~S,label,text,app,Obs.args(~S,F.args(~S,target,seed,fail)))
    case Stopped{text}:Stopped{text}

def retry_selected(~S:Data,label:String,fail:Bool,text:String,app:F.Application(~S),value:Maybe<F.Args<S>>) -> State<S>:
  match value:
    case Some{args}:arguments(~S,label,text,app,Obs.args(~S,retry_args(~S,args,fail)))
    case None{}:stop(~S,label ++ ":BUG-no-retry",text,Obs.app(~S,app))

def run_retry(~S:Data,label:String,fail:Bool,value:State<S>) -> State<S>:
  match value:
    case State{app,retry,text}:retry_selected(~S,label,fail,text,app,retry)
    case Stopped{text}:Stopped{text}

def sequence(~S:Data,+target:W.Handle<S>,app:F.Application(~S)) -> String:
  finish(~S,snapshot(~S,"disabled-final",enabled(~S,False{},snapshot(~S,"repeated-final",run_retry(~S,"retry-success",False{},run_fresh(~S,"failed",target,200,True{},run_fresh(~S,"commit",target,100,False{},snapshot(~S,"enabled-repeated",snapshot(~S,"enabled-first",enabled(~S,True{},snapshot(~S,"registered-disabled",State{app,None{},""})))))))))))

def define_rejected(~S:Data,app:F.Before(~S),capture:Array<Array<U32>>) -> String:
  match app:
    case Build.Registered{world,previous,_,debug}:define_rejected_observed(~S,debug,Obs.world(~S,world),Obs.array(capture),Obs.previous(~S,previous))

def defined(~S:Data,target:W.Handle<S>,value:Bridge.Appended<F.Before(~S),F.Application(~S),Array<Array<U32>>>) -> String:
  match value:
    case Bridge.Appended{app}:sequence(~S,target,app)
    case Bridge.AppendRejected{app,capture}:define_rejected(~S,app,capture)

def prior_registered(~S:Data,target:W.Handle<S>,value:PriorApp.Appended<F.Initial(~S),F.Before(~S),Array<U32>>) -> String:
  match value:
    case PriorApp.Appended{app}:defined(~S,target,F.define(~S,app,F.array(700)))
    case PriorApp.AppendRejected{app,capture}:prior_rejected(~S,app,capture)

def populated(~S:Data,target:W.Handle<S>,value:RC.Replacement<F.World(~S),S,Array<Array<U32>>>) -> String:
  match value:
    case RC.Applied{world,_}:prior_registered(~S,target,F.previous_register(~S,Build.empty(~S,~F.World(~S),world),F.pair(600)))
    case RC.Refused{world,_,_}:preparation_failed(~S,Obs.world(~S,world))

def activated(~S:Data,+target:W.Handle<S>,value:F.World(~S) & W.Status) -> String:
  match value:
    case (world,W.Accepted{}):populated(~S,target,RC.replace(~S,~Array<Array<U32>>,~F.Resources(),~Unit,"Payload",world,target,Some{F.array(10)}))
    case (world,_):preparation_failed(~S,Obs.world(~S,world))

def reserved(~S:Data,value:F.World(~S) & W.Reservation<S>) -> String:
  match value:
    case (world,W.Reserved{+target}):activated(~S,target,W.activate(~S,~F.Store(~S),~F.Resources(),~Unit,world,target))
    case (world,_):preparation_failed(~S,Obs.world(~S,world))

def start(~S:Data,world:F.World(~S)) -> String:
  reserved(~S,W.reserve_id(~S,~F.Store(~S),~F.Resources(),~Unit,world))
