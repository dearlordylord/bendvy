import Base
import ./declarations.bend as Ordinary
import ./staging.bend as Stage
import ./receiver.bend as Receiver
import ./publication.bend as Publication
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-restore-receiver.bend as Prepare
import ../../src/ecs/execution-restore-clear.bend as Clear
import ../../src/ecs/execution-restore-publication.bend as Publish
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-lifecycle-notices.bend as Notice

def Receipt(~S:Data) -> Type:Buffer.Receipt<S,Ordinary.Actor<S>,Removed.Removed(Receiver.Components(~S))>
type Outcome<-S:Data> is Type:
  ReceiverRefused{schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,world:Receiver.World(~S),reason:Prepare.Reason}
  InputRefused{state:Stage.State<S>,input:Saved.Snapshot<S>,world:Receiver.World(~S),error:Stage.Error}
  RowsRefused{state:Stage.State<S>,input:Saved.Snapshot<S>,world:Receiver.World(~S),rows:List<Publish.Row<Receiver.Components(~S)>>}
  ClearInterrupted{state:Stage.State<S>,input:Saved.Snapshot<S>,rows:List<Publish.Row<Receiver.Components(~S)>>,result:Clear.Cleared<S,Receiver.Components(~S),Layout.InLeft{Layout.AtLeaf{}},Receiver.Resources(~S),Unit>}
  PublicationPartial{state:Stage.State<S>,input:Saved.Snapshot<S>,removed:List<Receipt(~S)>,result:Publish.Published<S,Receiver.Components(~S),Receiver.Resources(~S),Unit>}
  ResourcePartial{state:Stage.State<S>,input:Saved.Snapshot<S>,world:Receiver.World(~S),removed:List<Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publish.Receipt<S,Receiver.Components(~S)>>,previous:Maybe<&1,Publication.ConfigSlot(~S)>}
  Restored{state:Stage.State<S>,input:Saved.Snapshot<S>,world:Receiver.World(~S),removed:List<Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publish.Receipt<S,Receiver.Components(~S)>>,previous:Maybe<&1,Publication.ConfigSlot(~S)>}
def finished(~S:Data,valid:Bool,state:Stage.State<S>,input:Saved.Snapshot<S>,world:Receiver.World(~S),removed:List<Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publish.Receipt<S,Receiver.Components(~S)>>,previous:Maybe<&1,Publication.ConfigSlot(~S)>) -> Outcome<S>:
  match valid:
    case False{}:ResourcePartial{state,input,world,removed,mapping,publications,previous}
    case True{}:Restored{state,input,world,removed,mapping,publications,previous}
def resource_updated(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,actors:Stage.Actors(~S),input:Saved.Snapshot<S>,namespace:U32,allocator:A.Allocator,store:Layout.columns(~S,Receiver.Components(~S)),events:List<&2,Unit>,pending:List<Deferred.Command<Receiver.World(~S)>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,journal:Notice.Journal<S>,removed:List<Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publish.Receipt<S,Receiver.Components(~S)>>,result:Publication.ResourceUpdated<S>) -> Outcome<S>:
  match result:
    case Publication.ResourceUpdated{configs,resources,previous,valid}:finished(~S,valid,Stage.State{schema,actors,configs},input,W.World{namespace,allocator,store,resources,events,pending,registrations,nextSystemId,clock,journal},removed,mapping,publications,previous)
def replace_resource(~S:Data,state:Stage.State<S>,input:Saved.Snapshot<S>,world:Receiver.World(~S),removed:List<Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publish.Receipt<S,Receiver.Components(~S)>>,tick:Tick.Tick) -> Outcome<S>:
  match state world:
    case Stage.State{schema,actors,configs} W.World{namespace,allocator,store,resources,events,pending,registrations,nextSystemId,clock,journal}:resource_updated(~S,schema,actors,input,namespace,allocator,store,events,pending,registrations,nextSystemId,clock,journal,removed,mapping,publications,Publication.resources(~S,configs,resources,tick))
def published(~S:Data,state:Stage.State<S>,input:Saved.Snapshot<S>,removed:List<Receipt(~S)>,tick:Tick.Tick,result:Publish.Published<S,Receiver.Components(~S),Receiver.Resources(~S),Unit>) -> Outcome<S>:
  match result:
    case Publish.Published{world,mapping,receipts,False{}}:PublicationPartial{state,input,removed,Publish.Published{world,mapping,receipts,False{}}}
    case Publish.Published{world,mapping,receipts,True{}}:replace_resource(~S,state,input,world,removed,mapping,receipts,tick)
