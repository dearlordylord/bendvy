import Base
import ./public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./observation.bend as O
import ./application.bend as App
import ./request.bend as Deferred
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
# Retained declaration supplies both the operation identity and runtime codec.
# No caller-authored access metadata or replacement codec at invocation.
def Declaration(~S:Data) -> Data:Public.Declaration<S>
def Args(~S:Data) -> Type:Public.Args<S>
type Recovery<S:Data> is Type:Recovery{output:Deferred.Output<S,Input.Owner>,packets:List<Deferred.Packet<Input.Owner>>}
type State<S:Data> is Type:State{declaration:Public.Declaration<S>,recovery:List<Recovery<S>>}
def access(~S:Data,declaration:Public.Declaration<S>) -> List<&2,String>:
  match declaration:
    case Public.Declaration{App.Resource{},_,_}:[Identity.key(~S,~Input.Owner,App.resource_identity(~S))]
    case Public.Declaration{_,_,_}:[Identity.key(~S,~Input.Owner,App.identity(~S))]
def invoked(~S:Data,previous:List<Recovery<S>>,result:Public.Frame<S> & Public.Output<S>) -> Local.Outcome<App.World(~S),State<S>,Unit,Deferred.Output<S,Input.Owner>>:
  match result:
    case (Public.Frame{world,declaration},Public.Completed{output}):Local.Succeeded{world,State{declaration,previous},output}
    case (Public.Frame{world,declaration},Public.Aborted{output,packets,error}):Local.Failed{world,State{declaration,Recovery{output,packets} <> previous},error}
def runner(~S:Data,world:App.World(~S),state:State<S>,args:Public.Args<S>) -> Local.Outcome<App.World(~S),State<S>,Unit,Deferred.Output<S,Input.Owner>>:
  match state:
    case State{declaration,previous}:invoked(~S,previous,Public.provide(~S,Public.Frame{world,declaration},args))
def Instance(~S:Data) -> Type:Local.Instance<S,App.Store(~S),App.Mail<S>,Unit,State<S>,Public.Args<S>,Unit,Deferred.Output<S,Input.Owner>,runner(~S)>
def define(~S:Data,world:App.World(~S),+declaration:Public.Declaration<S>) -> Local.Registered<S,App.Store(~S),App.Mail<S>,Unit,State<S>,Public.Args<S>,Unit,Deferred.Output<S,Input.Owner>,runner(~S)>:
  Local.register(~S,~App.Store(~S),~App.Mail<S>,~Unit,~State<S>,~Public.Args<S>,~Unit,~Deferred.Output<S,Input.Owner>,~runner(~S),world,"decode-owned",access(~S,declaration),State{declaration,[]})
def run(~S:Data,instance:Instance(~S),world:App.World(~S),args:Public.Args<S>) -> Local.Run<S,App.Store(~S),App.Mail<S>,Unit,State<S>,Public.Args<S>,Unit,Deferred.Output<S,Input.Owner>,runner(~S)>:
  Local.run(~S,~App.Store(~S),~App.Mail<S>,~Unit,~State<S>,~Public.Args<S>,~Unit,~Deferred.Output<S,Input.Owner>,~runner(~S),instance,world,args)

type OutputView is Data:
  AcceptedView{namespace:U32,id:U32,spawned:Bool,canonical:D.Raw}
  RefusedView{owner:Maybe<&2,O.PayloadView>,error:Deferred.Error}
type RecoveryView is Data:RecoveryView{output:OutputView,packets:List<&2,O.PacketView>}
type InstanceView is Data:InstanceView{namespace:U32,id:U32,name:String,access:List<&2,String>,operation:App.Operation,codec:D.Codec,completion:T.Outcome<Unit>,recovery:List<&2,RecoveryView>}
def refused_view(~S:Data,+error:Deferred.Error,result:Maybe<&1,Input.Owner> & Maybe<&2,O.PayloadView>) -> Deferred.Output<S,Input.Owner> & OutputView:
  match result:
    case (owner,view):(Deferred.Refused{owner,error},RefusedView{view,error})
def output_view(~S:Data,output:Deferred.Output<S,Input.Owner>) -> Deferred.Output<S,Input.Owner> & OutputView:
  match output:
    case Deferred.Accepted{W.Handle{+namespace,+id},+spawned,+canonical}:(Deferred.Accepted{W.Handle{namespace,id},spawned,canonical},AcceptedView{namespace,id,spawned,canonical})
    case Deferred.Refused{owner,error}:refused_view(~S,error,O.option(owner))
def recovery_join(~S:Data,output:Deferred.Output<S,Input.Owner> & OutputView,packets:List<Deferred.Packet<Input.Owner>> & List<&2,O.PacketView>) -> Recovery<S> & RecoveryView:
  match output packets:
    case (output,view), (packets,views):(Recovery{output,packets},RecoveryView{view,views})
def recovery_view(~S:Data,value:Recovery<S>) -> Recovery<S> & RecoveryView:
  match value:
    case Recovery{output,packets}:recovery_join(~S,output_view(~S,output),O.packets(packets))
def recoveries_join(~S:Data,head:Recovery<S> & RecoveryView,tail:List<Recovery<S>> & List<&2,RecoveryView>) -> List<Recovery<S>> & List<&2,RecoveryView>:
  match head tail:
    case (owner,view), (owners,views):(owner <> owners,view <> views)
def recoveries_view(~S:Data,values:List<Recovery<S>>) -> List<Recovery<S>> & List<&2,RecoveryView>:
  match values:
    case []:([],[])
    case head <> tail:recoveries_join(~S,recovery_view(~S,head),recoveries_view(~S,tail))
def instance_declared(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,declaration:Public.Declaration<S>,owners:List<Recovery<S>>,views:List<&2,RecoveryView>) -> Instance(~S) & InstanceView:
  match declaration:
    case Public.Declaration{+operation,+codec,+completion}:(Local.Instance{namespace,id,name,access,State{Public.Declaration{operation,codec,completion},owners}},InstanceView{namespace,id,name,access,operation,codec,completion,views})
def instance_join(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+declaration:Public.Declaration<S>,result:List<Recovery<S>> & List<&2,RecoveryView>) -> Instance(~S) & InstanceView:
  match result:
    case (owners,views):instance_declared(~S,namespace,id,name,access,declaration,owners,views)
def instance_view(~S:Data,instance:Instance(~S)) -> Instance(~S) & InstanceView:
  match instance:
    case Local.Instance{namespace,id,name,access,State{declaration,recovery}}:instance_join(~S,namespace,id,name,access,declaration,recoveries_view(~S,recovery))
