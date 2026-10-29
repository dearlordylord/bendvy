import Base
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/world.bend as W
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/lifetime-scope.bend as Scope
import ../../src/ecs/execution-relation-operation.bend as Operation
import ../../src/ecs/execution-relation-store.bend as Store
import ../parallel-relations/failure-message-text.bend as FailureText
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/machine-stream-queue.bend as Queue
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-resource-recipe.bend as ResourceRecipe
import ../../src/ecs/execution-parallel-registration.bend as Registration
import ../../src/ecs/execution-query-domain.bend as Domain
import ../../src/ecs/execution-query-schema.bend as Schema
import ../../src/ecs/execution-resource-description.bend as Description
import ../../src/ecs/execution-query-admission.bend as Query
import ../../src/ecs/execution-reservation-bundle.bend as Bundle

def identity(value:String) -> String:value
def strings(values:List<&2,String>) -> String:List.show(&2,String,identity,values)
def ids(values:List<&2,U32>) -> String:List.show(&2,U32,U32.show,values)
def bool(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,value}:U32.show(namespace) ++ "/" ++ key(value)
def route(value:L.Route) -> String:
  match value:
    case L.AtLeaf{}:"@"
    case L.InLeft{rest}:"L" ++ route(rest)
    case L.InRight{rest}:"R" ++ route(rest)
def member(value:Scope.Member) -> String:
  match value:
    case Scope.Member{name,id}:name ++ "/" ++ key(id)
def reason(value:Store.Reason) -> String:
  match value:
    case Store.NamespaceMismatch{}:"namespace-mismatch"
    case Store.OperationRefused{Operation.HierarchyRequired{}}:"hierarchy-required"
    case Store.OperationRefused{Operation.RelationError{error}}:FailureText.error(error)
def relation_receipt(~S:Data,value:Store.Receipt<S>) -> String:
  match value:
    case Store.Applied{operation}:"applied:" ++ FailureText.operation(S,operation)
    case Store.Refused{operation,why}:"refused:" ++ FailureText.operation(S,operation) ++ "/" ++ reason(why)
def batch(~S:Data,~family:T.Descriptor<S>,value:Queue.Batch<Message.Message<S,family>>) -> String:
  match value:
    case Queue.Batch{tick,count,values}:Nat.show(tick) ++ "/count=" ++ Nat.show(count) ++ "/" ++ List.show(&2,Message.Message<S,family>,value => FailureText.message(S,family,value),values)
def descriptor(~S:Data,value:T.Descriptor<S>) -> String:
  match value:
    case T.Descriptor{id,name,inverse,T.Ordinary{}}:U32.show(id) ++ "/" ++ name ++ "/" ++ inverse ++ "/ordinary"
    case T.Descriptor{id,name,inverse,T.Hierarchy{}}:U32.show(id) ++ "/" ++ name ++ "/" ++ inverse ++ "/hierarchy"
def edge(~S:Data,value:T.Edge<S>) -> String:
  match value:
    case T.Edge{family,source,target}:descriptor(~S,family) ++ ":" ++ key(source) ++ "->" ++ key(target)
def inverse(~S:Data,value:T.Inverse<S>) -> String:
  match value:
    case T.Inverse{family,target,sources}:descriptor(~S,family) ++ ":" ++ key(target) ++ "<-" ++ List.show(&2,Key.Key,key,sources)
def frame(~S:Data,value:T.CleanupFrame<S>) -> String:
  match value:
    case T.CleanupEnter{id}:"enter:" ++ key(id)
    case T.CleanupFinish{id}:"finish:" ++ key(id)
    case T.CleanupDescriptors{id,remaining}:"descriptors:" ++ key(id) ++ "/" ++ List.show(&2,T.Descriptor<S>,descriptor(~S),remaining)
    case T.CleanupChildren{id,family,remaining,children}:"children:" ++ key(id) ++ "/" ++ descriptor(~S,family) ++ "/" ++ List.show(&2,T.Descriptor<S>,descriptor(~S),remaining) ++ "/" ++ List.show(&2,Key.Key,key,children)
def frames(~S:Data,values:List<&2,T.CleanupFrame<S>>) -> String:List.show(&2,T.CleanupFrame<S>,frame(~S),values)
def tick(value:Tick.Tick) -> String:
  match value:
    case Tick.Tick{epoch,low}:Nat.show(epoch) ++ ":" ++ U32.show(low)
