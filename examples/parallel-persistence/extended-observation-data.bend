import Base
import ./observation.bend as Basic
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./declarations.bend as O
import ../parallel-machines/declarations.bend as Modes
import ../parallel-linked-despawn/generalized-observation-data.bend as GraphText
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Chunk
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/entity-key-render.bend as KeyText
import ../../src/ecs/world.bend as W
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-relation-store.bend as Graph
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/execution-machine-stream.bend as Stream
import ../../src/ecs/machine-stream-queue.bend as Queue
import ../../src/ecs/machine.bend as M
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../../src/ecs/lifetime-scope.bend as Scope
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/restore-graph-data.bend as SavedGraph
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/execution-restore-scope-admission.bend as Scopes
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-lifecycle-notices.bend as Notice

def data_retained(-V:Data,show:V -> String,+value:V) -> V & String:(value,show(value))
def consumed(-V:Type,result:V & String) -> String:
  match result:
    case (_,text):text
def array_leaf(-V:Type,result:V & String) -> Array<V> & String:
  match result:
    case (value,text):(ALeaf{value},"[" ++ text ++ "]")
def array_right(-V:Type,left:Array<V>,text:String,result:Array<V> & String) -> Array<V> & String:
  match result:
    case (right,other):(ANode{left,right},"[" ++ text ++ "," ++ other ++ "]")
def array_pair(-V:Type,left:Array<V> & String,right:Array<V> & String) -> Array<V> & String:
  match left:
    case (left,text):array_right(V,left,text,right)
def array_retained(~V:Type,~show:V -> V & String,value:Array<V>) -> Array<V> & String:
  match value:
    case ALeaf{value}:array_leaf(V,show(value))
    case ANode{left,right}:array_pair(V,array_retained(~V,~show,left),array_retained(~V,~show,right))
def u32_array(value:Array<U32>) -> Array<U32> & String:array_retained(~U32,~(value => data_retained(U32,U32.show,value)),value)
def maybe_some(-V:Type,result:V & String) -> Maybe<&1,V> & String:
  match result:
    case (value,text):(Some{value},"some(" ++ text ++ ")")
def maybe_retained(-V:Type,show:V -> V & String,value:Maybe<&1,V>) -> Maybe<&1,V> & String:
  match value:
    case None{}:(None{},"none")
    case Some{value}:maybe_some(V,show(value))
def actor_values(~S:Data,+name:String,result:Array<U32> & String) -> O.Actor<S> & String:
  match result:
    case (values,text):(O.Actor{name,values},"name=" ++ name ++ ":energy=" ++ text)
def actor(~S:Data,value:O.Actor<S>) -> O.Actor<S> & String:
  match value:
    case O.Actor{name,values}:actor_values(~S,name,u32_array(values))
def scratch_values(~S:Data,result:Array<U32> & String) -> O.Scratch<S> & String:
  match result:
    case (values,text):(O.Scratch{values},text)
def scratch(~S:Data,value:O.Scratch<S>) -> O.Scratch<S> & String:
  match value:
    case O.Scratch{values}:scratch_values(~S,u32_array(values))
def viewed_actor_values(~S:Data,+view:O.ActorView,result:O.Actor<S> & String) -> Layout.Viewed<O.Actor<S>,O.ActorView> & String:
  match view result:
    case O.ActorView{name,energy}, (owner,text):(Layout.Viewed{owner,view},text ++ ":cache=" ++ name ++ ":" ++ U32.show(energy))
def viewed_actor(~S:Data,value:Layout.Viewed<O.Actor<S>,O.ActorView>) -> Layout.Viewed<O.Actor<S>,O.ActorView> & String:
  match value:
    case Layout.Viewed{owner,view}:viewed_actor_values(~S,view,actor(~S,owner))
def viewed_scratch_values(~S:Data,view:Unit,result:O.Scratch<S> & String) -> Layout.Viewed<O.Scratch<S>,Unit> & String:
  match result:
    case (owner,text):(Layout.Viewed{owner,view},text ++ ":cache=unit")
def viewed_scratch(~S:Data,value:Layout.Viewed<O.Scratch<S>,Unit>) -> Layout.Viewed<O.Scratch<S>,Unit> & String:
  match value:
    case Layout.Viewed{owner,view}:viewed_scratch_values(~S,view,scratch(~S,owner))
