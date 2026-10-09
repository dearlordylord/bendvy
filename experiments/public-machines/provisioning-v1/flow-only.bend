import Base
import initial.bend as Init
import requirements.bend as Req
import declared.bend as D
import scene/provider.bend as P
import scene/stream.bend as St
import scene/observe.bend as O
import ../../../../../bendvy/src/ecs/machine.bend as M
import ../../../../../bendvy/src/ecs/world.bend as W
import ../../../../../bendvy/src/ecs/system.bend as Sys

# One ordinary typed machine declaration drives both requirement and registration.
type Declaration<S: Data> is Data:
  Declaration{family: M.Family<S,P.FlowToken,P.Flow,W.World<S,P.Store<S>,P.Resources<S>,Unit>,(w => P.flow_take(~S,w)),(w => slot => P.flow_put(~S,w,slot))>,name: String}
def declaration(~S: Data) -> Declaration<S>:
  Declaration{M.Family{"Flow"},"flow-only"}
def needs(~S: Data,_: Declaration<S>) -> Req.Requirements<S,D.Token<S>>:
  Req.Requirements{[D.Flow{}]}
def access(~S: Data,declared: Declaration<S>) -> List<&2,String>:
  match declared:
    case Declaration{M.Family{name},_}: ["machine." ++ name ++ ".read"]
def read_taken(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & M.Slot<S,P.FlowToken,P.Flow>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,M.CurrentView<S,P.FlowToken,P.Flow>>:
  match pair:
    case (world,slot): Sys.Succeeded{world,M.current_view(~S,~P.FlowToken,~P.Flow,slot)}
def runner(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,_: Unit) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,M.CurrentView<S,P.FlowToken,P.Flow>>:
  read_taken(~S,P.flow_take(~S,world))

type Run<S: Data> is Type:
  Returned{registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,status: String}
  Rejected{registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,args: Unit}
def completed(~S: Data,result: Sys.RunResult<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>) -> Run<S>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,M.Current{value}}}: Returned{registry,world,"current:" ++ O.flow(value)}
    case Sys.Completed{registry,Sys.Succeeded{world,M.Unavailable{}}}: Returned{registry,world,"unexpected-unavailable"}
    case Sys.Completed{registry,Sys.Failed{world,error}}: Returned{registry,world,"body-failed:" ++ error}
    case Sys.RegistrationRejected{registry,world,args}: Rejected{registry,world,args}
def checked(~S: Data,value: Req.Checked<S,D.Token<S>,Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>,W.World<S,P.Store<S>,P.Resources<S>,Unit>>) -> Run<S>:
  match value:
    case Req.Missing{registry,world,_}: Returned{registry,world,"required-flow-missing"}
    case Req.Ready{registry,world}: completed(~S,Sys.run_tracked(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Unit,~String,~M.CurrentView<S,P.FlowToken,P.Flow>,~(w => u => runner(~S,w,u)),registry,world,Unit{}))
def run_if(~S: Data,enabled: Bool,declared: Declaration<S>,registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Run<S>:
  match enabled:
    case False{}: Returned{registry,world,"gate-skipped"}
    case True{}: checked(~S,Req.preflight(~S,~D.Token<S>,~P.ConditionEnv<S>,~Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~(w => D.inspect(~S,w)),~(key => env => D.present(~S,key,env)),needs(~S,declared),registry,world))

# Fixture reports retain the actual registry and arbitrary Type world at each step.
type Observed<S: Data> is Type:
  Observed{registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,rows: List<&2,String>}
def registry_view(~S: Data,registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>) -> Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))> & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:
      (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,O.text,access) ++ ":" ++ U32.show(cursor))
def joined(~S: Data,label: String,status: String,rows: List<&2,String>,a: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))> & String,b: W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> Observed<S>:
  (registry,description)=a
  (world,body)=b
  Observed{registry,world,List.append(&2,String,rows,[label ++ "|" ++ status ++ "|" ++ body ++ ";flowRegistry=" ++ description])}
