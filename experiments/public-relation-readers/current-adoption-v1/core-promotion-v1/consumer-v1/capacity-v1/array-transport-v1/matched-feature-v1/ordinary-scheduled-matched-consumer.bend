import Base
import ../../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../../../src/ecs/internal/relation-failures/readings.bend as KRead
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../../src/ecs/reader-parameter.bend as RP
import ../../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../../src/ecs/lifecycle.bend as Lifecycle
import ../../../../../../../../src/ecs/compose.bend as Compose
import ../../../../../../../../src/ecs/inspector.bend as Inspector
import ../../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../../src/ecs/ordinary-component-removal.bend as OrdinaryRemoval
import ../../../../../../../../src/ecs/structural.bend as Structural
import ../../../../../../../../src/ecs/ordinary-query-observable.bend as Observable
import ../../../../../../../../src/ecs/ordinary-reader-query-parameter.bend as QParam
import ../../../../../../../../src/ecs/ordinary-reader-stream-parameter.bend as Stream
import ../../../../../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../../src/ecs/event-stream.bend as Leaf
import ../../../../../../../../src/ecs/event-family-runtime.bend as Family
import ../../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../../src/ecs/relation-commands.bend as Notice
import ../../../../../../../../src/ecs/removals.bend as Rm
import ../../../../../../../../src/ecs/ordinary-removal-provision.bend as Provision
import ../../../../../../../../src/ecs/relation-types.bend as Relations
import ../../../../../../../../src/ecs/relation-failure-reader.bend as KDecl
import ../../../../../../../../src/ecs/internal/relation-failures/domains.bend as KD
import ../../../../../../../../src/ecs/internal/relation-failures/queue.bend as KQ
import ../../../../../../../../src/ecs/relation-providers.bend as RelationProvider
import ../../../../../../../../src/ecs/commands.bend as Commands
import ../../../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../../../src/ecs/schedule.bend as Sch
import ../../../../../../../../src/ecs/schedule-with-barrier.bend as SchBarrier

# Actual shared-context composition consumer. Library-owned hooks and registration
# remain in Ordinary; this application supplies its schema and ordinary declarations.
type Schema is Data:
  Schema{}
type Publication is Data:
  Value{value:U32}
  Removed{record:Rm.Record<Schema,Identity.Declaration<Schema,U32>>}

def event_type() -> Data:
  Notice.Notice<Schema,Publication>
def store_type() -> Type:
  Notice.Store<Schema,Col.Column<Schema,U32>>
def world_type() -> Type:
  W.World<Schema,store_type(),Unit,event_type()>
def family_type() -> Data:
  Leaf.Stream<Schema,event_type()>
def context_type() -> Type:
  Route.Runtime<Schema,store_type(),Unit,event_type(),Mixed.State<Schema,Publication,family_type(),Unit>>
def metadata_type() -> Type:
  Mixed.State<Schema,Publication,family_type(),Unit> & Nat
def no_caps(H:Type) -> Type:
  Cap.Send<H,U32>
def reader_publish(tx:Tx.Tx<world_type(),event_type()>,value:U32) -> Tx.Tx<world_type(),event_type()>:
  Tx.emit(~world_type(),~event_type(),tx,Notice.Original{Value{value}})
def no_grant() -> Cap.Send<Tx.Tx<world_type(),event_type()>,U32>:
  Cap.Send{reader_publish}
def empty_store(_:Unit) -> store_type():
  Notice.Store{Col.empty(~Schema,~U32),Relations.Graph{[],[]}}
def take_values(store:store_type()) -> Relations.Graph<Schema> & Col.Column<Schema,U32>:
  match store:
    case Notice.Store{components,+graph}:(graph,components)
def put_values(graph:Relations.Graph<Schema>,column:Col.Column<Schema,U32>) -> store_type():
  Notice.Store{column,graph}
def presence(value:U32) -> U32 & Unit:
  (value,Unit{})
def binding() -> Binding.Binding<Schema,store_type(),Relations.Graph<Schema>,U32,Unit,Unit,take_values,put_values,presence>:
  Binding.bind(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~Unit,~Unit,~take_values,~put_values,~presence,Identity.component(~Schema,~U32,"value"))
def query_projection(value:U32) -> U32 & U32:
  match value:
    case +found:(found,found)
def query_binding() -> Binding.Binding<Schema,store_type(),Relations.Graph<Schema>,U32,U32,Unit,take_values,put_values,query_projection>:
  Binding.bind(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~U32,~Unit,~take_values,~put_values,~query_projection,Identity.component(~Schema,~U32,"value"))
def query_declaration() -> Observable.Declaration<Schema,Compose.Frame<Schema,store_type(),Unit,event_type()>,Cap.Read<Compose.Frame<Schema,store_type(),Unit,event_type()>,U32>,Inspector.Frame<Schema,store_type(),Unit,event_type()>,Cmp.Access<U32>>:
  Observable.read(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~U32,~Unit,~take_values,~put_values,~query_projection,~Unit,~event_type(),~query_binding())
def added_declaration() -> Observable.Declaration<Schema,Compose.Frame<Schema,store_type(),Unit,event_type()>,Unit,Inspector.Frame<Schema,store_type(),Unit,event_type()>,Unit>:
  Observable.added(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~U32,~Unit,~take_values,~put_values,~query_projection,~Unit,~event_type(),~query_binding())
def changed_declaration() -> Observable.Declaration<Schema,Compose.Frame<Schema,store_type(),Unit,event_type()>,Unit,Inspector.Frame<Schema,store_type(),Unit,event_type()>,Unit>:
  Observable.changed(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~U32,~Unit,~take_values,~put_values,~query_projection,~Unit,~event_type(),~query_binding())
def event_declaration() -> Event.Declaration<Schema,event_type()>:
  Event.read(~Schema,~event_type(),Event.domain(~Schema,~event_type(),"values"))
def copy_events(+family:family_type()) -> family_type() & family_type():
  (family,family)
def take_events(family:family_type()) -> family_type() & family_type():
  copy_events(family)
def put_events(_:family_type(),stream:family_type()) -> family_type():
  stream
def original_values(values:List<&2,Publication>) -> List<&2,event_type()>:
  match values:
    case []:[]
    case Value{value} <> rest:Notice.Original{Value{value}} <> original_values(rest)
    case Removed{_} <> rest:original_values(rest)
def sync_events(family:family_type(),tick:Nat,values:List<&2,Publication>) -> family_type():
  Leaf.append(~Schema,~event_type(),family,tick,original_values(values))
def inject_removal(identity:Identity.Declaration<Schema,U32>,handle:W.Handle<Schema>) -> event_type():
  Notice.Original{Removed{Rm.Removed{handle,identity}}}
def select_removed(value:Publication) -> Maybe<&2,Rm.Record<Schema,Identity.Declaration<Schema,U32>>>:
  match value:
    case Removed{record}:Some{record}
    case Value{_}:None{}
def select_removal(value:event_type()) -> Maybe<&2,Rm.Record<Schema,Identity.Declaration<Schema,U32>>>:
  match value:
    case Notice.Original{value}:select_removed(value)
    case _:None{}
def removal_selection() -> Provision.Selection<Schema,U32,event_type(),inject_removal,select_removal>:
  Provision.Selection{Identity.component(~Schema,~U32,"value")}
def relation_descriptor() -> Relations.Descriptor<Schema>:
  Relations.Descriptor{1,"Parent","Children",Relations.Hierarchy{}}
def isolated_relation_descriptor() -> Relations.Descriptor<Schema>:
  Relations.Descriptor{2,"OrdinaryParent","OrdinaryChildren",Relations.Ordinary{}}
def relation_declarations() -> List<&2,KDecl.Declaration<Schema>>:
  [KDecl.relation(~Schema,relation_descriptor()),KDecl.relation(~Schema,isolated_relation_descriptor())]
def classify(value:event_type()) -> Maybe<KD.DescriptorKey<Schema>>:
  match value:
    case Notice.RelationFailed{Relations.Failure{Relations.Descriptor{key,_,_,_},_,_,_,_}}:Some{KD.DeclaredKey{key}}
    case _:None{}

# A separate trusted custom-command control composes three real relation calls
# under one queued closure: two use the first descriptor and one uses the second.
# The registered writer remains the 65,537-command path; these calls verify
# per-command batch grouping and descriptor isolation.
def control_key_one_second(source:W.Handle<Schema>,target:W.Handle<Schema>,world:world_type()) -> world_type():
  Notice.apply_relate(~Schema,~Col.Column<Schema,U32>,~Unit,~Publication,world,relation_descriptor(),source,target)
def control_key_one_first(source:W.Handle<Schema>,target:W.Handle<Schema>,world:world_type()) -> world_type():
  Notice.apply_relate(~Schema,~Col.Column<Schema,U32>,~Unit,~Publication,world,relation_descriptor(),source,target)
def control_key_two_first(source:W.Handle<Schema>,target:W.Handle<Schema>,world:world_type()) -> world_type():
  Notice.apply_relate(~Schema,~Col.Column<Schema,U32>,~Unit,~Publication,world,isolated_relation_descriptor(),source,target)
def control_command_targets(source_one:W.Handle<Schema>,source_two:W.Handle<Schema>,source_three:W.Handle<Schema>,targets:W.Handle<Schema> & (W.Handle<Schema> & W.Handle<Schema>),world:world_type()) -> world_type():
  match targets:
    case (target_one,(target_two,target_three)):
      control_key_two_first(source_three,target_three,control_key_one_second(source_two,target_two,control_key_one_first(source_one,target_one,world)))
def control_command(source:W.Handle<Schema>,targets:W.Handle<Schema> & (W.Handle<Schema> & W.Handle<Schema>),world:world_type()) -> world_type():
  match source:
    case W.Handle{+namespace,+id}:control_command_targets(W.Handle{namespace,id},W.Handle{namespace,id},W.Handle{namespace,id},targets,world)
def enqueue_control_context(metadata:metadata_type(),source:W.Handle<Schema>,targets:W.Handle<Schema> & (W.Handle<Schema> & W.Handle<Schema>),world:world_type()) -> context_type():
  Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,W.enqueue(~Schema,~store_type(),~Unit,~event_type(),world,(current => control_command(source,targets,current))),metadata)
def enqueue_control_parts(source:W.Handle<Schema>,targets:W.Handle<Schema> & (W.Handle<Schema> & W.Handle<Schema>),parts:world_type() & metadata_type()) -> context_type():
  match parts:
    case (world,metadata):enqueue_control_context(metadata,source,targets,world)
def enqueue_control(context:context_type(),source:W.Handle<Schema>,targets:W.Handle<Schema> & (W.Handle<Schema> & W.Handle<Schema>)) -> context_type():
  enqueue_control_parts(source,targets,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))

type ControlTargets is Type:
  TargetsReady{world:world_type(),targets:W.Handle<Schema> & (W.Handle<Schema> & W.Handle<Schema>)}
  TargetsRejected{world:world_type()}
def reserve_control_third(first:W.Handle<Schema>,second:W.Handle<Schema>,result:world_type() & W.Reservation<Schema>) -> ControlTargets:
  match result:
    case (world,W.ReservationRejected{_}):TargetsRejected{world}
    case (world,W.Reserved{+third}):TargetsReady{world,(first,(second,third))}
def reserve_control_second(first:W.Handle<Schema>,result:world_type() & W.Reservation<Schema>) -> ControlTargets:
  match result:
    case (world,W.ReservationRejected{_}):TargetsRejected{world}
    case (world,W.Reserved{+second}):reserve_control_third(first,second,W.reserve_id(~Schema,~store_type(),~Unit,~event_type(),world))
def reserve_control_first(result:world_type() & W.Reservation<Schema>) -> ControlTargets:
  match result:
    case (world,W.ReservationRejected{_}):TargetsRejected{world}
    case (world,W.Reserved{+first}):reserve_control_second(first,W.reserve_id(~Schema,~store_type(),~Unit,~event_type(),world))
def reserve_control_targets(world:world_type()) -> ControlTargets:
  reserve_control_first(W.reserve_id(~Schema,~store_type(),~Unit,~event_type(),world))

# Queue the real ordinary relation capability into the transaction journal.
# The relation graph mutation and failure notice are deferred to World.barrier.
def relation_body(-H:Type,caps:RelationProvider.Writable<H,Schema>,targets:RelationProvider.Targets<Schema>,owner:H) -> H & Notice.QueueStatus:
  match caps:
    case RelationProvider.Writable{_,Cap.Request{relate},_}:relate(owner,targets)
def relation_finished(status:Notice.QueueStatus,returned:Tx.Returned<world_type(),U32>) -> world_type() & (Notice.QueueStatus & Tx.Outcome<U32>):
  match returned:
    case Tx.Returned{world,outcome}:(world,(status,outcome))
def relation_finish(queued:Tx.Tx<world_type(),event_type()> & Notice.QueueStatus,outcome:Tx.Outcome<U32>) -> world_type() & (Notice.QueueStatus & Tx.Outcome<U32>):
  match queued:
    case (tx,status):relation_finished(status,Commands.tx_finish(~Schema,~store_type(),~Unit,~event_type(),~U32,tx,outcome))
def self_targets(+entity:W.Handle<Schema>) -> RelationProvider.Targets<Schema>:
  match entity:
    case W.Handle{+namespace,+id}:RelationProvider.Targets{W.Handle{namespace,id},W.Handle{namespace,id}}
def relation_attempt(world:world_type(),+entity:W.Handle<Schema>,outcome:Tx.Outcome<U32>) -> world_type() & (Notice.QueueStatus & Tx.Outcome<U32>):
  relation_finish(RelationProvider.invoke_write(~Schema,~Col.Column<Schema,U32>,~Unit,~Publication,~relation_descriptor(),~Notice.QueueStatus,~relation_body,self_targets(entity),Tx.begin(~world_type(),~event_type(),world)),outcome)
def submitted_context(metadata:metadata_type(),attempt:world_type() & (Notice.QueueStatus & Tx.Outcome<U32>)) -> context_type() & (Notice.QueueStatus & Tx.Outcome<U32>):
  match attempt:
    case (world,result):(Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata),result)
def submit_relation_parts(parts:world_type() & metadata_type(),entity:W.Handle<Schema>,outcome:Tx.Outcome<U32>) -> context_type() & (Notice.QueueStatus & Tx.Outcome<U32>):
  match parts:
    case (world,metadata):submitted_context(metadata,relation_attempt(world,entity,outcome))
def submit_relation(context:context_type(),entity:W.Handle<Schema>,outcome:Tx.Outcome<U32>) -> context_type() & (Notice.QueueStatus & Tx.Outcome<U32>):
  submit_relation_parts(Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context),entity,outcome)
type MutationReport is Data:
  MutationReport{committedStatus:Notice.QueueStatus,committedOutcome:Tx.Outcome<U32>,rolledBackStatus:Notice.QueueStatus,rolledBackOutcome:Tx.Outcome<U32>}
def mutation_report_done(committedStatus:Notice.QueueStatus,committedOutcome:Tx.Outcome<U32>,rolledBack:context_type() & (Notice.QueueStatus & Tx.Outcome<U32>)) -> context_type() & MutationReport:
  match rolledBack:
    case (context,(status,outcome)):(context,MutationReport{committedStatus,committedOutcome,status,outcome})
def mutate_prior_and_rollback(context:context_type(),entity:W.Handle<Schema>,committedStatus:Notice.QueueStatus,committedOutcome:Tx.Outcome<U32>) -> context_type() & MutationReport:
  mutation_report_done(committedStatus,committedOutcome,submit_relation(context,entity,Tx.Failure{77}))
def schedule_relation_first(entity:W.Handle<Schema>,first:context_type() & (Notice.QueueStatus & Tx.Outcome<U32>)) -> context_type() & MutationReport:
  match first:
    case (context,(status,outcome)):mutate_prior_and_rollback(context,entity,status,outcome)
def schedule_relation(context:context_type(),+entity:W.Handle<Schema>) -> context_type() & MutationReport:
  schedule_relation_first(entity,submit_relation(context,entity,Tx.Success{}))

def barrier_context_join(metadata:metadata_type(),world:world_type()) -> context_type():
  Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata)
def barrier_context_parts(parts:world_type() & metadata_type()) -> context_type():
  match parts:
    case (world,metadata):barrier_context_join(metadata,W.barrier(~Schema,~store_type(),~Unit,~event_type(),world))
def barrier_context(context:context_type()) -> context_type():
  barrier_context_parts(Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))

def q_owner() -> Type:
  Unit
def q_view() -> Data:
  QParam.Rows<Schema,Cmp.Access<U32>>
def q_delta() -> Type:
  Unit
def q_validate(context:context_type(),owner:q_owner()) -> context_type() & (q_owner() & Bool):
  QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Cap.Read<Compose.Frame<Schema,store_type(),Unit,event_type()>,U32>,~Cmp.Access<U32>,~query_declaration())(context,owner)
def q_prepare(context:context_type(),+cursor:U32,owner:q_owner()) -> context_type() & (q_owner() & (q_view() & q_delta())):
  QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Cap.Read<Compose.Frame<Schema,store_type(),Unit,event_type()>,U32>,~Cmp.Access<U32>,~query_declaration())(context,cursor,owner)
def q_commit(context:context_type(),owner:q_owner(),delta:q_delta(),+cursor:U32) -> context_type() & q_owner():
  QParam.commit_context(~context_type())(context,owner,delta,cursor)
def q_release(context:context_type(),owner:q_owner()) -> context_type():
  QParam.release_context(~context_type())(context,owner)
def q_parameter_type() -> Data:
  RP.Param<context_type(),q_owner(),q_view(),q_delta(),QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Cap.Read<Compose.Frame<Schema,store_type(),Unit,event_type()>,U32>,~Cmp.Access<U32>,~query_declaration()),QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Cap.Read<Compose.Frame<Schema,store_type(),Unit,event_type()>,U32>,~Cmp.Access<U32>,~query_declaration()),QParam.commit_context(~context_type()),QParam.release_context(~context_type())>
def q_parameter() -> q_parameter_type():
  QParam.from_observable(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Cap.Read<Compose.Frame<Schema,store_type(),Unit,event_type()>,U32>,~Cmp.Access<U32>,~query_declaration())
def q_initialize(context:context_type(),_:RP.RegistrationFacts) -> context_type() & (q_owner() & q_parameter_type()):
  (context,(Unit{},q_parameter()))
def a_owner() -> Type:
  Unit
def a_view() -> Data:
  QParam.Rows<Schema,Unit>
def a_delta() -> Type:
  Unit
def a_validate(context:context_type(),owner:a_owner()) -> context_type() & (a_owner() & Bool):
  QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~added_declaration())(context,owner)
