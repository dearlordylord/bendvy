import Base
import ../../../../src/ecs/ordinary-machine-declaration.bend as MD
import ../../../../src/ecs/ordinary-machine-initialization-marker.bend as Marker
import ../../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../../src/ecs/ordinary-owned-event-binding.bend as EventBinding
import ../../../../src/ecs/ordinary-owned-event-family-write.bend as EventWrite
import ../../../../src/ecs/ordinary-owned-event-declaration.bend as Events
import ../../../../src/ecs/ordinary-owned-event-family-publisher.bend as Publisher
import ../../../../src/ecs/ordinary-app-owned-event-publisher.bend as AppPublisher
import ../../../../src/ecs/owned-event-journal.bend as EventStage
import ../../../../src/ecs/owned-event-key-route.bend as EventRoute
import ../../../../src/ecs/relation-failure-reader.bend as RelationDecl
import ../../../../src/ecs/relation-providers.bend as RelationOps
import ../../../../src/ecs/ordinary-app-relation.bend as AppRelation
import ../../../../src/ecs/machine-handlers.bend as Handlers
import ../../../../src/ecs/relation-commands.bend as Relations
import ../../../../src/ecs/relation-types.bend as Graph
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/machine.bend as Machine
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/commands.bend as Commands
import ../../../../src/ecs/execution-trace.bend as Trace
import ../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/resource-field-binding.bend as Binding
import ../../../../src/ecs/ordinary-resource-field-system.bend as Field
import ../../../../src/ecs/ordinary-app-resource-field-declaration.bend as Decl
import ../../../../src/ecs/ordinary-app-resource-field.bend as AppField
import ../../../../src/ecs/ordinary-app-resource-field-observation.bend as Leaves
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Records
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-registration-run.bend as Transport
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../src/ecs/ordinary-component-binding.bend as ComponentBinding
import ../../../../src/ecs/ordinary-query-observable.bend as Query
import ../../../../src/ecs/ordinary-app-component.bend as AppComponent
import ../../../../src/ecs/ordinary-system.bend as ComponentSystem
import ../../../../src/ecs/ordinary-app-observation.bend as ComponentLeaves
import ../../../../src/ecs/ordinary-app-execution-run.bend as ExecutionRun
import ../../../../src/ecs/execution-context.bend as Context
import ../../../../src/ecs/trace-facts.bend as Facts
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/inspector.bend as I
import ../../../../src/ecs/inspector-query.bend as IQ
import ./fixture.bend as F

