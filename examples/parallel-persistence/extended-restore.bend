import Base
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./extended-target.bend as Target
import ./declarations.bend as O
import ./constructors.bend as Factory
import ./staging.bend as Stage
import ./publication.bend as Rows
import ./restore.bend as Old
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/execution-restore-stage.bend as StageWalk
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/lifecycle.bend as Life
import ../parallel-machines/declarations.bend as Modes
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-save-data.bend as Basic
import ../../src/ecs/execution-save-metadata.bend as Metadata
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-restore-receiver.bend as Receiver
import ../../src/ecs/execution-restore-clear.bend as Clear
import ../../src/ecs/execution-restore-publication.bend as Publication
import ../../src/ecs/execution-relation-restore.bend as GraphRestore
import ../../src/ecs/execution-relation-store.bend as GraphStore
import ../../src/ecs/restore-graph-mapping.bend as Mapping
import ../../src/ecs/execution-machine-restore.bend as MachineRestore
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/restore-leaf.bend as Leaf
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/decode-data.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/restore-world.bend as Progress
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-lifetime-scope-restore.bend as ScopeRestore
import ../../src/ecs/execution-restore-scope-admission.bend as ScopeMap
import ../../src/ecs/lifetime-scope.bend as Scope

type Previous<-S:Data> is Data:Previous{graph:T.Graph<S>,scopes:List<&2,Scope.Member>}

type State<-S:Data> is Type:State{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,graph:T.Graph<S>,machine:MachineRestore.Commit<Modes.Mode>,actors:Stage.Actors(~S)}
type Outcome<-S:Data> is Type:
  InputRefused{world:Schema.World(~S),schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,reason:Admission.Reason}
  NamespaceRefused{state:State<S>,world:Schema.World(~S)}
  ReceiverRefused{state:State<S>,result:Receiver.Prepared<S,Schema.components(~S),Schema.Resources(~S),Unit>}
  StagingRefused{state:State<S>,world:Schema.World(~S),error:R.Error<Unit>}
  RowsRefused{state:State<S>,world:Schema.World(~S),rows:List<Publication.Row<Schema.components(~S)>>}
  ClearPartial{state:State<S>,rows:List<Publication.Row<Schema.components(~S)>>,result:Clear.Cleared<S,Schema.components(~S),Layout.InLeft{Layout.AtLeaf{}},Schema.Resources(~S),Unit>}
  Published{state:State<S>,removed:List<Old.Receipt(~S)>,result:Publication.Published<S,Schema.components(~S),Schema.Resources(~S),Unit>}
  MappingRefused{state:State<S>,removed:List<Old.Receipt(~S)>,result:Publication.Published<S,Schema.components(~S),Schema.Resources(~S),Unit>,saved:Key.Key}
  Restored{state:State<S>,world:Schema.World(~S),removed:List<Old.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,previous:Previous<S>}
  ResourcePartial{state:State<S>,world:Schema.World(~S),removed:List<Old.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>}
def stage(~S:Data,actors:Stage.Actors(~S),position:R.Position,field:D.Field) -> Stage.Actors(~S) & R.Dispatch<Unit>:
  match field:
    case D.Field{"actor",raw}:Stage.actor(~S,actors,position,raw)
    case _:(actors,R.Unhandled{})
def release(~S:Data,actors:Stage.Actors(~S)) -> Stage.Actors(~S):Leaf.release(~Factory.ActorFactory(~S),~D.Raw,~O.Actor<S>,actors)
def basic(~S:Data,input:Extended.Snapshot<S>) -> Basic.Snapshot<S>:
  match input:
    case Extended.Snapshot{basic,_,_,_}:basic
def floor(~S:Data,input:Extended.Snapshot<S>) -> U32:
  match input:
    case Extended.Snapshot{Basic.Snapshot{_,Metadata.Metadata{_,Metadata.Allocator{next,_,_,_,_,_,_},_,_},_,_},_,_,_}:next
def count(~S:Data,input:Extended.Snapshot<S>) -> Nat:
  match input:
    case Extended.Snapshot{Basic.Snapshot{_,_,entities,_},_,_,_}:List.length(&2,Basic.Entity,entities)
def entity_values(~S:Data,input:Extended.Snapshot<S>) -> List<&2,Basic.Entity>:
  match input:
    case Extended.Snapshot{Basic.Snapshot{_,_,entities,_},_,_,_}:entities
