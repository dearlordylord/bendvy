import Base
import ./application.bend as App
import ./owner.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

type Pending is Data:Pending{kind:String,system:String,target:U32,payload:App.QueuedPayload}
def pending(value:List<&2,App.Queued>) -> List<&2,Pending>:
  match value:
    case []:[]
    case App.Queued{kind,system,_,id,payload} <> rest:Pending{kind,system,id,payload} <> pending(rest)
def count(value:List<&2,Pending>) -> U32:
  match value:
    case []:0
    case _ <> rest:U32.add(1,count(rest))
type Entity is Data:Entity{id:U32,value:Maybe<&2,Owner.View>,marker:Maybe<&2,U32>}
# Missing physical capacity is ordinary absent-component semantics, as Col.get.
def at(~T:Data,items:List<&2,Maybe<&2,T>>,index:Nat) -> Maybe<&2,T>:
  match items index:
    case [] _:None{}
    case item <> _ Zero{}:item
    case _ <> rest Succ{n}:at(~T,rest,n)
def entities(live:List<&2,Bool>,+values:List<&2,Maybe<&2,Owner.View>>,+markers:List<&2,Maybe<&2,U32>>,+index:Nat,+id:U32) -> List<&2,Entity>:
  match live:
    case []:[]
    case True{} <> rest:Entity{id,at(~Owner.View,values,index),at(~U32,markers,index)} <> entities(rest,values,markers,Succ{index},U32.add(id,1))
    case False{} <> rest:entities(rest,values,markers,Succ{index},U32.add(id,1))
# World.live is indexed by logical id, including the reserved id0 sentinel.
# Component columns are indexed id-1; discard only that sentinel before traversal.
def live_entities(live:List<&2,Bool>,values:List<&2,Maybe<&2,Owner.View>>,markers:List<&2,Maybe<&2,U32>>) -> List<&2,Entity>:
  match live:
    case []:[]
    case _ <> rest:entities(rest,values,markers,0n,1)
type State is Data:State{entities:List<&2,Entity>,resource:Owner.View,pending:List<&2,Pending>,pendingCount:U32,receiptCountMatches:Bool} Unsupported{snapshot:App.Snapshot}
def state(value:App.Snapshot) -> State:
  match value:
    case App.Snapshot{_,live,App.StoreView{App.ColumnView{True{},values,_},App.MarkerView{markers,_},_,_,+receipts},resource,+n}:State{live_entities(live,values,markers),resource,pending(receipts),n,U32.is_eq(count(pending(receipts)),n)}
    case other:Unsupported{other}
type Checked is Data:
  Accepted{target:Maybe<&2,U32>,spawned:Bool,canonical:D.Raw}
  Refused{input:Maybe<&2,Owner.InputView>,error:Request.Error}
  SystemFailed{error:Unit}
  InvocationRefused{input:Owner.InputView,operation:App.Mode,namespace:U32,target:U32}
def target(~S:Data,value:W.Handle<S>) -> U32:
  match value:
    case W.Handle{_,id}:id
def checked(~S:Data,value:App.ResultView<S>) -> Checked:
  match value:
    case App.Completed{App.ComponentView{App.Accepted{handle,spawned,canonical,_}}}:Accepted{Some{target(~S,handle)},spawned,canonical}
    case App.Completed{App.ComponentView{App.Refused{input,error}}}:Refused{input,error}
    case App.Completed{App.ResourceOutputView{App.ResourceReplaced{canonical,_}}}:Accepted{None{},False{},canonical}
    case App.Completed{App.ResourceOutputView{App.ResourceRefused{input,error}}}:Refused{Some{input},Request.Validation{error}}
    case App.Failed{error}:SystemFailed{error}
    case App.InvocationRefused{input,operation,W.Handle{namespace,id}}:InvocationRefused{input,operation,namespace,id}
type View is Data:View{original:Owner.InputView,before:State,committed:State,barrier:State,checked:Checked} SetupRefused{}
def view(~S:Data,value:App.Report<S>) -> View:
  match value:
    case App.Report{original,before,committed,barrier,_,result}:View{original,state(before),state(committed),state(barrier),checked(~S,result)}
    case _:SetupRefused{}
# Physical supplement remains complete, never replaced by the public value view.
type Whole<S:Data> is Data:Whole{public:View,native:App.Report<S>}
def whole(~S:Data,+value:App.Report<S>) -> Whole<S>:Whole{view(~S,value),value}
