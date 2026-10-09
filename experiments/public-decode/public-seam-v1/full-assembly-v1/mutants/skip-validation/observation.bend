import Base
import ./application.bend as App
import ./request.bend as Deferred
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L

type PayloadView is Data: PayloadView{raw:D.Raw,sentinel:List<&2,U32>}
type ColumnView is Data: ColumnView{supported:Bool,slots:List<&2,Maybe<&2,PayloadView>>,stamps:List<&2,L.Entry>}
type Meta is Data: Meta{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,events:List<&2,Unit>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type Snapshot is Data: Snapshot{meta:Meta,live:List<&2,Bool>,column:ColumnView,resource:MailView,pending:U32}
def joined(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,U32,a,b))
def array(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: joined(array(left),array(right))
def payload_done(+raw:D.Raw,result:Array<U32> & List<&2,U32>) -> Input.Owner & PayloadView:
  match result:
    case (owner,cells): (Input.Owner{raw,owner},PayloadView{raw,cells})
def payload(owner:Input.Owner) -> Input.Owner & PayloadView:
  match owner:
    case Input.Owner{raw,sentinel}: payload_done(raw,array(sentinel))
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
def bool_join(left:Array<Bool> & List<&2,Bool>,right:Array<Bool> & List<&2,Bool>) -> Array<Bool> & List<&2,Bool>:
  match left right:
    case (left,a), (right,b): (ANode{left,right},List.append(&2,Bool,a,b))
def bools(owner:Array<Bool>) -> Array<Bool> & List<&2,Bool>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: bool_join(bools(left),bools(right))
type PacketView is Data:PacketView{owner:Maybe<&2,PayloadView>,original:D.Raw,canonical:D.Raw}
type MailView is Data:MailView{value:PayloadView,retired:List<&2,PayloadView>,returned:List<&2,PacketView>,errors:List<&2,W.WorldError>}
def owners_join(head:Input.Owner & PayloadView,tail:List<Input.Owner> & List<&2,PayloadView>) -> List<Input.Owner> & List<&2,PayloadView>:
  match head tail:
    case (owner,view),(rest,views):(owner <> rest,view <> views)
def owners(values:List<Input.Owner>) -> List<Input.Owner> & List<&2,PayloadView>:
  match values:
    case []:([],[])
    case owner <> rest:owners_join(payload(owner),owners(rest))
def packet_join(+original:D.Raw,+canonical:D.Raw,result:Maybe<&1,Input.Owner> & Maybe<&2,PayloadView>) -> Deferred.Packet<Input.Owner> & PacketView:
  match result:
    case (owner,view):(Deferred.Packet{owner,original,canonical},PacketView{view,original,canonical})
def packet(value:Deferred.Packet<Input.Owner>) -> Deferred.Packet<Input.Owner> & PacketView:
  match value:
    case Deferred.Packet{owner,original,canonical}:packet_join(original,canonical,option(owner))
def packets_join(head:Deferred.Packet<Input.Owner> & PacketView,tail:List<Deferred.Packet<Input.Owner>> & List<&2,PacketView>) -> List<Deferred.Packet<Input.Owner>> & List<&2,PacketView>:
  match head tail:
    case (owner,view),(rest,views):(owner <> rest,view <> views)
def packets(values:List<Deferred.Packet<Input.Owner>>) -> List<Deferred.Packet<Input.Owner>> & List<&2,PacketView>:
  match values:
    case []:([],[])
    case owner <> rest:packets_join(packet(owner),packets(rest))
def mail_join(~S:Data,+errors:List<&2,W.WorldError>,value:Input.Owner & PayloadView,retired:List<Input.Owner> & List<&2,PayloadView>,returned:List<Deferred.Packet<Input.Owner>> & List<&2,PacketView>) -> App.Mail<S> & MailView:
  match value retired returned:
    case (value,a),(retired,b),(returned,c):(App.Mail{value,retired,returned,errors},MailView{a,b,c,errors})
def mail(~S:Data,value:App.Mail<S>) -> App.Mail<S> & MailView:
  match value:
    case App.Mail{value,retired,returned,errors}:mail_join(~S,errors,payload(value),owners(retired),packets(returned))
def assembled(~S:Data,+meta:Meta,live:Array<Bool> & List<&2,Bool>,store:Col.Column<S,Input.Owner> & ColumnView,resource:App.Mail<S> & MailView,pending:List<(App.World(~S) -> App.World(~S))> & U32) -> App.World(~S) & Snapshot:
  match meta live store resource pending:
    case Meta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock}, (live,a), (store,b), (resource,c), (pending,count): (W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock},Snapshot{meta,a,b,c,count})
def snapshot(~S:Data,world:App.World(~S)) -> App.World(~S) & Snapshot:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock}: assembled(~S,Meta{namespace,next,high,capacity,depth,events,registrations,nextSystem,clock},bools(live),column(~S,store),mail(~S,resource),W.pending_length(~S,~App.Store(~S),~App.Mail<S>,~Unit,pending))