def scope_values(~S:Data,input:Extended.Snapshot<S>) -> List<&2,Scope.Member>:
  match input:
    case Extended.Snapshot{_,_,_,members}:members
# Publication failures retain their actual World and typed owner receipts.
# Only successful fresh mapping reaches graph/Cell installation below.
def GraphSlot(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}}))
def MachineSlot(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}}))
def ScopeSlot(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}}))
def cell_projected(~S:Data,stamp:Life.Stamp,result:Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>) -> MachineSlot(~S):
  match result:
    case (cell,view):Layout.ResourceSlot{Layout.Viewed{cell,view},stamp}
def cell_installed(~S:Data,commit:MachineRestore.Commit<Modes.Mode>,tick:Tick.Tick,slot:MachineSlot(~S)) -> MachineSlot(~S):
  match slot:
    case Layout.ResourceSlot{Layout.Viewed{cell,_},stamp}:cell_projected(~S,Life.after_write(True{},True{},stamp,tick),Cell.projected(S,Modes.Key,Modes.Mode,MachineRestore.install(S,Modes.Key,Modes.Mode,cell,commit)))
def scope_installed(~S:Data,graph:GraphSlot(~S),cell:MachineSlot(~S),previous:T.Graph<S>,result:ScopeRestore.Publication<S,"restore-scopes",Layout.origin(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}}),Unit>) -> Schema.Resources(~S) & Maybe<&2,Previous<S>>:
  match result:
    case ScopeRestore.Installed{scope,_,old}:(Product.Owner{graph,Product.Owner{cell,scope}},Some{Previous{previous,old}})
    case ScopeRestore.Rejected{scope,_}:(Product.Owner{graph,Product.Owner{cell,scope}},None{})
def graph_installed(~S:Data,members:List<&2,Scope.Member>,commit:MachineRestore.Commit<Modes.Mode>,+tick:Tick.Tick,cell:MachineSlot(~S),scope:ScopeSlot(~S),result:GraphRestore.Publication<S,Schema.hierarchy(~S),"restore-hierarchy",Layout.origin(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}}),Unit>) -> Schema.Resources(~S) & Maybe<&2,Previous<S>>:
  match result:
    case GraphRestore.Installed{slot,_,previous}:scope_installed(~S,slot,cell_installed(~S,commit,tick,cell),previous,ScopeRestore.publish(~S,~"restore-scopes",~Layout.origin(Schema.resource_layout(~S),Layout.InRight{Layout.InRight{Layout.AtLeaf{}}}),~{==},~Unit,scope,tick,ScopeRestore.Ready{members,Unit{}}))
    case GraphRestore.Rejected{slot,_}:(Product.Owner{slot,Product.Owner{cell,scope}},None{})
def install_resources(~S:Data,graph:T.Graph<S>,members:List<&2,Scope.Member>,commit:MachineRestore.Commit<Modes.Mode>,+tick:Tick.Tick,resources:Schema.Resources(~S)) -> Schema.Resources(~S) & Maybe<&2,Previous<S>>:
  match resources:
    case Product.Owner{slot,Product.Owner{cell,scope}}:graph_installed(~S,members,commit,tick,cell,scope,GraphRestore.publish(~S,~Schema.hierarchy(~S),~"restore-hierarchy",~Layout.origin(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}}),~{==},~Unit,slot,tick,GraphRestore.Ready{graph,Unit{}}))
def install(~S:Data,graph:T.Graph<S>,members:List<&2,Scope.Member>,commit:MachineRestore.Commit<Modes.Mode>,tick:Tick.Tick,world:Schema.World(~S)) -> Schema.World(~S) & Maybe<&2,Previous<S>>:
  match world:
    case W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle}:W.observe_resource_finish(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~Maybe<&2,Previous<S>>,install_resources(~S,graph,members,commit,tick,resources),namespace,allocator,columns,events,pending,registrations,nextSystem,clock,lifecycle)
def installed(~S:Data,state:State<S>,removed:List<Old.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,result:Schema.World(~S) & Maybe<&2,Previous<S>>) -> Outcome<S>:
  match result:
    case (world,Some{previous}):Restored{state,world,removed,mapping,publications,previous}
    case (world,None{}):ResourcePartial{state,world,removed,mapping,publications}
