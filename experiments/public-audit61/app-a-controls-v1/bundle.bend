import Base
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
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Owned

type AuditWorkshop is Data:
  AuditWorkshop{}
type ArrayToken is Data:
  ArrayToken{}
type ScalarToken is Data:
  ScalarToken{}
type Store is Type:
  Store{arrays:Col.Column<AuditWorkshop,Array<U32>>,scalars:Col.Column<AuditWorkshop,U32>}
def World(~Resource:Type) -> Type: W.World<AuditWorkshop,Store,Resource,U32>
def Raw() -> Type: P.Pack<Maybe<&1,Array<U32>>,P.Pack<Maybe<&1,U32>,Unit>>
type Packet is Type:
  Packet{cooked:Raw(),undo:Raw() -> Raw()}
def Owner(~Resource:Type) -> Type: AD.Owner<AuditWorkshop,Store,Resource,U32,Packet,Unit>
def Input() -> Type: Cmd.Input<AuditWorkshop,Raw()>
def Output() -> Type: Cmd.Output<AuditWorkshop,Raw(),String>

# Trusted schema setup: two distinct token/payload/lens families.
def take_array(store:Store) -> Col.Column<AuditWorkshop,U32> & Col.Column<AuditWorkshop,Array<U32>>:
  match store:
    case Store{arrays,scalars}: (scalars,arrays)
def put_array(scalars:Col.Column<AuditWorkshop,U32>,arrays:Col.Column<AuditWorkshop,Array<U32>>) -> Store:
  Store{arrays,scalars}