def snapshot(~S: Data,label: String,status: String,current: Observed<S>) -> Observed<S>:
  match current:
    case Observed{registry,world,rows}: joined(~S,label,status,rows,registry_view(~S,registry),O.world(~S,world))
def observed(~S: Data,label: String,rows: List<&2,String>,result: Run<S>) -> Observed<S>:
  match result:
    case Returned{registry,world,status}: snapshot(~S,label,status,Observed{registry,world,rows})
    case Rejected{registry,world,_}: snapshot(~S,label,"registration-rejected",Observed{registry,world,rows})
def step(~S: Data,label: String,enabled: Bool,current: Observed<S>) -> Observed<S>:
  match current:
    case Observed{registry,world,rows}: observed(~S,label,rows,run_if(~S,enabled,declaration(~S),registry,world))

type Delivered<S: Data> is Type:
  Delivered{factory: W.Factory,observed: Observed<S>,incoming: Maybe<&2,P.Flow>}
  RegistrationFailed{factory: W.Factory,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
  CreationFailed{factory: W.Factory,resource: P.Resources<S>}
def initialized(~S: Data,factory: W.Factory,registry: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>,rows: List<&2,String>,result: Init.Installation<W.World<S,P.Store<S>,P.Resources<S>,Unit>,P.Flow>) -> Delivered<S>:
  match result:
    case Init.Occupied{world,incoming}: Delivered{factory,snapshot(~S,"install","private-occupied",Observed{registry,world,rows}),Some{incoming}}
    case Init.Installed{world}:
      Delivered{factory,step(~S,"flow-only-level-absent",True{},snapshot(~S,"install","ok",Observed{registry,world,rows})),None{}}
def install(~S: Data,factory: W.Factory,current: Observed<S>) -> Delivered<S>:
  match current:
    case Observed{registry,world,rows}:
      initialized(~S,factory,registry,rows,Init.install_empty(~S,~P.FlowToken,~P.Flow,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~(w => P.flow_take(~S,w)),~(w => slot => P.flow_put(~S,w,slot)),M.Family{"Flow"},world,P.Boot{}))
def registered(~S: Data,factory: W.Factory,result: Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,Unit,Unit,String,M.CurrentView<S,P.FlowToken,P.Flow>,(w => u => runner(~S,w,u))>) -> Delivered<S>:
  match result:
    case Sys.RegistrationFailed{world}: RegistrationFailed{factory,world}
    case Sys.Registered{world,registry}:
      current=snapshot(~S,"registered-missing","ok",Observed{registry,world,[]})
      current=step(~S,"false-gate-missing",False{},current)
      install(~S,factory,step(~S,"required-flow-missing",True{},current))
def declared_registered(~S: Data,factory: W.Factory,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+declared: Declaration<S>) -> Delivered<S>:
  match declared:
    case Declaration{family,+name}:
      registered(~S,factory,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Unit,~String,~M.CurrentView<S,P.FlowToken,P.Flow>,~(w => u => runner(~S,w,u)),world,name,access(~S,Declaration{family,name})))
def created(~S: Data,result: W.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> Delivered<S>:
  match result:
    case W.CreateRejected{factory,resource}: CreationFailed{factory,resource}
    case W.Created{factory,world}: declared_registered(~S,factory,world,declaration(~S))
def resources(~S: Data) -> P.Resources<S>:
  P.Resources{ANode{ALeaf{30},ALeaf{130}},M.Missing{},M.Missing{},St.empty(~P.Flow),St.empty(~P.Level),0n,0n,[]}
def scenario(~S: Data) -> Delivered<S>:
  created(~S,W.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(u => P.empty_store(~S,u)),W.factory(),resources(~S)))
def teardown(~S: Data,result: Delivered<S>) -> String:
  match result:
    case Delivered{_,Observed{_,_,rows},_}: String.join(rows,"\n")
    case RegistrationFailed{_,_}: "registration-failed"
    case CreationFailed{_,_}: "creation-failed"
def main() -> String:
  "SCHEMA=A\n" ++ teardown(~P.SchemaA,scenario(~P.SchemaA)) ++ "\nSCHEMA=B\n" ++ teardown(~P.SchemaB,scenario(~P.SchemaB))
