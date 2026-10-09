import Base
import ../fixture.bend as Input
import ../materialization-v1/fixture.bend as Material
import ../materialization-v1/mail.bend as Mail
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type ArgsView<S:Data> is Data:ArgsView{operation:Commands.Operation<S>,input:Input.InputView,fail:Bool}
def args_join(~S:Data,+operation:Commands.Operation<S>,+fail:Bool,value:Input.Input & Input.InputView) -> Material.Args<S> & ArgsView<S>:
  match value:
    case (input,view):(Material.Args{operation,input,fail},ArgsView{operation,view,fail})
def args_observe(~S:Data,args:Material.Args<S>) -> Material.Args<S> & ArgsView<S>:
  match args:
    case Material.Args{+operation,input,+fail}:args_join(~S,operation,fail,Input.input_view(input))
type Report<S:Data> is Data:
  Refused{primaryBefore:Material.Snapshot,primaryAfter:Material.Snapshot,suppliedBefore:Material.Snapshot,suppliedAfter:Material.Snapshot,instanceBefore:Material.InstanceView<S>,instanceAfter:Material.InstanceView<S>,incoming:ArgsView<S>,returned:ArgsView<S>}
  UnexpectedCompleted{} SetupRefused{}
def primary_finished(~S:Data,primaryBefore:Material.Snapshot,suppliedBefore:Material.Snapshot,suppliedAfter:Material.Snapshot,instanceBefore:Material.InstanceView<S>,instanceAfter:Material.InstanceView<S>,incoming:ArgsView<S>,returned:ArgsView<S>,value:Material.World(~S) & Material.Snapshot) -> Report<S>:
  match value:
    case (_,primaryAfter):Refused{primaryBefore,primaryAfter,suppliedBefore,suppliedAfter,instanceBefore,instanceAfter,incoming,returned}
def finish(~S:Data,primaryBefore:Material.Snapshot,primary:Material.World(~S),suppliedBefore:Material.Snapshot,instanceBefore:Material.InstanceView<S>,instanceAfter:Material.InstanceView<S>,incoming:ArgsView<S>,returned:ArgsView<S>,value:Material.World(~S) & Material.Snapshot) -> Report<S>:
  match value:
    case (_,suppliedAfter):primary_finished(~S,primaryBefore,suppliedBefore,suppliedAfter,instanceBefore,instanceAfter,incoming,returned,Material.snapshot(~S,primary))
def returned_args(~S:Data,primaryBefore:Material.Snapshot,primary:Material.World(~S),suppliedBefore:Material.Snapshot,instanceBefore:Material.InstanceView<S>,instanceAfter:Material.InstanceView<S>,incoming:ArgsView<S>,world:Material.World(~S),value:Material.Args<S> & ArgsView<S>) -> Report<S>:
  match value:
    case (_,returned):finish(~S,primaryBefore,primary,suppliedBefore,instanceBefore,instanceAfter,incoming,returned,Material.snapshot(~S,world))
def returned_instance(~S:Data,primaryBefore:Material.Snapshot,primary:Material.World(~S),suppliedBefore:Material.Snapshot,instanceBefore:Material.InstanceView<S>,incoming:ArgsView<S>,world:Material.World(~S),args:Material.Args<S>,value:Material.Instance(~S) & Material.InstanceView<S>) -> Report<S>:
  match value:
    case (_,instanceAfter):returned_args(~S,primaryBefore,primary,suppliedBefore,instanceBefore,instanceAfter,incoming,world,args_observe(~S,args))
def outcome(~S:Data,primaryBefore:Material.Snapshot,primary:Material.World(~S),suppliedBefore:Material.Snapshot,instanceBefore:Material.InstanceView<S>,incoming:ArgsView<S>,value:Local.Run<S,Material.Store(~S),Material.Resource(),Unit,Material.State<S>,Material.Args<S>,Unit,Material.Out(~S),Material.runner(~S)>) -> Report<S>:
  match value:
    case Local.Refused{world,instance,args}:returned_instance(~S,primaryBefore,primary,suppliedBefore,instanceBefore,incoming,world,args,Material.instance_observe(~S,instance))
    case Local.Completed{_,_,_}:UnexpectedCompleted{}
