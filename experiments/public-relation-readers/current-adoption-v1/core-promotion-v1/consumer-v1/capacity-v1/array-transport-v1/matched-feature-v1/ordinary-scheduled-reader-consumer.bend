import Base
import ../../../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../../../src/ecs/internal/relation-failures/readings.bend as KRead
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../../src/ecs/reader-parameter.bend as RP
import ../../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../../src/ecs/compose.bend as Compose
import ../../../../../../../../src/ecs/inspector.bend as Inspector
import ../../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../../src/ecs/ordinary-query-observable.bend as Observable
import ../../../../../../../../src/ecs/ordinary-reader-query-parameter.bend as QParam
import ../../../../../../../../src/ecs/ordinary-reader-stream-parameter.bend as Stream
import ../../../../../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../../src/ecs/event-stream.bend as Leaf
import ../../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../../src/ecs/relation-commands.bend as Notice
import ../../../../../../../../src/ecs/removals.bend as Rm
import ../../../../../../../../src/ecs/ordinary-removal-provision.bend as Provision
import ../../../../../../../../src/ecs/relation-types.bend as Relations
import ../../../../../../../../src/ecs/relation-failure-reader.bend as KDecl
import ../../../../../../../../src/ecs/internal/relation-failures/domains.bend as KD
import ../../../../../../../../src/ecs/relation-providers.bend as RelationProvider
import ../../../../../../../../src/ecs/commands.bend as Commands
import ../../../../../../../../src/ecs/capabilities.bend as Cap

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
  Unit
def no_grant(~H:Type) -> Unit:
  Unit{}
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
def query_declaration() -> Observable.Declaration<Schema,Compose.Frame<Schema,store_type(),Unit,event_type()>,Unit,Inspector.Frame<Schema,store_type(),Unit,event_type()>,Unit>:
  Observable.with_component(~Schema,~store_type(),~Relations.Graph<Schema>,~U32,~Unit,~Unit,~take_values,~put_values,~presence,~Unit,~event_type(),~binding())
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
def relation_declarations() -> List<&2,KDecl.Declaration<Schema>>:
  [KDecl.relation(~Schema,relation_descriptor())]
def classify(value:event_type()) -> Maybe<KD.DescriptorKey<Schema>>:
  match value:
    case Notice.RelationFailed{Relations.Failure{Relations.Descriptor{key,_,_,_},_,_,_,_}}:Some{KD.DeclaredKey{key}}
    case _:None{}

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
  QParam.Rows<Schema,Unit>
def q_delta() -> Type:
  Unit
def q_parameter_type() -> Data:
  RP.Param<context_type(),q_owner(),q_view(),q_delta(),QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~query_declaration()),QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~query_declaration()),QParam.commit_context(~context_type()),QParam.release_context(~context_type())>
def q_parameter() -> q_parameter_type():
  QParam.from_observable(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~query_declaration())

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

def mr_owner() -> Type:
  m_owner() & r_owner()
def mr_view() -> Data:
  RP.ViewPair<m_view(),r_view()>
def mr_delta() -> Type:
  m_delta() & r_delta()
def mr_parameter_type() -> Data:
  RP.Param<context_type(),mr_owner(),mr_view(),mr_delta(),RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())),RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())),RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)),RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit))>
def mr_parameter() -> mr_parameter_type():
  RP.pair(~context_type(),~m_owner(),~m_view(),~m_delta(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~r_owner(),~r_view(),~r_delta(),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit),m_parameter(),r_parameter())
def pair_mr(left:m_parameter_type(),right:r_parameter_type()) -> mr_parameter_type():
  RP.pair(~context_type(),~m_owner(),~m_view(),~m_delta(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~r_owner(),~r_view(),~r_delta(),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit),left,right)

def emr_owner() -> Type:
  e_owner() & mr_owner()
def emr_view() -> Data:
  RP.ViewPair<e_view(),mr_view()>
def emr_delta() -> Type:
  e_delta() & mr_delta()
def emr_parameter_type() -> Data:
  RP.Param<context_type(),emr_owner(),emr_view(),emr_delta(),RP.pair_validate_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()))),RP.pair_prepare_fn(~context_type(),~e_owner(),~mr_owner(),~e_view(),~mr_view(),~e_delta(),~mr_delta(),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()))),RP.pair_commit_fn(~context_type(),~e_owner(),~mr_owner(),~e_delta(),~mr_delta(),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit))),RP.pair_release_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)))>