def scope_mapped(~S:Data,state:State<S>,removed:List<Old.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,world:Schema.World(~S),graph:T.Graph<S>,tick:Tick.Tick,result:ScopeMap.Mapped) -> Outcome<S>:
  match state result:
    case state ScopeMap.MissingBinding{key}:MappingRefused{state,removed,Publication.Published{world,mapping,publications,True{}},key}
    case State{schema,input,source,+machine,actors} ScopeMap.Mapped{members}:installed(~S,State{schema,input,source,machine,actors},removed,mapping,publications,install(~S,graph,members,machine,tick,world))
def install_state(~S:Data,state:State<S>,removed:List<Old.Receipt(~S)>,+mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,world:Schema.World(~S),graph:T.Graph<S>,tick:Tick.Tick) -> Outcome<S>:
  match state:
    case State{schema,+input,source,machine,actors}:scope_mapped(~S,State{schema,input,source,machine,actors},removed,mapping,publications,world,graph,tick,ScopeMap.remap(~S,scope_values(~S,input),mapping))
def mapped(~S:Data,state:State<S>,removed:List<Old.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,world:Schema.World(~S),tick:Tick.Tick,result:Mapping.Mapped<S>) -> Outcome<S>:
  match result:
    case Mapping.MissingBinding{saved}:MappingRefused{state,removed,Publication.Published{world,mapping,publications,True{}},saved}
    case Mapping.Mapped{graph}:install_state(~S,state,removed,mapping,publications,world,graph,tick)
def published(~S:Data,state:State<S>,removed:List<Old.Receipt(~S)>,tick:Tick.Tick,result:Publication.Published<S,Schema.components(~S),Schema.Resources(~S),Unit>) -> Outcome<S>:
  match state result:
    case state, Publication.Published{world,mapping,receipts,False{}}:Published{state,removed,Publication.Published{world,mapping,receipts,False{}}}
    case State{schema,input,+graph,machine,actors}, Publication.Published{world,+mapping,receipts,True{}}:mapped(~S,State{schema,input,graph,machine,actors},removed,mapping,receipts,world,tick,Mapping.remap(~S,graph,mapping))
def cleared(~S:Data,state:State<S>,rows:List<Publication.Row<Schema.components(~S)>>,+tick:Tick.Tick,result:Clear.Cleared<S,Schema.components(~S),Layout.InLeft{Layout.AtLeaf{}},Schema.Resources(~S),Unit>) -> Outcome<S>:
  match result:
    case Clear.Interrupted{world,receipts,remaining}:ClearPartial{state,rows,Clear.Interrupted{world,receipts,remaining}}
    case Clear.Cleared{world,receipts}:published(~S,state,receipts,tick,Publication.publish(~S,~Schema.components(~S),~Schema.Resources(~S),~Unit,rows,world,tick))
def clocked(~S:Data,state:State<S>,rows:List<Publication.Row<Schema.components(~S)>>,handles:List<&2,W.Handle<S>>,result:Schema.World(~S) & Tick.Tick) -> Outcome<S>:
  match result:
    case (world,+tick):cleared(~S,state,rows,tick,Clear.clear(~S,~Schema.components(~S),~Layout.InLeft{Layout.AtLeaf{}},~Schema.Resources(~S),~Unit,handles,world,tick))
def saved_clock(~S:Data,input:Extended.Snapshot<S>) -> Tick.Tick:
  match input:
    case Extended.Snapshot{Basic.Snapshot{_,Metadata.Metadata{_,_,clock,_},_,_},_,_,_}:Clock.now(clock)
def floor_clock(~S:Data,world:Schema.World(~S),minimum:Tick.Tick) -> Schema.World(~S):
  match world:
    case W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle}:W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,Clock.floor(clock,minimum),lifecycle}
def committed_clock(~S:Data,state:State<S>,rows:List<Publication.Row<Schema.components(~S)>>,handles:List<&2,W.Handle<S>>,world:Schema.World(~S)) -> Outcome<S>:
  match state:
    case State{schema,+input,graph,machine,actors}:clocked(~S,State{schema,input,graph,machine,actors},rows,handles,W.write_clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,floor_clock(~S,world,saved_clock(~S,input))))
