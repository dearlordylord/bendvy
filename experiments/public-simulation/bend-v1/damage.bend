import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import ./geometry.bend as Geometry
import ./storage.bend as Storage
import ./schema.bend as Schema
import ./step.bend as Step
import ./cleanup.bend as Cleanup
import ./damage-body.bend as Damage

def Frame(~S: Data) -> Type: Q.Frame<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>
def selected_position(~S: Data,frame: Frame(~S)) -> Frame(~S) & Bool:
  Q.family_match(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.PositionRest<S>,~Array<U32>,~Geometry.Cell,~Storage.PositionToken<S>,~Storage.take_position(~S),~Storage.put_position(~S),~Geometry.project,~Schema.position(~S),~Q.Required{},frame)
def selected_health(~S: Data,frame: Frame(~S)) -> Frame(~S) & Bool:
  Q.family_match(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.HealthRest<S>,~Array<U32>,~Geometry.Cell,~Storage.HealthToken<S>,~Storage.take_health(~S),~Storage.put_health(~S),~Geometry.project,~Schema.health(~S),~Q.Required{},frame)
def selected(~S: Data,frame: Frame(~S)) -> Frame(~S) & Bool:
  Q.both(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~selected_position(~S),~selected_health(~S),frame)
def plan(~S: Data) -> Q.Plan<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Damage.Ops(~S)>:
  Q.Plan{Damage.DamageOps{Q.read_family(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.PositionRest<S>,~Array<U32>,~Geometry.Cell,~Storage.PositionToken<S>,~Storage.take_position(~S),~Storage.put_position(~S),~Geometry.project,~Schema.position(~S)),Q.write_family(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.HealthRest<S>,~Array<U32>,~Geometry.Cell,~Storage.HealthToken<S>,~Storage.take_health(~S),~Storage.put_health(~S),~Geometry.project,~Schema.health(~S)),Q.handle_read(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent),Q.event_write(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent),Q.command_despawn(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Cleanup.clear(~S))},selected(~S)}
def execute(~S: Data,args: Damage.DamageArgs,world: Step.World(~S)) -> Q.Executed<Step.World(~S),Q.Error<Damage.DamageError>,Geometry.Cell>:
  Q.each(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Damage.Ops(~S),~Damage.DamageArgs,~Damage.DamageError,~Geometry.Cell,~plan(~S),~Damage.body(~S),args,world)