def emr_parameter() -> emr_parameter_type():
  RP.pair(~context_type(),~e_owner(),~e_view(),~e_delta(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~mr_owner(),~mr_view(),~mr_delta(),~RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())),~RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())),~RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)),~RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)),e_parameter(),mr_parameter())
def pair_emr(left:e_parameter_type(),right:mr_parameter_type()) -> emr_parameter_type():
  RP.pair(~context_type(),~e_owner(),~e_view(),~e_delta(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~mr_owner(),~mr_view(),~mr_delta(),~RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())),~RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())),~RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)),~RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)),left,right)

def eemr_owner() -> Type:
  e_owner() & emr_owner()
def eemr_view() -> Data:
  RP.ViewPair<e_view(),emr_view()>
def eemr_delta() -> Type:
  e_delta() & emr_delta()
def eemr_parameter_type() -> Data:
  RP.Param<context_type(),eemr_owner(),eemr_view(),eemr_delta(),RP.pair_validate_fn(~context_type(),~e_owner(),~emr_owner(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_validate_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())))),RP.pair_prepare_fn(~context_type(),~e_owner(),~emr_owner(),~e_view(),~emr_view(),~e_delta(),~emr_delta(),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_prepare_fn(~context_type(),~e_owner(),~mr_owner(),~e_view(),~mr_view(),~e_delta(),~mr_delta(),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())))),RP.pair_commit_fn(~context_type(),~e_owner(),~emr_owner(),~e_delta(),~emr_delta(),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_commit_fn(~context_type(),~e_owner(),~mr_owner(),~e_delta(),~mr_delta(),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)))),RP.pair_release_fn(~context_type(),~e_owner(),~emr_owner(),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_release_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit))))>
def eemr_parameter() -> eemr_parameter_type():
  RP.pair(~context_type(),~e_owner(),~e_view(),~e_delta(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~emr_owner(),~emr_view(),~emr_delta(),~RP.pair_validate_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()))),~RP.pair_prepare_fn(~context_type(),~e_owner(),~mr_owner(),~e_view(),~mr_view(),~e_delta(),~mr_delta(),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()))),~RP.pair_commit_fn(~context_type(),~e_owner(),~mr_owner(),~e_delta(),~mr_delta(),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit))),~RP.pair_release_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit))),e_parameter(),emr_parameter())
def pair_eemr(left:e_parameter_type(),right:emr_parameter_type()) -> eemr_parameter_type():
  RP.pair(~context_type(),~e_owner(),~e_view(),~e_delta(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~emr_owner(),~emr_view(),~emr_delta(),~RP.pair_validate_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()))),~RP.pair_prepare_fn(~context_type(),~e_owner(),~mr_owner(),~e_view(),~mr_view(),~e_delta(),~mr_delta(),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations()))),~RP.pair_commit_fn(~context_type(),~e_owner(),~mr_owner(),~e_delta(),~mr_delta(),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit))),~RP.pair_release_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit))),left,right)

def all_owner() -> Type:
  q_owner() & eemr_owner()
def all_view() -> Data:
  RP.ViewPair<q_view(),eemr_view()>
def all_delta() -> Type:
  q_delta() & eemr_delta()
def validate_all(context:context_type(),owner:all_owner()) -> context_type() & (all_owner() & Bool):
  RP.pair_validate_fn(~context_type(),~q_owner(),~eemr_owner(),~QParam.validate_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~query_declaration()),~RP.pair_validate_fn(~context_type(),~e_owner(),~emr_owner(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_validate_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.validate_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_validate_fn(~context_type(),~m_owner(),~r_owner(),~Stream.validate_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection()),~Stream.validate_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())))),context,owner)