def cleared(~S:Data,state:Stage.State<S>,input:Saved.Snapshot<S>,rows:List<Publish.Row<Receiver.Components(~S)>>,+tick:Tick.Tick,result:Clear.Cleared<S,Receiver.Components(~S),Layout.InLeft{Layout.AtLeaf{}},Receiver.Resources(~S),Unit>) -> Outcome<S>:
  match result:
    case Clear.Interrupted{world,receipts,remaining}:ClearInterrupted{state,input,rows,Clear.Interrupted{world,receipts,remaining}}
    case Clear.Cleared{world,receipts}:published(~S,state,input,receipts,tick,Publication.publish(~S,rows,world,tick))
def clocked(~S:Data,state:Stage.State<S>,input:Saved.Snapshot<S>,rows:List<Publish.Row<Receiver.Components(~S)>>,handles:List<&2,W.Handle<S>>,result:Receiver.World(~S) & Tick.Tick) -> Outcome<S>:
  match result:
    case (world,+tick):cleared(~S,state,input,rows,tick,Receiver.clear(~S,handles,world,tick))
def rows_ready(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,configs:Stage.Configs(~S),input:Saved.Snapshot<S>,world:Receiver.World(~S),handles:List<&2,W.Handle<S>>,result:Publication.Rows<S>) -> Outcome<S>:
  match result:
    case Publication.Rows{actors,rows,False{}}:RowsRefused{Stage.State{schema,actors,configs},input,world,rows}
    case Publication.Rows{actors,rows,True{}}:clocked(~S,Stage.State{schema,actors,configs},input,rows,handles,W.write_clock(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,world))
def staged(~S:Data,world:Receiver.World(~S),handles:List<&2,W.Handle<S>>,result:Stage.State<S> & (Saved.Snapshot<S> & Maybe<&2,Stage.Error>)) -> Outcome<S>:
  match result:
    case (state,(input,Some{error})):InputRefused{state,input,world,error}
    case (Stage.State{schema,actors,configs},(Saved.Snapshot{+version,+metadata,+values,+resources},None{})):rows_ready(~S,schema,configs,Saved.Snapshot{version,metadata,values,resources},world,handles,Publication.staged_rows(~S,values,actors))
def receiver_ready(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,result:Prepare.Prepared<S,Receiver.Components(~S),Receiver.Resources(~S),Unit>) -> Outcome<S>:
  match result:
    case Prepare.Refused{world,reason}:ReceiverRefused{schema,input,world,reason}
    case Prepare.Ready{world,handles}:staged(~S,world,handles,Stage.prepare(~S,schema,input))
def count(values:List<&2,Saved.Entity>) -> Nat:
  match values:
    case []:0n
    case _ <> rest:1n+count(rest)
# Internal World continuation. Ordinary Scheduled owners must pass their actual
# pending-buffer gate first. No callback, queue or source namespace is installed.
def restore(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,+input:Saved.Snapshot<S>,world:Receiver.World(~S)) -> Outcome<S>:
  match input:
    case Saved.Snapshot{+version,+metadata,+values,+resources}:receiver_ready(~S,schema,Saved.Snapshot{version,metadata,values,resources},Receiver.prepare(~S,count(values),world))
def alpha(schema:Plan.Schema<Ordinary.Alpha,Ordinary.components(~Ordinary.Alpha),Ordinary.resources(~Ordinary.Alpha)>,input:Saved.Snapshot<Ordinary.Alpha>,world:Receiver.World(~Ordinary.Alpha)) -> Outcome<Ordinary.Alpha>:restore(~Ordinary.Alpha,schema,input,world)
def beta(schema:Plan.Schema<Ordinary.Beta,Ordinary.components(~Ordinary.Beta),Ordinary.resources(~Ordinary.Beta)>,input:Saved.Snapshot<Ordinary.Beta>,world:Receiver.World(~Ordinary.Beta)) -> Outcome<Ordinary.Beta>:restore(~Ordinary.Beta,schema,input,world)
