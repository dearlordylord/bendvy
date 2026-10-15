import Base
import ./fixture.bend as Core
import ../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/event-stream.bend as Leaf
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/event-family-runtime.bend as Family
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/reader-parameter.bend as RP
import ../../../../src/ecs/ordinary-reader-stream-parameter.bend as Stream
import ../../../../src/ecs/removals.bend as Rm
import ../../../../src/ecs/internal/relation-failures/domains.bend as KD
import ../../../../src/ecs/internal/relation-failures/queue.bend as KQ
import ../../../../src/ecs/relation-commands.bend as Notice
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../src/ecs/registration.bend as Registration
import ../../../../src/ecs/relation-types.bend as Relations

# This consumer observes the complete cleanup boundary while keeping the same
# affine Context and Provider values flowing through real library operations.

def position_json(position:Ev.Position) -> String:
  match position:
    case Ev.Position{id,cursor,registeredAt}:"{\"id\":"++U32.show(id)++",\"cursor\":"++Nat.show(cursor)++",\"registeredAt\":"++Nat.show(registeredAt)++"}"
def position_list_json(values:List<&2,Ev.Position>) -> String:
  Core.list_json(~Ev.Position,~position_json,values)

def notice_batch_json(batch:Ev.Batch<Core.event_type()>) -> String:
  match batch:
    case Ev.Batch{tick,values}:"{\"tick\":"++Nat.show(tick)++",\"values\":"++Core.list_json(~Core.event_type(),~Core.notice_json,values)++"}"
def notice_batches_json(values:List<&2,Ev.Batch<Core.event_type()>>) -> String:
  Core.list_json(~Ev.Batch<Core.event_type()>,~notice_batch_json,values)
def family_stream_json(family:Core.family_type()) -> String:
  match family:
    case Leaf.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:
      match domain:
        case Event.Domain{key}:"{\"domain\":"++Core.quoted(key)++",\"batches\":"++notice_batches_json(batches)++",\"positions\":"++position_list_json(positions)++",\"nextReader\":"++U32.show(nextReader)++",\"frameStart\":"++Nat.show(frameStart)++",\"boundary\":"++Nat.show(boundary)++",\"capacity\":"++Nat.show(capacity)++",\"dropped\":"++Nat.show(dropped)++"}"

def failure_batch_json(batch:KQ.Batch<Core.event_type()>) -> String:
  match batch:
    case KQ.Batch{tick,count,values}:"{\"tick\":"++Nat.show(tick)++",\"count\":"++Nat.show(count)++",\"values\":"++Core.list_json(~Core.event_type(),~Core.notice_json,values)++"}"
def failure_batches_json(values:List<&2,KQ.Batch<Core.event_type()>>) -> String:
  Core.list_json(~KQ.Batch<Core.event_type()>,~failure_batch_json,values)
def failure_queue_json(queue:KQ.Queue<Core.event_type()>) -> String:
  match queue:
    case KQ.Queue{front,back,size,dropped}:"{\"front\":"++failure_batches_json(front)++",\"back\":"++failure_batches_json(back)++",\"size\":"++Nat.show(size)++",\"dropped\":"++Nat.show(dropped)++"}"
def u32s_json(values:List<&2,U32>) -> String:
  Core.list_json(~U32,~U32.show,values)
def failure_domain_json(domain:KD.Domain<Core.Schema,Core.event_type()>) -> String:
  match domain:
    case KD.Domain{key,queue,readers}:
      match key:
        case KD.DeclaredKey{id}:"{\"key\":"++U32.show(id)++",\"queue\":"++failure_queue_json(queue)++",\"readers\":"++u32s_json(readers)++"}"
def failure_domains_json(values:List<&2,KD.Domain<Core.Schema,Core.event_type()>>) -> String:
  Core.list_json(~KD.Domain<Core.Schema,Core.event_type()>,~failure_domain_json,values)