def column_stamps(-S:Data,-V:Type,values:Array<Maybe<&1,V>>,text:String,result:Array<Life.Stamp> & String) -> Chunk.Column<S,V> & String:
  match result:
    case (stamps,other):(Chunk.Leaf{values,stamps},"leaf(values=" ++ text ++ ",stamps=" ++ other ++ ")")
def column_values(-S:Data,-V:Type,stamps:Array<Life.Stamp>,result:Array<Maybe<&1,V>> & String) -> Chunk.Column<S,V> & String:
  match result:
    case (values,text):column_stamps(S,V,values,text,array_retained(~Life.Stamp,~(value => data_retained(Life.Stamp,Basic.stamp,value)),stamps))
def column_right(-S:Data,-V:Type,+half:U32,left:Chunk.Column<S,V>,text:String,result:Chunk.Column<S,V> & String) -> Chunk.Column<S,V> & String:
  match result:
    case (right,other):(Chunk.Branch{half,left,right},"branch(" ++ U32.show(half) ++ "," ++ text ++ "," ++ other ++ ")")
def column_pair(-S:Data,-V:Type,half:U32,left:Chunk.Column<S,V> & String,right:Chunk.Column<S,V> & String) -> Chunk.Column<S,V> & String:
  match left:
    case (left,text):column_right(S,V,half,left,text,right)
def column(~S:Data,~V:Type,~show:V -> V & String,value:Chunk.Column<S,V>) -> Chunk.Column<S,V> & String:
  match value:
    case Chunk.Leaf{values,stamps}:column_values(S,V,stamps,array_retained(~Maybe<&1,V>,~maybe_retained(V,show),values))
    case Chunk.Branch{half,left,right}:column_pair(S,V,half,column(~S,~V,~show,left),column(~S,~V,~show,right))
def scratch_column(~S:Data,actors:Chunk.Column<S,Layout.Viewed<O.Actor<S>,O.ActorView>>,text:String,result:Chunk.Column<S,Layout.Viewed<O.Scratch<S>,Unit>> & String) -> Layout.columns(~S,Schema.components(~S)) & String:
  match result:
    case (scratch,other):(Product.Owner{Layout.ColumnSlot{actors},Layout.ColumnSlot{scratch}},"actor=" ++ text ++ ":scratch=" ++ other)
def actor_column(~S:Data,scratch:Chunk.Column<S,Layout.Viewed<O.Scratch<S>,Unit>>,result:Chunk.Column<S,Layout.Viewed<O.Actor<S>,O.ActorView>> & String) -> Layout.columns(~S,Schema.components(~S)) & String:
  match result:
    case (actors,text):scratch_column(~S,actors,text,column(~S,~Layout.Viewed<O.Scratch<S>,Unit>,~viewed_scratch(~S),scratch))
def columns(~S:Data,value:Layout.columns(~S,Schema.components(~S))) -> Layout.columns(~S,Schema.components(~S)) & String:
  match value:
    case Product.Owner{Layout.ColumnSlot{actors},Layout.ColumnSlot{scratch}}:actor_column(~S,scratch,column(~S,~Layout.Viewed<O.Actor<S>,O.ActorView>,~viewed_actor(~S),actors))
def graph(~S:Data,value:T.Graph<S>) -> String:
  match value:
    case T.Graph{edges,inverses}:"edges=" ++ List.show(&2,T.Edge<S>,GraphText.edge(~S),edges) ++ ":inverses=" ++ List.show(&2,T.Inverse<S>,GraphText.inverse(~S),inverses)
def graph_view(~S:Data,value:Graph.View<S,Schema.hierarchy(~S)>) -> String:
  match value:
    case Graph.View{namespace,value,failures,sequence,nextReader}:"ns=" ++ U32.show(namespace) ++ ":" ++ graph(~S,value) ++ ":failures=" ++ GraphText.channel(~S,~Schema.hierarchy(~S),failures) ++ ":sequence=" ++ Nat.show(sequence) ++ ":nextReader=" ++ U32.show(nextReader)
def graph_owner(~S:Data,value:Graph.Store<S,Schema.hierarchy(~S)>) -> Graph.Store<S,Schema.hierarchy(~S)> & String:
  match value:
    case Graph.Store{+namespace,+value,+failures,+sequence,+nextReader}:(Graph.Store{namespace,value,failures,sequence,nextReader},graph_view(~S,Graph.View{namespace,value,failures,sequence,nextReader}))
