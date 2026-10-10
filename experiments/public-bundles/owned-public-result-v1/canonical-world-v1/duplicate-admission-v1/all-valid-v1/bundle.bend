import Base
import ../ordinary-bundle.bend as Front
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import ../../complete-families-v1/canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as CS
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/bundle-component-install.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/bundle-provider.bend as Provider
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type HeadToken is Data:HeadToken{}
type TailToken is Data:TailToken{}
type TagToken is Data:TagToken{}
type DataToken is Data:DataToken{}
type Store is Type:Store{heads:Col.Column<K.SchemaA,K.Payload>,tails:Col.Column<K.SchemaA,K.Tail>,tags:Col.Column<K.SchemaA,K.Tag>,data:Col.Column<K.SchemaA,U32>}
def World(~R:Type) -> Type:W.World<K.SchemaA,Store,R,U32>
def Raw() -> Type:K.Raw()
def Cooked() -> Type:K.Cooked()
type Packet is Type:Packet{cooked:Cooked(),undo:Cooked() -> Raw()}
def Owner(~R:Type) -> Type:AD.Owner<K.SchemaA,Store,R,U32,Packet,K.Context<K.SchemaA>>
def Input() -> Type:Cmd.Input<K.SchemaA,Raw()>
def ConstructorError() -> Data:Constructor.Error<K.Custom>
def Output() -> Type:Cmd.Output<K.SchemaA,Raw(),ConstructorError()>
def HeadRest() -> Type:P.Pack<Col.Column<K.SchemaA,K.Tail>,P.Pack<Col.Column<K.SchemaA,K.Tag>,Col.Column<K.SchemaA,U32>>>
def tail_identity() -> Identity.Declaration<K.SchemaA,K.Tail>:Identity.component(~K.SchemaA,~K.Tail,"canonical-tail")
def tag_identity() -> Identity.Declaration<K.SchemaA,K.Tag>:Identity.component(~K.SchemaA,~K.Tag,"canonical-tag")
def data_identity() -> Identity.Declaration<K.SchemaA,U32>:Identity.component(~K.SchemaA,~U32,"canonical-data")
def take_head(store:Store) -> HeadRest() & Col.Column<K.SchemaA,K.Payload>:
  match store:
    case Store{heads,tails,tags,data}:(P.Pack{tails,P.Pack{tags,data}},heads)
def put_head(rest:HeadRest(),owned:Col.Column<K.SchemaA,K.Payload>) -> Store:
  match rest:
    case P.Pack{tails,P.Pack{tags,data}}:Store{owned,tails,tags,data}
def family_head() -> C.Family<K.SchemaA,Store,HeadRest(),K.Payload,String,HeadToken,take_head,put_head,K.payload_observe>:C.Family{Identity.key(~K.SchemaA,~K.Payload,K.identity(~K.SchemaA))}
def install_head(~R:Type,world:World(R),entry:I.Entry<K.SchemaA,K.Payload>) -> F.Attempt<World(R),I.Entry<K.SchemaA,K.Payload>,I.Recovery<K.SchemaA,K.Payload>>:
  I.install(~K.SchemaA,~Store,~R,~U32,~HeadRest(),~K.Payload,~String,~HeadToken,~take_head,~put_head,~K.payload_observe,family_head(),world,entry)
def TailRest() -> Type:P.Pack<Col.Column<K.SchemaA,K.Payload>,P.Pack<Col.Column<K.SchemaA,K.Tag>,Col.Column<K.SchemaA,U32>>>
def take_tail(store:Store) -> TailRest() & Col.Column<K.SchemaA,K.Tail>:
  match store:
    case Store{heads,tails,tags,data}:(P.Pack{heads,P.Pack{tags,data}},tails)
def put_tail(rest:TailRest(),owned:Col.Column<K.SchemaA,K.Tail>) -> Store:
  match rest:
    case P.Pack{heads,P.Pack{tags,data}}:Store{heads,owned,tags,data}
def family_tail() -> C.Family<K.SchemaA,Store,TailRest(),K.Tail,String,TailToken,take_tail,put_tail,K.tail_observe>:C.Family{Identity.key(~K.SchemaA,~K.Tail,tail_identity())}
def install_tail(~R:Type,world:World(R),entry:I.Entry<K.SchemaA,K.Tail>) -> F.Attempt<World(R),I.Entry<K.SchemaA,K.Tail>,I.Recovery<K.SchemaA,K.Tail>>:
  I.install(~K.SchemaA,~Store,~R,~U32,~TailRest(),~K.Tail,~String,~TailToken,~take_tail,~put_tail,~K.tail_observe,family_tail(),world,entry)
def TagRest() -> Type:P.Pack<Col.Column<K.SchemaA,K.Payload>,P.Pack<Col.Column<K.SchemaA,K.Tail>,Col.Column<K.SchemaA,U32>>>
def take_tag(store:Store) -> TagRest() & Col.Column<K.SchemaA,K.Tag>:
  match store:
    case Store{heads,tails,tags,data}:(P.Pack{heads,P.Pack{tails,data}},tags)