def publication_batch_json(batch:Ev.Batch<Core.Publication>) -> String:
  match batch:
    case Ev.Batch{tick,values}:"{\"tick\":"++Nat.show(tick)++",\"values\":"++Core.list_json(~Core.Publication,~Core.publication_json,values)++"}"
def publication_batches_json(values:List<&2,Ev.Batch<Core.Publication>>) -> String:
  Core.list_json(~Ev.Batch<Core.Publication>,~publication_batch_json,values)
def family_state_keep(state:Family.State<Core.Publication,Core.family_type(),Unit>) -> Family.State<Core.Publication,Core.family_type(),Unit> & String:
  match state:
    case Family.State{+family,owners,+journal,+frameStart}:
      (Family.State{family,owners,journal,frameStart},"{\"stream\":"++family_stream_json(family)++",\"journal\":"++publication_batches_json(journal)++",\"frameStart\":"++Nat.show(frameStart)++"}")
def failure_state_json(failures:Mixed.Failures<Core.Schema,Core.Publication>) -> String:
  match failures:
    case Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}:
      "{\"domains\":"++failure_domains_json(domains)++",\"positions\":"++position_list_json(positions)++",\"tick\":"++Nat.show(tick)++",\"frameStart\":"++Nat.show(frameStart)++",\"boundary\":"++Nat.show(boundary)++",\"capacity\":"++Nat.show(capacity)++",\"nextReader\":"++U32.show(nextReader)++"}"
def mixed_state_keep_family(result:Family.State<Core.Publication,Core.family_type(),Unit> & String,+failures:Mixed.Failures<Core.Schema,Core.Publication>) -> Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit> & String:
  match result:
    case (typed,typed_json):(Mixed.State{typed,failures},"{\"typed\":"++typed_json++",\"relationFailures\":"++failure_state_json(failures)++"}")
def mixed_state_keep(state:Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit>) -> Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit> & String:
  match state:
    case Mixed.State{typed,+failures}:mixed_state_keep_family(family_state_keep(typed),failures)

def registration_json(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"{\"id\":"++U32.show(id)++",\"name\":"++Core.quoted(name)++",\"access\":"++Core.list_json(~String,~Core.quoted,access)++"}"
def registrations_json(values:List<&2,W.RegistrationMeta>) -> String:
  Core.list_json(~W.RegistrationMeta,~registration_json,values)
def world_keep(world:Core.world_type()) -> Core.world_type() & String:
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},
        "{\"namespace\":"++U32.show(namespace)++",\"nextId\":"++U32.show(nextId)++",\"highWater\":"++U32.show(highWater)++",\"capacity\":"++U32.show(capacity)++",\"depth\":"++Nat.show(depth)++",\"clock\":"++U32.show(clock)++",\"events\":"++Core.list_json(~Core.event_type(),~Core.notice_json,events)++",\"registrations\":"++registrations_json(registrations)++"}")
def context_keep_parts(worldResult:Core.world_type() & String,stateResult:Mixed.State<Core.Schema,Core.Publication,Core.family_type(),Unit> & String,+tick:Nat) -> Core.context_type() & String:
  match worldResult:
    case (world,world_json):
      match stateResult:
        case (state,state_json):(Route.Runtime{world,state,tick},"{\"world\":"++world_json++",\"routeTick\":"++Nat.show(tick)++",\"shared\":"++state_json++"}")
def context_keep(context:Core.context_type()) -> Core.context_type() & String:
  match context:
    case Route.Runtime{world,state,tick}:context_keep_parts(world_keep(world),mixed_state_keep(state),tick)