def mode(value:Modes.Mode) -> String:
  match value:
    case Modes.Waiting{}:"waiting"
    case Modes.Running{}:"running"
def maybe_mode(value:Maybe<&2,Modes.Mode>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:"some(" ++ mode(value) ++ ")"
def pending(value:M.Pending<Modes.Mode>) -> String:
  match value:
    case M.NoPending{}:"none"
    case M.Queued{value,skip}:"queued(" ++ mode(value) ++ "," ++ Bool.show(skip) ++ ")"
def machine_slot(~S:Data,value:M.Slot<S,Modes.Key,Modes.Mode>) -> String:
  match value:
    case M.Missing{}:"missing"
    case M.Present{value,next,previous,changed}:"current=" ++ mode(value) ++ ":pending=" ++ pending(next) ++ ":previous=" ++ maybe_mode(previous) ++ ":changed=" ++ Bool.show(changed)
def intent(value:Cell.Intent<Modes.Mode>) -> String:
  match value:
    case Cell.Idle{}:"idle"
    case Cell.Initial{value}:"initial(" ++ mode(value) ++ ")"
    case Cell.Transition{from,to,allowed}:"transition(" ++ mode(from) ++ "," ++ mode(to) ++ "," ++ Bool.show(allowed) ++ ")"
def transition(value:M.Transition<Modes.Mode>) -> String:
  match value:
    case M.Initial{to}:"initial(" ++ mode(to) ++ ")"
    case M.Transition{from,to}:"transition(" ++ mode(from) ++ "," ++ mode(to) ++ ")"
def machine_batch(value:Queue.Batch<M.Transition<Modes.Mode>>) -> String:
  match value:
    case Queue.Batch{tick,count,values}:Nat.show(tick) ++ "/count=" ++ Nat.show(count) ++ "/" ++ List.show(&2,M.Transition<Modes.Mode>,transition,values)
def machine_stream(value:Stream.Store<Modes.Mode>) -> String:
  match value:
    case Stream.Store{Queue.Queue{front,back,size,dropped,batches},older,at}:"front=" ++ List.show(&2,Queue.Batch<M.Transition<Modes.Mode>>,machine_batch,front) ++ ":back=" ++ List.show(&2,Queue.Batch<M.Transition<Modes.Mode>>,machine_batch,back) ++ ":size=" ++ Nat.show(size) ++ ":dropped=" ++ Nat.show(dropped) ++ ":batches=" ++ Nat.show(batches) ++ ":older=" ++ Nat.show(older) ++ ":maintained=" ++ Basic.maybe_tick(at)
def current(~S:Data,value:M.CurrentView<S,Modes.Key,Modes.Mode>) -> String:
  match value:
    case M.Unavailable{}:"unavailable"
    case M.Current{value}:mode(value)
def next(~S:Data,value:M.NextView<S,Modes.Key,Modes.Mode>) -> String:
  match value:
    case M.NoNext{}:"none"
    case M.Next{value}:mode(value)
def cell_view(~S:Data,value:Cell.View<S,Modes.Key,Modes.Mode>) -> String:
  match value:
    case Cell.View{value,nextValue,revision,stamp,nextStamp,what}:"current=" ++ current(~S,value) ++ ":next=" ++ next(~S,nextValue) ++ ":revision=" ++ Nat.show(revision) ++ ":stamp=" ++ Basic.maybe_tick(stamp) ++ ":nextStamp=" ++ Basic.maybe_tick(nextStamp) ++ ":intent=" ++ intent(what)
def cell(~S:Data,value:Cell.Cell<S,Modes.Key,Modes.Mode>) -> Cell.Cell<S,Modes.Key,Modes.Mode> & String:
  match value:
    case Cell.Cell{+slot,+stream,+revision,+stamp,+nextStamp,+sequence,+initialPending,+namespace,+what}:(Cell.Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,what},"slot=" ++ machine_slot(~S,slot) ++ ":stream=" ++ machine_stream(stream) ++ ":revision=" ++ Nat.show(revision) ++ ":stamp=" ++ Basic.maybe_tick(stamp) ++ ":nextStamp=" ++ Basic.maybe_tick(nextStamp) ++ ":sequence=" ++ Nat.show(sequence) ++ ":initialPending=" ++ Bool.show(initialPending) ++ ":namespace=" ++ Basic.maybe_u32(namespace) ++ ":intent=" ++ intent(what))
