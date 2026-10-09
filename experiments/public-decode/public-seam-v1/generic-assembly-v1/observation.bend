import Base
import ./second-owner.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as First
import /workspace/formal-proofs/bendvy/experiments/public-decode/adoption-v1/observation.bend as FirstObservation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
type PayloadView is Data: PayloadView{raw:D.Raw,words:List<&2,U32>,flags:List<&2,Bool>}
type ColumnView is Data: ColumnView{supported:Bool,slots:List<&2,Maybe<&2,PayloadView>>,stamps:List<&2,L.Entry>}
type Meta is Data: Meta{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type Snapshot is Data: Snapshot{meta:Meta,live:List<&2,Bool>,column:ColumnView,resource:FirstObservation.PayloadView,pending:U32}
def joined(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,U32,a,b))
def array(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: joined(array(left),array(right))
def bool_join(left:Array<Bool> & List<&2,Bool>,right:Array<Bool> & List<&2,Bool>) -> Array<Bool> & List<&2,Bool>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,Bool,a,b))
def bools(owner:Array<Bool>) -> Array<Bool> & List<&2,Bool>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: bool_join(bools(left),bools(right))
def payload_done(+raw:D.Raw,result:Array<U32> & List<&2,U32>,flagged:Array<Bool> & List<&2,Bool>) -> Input.Owner & PayloadView:
  match result flagged:
    case (owner,cells),(flags,view): (Input.Owner{raw,owner,flags},PayloadView{raw,cells,view})
def payload(owner:Input.Owner) -> Input.Owner & PayloadView:
  match owner:
    case Input.Owner{raw,words,flags}: payload_done(raw,array(words),bools(flags))
def some(result:Input.Owner & PayloadView) -> Maybe<&1,Input.Owner> & Maybe<&2,PayloadView>:
  match result:
    case (owner,view): (Some{owner},Some{view})
def option(owner:Maybe<&1,Input.Owner>) -> Maybe<&1,Input.Owner> & Maybe<&2,PayloadView>:
  match owner:
    case None{}: (None{},None{})
    case Some{owner}: some(payload(owner))
def leaf(result:Maybe<&1,Input.Owner> & Maybe<&2,PayloadView>) -> Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,PayloadView>>:
  match result:
    case (owner,view): (ALeaf{owner},[view])
def slot_join(left:Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,PayloadView>>,right:Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,PayloadView>>) -> Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,PayloadView>>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,Maybe<&2,PayloadView>,a,b))
def slots(owner:Array<Maybe<&1,Input.Owner>>) -> Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,PayloadView>>:
  match owner:
    case ALeaf{owner}: leaf(option(owner))
    case ANode{left,right}: slot_join(slots(left),slots(right))
def column_done(~S:Data,+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,Input.Owner>> & List<&2,Maybe<&2,PayloadView>>) -> Col.Column<S,Input.Owner> & ColumnView:
  match result:
    case (owner,view): (Col.Column{owner,stamps},ColumnView{True{},view,stamps})
def column(~S:Data,owner:Col.Column<S,Input.Owner>) -> Col.Column<S,Input.Owner> & ColumnView:
  match owner:
    case Col.Column{values,stamps}: column_done(~S,stamps,slots(values))
    case owner: (owner,ColumnView{False{},[],[]})
def assembled(+meta:Meta,live:Array<Bool> & List<&2,Bool>,store:Col.Column<Unit,Input.Owner> & ColumnView,resource:First.Owner & FirstObservation.PayloadView,pending:List<(Input.World() -> Input.World())> & U32) -> Input.World() & Snapshot:
  match meta live store resource pending:
    case Meta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock}, (live,a), (store,b), (resource,c), (pending,count):(W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock},Snapshot{meta,a,b,c,count})
def snapshot(world:Input.World()) -> Input.World() & Snapshot:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock}:assembled(Meta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock},bools(live),column(~Unit,store),FirstObservation.payload(resource),W.pending_length(~Unit,~Input.Store(),~First.Owner,~Unit,pending))
