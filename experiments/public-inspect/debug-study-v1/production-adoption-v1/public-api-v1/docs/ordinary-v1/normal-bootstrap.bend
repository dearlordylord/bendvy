import Base
import ./normal-values.bend as Game
import ./normal-application.bend as Application
import ./canonical-schema.bend as Schema
import ./canonical-app.bend as App
import ./schema-validation.bend as Validate
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WIO
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment

type Started is Type:
  Started{prepared:Application.Prepared}
  SchemaRejected{error:Fragment.Error,settings:Array<U32>,clock:Game.Clock}
  NamespaceRejected{owner:Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>}
def empty(args:Unit) -> Unit:
  Unit{}
def identity(world:Application.World()) -> Application.World():
  world
# Fixture marker configuration, separate from the ordinary declaration facade.
def configured(world:Application.World()) -> Application.World():
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,_,_,regs,system,_}:W.World{ns,next,high,live,capacity,depth,store,resource,[17],[identity,identity],regs,system,41}
def created(debug:App.Debug,result:WIO.Creation<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32>) -> Started:
  match result:
    case WIO.Refused{resource}:NamespaceRejected{resource}
    case WIO.Created{world}:Started{Application.prepare(configured(world),debug)}
def validated(debug:App.Debug,result:Validate.Bootstrapped<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>) -> IO(Started):
  match result:
    case Validate.Rejected{error,left,right}:IO.pure(Started,SchemaRejected{error,left,right})
    case Validate.Ready{owner}:IO.bind(WIO.Creation<Game.GameSchema,Unit,Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,U32>,Started,WIO.create(~Game.GameSchema,~Unit,~Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,Game.layout()>,~U32,~empty,owner),value => IO.pure(Started,created(debug,value)))
# The normal caller supplies only normal values plus one debug enable flag.
def start(debug:App.Debug) -> IO(Started):
  validated(debug,Validate.bootstrap(~Game.GameSchema,~Array<U32>,~Game.Clock,~Game.layout(),ALeaf{17},Game.Clock{ALeaf{23}}))