def member(value:Scope.Member) -> String:
  match value:
    case Scope.Member{name,key}:name ++ ":" ++ KeyText.show(key)
def scope_view(~S:Data,value:ScopeStore.View<S>) -> String:
  match value:
    case ScopeStore.View{namespace,members}:"ns=" ++ U32.show(namespace) ++ ":members=" ++ List.show(&2,Scope.Member,member,members)
def scope(~S:Data,value:ScopeStore.Store<S>) -> ScopeStore.Store<S> & String:
  match value:
    case ScopeStore.Store{+namespace,+members}:(ScopeStore.Store{namespace,members},scope_view(~S,ScopeStore.View{namespace,members}))
def graph_slot_values(~S:Data,+view:Graph.View<S,Schema.hierarchy(~S)>,+stamp:Life.Stamp,result:Graph.Store<S,Schema.hierarchy(~S)> & String) -> Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}})) & String:
  match result:
    case (owner,text):(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},"graph={" ++ text ++ ":cache={" ++ graph_view(~S,view) ++ "}:stamp=" ++ Basic.stamp(stamp) ++ "}")
def graph_slot(~S:Data,value:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}}))) -> Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}})) & String:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,view},stamp}:graph_slot_values(~S,view,stamp,graph_owner(~S,owner))
def cell_slot_values(~S:Data,+view:Cell.View<S,Modes.Key,Modes.Mode>,+stamp:Life.Stamp,result:Cell.Cell<S,Modes.Key,Modes.Mode> & String) -> Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}})) & String:
  match result:
    case (owner,text):(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},"machine={" ++ text ++ ":cache={" ++ cell_view(~S,view) ++ "}:stamp=" ++ Basic.stamp(stamp) ++ "}")
def cell_slot(~S:Data,value:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}}))) -> Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}})) & String:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,view},stamp}:cell_slot_values(~S,view,stamp,cell(~S,owner))
def scope_slot_values(~S:Data,+view:ScopeStore.View<S>,+stamp:Life.Stamp,result:ScopeStore.Store<S> & String) -> Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}})) & String:
  match result:
    case (owner,text):(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},"scopes={" ++ text ++ ":cache={" ++ scope_view(~S,view) ++ "}:stamp=" ++ Basic.stamp(stamp) ++ "}")
def scope_slot(~S:Data,value:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}}))) -> Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}})) & String:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,view},stamp}:scope_slot_values(~S,view,stamp,scope(~S,owner))
def pair_right(-L:Type,-R:Type,left:L,text:String,result:R & String) -> Product.Owner<L,R> & String:
  match result:
    case (right,other):(Product.Owner{left,right},text ++ ":" ++ other)
def pair_left(-L:Type,-R:Type,show:R -> R & String,right:R,result:L & String) -> Product.Owner<L,R> & String:
  match result:
    case (left,text):pair_right(L,R,left,text,show(right))
def pair(-L:Type,-R:Type,leftShow:L -> L & String,rightShow:R -> R & String,value:Product.Owner<L,R>) -> Product.Owner<L,R> & String:
  match value:
    case Product.Owner{left,right}:pair_left(L,R,rightShow,right,leftShow(left))
def resources(~S:Data,value:Schema.Resources(~S)) -> Schema.Resources(~S) & String:
  pair(Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}})),Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.AtLeaf{}})),graph_slot(~S),pair(Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}})),Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}})),cell_slot(~S),scope_slot(~S)),value)
def allocator_slots(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,result:Array<Allocator.Slot> & String) -> Allocator.Allocator & String:
  match result:
    case (slots,text):(Allocator.Allocator{next,high,slots,capacity,depth,free,order},"next=" ++ U32.show(next) ++ ":high=" ++ U32.show(high) ++ ":capacity=" ++ U32.show(capacity) ++ ":depth=" ++ Nat.show(depth) ++ ":slots=" ++ text ++ ":free=" ++ List.show(&2,U32,U32.show,free) ++ ":order=" ++ List.show(&2,Key.Key,KeyText.show,order))
def allocator(value:Allocator.Allocator) -> Allocator.Allocator & String:
  match value:
    case Allocator.Allocator{next,high,slots,capacity,depth,free,order}:allocator_slots(next,high,capacity,depth,free,order,array_retained(~Allocator.Slot,~(value => data_retained(Allocator.Slot,Basic.slot,value)),slots))
