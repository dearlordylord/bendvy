import Base
import ./restore.bend as Restore
import ./staging.bend as Stage
import ./receiver.bend as Receiver
import ./publication.bend as Publication
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-restore-receiver.bend as Prepare
import ../../src/ecs/execution-restore-clear.bend as Clear
import ../../src/ecs/execution-restore-publication.bend as Publish
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as Layout

type Status is Data:Pending{} ReceiverRefused{reason:Prepare.Reason} InputRefused{error:Stage.Error} RowsRefused{} ClearInterrupted{} PublicationPartial{} ResourcePartial{} Restored{}
type Receipt<-S:Data> is Type:
  Receipt{state:Stage.State<S>,input:Saved.Snapshot<S>,removed:List<Restore.Receipt(~S)>,rows:List<Publish.Row<Receiver.Components(~S)>>,mapping:List<&2,R.Binding<S>>,publications:List<Publish.Receipt<S,Receiver.Components(~S)>>,previous:Maybe<&1,Publication.ConfigSlot(~S)>,remaining:List<&2,W.Handle<S>>,status:Status}
def cleared(~S:Data,state:Stage.State<S>,input:Saved.Snapshot<S>,rows:List<Publish.Row<Receiver.Components(~S)>>,result:Clear.Cleared<S,Receiver.Components(~S),Layout.InLeft{Layout.AtLeaf{}},Receiver.Resources(~S),Unit>) -> Receiver.World(~S) & Receipt<S>:
  match result:
    case Clear.Interrupted{world,removed,remaining}:(world,Receipt{state,input,removed,rows,[],[],None{},remaining,ClearInterrupted{}})
    case Clear.Cleared{world,removed}:(world,Receipt{state,input,removed,rows,[],[],None{},[],ClearInterrupted{}})
def published(~S:Data,state:Stage.State<S>,input:Saved.Snapshot<S>,removed:List<Restore.Receipt(~S)>,result:Publish.Published<S,Receiver.Components(~S),Receiver.Resources(~S),Unit>) -> Receiver.World(~S) & Receipt<S>:
  match result:
    case Publish.Published{world,mapping,receipts,_}:(world,Receipt{state,input,removed,[],mapping,receipts,None{},[],PublicationPartial{}})
def extract(~S:Data,result:Restore.Outcome<S>) -> Receiver.World(~S) & Receipt<S>:
  match result:
    case Restore.ReceiverRefused{schema,input,world,reason}:(world,Receipt{Stage.empty(~S,schema),input,[],[],[],[],None{},[],ReceiverRefused{reason}})
    case Restore.InputRefused{state,input,world,error}:(world,Receipt{state,input,[],[],[],[],None{},[],InputRefused{error}})
    case Restore.RowsRefused{state,input,world,rows}:(world,Receipt{state,input,[],rows,[],[],None{},[],RowsRefused{}})
    case Restore.ClearInterrupted{state,input,rows,result}:cleared(~S,state,input,rows,result)
    case Restore.PublicationPartial{state,input,removed,result}:published(~S,state,input,removed,result)
    case Restore.ResourcePartial{state,input,world,removed,mapping,publications,previous}:(world,Receipt{state,input,removed,[],mapping,publications,previous,[],ResourcePartial{}})
    case Restore.Restored{state,input,world,removed,mapping,publications,previous}:(world,Receipt{state,input,removed,[],mapping,publications,previous,[],Restored{}})
