import Base
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import ./application.bend as Constructed
import ./plain-transient-application.bend as Plain
import ./registered-application.bend as Registered
import ./nonempty.bend as Seed
import ./system.bend as System
import ./declaration.bend as Query
import ./app.bend as App
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/application/game.bend as Game
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/application/legacy-fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/application/setup.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q

type Consumed<-S:Data,C:Type,R:Type,P:Type,Result:Type> is Type:
  Consumed{factory:W.Factory,returned:Maybe<P>,result:Result}
  SeedRefused{seed:Seed.Seed<S,C,R,P>}
  RegistrationRefused{factory:W.Factory,world:W.World<S,C,R,Unit>,returned:Maybe<P>}
  PreparationRefused{factory:W.Factory,world:W.World<S,C,R,Unit>,returned:Maybe<P>}
  CreationRefused{factory:W.Factory,resource:R}

def plain_run_registered(factory:W.Factory,returned:Maybe<Plain.Payload>,defined:System.Defined<Plain.Schema,W.World<Plain.Schema,Plain.Plain,Unit,Unit>,Registered.plain_registry()>) -> Consumed<Plain.Schema,Plain.Plain,Unit,Plain.Payload,Sys.RunResult<Plain.Schema,Plain.Plain,Unit,Unit,Unit & U32,Q.Error<Unit>,List<&2,U32>,System.runner(~Plain.Schema,~Plain.Plain,~Unit,~Unit,~Registered.plain_ops,~Unit,~Unit,~U32,~Plain.plain_read(),~(H => caps => args => owner => Registered.plain_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<Plain.Schema>>)>:
  match defined:
    case System.Rejected{world}:RegistrationRefused{factory,world,returned}
    case System.Defined{world,owner}:Consumed{factory,returned,Registered.plain_run(owner,world)}
def plain_run_seeded(seed:Seed.Seed<Plain.Schema,Plain.Plain,Unit,Plain.Payload>) -> Consumed<Plain.Schema,Plain.Plain,Unit,Plain.Payload,Sys.RunResult<Plain.Schema,Plain.Plain,Unit,Unit,Unit & U32,Q.Error<Unit>,List<&2,U32>,System.runner(~Plain.Schema,~Plain.Plain,~Unit,~Unit,~Registered.plain_ops,~Unit,~Unit,~U32,~Plain.plain_read(),~(H => caps => args => owner => Registered.plain_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<Plain.Schema>>)>:
  match seed:
    case Seed.Seeded{factory,world,True{},returned}:plain_run_registered(factory,returned,Registered.plain_define(world))
    case seed:SeedRefused{seed}
def plain_run() -> Consumed<Plain.Schema,Plain.Plain,Unit,Plain.Payload,Sys.RunResult<Plain.Schema,Plain.Plain,Unit,Unit,Unit & U32,Q.Error<Unit>,List<&2,U32>,System.runner(~Plain.Schema,~Plain.Plain,~Unit,~Unit,~Registered.plain_ops,~Unit,~Unit,~U32,~Plain.plain_read(),~(H => caps => args => owner => Registered.plain_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<Plain.Schema>>)>:
  plain_run_seeded(Seed.plain())

def plain_app_registered(factory:W.Factory,returned:Maybe<Plain.Payload>,defined:System.Defined<Plain.Schema,W.World<Plain.Schema,Plain.Plain,Unit,Unit>,Registered.plain_registry()>,debug:App.Debug) -> Consumed<Plain.Schema,Plain.Plain,Unit,Plain.Payload,App.Built<Plain.Schema,Plain.Plain,Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.plain_registry()>> & W.World<Plain.Schema,Plain.Plain,Unit,Unit>>:
  match defined:
    case System.Rejected{world}:RegistrationRefused{factory,world,returned}
    case System.Defined{world,owner}:Consumed{factory,returned,(Registered.plain_application(owner,debug),world)}
def plain_app_seeded(seed:Seed.Seed<Plain.Schema,Plain.Plain,Unit,Plain.Payload>,debug:App.Debug) -> Consumed<Plain.Schema,Plain.Plain,Unit,Plain.Payload,App.Built<Plain.Schema,Plain.Plain,Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.plain_registry()>> & W.World<Plain.Schema,Plain.Plain,Unit,Unit>>:
  match seed:
    case Seed.Seeded{factory,world,True{},returned}:plain_app_registered(factory,returned,Registered.plain_define(world),debug)
    case seed:SeedRefused{seed}
def plain_app(debug:App.Debug) -> Consumed<Plain.Schema,Plain.Plain,Unit,Plain.Payload,App.Built<Plain.Schema,Plain.Plain,Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.plain_registry()>> & W.World<Plain.Schema,Plain.Plain,Unit,Unit>>:
  plain_app_seeded(Seed.plain(),debug)

def transient_run_registered(factory:W.Factory,returned:Maybe<Plain.Payload>,defined:System.Defined<Plain.Schema,W.World<Plain.Schema,Plain.Transient(),Unit,Unit>,Registered.transient_registry()>) -> Consumed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload,Sys.RunResult<Plain.Schema,Plain.Transient(),Unit,Unit,Unit & U32,Q.Error<Unit>,List<&2,U32>,System.runner(~Plain.Schema,~Plain.Transient(),~Unit,~Unit,~Registered.transient_ops,~Unit,~Unit,~U32,~Plain.transient_read(),~(H => caps => args => owner => Registered.transient_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<Plain.Schema>>)>:
  match defined:
    case System.Rejected{world}:RegistrationRefused{factory,world,returned}
    case System.Defined{world,owner}:Consumed{factory,returned,Registered.transient_run(owner,world)}
def transient_run_seeded(seed:Seed.Seed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload>) -> Consumed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload,Sys.RunResult<Plain.Schema,Plain.Transient(),Unit,Unit,Unit & U32,Q.Error<Unit>,List<&2,U32>,System.runner(~Plain.Schema,~Plain.Transient(),~Unit,~Unit,~Registered.transient_ops,~Unit,~Unit,~U32,~Plain.transient_read(),~(H => caps => args => owner => Registered.transient_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<Plain.Schema>>)>:
  match seed:
    case Seed.Seeded{factory,world,True{},returned}:transient_run_registered(factory,returned,Registered.transient_define(world))
    case seed:SeedRefused{seed}
def transient_run() -> Consumed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload,Sys.RunResult<Plain.Schema,Plain.Transient(),Unit,Unit,Unit & U32,Q.Error<Unit>,List<&2,U32>,System.runner(~Plain.Schema,~Plain.Transient(),~Unit,~Unit,~Registered.transient_ops,~Unit,~Unit,~U32,~Plain.transient_read(),~(H => caps => args => owner => Registered.transient_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<Plain.Schema>>)>:
  transient_run_seeded(Seed.transient())

def transient_app_registered(factory:W.Factory,returned:Maybe<Plain.Payload>,defined:System.Defined<Plain.Schema,W.World<Plain.Schema,Plain.Transient(),Unit,Unit>,Registered.transient_registry()>,debug:App.Debug) -> Consumed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload,App.Built<Plain.Schema,Plain.Transient(),Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.transient_registry()>> & W.World<Plain.Schema,Plain.Transient(),Unit,Unit>>:
  match defined:
    case System.Rejected{world}:RegistrationRefused{factory,world,returned}
    case System.Defined{world,owner}:Consumed{factory,returned,(Registered.transient_application(owner,debug),world)}
def transient_app_seeded(seed:Seed.Seed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload>,debug:App.Debug) -> Consumed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload,App.Built<Plain.Schema,Plain.Transient(),Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.transient_registry()>> & W.World<Plain.Schema,Plain.Transient(),Unit,Unit>>:
  match seed:
    case Seed.Seeded{factory,world,True{},returned}:transient_app_registered(factory,returned,Registered.transient_define(world),debug)
    case seed:SeedRefused{seed}
def transient_app(debug:App.Debug) -> Consumed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload,App.Built<Plain.Schema,Plain.Transient(),Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.transient_registry()>> & W.World<Plain.Schema,Plain.Transient(),Unit,Unit>>:
  transient_app_seeded(Seed.transient(),debug)

def constructed_run_registered(factory:W.Factory,defined:System.Defined<F.Workshop,W.World<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,Registered.constructed_registry()>) -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,Sys.RunResult<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & U32,Q.Error<Unit>,List<&2,D.Raw>,System.runner(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),~Unit,~Registered.constructed_ops,~Unit,~Unit,~D.Raw,~Constructed.read(~F.Workshop),~(H => caps => args => owner => Registered.constructed_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<F.Workshop>>)>:
  match defined:
    case System.Rejected{world}:RegistrationRefused{factory,world,None{}}
    case System.Defined{world,owner}:Consumed{factory,None{},Registered.constructed_run(owner,world)}
def constructed_run_prepared(factory:W.Factory,result:Setup.Setup<F.Workshop>) -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,Sys.RunResult<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & U32,Q.Error<Unit>,List<&2,D.Raw>,System.runner(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),~Unit,~Registered.constructed_ops,~Unit,~Unit,~D.Raw,~Constructed.read(~F.Workshop),~(H => caps => args => owner => Registered.constructed_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<F.Workshop>>)>:
  match result:
    case Setup.Ready{world}:constructed_run_registered(factory,Registered.constructed_define(world))
    case Setup.Refused{world,incoming}:PreparationRefused{factory,world,incoming}
def constructed_run_created(result:W.Creation<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>) -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,Sys.RunResult<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & U32,Q.Error<Unit>,List<&2,D.Raw>,System.runner(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),~Unit,~Registered.constructed_ops,~Unit,~Unit,~D.Raw,~Constructed.read(~F.Workshop),~(H => caps => args => owner => Registered.constructed_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<F.Workshop>>)>:
  match result:
    case W.CreateRejected{factory,resource}:CreationRefused{factory,resource}
    case W.Created{factory,world}:constructed_run_prepared(factory,Setup.setup(~F.Workshop,world))
def constructed_run() -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,Sys.RunResult<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & U32,Q.Error<Unit>,List<&2,D.Raw>,System.runner(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),~Unit,~Registered.constructed_ops,~Unit,~Unit,~D.Raw,~Constructed.read(~F.Workshop),~(H => caps => args => owner => Registered.constructed_body(~H,~caps,args,owner)))> & (String & List<&2,Query.Clause<F.Workshop>>)>:
  constructed_run_created(W.create(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),~Unit,~Game.empty(~F.Workshop),W.factory(),Game.initial_resources(~F.Workshop)))

def constructed_app_registered(factory:W.Factory,defined:System.Defined<F.Workshop,W.World<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,Registered.constructed_registry()>,debug:App.Debug) -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,App.Built<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & System.Owner<F.Workshop,Registered.constructed_registry()>> & W.World<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>>:
  match defined:
    case System.Rejected{world}:RegistrationRefused{factory,world,None{}}
    case System.Defined{world,owner}:Consumed{factory,None{},(Registered.constructed_application(owner,debug),world)}
def constructed_app_prepared(factory:W.Factory,result:Setup.Setup<F.Workshop>,debug:App.Debug) -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,App.Built<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & System.Owner<F.Workshop,Registered.constructed_registry()>> & W.World<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>>:
  match result:
    case Setup.Ready{world}:constructed_app_registered(factory,Registered.constructed_define(world),debug)
    case Setup.Refused{world,incoming}:PreparationRefused{factory,world,incoming}
def constructed_app_created(result:W.Creation<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>,debug:App.Debug) -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,App.Built<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & System.Owner<F.Workshop,Registered.constructed_registry()>> & W.World<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>>:
  match result:
    case W.CreateRejected{factory,resource}:CreationRefused{factory,resource}
    case W.Created{factory,world}:constructed_app_prepared(factory,Setup.setup(~F.Workshop,world),debug)
def constructed_app(debug:App.Debug) -> Consumed<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),F.Payload,App.Built<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit,Unit & System.Owner<F.Workshop,Registered.constructed_registry()>> & W.World<F.Workshop,Game.Store(~F.Workshop),Game.ResourceStore(~F.Workshop),Unit>>:
  constructed_app_created(W.create(~F.Workshop,~Game.Store(~F.Workshop),~Game.ResourceStore(~F.Workshop),~Unit,~Game.empty(~F.Workshop),W.factory(),Game.initial_resources(~F.Workshop)),debug)
