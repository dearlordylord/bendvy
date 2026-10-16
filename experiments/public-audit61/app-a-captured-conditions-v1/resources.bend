import Base
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import bundle.bend as Bundle
import owner-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as Pack
type QuarantineReceipt is Type:
  QuarantineReceipt{recovery:Bundle.RecipeRecovery(Resources()),undo:Bundle.Raw() -> Bundle.Raw(),error:W.WorldError}
type Receipts is Type:
  Receipts{inverses:List<(W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)>,returned:List<Bundle.Packet>,errors:List<&2,W.WorldError>,quarantines:List<QuarantineReceipt>}
def Resources() -> Type:
  Product.Owner<Array<U32>,Product.Owner<Array<U32>,Receipts>>
def Counter() -> Schema.Resource<Bundle.AuditWorkshop,Array<U32>>:
  Schema.resource(~Bundle.AuditWorkshop,~Array<U32>,"Counter")
def Sibling() -> Schema.Resource<Bundle.AuditWorkshop,Array<U32>>:
  Schema.resource(~Bundle.AuditWorkshop,~Array<U32>,"Sibling")
def ReceiptIdentity() -> Schema.Resource<Bundle.AuditWorkshop,Receipts>:
  Schema.resource(~Bundle.AuditWorkshop,~Receipts,"BundleReceipts")
def Leaf() -> Data:
  Binding.Built<Bundle.AuditWorkshop,Array<U32>,Schema.Resource<Bundle.AuditWorkshop,Array<U32>>>
def TailIndex() -> Data:
  Binding.Branch<Leaf(),Binding.Built<Bundle.AuditWorkshop,Receipts,Schema.Resource<Bundle.AuditWorkshop,Receipts>>>
def Index() -> Data:
  Binding.Branch<Leaf(),Binding.Built<Bundle.AuditWorkshop,Product.Owner<Array<U32>,Receipts>,TailIndex()>>
def layout() -> Binding.Built<Bundle.AuditWorkshop,Resources(),Index()>:
  Binding.joined(~Bundle.AuditWorkshop,~Array<U32>,~Product.Owner<Array<U32>,Receipts>,~Schema.Resource<Bundle.AuditWorkshop,Array<U32>>,~TailIndex(),Binding.leaf(~Bundle.AuditWorkshop,~Array<U32>,Counter()),Binding.joined(~Bundle.AuditWorkshop,~Array<U32>,~Receipts,~Schema.Resource<Bundle.AuditWorkshop,Array<U32>>,~Schema.Resource<Bundle.AuditWorkshop,Receipts>,Binding.leaf(~Bundle.AuditWorkshop,~Array<U32>,Sibling()),Binding.leaf(~Bundle.AuditWorkshop,~Receipts,ReceiptIdentity())))
def lens() -> Product.Lens<Resources(),Array<U32>,Unit & Product.Owner<Array<U32>,Receipts>>:
  Binding.left_lens(~Resources(),~Array<U32>,~Product.Owner<Array<U32>,Receipts>,~Unit,~Binding.whole(~Resources()))
def cursor() -> Binding.Cursor<Bundle.AuditWorkshop,Resources(),Array<U32>,Unit & Product.Owner<Array<U32>,Receipts>,Schema.Resource<Bundle.AuditWorkshop,Array<U32>>,lens()>:
  Binding.left(~Bundle.AuditWorkshop,~Resources(),~Array<U32>,~Product.Owner<Array<U32>,Receipts>,~Unit,~Schema.Resource<Bundle.AuditWorkshop,Array<U32>>,~TailIndex(),~Binding.whole(~Resources()),Binding.root(~Bundle.AuditWorkshop,~Resources(),~Index(),layout()))
def binding() -> Binding.Binding<Bundle.AuditWorkshop,Resources(),Array<U32>,Unit & Product.Owner<Array<U32>,Receipts>,lens(),Counter()>:
  Binding.bind(~Bundle.AuditWorkshop,~Resources(),~Array<U32>,~Unit & Product.Owner<Array<U32>,Receipts>,~lens(),~cursor())
def project(values:Array<U32>) -> Array<U32> & List<&2,U32>:
  Bundle.project_array(values)
def Ops(H:Type) -> Type:
  Field.Write<Bundle.AuditWorkshop,Array<U32>,Counter(),H,List<&2,U32>>
def declaration() -> Field.Declaration<Bundle.AuditWorkshop,T.Tx<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,U32>,Ops(T.Tx<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,U32>)>:
  Field.write(~Bundle.AuditWorkshop,~Bundle.Store,~Resources(),~U32,~Array<U32>,~Unit & Product.Owner<Array<U32>,Receipts>,~List<&2,U32>,~lens(),~Counter(),~binding(),~project)