def a_prepare(context:context_type(),+cursor:U32,owner:a_owner()) -> context_type() & (a_owner() & (a_view() & a_delta())):
  QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~added_declaration())(context,cursor,owner)
def a_commit(context:context_type(),owner:a_owner(),delta:a_delta(),+cursor:U32) -> context_type() & a_owner():
  QParam.commit_context(~context_type())(context,owner,delta,cursor)
def a_release(context:context_type(),owner:a_owner()) -> context_type():
  QParam.release_context(~context_type())(context,owner)
def a_parameter_type() -> Data:
  RP.Param<context_type(),a_owner(),a_view(),a_delta(),QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~added_declaration()),QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~added_declaration()),QParam.commit_context(~context_type()),QParam.release_context(~context_type())>
def a_parameter() -> a_parameter_type():
  QParam.from_observable(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~added_declaration())
def a_initialize(context:context_type(),_:RP.RegistrationFacts) -> context_type() & (a_owner() & a_parameter_type()):
  (context,(Unit{},a_parameter()))
def c_owner() -> Type:
  Unit
def c_view() -> Data:
  QParam.Rows<Schema,Unit>
def c_delta() -> Type:
  Unit
def c_validate(context:context_type(),owner:c_owner()) -> context_type() & (c_owner() & Bool):
  QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~changed_declaration())(context,owner)
def c_prepare(context:context_type(),+cursor:U32,owner:c_owner()) -> context_type() & (c_owner() & (c_view() & c_delta())):
  QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~changed_declaration())(context,cursor,owner)
def c_commit(context:context_type(),owner:c_owner(),delta:c_delta(),+cursor:U32) -> context_type() & c_owner():
  QParam.commit_context(~context_type())(context,owner,delta,cursor)
def c_release(context:context_type(),owner:c_owner()) -> context_type():
  QParam.release_context(~context_type())(context,owner)
def c_parameter_type() -> Data:
  RP.Param<context_type(),c_owner(),c_view(),c_delta(),QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~changed_declaration()),QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~changed_declaration()),QParam.commit_context(~context_type()),QParam.release_context(~context_type())>
def c_parameter() -> c_parameter_type():
  QParam.from_observable(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~changed_declaration())
def c_initialize(context:context_type(),_:RP.RegistrationFacts) -> context_type() & (c_owner() & c_parameter_type()):
  (context,(Unit{},c_parameter()))
def e_owner() -> Type:
  Stream.EventOwner<Schema,store_type(),Unit,Publication,event_type(),family_type(),Unit,take_events,put_events>
def e_view() -> Data:
  Stream.EventView<Schema,event_type()>
def e_delta() -> Type:
  Nat
def e_parameter_type() -> Data:
  RP.Param<context_type(),e_owner(),e_view(),e_delta(),Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events)>
def e_parameter() -> e_parameter_type():
  Stream.event_param(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,event_declaration())

def e_validate(context:context_type(),owner:e_owner()) -> context_type() & (e_owner() & Bool):
  Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration())(context,owner)
def e_prepare(context:context_type(),+cursor:U32,owner:e_owner()) -> context_type() & (e_owner() & (e_view() & e_delta())):
  Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration())(context,cursor,owner)
def e_commit(context:context_type(),owner:e_owner(),delta:e_delta(),+cursor:U32) -> context_type() & e_owner():
  Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events)(context,owner,delta,cursor)
def e_release(context:context_type(),owner:e_owner()) -> context_type():
  Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events)(context,owner)
def e_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (e_owner() & e_parameter_type()):
  Stream.initialize_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration(),context,facts)
def m_owner() -> Type:
  Stream.RemovalOwner<Schema,U32,event_type(),select_removal>
def m_view() -> Data:
  Stream.RemovalView<Schema,U32>
def m_delta() -> Type:
  Nat
def m_parameter_type() -> Data:
  RP.Param<context_type(),m_owner(),m_view(),m_delta(),Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal)>
def m_parameter() -> m_parameter_type():
  Stream.removal_param(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection())

def m_validate(context:context_type(),owner:m_owner()) -> context_type() & (m_owner() & Bool):
  Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection())(context,owner)
def m_prepare(context:context_type(),+cursor:U32,owner:m_owner()) -> context_type() & (m_owner() & (m_view() & m_delta())):
  Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal)(context,cursor,owner)
def m_commit(context:context_type(),owner:m_owner(),delta:m_delta(),+cursor:U32) -> context_type() & m_owner():
  Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal)(context,owner,delta,cursor)
def m_release(context:context_type(),owner:m_owner()) -> context_type():
  Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal)(context,owner)
def m_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (m_owner() & m_parameter_type()):
  Stream.initialize_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection(),context,facts)
def r_owner() -> Type:
  Stream.RelationOwner<Schema,Publication>
def r_view() -> Data:
  Stream.RelationView<Schema,Publication>
def r_delta() -> Type:
  Stream.RelationDelta
def r_parameter_type() -> Data:
  RP.Param<context_type(),r_owner(),r_view(),r_delta(),Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()),Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()),Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit),Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)>
def r_parameter() -> r_parameter_type():
  Stream.relation_param(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())

def r_validate(context:context_type(),owner:r_owner()) -> context_type() & (r_owner() & Bool):
  Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())(context,owner)
def r_prepare(context:context_type(),+cursor:U32,owner:r_owner()) -> context_type() & (r_owner() & (r_view() & r_delta())):
  Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())(context,cursor,owner)
def r_commit(context:context_type(),owner:r_owner(),delta:r_delta(),+cursor:U32) -> context_type() & r_owner():
  Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)(context,owner,delta,cursor)
def r_release(context:context_type(),owner:r_owner()) -> context_type():
  Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)(context,owner)
def r_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (r_owner() & r_parameter_type()):
  Stream.initialize_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations(),context,facts)
def mr_owner() -> Type:
  m_owner() & r_owner()
def mr_view() -> Data:
  RP.ViewPair<m_view(),r_view()>
def mr_delta() -> Type:
  m_delta() & r_delta()
def mr_validate(context:context_type(),owner:mr_owner()) -> context_type() & (mr_owner() & Bool):
  RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~m_validate,~r_validate)(context,owner)
def mr_prepare(context:context_type(),+cursor:U32,owner:mr_owner()) -> context_type() & (mr_owner() & (mr_view() & mr_delta())):
  RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~m_prepare,~r_prepare)(context,cursor,owner)
def mr_commit(context:context_type(),owner:mr_owner(),delta:mr_delta(),+cursor:U32) -> context_type() & mr_owner():
  RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~m_commit,~r_commit)(context,owner,delta,cursor)
def mr_release(context:context_type(),owner:mr_owner()) -> context_type():
  RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~m_release,~r_release)(context,owner)
def mr_parameter_type() -> Data:
  RP.Param<context_type(),mr_owner(),mr_view(),mr_delta(),mr_validate,mr_prepare,mr_commit,mr_release>
def pair_mr(left:m_parameter_type(),right:r_parameter_type()) -> mr_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def mr_parameter() -> mr_parameter_type():
  pair_mr(m_parameter(),r_parameter())
def mr_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (mr_owner() & mr_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~m_owner(),~m_parameter_type(),~r_owner(),~r_parameter_type(),~mr_parameter_type(),~m_initialize,~r_initialize,~pair_mr,context,facts)
def emr_owner() -> Type:
  e_owner() & mr_owner()
def emr_view() -> Data:
  RP.ViewPair<e_view(),mr_view()>
def emr_delta() -> Type:
  e_delta() & mr_delta()
def emr_validate(context:context_type(),owner:emr_owner()) -> context_type() & (emr_owner() & Bool):
  RP.pair_validate_fn(~context_type(),~e_owner(),~mr_owner(),~e_validate,~mr_validate)(context,owner)
def emr_prepare(context:context_type(),+cursor:U32,owner:emr_owner()) -> context_type() & (emr_owner() & (emr_view() & emr_delta())):
  RP.pair_prepare_fn(~context_type(),~e_owner(),~mr_owner(),~e_view(),~mr_view(),~e_delta(),~mr_delta(),~e_prepare,~mr_prepare)(context,cursor,owner)
def emr_commit(context:context_type(),owner:emr_owner(),delta:emr_delta(),+cursor:U32) -> context_type() & emr_owner():
  RP.pair_commit_fn(~context_type(),~e_owner(),~mr_owner(),~e_delta(),~mr_delta(),~e_commit,~mr_commit)(context,owner,delta,cursor)
def emr_release(context:context_type(),owner:emr_owner()) -> context_type():
  RP.pair_release_fn(~context_type(),~e_owner(),~mr_owner(),~e_release,~mr_release)(context,owner)
def emr_parameter_type() -> Data:
  RP.Param<context_type(),emr_owner(),emr_view(),emr_delta(),emr_validate,emr_prepare,emr_commit,emr_release>
def pair_emr(left:e_parameter_type(),right:mr_parameter_type()) -> emr_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def emr_parameter() -> emr_parameter_type():
  pair_emr(e_parameter(),mr_parameter())
def emr_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (emr_owner() & emr_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~e_owner(),~e_parameter_type(),~mr_owner(),~mr_parameter_type(),~emr_parameter_type(),~e_initialize,~mr_initialize,~pair_emr,context,facts)
def cemr_owner() -> Type:
  c_owner() & emr_owner()
def cemr_view() -> Data:
  RP.ViewPair<c_view(),emr_view()>
def cemr_delta() -> Type:
  c_delta() & emr_delta()
def cemr_validate(context:context_type(),owner:cemr_owner()) -> context_type() & (cemr_owner() & Bool):
  RP.pair_validate_fn(~context_type(),~c_owner(),~emr_owner(),~c_validate,~emr_validate)(context,owner)
def cemr_prepare(context:context_type(),+cursor:U32,owner:cemr_owner()) -> context_type() & (cemr_owner() & (cemr_view() & cemr_delta())):
  RP.pair_prepare_fn(~context_type(),~c_owner(),~emr_owner(),~c_view(),~emr_view(),~c_delta(),~emr_delta(),~c_prepare,~emr_prepare)(context,cursor,owner)
def cemr_commit(context:context_type(),owner:cemr_owner(),delta:cemr_delta(),+cursor:U32) -> context_type() & cemr_owner():
  RP.pair_commit_fn(~context_type(),~c_owner(),~emr_owner(),~c_delta(),~emr_delta(),~c_commit,~emr_commit)(context,owner,delta,cursor)
def cemr_release(context:context_type(),owner:cemr_owner()) -> context_type():
  RP.pair_release_fn(~context_type(),~c_owner(),~emr_owner(),~c_release,~emr_release)(context,owner)
def cemr_parameter_type() -> Data:
  RP.Param<context_type(),cemr_owner(),cemr_view(),cemr_delta(),cemr_validate,cemr_prepare,cemr_commit,cemr_release>
def pair_cemr(left:c_parameter_type(),right:emr_parameter_type()) -> cemr_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def cemr_parameter() -> cemr_parameter_type():
  pair_cemr(c_parameter(),emr_parameter())
def cemr_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (cemr_owner() & cemr_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~c_owner(),~c_parameter_type(),~emr_owner(),~emr_parameter_type(),~cemr_parameter_type(),~c_initialize,~emr_initialize,~pair_cemr,context,facts)
def acemr_owner() -> Type:
  a_owner() & cemr_owner()
def acemr_view() -> Data:
  RP.ViewPair<a_view(),cemr_view()>
def acemr_delta() -> Type:
  a_delta() & cemr_delta()
def acemr_validate(context:context_type(),owner:acemr_owner()) -> context_type() & (acemr_owner() & Bool):
  RP.pair_validate_fn(~context_type(),~a_owner(),~cemr_owner(),~a_validate,~cemr_validate)(context,owner)
def acemr_prepare(context:context_type(),+cursor:U32,owner:acemr_owner()) -> context_type() & (acemr_owner() & (acemr_view() & acemr_delta())):
  RP.pair_prepare_fn(~context_type(),~a_owner(),~cemr_owner(),~a_view(),~cemr_view(),~a_delta(),~cemr_delta(),~a_prepare,~cemr_prepare)(context,cursor,owner)
def acemr_commit(context:context_type(),owner:acemr_owner(),delta:acemr_delta(),+cursor:U32) -> context_type() & acemr_owner():
  RP.pair_commit_fn(~context_type(),~a_owner(),~cemr_owner(),~a_delta(),~cemr_delta(),~a_commit,~cemr_commit)(context,owner,delta,cursor)
def acemr_release(context:context_type(),owner:acemr_owner()) -> context_type():
  RP.pair_release_fn(~context_type(),~a_owner(),~cemr_owner(),~a_release,~cemr_release)(context,owner)
def acemr_parameter_type() -> Data:
  RP.Param<context_type(),acemr_owner(),acemr_view(),acemr_delta(),acemr_validate,acemr_prepare,acemr_commit,acemr_release>
def pair_acemr(left:a_parameter_type(),right:cemr_parameter_type()) -> acemr_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def acemr_parameter() -> acemr_parameter_type():
  pair_acemr(a_parameter(),cemr_parameter())
def acemr_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (acemr_owner() & acemr_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~a_owner(),~a_parameter_type(),~cemr_owner(),~cemr_parameter_type(),~acemr_parameter_type(),~a_initialize,~cemr_initialize,~pair_acemr,context,facts)
def all_owner() -> Type:
  q_owner() & acemr_owner()
type AllView is Data:
  AllView{query:QParam.Rows<Schema,Cmp.Access<U32>>,added:QParam.Rows<Schema,Unit>,changed:QParam.Rows<Schema,Unit>,event:Stream.EventView<Schema,event_type()>,removals:Stream.RemovalView<Schema,U32>,relations:Stream.RelationView<Schema,Publication>}
def all_view() -> Data:
  AllView
def all_nested_view() -> Data:
  RP.ViewPair<q_view(),acemr_view()>
def pack_all_view(nested:all_nested_view()) -> all_view():
  match nested:
    case RP.ViewPair{query,RP.ViewPair{added,RP.ViewPair{changed,RP.ViewPair{event,RP.ViewPair{removals,relations}}}}}:
      AllView{query,added,changed,event,removals,relations}
def all_delta() -> Type:
  q_delta() & acemr_delta()
def validate_all(context:context_type(),owner:all_owner()) -> context_type() & (all_owner() & Bool):
  RP.pair_validate_fn(~context_type(),~q_owner(),~acemr_owner(),~q_validate,~acemr_validate)(context,owner)
def prepare_all_nested(context:context_type(),+cursor:U32,owner:all_owner()) -> context_type() & (all_owner() & (all_nested_view() & all_delta())):
  RP.pair_prepare_fn(~context_type(),~q_owner(),~acemr_owner(),~q_view(),~acemr_view(),~q_delta(),~acemr_delta(),~q_prepare,~acemr_prepare)(context,cursor,owner)
def pack_all_prepare(prepared:context_type() & (all_owner() & (all_nested_view() & all_delta()))) -> context_type() & (all_owner() & (all_view() & all_delta())):
  match prepared:
    case (context,(owner,(nested,delta))):(context,(owner,(pack_all_view(nested),delta)))
def prepare_all(context:context_type(),+cursor:U32,owner:all_owner()) -> context_type() & (all_owner() & (all_view() & all_delta())):
  pack_all_prepare(prepare_all_nested(context,cursor,owner))
def commit_all(context:context_type(),owner:all_owner(),delta:all_delta(),+cursor:U32) -> context_type() & all_owner():
  RP.pair_commit_fn(~context_type(),~q_owner(),~acemr_owner(),~q_delta(),~acemr_delta(),~q_commit,~acemr_commit)(context,owner,delta,cursor)
def release_all(context:context_type(),owner:all_owner()) -> context_type():
  RP.pair_release_fn(~context_type(),~q_owner(),~acemr_owner(),~q_release,~acemr_release)(context,owner)
def all_parameter_type() -> Data:
  RP.Param<context_type(),all_owner(),all_view(),all_delta(),validate_all,prepare_all,commit_all,release_all>
def pair_all(left:q_parameter_type(),right:acemr_parameter_type()) -> all_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def all_parameter() -> all_parameter_type():
  pair_all(q_parameter(),acemr_parameter())
def all_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (all_owner() & all_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~q_owner(),~q_parameter_type(),~acemr_owner(),~acemr_parameter_type(),~all_parameter_type(),~q_initialize,~acemr_initialize,~pair_all,context,facts)

def callback_outcome(fail:Bool) -> Tx.Outcome<U32>:
  match fail:
    case True{}:Tx.Failure{7}
    case False{}:Tx.Success{}
def callback_sent(~H:Type,view:all_view(),owner:H) -> H & (Tx.Outcome<U32> & all_view()):
  (owner,(Tx.Failure{77},view))
def callback_selected(~H:Type,send:H -> U32 -> H,view:all_view(),fail:Bool,owner:H) -> H & (Tx.Outcome<U32> & all_view()):
  match fail:
    case False{}:(owner,(Tx.Success{},view))
    case True{}:callback_sent(~H,view,send(owner,999))
def callback_granted(~H:Type,caps:Cap.Send<H,U32>,input:all_view() & Bool,owner:H) -> H & (Tx.Outcome<U32> & all_view()):
  match caps input:
    case Cap.Send{send}, (view,fail):callback_selected(~H,send,view,fail,owner)
def callback(~H:Type,~caps:no_caps(H),input:all_view() & Bool,owner:H) -> H & (Tx.Outcome<U32> & all_view()):
  callback_granted(~H,caps,input,owner)

# A small actual scheduled lifecycle over the same provider composition as the
# full-capacity consumer. The setup keeps one reserved, inactive handle for a
# genuine MissingTargetEntity write outcome.
type Setup is Type:
  Ready{context:context_type()}
  SetupFailed{}
def seeded_column(graph:Relations.Graph<Schema>,result:Col.SwapOutcome<Schema,U32>) -> store_type() & Bool:
  match result:
    case Col.Accepted{column,_}:(Notice.Store{column,graph},True{})
    case Col.Rejected{column,_}:(Notice.Store{column,graph},False{})
def setup_created(created:W.Creation<Schema,store_type(),Unit,event_type()>) -> Setup:
  match created:
    case W.CreateRejected{_,_}:SetupFailed{}
    case W.Created{_,world}:Ready{Mixed.start(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,Leaf.provision(~Schema,~event_type(),Event.domain(~Schema,~event_type(),"values"),65536n),Unit{})}
def setup_with_factory(factory:W.Factory) -> Setup:
  setup_created(W.create(~Schema,~store_type(),~Unit,~event_type(),~empty_store,factory,Unit{}))
