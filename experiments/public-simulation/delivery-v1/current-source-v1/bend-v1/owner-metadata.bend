import Base
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/event-runtime.bend as ER
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/compose.bend as Q
import ./step.bend as Step
import ./storage.bend as Storage
import ./events.bend as Events
import ./spawn-system.bend as Spawn
import ./systems.bend as Systems
import ./movement.bend as Movement
import ./damage-body.bend as Damage
import ./geometry.bend as Geometry
import ../readers-v1/readers.bend as R

type RegistryMetadata is Data:
  RegistryMetadata{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type ReaderMetadata is Data:
  ReaderMetadata{namespace:U32,id:U32,registryId:U32,registry:RegistryMetadata}
type OwnerMetadata is Data:
  OwnerMetadata{spawn:Maybe<&2,RegistryMetadata>,movement:Maybe<&2,RegistryMetadata>,damage:Maybe<&2,RegistryMetadata>,readerA:ReaderMetadata,readerB:ReaderMetadata}
type RegistryViews is Data:
  RegistryViews{spawn:Maybe<&2,RegistryMetadata>,movement:Maybe<&2,RegistryMetadata>,damage:Maybe<&2,RegistryMetadata>}
type RegistryRead<S:Data> is Type:
  RegistryRead{spawn:Maybe<&1,Spawn.Registry(~S)>,movement:Maybe<&1,Systems.MovementRegistry(~S)>,damage:Maybe<&1,Systems.DamageRegistry(~S)>,views:RegistryViews}
def maybe_registry(~S:Data,~Args:Type,~Error:Data,~Output:Type,~runner:Step.World(~S) -> Args -> Sys.Outcome<Step.World(~S),Error,Output>,owner:Maybe<&1,Sys.Registry<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Args,Error,Output,runner>>) -> Maybe<&1,Sys.Registry<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Args,Error,Output,runner>> & Maybe<&2,RegistryMetadata>:
  match owner:
    case None{}:(None{},None{})
    case Some{Sys.Registry{+namespace,+id,+name,+access,+cursor}}:(Some{Sys.Registry{namespace,id,name,access,cursor}},Some{RegistryMetadata{namespace,id,name,access,cursor}})
def damage_done(~S:Data,spawn:Maybe<&1,Spawn.Registry(~S)>,movement:Maybe<&1,Systems.MovementRegistry(~S)>,sv:Maybe<&2,RegistryMetadata>,mv:Maybe<&2,RegistryMetadata>,observed:Maybe<&1,Systems.DamageRegistry(~S)> & Maybe<&2,RegistryMetadata>) -> RegistryRead<S>:
  (damage,dv)=observed
  RegistryRead{spawn,movement,damage,RegistryViews{sv,mv,dv}}
def movement_done(~S:Data,spawn:Maybe<&1,Spawn.Registry(~S)>,damage:Maybe<&1,Systems.DamageRegistry(~S)>,sv:Maybe<&2,RegistryMetadata>,observed:Maybe<&1,Systems.MovementRegistry(~S)> & Maybe<&2,RegistryMetadata>) -> RegistryRead<S>:
  (movement,mv)=observed
  damage_done(~S,spawn,movement,sv,mv,maybe_registry(~S,~Damage.DamageArgs,~Q.Error<Damage.DamageError>,~List<&2,Geometry.Cell>,~Systems.damage_runner(~S),damage))
def spawn_done(~S:Data,movement:Maybe<&1,Systems.MovementRegistry(~S)>,damage:Maybe<&1,Systems.DamageRegistry(~S)>,observed:Maybe<&1,Spawn.Registry(~S)> & Maybe<&2,RegistryMetadata>) -> RegistryRead<S>:
  (spawn,sv)=observed
  movement_done(~S,spawn,damage,sv,maybe_registry(~S,~U32,~Q.Error<Movement.MovementError>,~List<&2,Geometry.Cell>,~Systems.movement_runner(~S),movement))
def registries(~S:Data,spawn:Maybe<&1,Spawn.Registry(~S)>,movement:Maybe<&1,Systems.MovementRegistry(~S)>,damage:Maybe<&1,Systems.DamageRegistry(~S)>) -> RegistryRead<S>:
  spawn_done(~S,movement,damage,maybe_registry(~S,~Unit,~Spawn.SpawnError,~List<&2,W.Reservation<S>>,~Spawn.runner(~S),spawn))
def reader(~S:Data,owner:R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>) -> R.Owner<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent> & ReaderMetadata:
  match owner:
    case R.Owner{ER.Reader{+namespace,+id,+registryId},Sys.Registry{+rns,+rid,+name,+access,+cursor}}:(R.Owner{ER.Reader{namespace,id,registryId},Sys.Registry{rns,rid,name,access,cursor}},ReaderMetadata{namespace,id,registryId,RegistryMetadata{rns,rid,name,access,cursor}})