def schema_retained(~S:Data,value:Admission.Recipes(~S)) -> Admission.Recipes(~S) & String:
  match value:
    case Plan.Schema{Product.Owner{Decl.Constructed{+codec},Decl.Transient{}},Product.Owner{Decl.Transient{},Product.Owner{Decl.Transient{},Decl.Transient{}}}}:(Plan.Schema{Product.Owner{Decl.Constructed{codec},Decl.Transient{}},Product.Owner{Decl.Transient{},Product.Owner{Decl.Transient{},Decl.Transient{}}}},"actor=" ++ Basic.codec(codec) ++ ":scratch=transient/graph=transient:machine=transient:scopes=transient")
def schema(~S:Data,value:Admission.Recipes(~S)) -> String:
  consumed(Admission.Recipes(~S),schema_retained(~S,value))
def group(value:SavedGraph.Group) -> String:
  match value:
    case SavedGraph.Group{target,sources}:KeyText.show(target) ++ "<-" ++ List.show(&2,Key.Key,KeyText.show,sources)
def relation(value:SavedGraph.Relation) -> String:
  match value:
    case SavedGraph.Relation{name,groups}:name ++ List.show(&2,SavedGraph.Group,group,groups)
def saved_current(value:Maybe<&2,D.Raw>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:"some(" ++ Basic.raw(value) ++ ")"
def saved_machine(value:Extended.Machine) -> String:
  match value:
    case Extended.Machine{name,current,revision,stamp}:name ++ ":current=" ++ saved_current(current) ++ ":revision=" ++ Nat.show(revision) ++ ":stamp=" ++ Basic.maybe_tick(stamp)
def snapshot(~S:Data,value:Extended.Snapshot<S>) -> String:
  match value:
    case Extended.Snapshot{basic,relations,machines,scopes}:Basic.snapshot(~S,basic) ++ "/relations=" ++ List.show(&2,SavedGraph.Relation,relation,relations) ++ "/machines=" ++ List.show(&2,Extended.Machine,saved_machine,machines) ++ "/scopes=" ++ List.show(&2,Scope.Member,member,scopes)
def list_tail(-V:Type,head:V,text:String,result:List<V> & String) -> List<V> & String:
  match result:
    case (rest,other):(head <> rest,text ++ ";" ++ other)
def list_pair(-V:Type,head:V & String,rest:List<V> & String) -> List<V> & String:
  match head:
    case (head,text):list_tail(V,head,text,rest)
def list_retained(~V:Type,~show:V -> V & String,value:List<V>) -> List<V> & String:
  match value:
    case []:([],"[]")
    case head <> rest:list_pair(V,show(head),list_retained(~V,~show,rest))
def deferred(~S:Data,value:Deferred.Command<Schema.World(~S)>) -> Deferred.Command<Schema.World(~S)> & String:
  match value:
    case Deferred.Raw{callback}:(Deferred.Raw{callback},"raw(callback-opaque)")
    case Deferred.Observed{callback}:(Deferred.Observed{callback},"observed(callback-opaque)")
type WorldRemainder<-S:Data> is Type:WorldRemainder{namespace:U32,allocator:Allocator.Allocator,resources:Schema.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Schema.World(~S)>>,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
def world_columns_finished(~S:Data,rest:WorldRemainder<S>,text:String,result:Layout.columns(~S,Schema.components(~S)) & String) -> Schema.World(~S) & String:
  match rest result:
    case WorldRemainder{namespace,allocator,resources,events,pending,registrations,nextSystem,clock,lifecycle}, (columns,other):(W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},text ++ "/columns=" ++ other)
def world_columns(~S:Data,result:Schema.World(~S) & String) -> Schema.World(~S) & String:
  match result:
    case (W.World{namespace,allocator,store,resources,events,pending,registrations,nextSystem,clock,lifecycle},text):world_columns_finished(~S,WorldRemainder{namespace,allocator,resources,events,pending,registrations,nextSystem,clock,lifecycle},text,columns(~S,store))
type AllocatorRemainder<-S:Data> is Type:AllocatorRemainder{namespace:U32,columns:Layout.columns(~S,Schema.components(~S)),resources:Schema.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Schema.World(~S)>>,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
def world_allocator_finished(~S:Data,rest:AllocatorRemainder<S>,text:String,result:Allocator.Allocator & String) -> Schema.World(~S) & String:
  match rest result:
    case AllocatorRemainder{namespace,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle}, (allocator,other):(W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},text ++ "/allocator=" ++ other)
def world_allocator(~S:Data,result:Schema.World(~S) & String) -> Schema.World(~S) & String:
  match result:
    case (W.World{namespace,value,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},text):world_allocator_finished(~S,AllocatorRemainder{namespace,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},text,allocator(value))
type PendingRemainder<-S:Data> is Type:PendingRemainder{namespace:U32,allocator:Allocator.Allocator,columns:Layout.columns(~S,Schema.components(~S)),resources:Schema.Resources(~S),events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
def journal_retained(~S:Data,value:Notice.Journal<S>) -> Notice.Journal<S> & String:
  match value:
    case Notice.Journal{+namespace,+channels,+nextReader,+entries}:(Notice.Journal{namespace,channels,nextReader,entries},Basic.journal(~S,Notice.Journal{namespace,channels,nextReader,entries}))
type JournalRemainder<-S:Data> is Type:JournalRemainder{namespace:U32,allocator:Allocator.Allocator,columns:Layout.columns(~S,Schema.components(~S)),resources:Schema.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Schema.World(~S)>>,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,clock:Clock.State}
def world_journal_finished(~S:Data,rest:JournalRemainder<S>,text:String,pendingText:String,result:Notice.Journal<S> & String) -> Schema.World(~S) & String:
  match rest result:
    case JournalRemainder{+namespace,allocator,columns,resources,+events,pending,+registrations,+nextSystem,+clock}, (lifecycle,other):(W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},"ns=" ++ U32.show(namespace) ++ "/resources=" ++ text ++ "/events=" ++ List.show(&2,Unit,(_ => "unit"),events) ++ "/pending=" ++ pendingText ++ "/registrations=" ++ List.show(&2,W.RegistrationMeta,Basic.registration,registrations) ++ "/nextSystem=" ++ U32.show(nextSystem) ++ "/clock=" ++ Basic.clock(clock) ++ "/lifecycle=" ++ other)
def world_pending_finished(~S:Data,rest:PendingRemainder<S>,text:String,result:List<Deferred.Command<Schema.World(~S)>> & String) -> Schema.World(~S) & String:
  match rest result:
    case PendingRemainder{namespace,allocator,columns,resources,events,registrations,nextSystem,clock,lifecycle}, (pending,other):world_journal_finished(~S,JournalRemainder{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock},text,other,journal_retained(~S,lifecycle))
def world_pending(~S:Data,result:Schema.World(~S) & String) -> Schema.World(~S) & String:
  match result:
    case (W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},text):world_pending_finished(~S,PendingRemainder{namespace,allocator,columns,resources,events,registrations,nextSystem,clock,lifecycle},text,list_retained(~Deferred.Command<Schema.World(~S)>,~deferred(~S),pending))