def setup() -> Setup:
  setup_with_factory(W.factory())

# JSON strings here are the frozen ASCII declaration names of this consumer.
def quoted(value:String) -> String:
  "\""++value++"\""
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
# Large observations stay as a tree of bounded text leaves until the host
# writes them. In particular, nesting a batch/domain/state no longer copies a
# previously rendered multi-megabyte child String through successive `++`s.
type JsonDoc is Data:
  JsonText{value:String}
  JsonParts{parts:List<&2,JsonDoc>,steps:Nat}
type JsonTask is Data:
  Visit{value:JsonDoc}
  More{remaining:List<&2,JsonDoc>}
  Text{remaining:String}
type JsonBuffer is Data:
  JsonBuffer{chunks:List<&2,String>,fragments:List<&2,String>,count:Nat}
def json_doc_steps(value:JsonDoc) -> Nat:
  match value:
    case JsonText{_}:3n
    case JsonParts{_,steps}:steps
def json_parts_steps(+parts:List<&2,JsonDoc>,accumulated:Nat) -> Nat:
  match parts:
    case []:Nat.add(2n,accumulated)
    case part <> rest:json_parts_steps(rest,Nat.add(Nat.add(accumulated,1n),json_doc_steps(part)))
def json_text(value:String) -> JsonDoc:
  JsonText{value}
def json_parts(+parts:List<&2,JsonDoc>) -> JsonDoc:
  JsonParts{parts,json_parts_steps(parts,0n)}
def json_string_renderer(~A:Data,~render:A -> String) -> A -> JsonDoc:
  value => JsonText{render(value)}
def json_array_reverse(~A:Data,~render:A -> JsonDoc,values:List<&2,A>,+reversed:List<&2,JsonDoc>,first:Bool) -> List<&2,JsonDoc>:
  match values:
    case []:JsonText{"]"} <> reversed
    case value <> rest:
      match first:
        case True{}:json_array_reverse(~A,~render,rest,render(value) <> reversed,False{})
        case False{}:json_array_reverse(~A,~render,rest,render(value) <> JsonText{","} <> reversed,False{})
def json_array(~A:Data,~render:A -> JsonDoc,values:List<&2,A>) -> JsonDoc:
  json_parts(List.reverse(&2,JsonDoc,json_array_reverse(~A,~render,values,[JsonText{"["}],True{})))
def json_array_strings(~A:Data,~render:A -> String,values:List<&2,A>) -> JsonDoc:
  json_array(~A,~json_string_renderer(~A,~render),values)
def json_fragments_join(+fragments:List<&2,String>,+output:String) -> String:
  match fragments:
    case []:output
    case fragment <> rest:json_fragments_join(rest,String.append(fragment,output))
def json_flush(buffer:JsonBuffer) -> JsonBuffer:
  match buffer:
    case JsonBuffer{+chunks,+fragments,+count}:
      match count:
        case 0n:JsonBuffer{chunks,fragments,count}
        case 1n+more:JsonBuffer{json_fragments_join(fragments,"") <> chunks,[],0n}
def json_output_done_flushed(flushed:JsonBuffer) -> List<&2,String>:
  match flushed:
    case JsonBuffer{chunks,_,_}:List.reverse(&2,String,chunks)
def json_output_done(buffer:JsonBuffer) -> List<&2,String>:
  json_output_done_flushed(json_flush(buffer))
type JsonOutputState is Data:
  Continue{stack:List<&2,JsonTask>,buffer:JsonBuffer}
def json_output_transition(exceeds:Bool,length:Nat,buffer:JsonBuffer,remaining:String,rest:List<&2,JsonTask>) -> JsonOutputState:
  match exceeds:
    case False{}:
      match buffer:
        case JsonBuffer{chunks,fragments,count}:Continue{rest,JsonBuffer{chunks,remaining <> fragments,Nat.add(count,length)}}
    case True{}:
      match buffer:
        case JsonBuffer{chunks,fragments,count}:
          match count:
            case 0n:Continue{rest,JsonBuffer{remaining <> chunks,[],0n}}
            case 1n+more:Continue{Text{remaining} <> rest,json_flush(JsonBuffer{chunks,fragments,count})}
def json_output_loop(fuel:Nat,state:JsonOutputState) -> List<&2,String>:
  match fuel:
    case 0n:
      match state:
        case Continue{_,buffer}:json_output_done(buffer)
    case 1n+more:
      match state:
        case Continue{stack,buffer}:
          match stack:
            case []:json_output_done(buffer)
            case Visit{JsonText{value}} <> rest:json_output_loop(more,Continue{Text{value} <> rest,buffer})
            case Visit{JsonParts{parts,_}} <> rest:json_output_loop(more,Continue{More{parts} <> rest,buffer})
            case More{[]} <> rest:json_output_loop(more,Continue{rest,buffer})
            case More{part <> remaining} <> rest:json_output_loop(more,Continue{Visit{part} <> More{remaining} <> rest,buffer})
            case Text{SNil{}} <> rest:json_output_loop(more,Continue{rest,buffer})
            case Text{+remaining} <> rest:
              match buffer:
                case JsonBuffer{chunks,fragments,+count}:
                  match count:
                    case 0n:
                      +length = String.length(remaining)
                      exceeds = Nat.is_gt(length,4096n)
                      json_output_loop(more,json_output_transition(exceeds,length,JsonBuffer{chunks,fragments,count},remaining,rest))
                    case 1n+buffered:
                      +buffered = buffered
                      +length = String.length(remaining)
                      exceeds = Nat.is_gt(Nat.add(Nat.add(1n,buffered),length),4096n)
                      json_output_loop(more,json_output_transition(exceeds,length,JsonBuffer{chunks,fragments,count},remaining,rest))
def json_output(+value:JsonDoc) -> List<&2,String>:
  json_output_loop(json_doc_steps(value),Continue{[Visit{value}],JsonBuffer{[],[],0n}})
# JSON serialization walks large consumer lists with tail-recursive chunk
# transport. Each rendered value is retained once in reverse order, then a
# tail fold copies each bounded fragment once into the final String.
def list_chunk(first:Bool,rendered:String) -> String:
  match first:
    case True{}:rendered
    case False{}:String.append(",",rendered)
def list_chunks_reversed(~A:Data,~render:A -> String,values:List<&2,A>,+chunks:List<&2,String>,first:Bool) -> List<&2,String>:
  match values:
    case []:chunks
    case value <> rest:list_chunks_reversed(~A,~render,rest,list_chunk(first,render(value)) <> chunks,False{})
def list_json_tail(chunks:List<&2,String>,+output:String) -> String:
  match chunks:
    case []:output
    case chunk <> rest:list_json_tail(rest,String.append(chunk,output))
def list_json(~A:Data,~render:A -> String,values:List<&2,A>) -> String:
  String.append("[",list_json_tail(list_chunks_reversed(~A,~render,values,[],True{}),"]"))
def handle_json(value:W.Handle<Schema>) -> String:
  match value:
    case W.Handle{namespace,id}:"{\"namespace\":"++U32.show(namespace)++",\"id\":"++U32.show(id)++"}"
def kind_json(value:Relations.RelationKind) -> String:
  match value:
    case Relations.Ordinary{}:"\"ordinary\""
    case Relations.Hierarchy{}:"\"hierarchy\""
def descriptor_json(value:Relations.Descriptor<Schema>) -> String:
  match value:
    case Relations.Descriptor{key,name,inverse,kind}:"{\"key\":"++U32.show(key)++",\"name\":"++quoted(name)++",\"inverse\":"++quoted(inverse)++",\"kind\":"++kind_json(kind)++"}"
def operation_json(value:Relations.Operation) -> String:
  match value:
    case Relations.Relate{}:"\"relate\""
    case Relations.ReorderChildren{}:"\"reorder\""
def error_json(value:Relations.Error) -> String:
  match value:
    case Relations.MissingEntity{source}:"{\"kind\":\"missingEntity\",\"source\":"++U32.show(source)++"}"
    case Relations.MissingTargetEntity{source,target,relation}:"{\"kind\":\"missingTarget\",\"source\":"++U32.show(source)++",\"target\":"++U32.show(target)++",\"relation\":"++quoted(relation)++"}"
    case Relations.SelfRelationNotAllowed{source,relation}:"{\"kind\":\"self\",\"source\":"++U32.show(source)++",\"relation\":"++quoted(relation)++"}"
    case Relations.HierarchyCycle{source,target,relation}:"{\"kind\":\"cycle\",\"source\":"++U32.show(source)++",\"target\":"++U32.show(target)++",\"relation\":"++quoted(relation)++"}"
    case Relations.MissingChildEntity{source,child,relation}:"{\"kind\":\"missingChild\",\"source\":"++U32.show(source)++",\"child\":"++U32.show(child)++",\"relation\":"++quoted(relation)++"}"
    case Relations.DuplicateChild{source,child,relation}:"{\"kind\":\"duplicateChild\",\"source\":"++U32.show(source)++",\"child\":"++U32.show(child)++",\"relation\":"++quoted(relation)++"}"
    case Relations.ChildNotRelatedToParent{source,child,relation}:"{\"kind\":\"unrelatedChild\",\"source\":"++U32.show(source)++",\"child\":"++U32.show(child)++",\"relation\":"++quoted(relation)++"}"
    case Relations.ChildSetMismatch{source,relation}:"{\"kind\":\"childSetMismatch\",\"source\":"++U32.show(source)++",\"relation\":"++quoted(relation)++"}"
def failure_json(value:Relations.Failure<Schema>) -> String:
  match value:
    case Relations.Failure{relation,operation,source,target,error}:"{\"relation\":"++descriptor_json(relation)++",\"operation\":"++operation_json(operation)++",\"source\":"++U32.show(source)++",\"target\":"++U32.show(target)++",\"error\":"++error_json(error)++"}"
def removal_json(value:Rm.Record<Schema,Identity.Declaration<Schema,U32>>) -> String:
  match value:
    case Rm.Removed{entity,identity}:"{\"entity\":"++handle_json(entity)++",\"component\":"++quoted(Identity.key(~Schema,~U32,identity))++"}"
    case Rm.Despawned{entity}:"{\"kind\":\"despawned\",\"entity\":"++handle_json(entity)++"}"
def publication_json(value:Publication) -> String:
  match value:
    case Value{number}:"{\"kind\":\"value\",\"value\":"++U32.show(number)++"}"
    case Removed{record}:"{\"kind\":\"removed\",\"record\":"++removal_json(record)++"}"
def frame_json(value:Relations.CleanupFrame<Schema>) -> String:
  match value:
    case Relations.CleanupEnter{id}:"{\"kind\":\"enter\",\"id\":"++U32.show(id)++"}"
    case Relations.CleanupDescriptors{id,remaining}:"{\"kind\":\"descriptors\",\"id\":"++U32.show(id)++",\"remaining\":"++list_json(~Relations.Descriptor<Schema>,~descriptor_json,remaining)++"}"
    case Relations.CleanupChildren{id,descriptor,remaining,children}:"{\"kind\":\"children\",\"id\":"++U32.show(id)++",\"descriptor\":"++descriptor_json(descriptor)++",\"remaining\":"++list_json(~Relations.Descriptor<Schema>,~descriptor_json,remaining)++",\"children\":"++list_json(~U32,~U32.show,children)++"}"
    case Relations.CleanupFinish{id}:"{\"kind\":\"finish\",\"id\":"++U32.show(id)++"}"
def notice_json(value:event_type()) -> String:
  match value:
    case Notice.Original{event}:"{\"kind\":\"original\",\"event\":"++publication_json(event)++"}"
    case Notice.RelationFailed{failure}:"{\"kind\":\"relationFailure\",\"failure\":"++failure_json(failure)++"}"
    case Notice.ComponentRemoved{id}:"{\"kind\":\"componentRemoved\",\"id\":"++U32.show(id)++"}"
    case Notice.CleanupPaused{frames}:"{\"kind\":\"cleanupPaused\",\"frames\":"++list_json(~Relations.CleanupFrame<Schema>,~frame_json,frames)++"}"
def edge_json(value:Relations.Edge<Schema>) -> String:
  match value:
    case Relations.Edge{relation,source,target}:"{\"relation\":"++descriptor_json(relation)++",\"source\":"++U32.show(source)++",\"target\":"++U32.show(target)++"}"
def inverse_json(value:Relations.Inverse<Schema>) -> String:
  match value:
    case Relations.Inverse{relation,target,sources}:"{\"relation\":"++descriptor_json(relation)++",\"target\":"++U32.show(target)++",\"sources\":"++list_json(~U32,~U32.show,sources)++"}"
def graph_json(value:Relations.Graph<Schema>) -> String:
  match value:
    case Relations.Graph{edges,inverses}:"{\"edges\":"++list_json(~Relations.Edge<Schema>,~edge_json,edges)++",\"inverses\":"++list_json(~Relations.Inverse<Schema>,~inverse_json,inverses)++"}"
type ComponentObservation is Data:
  ComponentObservation{entity:W.Handle<Schema>,value:Maybe<&2,Nat>,added:U32,changed:U32}
type StoreObservation is Data:
  StoreObservation{graph:Relations.Graph<Schema>,components:List<&2,ComponentObservation>}
type LiveScan is Data:
  LiveScan{slots:List<&2,Bool>,active:List<&2,W.Handle<Schema>>,inactiveReservations:List<&2,W.Handle<Schema>>}
type WorldObservation is Data:
  WorldObservation{namespace:U32,nextId:U32,highWater:U32,live:List<&2,Bool>,inactiveReservations:List<&2,W.Handle<Schema>>,capacity:U32,depth:Nat,components:List<&2,ComponentObservation>,resource:Unit,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,pending:U32,graph:Relations.Graph<Schema>,events:List<&2,event_type()>}
type LiveScanPhase is Type:
  LiveScanReady{live:Array<Bool>,index:Nat,slots:List<&2,Bool>,active:List<&2,W.Handle<Schema>>,inactiveReservations:List<&2,W.Handle<Schema>>}
  LiveScanRead{observed:Array<Bool> & Bool,index:Nat,slots:List<&2,Bool>,active:List<&2,W.Handle<Schema>>,inactiveReservations:List<&2,W.Handle<Schema>>}
def live_scan_update(slot_live:Bool,positive:Bool,allocated:Bool,+index:Nat,+namespace:U32,live:Array<Bool>,+slots:List<&2,Bool>,+active:List<&2,W.Handle<Schema>>,+inactiveReservations:List<&2,W.Handle<Schema>>) -> LiveScanPhase:
  match slot_live:
    case False{}:
      match positive:
        case False{}:LiveScanReady{live,(index + 1n : Nat),slot_live <> slots,active,inactiveReservations}
        case True{}:
          match allocated:
            case False{}:LiveScanReady{live,(index + 1n : Nat),slot_live <> slots,active,inactiveReservations}
            case True{}:LiveScanReady{live,(index + 1n : Nat),slot_live <> slots,active,W.Handle{namespace,U32.from_nat(index)} <> inactiveReservations}
    case True{}:
      match positive:
        case False{}:LiveScanReady{live,(index + 1n : Nat),slot_live <> slots,active,inactiveReservations}
        case True{}:
          match allocated:
            case False{}:LiveScanReady{live,(index + 1n : Nat),slot_live <> slots,active,inactiveReservations}
            case True{}:LiveScanReady{live,(index + 1n : Nat),slot_live <> slots,W.Handle{namespace,U32.from_nat(index)} <> active,inactiveReservations}
def live_scan_start_read(live:Array<Bool>,+index:Nat,slots:List<&2,Bool>,active:List<&2,W.Handle<Schema>>,inactiveReservations:List<&2,W.Handle<Schema>>) -> LiveScanPhase:
  LiveScanRead{Array.get(Bool,live,U32.from_nat(index)),index,slots,active,inactiveReservations}
def live_slots_loop(fuel:Nat,remaining:Nat,+namespace:U32,+highWater:U32,phase:LiveScanPhase) -> Array<Bool> & LiveScan:
  match fuel remaining phase:
    case 0n _ LiveScanReady{live,index,slots,active,inactiveReservations}:(live,LiveScan{List.reverse(&2,Bool,slots),List.reverse(&2,W.Handle<Schema>,active),List.reverse(&2,W.Handle<Schema>,inactiveReservations)})
    case 0n _ LiveScanRead{(live,_),index,slots,active,inactiveReservations}:(live,LiveScan{List.reverse(&2,Bool,slots),List.reverse(&2,W.Handle<Schema>,active),List.reverse(&2,W.Handle<Schema>,inactiveReservations)})
    case 1n+more 0n LiveScanReady{live,index,slots,active,inactiveReservations}:(live,LiveScan{List.reverse(&2,Bool,slots),List.reverse(&2,W.Handle<Schema>,active),List.reverse(&2,W.Handle<Schema>,inactiveReservations)})
    case 1n+more 1n++rest LiveScanReady{live,+index,slots,active,inactiveReservations}:live_slots_loop(more,1n+rest,namespace,highWater,live_scan_start_read(live,index,slots,active,inactiveReservations))
    case 1n+more 0n LiveScanRead{(live,_),index,slots,active,inactiveReservations}:(live,LiveScan{List.reverse(&2,Bool,slots),List.reverse(&2,W.Handle<Schema>,active),List.reverse(&2,W.Handle<Schema>,inactiveReservations)})
    case 1n+more 1n++rest LiveScanRead{(live,slot_live),+index,slots,active,inactiveReservations}:live_slots_loop(more,rest,namespace,highWater,live_scan_update(slot_live,U32.is_gt(U32.from_nat(index),0),U32.is_le(U32.from_nat(index),highWater),index,namespace,live,slots,active,inactiveReservations))
def live_slots_sized(+namespace:U32,+highWater:U32,sized:Array<Bool> & U32) -> Array<Bool> & LiveScan:
  match sized:
    case (live,+size):live_slots_loop(Nat.mul(2n,U32.to_nat(size)),U32.to_nat(size),namespace,highWater,LiveScanReady{live,0n,[],[],[]})
def live_slots(+namespace:U32,+highWater:U32,live:Array<Bool>) -> Array<Bool> & LiveScan:
  live_slots_sized(namespace,highWater,Array.size(Bool,live))
def handle_id(entity:W.Handle<Schema>) -> U32:
  match entity:
    case W.Handle{_,id}:id
def duplicate_nat_step(result:Nat & Nat) -> Nat & Nat:
  match result:
    case (left,right):(1n+left,1n+right)
def duplicate_nat(n:Nat) -> Nat & Nat:
  match n:
    case 0n:(0n,0n)
    case 1n+rest:duplicate_nat_step(duplicate_nat(rest))