def projected(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (a,+xs), (b,+ys): (ANode{a,b},List.append(&2,U32,xs,ys))
def project_array(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{a,b}: projected(project_array(a),project_array(b))
def array_family() -> C.Family<AuditWorkshop,Store,Col.Column<AuditWorkshop,U32>,Array<U32>,List<&2,U32>,ArrayToken,take_array,put_array,project_array>:
  C.Family{"array"}
def take_scalar(store:Store) -> Col.Column<AuditWorkshop,Array<U32>> & Col.Column<AuditWorkshop,U32>:
  match store:
    case Store{arrays,scalars}: (arrays,scalars)
def put_scalar(arrays:Col.Column<AuditWorkshop,Array<U32>>,scalars:Col.Column<AuditWorkshop,U32>) -> Store:
  Store{arrays,scalars}
def project_scalar(value:U32) -> U32 & U32:
  +copy=value
  (copy,copy)
def scalar_family() -> C.Family<AuditWorkshop,Store,Col.Column<AuditWorkshop,Array<U32>>,U32,U32,ScalarToken,take_scalar,put_scalar,project_scalar>:
  C.Family{"scalar"}
def install_array(~Resource:Type,world:World(Resource),entry:I.Entry<AuditWorkshop,Array<U32>>) -> F.Attempt<World(Resource),I.Entry<AuditWorkshop,Array<U32>>,I.Recovery<AuditWorkshop,Array<U32>>>:
  I.install(~AuditWorkshop,~Store,~Resource,~U32,~Col.Column<AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~ArrayToken,~take_array,~put_array,~project_array,array_family(),world,entry)
def install_scalar(~Resource:Type,world:World(Resource),entry:I.Entry<AuditWorkshop,U32>) -> F.Attempt<World(Resource),I.Entry<AuditWorkshop,U32>,I.Recovery<AuditWorkshop,U32>>:
  I.install(~AuditWorkshop,~Store,~Resource,~U32,~Col.Column<AuditWorkshop,Array<U32>>,~U32,~U32,~ScalarToken,~take_scalar,~put_scalar,~project_scalar,scalar_family(),world,entry)
def ScalarEntries() -> Type: P.Pack<I.Entry<AuditWorkshop,U32>,Unit>
def Entries() -> Type: P.Pack<I.Entry<AuditWorkshop,Array<U32>>,ScalarEntries()>
def ScalarRecovery(~Resource:Type) -> Type: F.Recovery<World(Resource),I.Entry<AuditWorkshop,U32>,I.Recovery<AuditWorkshop,U32>,Unit,Unit>
def RecipeRecovery(~Resource:Type) -> Type: F.Recovery<World(Resource),I.Entry<AuditWorkshop,Array<U32>>,I.Recovery<AuditWorkshop,Array<U32>>,ScalarEntries(),ScalarRecovery(Resource)>
def install_scalar_tail(~Resource:Type,world:World(Resource),tail:ScalarEntries()) -> F.Attempt<World(Resource),ScalarEntries(),ScalarRecovery(Resource)>:
  F.install(~World(Resource),~I.Entry<AuditWorkshop,U32>,~I.Recovery<AuditWorkshop,U32>,~Unit,~Unit,~(w => entry => install_scalar(~Resource,w,entry)),~(w => unit => F.terminal(~World(Resource),w,unit)),world,tail)
# Reached omission control: keep the affine entry in the inverse receipt,
# skipping only the public array installation operation.
def omitted_array(~Resource:Type,world:World(Resource),entry:I.Entry<AuditWorkshop,Array<U32>>) -> F.Attempt<World(Resource),I.Entry<AuditWorkshop,Array<U32>>,I.Recovery<AuditWorkshop,Array<U32>>>:
  F.Installed{world,w => F.Restored{w,entry}}
def install_entries(~Resource:Type,world:World(Resource),entries:Entries()) -> F.Attempt<World(Resource),Entries(),RecipeRecovery(Resource)>:
  F.install(~World(Resource),~I.Entry<AuditWorkshop,Array<U32>>,~I.Recovery<AuditWorkshop,Array<U32>>,~ScalarEntries(),~ScalarRecovery(Resource),~(w => entry => omitted_array(~Resource,w,entry)),~(w => tail => install_scalar_tail(~Resource,w,tail)),world,entries)
def entries(+target:W.Handle<AuditWorkshop>,raw:Raw()) -> Entries():
  match raw:
    case P.Pack{array,P.Pack{scalar,Unit{}}}: P.Pack{I.Entry{target,array},P.Pack{I.Entry{target,scalar},Unit{}}}
def raw_of(entries:Entries()) -> Raw():
  match entries:
    case P.Pack{I.Entry{handle,array},P.Pack{I.Entry{other,scalar},Unit{}}}: P.Pack{array,P.Pack{scalar,Unit{}}}
def install_recipe(~Resource:Type,world:World(Resource),+target:W.Handle<AuditWorkshop>,packet:Packet) -> F.Attempt<World(Resource),Entries(),RecipeRecovery(Resource)> & (Raw() -> Raw()):
  match packet:
    case Packet{cooked,undo}: (install_entries(~Resource,world,entries(target,cooked)),undo)

# Identity constructor receipts preserve the existing optional-owner domain.
def construct_array(ctx:Unit,owner:Maybe<&1,Array<U32>>) -> Unit & CS.Construction<Maybe<&1,Array<U32>>,Maybe<&1,Array<U32>>,String>:
  (ctx,CS.Constructed{owner,x => x})
def construct_scalar(ctx:Unit,owner:Maybe<&1,U32>) -> Unit & CS.Construction<Maybe<&1,U32>,Maybe<&1,U32>,String>:
  (ctx,CS.Constructed{owner,x => x})
def stage_scalar(ctx:Unit,raw:P.Pack<Maybe<&1,U32>,Unit>) -> CS.Staged<Unit,P.Pack<Maybe<&1,U32>,Unit>,P.Pack<Maybe<&1,U32>,Unit>,String>:
  CS.stage(~Unit,~Maybe<&1,U32>,~Maybe<&1,U32>,~Unit,~Unit,~String,~construct_scalar,~(ctx => unit => CS.terminal(~Unit,~String,ctx,unit)),ctx,raw)
def construct(ctx:Unit,raw:Raw()) -> CS.Staged<Unit,Raw(),Raw(),String>:
  CS.stage(~Unit,~Maybe<&1,Array<U32>>,~Maybe<&1,Array<U32>>,~P.Pack<Maybe<&1,U32>,Unit>,~P.Pack<Maybe<&1,U32>,Unit>,~String,~construct_array,~stage_scalar,ctx,raw)
def pack(cooked:Raw(),undo:Raw() -> Raw()) -> Packet: Packet{cooked,undo}
def unpack(packet:Packet) -> Raw():
  match packet:
    case Packet{cooked,undo}: undo(cooked)
def owner(~Resource:Type,tx:T.Tx<World(Resource),U32>) -> Owner(Resource): AD.Owner{BT.Batch{tx,[]},Unit{}}
def request(~Resource:Type,ctx:Owner(Resource),input:Input()) -> Owner(Resource) & Output():
  Cmd.request(~AuditWorkshop,~Store,~Resource,~U32,~Packet,~Unit,~Raw(),~Raw(),~String,~construct,~pack,~unpack,ctx,input)

# Gameplay is independent of Store/Resource and cannot reconstruct opaque H.
def body(~H:Type,~cap:Owned.OwnedRequest<H,Input(),Output()>,input:Input(),ctx:H) -> H & Output():
  Owned.owned_request(~H,~Input(),~Output(),~cap,ctx,input)
def run(~Resource:Type,ctx:Owner(Resource),input:Input()) -> Owner(Resource) & Output():
  Provider.provide_owned(~Owner(Resource),~Input(),~Output(),~Input(),~Output(),~(ctx => input => request(~Resource,ctx,input)),~body,input,ctx)


def empty(unit:Unit) -> Store:
  Store{Col.empty(~AuditWorkshop,~Array<U32>),Col.empty(~AuditWorkshop,~U32)}
def sample() -> Raw():
  P.Pack{Some{ANode{ALeaf{7},ALeaf{9}}},P.Pack{Some{11},Unit{}}}