def machine_returned(~S:Data,result:Transport.TransportResult<S,Context.Context<F.World(~S)>,Unit,String,Unit,Records.Token<F.MachineRegistry(~S)>>) -> F.MachineOwner(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:(Leaf.Record{token,fields},outcome)
    case Transport.RegistrationRejected{token,fields,world,_}:(Leaf.Record{token,fields},Sys.Failed{world,"registration-refused"})
def machine_call(~S:Data,owner:F.MachineOwner(~S),world:Context.Context<F.World(~S)>,args:Unit) -> F.MachineOwner(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match owner:
    case Leaf.Record{token,fields}:machine_returned(~S,ExecutionRun.resource_field(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~Decl.machine_ops(~S,~F.Mode,~U32),~Unit,~String,~Unit,~Machine.CurrentView<S,F.Mode,U32>,~F.machine_declaration(~S),~F.machine_body(~S),token,fields,world,args))
def dispatch5_called(~S:Data,owners:F.Owners4(~S),result:F.MachineOwner(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>) -> F.Owners5(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case (owner,outcome):((owners,owner),outcome)
def dispatch5_delegated(~S:Data,owner:F.MachineOwner(~S),result:F.Owners4(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>) -> F.Owners5(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case (owners,outcome):((owners,owner),outcome)

def relation_returned(~S:Data,result:Transport.TransportResult<S,Context.Context<F.World(~S)>,F.RelationArgs<S>,String,Unit,Records.Token<F.RelationRegistry(~S)>>) -> F.RelationOwner(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:(Leaf.Record{token,fields},outcome)
    case Transport.RegistrationRejected{token,fields,world,_}:(Leaf.Record{token,fields},Sys.Failed{world,"registration-refused"})
def relation_call(~S:Data,owner:F.RelationOwner(~S),world:Context.Context<F.World(~S)>,args:F.RelationArgs<S>) -> F.RelationOwner(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match owner:
    case Leaf.Record{token,fields}:relation_returned(~S,ExecutionRun.resource_field(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~Decl.relation_ops(~S),~F.RelationArgs<S>,~String,~Unit,~AppRelation.View<S>,~F.relation_declaration(~S),~F.relation_body(~S),token,fields,world,args))
def dispatch6_called(~S:Data,owners:F.Owners5(~S),result:F.RelationOwner(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>) -> F.Owners6(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case (owner,outcome):((owners,owner),outcome)
def dispatch6_delegated(~S:Data,owner:F.RelationOwner(~S),result:F.Owners5(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>) -> F.Owners6(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case (owners,outcome):((owners,owner),outcome)

def dispatch5(~S:Data,owners:F.Owners5(~S),world:Context.Context<F.World(~S)>,id:U32) -> F.Owners5(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match owners id:
    case (owners,owner) 5:dispatch5_called(~S,owners,machine_call(~S,owner,world,Unit{}))
    case (owners,owner) id:dispatch5_delegated(~S,owner,F.dispatch4(~S,owners,world,id))
def dispatch6(~S:Data,owners:F.Owners6(~S),world:Context.Context<F.World(~S)>,id:U32,args:F.RelationArgs<S>) -> F.Owners6(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match owners id:
    case (owners,owner) 6:dispatch6_called(~S,owners,relation_call(~S,owner,world,args))
    case (owners,owner) id:dispatch6_delegated(~S,owner,dispatch5(~S,owners,world,id))

def retry_join(values:List<Array<U32>>,rest:List<Array<U32>>) -> List<Array<U32>>:
  match values:
    case []:rest
    case value <> values:value <> retry_join(values,rest)
def published(~S:Data,owners:F.Owners6(~S),held:F.Held<S>,owner:F.PublisherOwner(~S),result:Sys.Outcome<Context.Context<F.World(~S)>,Unit,Publisher.Reply<String,Unit,List<Array<U32>>>>) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match held result:
    case F.Held{source,target,incoming,retry,calls,relations,outcomes} Sys.Succeeded{world,Publisher.Reply{outcome,Unit{},returned}}:(((owners,owner),F.Held{source,target,incoming,retry_join(returned,retry),calls,relations,outcome <> outcomes}),Sys.Succeeded{world,Unit{}})
    case held Sys.Failed{world,Unit{}}:(((owners,owner),held),Sys.Failed{world,"publisher-transport-failure"})
def publication_refused(~S:Data,owners:F.Owners6(~S),held:F.Held<S>,owner:F.PublisherOwner(~S),world:Context.Context<F.World(~S)>,payload:Array<U32>) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match held:
    case F.Held{source,target,incoming,retry,calls,relations,outcomes}:(((owners,owner),F.Held{source,target,incoming,payload <> retry,calls,relations,outcomes}),Sys.Failed{world,"publisher-registration-refused"})
def publication_returned(~S:Data,owners:F.Owners6(~S),held:F.Held<S>,result:Transport.TransportResult<S,Context.Context<F.World(~S)>,F.PublishArgs,Unit,Publisher.Reply<String,Unit,List<Array<U32>>>,Records.Token<F.PublisherRegistry(~S)>>) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:published(~S,owners,held,Leaf.Record{token,fields},outcome)
    case Transport.RegistrationRejected{token,fields,world,F.PublishArgs{payload,_}}:publication_refused(~S,owners,held,Leaf.Record{token,fields},world,payload)
def publication_call(~S:Data,owners:F.Owners6(~S),owner:F.PublisherOwner(~S),held:F.Held<S>,world:Context.Context<F.World(~S)>,args:F.PublishArgs) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match owner:
    case Leaf.Record{token,fields}:publication_returned(~S,owners,held,ExecutionRun.publisher(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~List<Array<U32>>,~F.EventOps(~S),~EventWrite.grant(~S,~F.Store(~S),~F.Resources(~S),~Array<U32>,~(F.UserResources(~S) & Unit),~F.Notice(~S),~F.event_path(~S),~F.event_inject(~S),~F.event_domain(~S)),~F.event_declaration(~S),~F.PublishArgs,~String,~Unit,~F.publish_body(~S),token,fields,world,args))
def publication_selected(~S:Data,owners:F.Owners6(~S),owner:F.PublisherOwner(~S),held:F.Held<S>,world:Context.Context<F.World(~S)>) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match held:
    case F.Held{source,target,incoming,payload <> retry,+calls,relations,outcomes}:publication_call(~S,owners,owner,F.Held{source,target,incoming,retry,(calls+1:U32),relations,outcomes},world,F.PublishArgs{payload,U32.is_eq(calls,1)})
    case F.Held{source,target,payload <> incoming,[],+calls,relations,outcomes}:publication_call(~S,owners,owner,F.Held{source,target,incoming,[],(calls+1:U32),relations,outcomes},world,F.PublishArgs{payload,U32.is_eq(calls,1)})
    case held:(((owners,owner),held),Sys.Failed{world,"MissingPublicationInput"})
def routed(~S:Data,owner:F.PublisherOwner(~S),held:F.Held<S>,result:F.Owners6(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match result:
    case (owners,outcome):(((owners,owner),held),outcome)
def relation_args(~S:Data,+source:W.Handle<S>,target:W.Handle<S>,calls:U32) -> F.RelationArgs<S>:
  match calls:
    case 0:F.RelationArgs{source,target,False{}}
    case 1:F.RelationArgs{source,target,True{}}
    case _:F.RelationArgs{source,source,False{}}
def relation_selected(~S:Data,owners:F.Owners6(~S),owner:F.PublisherOwner(~S),held:F.Held<S>,world:Context.Context<F.World(~S)>,id:U32) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match held id:
    case F.Held{+source,+target,incoming,retry,calls,+relations,outcomes} 6:routed(~S,owner,F.Held{source,target,incoming,retry,calls,(relations+1:U32),outcomes},dispatch6(~S,owners,world,6,relation_args(~S,source,target,relations)))
    case F.Held{+source,+target,incoming,retry,calls,relations,outcomes} id:routed(~S,owner,F.Held{source,target,incoming,retry,calls,relations,outcomes},dispatch6(~S,owners,world,id,F.RelationArgs{source,target,False{}}))
def dispatch_logical(~S:Data,owners:F.Owners(~S),world:Context.Context<F.World(~S)>,id:U32) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:
  match owners id:
    case ((owners,publisher),held) 7:publication_selected(~S,owners,publisher,held,world)
    case ((owners,publisher),held) id:relation_selected(~S,owners,publisher,held,world,id)
def dispatch(~S:Data,owners:F.Owners(~S),world:Context.Context<F.World(~S)>,id:U32) -> F.Owners(~S) & Sys.Outcome<Context.Context<F.World(~S)>,String,Unit>:dispatch_logical(~S,owners,world,(id-3:U32))

def run(~S:Data,app:F.Application(~S)) -> Execution.Run<F.Application(~S),S,String>:Execution.run(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~F.Owners(~S),~F.Rows(~S),~F.observe(~S),~F.fold(~S),~String,~dispatch(~S),~F.condition(~S),~F.provision(~S),app)
def enabled(~S:Data,app:F.Application(~S),flag:Bool) -> F.Application(~S):Single.enabled(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~F.Owners(~S),~F.Rows(~S),~F.observe(~S),~F.fold(~S),app,flag)
def snapshot(~S:Data,app:F.Application(~S)) -> F.Application(~S) & Maybe<&2,Single.Description<S,F.Rows(~S)>>:Single.snapshot(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~F.Owners(~S),~F.Rows(~S),~F.observe(~S),~F.fold(~S),app)