def prepare_all(context:context_type(),+cursor:U32,owner:all_owner()) -> context_type() & (all_owner() & (all_view() & all_delta())):
  RP.pair_prepare_fn(~context_type(),~q_owner(),~eemr_owner(),~q_view(),~eemr_view(),~q_delta(),~eemr_delta(),~QParam.prepare_context(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~Unit,~Unit,~query_declaration()),~RP.pair_prepare_fn(~context_type(),~e_owner(),~emr_owner(),~e_view(),~emr_view(),~e_delta(),~emr_delta(),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_prepare_fn(~context_type(),~e_owner(),~mr_owner(),~e_view(),~mr_view(),~e_delta(),~mr_delta(),~Stream.prepare_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration()),~RP.pair_prepare_fn(~context_type(),~m_owner(),~r_owner(),~m_view(),~r_view(),~m_delta(),~r_delta(),~Stream.prepare_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.prepare_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations())))),context,cursor,owner)
def commit_all(context:context_type(),owner:all_owner(),delta:all_delta(),+cursor:U32) -> context_type() & all_owner():
  RP.pair_commit_fn(~context_type(),~q_owner(),~eemr_owner(),~q_delta(),~eemr_delta(),~QParam.commit_context(~context_type()),~RP.pair_commit_fn(~context_type(),~e_owner(),~emr_owner(),~e_delta(),~emr_delta(),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_commit_fn(~context_type(),~e_owner(),~mr_owner(),~e_delta(),~mr_delta(),~Stream.commit_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_commit_fn(~context_type(),~m_owner(),~r_owner(),~m_delta(),~r_delta(),~Stream.commit_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.commit_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)))),context,owner,delta,cursor)
def release_all(context:context_type(),owner:all_owner()) -> context_type():
  RP.pair_release_fn(~context_type(),~q_owner(),~eemr_owner(),~QParam.release_context(~context_type()),~RP.pair_release_fn(~context_type(),~e_owner(),~emr_owner(),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_release_fn(~context_type(),~e_owner(),~mr_owner(),~Stream.release_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events),~RP.pair_release_fn(~context_type(),~m_owner(),~r_owner(),~Stream.release_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~select_removal),~Stream.release_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit)))),context,owner)
def all_parameter_type() -> Data:
  RP.Param<context_type(),all_owner(),all_view(),all_delta(),validate_all,prepare_all,commit_all,release_all>
def pair_all(left:q_parameter_type(),right:eemr_parameter_type()) -> all_parameter_type():
  match left right:
    case RP.Param{a} RP.Param{b}:RP.Param{List.append(&2,String,a,b)}
def all_parameter() -> all_parameter_type():
  pair_all(q_parameter(),eemr_parameter())

def q_initialize(context:context_type(),_:RP.RegistrationFacts) -> context_type() & (q_owner() & q_parameter_type()):
  (context,(Unit{},q_parameter()))
def e_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (e_owner() & e_parameter_type()):
  Stream.initialize_event(~Schema,~store_type(),~Unit,~Publication,~event_type(),~family_type(),~Unit,~take_events,~put_events,~event_declaration(),context,facts)
def m_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (m_owner() & m_parameter_type()):
  Stream.initialize_removal(~Schema,~store_type(),~Unit,~Publication,~U32,~family_type(),~Unit,~inject_removal,~select_removal,~removal_selection(),context,facts)
def r_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (r_owner() & r_parameter_type()):
  Stream.initialize_relation(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~relation_declarations(),context,facts)
def mr_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (mr_owner() & mr_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~m_owner(),~m_parameter_type(),~r_owner(),~r_parameter_type(),~mr_parameter_type(),~m_initialize,~r_initialize,~pair_mr,context,facts)
def emr_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (emr_owner() & emr_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~e_owner(),~e_parameter_type(),~mr_owner(),~mr_parameter_type(),~emr_parameter_type(),~e_initialize,~mr_initialize,~pair_emr,context,facts)
def eemr_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (eemr_owner() & eemr_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~e_owner(),~e_parameter_type(),~emr_owner(),~emr_parameter_type(),~eemr_parameter_type(),~e_initialize,~emr_initialize,~pair_eemr,context,facts)
def all_initialize(context:context_type(),facts:RP.RegistrationFacts) -> context_type() & (all_owner() & all_parameter_type()):
  RP.initialize_pair(~context_type(),~RP.RegistrationFacts,~q_owner(),~q_parameter_type(),~eemr_owner(),~eemr_parameter_type(),~all_parameter_type(),~q_initialize,~eemr_initialize,~pair_all,context,facts)