def invoke(~S:Data,primaryBefore:Material.Snapshot,primary:Material.World(~S),suppliedBefore:Material.Snapshot,instanceBefore:Material.InstanceView<S>,instance:Material.Instance(~S),world:Material.World(~S),value:Material.Args<S> & ArgsView<S>) -> Report<S>:
  match value:
    case (args,incoming):outcome(~S,primaryBefore,primary,suppliedBefore,instanceBefore,incoming,Local.run(~S,~Material.Store(~S),~Material.Resource(),~Unit,~Material.State<S>,~Material.Args<S>,~Unit,~Material.Out(~S),~Material.runner(~S),instance,world,args))
def supplied(~S:Data,primaryBefore:Material.Snapshot,primary:Material.World(~S),instance:Material.Instance(~S),instanceBefore:Material.InstanceView<S>,value:Material.World(~S) & Material.Snapshot) -> Report<S>:
  match value:
    case (world,suppliedBefore):invoke(~S,primaryBefore,primary,suppliedBefore,instanceBefore,instance,world,args_observe(~S,Material.Args{Commands.Spawn{},Input.input(Input.valid()),True{}}))
def other_created(~S:Data,primaryBefore:Material.Snapshot,primary:Material.World(~S),instance:Material.Instance(~S),instanceBefore:Material.InstanceView<S>,value:W.Creation<S,Material.Store(~S),Material.Resource(),Unit>) -> Report<S>:
  match value:
    case W.CreateRejected{_,_}:SetupRefused{}
    case W.Created{_,world}:supplied(~S,primaryBefore,primary,instance,instanceBefore,Material.snapshot(~S,world))
def primary_observed(~S:Data,foreign:Bool,factory:W.Factory,instance:Material.Instance(~S),instanceBefore:Material.InstanceView<S>,value:Material.World(~S) & Material.Snapshot) -> Report<S>:
  match foreign value:
    case True{},(primary,before):other_created(~S,before,primary,instance,instanceBefore,W.create(~S,~Material.Store(~S),~Material.Resource(),~Unit,~Material.empty(~S),factory,Mail.Mail{Input.owned(D.Number{200}),[],[],[]}))
    case False{},(primary,before):other_created(~S,before,primary,instance,instanceBefore,W.create(~S,~Material.Store(~S),~Material.Resource(),~Unit,~Material.empty(~S),W.factory(),Mail.Mail{Input.owned(D.Number{200}),[],[],[]}))
def instance_observed(~S:Data,foreign:Bool,factory:W.Factory,world:Material.World(~S),value:Material.Instance(~S) & Material.InstanceView<S>) -> Report<S>:
  match value:
    case (instance,before):primary_observed(~S,foreign,factory,instance,before,Material.snapshot(~S,world))
def registered(~S:Data,foreign:Bool,factory:W.Factory,value:Local.Registered<S,Material.Store(~S),Material.Resource(),Unit,Material.State<S>,Material.Args<S>,Unit,Material.Out(~S),Material.runner(~S)>) -> Report<S>:
  match value:
    case Local.RegistrationRejected{_,_}:SetupRefused{}
    case Local.Registered{world,instance}:instance_observed(~S,foreign,factory,world,Material.instance_observe(~S,instance))
def created(~S:Data,foreign:Bool,value:W.Creation<S,Material.Store(~S),Material.Resource(),Unit>) -> Report<S>:
  match value:
    case W.CreateRejected{_,_}:SetupRefused{}
    case W.Created{factory,world}:registered(~S,foreign,factory,Material.define(~S,world))
def run(~S:Data,foreign:Bool) -> Report<S>:created(~S,foreign,W.create(~S,~Material.Store(~S),~Material.Resource(),~Unit,~Material.empty(~S),W.factory(),Mail.Mail{Input.owned(D.Number{100}),[],[],[]}))
type Candidate is Data:Candidate{foreignFirst:Report<Input.First>,missingRegistrationFirst:Report<Input.First>,foreignSecond:Report<Input.Second>,missingRegistrationSecond:Report<Input.Second>}
def main() -> Candidate:Candidate{run(~Input.First,True{}),run(~Input.First,False{}),run(~Input.Second,True{}),run(~Input.Second,False{})}