def advanced(~S:Data,state:State<S>,rows:List<Publication.Row<Schema.components(~S)>>,handles:List<&2,W.Handle<S>>,result:Schema.World(~S) & Bool) -> Outcome<S>:
  match result:
    case (world,False{}):RowsRefused{state,world,rows}
    case (world,True{}):committed_clock(~S,state,rows,handles,world)
def rows_ready(~S:Data,schema:Admission.Recipes(~S),+input:Extended.Snapshot<S>,graph:T.Graph<S>,machine:MachineRestore.Commit<Modes.Mode>,world:Schema.World(~S),handles:List<&2,W.Handle<S>>,result:Rows.Rows<S>) -> Outcome<S>:
  match result:
    case Rows.Rows{actors,rows,False{}}:RowsRefused{State{schema,input,graph,machine,actors},world,rows}
    case Rows.Rows{actors,rows,True{}}:advanced(~S,State{schema,input,graph,machine,actors},rows,handles,Progress.advance_floor(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world,floor(~S,input)))
def staged(~S:Data,schema:Admission.Recipes(~S),+input:Extended.Snapshot<S>,graph:T.Graph<S>,machine:MachineRestore.Commit<Modes.Mode>,world:Schema.World(~S),handles:List<&2,W.Handle<S>>,result:Stage.Actors(~S) & (Basic.Snapshot<S> & Maybe<&2,R.Error<Unit>>)) -> Outcome<S>:
  match result:
    case (actors,(_,Some{error})):StagingRefused{State{schema,input,graph,machine,actors},world,error}
    case (actors,(_,None{})):rows_ready(~S,schema,input,graph,machine,world,handles,Rows.staged_rows(~S,entity_values(~S,input),actors))
def room(~S:Data,state:State<S>,handles:List<&2,W.Handle<S>>,result:Schema.World(~S) & Bool) -> Outcome<S>:
  match state result:
    case state, (world,False{}):ReceiverRefused{state,Receiver.Refused{world,Receiver.Capacity{}}}
    case State{schema,+input,graph,machine,actors}, (world,True{}):staged(~S,schema,input,graph,machine,world,handles,StageWalk.admitted(~S,~Stage.Actors(~S),~Unit,~stage(~S),~release(~S),actors,basic(~S,input)))
def room_state(~S:Data,state:State<S>,world:Schema.World(~S),handles:List<&2,W.Handle<S>>) -> Outcome<S>:
  match state:
    case State{schema,+input,graph,machine,actors}:room(~S,State{schema,input,graph,machine,actors},handles,Progress.room(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world,floor(~S,input),count(~S,input)))
def receiver(~S:Data,state:State<S>,result:Receiver.Prepared<S,Schema.components(~S),Schema.Resources(~S),Unit>) -> Outcome<S>:
  match result:
    case Receiver.Refused{world,reason}:ReceiverRefused{state,Receiver.Refused{world,reason}}
    case Receiver.Ready{world,handles}:room_state(~S,state,world,handles)
def namespaces_checked(~S:Data,state:State<S>,result:Schema.World(~S) & Bool) -> Outcome<S>:
  match state result:
    case state, (world,False{}):NamespaceRefused{state,world}
    case State{schema,+input,graph,machine,actors}, (world,True{}):receiver(~S,State{schema,input,graph,machine,actors},Receiver.prepare(~S,~Schema.components(~S),~Schema.Resources(~S),~Unit,count(~S,input),world))
def prepared(~S:Data,world:Schema.World(~S),state:State<S>) -> Outcome<S>:namespaces_checked(~S,state,Target.namespaces(~S,world))
def admitted(~S:Data,world:Schema.World(~S),result:Admission.Prepared<S>) -> Outcome<S>:
  match result:
    case Admission.Refused{schema,input,reason}:InputRefused{world,schema,input,reason}
    case Admission.Prepared{Plan.Schema{Product.Owner{Decl.Constructed{+codec},transient},resources},input,graph,machine}:prepared(~S,world,State{Plan.Schema{Product.Owner{Decl.Constructed{codec},transient},resources},input,graph,machine,Leaf.empty(~Factory.ActorFactory(~S),~D.Raw,~O.Actor<S>,Factory.actor_factory(~S,Decl.Constructed{codec}))})
# Actual Scheduled buffer gating is required before this World continuation.
# Complete basic+graph+machine admission precedes receiver mutation/construction.
def restore(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,world:Schema.World(~S)) -> Outcome<S>:admitted(~S,world,Admission.prepare(~S,schema,input))