def physical_projection_duplicated(result:Nat & Nat) -> U32 & Nat:
  match result:
    case (raw,observed):(U32.from_nat(raw),observed)
def physical_projection_from_nat(value:Nat) -> U32 & Nat:
  physical_projection_duplicated(duplicate_nat(value))
def physical_projection(value:U32) -> U32 & Nat:
  physical_projection_from_nat(U32.to_nat(value))
def component_stamp_read(+entity:W.Handle<Schema>,value:Maybe<&2,Nat>,observed:Col.Column<Schema,U32> & Lifecycle.Stamp) -> Col.Column<Schema,U32> & ComponentObservation:
  match observed:
    case (column,Lifecycle.Stamp{added,changed}):(column,ComponentObservation{entity,value,added,changed})
def component_value_read(+entity:W.Handle<Schema>,observed:Col.Column<Schema,U32> & Maybe<&2,Nat>) -> Col.Column<Schema,U32> & ComponentObservation:
  match observed:
    case (column,value):component_stamp_read(entity,value,Col.lifecycle(~Schema,~U32,column,handle_id(entity)))
def component_read(+entity:W.Handle<Schema>,column:Col.Column<Schema,U32>) -> Col.Column<Schema,U32> & ComponentObservation:
  component_value_read(entity,Col.view(~Schema,~U32,~Nat,~physical_projection,column,handle_id(entity)))
type ComponentRowsPhase is Type:
  ComponentRowsReady{handles:List<&2,W.Handle<Schema>>,column:Col.Column<Schema,U32>,reversed:List<&2,ComponentObservation>}
  ComponentRowsRead{rest:List<&2,W.Handle<Schema>>,observed:Col.Column<Schema,U32> & ComponentObservation,reversed:List<&2,ComponentObservation>}
def component_rows_loop(fuel:Nat,phase:ComponentRowsPhase) -> Col.Column<Schema,U32> & List<&2,ComponentObservation>:
  match fuel phase:
    case 0n ComponentRowsReady{handles,column,reversed}:(column,List.reverse(&2,ComponentObservation,reversed))
    case 0n ComponentRowsRead{_,(column,_),reversed}:(column,List.reverse(&2,ComponentObservation,reversed))
    case 1n+more ComponentRowsReady{[],column,reversed}:(column,List.reverse(&2,ComponentObservation,reversed))
    case 1n+more ComponentRowsReady{entity <> rest,column,reversed}:component_rows_loop(more,ComponentRowsRead{rest,component_read(entity,column),reversed})
    case 1n+more ComponentRowsRead{rest,(column,observation),reversed}:component_rows_loop(more,ComponentRowsReady{rest,column,observation <> reversed})
def store_component_rows_finish(+graph:Relations.Graph<Schema>,scanned:Col.Column<Schema,U32> & List<&2,ComponentObservation>) -> store_type() & StoreObservation:
  match scanned:
    case (components,rows):(Notice.Store{components,graph},StoreObservation{graph,rows})
def store_component_rows(store:store_type(),handles:List<&2,W.Handle<Schema>>,capacity:U32) -> store_type() & StoreObservation:
  match store:
    case Notice.Store{components,+graph}:store_component_rows_finish(graph,component_rows_loop(Nat.mul(2n,U32.to_nat(capacity)),ComponentRowsReady{handles,components,[]}))
def world_snapshot_store(+namespace:U32,+nextId:U32,+highWater:U32,live:Array<Bool>,slots:List<&2,Bool>,inactiveReservations:List<&2,W.Handle<Schema>>,+capacity:U32,+depth:Nat,+resource:Unit,+events:List<&2,event_type()>,pendingCommands:List<(world_type() -> world_type())>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,pending:U32,observed:store_type() & StoreObservation) -> world_type() & WorldObservation:
  match observed:
    case (store,StoreObservation{graph,components}):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pendingCommands,registrations,nextSystemId,clock},WorldObservation{namespace,nextId,highWater,slots,inactiveReservations,capacity,depth,components,resource,registrations,nextSystemId,clock,pending,graph,events})
def world_snapshot_live(namespace:U32,nextId:U32,highWater:U32,+capacity:U32,depth:Nat,store:store_type(),resource:Unit,+events:List<&2,event_type()>,pendingCommands:List<(world_type() -> world_type())>,+registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,pending:U32,scanned:Array<Bool> & LiveScan) -> world_type() & WorldObservation:
  match scanned:
    case (live,LiveScan{slots,active,inactiveReservations}):world_snapshot_store(namespace,nextId,highWater,live,slots,inactiveReservations,capacity,depth,resource,events,pendingCommands,registrations,nextSystemId,clock,pending,store_component_rows(store,active,capacity))
def world_snapshot_fields(pending:U32,world:world_type()) -> world_type() & WorldObservation:
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,+resource,+events,pendingCommands,+registrations,+nextSystemId,+clock}:world_snapshot_live(namespace,nextId,highWater,capacity,depth,store,resource,events,pendingCommands,registrations,nextSystemId,clock,pending,live_slots(namespace,highWater,live))
def world_snapshot_counted(observed:world_type() & U32) -> world_type() & WorldObservation:
  match observed:
    case (world,pending):world_snapshot_fields(pending,world)
def world_snapshot(world:world_type()) -> world_type() & WorldObservation:
  world_snapshot_counted(W.pending_count(~Schema,~store_type(),~Unit,~event_type(),world))
def context_snapshot_join(state:Mixed.State<Schema,Publication,family_type(),Unit>,tick:Nat,observed:world_type() & WorldObservation) -> context_type() & WorldObservation:
  match observed:
    case (world,image):(Route.Runtime{world,state,tick},image)
def context_snapshot(context:context_type()) -> context_type() & WorldObservation:
  match context:
    case Route.Runtime{world,state,tick}:context_snapshot_join(state,tick,world_snapshot(world))
def component_value_json(value:Maybe<&2,Nat>) -> String:
  match value:
    case None{}:"null"
    case Some{value}:Nat.show(value)
def component_observation_json(value:ComponentObservation) -> String:
  match value:
    case ComponentObservation{entity,value,added,changed}:"{\"entity\":"++handle_json(entity)++",\"value\":"++component_value_json(value)++",\"added\":"++U32.show(added)++",\"changed\":"++U32.show(changed)++"}"
def registration_json(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"{\"id\":"++U32.show(id)++",\"name\":"++quoted(name)++",\"access\":"++list_json(~String,~quoted,access)++"}"
def resource_json(value:Unit) -> String:
  match value:
    case Unit{}:"unit"
def world_observation_json(value:WorldObservation) -> String:
  match value:
    case WorldObservation{namespace,nextId,highWater,live,inactiveReservations,capacity,depth,components,resource,registrations,nextSystemId,clock,pending,graph,events}:"{\"namespace\":"++U32.show(namespace)++",\"nextId\":"++U32.show(nextId)++",\"highWater\":"++U32.show(highWater)++",\"live\":"++list_json(~Bool,~boolean,live)++",\"inactiveReservations\":"++list_json(~W.Handle<Schema>,~handle_json,inactiveReservations)++",\"capacity\":"++U32.show(capacity)++",\"depth\":"++Nat.show(depth)++",\"components\":"++list_json(~ComponentObservation,~component_observation_json,components)++",\"resource\":\""++resource_json(resource)++"\",\"registrations\":"++list_json(~W.RegistrationMeta,~registration_json,registrations)++",\"nextSystemId\":"++U32.show(nextSystemId)++",\"clock\":"++U32.show(clock)++",\"pending\":"++U32.show(pending)++",\"graph\":"++graph_json(graph)++",\"events\":"++list_json(~event_type(),~notice_json,events)++"}"
def component_access_json(value:Cmp.Access<U32>) -> String:
  match value:
    case Cmp.Found{value}:"{\"found\":"++U32.show(value)++"}"
    case Cmp.ComponentAbsent{}:"{\"componentAbsent\":true}"
    case Cmp.MissingEntity{}:"{\"missingEntity\":true}"
def filter_row_json(value:IQ.ProjectedRow<Schema,Unit>) -> String:
  match value:
    case IQ.ProjectedRow{entity,_}:handle_json(entity)
def filter_query_json(value:a_view()) -> String:
  match value:
    case QParam.Rows{rows}:list_json(~IQ.ProjectedRow<Schema,Unit>,~filter_row_json,rows)
def row_json(value:IQ.ProjectedRow<Schema,Cmp.Access<U32>>) -> String:
  match value:
    case IQ.ProjectedRow{entity,data}:"{\"entity\":"++handle_json(entity)++",\"data\":"++component_access_json(data)++"}"
def query_json(value:q_view()) -> String:
  match value:
    case QParam.Rows{rows}:list_json(~IQ.ProjectedRow<Schema,Cmp.Access<U32>>,~row_json,rows)
def event_json(value:e_view()) -> String:
  match value:
    case Stream.EventView{Ev.Reading{values,lagged}}:"{\"values\":"++list_json(~event_type(),~notice_json,values)++",\"lagged\":"++boolean(lagged)++"}"
def removals_json(value:m_view()) -> String:
  match value:
    case Stream.RemovalView{records}:list_json(~Rm.Record<Schema,Identity.Declaration<Schema,U32>>,~removal_json,records)
def key_reading_json(value:KRead.KeyReading<Schema,event_type()>) -> String:
  match value:
    case KRead.KeyReading{KD.DeclaredKey{key},values,lagged}:"{\"key\":"++U32.show(key)++",\"values\":"++list_json(~event_type(),~notice_json,values)++",\"lagged\":"++boolean(lagged)++"}"
def relations_json(value:r_view()) -> String:
  match value:
    case Stream.RelationView{readings}:list_json(~KRead.KeyReading<Schema,event_type()>,~key_reading_json,readings)
def view_json(value:all_view()) -> String:
  match value:
    case AllView{query,added,changed,event,removals,relations}:
      "{\"query\":"++query_json(query)++",\"eventA\":"++event_json(event)++",\"added\":"++filter_query_json(added)++",\"changed\":"++filter_query_json(changed)++",\"removals\":"++removals_json(removals)++",\"relations\":"++relations_json(relations)++"}"

# Direct retained-state image. Reader results alone do not show batch boundaries,
# dormant positions, per-descriptor isolation, or whole-batch drop watermarks.
def position_json(position:Ev.Position) -> String:
  match position:
    case Ev.Position{id,cursor,registeredAt}:"{\"id\":"++U32.show(id)++",\"cursor\":"++Nat.show(cursor)++",\"registeredAt\":"++Nat.show(registeredAt)++"}"
def position_list_json(values:List<&2,Ev.Position>) -> String:
  list_json(~Ev.Position,~position_json,values)
def notice_batch_json(batch:Ev.Batch<event_type()>) -> String:
  match batch:
    case Ev.Batch{tick,values}:"{\"tick\":"++Nat.show(tick)++",\"values\":"++list_json(~event_type(),~notice_json,values)++"}"
def notice_batches_json(values:List<&2,Ev.Batch<event_type()>>) -> String:
  list_json(~Ev.Batch<event_type()>,~notice_batch_json,values)
def family_stream_json(family:family_type()) -> String:
  match family:
    case Leaf.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:
      match domain:
        case Event.Domain{key}:"{\"domain\":"++quoted(key)++",\"batches\":"++notice_batches_json(batches)++",\"positions\":"++position_list_json(positions)++",\"nextReader\":"++U32.show(nextReader)++",\"frameStart\":"++Nat.show(frameStart)++",\"boundary\":"++Nat.show(boundary)++",\"capacity\":"++Nat.show(capacity)++",\"dropped\":"++Nat.show(dropped)++"}"
def failure_batch_json(batch:KQ.Batch<event_type()>) -> String:
  match batch:
    case KQ.Batch{tick,count,values}:"{\"tick\":"++Nat.show(tick)++",\"count\":"++Nat.show(count)++",\"values\":"++list_json(~event_type(),~notice_json,values)++"}"
def failure_batches_json(values:List<&2,KQ.Batch<event_type()>>) -> String:
  list_json(~KQ.Batch<event_type()>,~failure_batch_json,values)
def failure_queue_json(queue:KQ.Queue<event_type()>) -> String:
  match queue:
    case KQ.Queue{front,back,size,dropped}:"{\"front\":"++failure_batches_json(front)++",\"back\":"++failure_batches_json(back)++",\"size\":"++Nat.show(size)++",\"dropped\":"++Nat.show(dropped)++"}"
def u32s_json(values:List<&2,U32>) -> String:
  list_json(~U32,~U32.show,values)
def failure_domain_json(domain:KD.Domain<Schema,event_type()>) -> String:
  match domain:
    case KD.Domain{key,queue,readers}:
      match key:
        case KD.DeclaredKey{id}:"{\"key\":"++U32.show(id)++",\"queue\":"++failure_queue_json(queue)++",\"readers\":"++u32s_json(readers)++"}"
def failure_domains_json(values:List<&2,KD.Domain<Schema,event_type()>>) -> String:
  list_json(~KD.Domain<Schema,event_type()>,~failure_domain_json,values)
def publication_batch_json(batch:Ev.Batch<Publication>) -> String:
  match batch:
    case Ev.Batch{tick,values}:"{\"tick\":"++Nat.show(tick)++",\"values\":"++list_json(~Publication,~publication_json,values)++"}"
def publication_batches_json(values:List<&2,Ev.Batch<Publication>>) -> String:
  list_json(~Ev.Batch<Publication>,~publication_batch_json,values)
def family_state_image(state:Family.State<Publication,family_type(),Unit>) -> Family.State<Publication,family_type(),Unit> & String:
  match state:
    case Family.State{+family,owners,+journal,+frameStart}:
      (Family.State{family,owners,journal,frameStart},"{\"stream\":"++family_stream_json(family)++",\"journal\":"++publication_batches_json(journal)++",\"frameStart\":"++Nat.show(frameStart)++"}")
def failure_state_image(failures:Mixed.Failures<Schema,Publication>) -> Mixed.Failures<Schema,Publication> & String:
  match failures:
    case Mixed.Failures{+domains,+positions,+tick,+frameStart,+boundary,+capacity,+nextReader}:
      (Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader},"{\"domains\":"++failure_domains_json(domains)++",\"positions\":"++position_list_json(positions)++",\"tick\":"++Nat.show(tick)++",\"frameStart\":"++Nat.show(frameStart)++",\"boundary\":"++Nat.show(boundary)++",\"capacity\":"++Nat.show(capacity)++",\"nextReader\":"++U32.show(nextReader)++"}")
def failure_state_json_result(result:Mixed.Failures<Schema,Publication> & String) -> String:
  match result:
    case (_,image):image
def failure_state_json(failures:Mixed.Failures<Schema,Publication>) -> String:
  failure_state_json_result(failure_state_image(failures))
def mixed_state_image_parts(typedResult:Family.State<Publication,family_type(),Unit> & String,failuresResult:Mixed.Failures<Schema,Publication> & String) -> Mixed.State<Schema,Publication,family_type(),Unit> & String:
  match typedResult:
    case (typed,typedImage):
      match failuresResult:
        case (failures,failureImage):(Mixed.State{typed,failures},"{\"typed\":"++typedImage++",\"relationFailures\":"++failureImage++"}")
def mixed_state_image(state:Mixed.State<Schema,Publication,family_type(),Unit>) -> Mixed.State<Schema,Publication,family_type(),Unit> & String:
  match state:
    case Mixed.State{typed,+failures}:mixed_state_image_parts(family_state_image(typed),failure_state_image(failures))
def metadata_image_join(ticks:Nat & Nat,stateResult:Mixed.State<Schema,Publication,family_type(),Unit> & String) -> metadata_type() & String:
  match ticks:
    case (stored,jsonTick):
      match stateResult:
        case (state,image):((state,stored),"{\"routeTick\":"++Nat.show(jsonTick)++",\"shared\":"++image++"}")
def metadata_image(metadata:metadata_type()) -> metadata_type() & String:
  match metadata:
    case (state,tick):metadata_image_join(duplicate_nat(tick),mixed_state_image(state))
def context_image_join(world:world_type(),image:WorldObservation,stateResult:metadata_type() & String) -> context_type() & String:
  match stateResult:
    case (metadata,sharedImage):(Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata),"{\"world\":"++world_observation_json(image)++",\"metadata\":"++sharedImage++"}")
def context_image_observed(worldResult:world_type() & WorldObservation,metadataResult:metadata_type() & String) -> context_type() & String:
  match worldResult:
    case (world,image):
      match metadataResult:
        case (metadata,sharedImage):context_image_join(world,image,(metadata,sharedImage))
def context_image_parts(parts:world_type() & metadata_type()) -> context_type() & String:
  match parts:
    case (world,metadata):context_image_observed(world_snapshot(world),metadata_image(metadata))
def context_image(context:context_type()) -> context_type() & String:
  context_image_parts(Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))

# Structured equivalents for the reached full-capacity observation path. Small
# scalar records may still use the frozen String serializers above; list and
# nested-state boundaries remain structured so a 65,537-value batch is never
# copied through an enclosing JSON String.
def json_quote_text(value:String) -> JsonDoc:
  json_parts([JsonText{"\""},JsonText{value},JsonText{"\""}])
def json_trace_entry(value:JsonDoc) -> JsonDoc:
  json_parts([JsonText{"\""},value,JsonText{"\""}])
def json_doc_identity(value:JsonDoc) -> JsonDoc:
  value
def json_frame(value:Relations.CleanupFrame<Schema>) -> JsonDoc:
  match value:
    case Relations.CleanupEnter{id}:json_parts([JsonText{"{\"kind\":\"enter\",\"id\":"},JsonText{U32.show(id)},JsonText{"}"}])
    case Relations.CleanupFinish{id}:json_parts([JsonText{"{\"kind\":\"finish\",\"id\":"},JsonText{U32.show(id)},JsonText{"}"}])
    case Relations.CleanupDescriptors{id,remaining}:json_parts([JsonText{"{\"kind\":\"descriptors\",\"id\":"},JsonText{U32.show(id)},JsonText{",\"remaining\":"},json_array_strings(~Relations.Descriptor<Schema>,~descriptor_json,remaining),JsonText{"}"}])
    case Relations.CleanupChildren{id,descriptor,remaining,children}:json_parts([JsonText{"{\"kind\":\"children\",\"id\":"},JsonText{U32.show(id)},JsonText{",\"descriptor\":"},JsonText{descriptor_json(descriptor)},JsonText{",\"remaining\":"},json_array_strings(~Relations.Descriptor<Schema>,~descriptor_json,remaining),JsonText{",\"children\":"},json_array_strings(~U32,~U32.show,children),JsonText{"}"}])