def maybe_tick(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:tick(value)
def channel(~S:Data,~family:T.Descriptor<S>,value:Channel.Store<Message.Message<S,family>>) -> String:
  match value:
    case Channel.Store{Queue.Queue{front,back,size,dropped,batches},older,at}:"front=" ++ List.show(&2,Queue.Batch<Message.Message<S,family>>,batch(~S,~family),front) ++ ",back=" ++ List.show(&2,Queue.Batch<Message.Message<S,family>>,batch(~S,~family),back) ++ ",size=" ++ Nat.show(size) ++ ",dropped=" ++ Nat.show(dropped) ++ ",batches=" ++ Nat.show(batches) ++ ",older=" ++ Nat.show(older) ++ ",maintained=" ++ maybe_tick(at)
def stamp(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{added,changed}:"added=" ++ maybe_tick(added) ++ ",changed=" ++ maybe_tick(changed)
def stamps(values:Array<Life.Stamp>) -> String:
  match values:
    case ALeaf{value}:stamp(value)
    case ANode{left,right}:"[" ++ stamps(left) ++ "," ++ stamps(right) ++ "]"
def phase(value:Allocator.Phase) -> String:
  match value:
    case Allocator.Consumed{}:"consumed"
    case Allocator.Pending{}:"pending"
    case Allocator.Live{}:"live"
    case Allocator.DeadRetained{}:"dead-retained"
    case Allocator.Free{}:"free"
def slots_join(left:Array<Allocator.Slot> & String,right:Array<Allocator.Slot> & String) -> Array<Allocator.Slot> & String:
  match left right:
    case (left,a), (right,b):(ANode{left,right},"[" ++ a ++ "," ++ b ++ "]")
def slots(values:Array<Allocator.Slot>) -> Array<Allocator.Slot> & String:
  match values:
    case ALeaf{Allocator.Slot{+generation,+state}}:(ALeaf{Allocator.Slot{generation,state}},U32.show(generation) ++ "/" ++ phase(state))
    case ANode{left,right}:slots_join(slots(left),slots(right))
def allocator_returned(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,result:Array<Allocator.Slot> & String) -> Allocator.Allocator & String:
  match result:
    case (slots,text):(Allocator.Allocator{next,high,slots,capacity,depth,free,order},"next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",slots=" ++ text ++ ",free=" ++ ids(free) ++ ",order=" ++ List.show(&2,Key.Key,key,order))
def allocator(value:Allocator.Allocator) -> Allocator.Allocator & String:
  match value:
    case Allocator.Allocator{next,high,values,capacity,depth,free,order}:allocator_returned(next,high,capacity,depth,free,order,slots(values))
def row(~S:Data,value:Notice.Row<S>) -> String:
  match value:
    case Notice.Row{sequence,Notice.Identity{namespace,id},at}:Nat.show(sequence) ++ "/" ++ U32.show(namespace) ++ "/" ++ key(id) ++ "/" ++ tick(at)
def selector(value:Notice.Selector) -> String:
  match value:
    case Notice.Removed{key}:"removed:" ++ key
    case Notice.Despawned{}:"despawned"
def notice_channel(~S:Data,value:Notice.Channel<S>) -> String:
  match value:
    case Notice.Channel{selected,next,previous,current,dropped}:selector(selected) ++ "/next=" ++ Nat.show(next) ++ "/previous=" ++ List.show(&2,Notice.Row<S>,row(~S),previous) ++ "/current=" ++ List.show(&2,Notice.Row<S>,row(~S),current) ++ "/dropped=" ++ Nat.show(dropped)
def active(value:Notice.Active) -> String:
  match value:
    case Notice.Active{id,selected}:U32.show(id) ++ "/" ++ selector(selected)
def journal(~S:Data,value:Notice.Journal<S>) -> Notice.Journal<S> & String:
  match value:
    case Notice.Journal{+namespace,+channels,+next,+readers}:(Notice.Journal{namespace,channels,next,readers},"namespace=" ++ U32.show(namespace) ++ ",channels=" ++ List.show(&2,Notice.Channel<S>,notice_channel(~S),channels) ++ ",nextReader=" ++ U32.show(next) ++ ",active=" ++ List.show(&2,Notice.Active,active,readers))
def clock(value:Clock.State) -> String:
  match value:
    case Clock.State{now,scopes}:tick(now) ++ "/scopes=" ++ List.show(&2,Tick.Tick,tick,scopes)
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ "/" ++ name ++ "/" ++ strings(access)
def invalid(value:Plan.Invalid<String>) -> String:
  match value:
    case Plan.Duplicate{id}:"duplicate:" ++ U32.show(id)
    case Plan.UnknownDependency{id}:"unknown:" ++ U32.show(id)
    case Plan.Missing{id,requirement}:"missing:" ++ U32.show(id) ++ "/" ++ requirement
    case Plan.Cycle{}:"cycle"
    case Plan.InvalidCondition{id}:"invalid-condition:" ++ U32.show(id)
def plan_node(value:Plan.Node<String>) -> String:
  match value:
    case Plan.Node{id,requirements}:U32.show(id) ++ "/" ++ strings(requirements)
def plan_edge(value:Plan.Edge) -> String:
  match value:
    case Plan.Edge{before,after}:U32.show(before) ++ "->" ++ U32.show(after)
def plan(value:Plan.Build<String>) -> String:
  match value:
    case Plan.Rejected{reason}:"rejected:" ++ invalid(reason)
    case Plan.Planned{order,edges}:"order=" ++ List.show(&2,Plan.Node<String>,plan_node,order) ++ ",edges=" ++ List.show(&2,Plan.Edge,plan_edge,edges)
def binding(value:App.Binding) -> String:
  match value:
    case App.Binding{system,condition}:U32.show(system) ++ "/" ++ U32.show(condition)
def maybe_id(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"none"
    case Some{id}:U32.show(id)
def explicit(value:Settings.Explicit) -> String:
  match value:
    case Settings.Explicit{before,condition}:U32.show(before) ++ "/" ++ maybe_id(condition)
def deferred(value:Root.Deferred) -> String:
  match value:
    case Root.Deferred{systems,Settings.Settings{automatic,final,ignored,values},unapplied}:"systems=" ++ ids(systems) ++ ",automatic=" ++ bool(automatic) ++ ",final=" ++ bool(final) ++ ",ignored=" ++ List.show(&2,Plan.Edge,plan_edge,ignored) ++ ",explicit=" ++ List.show(&2,Settings.Explicit,explicit,values) ++ ",unapplied=" ++ ids(unapplied)
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,output}:"ran:" ++ U32.show(id) ++ "/" ++ output
    case Exec.BodyFailed{id,error,output}:"body-failed:" ++ U32.show(id) ++ "/" ++ error ++ "/" ++ output
    case Exec.Skipped{id}:"skipped:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"condition-failed:" ++ U32.show(id) ++ "/" ++ error
    case Exec.ConditionRejected{id}:"condition-rejected:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"admission-rejected:" ++ U32.show(id)
def report(value:Context.RunReport<App.Report<String,String>>) -> String:
  match value:
    case Context.ContextRefused{}:"context-refused"
    case Context.RunReported{App.Invalid{reason}}:"invalid:" ++ invalid(reason)
    case Context.RunReported{App.Finished{events}}:"finished:" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case Context.RunReported{App.Stopped{error,events}}:"stopped:" ++ error ++ "/" ++ List.show(&2,Exec.Observation<String,String>,event,events)
def mode(value:D.Mode) -> String:
  match value:
    case D.Exclusive{}:"exclusive"
    case D.SharedView{}:"shared-view"
def access_kind(value:D.AccessKind) -> String:
  match value:
    case D.ComponentAccess{}:"component"
    case D.ResourceAccess{}:"resource"
    case D.ServiceAccess{}:"service"
    case D.LifecycleAccess{}:"lifecycle"
def access_permission(value:D.Permission) -> String:
  match value:
    case D.ReadOnly{}:"read"
    case D.Writable{}:"write"
def access(value:D.Access) -> String:
  match value:
    case D.Access{key,kind,selected,permission}:key ++ "/" ++ access_kind(kind) ++ "/" ++ mode(selected) ++ "/" ++ access_permission(permission)
def bound(value:Recipe.Bound) -> String:
  match value:
    case Recipe.AllLive{}:"all-live"
    case Recipe.With{selected}:"with:" ++ route(selected)
    case Recipe.Without{selected}:"without:" ++ route(selected)
    case Recipe.Changed{selected}:"changed:" ++ route(selected)
    case Recipe.And{left,right}:"and(" ++ bound(left) ++ "," ++ bound(right) ++ ")"
    case Recipe.Or{left,right}:"or(" ++ bound(left) ++ "," ++ bound(right) ++ ")"
def query_kind(value:Recipe.QueryKind) -> String:
  match value:
    case Recipe.ReadRows{}:"read"
    case Recipe.WriteRows{}:"write"
def presence(value:Match.Presence) -> String:
  match value:
    case Match.Optional{}:"optional"
    case Match.Required{}:"required"
    case Match.With{}:"with"
    case Match.Without{}:"without"
def recipe(~S:Data,~C:Type,value:Recipe.Recipe<S,C>) -> String:
  match value:
    case Recipe.Recipe{Recipe.Entry{selected,kind,domain,required}}:route(selected) ++ "/" ++ query_kind(kind) ++ "/" ++ bound(domain) ++ "/" ++ presence(required)
def resource_permission(value:ResourceRecipe.Permission) -> String:
  match value:
    case ResourceRecipe.Unused{}:"unused"
    case ResourceRecipe.ReadOnly{}:"read"
    case ResourceRecipe.Writable{}:"write"
def resource_recipe(value:ResourceRecipe.Entry) -> String:
  match value:
    case ResourceRecipe.Entry{selected,key,permission}:route(selected) ++ "/" ++ key ++ "/" ++ resource_permission(permission)
def recipes(~S:Data,~C:Type,value:D.Recipes<S,C>) -> String:
  match value:
    case D.Recipes{queries,resources}:"queries=" ++ List.show(&2,Recipe.Recipe<S,C>,recipe(~S,~C),queries) ++ ",resources=" ++ List.show(&2,ResourceRecipe.Entry,resource_recipe,resources)
def coordinates(value:Registration.Coordinates) -> String:
  match value:
    case Registration.EmptyCoordinates{}:"empty"
    case Registration.LeafCoordinates{key}:key
    case Registration.PairCoordinates{left,right}:"(" ++ coordinates(left) ++ "," ++ coordinates(right) ++ ")"
def usage(value:Registration.Use) -> String:
  match value:
    case Registration.Use{key,selected}:key ++ "/" ++ mode(selected)
    case Registration.SelectedQuery{key,selected,path,domain,position}:key ++ "/" ++ mode(selected) ++ "/" ++ route(path) ++ "/" ++ bound(domain) ++ "/" ++ coordinates(position)
def rule(value:Registration.Entry) -> String:
  match value:
    case Registration.Entry{id,uses}:U32.show(id) ++ "/" ++ List.show(&2,Registration.Use,usage,uses)
def rules(value:Registration.Rules) -> String:
  match value:
    case Registration.Rules{entries}:List.show(&2,Registration.Entry,rule,entries)
def domain(value:Domain.Domain) -> String:
  match value:
    case Domain.Domain{offsets}:ids(offsets)
def component_info(value:Schema.Info) -> String:
  match value:
    case Schema.Info{selected,capacity,present}:route(selected) ++ "/capacity=" ++ U32.show(capacity) ++ "/present=" ++ domain(present)
def resource_info(value:Description.Info) -> String:
  match value:
    case Description.Info{selected,key,at}:route(selected) ++ "/" ++ key ++ "/" ++ stamp(at)
def query_entry(value:Recipe.Entry) -> String:
  match value:
    case Recipe.Entry{selected,kind,selectedBound,required}:route(selected) ++ "/" ++ query_kind(kind) ++ "/" ++ bound(selectedBound) ++ "/" ++ presence(required)
def granted(~S:Data,~C:Type,value:Query.Granted<S,C>) -> String:
  match value:
    case Query.Granted{entry,handles}:query_entry(entry) ++ "/handles=" ++ List.show(&2,W.Handle<S>,handle(~S),handles)
def match_recipe(value:Match.Recipe) -> String:
  match value:
    case Match.Read{selected}:"read:" ++ domain(selected)
    case Match.Write{selected}:"write:" ++ domain(selected)
    case Match.Both{left,right}:"both(" ++ match_recipe(left) ++ "," ++ match_recipe(right) ++ ")"
def schema_entry(value:Schema.Entry) -> String:
  match value:
    case Schema.Entry{selected,recipe}:route(selected) ++ "/" ++ match_recipe(recipe)
def query_book(~S:Data,~full:L.Layout,value:Schema.Book<S,full>) -> String:
  match value:
    case Schema.Book{entries}:List.show(&2,Schema.Entry,schema_entry,entries)
def resource_book(~S:Data,~full:L.Layout,value:ResourceRecipe.Book<S,full>) -> String:
  match value:
    case ResourceRecipe.Book{entries}:List.show(&2,ResourceRecipe.Entry,resource_recipe,entries)
def world_error(value:W.WorldError) -> String:
  match value:
    case W.ReservationUnauthorized{}:"reservation-unauthorized"
    case W.MissingEntity{}:"missing-entity"
    case W.CapacityExceeded{}:"capacity-exceeded"
    case W.NamespaceExhausted{}:"namespace-exhausted"
    case W.SystemIdExhausted{}:"system-id-exhausted"
def bundle_refusal(value:Bundle.Refusal) -> String:
  match value:
    case Bundle.InvalidPending{error}:"invalid-pending:" ++ world_error(error)
    case Bundle.PermissionDenied{}:"permission-denied"
    case Bundle.DuplicateFamily{}:"duplicate-family"
    case Bundle.PhysicalIndex{}:"physical-index"
    case Bundle.MalformedColumn{key}:"malformed-column:" ++ key
    case Bundle.OccupiedFamily{key}:"occupied-family:" ++ key