def put_tag(rest:TagRest(),owned:Col.Column<K.SchemaA,K.Tag>) -> Store:
  match rest:
    case P.Pack{heads,P.Pack{tails,data}}:Store{heads,tails,owned,data}
def family_tag() -> C.Family<K.SchemaA,Store,TagRest(),K.Tag,String,TagToken,take_tag,put_tag,K.tag_observe>:C.Family{Identity.key(~K.SchemaA,~K.Tag,tag_identity())}
def install_tag(~R:Type,world:World(R),entry:I.Entry<K.SchemaA,K.Tag>) -> F.Attempt<World(R),I.Entry<K.SchemaA,K.Tag>,I.Recovery<K.SchemaA,K.Tag>>:
  I.install(~K.SchemaA,~Store,~R,~U32,~TagRest(),~K.Tag,~String,~TagToken,~take_tag,~put_tag,~K.tag_observe,family_tag(),world,entry)
def DataRest() -> Type:P.Pack<Col.Column<K.SchemaA,K.Payload>,P.Pack<Col.Column<K.SchemaA,K.Tail>,Col.Column<K.SchemaA,K.Tag>>>
def take_data(store:Store) -> DataRest() & Col.Column<K.SchemaA,U32>:
  match store:
    case Store{heads,tails,tags,data}:(P.Pack{heads,P.Pack{tails,tags}},data)
def put_data(rest:DataRest(),owned:Col.Column<K.SchemaA,U32>) -> Store:
  match rest:
    case P.Pack{heads,P.Pack{tails,tags}}:Store{heads,tails,tags,owned}
def family_data() -> C.Family<K.SchemaA,Store,DataRest(),U32,String,DataToken,take_data,put_data,K.data_observe>:C.Family{Identity.key(~K.SchemaA,~U32,data_identity())}
def install_data(~R:Type,world:World(R),entry:I.Entry<K.SchemaA,U32>) -> F.Attempt<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>>:
  I.install(~K.SchemaA,~Store,~R,~U32,~DataRest(),~U32,~String,~DataToken,~take_data,~put_data,~K.data_observe,family_data(),world,entry)
def DataEntries() -> Type:P.Pack<I.Entry<K.SchemaA,U32>,Unit>
def DataRecovery(~R:Type) -> Type:F.Recovery<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>,Unit,Unit>
def install_data_entries(~R:Type,world:World(R),entries:DataEntries()) -> F.Attempt<World(R),DataEntries(),DataRecovery(R)>:
  F.install(~World(R),~I.Entry<K.SchemaA,U32>,~I.Recovery<K.SchemaA,U32>,~Unit,~Unit,~(w => e => install_data(~R,w,e)),~(w => e => F.terminal(~World(R),w,e)),world,entries)
def TagEntries() -> Type:P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>
def TagRecovery(~R:Type) -> Type:F.Recovery<World(R),I.Entry<K.SchemaA,K.Tag>,I.Recovery<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>,F.Recovery<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>,Unit,Unit>>
def install_tag_entries(~R:Type,world:World(R),entries:TagEntries()) -> F.Attempt<World(R),TagEntries(),TagRecovery(R)>:
  F.install(~World(R),~I.Entry<K.SchemaA,K.Tag>,~I.Recovery<K.SchemaA,K.Tag>,~P.Pack<I.Entry<K.SchemaA,U32>,Unit>,~F.Recovery<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>,Unit,Unit>,~(w => e => install_tag(~R,w,e)),~(w => e => install_data_entries(~R,w,e)),world,entries)
def TailEntries() -> Type:P.Pack<I.Entry<K.SchemaA,K.Tail>,P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>>
def TailRecovery(~R:Type) -> Type:F.Recovery<World(R),I.Entry<K.SchemaA,K.Tail>,I.Recovery<K.SchemaA,K.Tail>,P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>,F.Recovery<World(R),I.Entry<K.SchemaA,K.Tag>,I.Recovery<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>,F.Recovery<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>,Unit,Unit>>>
def install_tail_entries(~R:Type,world:World(R),entries:TailEntries()) -> F.Attempt<World(R),TailEntries(),TailRecovery(R)>:
  F.install(~World(R),~I.Entry<K.SchemaA,K.Tail>,~I.Recovery<K.SchemaA,K.Tail>,~P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>,~F.Recovery<World(R),I.Entry<K.SchemaA,K.Tag>,I.Recovery<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>,F.Recovery<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>,Unit,Unit>>,~(w => e => install_tail(~R,w,e)),~(w => e => install_tag_entries(~R,w,e)),world,entries)