def callback_outcome(fail:Bool) -> Tx.Outcome<U32>:
  match fail:
    case True{}:Tx.Failure{7}
    case False{}:Tx.Success{}
def callback(~H:Type,~caps:no_caps(H),input:all_view() & Bool,owner:H) -> H & (Tx.Outcome<U32> & all_view()):
  match input:
    case (view,fail):(owner,(callback_outcome(fail),view))

# Nonempty storage plus seeded histories exercise the product itself. Actual
# scheduled mutation/publication timing remains a separate #43 acceptance gate.
type Setup is Type:
  Ready{context:context_type(),entity:W.Handle<Schema>}
  SetupFailed{}
def seeded_column(graph:Relations.Graph<Schema>,result:Col.SwapOutcome<Schema,U32>) -> store_type() & Bool:
  match result:
    case Col.Accepted{column,_}:(Notice.Store{column,graph},True{})
    case Col.Rejected{column,_}:(Notice.Store{column,graph},False{})
def seed_column(store:store_type(),id:U32) -> store_type() & Bool:
  match store:
    case Notice.Store{components,+graph}:seeded_column(graph,Col.swap(~Schema,~U32,components,id,Some{42}))
def setup_stored(+entity:W.Handle<Schema>,stored:world_type() & Bool) -> Setup:
  match stored:
    case (world,False{}):SetupFailed{}
    case (world,True{}):
      Ready{Mixed.start(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,
        W.event_publish(~Schema,~store_type(),~Unit,~event_type(),world,
          [Notice.Original{Value{11}},inject_removal(Identity.component(~Schema,~U32,"value"),entity)]),
        Leaf.provision(~Schema,~event_type(),Event.domain(~Schema,~event_type(),"values"),65536n),Unit{}),entity}
def entity_id(entity:W.Handle<Schema>) -> U32:
  match entity:
    case W.Handle{_,id}:id
def setup_activated(+entity:W.Handle<Schema>,activated:world_type() & W.Status) -> Setup:
  match activated:
    case (_,W.Rejected{_}):SetupFailed{}
    case (world,W.Accepted{}):setup_stored(entity,W.with_store(~Schema,~store_type(),~Unit,~event_type(),~Bool,(store => seed_column(store,entity_id(entity))),world))
def setup_reserved(reserved:world_type() & W.Reservation<Schema>) -> Setup:
  match reserved:
    case (_,W.ReservationRejected{_}):SetupFailed{}
    case (world,W.Reserved{+entity}):setup_activated(entity,W.activate(~Schema,~store_type(),~Unit,~event_type(),world,entity))
def setup_created(created:W.Creation<Schema,store_type(),Unit,event_type()>) -> Setup:
  match created:
    case W.CreateRejected{_,_}:SetupFailed{}
    case W.Created{_,world}:setup_reserved(W.reserve_id(~Schema,~store_type(),~Unit,~event_type(),world))
def setup() -> Setup:
  setup_created(W.create(~Schema,~store_type(),~Unit,~event_type(),~empty_store,W.factory(),Unit{}))

# JSON strings here are the frozen ASCII declaration names of this consumer.
def quoted(value:String) -> String:
  "\""++value++"\""
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def list_tail(~A:Data,~render:A -> String,values:List<&2,A>) -> String:
  match values:
    case []:""
    case value <> rest:","++render(value)++list_tail(~A,~render,rest)