def json_publication(value:Publication) -> JsonDoc:
  match value:
    case Value{number}:json_text(publication_json(value))
    case Removed{record}:json_parts([JsonText{"{\"kind\":\"removed\",\"record\":"},JsonText{removal_json(record)},JsonText{"}"}])
def json_notice(value:event_type()) -> JsonDoc:
  match value:
    case Notice.Original{event}:json_parts([JsonText{"{\"kind\":\"original\",\"event\":"},json_publication(event),JsonText{"}"}])
    case Notice.RelationFailed{failure}:json_parts([JsonText{"{\"kind\":\"relationFailure\",\"failure\":"},json_text(failure_json(failure)),JsonText{"}"}])
    case Notice.ComponentRemoved{id}:json_parts([JsonText{"{\"kind\":\"componentRemoved\",\"id\":"},JsonText{U32.show(id)},JsonText{"}"}])
    case Notice.CleanupPaused{frames}:json_parts([JsonText{"{\"kind\":\"cleanupPaused\",\"frames\":"},json_array(~Relations.CleanupFrame<Schema>,~json_frame,frames),JsonText{"}"}])
def json_list_frames(values:List<&2,Relations.CleanupFrame<Schema>>) -> JsonDoc:
  json_array(~Relations.CleanupFrame<Schema>,~json_frame,values)
def json_list_trace(values:List<&2,JsonDoc>) -> JsonDoc:
  json_array(~JsonDoc,~json_trace_entry,values)
def json_list_notices(values:List<&2,event_type()>) -> JsonDoc:
  json_array(~event_type(),~json_notice,values)
def json_list_publications(values:List<&2,Publication>) -> JsonDoc:
  json_array(~Publication,~json_publication,values)
def json_list_positions(values:List<&2,Ev.Position>) -> JsonDoc:
  json_array_strings(~Ev.Position,~position_json,values)
def json_list_removals(values:List<&2,Rm.Record<Schema,Identity.Declaration<Schema,U32>>>) -> JsonDoc:
  json_array_strings(~Rm.Record<Schema,Identity.Declaration<Schema,U32>>,~removal_json,values)
def json_list_rows(values:List<&2,ComponentObservation>) -> JsonDoc:
  json_array_strings(~ComponentObservation,~component_observation_json,values)
def json_list_registrations(values:List<&2,W.RegistrationMeta>) -> JsonDoc:
  json_array_strings(~W.RegistrationMeta,~registration_json,values)
def json_inverse(value:Relations.Inverse<Schema>) -> JsonDoc:
  match value:
    case Relations.Inverse{relation,target,sources}:json_parts([JsonText{"{\"relation\":"},JsonText{descriptor_json(relation)},JsonText{",\"target\":"},JsonText{U32.show(target)},JsonText{",\"sources\":"},json_array_strings(~U32,~U32.show,sources),JsonText{"}"}])
def json_notice_batch(batch:Ev.Batch<event_type()>) -> JsonDoc:
  match batch:
    case Ev.Batch{tick,values}:json_parts([JsonText{"{\"tick\":"},JsonText{Nat.show(tick)},JsonText{",\"values\":"},json_list_notices(values),JsonText{"}"}])
def json_notice_batches(values:List<&2,Ev.Batch<event_type()>>) -> JsonDoc:
  json_array(~Ev.Batch<event_type()>,~json_notice_batch,values)
def json_family_stream(value:family_type()) -> JsonDoc:
  match value:
    case Leaf.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:
      match domain:
        case Event.Domain{key}:json_parts([JsonText{"{\"domain\":"},json_quote_text(key),JsonText{",\"batches\":"},json_notice_batches(batches),JsonText{",\"positions\":"},json_list_positions(positions),JsonText{",\"nextReader\":"},JsonText{U32.show(nextReader)},JsonText{",\"frameStart\":"},JsonText{Nat.show(frameStart)},JsonText{",\"boundary\":"},JsonText{Nat.show(boundary)},JsonText{",\"capacity\":"},JsonText{Nat.show(capacity)},JsonText{",\"dropped\":"},JsonText{Nat.show(dropped)},JsonText{"}"}])
def json_failure_batch(batch:KQ.Batch<event_type()>) -> JsonDoc:
  match batch:
    case KQ.Batch{tick,count,values}:json_parts([JsonText{"{\"tick\":"},JsonText{Nat.show(tick)},JsonText{",\"count\":"},JsonText{Nat.show(count)},JsonText{",\"values\":"},json_list_notices(values),JsonText{"}"}])
def json_failure_batches(values:List<&2,KQ.Batch<event_type()>>) -> JsonDoc:
  json_array(~KQ.Batch<event_type()>,~json_failure_batch,values)
def json_failure_queue(value:KQ.Queue<event_type()>) -> JsonDoc:
  match value:
    case KQ.Queue{front,back,size,dropped}:json_parts([JsonText{"{\"front\":"},json_failure_batches(front),JsonText{",\"back\":"},json_failure_batches(back),JsonText{",\"size\":"},JsonText{Nat.show(size)},JsonText{",\"dropped\":"},JsonText{Nat.show(dropped)},JsonText{"}"}])
def json_failure_domain(value:KD.Domain<Schema,event_type()>) -> JsonDoc:
  match value:
    case KD.Domain{key,queue,readers}:
      match key:
        case KD.DeclaredKey{id}:json_parts([JsonText{"{\"key\":"},JsonText{U32.show(id)},JsonText{",\"queue\":"},json_failure_queue(queue),JsonText{",\"readers\":"},json_array_strings(~U32,~U32.show,readers),JsonText{"}"}])
def json_failure_domains(values:List<&2,KD.Domain<Schema,event_type()>>) -> JsonDoc:
  json_array(~KD.Domain<Schema,event_type()>,~json_failure_domain,values)
def json_publication_batch(batch:Ev.Batch<Publication>) -> JsonDoc:
  match batch:
    case Ev.Batch{tick,values}:json_parts([JsonText{"{\"tick\":"},JsonText{Nat.show(tick)},JsonText{",\"values\":"},json_list_publications(values),JsonText{"}"}])
def json_publication_batches(values:List<&2,Ev.Batch<Publication>>) -> JsonDoc:
  json_array(~Ev.Batch<Publication>,~json_publication_batch,values)
def json_failure_state(failures:Mixed.Failures<Schema,Publication>) -> JsonDoc:
  match failures:
    case Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}:json_parts([JsonText{"{\"domains\":"},json_failure_domains(domains),JsonText{",\"positions\":"},json_list_positions(positions),JsonText{",\"tick\":"},JsonText{Nat.show(tick)},JsonText{",\"frameStart\":"},JsonText{Nat.show(frameStart)},JsonText{",\"boundary\":"},JsonText{Nat.show(boundary)},JsonText{",\"capacity\":"},JsonText{Nat.show(capacity)},JsonText{",\"nextReader\":"},JsonText{U32.show(nextReader)},JsonText{"}"}])
def json_family_state(state:Family.State<Publication,family_type(),Unit>) -> Family.State<Publication,family_type(),Unit> & JsonDoc:
  match state:
    case Family.State{+family,owners,+journal,+frameStart}:
      (Family.State{family,owners,journal,frameStart},json_parts([JsonText{"{\"stream\":"},json_family_stream(family),JsonText{",\"journal\":"},json_publication_batches(journal),JsonText{",\"frameStart\":"},JsonText{Nat.show(frameStart)},JsonText{"}"}]))
def json_mixed_state_parts(typedResult:Family.State<Publication,family_type(),Unit> & JsonDoc,+failures:Mixed.Failures<Schema,Publication>) -> Mixed.State<Schema,Publication,family_type(),Unit> & JsonDoc:
  match typedResult:
    case (typed,typedDoc):(Mixed.State{typed,failures},json_parts([JsonText{"{\"typed\":"},typedDoc,JsonText{",\"relationFailures\":"},json_failure_state(failures),JsonText{"}"}]))
def json_mixed_state(state:Mixed.State<Schema,Publication,family_type(),Unit>) -> Mixed.State<Schema,Publication,family_type(),Unit> & JsonDoc:
  match state:
    case Mixed.State{typed,+failures}:json_mixed_state_parts(json_family_state(typed),failures)
def json_metadata_join(ticks:Nat & Nat,stateResult:Mixed.State<Schema,Publication,family_type(),Unit> & JsonDoc) -> metadata_type() & JsonDoc:
  match ticks:
    case (stored,jsonTick):
      match stateResult:
        case (state,stateDoc):((state,stored),json_parts([JsonText{"{\"routeTick\":"},JsonText{Nat.show(jsonTick)},JsonText{",\"shared\":"},stateDoc,JsonText{"}"}]))
def json_metadata(value:metadata_type()) -> metadata_type() & JsonDoc:
  match value:
    case (state,tick):json_metadata_join(duplicate_nat(tick),json_mixed_state(state))
def json_graph(value:Relations.Graph<Schema>) -> JsonDoc:
  match value:
    case Relations.Graph{edges,inverses}:json_parts([JsonText{"{\"edges\":"},json_array_strings(~Relations.Edge<Schema>,~edge_json,edges),JsonText{",\"inverses\":"},json_array(~Relations.Inverse<Schema>,~json_inverse,inverses),JsonText{"}"}])
def json_world_observation(value:WorldObservation) -> JsonDoc:
  match value:
    case WorldObservation{namespace,nextId,highWater,live,inactiveReservations,capacity,depth,components,resource,registrations,nextSystemId,clock,pending,graph,events}:json_parts([JsonText{"{\"namespace\":"},JsonText{U32.show(namespace)},JsonText{",\"nextId\":"},JsonText{U32.show(nextId)},JsonText{",\"highWater\":"},JsonText{U32.show(highWater)},JsonText{",\"live\":"},json_array_strings(~Bool,~boolean,live),JsonText{",\"inactiveReservations\":"},json_array_strings(~W.Handle<Schema>,~handle_json,inactiveReservations),JsonText{",\"capacity\":"},JsonText{U32.show(capacity)},JsonText{",\"depth\":"},JsonText{Nat.show(depth)},JsonText{",\"components\":"},json_list_rows(components),JsonText{",\"resource\":\""},JsonText{resource_json(resource)},JsonText{"\",\"registrations\":"},json_list_registrations(registrations),JsonText{",\"nextSystemId\":"},JsonText{U32.show(nextSystemId)},JsonText{",\"clock\":"},JsonText{U32.show(clock)},JsonText{",\"pending\":"},JsonText{U32.show(pending)},JsonText{",\"graph\":"},json_graph(graph),JsonText{",\"events\":"},json_list_notices(events),JsonText{"}"}])
def json_context_image_join(world:world_type(),image:WorldObservation,metadataResult:metadata_type() & JsonDoc) -> context_type() & JsonDoc:
  match metadataResult:
    case (metadata,metadataDoc):(Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata),json_parts([JsonText{"{\"world\":"},json_world_observation(image),JsonText{",\"metadata\":"},metadataDoc,JsonText{"}"}]))
def json_context_image_observed(worldResult:world_type() & WorldObservation,metadataResult:metadata_type() & JsonDoc) -> context_type() & JsonDoc:
  match worldResult:
    case (world,image):json_context_image_join(world,image,metadataResult)
def json_context_image_parts(parts:world_type() & metadata_type()) -> context_type() & JsonDoc:
  match parts:
    case (world,metadata):json_context_image_observed(world_snapshot(world),json_metadata(metadata))
def json_context_image(context:context_type()) -> context_type() & JsonDoc:
  json_context_image_parts(Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def json_query_view(value:q_view()) -> JsonDoc:
  match value:
    case QParam.Rows{rows}:json_array_strings(~IQ.ProjectedRow<Schema,Cmp.Access<U32>>,~row_json,rows)
def json_event_view(value:e_view()) -> JsonDoc:
  match value:
    case Stream.EventView{Ev.Reading{values,lagged}}:json_parts([JsonText{"{\"values\":"},json_list_notices(values),JsonText{",\"lagged\":"},JsonText{boolean(lagged)},JsonText{"}"}])
def json_removal_view(value:m_view()) -> JsonDoc:
  match value:
    case Stream.RemovalView{records}:json_list_removals(records)
def json_key_reading(value:KRead.KeyReading<Schema,event_type()>) -> JsonDoc:
  match value:
    case KRead.KeyReading{KD.DeclaredKey{key},values,lagged}:json_parts([JsonText{"{\"key\":"},JsonText{U32.show(key)},JsonText{",\"values\":"},json_list_notices(values),JsonText{",\"lagged\":"},JsonText{boolean(lagged)},JsonText{"}"}])
def json_relation_view(value:r_view()) -> JsonDoc:
  match value:
    case Stream.RelationView{readings}:json_array(~KRead.KeyReading<Schema,event_type()>,~json_key_reading,readings)
def json_view(value:all_view()) -> JsonDoc:
  match value:
    case AllView{query,added,changed,event,removals,relations}:json_parts([JsonText{"{\"query\":"},json_query_view(query),JsonText{",\"eventA\":"},json_event_view(event),JsonText{",\"added\":"},JsonText{filter_query_json(added)},JsonText{",\"changed\":"},JsonText{filter_query_json(changed)},JsonText{",\"removals\":"},json_removal_view(removals),JsonText{",\"relations\":"},json_relation_view(relations),JsonText{"}"}])

def registry_type() -> Type:
  Sys.Registry<Schema,store_type(),Unit,event_type(),Ordinary.Invocation<metadata_type(),all_owner(),all_parameter_type(),Unit,Bool>,Empty,Ordinary.Envelope<metadata_type(),all_owner(),all_parameter_type(),Unit,U32,all_view()>,Ordinary.shared_runner(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~all_owner(),~all_view(),~all_delta(),~Bool,~Unit,~U32,~all_view(),~validate_all,~prepare_all,~commit_all,~release_all,~no_caps,~callback,~no_grant(),~sync_events,~classify)>
def provider_type() -> Type:
  Ordinary.Provider<registry_type(),all_owner(),all_parameter_type(),Unit>
def definition_type() -> Type:
  Ordinary.Definition<context_type(),provider_type(),all_parameter_type(),Unit>
def run_type() -> Type:
  Ordinary.RunResult<context_type(),provider_type(),Bool,U32,all_view()>
def define_all(context:context_type(),name:String) -> definition_type():
  Ordinary.define_mixed(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~all_owner(),~all_view(),~all_delta(),~Bool,~Unit,~U32,~all_view(),~validate_all,~prepare_all,~commit_all,~release_all,~no_caps,~callback,~no_grant(),~sync_events,~classify,~all_initialize,all_parameter(),Unit{},context,name)
def run_all(provider:provider_type(),context:context_type(),fail:Bool) -> run_type():
  Ordinary.run_mixed(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~all_owner(),~all_view(),~all_delta(),~Bool,~Unit,~U32,~all_view(),~validate_all,~prepare_all,~commit_all,~release_all,~no_caps,~callback,~no_grant(),~sync_events,~classify,provider,context,fail)

def context_clocked(metadata:metadata_type(),clocked:world_type() & U32) -> context_type() & U32:
  match clocked:
    case (world,clock):(Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata),clock)
def context_clock_parts(parts:world_type() & metadata_type()) -> context_type() & U32:
  match parts:
    case (world,metadata):context_clocked(metadata,W.clock(~Schema,~store_type(),~Unit,~event_type(),world))