def Entries() -> Type:P.Pack<I.Entry<K.SchemaA,K.Payload>,P.Pack<I.Entry<K.SchemaA,K.Tail>,P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>>>
def Recovery(~R:Type) -> Type:F.Recovery<World(R),I.Entry<K.SchemaA,K.Payload>,I.Recovery<K.SchemaA,K.Payload>,P.Pack<I.Entry<K.SchemaA,K.Tail>,P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>>,F.Recovery<World(R),I.Entry<K.SchemaA,K.Tail>,I.Recovery<K.SchemaA,K.Tail>,P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>,F.Recovery<World(R),I.Entry<K.SchemaA,K.Tag>,I.Recovery<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>,F.Recovery<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>,Unit,Unit>>>>
def install_entries(~R:Type,world:World(R),entries:Entries()) -> F.Attempt<World(R),Entries(),Recovery(R)>:
  F.install(~World(R),~I.Entry<K.SchemaA,K.Payload>,~I.Recovery<K.SchemaA,K.Payload>,~P.Pack<I.Entry<K.SchemaA,K.Tail>,P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>>,~F.Recovery<World(R),I.Entry<K.SchemaA,K.Tail>,I.Recovery<K.SchemaA,K.Tail>,P.Pack<I.Entry<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>>,F.Recovery<World(R),I.Entry<K.SchemaA,K.Tag>,I.Recovery<K.SchemaA,K.Tag>,P.Pack<I.Entry<K.SchemaA,U32>,Unit>,F.Recovery<World(R),I.Entry<K.SchemaA,U32>,I.Recovery<K.SchemaA,U32>,Unit,Unit>>>,~(w => e => install_head(~R,w,e)),~(w => e => install_tail_entries(~R,w,e)),world,entries)
def entries(+target:W.Handle<K.SchemaA>,cooked:Cooked()) -> Entries():
  match cooked:
    case P.Pack{head,P.Pack{tail,P.Pack{tag,P.Pack{data,unit}}}}:P.Pack{I.Entry{target,Some{head}},P.Pack{I.Entry{target,Some{tail}},P.Pack{I.Entry{target,Some{tag}},P.Pack{I.Entry{target,Some{data}},Unit{}}}}}
type Reassembled is Type:
  Ready{cooked:Cooked()}
  Missing{entries:Entries()}
def cooked_of(entries:Entries()) -> Reassembled:
  match entries:
    case P.Pack{I.Entry{h,Some{head}},P.Pack{I.Entry{t,Some{tail}},P.Pack{I.Entry{g,Some{tag}},P.Pack{I.Entry{d,Some{data}},Unit{}}}}}:Ready{P.Pack{head,P.Pack{tail,P.Pack{tag,P.Pack{data,Unit{}}}}}}
    case entries:Missing{entries}
def install_packet(~R:Type,world:World(R),+target:W.Handle<K.SchemaA>,packet:Packet) -> F.Attempt<World(R),Entries(),Recovery(R)> & (Cooked() -> Raw()):
  match packet:
    case Packet{cooked,undo}:(install_entries(~R,world,entries(target,cooked)),undo)
def pack(cooked:Cooked(),undo:Cooked() -> Raw()) -> Packet:Packet{cooked,undo}
def unpack(packet:Packet) -> Raw():
  match packet:
    case Packet{cooked,undo}:undo(cooked)
def plan_data() -> Front.Plan<K.SchemaA,P.Pack<U32,Unit>,P.Pack<U32,Unit>>:Front.compose(~K.SchemaA,~U32,~U32,~Unit,~Unit,Front.component(~K.SchemaA,~U32,~U32,data_identity()),Front.terminal(~K.SchemaA))
def plan_extras() -> Front.Plan<K.SchemaA,K.Extras(),K.Extras()>:Front.compose(~K.SchemaA,~K.Tag,~K.Tag,~P.Pack<U32,Unit>,~P.Pack<U32,Unit>,Front.component(~K.SchemaA,~K.Tag,~K.Tag,tag_identity()),plan_data())
def plan_side() -> Front.Plan<K.SchemaA,K.Side(),K.Side()>:Front.compose(~K.SchemaA,~K.Tail,~K.Tail,~K.Extras(),~K.Extras(),Front.component(~K.SchemaA,~K.Tail,~K.Tail,tail_identity()),plan_extras())
def plan() -> Front.Plan<K.SchemaA,Raw(),Cooked()>:Front.compose(~K.SchemaA,~K.Incoming,~K.Payload,~K.Side(),~K.Side(),Front.component(~K.SchemaA,~K.Incoming,~K.Payload,K.identity(~K.SchemaA)),plan_side())
def request(~R:Type,owner:Owner(R),input:Input()) -> Owner(R) & Output():
  Front.request(~K.SchemaA,~Store,~R,~U32,~Packet,~K.Context<K.SchemaA>,~Raw(),~Cooked(),~ConstructorError(),~K.stage(~K.SchemaA),~pack,~unpack,plan(),owner,input)
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input(),Output()>,input:Input(),owner:H) -> H & Output():Cap.owned_request(~H,~Input(),~Output(),~cap,owner,input)
def run(~R:Type,owner:Owner(R),input:Input()) -> Owner(R) & Output():
  Provider.provide_owned(~Owner(R),~Input(),~Output(),~Input(),~Output(),~(o => i => request(~R,o,i)),~body,input,owner)