def body(~H:Type,~cap:Ops(H),unit:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (Field.set(~Bundle.AuditWorkshop,~Array<U32>,~Counter(),~H,~List<&2,U32>,~cap,owner,ANode{ALeaf{21},ALeaf{22}}),(T.Success{},Unit{}))
def initial() -> Resources():
  Product.Owner{ANode{ALeaf{10},ALeaf{11}},Product.Owner{ANode{ALeaf{100},ALeaf{101}},Receipts{[],[],[],[]}}}
def counted_inverse(inverse:W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>,rest:List<(W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat) -> List<(W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat:
  match rest:
    case (tail,n):(inverse <> tail,1n+n)
def inverse_count(values:List<(W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)>) -> List<(W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat:
  match values:
    case []:([],0n)
    case inverse <> tail:counted_inverse(inverse,inverse_count(tail))
def world_error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def maybe_array(value:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  Dump.optional(~Array<U32>,~Dump.u32_array,value)
def maybe_scalar(value:Maybe<&1,U32>) -> Maybe<&1,U32> & String:
  Dump.optional(~U32,~Dump.u32_value,value)
def packet_join(undo:Bundle.Raw() -> Bundle.Raw(),left:Maybe<&1,Array<U32>> & String,right:Maybe<&1,U32> & String) -> Bundle.Packet & String:
  (array,sa)=left
  (scalar,ss)=right
  (Bundle.Packet{Pack.Pack{array,Pack.Pack{scalar,Unit{}}},undo},"array=" ++ sa ++ ";scalar=" ++ ss)
def packet_view(value:Bundle.Packet) -> Bundle.Packet & String:
  match value:
    case Bundle.Packet{Pack.Pack{array,Pack.Pack{scalar,Unit{}}},undo}:packet_join(undo,maybe_array(array),maybe_scalar(scalar))
def packet_cons(head:Bundle.Packet & String,tail:List<Bundle.Packet> & List<&2,String>) -> List<Bundle.Packet> & List<&2,String>:
  (head,text)=head
  (tail,texts)=tail
  (head <> tail,text <> texts)
def packets_view(values:List<Bundle.Packet>) -> List<Bundle.Packet> & List<&2,String>:
  match values:
    case []:([],[])
    case head <> tail:packet_cons(packet_view(head),packets_view(tail))
def quarantine_cons(head:QuarantineReceipt,tail:List<QuarantineReceipt> & Nat) -> List<QuarantineReceipt> & Nat:
  match tail:
    case (tail,count):(head <> tail,1n+count)
def quarantines_count(values:List<QuarantineReceipt>) -> List<QuarantineReceipt> & Nat:
  match values:
    case []:([],0n)
    case head <> tail:quarantine_cons(head,quarantines_count(tail))
def identity(value:String) -> String:
  value
def receipts_complete(+errors:List<&2,W.WorldError>,inverseObserved:List<(W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat,returnedObserved:List<Bundle.Packet> & List<&2,String>,quarantineObserved:List<QuarantineReceipt> & Nat) -> Receipts & String:
  (inverses,ic)=inverseObserved
  (returned,rt)=returnedObserved
  (quarantines,qc)=quarantineObserved
  (Receipts{inverses,returned,errors,quarantines},"inverses=" ++ Nat.show(ic) ++ ";returned=" ++ List.show(&2,String,identity,rt) ++ ";errors=" ++ List.show(&2,W.WorldError,world_error,errors) ++ ";quarantines=" ++ Nat.show(qc))
def receipts_view(returned:List<Bundle.Packet>,errors:List<&2,W.WorldError>,quarantines:List<QuarantineReceipt>,observed:List<(W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32> -> Install.Restore<W.World<Bundle.AuditWorkshop,Bundle.Store,Resources(),U32>,Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat) -> Receipts & String:
  receipts_complete(errors,observed,packets_view(returned),quarantines_count(quarantines))
def resource_join(left:Array<U32> & String,right:Array<U32> & String,receipts:Receipts & String) -> Resources() & String:
  (counter,sc)=left
  (sibling,ss)=right
  (receipts,sr)=receipts
  (Product.Owner{counter,Product.Owner{sibling,receipts}},"Counter=" ++ sc ++ ";Sibling=" ++ ss ++ ";receipts=" ++ sr)
def resource_view(value:Resources()) -> Resources() & String:
  match value:
    case Product.Owner{counter,Product.Owner{sibling,Receipts{inverses,returned,errors,quarantines}}}:resource_join(Dump.u32_array(counter),Dump.u32_array(sibling),receipts_view(returned,errors,quarantines,inverse_count(inverses)))