def list_json(~A:Data,~render:A -> String,values:List<&2,A>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"["++render(value)++list_tail(~A,~render,rest)++"]"
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
type WorldObservation is Data:
  WorldObservation{namespace:U32,clock:U32,pending:U32,graph:Relations.Graph<Schema>,events:List<&2,event_type()>}
def world_graph_store(store:store_type()) -> store_type() & Relations.Graph<Schema>:
  Notice.graph_read(~Schema,~Col.Column<Schema,U32>,store)
def world_graph_read(world:world_type()) -> world_type() & Relations.Graph<Schema>:
  W.with_store(~Schema,~store_type(),~Unit,~event_type(),~Relations.Graph<Schema>,world_graph_store,world)
def world_snapshot_events_join(graph:Relations.Graph<Schema>,observed:world_type() & List<&2,event_type()>) -> world_type() & (Relations.Graph<Schema> & List<&2,event_type()>):
  match observed:
    case (world,events):(world,(graph,events))
def world_snapshot_events(result:world_type() & Relations.Graph<Schema>) -> world_type() & (Relations.Graph<Schema> & List<&2,event_type()>):
  match result:
    case (world,graph):world_snapshot_events_join(graph,W.events_view(~Schema,~store_type(),~Unit,~event_type(),world))
def world_snapshot_pending_join(graph:Relations.Graph<Schema>,events:List<&2,event_type()>,observed:world_type() & U32) -> world_type() & (Relations.Graph<Schema> & (List<&2,event_type()> & U32)):
  match observed:
    case (world,pending):(world,(graph,(events,pending)))
def world_snapshot_pending(result:world_type() & (Relations.Graph<Schema> & List<&2,event_type()>)) -> world_type() & (Relations.Graph<Schema> & (List<&2,event_type()> & U32)):
  match result:
    case (world,(graph,events)):world_snapshot_pending_join(graph,events,W.pending_count(~Schema,~store_type(),~Unit,~event_type(),world))
def world_snapshot_clock_join(graph:Relations.Graph<Schema>,events:List<&2,event_type()>,pending:U32,observed:world_type() & U32) -> world_type() & (Relations.Graph<Schema> & (List<&2,event_type()> & (U32 & U32))):
  match observed:
    case (world,clock):(world,(graph,(events,(pending,clock))))
def world_snapshot_clock(result:world_type() & (Relations.Graph<Schema> & (List<&2,event_type()> & U32))) -> world_type() & (Relations.Graph<Schema> & (List<&2,event_type()> & (U32 & U32))):
  match result:
    case (world,(graph,(events,pending))):world_snapshot_clock_join(graph,events,pending,W.clock(~Schema,~store_type(),~Unit,~event_type(),world))
def world_snapshot_namespace_join(graph:Relations.Graph<Schema>,events:List<&2,event_type()>,pending:U32,clock:U32,observed:world_type() & U32) -> world_type() & WorldObservation:
  match observed:
    case (world,namespace):(world,WorldObservation{namespace,clock,pending,graph,events})
def world_snapshot_namespace(result:world_type() & (Relations.Graph<Schema> & (List<&2,event_type()> & (U32 & U32)))) -> world_type() & WorldObservation:
  match result:
    case (world,(graph,(events,(pending,clock)))):world_snapshot_namespace_join(graph,events,pending,clock,W.namespace(~Schema,~store_type(),~Unit,~event_type(),world))
def world_snapshot(world:world_type()) -> world_type() & WorldObservation:
  world_snapshot_namespace(world_snapshot_clock(world_snapshot_pending(world_snapshot_events(world_graph_read(world)))))
def context_snapshot_join(state:Mixed.State<Schema,Publication,family_type(),Unit>,tick:Nat,observed:world_type() & WorldObservation) -> context_type() & WorldObservation:
  match observed:
    case (world,image):(Route.Runtime{world,state,tick},image)
def context_snapshot(context:context_type()) -> context_type() & WorldObservation:
  match context:
    case Route.Runtime{world,state,tick}:context_snapshot_join(state,tick,world_snapshot(world))
def world_observation_json(value:WorldObservation) -> String:
  match value:
    case WorldObservation{namespace,clock,pending,graph,events}:"{\"namespace\":"++U32.show(namespace)++",\"clock\":"++U32.show(clock)++",\"pending\":"++U32.show(pending)++",\"graph\":"++graph_json(graph)++",\"events\":"++list_json(~event_type(),~notice_json,events)++"}"
def row_json(value:IQ.ProjectedRow<Schema,Unit>) -> String:
  match value:
    case IQ.ProjectedRow{entity,_}:"{\"entity\":"++handle_json(entity)++",\"value\":null}"
def query_json(value:q_view()) -> String:
  match value:
    case QParam.Rows{rows}:list_json(~IQ.ProjectedRow<Schema,Unit>,~row_json,rows)
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
    case RP.ViewPair{query,RP.ViewPair{eventA,RP.ViewPair{eventB,RP.ViewPair{removals,relations}}}}:
      "{\"query\":"++query_json(query)++",\"eventA\":"++event_json(eventA)++",\"eventB\":"++event_json(eventB)++",\"removals\":"++removals_json(removals)++",\"relations\":"++relations_json(relations)++"}"


def registry_type() -> Type:
  Sys.Registry<Schema,store_type(),Unit,event_type(),Ordinary.Invocation<metadata_type(),all_owner(),all_parameter_type(),Unit,Bool>,Empty,Ordinary.Envelope<metadata_type(),all_owner(),all_parameter_type(),Unit,U32,all_view()>,Ordinary.shared_runner(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~all_owner(),~all_view(),~all_delta(),~Bool,~Unit,~U32,~all_view(),~validate_all,~prepare_all,~commit_all,~release_all,~no_caps,~callback,~no_grant(~Tx.Tx<world_type(),event_type()>),~sync_events,~classify)>
def provider_type() -> Type:
  Ordinary.Provider<registry_type(),all_owner(),all_parameter_type(),Unit>
def definition_type() -> Type:
  Ordinary.Definition<context_type(),provider_type(),all_parameter_type(),Unit>
def run_type() -> Type:
  Ordinary.RunResult<context_type(),provider_type(),Bool,U32,all_view()>
def define_all(context:context_type(),name:String) -> definition_type():
  Ordinary.define_mixed(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~all_owner(),~all_view(),~all_delta(),~Bool,~Unit,~U32,~all_view(),~validate_all,~prepare_all,~commit_all,~release_all,~no_caps,~callback,~no_grant(~Tx.Tx<world_type(),event_type()>),~sync_events,~classify,~all_initialize,all_parameter(),Unit{},context,name)
def run_all(provider:provider_type(),context:context_type(),fail:Bool) -> run_type():
  Ordinary.run_mixed(~Schema,~store_type(),~Unit,~Publication,~family_type(),~Unit,~all_owner(),~all_view(),~all_delta(),~Bool,~Unit,~U32,~all_view(),~validate_all,~prepare_all,~commit_all,~release_all,~no_caps,~callback,~no_grant(~Tx.Tx<world_type(),event_type()>),~sync_events,~classify,provider,context,fail)

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
    case WorldObservation{_,clock,_,_,_}:clock
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
def barrier_after_first(context:context_type(),first:provider_type(),second:provider_type(),report:MutationReport,prefix:String) -> String:
  after_barrier(barrier_context(context),first,second,report,prefix)
def before_barrier(context:context_type(),first:provider_type(),second:provider_type(),report:MutationReport) -> String:
  observe_result((context => provider => row => barrier_after_first(context,provider,second,report,row)),"pre-barrier-fast",run_all(first,context,False{}))
def scheduled_observers_report(first:provider_type(),second:provider_type(),scheduled:context_type() & MutationReport) -> String:
  match scheduled:
    case (context,report):before_barrier(context,first,second,report)
def scheduled_observers(context:context_type(),first:provider_type(),second:provider_type(),entity:W.Handle<Schema>) -> String:
  scheduled_observers_report(first,second,schedule_relation(context,entity))
def second_defined(entity:W.Handle<Schema>,first:provider_type(),defined:definition_type()) -> String:
  match defined:
    case Ordinary.DefinitionRejected{_,_,_}:"unexpected-second-registration-rejection"
    case Ordinary.DefinitionDisposalRejected{_,_,_}:"unexpected-second-initialization-cleanup-rejection"
    case Ordinary.DefinitionRegistered{context,second}:scheduled_observers(context,first,second,entity)
def first_defined(entity:W.Handle<Schema>,defined:definition_type()) -> String:
  match defined:
    case Ordinary.DefinitionRejected{_,_,_}:"unexpected-first-registration-rejection"
    case Ordinary.DefinitionDisposalRejected{_,_,_}:"unexpected-first-initialization-cleanup-rejection"
    case Ordinary.DefinitionRegistered{context,first}:second_defined(entity,first,define_all(context,"B"))
def started(state:Setup) -> String:
  match state:
    case SetupFailed{}:"unexpected-setup-failure"
    case Ready{context,entity}:first_defined(entity,define_all(context,"A"))
def main() -> IO(Unit):
  IO.print(started(setup()))