def world_retained(~S:Data,value:Schema.World(~S)) -> Schema.World(~S) & String:
  world_pending(~S,world_allocator(~S,world_columns(~S,W.observe_resource(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~String,~resources(~S),value))))
def world(~S:Data,value:Schema.World(~S)) -> String:consumed(Schema.World(~S),world_retained(~S,value))
def graph_error(value:SavedGraph.Error) -> String:
  match value:
    case SavedGraph.UnknownRelation{name}:"unknown-relation(" ++ name ++ ")"
    case SavedGraph.InvalidRelation{name,source,target}:"invalid-relation(" ++ name ++ "," ++ KeyText.show(source) ++ "," ++ KeyText.show(target) ++ ")"
    case SavedGraph.UnknownMachine{name}:"unknown-machine(" ++ name ++ ")"
    case SavedGraph.InvalidMachineState{name,value}:"invalid-machine(" ++ name ++ "," ++ Basic.raw(value) ++ ")"
def reason(value:Admission.Reason) -> String:
  match value:
    case Admission.BasicRefused{error}:"basic(" ++ Basic.admission_error(error) ++ ")"
    case Admission.GraphRefused{error}:"graph(" ++ graph_error(error) ++ ")"
    case Admission.ScopeRefused{Scopes.MissingEntity{key}}:"missing-scope(" ++ KeyText.show(key) ++ ")"
    case Admission.ScopeRefused{Scopes.DuplicateEntity{key}}:"duplicate-scope(" ++ KeyText.show(key) ++ ")"
    case Admission.MachineShape{}:"machine-shape"
    case Admission.MachineCodec{}:"machine-codec"
    case Admission.MachineStamp{}:"machine-stamp"