def context_clock(context:context_type()) -> context_type() & U32:
  context_clock_parts(Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def world_observation_clock(value:WorldObservation) -> U32:
  match value:
    case WorldObservation{namespace,nextId,highWater,live,inactiveReservations,capacity,depth,components,resource,registrations,nextSystemId,clock,pending,graph,events}:clock
def provider_cursor(provider:provider_type()) -> provider_type() & U32:
  match provider:
    case Ordinary.Provider{Sys.Registry{namespace,id,name,access,+cursor},reader,parameter,declaration}:
      (Ordinary.Provider{Sys.Registry{namespace,id,name,access,cursor},reader,parameter,declaration},cursor)
def observation_context(next:context_type() -> provider_type() -> String -> String,provider:provider_type(),cursor:U32,phase:String,status:String,error:String,view:all_view(),observed:context_type() & WorldObservation) -> String:
  match observed:
    case (context,+image):next(context,provider,"{\"phase\":"++quoted(phase)++",\"status\":"++quoted(status)++",\"error\":"++error++",\"clock\":"++U32.show(world_observation_clock(image))++",\"queryCursor\":"++U32.show(cursor)++",\"view\":"++view_json(view)++",\"world\":"++world_observation_json(image)++"}")
def observation_cursor(next:context_type() -> provider_type() -> String -> String,context:context_type(),clock:U32,phase:String,status:String,error:String,view:all_view(),observed:provider_type() & U32) -> String:
  match observed:
    case (provider,cursor):observation_context(next,provider,cursor,phase,status,error,view,context_snapshot(context))
def observation_clocked(next:context_type() -> provider_type() -> String -> String,provider:provider_type(),phase:String,status:String,error:String,view:all_view(),observed:context_type() & U32) -> String:
  match observed:
    case (context,clock):observation_cursor(next,context,clock,phase,status,error,view,provider_cursor(provider))
def observe_result(next:context_type() -> provider_type() -> String -> String,phase:String,result:run_type()) -> String:
  match result:
    case Ordinary.RunCompleted{context,provider,view}:observation_clocked(next,provider,phase,"completed","null",view,context_clock(context))
    case Ordinary.RunFailed{context,provider,error,view}:observation_clocked(next,provider,phase,"failed",U32.show(error),view,context_clock(context))
    case Ordinary.RunInvalidReader{_,_}:"unexpected-invalid-reader"
    case Ordinary.RunSkipped{_,_}:"unexpected-skip"
    case Ordinary.RunRegistrationRejected{_,_,_}:"unexpected-registration-rejection"
type Step is Data:
  Step{first:Bool,fail:Bool,phase:String}
def drive(steps:List<&2,Step>,context:context_type(),first:provider_type(),second:provider_type(),rows:String,separator:String) -> String:
  match steps:
    case []:"["++rows++"]"
    case Step{True{},fail,phase} <> rest:
      observe_result((context => provider => row => drive(rest,context,provider,second,rows++separator++row,",")),phase,run_all(first,context,fail))
    case Step{False{},fail,phase} <> rest:
      observe_result((context => provider => row => drive(rest,context,first,provider,rows++separator++row,",")),phase,run_all(second,context,fail))
def queue_status_json(value:Notice.QueueStatus) -> String:
  match value:
    case Notice.Queued{}:"\"queued\""
    case Notice.MissingEntity{}:"\"missingEntity\""
def outcome_json(value:Tx.Outcome<U32>) -> String:
  match value:
    case Tx.Success{}:"\"success\""
    case Tx.Failure{error}:"{\"failure\":"++U32.show(error)++"}"
def mutation_json(value:MutationReport) -> String:
  match value:
    case MutationReport{committedStatus,committedOutcome,rolledBackStatus,rolledBackOutcome}:"{\"committedQueue\":"++queue_status_json(committedStatus)++",\"committedOutcome\":"++outcome_json(committedOutcome)++",\"rolledBackQueue\":"++queue_status_json(rolledBackStatus)++",\"rolledBackOutcome\":"++outcome_json(rolledBackOutcome)++"}"
def after_barrier(context:context_type(),first:provider_type(),second:provider_type(),report:MutationReport,prefix:String) -> String:
  "{\"mutation\":"++mutation_json(report)++",\"observations\":"++drive([Step{True{},True{},"A-fail-after-barrier"},Step{True{},False{},"A-retry"},Step{True{},False{},"A-repeat"},Step{False{},False{},"B-first"},Step{False{},False{},"B-repeat"}],context,first,second,prefix,",")++"}"
# The ordinary writer and readers share the declared relation descriptors.
type StructuralCommand is Data:
  SeedPair{}
  RemoveValue{handle:W.Handle<Schema>}
  InsertValue{handle:W.Handle<Schema>,value:U32}
  SpawnEmpty{}
  DespawnEmpty{handle:W.Handle<Schema>}
type StructuralResult is Data:
  StructuralResult{accepted:Bool,spawned:Maybe<&2,W.Handle<Schema>>,also:Maybe<&2,W.Handle<Schema>>}
type StructuralOps<H:Type> is Type:
  StructuralOps{apply:Cap.OwnedRequest<H,StructuralCommand,StructuralResult>}
type EventOps<H:Type> is Type:
  EventOps{emit:Cap.Send<H,List<&2,Publication>>}
type RelationOps<H:Type> is Type:
  RelationOps{apply:Cap.OwnedRequest<H,List<&2,RelationProvider.Targets<Schema>>,WriteCounts>}
type WriteOps<H:Type> is Type:
  WriteOps{events:EventOps<H>,relations:RelationOps<H>,structural:StructuralOps<H>}
type WriteArgs is Data:
  WriteArgs{source:Maybe<&2,W.Handle<Schema>>,target:Maybe<&2,W.Handle<Schema>>,doomed:Maybe<&2,W.Handle<Schema>>,emitValues:Bool,operation:Maybe<&2,StructuralCommand>,targets:List<&2,RelationProvider.Targets<Schema>>}
type WriteReport is Data:
  WriteReport{queued:U32,refused:U32,operations:List<&2,StructuralResult>}
type WriteCounts is Data:
  WriteCounts{queued:U32,refused:U32}
def write_args_type() -> Data:
  WriteArgs
def write_report_type() -> Data:
  WriteReport
def write_ops(H:Type) -> Type:
  WriteOps<H>
def insert_structural_result(queued:Structural.Queued<Tx.Tx<world_type(),event_type()>,U32>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match queued:
    case Structural.Queued{tx}:(tx,StructuralResult{True{},None{},None{}})
    case Structural.QueueRejected{tx,_,_}:(tx,StructuralResult{False{},None{},None{}})
def insert_structural(tx:Tx.Tx<world_type(),event_type()>,handle:W.Handle<Schema>,value:U32) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  insert_structural_result(Structural.tx_insert(~Schema,~store_type(),~Unit,~event_type(),~Relations.Graph<Schema>,~U32,~Unit,~Unit,~take_values,~put_values,~presence,Binding.family(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~Unit,~Unit,~take_values,~put_values,~presence,binding()),tx,handle,value))
def remove_structural_result(queued:Structural.Queued<Tx.Tx<world_type(),event_type()>,U32>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match queued:
    case Structural.Queued{tx}:(tx,StructuralResult{True{},None{},None{}})
    case Structural.QueueRejected{tx,_,_}:(tx,StructuralResult{False{},None{},None{}})
def remove_structural(tx:Tx.Tx<world_type(),event_type()>,handle:W.Handle<Schema>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  remove_structural_result(OrdinaryRemoval.remove(~Schema,~store_type(),~Unit,~event_type(),~Relations.Graph<Schema>,~U32,~Unit,~Unit,~take_values,~put_values,~presence,~inject_removal,~binding(),tx,handle))
def populate_value(world:world_type(),handle:W.Handle<Schema>,value:U32) -> world_type():
  Structural.apply(~Schema,~store_type(),~Unit,~event_type(),~Relations.Graph<Schema>,~U32,~Unit,~Unit,~take_values,~put_values,~presence,Binding.family(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~Unit,~Unit,~take_values,~put_values,~presence,binding()),world,handle,Some{value})
def structural_spawn_value_result(observed:Tx.Tx<world_type(),event_type()> & W.Reservation<Schema>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match observed:
    case (tx,W.Reserved{+handle}):(tx,StructuralResult{True{},Some{handle},None{}})
    case (tx,W.ReservationRejected{_}):(tx,StructuralResult{False{},None{},None{}})
def structural_spawn_value(tx:Tx.Tx<world_type(),event_type()>,value:U32) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  structural_spawn_value_result(Commands.tx_spawn(~Schema,~store_type(),~Unit,~event_type(),~U32,~populate_value,tx,value))
def structural_seed_second_result(source:W.Handle<Schema>,observed:Tx.Tx<world_type(),event_type()> & W.Reservation<Schema>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match observed:
    case (tx,W.Reserved{+target}):(tx,StructuralResult{True{},Some{source},Some{target}})
    case (tx,W.ReservationRejected{_}):(tx,StructuralResult{False{},Some{source},None{}})
def structural_seed_second(tx:Tx.Tx<world_type(),event_type()>,source:W.Handle<Schema>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  structural_seed_second_result(source,Commands.tx_spawn(~Schema,~store_type(),~Unit,~event_type(),~U32,~populate_value,tx,43))
def structural_seed_first_result(observed:Tx.Tx<world_type(),event_type()> & W.Reservation<Schema>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match observed:
    case (tx,W.Reserved{+source}):structural_seed_second(tx,source)
    case (tx,W.ReservationRejected{_}):(tx,StructuralResult{False{},None{},None{}})
def structural_seed_first(tx:Tx.Tx<world_type(),event_type()>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  structural_seed_first_result(Commands.tx_spawn(~Schema,~store_type(),~Unit,~event_type(),~U32,~populate_value,tx,42))
def empty_population(world:world_type(),_:W.Handle<Schema>,_:Unit) -> world_type():
  world
def structural_despawn_result(observed:Tx.Tx<world_type(),event_type()> & W.Status) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match observed:
    case (tx,W.Accepted{}):(tx,StructuralResult{True{},None{},None{}})
    case (tx,W.Rejected{_}):(tx,StructuralResult{False{},None{},None{}})
def structural_despawn(tx:Tx.Tx<world_type(),event_type()>,handle:W.Handle<Schema>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  structural_despawn_result(Commands.tx_despawn(~Schema,~store_type(),~Unit,~event_type(),tx,handle))
def structural_spawn_result(observed:Tx.Tx<world_type(),event_type()> & W.Reservation<Schema>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match observed:
    case (tx,W.Reserved{+handle}):(tx,StructuralResult{True{},Some{handle},None{}})
    case (tx,W.ReservationRejected{_}):(tx,StructuralResult{False{},None{},None{}})
def structural_spawn(tx:Tx.Tx<world_type(),event_type()>) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  structural_spawn_result(Commands.tx_spawn(~Schema,~store_type(),~Unit,~event_type(),~Unit,~empty_population,tx,Unit{}))
def apply_structural(tx:Tx.Tx<world_type(),event_type()>,command:StructuralCommand) -> Tx.Tx<world_type(),event_type()> & StructuralResult:
  match command:
    case SeedPair{}:structural_seed_first(tx)
    case RemoveValue{handle}:remove_structural(tx,handle)
    case InsertValue{handle,value}:insert_structural(tx,handle,value)
    case SpawnEmpty{}:structural_spawn(tx)
    case DespawnEmpty{handle}:structural_despawn(tx,handle)
def structural_finished(~H:Type,result:H & StructuralResult) -> H & (Tx.Outcome<U32> & WriteReport):
  match result:
    case (owner,operation):
      match operation:
        case StructuralResult{True{},_,_}:(owner,(Tx.Success{},WriteReport{0,0,[operation]}))
        case StructuralResult{False{},_,_}:(owner,(Tx.Failure{90},WriteReport{0,0,[operation]}))
def write_fold_queued(~H:Type,counts:WriteCounts,owner:H) -> H & WriteCounts:
  match counts:
    case WriteCounts{queued,refused}:(owner,WriteCounts{(queued+1:U32),refused})
def write_fold_refused(~H:Type,counts:WriteCounts,owner:H) -> H & WriteCounts:
  match counts:
    case WriteCounts{queued,refused}:(owner,WriteCounts{queued,(refused+1:U32)})
def write_fold_result(~H:Type,counts:WriteCounts,result:H & Notice.QueueStatus) -> H & WriteCounts:
  match result:
    case (owner,Notice.Queued{}):write_fold_queued(~H,counts,owner)
    case (owner,Notice.MissingEntity{}):write_fold_refused(~H,counts,owner)
def write_relation_cap() -> RelationProvider.Writable<Tx.Tx<world_type(),event_type()>,Schema>:
  RelationProvider.provide_write(~Schema,~Col.Column<Schema,U32>,~Unit,~Publication,~relation_descriptor())
def write_relation_request(owner:Tx.Tx<world_type(),event_type()>,target:RelationProvider.Targets<Schema>) -> Tx.Tx<world_type(),event_type()> & Notice.QueueStatus:
  RelationProvider.relate_live(Tx.Tx<world_type(),event_type()>,Schema,write_relation_cap(),owner,target)
def write_targets_fold(targets:List<&2,RelationProvider.Targets<Schema>>,state:Tx.Tx<world_type(),event_type()> & WriteCounts) -> Tx.Tx<world_type(),event_type()> & WriteCounts:
  match targets:
    case []:state
    case target <> rest:
      match state:
        case (owner,counts):write_targets_fold(rest,write_fold_result(~Tx.Tx<world_type(),event_type()>,counts,write_relation_request(owner,target)))
def write_target(source:W.Handle<Schema>,namespace:U32,firstTarget:U32,index:Nat) -> RelationProvider.Targets<Schema>:
  RelationProvider.Targets{source,W.Handle{namespace,U32.from_nat(Nat.add(U32.to_nat(firstTarget),index))}}
def write_targets_from(+source:W.Handle<Schema>,+namespace:U32,+firstTarget:U32,remaining:Nat,+index:Nat,+reversed:List<&2,RelationProvider.Targets<Schema>>) -> List<&2,RelationProvider.Targets<Schema>>:
  match remaining:
    case 0n:List.reverse(&2,RelationProvider.Targets<Schema>,reversed)
    case 1n+rest:write_targets_from(source,namespace,firstTarget,rest,Nat.add(index,1n),write_target(source,namespace,firstTarget,index) <> reversed)
def write_targets(source:W.Handle<Schema>,namespace:U32,firstTarget:U32,count:U32) -> List<&2,RelationProvider.Targets<Schema>>:
  write_targets_from(source,namespace,firstTarget,U32.to_nat(count),0n,[])
def write_publications(values:List<&2,Publication>,tx:Tx.Tx<world_type(),event_type()>) -> Tx.Tx<world_type(),event_type()>:
  match values:
    case []:tx
    case value <> rest:write_publications(rest,Tx.emit(~world_type(),~event_type(),tx,Notice.Original{value}))
def writer_send_values(~H:Type,emit:Cap.Send<H,List<&2,Publication>>,owner:H) -> H:
  match emit:
    case Cap.Send{send}:send(owner,[Value{31},Value{32}])
def write_finished(~H:Type,folded:H & WriteCounts,operations:List<&2,StructuralResult>) -> H & (Tx.Outcome<U32> & WriteReport):
  match folded:
    case (owner,WriteCounts{queued,refused}):(owner,(Tx.Success{},WriteReport{queued,refused,operations}))
def write_finished_targets(~H:Type,counts:H & WriteCounts) -> H & (Tx.Outcome<U32> & WriteReport):
  write_finished(~H,counts,[])
def write_callback_command(~H:Type,apply_relations:Cap.OwnedRequest<H,List<&2,RelationProvider.Targets<Schema>>,WriteCounts>,apply_structural:Cap.OwnedRequest<H,StructuralCommand,StructuralResult>,input:WriteArgs,owner:H) -> H & (Tx.Outcome<U32> & WriteReport):
  match input:
    case WriteArgs{_,_,_,_,operation,targets}:
      match operation:
        case None{}:write_finished_targets(~H,Cap.owned_request_field(~H,~List<&2,RelationProvider.Targets<Schema>>,~WriteCounts,apply_relations)(owner,targets))
        case Some{command}:structural_finished(~H,Cap.owned_request_field(~H,~StructuralCommand,~StructuralResult,apply_structural)(owner,command))
def write_callback_with_caps(~H:Type,caps:write_ops(H),input:Unit & WriteArgs,owner:H) -> H & (Tx.Outcome<U32> & WriteReport):
  match caps:
    case WriteOps{EventOps{emit},RelationOps{apply_relations},StructuralOps{apply}}:
      match input:
        case (Unit{},args):
          match args:
            case WriteArgs{_,_,_,emitValues,_,_}:
              match emitValues:
                case False{}:write_callback_command(~H,apply_relations,apply,args,owner)
                case True{}:write_callback_command(~H,apply_relations,apply,args,writer_send_values(~H,emit,owner))
def write_callback(~H:Type,~caps:write_ops(H),input:Unit & WriteArgs,owner:H) -> H & (Tx.Outcome<U32> & WriteReport):
  write_callback_with_caps(~H,caps,input,owner)
def write_grant() -> write_ops(Tx.Tx<world_type(),event_type()>):
  WriteOps{EventOps{Cap.Send{owner => values => write_publications(values,owner)}},RelationOps{Cap.OwnedRequest{owner => targets => write_targets_fold(targets,(owner,WriteCounts{0,0}))}},StructuralOps{Cap.OwnedRequest{apply_structural}}}
def write_parameter_type() -> Data:
  RP.Param<context_type(),Unit,Unit,Unit,RP.unit_validate(~context_type()),RP.unit_prepare(~context_type()),RP.unit_commit(~context_type()),RP.unit_release(~context_type())>
def write_parameter() -> write_parameter_type():
  RP.unit(~context_type())
def write_initialize(context:context_type(),_:RP.RegistrationFacts) -> context_type() & (Unit & write_parameter_type()):
  (context,(Unit{},write_parameter()))
def write_registry_type() -> Type:
  Sys.Registry<Schema,store_type(),Unit,event_type(),Ordinary.Invocation<metadata_type(),Unit,write_parameter_type(),Unit,write_args_type()>,Empty,Ordinary.Envelope<metadata_type(),Unit,write_parameter_type(),Unit,U32,write_report_type()>,Ordinary.shared_runner(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~Unit,~write_args_type(),~Unit,~U32,~write_report_type(),~RP.unit_validate(~context_type()),~RP.unit_prepare(~context_type()),~RP.unit_commit(~context_type()),~RP.unit_release(~context_type()),~write_ops,~write_callback,~write_grant(),~sync_events,~classify)>
def write_provider_type() -> Type:
  Ordinary.Provider<write_registry_type(),Unit,write_parameter_type(),Unit>
def write_definition_type() -> Type:
  Ordinary.Definition<context_type(),write_provider_type(),write_parameter_type(),Unit>
def define_writer(context:context_type(),name:String) -> write_definition_type():
  Ordinary.define_mixed(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~Unit,~write_args_type(),~Unit,~U32,~write_report_type(),~RP.unit_validate(~context_type()),~RP.unit_prepare(~context_type()),~RP.unit_commit(~context_type()),~RP.unit_release(~context_type()),~write_ops,~write_callback,~write_grant(),~sync_events,~classify,~write_initialize,write_parameter(),Unit{},context,name)
def run_writer(provider:write_provider_type(),context:context_type(),args:write_args_type()) -> Ordinary.RunResult<context_type(),write_provider_type(),write_args_type(),U32,write_report_type()>:
  Ordinary.run_mixed(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~Unit,~write_args_type(),~Unit,~U32,~write_report_type(),~RP.unit_validate(~context_type()),~RP.unit_prepare(~context_type()),~RP.unit_commit(~context_type()),~RP.unit_release(~context_type()),~write_ops,~write_callback,~write_grant(),~sync_events,~classify,provider,context,args)

type ScheduleOwners is Type:
  ScheduleOwners{metadata:metadata_type(),writer:write_provider_type(),fast:provider_type(),slow:provider_type(),writeArgs:write_args_type(),trace:List<&2,JsonDoc>}
type ScheduleError is Data:
  DispatchFailed{}
def metadata_after_split(writer:write_provider_type(),fast:provider_type(),slow:provider_type(),writeArgs:write_args_type(),trace:List<&2,JsonDoc>,split:world_type() & metadata_type()) -> world_type() & ScheduleOwners:
  match split:
    case (world,metadata):(world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace})
def metadata_after(context:context_type(),writer:write_provider_type(),fast:provider_type(),slow:provider_type(),writeArgs:write_args_type(),trace:List<&2,JsonDoc>) -> world_type() & ScheduleOwners:
  metadata_after_split(writer,fast,slow,writeArgs,trace,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def context_from(world:world_type(),metadata:metadata_type()) -> context_type():
  Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata)
def skip_capture_finish_split(writer:write_provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,beforeContext:JsonDoc,beforeFast:U32,beforeSlow:U32,afterContext:JsonDoc,fastCursor:U32,slowCursor:U32,providers:provider_type() & provider_type(),split:world_type() & metadata_type()) -> ScheduleOwners & world_type():
  match providers:
    case (fast,slow):
      match split:
        case (world,metadata):(ScheduleOwners{metadata,writer,fast,slow,args,List.append(&2,JsonDoc,trace,[json_parts([JsonText{"{\"kind\":\"skipState\",\"before\":{\"context\":"},beforeContext,JsonText{",\"fastCursor\":"},JsonText{U32.show(beforeFast)},JsonText{",\"slowCursor\":"},JsonText{U32.show(beforeSlow)},JsonText{"},\"after\":{\"context\":"},afterContext,JsonText{",\"fastCursor\":"},JsonText{U32.show(fastCursor)},JsonText{",\"slowCursor\":"},JsonText{U32.show(slowCursor)},JsonText{"}}"}])])},world)
def skip_capture_split(writer:write_provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,beforeContext:JsonDoc,beforeFast:U32,beforeSlow:U32,afterContext:JsonDoc,fastCursor:U32,slowCursor:U32,providers:provider_type() & provider_type(),context:context_type()) -> ScheduleOwners & world_type():
  skip_capture_finish_split(writer,args,trace,beforeContext,beforeFast,beforeSlow,afterContext,fastCursor,slowCursor,providers,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def skip_capture_finish(writer:write_provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,beforeContext:JsonDoc,beforeFast:U32,beforeSlow:U32,contextResult:context_type() & JsonDoc,fastResult:provider_type() & U32,slowResult:provider_type() & U32) -> ScheduleOwners & world_type():
  match contextResult:
    case (context,afterContext):
      match fastResult:
        case (fast,fastCursor):
          match slowResult:
            case (slow,slowCursor):skip_capture_split(writer,args,trace,beforeContext,beforeFast,beforeSlow,afterContext,fastCursor,slowCursor,(fast,slow),context)
def skip_capture_after(writer:write_provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,beforeContext:JsonDoc,beforeFast:U32,beforeSlow:U32,context:context_type(),fast:provider_type(),slow:provider_type()) -> ScheduleOwners & world_type():
  skip_capture_finish(writer,args,trace,beforeContext,beforeFast,beforeSlow,json_context_image(context),provider_cursor(fast),provider_cursor(slow))
def skip_capture_results(writer:write_provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,contextResult:context_type() & JsonDoc,fastResult:provider_type() & U32,slowResult:provider_type() & U32) -> ScheduleOwners & world_type():
  match contextResult:
    case (context,beforeContext):
      match fastResult:
        case (fast,beforeFast):
          match slowResult:
            case (slow,beforeSlow):skip_capture_after(writer,args,trace,beforeContext,beforeFast,beforeSlow,context,fast,slow)
def skip_capture_start(writer:write_provider_type(),fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type()) -> ScheduleOwners & world_type():
  skip_capture_results(writer,args,trace,json_context_image(context),provider_cursor(fast),provider_cursor(slow))
def skip_ordinary(owners:ScheduleOwners,world:world_type(),_:U32) -> ScheduleOwners & world_type():
  match owners:
    case ScheduleOwners{metadata,writer,fast,slow,args,trace}:skip_capture_start(writer,fast,slow,args,trace,context_from(world,metadata))
def condition_for_slot(world:world_type(),slot:U32) -> world_type() & Bool:
  (world,Bool.not(U32.is_eq(slot,2)))
def condition_ordinary(world:world_type(),slot:U32) -> world_type() & Bool:
  condition_for_slot(world,slot)
def schedule_steps() -> List<&2,Sch.Step>:
  [Sch.System{3,2},Sch.System{2,0},Sch.System{4,0},Sch.System{1,0},Sch.Barrier{},Sch.System{5,0},Sch.System{6,0}]
def schedule_plan_namespace(owners:ScheduleOwners,observed:world_type() & U32) -> world_type() & Sch.Build<Schema,store_type(),Unit,event_type(),ScheduleOwners>:
  match observed:
    case (world,namespace):(world,Sch.build(~Schema,~store_type(),~Unit,~event_type(),~ScheduleOwners,namespace,"ordinary-fullcapacity-scheduled-v6",schedule_steps(),[1,2,3,4,5,6],owners))
def schedule_plan(owners:ScheduleOwners,world:world_type()) -> world_type() & Sch.Build<Schema,store_type(),Unit,event_type(),ScheduleOwners>:
  schedule_plan_namespace(owners,W.namespace(~Schema,~store_type(),~Unit,~event_type(),world))

def trace_append(trace:List<&2,JsonDoc>,entry:JsonDoc) -> List<&2,JsonDoc>:
  List.append(&2,JsonDoc,trace,[entry])
def json_writer_trace(queued:U32,refused:U32,image:WorldObservation) -> JsonDoc:
  json_parts([JsonText{"{\"kind\":\"writer\",\"queued\":"},JsonText{U32.show(queued)},JsonText{",\"refused\":"},JsonText{U32.show(refused)},JsonText{",\"world\":"},json_world_observation(image),JsonText{"}"}])
def writer_success_observed(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:write_provider_type(),queued:U32,refused:U32,metadata:metadata_type(),observed:world_type() & WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match observed:
    case (world,image):(ScheduleOwners{metadata,provider,fast,slow,args,trace_append(trace,json_writer_trace(queued,refused,image))},Sys.Succeeded{world,Unit{}})
def writer_success_controlled_split(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:write_provider_type(),queued:U32,refused:U32,split:world_type() & metadata_type(),image:WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match split:
    case (world,metadata):(ScheduleOwners{metadata,provider,fast,slow,args,trace_append(trace,json_writer_trace(queued,refused,image))},Sys.Succeeded{world,Unit{}})
def writer_success_controlled_context(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:write_provider_type(),queued:U32,refused:U32,context:context_type(),image:WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  writer_success_controlled_split(fast,slow,args,trace,provider,queued,refused,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context),image)
def writer_success_controlled(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:write_provider_type(),queued:U32,refused:U32,observed:context_type() & WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match observed:
    case (context,image):writer_success_controlled_context(fast,slow,args,trace,provider,queued,refused,context,image)
def first_spawned(operations:List<&2,StructuralResult>) -> Maybe<&2,W.Handle<Schema>>:
  match operations:
    case []:None{}
    case StructuralResult{_,Some{handle},_} <> _:Some{handle}
    case _ <> rest:first_spawned(rest)
def first_also_spawned(operations:List<&2,StructuralResult>) -> Maybe<&2,W.Handle<Schema>>:
  match operations:
    case []:None{}
    case StructuralResult{_,_,Some{handle}} <> _:Some{handle}
    case _ <> rest:first_also_spawned(rest)
def choose_handle(current:Maybe<&2,W.Handle<Schema>>,candidate:Maybe<&2,W.Handle<Schema>>) -> Maybe<&2,W.Handle<Schema>>:
  match current:
    case Some{handle}:Some{handle}
    case None{}:candidate
type SeededHandles is Data:
  SeededHandles{source:Maybe<&2,W.Handle<Schema>>,target:Maybe<&2,W.Handle<Schema>>}
def collect_seeded_handles_cons(source:Maybe<&2,W.Handle<Schema>>,target:Maybe<&2,W.Handle<Schema>>,later:SeededHandles) -> SeededHandles:
  match later:
    case SeededHandles{laterSource,laterTarget}:SeededHandles{choose_handle(source,laterSource),choose_handle(target,laterTarget)}
def collect_seeded_handles(operations:List<&2,StructuralResult>) -> SeededHandles:
  match operations:
    case []:SeededHandles{None{},None{}}
    case StructuralResult{_,source,target} <> rest:collect_seeded_handles_cons(source,target,collect_seeded_handles(rest))
def completed_seed_args(args:write_args_type(),first:Maybe<&2,W.Handle<Schema>>,second:Maybe<&2,W.Handle<Schema>>) -> write_args_type():
  match args:
    case WriteArgs{source,target,doomed,_,_,_}:
      WriteArgs{choose_handle(source,first),choose_handle(target,second),doomed,False{},None{},[]}
def completed_seed_args_from_handles(args:write_args_type(),handles:SeededHandles) -> write_args_type():
  match handles:
    case SeededHandles{source,target}:completed_seed_args(args,source,target)
def completed_doomed_args(args:write_args_type(),spawned:Maybe<&2,W.Handle<Schema>>) -> write_args_type():
  match args:
    case WriteArgs{source,target,doomed,_,_,_}:
      WriteArgs{source,target,choose_handle(doomed,spawned),False{},None{},[]}
def completed_write_args(args:write_args_type(),operations:List<&2,StructuralResult>) -> write_args_type():
  match args:
    case WriteArgs{source,target,doomed,emitValues,operation,targets}:
      match operation:
        case Some{SeedPair{}}:completed_seed_args_from_handles(args,collect_seeded_handles(operations))
        case Some{SpawnEmpty{}}:completed_doomed_args(args,first_spawned(operations))
        case _:WriteArgs{source,target,doomed,False{},None{},[]}
def writer_success_direct(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:write_provider_type(),report:WriteReport) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match report:
    case WriteReport{queued,refused,operations}:
      writer_success_controlled(fast,slow,completed_write_args(args,operations),trace,provider,queued,refused,context_snapshot(context))
def writer_fault_split(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:write_provider_type(),split:world_type() & metadata_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match split:
    case (world,metadata):(ScheduleOwners{metadata,provider,fast,slow,args,trace},Sys.Failed{world,DispatchFailed{}})
def writer_fault(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:write_provider_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  writer_fault_split(fast,slow,args,trace,provider,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def writer_result(fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,result:Ordinary.RunResult<context_type(),write_provider_type(),write_args_type(),U32,write_report_type()>) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match result:
    case Ordinary.RunCompleted{context,provider,output}:writer_success_direct(fast,slow,args,trace,context,provider,output)
    case Ordinary.RunFailed{context,provider,_,_}:writer_fault(fast,slow,args,trace,context,provider)
    case Ordinary.RunInvalidReader{context,provider}:writer_fault(fast,slow,args,trace,context,provider)
    case Ordinary.RunRegistrationRejected{context,provider,_}:writer_fault(fast,slow,args,trace,context,provider)
    case Ordinary.RunSkipped{context,provider}:writer_fault(fast,slow,args,trace,context,provider)
def reader_success_fast_meta(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,metadata:metadata_type(),provider:provider_type(),cursor:U32,view:all_view(),world:world_type(),worldJson:JsonDoc) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  (ScheduleOwners{metadata,writer,provider,slow,args,trace_append(trace,json_parts([JsonText{"{\"kind\":\"reader\",\"reader\":\"fast\",\"cursor\":"},JsonText{U32.show(cursor)},JsonText{",\"view\":"},json_view(view),JsonText{",\"world\":"},worldJson,JsonText{"}"}]))},Sys.Succeeded{world,Unit{}})
def reader_success_slow_meta(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,metadata:metadata_type(),provider:provider_type(),cursor:U32,view:all_view(),world:world_type(),worldJson:JsonDoc) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  (ScheduleOwners{metadata,writer,fast,provider,args,trace_append(trace,json_parts([JsonText{"{\"kind\":\"reader\",\"reader\":\"slow\",\"cursor\":"},JsonText{U32.show(cursor)},JsonText{",\"view\":"},json_view(view),JsonText{",\"world\":"},worldJson,JsonText{"}"}]))},Sys.Succeeded{world,Unit{}})
def reader_success_fast_observed(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,metadata:metadata_type(),provider:provider_type(),cursor:U32,view:all_view(),observed:world_type() & WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match observed:
    case (world,image):reader_success_fast_meta(writer,slow,args,trace,metadata,provider,cursor,view,world,json_world_observation(image))
def reader_success_slow_observed(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,metadata:metadata_type(),provider:provider_type(),cursor:U32,view:all_view(),observed:world_type() & WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match observed:
    case (world,image):reader_success_slow_meta(writer,fast,args,trace,metadata,provider,cursor,view,world,json_world_observation(image))
def reader_success_fast_parts(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,view:all_view(),withCursor:provider_type() & U32,split:world_type() & metadata_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match withCursor:
    case (provider,cursor):
      match split:
        case (world,metadata):reader_success_fast_observed(writer,slow,args,trace,metadata,provider,cursor,view,world_snapshot(world))
def reader_success_slow_parts(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,view:all_view(),withCursor:provider_type() & U32,split:world_type() & metadata_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match withCursor:
    case (provider,cursor):
      match split:
        case (world,metadata):reader_success_slow_observed(writer,fast,args,trace,metadata,provider,cursor,view,world_snapshot(world))
def reader_success_fast(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:provider_type(),view:all_view()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_success_fast_parts(writer,slow,args,trace,view,provider_cursor(provider),Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def reader_success_slow(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:provider_type(),view:all_view()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_success_slow_parts(writer,fast,args,trace,view,provider_cursor(provider),Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def reader_fault_fast_split(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:provider_type(),split:world_type() & metadata_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match split:
    case (world,metadata):(ScheduleOwners{metadata,writer,provider,slow,args,trace},Sys.Failed{world,DispatchFailed{}})
def reader_fault_slow_split(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:provider_type(),split:world_type() & metadata_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match split:
    case (world,metadata):(ScheduleOwners{metadata,writer,fast,provider,args,trace},Sys.Failed{world,DispatchFailed{}})
def reader_fault_fast(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:provider_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_fault_fast_split(writer,slow,args,trace,provider,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def reader_fault_slow(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:provider_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_fault_slow_split(writer,fast,args,trace,provider,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def reader_failed_fast_observed(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,metadata:metadata_type(),provider:provider_type(),cursor:U32,error:U32,view:all_view(),observed:world_type() & WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match observed:
    case (world,image):
      (ScheduleOwners{metadata,writer,provider,slow,args,trace_append(trace,json_parts([JsonText{"{\"kind\":\"reader\",\"reader\":\"fast\",\"status\":\"failed\",\"error\":"},JsonText{U32.show(error)},JsonText{",\"cursor\":"},JsonText{U32.show(cursor)},JsonText{",\"view\":"},json_view(view),JsonText{",\"world\":"},json_world_observation(image),JsonText{"}"}]))},Sys.Failed{world,DispatchFailed{}})
def reader_failed_fast_split(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:provider_type(),cursor:U32,error:U32,view:all_view(),split:world_type() & metadata_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match split:
    case (world,metadata):reader_failed_fast_observed(writer,slow,args,trace,metadata,provider,cursor,error,view,world_snapshot(world))
def reader_failed_fast_context(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:provider_type(),cursor:U32,error:U32,view:all_view(),context:context_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_failed_fast_split(writer,slow,args,trace,provider,cursor,error,view,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def reader_failed_fast_cursor(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),error:U32,view:all_view(),withCursor:provider_type() & U32) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match withCursor:
    case (provider,cursor):reader_failed_fast_context(writer,slow,args,trace,provider,cursor,error,view,context)
def reader_failed_fast(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:provider_type(),error:U32,view:all_view()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_failed_fast_cursor(writer,slow,args,trace,context,error,view,provider_cursor(provider))
def reader_result_fast(writer:write_provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,result:run_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match result:
    case Ordinary.RunCompleted{context,provider,view}:reader_success_fast(writer,slow,args,trace,context,provider,view)
    case Ordinary.RunFailed{context,provider,error,view}:reader_failed_fast(writer,slow,args,trace,context,provider,error,view)
    case Ordinary.RunInvalidReader{context,provider}:reader_fault_fast(writer,slow,args,trace,context,provider)
    case Ordinary.RunRegistrationRejected{context,provider,_}:reader_fault_fast(writer,slow,args,trace,context,provider)
    case Ordinary.RunSkipped{context,provider}:reader_fault_fast(writer,slow,args,trace,context,provider)
def reader_failed_slow_observed(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,metadata:metadata_type(),provider:provider_type(),cursor:U32,error:U32,view:all_view(),observed:world_type() & WorldObservation) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match observed:
    case (world,image):
      (ScheduleOwners{metadata,writer,fast,provider,args,trace_append(trace,json_parts([JsonText{"{\"kind\":\"reader\",\"reader\":\"slow\",\"status\":\"failed\",\"error\":"},JsonText{U32.show(error)},JsonText{",\"cursor\":"},JsonText{U32.show(cursor)},JsonText{",\"view\":"},json_view(view),JsonText{",\"world\":"},json_world_observation(image),JsonText{"}"}]))},Sys.Failed{world,DispatchFailed{}})
def reader_failed_slow_split(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:provider_type(),cursor:U32,error:U32,view:all_view(),split:world_type() & metadata_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match split:
    case (world,metadata):reader_failed_slow_observed(writer,fast,args,trace,metadata,provider,cursor,error,view,world_snapshot(world))
def reader_failed_slow_context(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,provider:provider_type(),cursor:U32,error:U32,view:all_view(),context:context_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_failed_slow_split(writer,fast,args,trace,provider,cursor,error,view,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def reader_failed_slow_cursor(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),error:U32,view:all_view(),withCursor:provider_type() & U32) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match withCursor:
    case (provider,cursor):reader_failed_slow_context(writer,fast,args,trace,provider,cursor,error,view,context)
def reader_failed_slow(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type(),provider:provider_type(),error:U32,view:all_view()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  reader_failed_slow_cursor(writer,fast,args,trace,context,error,view,provider_cursor(provider))
def reader_result_slow(writer:write_provider_type(),fast:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,result:run_type()) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match result:
    case Ordinary.RunCompleted{context,provider,view}:reader_success_slow(writer,fast,args,trace,context,provider,view)
    case Ordinary.RunFailed{context,provider,error,view}:reader_failed_slow(writer,fast,args,trace,context,provider,error,view)
    case Ordinary.RunInvalidReader{context,provider}:reader_fault_slow(writer,fast,args,trace,context,provider)
    case Ordinary.RunRegistrationRejected{context,provider,_}:reader_fault_slow(writer,fast,args,trace,context,provider)
    case Ordinary.RunSkipped{context,provider}:reader_fault_slow(writer,fast,args,trace,context,provider)
def dispatch_ordinary(owners:ScheduleOwners,world:world_type(),id:U32) -> ScheduleOwners & Sys.Outcome<world_type(),ScheduleError,Unit>:
  match owners:
    case ScheduleOwners{metadata,writer,fast,slow,+args,trace}:
      match id:
        case 1:writer_result(fast,slow,args,trace,run_writer(writer,context_from(world,metadata),args))
        case 2:reader_result_fast(writer,slow,args,trace,run_all(fast,context_from(world,metadata),False{}))
        case 3:reader_result_slow(writer,fast,args,trace,run_all(slow,context_from(world,metadata),False{}))
        case 4:reader_result_slow(writer,fast,args,trace,run_all(slow,context_from(world,metadata),True{}))
        case 5:reader_result_fast(writer,slow,args,trace,run_all(fast,context_from(world,metadata),False{}))
        case 6:reader_result_slow(writer,fast,args,trace,run_all(slow,context_from(world,metadata),False{}))
        case _:(ScheduleOwners{metadata,writer,fast,slow,args,trace},Sys.Failed{world,DispatchFailed{}})
def barrier_ordinary_split_result(writer:write_provider_type(),fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,image:JsonDoc,split:world_type() & metadata_type()) -> ScheduleOwners & world_type():
  match split:
    case (barrierWorld,nextMetadata):(ScheduleOwners{nextMetadata,writer,fast,slow,args,List.append(&2,JsonDoc,trace,[json_parts([JsonText{"{\"kind\":\"barrierFrame\",\"state\":"},image,JsonText{"}"}])])},barrierWorld)
def barrier_ordinary_image_result(writer:write_provider_type(),fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,observed:context_type() & JsonDoc) -> ScheduleOwners & world_type():
  match observed:
    case (context,image):barrier_ordinary_split_result(writer,fast,slow,args,trace,image,Mixed.split(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,context))
def barrier_ordinary_image(writer:write_provider_type(),fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type()) -> ScheduleOwners & world_type():
  barrier_ordinary_image_result(writer,fast,slow,args,trace,json_context_image(context))
def barrier_ordinary_context(writer:write_provider_type(),fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>,context:context_type()) -> ScheduleOwners & world_type():
  barrier_ordinary_image(writer,fast,slow,args,trace,Mixed.frame_failures(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,Mixed.barrier(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~classify,context)))
def barrier_ordinary(owners:ScheduleOwners,world:world_type()) -> ScheduleOwners & world_type():
  match owners:
    case ScheduleOwners{metadata,writer,fast,slow,args,trace}:
      barrier_ordinary_context(writer,fast,slow,args,trace,Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata))
def observation_json(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"{\"kind\":\"phase\",\"name\":"++quoted(name)++"}"
    case Sch.Ran{id}:"{\"kind\":\"ran\",\"id\":"++U32.show(id)++"}"
    case Sch.Skipped{id}:"{\"kind\":\"skipped\",\"id\":"++U32.show(id)++"}"
    case Sch.Applied{}:"{\"kind\":\"barrier-applied\"}"
def observations_json(values:List<&2,Sch.Observation>) -> String:
  list_json(~Sch.Observation,~observation_json,values)
def strings_json(values:List<&2,String>) -> String:
  list_json(~String,~quoted,values)
def output_one(value:String) -> List<&2,String>:
  [value]
def write_raw_chunks(chunks:List<&2,String>) -> IO(Unit):
  match chunks:
    case []:IO.pure(Unit,Unit{})
    case chunk <> rest:IO.bind(Unit,Unit,IO.write(chunk),_ => write_raw_chunks(rest))
def write_output_chunks(chunks:List<&2,String>) -> IO(Unit):
  IO.bind(Unit,Unit,write_raw_chunks(chunks),_ => IO.write("\n"))
def schedule_finished_state(trace:List<&2,JsonDoc>,observations:List<&2,Sch.Observation>,observed:context_type() & JsonDoc) -> List<&2,String>:
  match observed:
    case (_,image):
      json_output(json_parts([JsonText{"{\"steps\":"},JsonText{observations_json(observations)},JsonText{",\"trace\":"},json_list_trace(trace),JsonText{",\"final\":"},image,JsonText{"}"}]))
def schedule_finished(world:world_type(),schedule:Sch.Schedule<Schema,store_type(),Unit,event_type(),ScheduleOwners>,observations:List<&2,Sch.Observation>) -> List<&2,String>:
  match schedule:
    case Sch.Schedule{namespace,name,steps,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:schedule_finished_state(trace,observations,json_context_image(Mixed.join(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,world,metadata)))
def schedule_result(result:Sch.RunResult<Schema,store_type(),Unit,event_type(),ScheduleOwners,ScheduleError>) -> List<&2,String>:
  match result:
    case Sch.Finished{schedule,world,observations}:schedule_finished(world,schedule,observations)
    case Sch.Failed{_,_,_,_}:output_one("unexpected-schedule-failure")
    case Sch.Rejected{_,_}:output_one("unexpected-schedule-rejection")
def schedule_built(input:world_type() & Sch.Build<Schema,store_type(),Unit,event_type(),ScheduleOwners>) -> List<&2,String>:
  match input:
    case (world,Sch.Invalid{_}):output_one("invalid-schedule")
    case (world,Sch.Built{schedule}):schedule_result(SchBarrier.run(~Schema,~store_type(),~Unit,~event_type(),~ScheduleOwners,~ScheduleError,~skip_ordinary,~dispatch_ordinary,~barrier_ordinary,~condition_ordinary,schedule,world))
def smoke_ready(initialized:world_type() & ScheduleOwners) -> List<&2,String>:
  match initialized:
    case (world,owners):schedule_built(schedule_plan(owners,world))
def empty_write_args(+source:W.Handle<Schema>) -> write_args_type():
  WriteArgs{Some{source},Some{source},None{},False{},None{},[]}
def run_smoke(context:context_type(),writer:write_provider_type(),fast:provider_type(),slow:provider_type(),+source:W.Handle<Schema>) -> List<&2,String>:
  smoke_ready(metadata_after(context,writer,fast,slow,empty_write_args(source),[]))
type FollowState is Type:
  FollowState{world:world_type(),owners:ScheduleOwners}

def follow_record(status:String,observations:List<&2,Sch.Observation>) -> JsonDoc:
  json_parts([JsonText{"{\"kind\":\"scheduleOutcome\",\"status\":"},JsonText{quoted(status)},JsonText{",\"observations\":"},JsonText{observations_json(observations)},JsonText{"}"}])
def follow_record_state(status:String,observations:List<&2,Sch.Observation>,world:world_type(),owners:ScheduleOwners) -> FollowState:
  match owners:
    case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace_append(trace,follow_record(status,observations))}}
def follow_record_schedule(status:String,observations:List<&2,Sch.Observation>,schedule:Sch.Schedule<Schema,store_type(),Unit,event_type(),ScheduleOwners>,world:world_type()) -> FollowState:
  match schedule:
    case Sch.Schedule{_,_,_,owners}:follow_record_state(status,observations,world,owners)
def follow_schedule_result(result:Sch.RunResult<Schema,store_type(),Unit,event_type(),ScheduleOwners,ScheduleError>) -> FollowState:
  match result:
    case Sch.Finished{schedule,world,observations}:follow_record_schedule("finished",observations,schedule,world)
    case Sch.Failed{schedule,world,_,observations}:follow_record_schedule("failed",observations,schedule,world)
    case Sch.Rejected{schedule,world}:follow_record_schedule("rejected",[],schedule,world)
def follow_build_result(world:world_type(),build:Sch.Build<Schema,store_type(),Unit,event_type(),ScheduleOwners>) -> FollowState:
  match build:
    case Sch.Invalid{owners}:follow_record_state("invalid",[],world,owners)
    case Sch.Built{schedule}:follow_schedule_result(SchBarrier.run(~Schema,~store_type(),~Unit,~event_type(),~ScheduleOwners,~ScheduleError,~skip_ordinary,~dispatch_ordinary,~barrier_ordinary,~condition_ordinary,schedule,world))
def follow_schedule_namespace(+name:String,+steps:List<&2,Sch.Step>,owners:ScheduleOwners,named:world_type() & U32) -> FollowState:
  match named:
    case (world,+namespace):follow_build_result(world,Sch.build(~Schema,~store_type(),~Unit,~event_type(),~ScheduleOwners,namespace,name,steps,[1,2,3,4],owners))
def follow_schedule(+name:String,+steps:List<&2,Sch.Step>,owners:ScheduleOwners,world:world_type()) -> FollowState:
  follow_schedule_namespace(name,steps,owners,W.namespace(~Schema,~store_type(),~Unit,~event_type(),world))
def follow_scenario_error(state:FollowState,reason:String) -> FollowState:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace_append(trace,json_parts([JsonText{"{\"kind\":\"scenarioError\",\"reason\":"},JsonText{quoted(reason)},JsonText{"}"}]))}}
type FailureTargetState is Data:
  FailureTargetState{doomed:Maybe<&2,W.Handle<Schema>>,targets:List<&2,RelationProvider.Targets<Schema>>,valid:Bool}
def failure_targets(+source:W.Handle<Schema>,doomed:Maybe<&2,W.Handle<Schema>>) -> FailureTargetState:
  match doomed:
    case None{}:FailureTargetState{None{},[],False{}}
    case Some{+handle}:FailureTargetState{Some{handle},[RelationProvider.Targets{source,source},RelationProvider.Targets{source,handle}],True{}}
def follow_failure_targets(world:world_type(),metadata:metadata_type(),writer:write_provider_type(),fast:provider_type(),slow:provider_type(),source:Maybe<&2,W.Handle<Schema>>,target:Maybe<&2,W.Handle<Schema>>,trace:List<&2,JsonDoc>,prepared:FailureTargetState) -> FollowState:
  match prepared:
    case FailureTargetState{doomed,_,False{}}:follow_scenario_error(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,WriteArgs{source,target,doomed,False{},None{},[]},trace}},"missing-doomed-handle-before-relation-failure")
    case FailureTargetState{doomed,targets,True{}}:FollowState{world,ScheduleOwners{metadata,writer,fast,slow,WriteArgs{source,target,doomed,True{},None{},targets},trace}}
def follow_set_write_args(state:FollowState,failure:Bool) -> FollowState:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          match writeArgs:
            case WriteArgs{source,target,doomed,emitValues,_,_}:
              match source:
                case None{}:follow_scenario_error(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}},"missing-source-handle")
                case Some{+sourceHandle}:
                  match target:
                    case None{}:follow_scenario_error(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}},"missing-target-handle")
                    case Some{+targetHandle}:
                      match failure:
                        case False{}:FollowState{world,ScheduleOwners{metadata,writer,fast,slow,WriteArgs{source,target,doomed,False{},None{},[RelationProvider.Targets{sourceHandle,targetHandle}]},trace}}
                        case True{}:follow_failure_targets(world,metadata,writer,fast,slow,source,target,trace,failure_targets(sourceHandle,doomed))
def follow_set_structural(state:FollowState,command:StructuralCommand) -> FollowState:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          match writeArgs:
            case WriteArgs{source,target,doomed,emitValues,_,_}:FollowState{world,ScheduleOwners{metadata,writer,fast,slow,WriteArgs{source,target,doomed,emitValues,Some{command},[]},trace}}
def follow_run(state:FollowState,+name:String,+steps:List<&2,Sch.Step>) -> FollowState:
  match state:
    case FollowState{world,owners}:follow_schedule(name,steps,owners,world)
def follow_warm(state:FollowState) -> FollowState:
  follow_run(state,"warm-readers",[Sch.System{2,0},Sch.System{3,0}])
def follow_command(state:FollowState,+name:String,command:StructuralCommand) -> FollowState:
  follow_run(follow_set_structural(state,command),name,[Sch.System{1,0},Sch.Barrier{}])
def follow_removed(state:FollowState) -> FollowState:
  follow_run(state,"read-after-actual-remove",[Sch.System{2,0},Sch.System{3,0}])
def follow_reinserted(state:FollowState) -> FollowState:
  follow_run(state,"read-after-actual-reinsert",[Sch.System{2,0},Sch.System{3,0}])
def follow_actual_remove(state:FollowState) -> FollowState:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          match writeArgs:
            case WriteArgs{source,Some{+target},doomed,emitValues,_,_}:
              follow_removed(follow_run(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,WriteArgs{source,Some{target},doomed,emitValues,Some{RemoveValue{target}},[]},trace}},"ordinary-remove-target-value",[Sch.System{1,0},Sch.Barrier{}]))
            case _:follow_scenario_error(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}},"missing-target-before-remove")
def follow_actual_reinsert(state:FollowState) -> FollowState:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          match writeArgs:
            case WriteArgs{source,Some{+target},doomed,emitValues,_,_}:
              follow_reinserted(follow_run(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,WriteArgs{source,Some{target},doomed,emitValues,Some{InsertValue{target,44}},[]},trace}},"ordinary-reinsert-target-value",[Sch.System{1,0},Sch.Barrier{}]))
            case _:follow_scenario_error(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}},"missing-target-before-reinsert")
def follow_link(state:FollowState) -> FollowState:
  follow_run(follow_set_write_args(state,False{}),"writer-link-then-barrier",[Sch.System{1,0},Sch.Barrier{}])
def follow_failures(state:FollowState) -> FollowState:
  follow_run(follow_set_write_args(state,True{}),"writer-self-and-missing-queued",[Sch.System{1,0}])
def follow_failure_barrier(state:FollowState) -> FollowState:
  follow_run(state,"writer-self-and-missing-published",[Sch.Barrier{}])
def follow_spawn(state:FollowState) -> FollowState:
  follow_command(state,"ordinary-spawn-empty",SpawnEmpty{})
def follow_despawn_args(world:world_type(),metadata:metadata_type(),writer:write_provider_type(),fast:provider_type(),slow:provider_type(),args:write_args_type(),trace:List<&2,JsonDoc>) -> FollowState:
  match args:
    case WriteArgs{source,target,Some{+handle},emitValues,_,_}:
      follow_command(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,WriteArgs{source,target,Some{handle},emitValues,None{},[]},trace}},"ordinary-despawn-returned-spawn",DespawnEmpty{handle})
    case _ : follow_scenario_error(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,args,trace}},"missing-actual-spawn-handle")
def follow_despawn(state:FollowState) -> FollowState:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          follow_despawn_args(world,metadata,writer,fast,slow,writeArgs,trace)
def follow_slow_failure(state:FollowState) -> FollowState:
  follow_run(state,"slow-reader-callback-failure",[Sch.System{4,0}])
def follow_active_skip(state:FollowState) -> FollowState:
  follow_run(state,"active-fast-reader-condition-false",[Sch.System{2,2}])
def follow_slow_retry(state:FollowState) -> FollowState:
  follow_run(state,"slow-reader-retry",[Sch.System{3,0}])
def follow_slow_read(state:FollowState) -> FollowState:
  follow_run(state,"slow-reader-independent-read",[Sch.System{3,0}])
def follow_fast_repeat(state:FollowState) -> FollowState:
  follow_run(state,"fast-reader-repeat-empty",[Sch.System{2,0}])
def follow_slow_repeat(state:FollowState) -> FollowState:
  follow_run(state,"slow-reader-repeat-empty",[Sch.System{3,0}])
def follow_final_image(trace:List<&2,JsonDoc>,observed:context_type() & JsonDoc) -> List<&2,String>:
  match observed:
    case (_,image):json_output(json_parts([JsonText{"{\"scenario\":\"ordinary-scheduled-failure-retry\",\"trace\":"},json_list_trace(trace),JsonText{",\"final\":"},image,JsonText{"}"}]))
def follow_finish(state:FollowState) -> List<&2,String>:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          follow_final_image(trace,json_context_image(context_from(world,metadata)))
def follow_after_slow_repeat(state:FollowState) -> List<&2,String>:
  follow_finish(follow_slow_repeat(state))
def follow_after_fast_repeat(state:FollowState) -> List<&2,String>:
  follow_after_slow_repeat(follow_fast_repeat(state))
def follow_fast_read(state:FollowState) -> FollowState:
  follow_run(state,"fast-reader-independent-read",[Sch.System{2,0}])
def follow_after_retry(state:FollowState) -> List<&2,String>:
  follow_after_fast_repeat(follow_fast_read(follow_slow_retry(state)))
def follow_after_failure(state:FollowState) -> List<&2,String>:
  follow_after_retry(follow_slow_failure(state))
def follow_after_link(state:FollowState) -> List<&2,String>:
  follow_after_failure(follow_active_skip(follow_failure_barrier(follow_failures(follow_despawn(follow_spawn(state))))))
def follow_after_warm(state:FollowState) -> List<&2,String>:
  follow_after_link(follow_link(follow_actual_reinsert(follow_actual_remove(state))))
def follow_after_seed(state:FollowState) -> List<&2,String>:
  match state:
    case FollowState{world,owners}:
      match owners:
        case ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}:
          match writeArgs:
            case WriteArgs{Some{_},Some{_},_,_,_,_}:follow_after_warm(follow_warm(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}}))
            case _:follow_finish(follow_scenario_error(FollowState{world,ScheduleOwners{metadata,writer,fast,slow,writeArgs,trace}},"ordinary-seed-did-not-return-two-live-handles"))
def follow_initial(initialized:world_type() & ScheduleOwners) -> List<&2,String>:
  match initialized:
    case (world,owners):follow_after_seed(follow_command(FollowState{world,owners},"ordinary-seed-two-values",SeedPair{}))
def run_followup(context:context_type(),writer:write_provider_type(),fast:provider_type(),slow:provider_type()) -> List<&2,String>:
  follow_initial(metadata_after(context,writer,fast,slow,WriteArgs{None{},None{},None{},False{},None{},[]},[]))

def followup_slow_defined(writer:write_provider_type(),fast:provider_type(),defined:definition_type()) -> List<&2,String>:
  match defined:
    case Ordinary.DefinitionRejected{_,_,_}:output_one("slow-reader-registration-rejected")
    case Ordinary.DefinitionDisposalRejected{_,_,_}:output_one("slow-reader-initialization-disposal-rejected")
    case Ordinary.DefinitionRegistered{context,slow}:run_followup(context,writer,fast,slow)
def followup_fast_defined(writer:write_provider_type(),defined:definition_type()) -> List<&2,String>:
  match defined:
    case Ordinary.DefinitionRejected{_,_,_}:output_one("fast-reader-registration-rejected")
    case Ordinary.DefinitionDisposalRejected{_,_,_}:output_one("fast-reader-initialization-disposal-rejected")
    case Ordinary.DefinitionRegistered{context,fast}:followup_slow_defined(writer,fast,define_all(context,"slow"))
def followup_writer_defined(defined:write_definition_type()) -> List<&2,String>:
  match defined:
    case Ordinary.DefinitionRejected{_,_,_}:output_one("writer-registration-rejected")
    case Ordinary.DefinitionDisposalRejected{_,_,_}:output_one("writer-initialization-disposal-rejected")
    case Ordinary.DefinitionRegistered{context,writer}:followup_fast_defined(writer,define_all(context,"fast"))
def followup_start(state:Setup) -> List<&2,String>:
  match state:
    case SetupFailed{}:output_one("\"setup-failed\"")
    case Ready{context}:followup_writer_defined(define_writer(context,"relation-writer"))

def both_root_outputs(first:List<&2,String>,second:List<&2,String>) -> List<&2,String>:
  List.append(&2,String,["["],List.append(&2,String,first,List.append(&2,String,[","],List.append(&2,String,second,["]"]))))

def write_second_root() -> IO(Unit):
  IO.bind(Unit,Unit,IO.write(","),_ => IO.bind(Unit,Unit,write_raw_chunks(followup_start(setup_with_factory(W.Factory{2}))),_ => IO.bind(Unit,Unit,IO.write("]"),_ => IO.write("\n"))))
def write_first_root() -> IO(Unit):
  IO.bind(Unit,Unit,IO.write("["),_ => IO.bind(Unit,Unit,write_raw_chunks(followup_start(setup_with_factory(W.Factory{1}))),_ => write_second_root()))
def main() -> IO(Unit):
  write_first_root()
