import Base
import canonical.bend as K
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
type Store is Type:Store{heads:Col.Column<K.SchemaB,K.Payload>,tails:Col.Column<K.SchemaB,K.Tail>}
def World(~R:Type) -> Type:W.World<K.SchemaB,Store,R,U32>
def Raw() -> Type:P.Pack<K.Incoming,K.Tail>
def Cooked() -> Type:P.Pack<K.Payload,K.Tail>
type Packet is Type:Packet{cooked:Cooked(),undo:Cooked() -> Raw()}
def Owner(~R:Type) -> Type:AD.Owner<K.SchemaB,Store,R,U32,Packet,K.Context<K.SchemaB>>
def Input() -> Type:Cmd.Input<K.SchemaB,Raw()>
def ConstructorError() -> Data:Constructor.Error<K.Custom>
def Output() -> Type:Cmd.Output<K.SchemaB,Raw(),ConstructorError()>
def take_head(store:Store) -> Col.Column<K.SchemaB,K.Tail> & Col.Column<K.SchemaB,K.Payload>:
  match store:
    case Store{heads,tails}:(tails,heads)
def put_head(rest:Col.Column<K.SchemaB,K.Tail>,owned:Col.Column<K.SchemaB,K.Payload>) -> Store:Store{owned,rest}
def family_head() -> C.Family<K.SchemaB,Store,Col.Column<K.SchemaB,K.Tail>,K.Payload,String,HeadToken,take_head,put_head,K.payload_observe>:C.Family{"canonical-head"}
def install_head(~R:Type,world:World(R),entry:I.Entry<K.SchemaB,K.Payload>) -> F.Attempt<World(R),I.Entry<K.SchemaB,K.Payload>,I.Recovery<K.SchemaB,K.Payload>>:
  I.install(~K.SchemaB,~Store,~R,~U32,~Col.Column<K.SchemaB,K.Tail>,~K.Payload,~String,~HeadToken,~take_head,~put_head,~K.payload_observe,family_head(),world,entry)
def take_tail(store:Store) -> Col.Column<K.SchemaB,K.Payload> & Col.Column<K.SchemaB,K.Tail>:
  match store:
    case Store{heads,tails}:(heads,tails)
def put_tail(rest:Col.Column<K.SchemaB,K.Payload>,owned:Col.Column<K.SchemaB,K.Tail>) -> Store:Store{rest,owned}
def family_tail() -> C.Family<K.SchemaB,Store,Col.Column<K.SchemaB,K.Payload>,K.Tail,String,TailToken,take_tail,put_tail,K.tail_observe>:C.Family{"canonical-tail"}
def install_tail(~R:Type,world:World(R),entry:I.Entry<K.SchemaB,K.Tail>) -> F.Attempt<World(R),I.Entry<K.SchemaB,K.Tail>,I.Recovery<K.SchemaB,K.Tail>>:
  I.install(~K.SchemaB,~Store,~R,~U32,~Col.Column<K.SchemaB,K.Payload>,~K.Tail,~String,~TailToken,~take_tail,~put_tail,~K.tail_observe,family_tail(),world,entry)
def TailEntries() -> Type:P.Pack<I.Entry<K.SchemaB,K.Tail>,Unit>
def Entries() -> Type:P.Pack<I.Entry<K.SchemaB,K.Payload>,TailEntries()>
def TailRecovery(~R:Type) -> Type:F.Recovery<World(R),I.Entry<K.SchemaB,K.Tail>,I.Recovery<K.SchemaB,K.Tail>,Unit,Unit>
def Recovery(~R:Type) -> Type:F.Recovery<World(R),I.Entry<K.SchemaB,K.Payload>,I.Recovery<K.SchemaB,K.Payload>,TailEntries(),TailRecovery(R)>
def install_tail_entries(~R:Type,world:World(R),entries:TailEntries()) -> F.Attempt<World(R),TailEntries(),TailRecovery(R)>:
  F.install(~World(R),~I.Entry<K.SchemaB,K.Tail>,~I.Recovery<K.SchemaB,K.Tail>,~Unit,~Unit,~(w => e => install_tail(~R,w,e)),~(w => u => F.terminal(~World(R),w,u)),world,entries)
def install_entries(~R:Type,world:World(R),entries:Entries()) -> F.Attempt<World(R),Entries(),Recovery(R)>:
  F.install(~World(R),~I.Entry<K.SchemaB,K.Payload>,~I.Recovery<K.SchemaB,K.Payload>,~TailEntries(),~TailRecovery(R),~(w => e => install_head(~R,w,e)),~(w => e => install_tail_entries(~R,w,e)),world,entries)
def entries(+target:W.Handle<K.SchemaB>,cooked:Cooked()) -> Entries():
  match cooked:
    case P.Pack{head,tail}:P.Pack{I.Entry{target,Some{head}},P.Pack{I.Entry{target,Some{tail}},Unit{}}}
type Reassembled is Type:
  Ready{cooked:Cooked()}
  Missing{entries:Entries()}
def cooked_of(entries:Entries()) -> Reassembled:
  match entries:
    case P.Pack{I.Entry{target,Some{head}},P.Pack{I.Entry{other,Some{tail}},Unit{}}}:Ready{P.Pack{head,tail}}
    case P.Pack{I.Entry{target,None{}},tail}:Missing{P.Pack{I.Entry{target,None{}},tail}}
    case P.Pack{I.Entry{target,Some{head}},P.Pack{I.Entry{other,None{}},Unit{}}}:Missing{P.Pack{I.Entry{target,Some{head}},P.Pack{I.Entry{other,None{}},Unit{}}}}
def install_packet(~R:Type,world:World(R),+target:W.Handle<K.SchemaB>,packet:Packet) -> F.Attempt<World(R),Entries(),Recovery(R)> & (Cooked() -> Raw()):
  match packet:
    case Packet{cooked,undo}:(install_entries(~R,world,entries(target,cooked)),undo)
def pack(cooked:Cooked(),undo:Cooked() -> Raw()) -> Packet:Packet{cooked,undo}
def unpack(packet:Packet) -> Raw():
  match packet:
    case Packet{cooked,undo}:undo(cooked)
def request(~R:Type,owner:Owner(R),input:Input()) -> Owner(R) & Output():
  Cmd.request(~K.SchemaB,~Store,~R,~U32,~Packet,~K.Context<K.SchemaB>,~Raw(),~Cooked(),~ConstructorError(),~K.stage(~K.SchemaB),~pack,~unpack,owner,input)
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input(),Output()>,input:Input(),owner:H) -> H & Output():Cap.owned_request(~H,~Input(),~Output(),~cap,owner,input)
def run(~R:Type,owner:Owner(R),input:Input()) -> Owner(R) & Output():
  Provider.provide_owned(~Owner(R),~Input(),~Output(),~Input(),~Output(),~(o => i => request(~R,o,i)),~body,input,owner)
