import Base
import ./normal-values.bend as Game
import ./canonical-schema.bend as Schema
import ./canonical-system.bend as System
import ./canonical-retained.bend as Retained
import ./canonical-app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I

def runner(world:W.World<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32>,args:I.Instance<Game.GameSchema> & Unit) -> Sys.Outcome<W.World<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32>,Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>>:
  System.invoke(~Game.GameSchema,~Unit,~Array<U32>,~Game.Clock,~U32,~Game.layout(),~U32,~Bool,~Game.settings,~Game.clock,~Schema.first(~Game.GameSchema,~Array<U32>,~Game.Clock,~Game.layout(),Game.parameters()),~Schema.second(~Game.GameSchema,~Array<U32>,~Game.Clock,~Game.layout(),Game.parameters()),~(H => caps => args => owner => Game.body(~H,~caps,args,owner)),world,args)

def World() -> Type:
  W.World<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32>
def Application() -> Type:
  App.Application<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,Retained.Registered<Game.GameSchema,Array<U32>,Game.Clock,Game.layout(),Sys.Registry<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,I.Instance<Game.GameSchema> & Unit,Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>,runner>>>

type Prepared is Type:
  Prepared{world:World(),app:Application()}
  RegistrationRejected{world:World()}
  ScheduleRejected{world:World(),owners:Retained.Registered<Game.GameSchema,Array<U32>,Game.Clock,Game.layout(),Sys.Registry<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,I.Instance<Game.GameSchema> & Unit,Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>,runner>>}

def scheduled(world:World(),result:App.Build<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,Retained.Registered<Game.GameSchema,Array<U32>,Game.Clock,Game.layout(),Sys.Registry<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,I.Instance<Game.GameSchema> & Unit,Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>,runner>>>) -> Prepared:
  match result:
    case App.Built{app}:Prepared{world,app}
    case App.Invalid{owners}:ScheduleRejected{world,owners}

def registered(debug:App.Debug,result:Retained.Defined<Game.GameSchema,World(),Retained.Registered<Game.GameSchema,Array<U32>,Game.Clock,Game.layout(),Sys.Registry<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32,I.Instance<Game.GameSchema> & Unit,Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>,runner>>>) -> Prepared:
  match result:
    case Retained.Rejected{world}:RegistrationRejected{world}
    case Retained.Defined{world,owner}:scheduled(world,App.build(~Game.GameSchema,~Unit,~Array<U32>,~Game.Clock,~U32,~Game.layout(),~(I.Instance<Game.GameSchema> & Unit),~Unit,~(I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>),~runner,owner,"Update",debug))

# Normal application call: ordinary declaration+body above, debug flag once.
def prepare(world:World(),debug:App.Debug) -> Prepared:
  registered(debug,System.define(~Game.GameSchema,~Unit,~Array<U32>,~Game.Clock,~U32,~Game.layout(),~U32,~Bool,~Game.settings,~Game.clock,~Schema.first(~Game.GameSchema,~Array<U32>,~Game.Clock,~Game.layout(),Game.parameters()),~Schema.second(~Game.GameSchema,~Array<U32>,~Game.Clock,~Game.layout(),Game.parameters()),~(H => caps => args => owner => Game.body(~H,~caps,args,owner)),world,"Reader"))
