import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/machine.bend as M
import ../../../../../src/ecs/machine-handlers.bend as H
import ../../../../../src/ecs/machine-handler-bundle.bend as B
import ../../../../../src/ecs/machine-world.bend as MachineWorld
import ../../../../../src/ecs/ordinary-machine-declaration.bend as Machine
import ../../../../../src/ecs/ordinary-machine-schedule.bend as Ordinary
import ../../../../../src/ecs/ordinary-app-machine-handler.bend as App
import ../../../../../src/ecs/ordinary-app-resource-field-declaration.bend as D
import ../../../../../src/ecs/ordinary-resource-field-system.bend as Field
import ../../../../../src/ecs/ordinary-machine-handler-bundle-context.bend as Operation
import ./handler-trace.bend as TraceRun
import ../../../../../src/ecs/ordinary-machine-handler-bundle.bend as Classic
import ../../../../../src/ecs/execution-trace.bend as Trace
import ../../../../../src/ecs/trace-facts.bend as Facts
type Registration<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Registered{world:W.World<S,C,R,E>,entry:B.Scheduled<S,K,V,Q,C,R,E,runner>}
  Rejected{world:W.World<S,C,R,E>,selector:B.Selector<S,K,V>,requirements:List<&2,Q>,ordinal:U32,name:String}
def access_fields(~S:Data,~Owner:Type,~Ops:Type,value:Field.Declaration<S,Owner,Ops>) -> List<&2,String>:
  match value:
    case Field.Declaration{_,clauses}:Field.access(~S,clauses)
def access(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>) -> List<&2,String>:
  access_fields(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration))
def registered(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,selector:B.Selector<S,K,V>,requirements:List<&2,Q>,ordinal:U32,name:String,result:Sys.RegistrationResult<S,C,R,E,H.Invocation<V>,String,Unit,runner>) -> Registration<S,K,V,Q,C,R,E,runner>:
  match result:
    case Sys.Registered{world,registry}:Registered{world,B.Scheduled{selector,requirements,H.Entry{ordinal,registry}}}
    case Sys.RegistrationFailed{world}:Rejected{world,selector,requirements,ordinal,name}
def register(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> H.Invocation<V> -> H -> H & (T.Outcome<String> & Unit),world:W.World<S,C,R,E>,selector:B.Selector<S,K,V>,requirements:List<&2,Q>,ordinal:U32,+name:String) -> Registration<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>:
  registered(~S,~K,~V,~Q,~C,~R,~E,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),selector,requirements,ordinal,name,Sys.register(~S,~C,~R,~E,~H.Invocation<V>,~String,~Unit,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),world,name,access(~S,~C,~R,~E,~Ops,~Value,~declaration)))
def Application(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> H.Invocation<V> -> H -> H & (T.Outcome<String> & Unit),~Extra:Type) -> Type:App.Application<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),Extra>
def Bundle(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> H.Invocation<V> -> H -> H & (T.Outcome<String> & Unit)) -> Type:B.Bundle<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>
def Entry(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> H.Invocation<V> -> H -> H & (T.Outcome<String> & Unit)) -> Type:B.Scheduled<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>
def bind(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> H.Invocation<V> -> H -> H & (T.Outcome<String> & Unit),~Extra:Type,world:W.World<S,C,R,E>,bundle:B.Bundle<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body)>,phase:Ordinary.Declaration<S>,extra:Extra) -> App.Application<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),Extra>:
  App.bind(~S,~K,~V,~Q,~C,~R,~E,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Extra,world,bundle,phase,extra)
def returned(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,declaration:Ordinary.Declaration<S>,extra:Extra,debug:Bool,result:Classic.MarkerResult<S,K,V,Q,C,R,E,runner> & Trace.Batch<String>) -> App.RunResult<S,K,V,Q,C,R,E,runner,Extra> & Trace.Batch<String>:
  match result:
    case (result,batch):(App.RunResult{result,declaration,extra,debug},batch)
def state(debug:Bool) -> Facts.State:
  match debug:
    case False{}:Facts.Off{}
    case True{}:Facts.On{[]}
def run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> H.Invocation<V> -> H -> H & (T.Outcome<String> & Unit),~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~machine:Machine.Declaration<S,K,V,R,take>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~Extra:Type,app:App.Application<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),Extra>) -> App.RunResult<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),Extra> & Trace.Batch<String>:
  match app:
    case App.Recovering{result,declaration,extra,debug}:(App.RunResult{result,declaration,extra,debug},Trace.Disabled{})
    case App.Application{world,bundle,Ordinary.Declaration{+name},extra,+debug}:returned(~S,~K,~V,~Q,~C,~R,~E,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Extra,Ordinary.Declaration{name},extra,debug,TraceRun.captured(~S,~K,~V,~Q,~C,~R,~E,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),name,Operation.run(~S,~K,~V,~Q,~C,~R,~E,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Field.runner_observed(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Machine.name(~S,~K,~V,~R,~take,machine),~MachineWorld.take(~S,~K,~V,~C,~R,~E,~take),~MachineWorld.put(~S,~K,~V,~C,~R,~E,~put),~publish,~same,~requirement_same,~has,~frame,Ordinary.Declaration{name},bundle,world,state(debug))))
def resumed(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,declaration:Ordinary.Declaration<S>,extra:Extra,debug:Bool,value:Classic.MarkerResult<S,K,V,Q,C,R,E,runner>) -> App.Application<S,K,V,Q,C,R,E,runner,Extra> & B.Status<Q>:
  match value:
    case Classic.MarkerResult{B.Returned{bundle,world,status},_,_}:(App.Application{world,bundle,declaration,extra,debug},status)
    case Classic.MarkerResult{B.InternalOwnerRemainder{namespace,recovery,world,+status},steps,observations}:(App.Recovering{Classic.MarkerResult{B.InternalOwnerRemainder{namespace,recovery,world,status},steps,observations},declaration,extra,debug},status)
def resume(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,value:App.RunResult<S,K,V,Q,C,R,E,runner,Extra>) -> App.Application<S,K,V,Q,C,R,E,runner,Extra> & B.Status<Q>:
  match value:
    case App.RunResult{result,declaration,extra,debug}:resumed(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,declaration,extra,debug,result)