def maybe_u32_json(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"null"
    case Some{id}:U32.show(id)
def relation_key_json(value:KD.DescriptorKey<Core.Schema>) -> String:
  match value:
    case KD.DeclaredKey{id}:U32.show(id)
def facts_json(facts:RP.RegistrationFacts) -> String:
  match facts:
    case RP.RegistrationFacts{namespace,id,name,access}:"{\"namespace\":"++U32.show(namespace)++",\"id\":"++U32.show(id)++",\"name\":"++Core.quoted(name)++",\"access\":"++Core.list_json(~String,~Core.quoted,access)++"}"
def event_owner_keep(owner:Core.e_owner()) -> Core.e_owner() & String:
  match owner:
    case Stream.EventOwner{+facts,reader}:
      match reader:
        case Route.Reader{+namespace,+id,+registryId}:
          (Stream.EventOwner{facts,Route.Reader{namespace,id,registryId}},"{\"facts\":"++facts_json(facts)++",\"reader\":{\"namespace\":"++U32.show(namespace)++",\"id\":"++U32.show(id)++",\"registryId\":"++U32.show(registryId)++"}}")
def removal_owner_keep(owner:Core.m_owner()) -> Core.m_owner() & String:
  match owner:
    case Stream.RemovalOwner{+facts,reader}:
      match reader:
        case Rm.Reader{+namespace,+id,+name,+cursor}:
          (Stream.RemovalOwner{facts,Rm.Reader{namespace,id,name,cursor}},"{\"facts\":"++facts_json(facts)++",\"reader\":{\"namespace\":"++U32.show(namespace)++",\"id\":"++U32.show(id)++",\"name\":"++Core.quoted(name)++",\"cursor\":"++Nat.show(cursor)++"}}")
def relation_owner_keep(owner:Core.r_owner()) -> Core.r_owner() & String:
  match owner:
    case Stream.RelationOwner{+facts,+id,+keys}:
      (Stream.RelationOwner{facts,id,keys},"{\"facts\":"++facts_json(facts)++",\"id\":"++maybe_u32_json(id)++",\"keys\":"++Core.list_json(~KD.DescriptorKey<Core.Schema>,~relation_key_json,keys)++"}")
def owners_keep_results(eventAResult:Core.e_owner() & String,eventBResult:Core.e_owner() & String,removalResult:Core.m_owner() & String,relationResult:Core.r_owner() & String) -> Core.all_owner() & String:
  match eventAResult:
    case (eventA,eventA_json):
      match eventBResult:
        case (eventB,eventB_json):
          match removalResult:
            case (removal,removal_json):
              match relationResult:
                case (relation,relation_json):((Unit{},(eventA,(eventB,(removal,relation)))),"{\"eventA\":"++eventA_json++",\"eventB\":"++eventB_json++",\"removal\":"++removal_json++",\"relation\":"++relation_json++"}")
def owners_keep(owner:Core.all_owner()) -> Core.all_owner() & String:
  match owner:
    case (_, (eventA,(eventB,(removal,relation)))):owners_keep_results(event_owner_keep(eventA),event_owner_keep(eventB),removal_owner_keep(removal),relation_owner_keep(relation))
def registry_keep(registry:Core.registry_type()) -> Core.registry_type() & String:
  match registry:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:
      (Sys.Registry{namespace,id,name,access,cursor},"{\"namespace\":"++U32.show(namespace)++",\"id\":"++U32.show(id)++",\"name\":"++Core.quoted(name)++",\"access\":"++Core.list_json(~String,~Core.quoted,access)++",\"cursor\":"++U32.show(cursor)++"}")
def provider_keep_results(registryResult:Core.registry_type() & String,ownersResult:Core.all_owner() & String,parameter:RP.Param<Core.context_type(),Core.all_owner(),Core.all_view(),Core.all_delta(),Core.validate_all,Core.prepare_all,Core.commit_all,Core.release_all>,declaration:Unit) -> Core.provider_type() & String:
  match registryResult:
    case (registry,registry_json):
      match ownersResult:
        case (reader,reader_json):(Ordinary.Provider{registry,reader,parameter,declaration},"{\"registry\":"++registry_json++",\"readers\":"++reader_json++"}")
def provider_keep(provider:Core.provider_type()) -> Core.provider_type() & String:
  match provider:
    case Ordinary.Provider{registry,reader,parameter,declaration}:provider_keep_results(registry_keep(registry),owners_keep(reader),parameter,declaration)
