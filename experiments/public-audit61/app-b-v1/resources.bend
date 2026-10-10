import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import graph-dump.bend as GraphDump
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
  Receipts{inverses:List<(Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)>,returned:List<Bundle.Packet>,errors:List<&2,W.WorldError>,quarantines:List<QuarantineReceipt>}
def Resources() -> Type:
  Product.Owner<PhaseSlot(),Product.Owner<Array<U32>,Receipts>>
type PhaseToken is Data:
  PhaseToken{}
def PhaseSlot() -> Data: M.Slot<Bundle.Scene,PhaseToken,U32>
def initial() -> Resources():
  Product.Owner{M.Present{1,M.Queued{2,False{}},None{},False{}},Product.Owner{ANode{ALeaf{100},ALeaf{101}},Receipts{[],[],[],[]}}}
def phase(resources:Resources()) -> Resources() & PhaseSlot():
  match resources:
    case Product.Owner{+slot,rest}: (Product.Owner{slot,rest},slot)
def counted_inverse(inverse:Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>,rest:List<(Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat) -> List<(Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat:
  match rest:
    case (tail,n):(inverse <> tail,1n+n)
def inverse_count(values:List<(Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)>) -> List<(Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat:
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
def receipts_complete(+errors:List<&2,W.WorldError>,inverseObserved:List<(Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat,returnedObserved:List<Bundle.Packet> & List<&2,String>,quarantineObserved:List<QuarantineReceipt> & Nat) -> Receipts & String:
  (inverses,ic)=inverseObserved
  (returned,rt)=returnedObserved
  (quarantines,qc)=quarantineObserved
  (Receipts{inverses,returned,errors,quarantines},"inverses=" ++ Nat.show(ic) ++ ";returned=" ++ List.show(&2,String,identity,rt) ++ ";errors=" ++ List.show(&2,W.WorldError,world_error,errors) ++ ";quarantines=" ++ Nat.show(qc))
def receipts_view(returned:List<Bundle.Packet>,errors:List<&2,W.WorldError>,quarantines:List<QuarantineReceipt>,observed:List<(Bundle.World(Resources()) -> Install.Restore<Bundle.World(Resources()),Bundle.Entries(),Bundle.RecipeRecovery(Resources())>)> & Nat) -> Receipts & String:
  receipts_complete(errors,observed,packets_view(returned),quarantines_count(quarantines))
def phase_view(+slot:PhaseSlot()) -> PhaseSlot() & String:
  (slot,GraphDump.slot(~Bundle.Scene,~PhaseToken,slot))
def resource_join(left:PhaseSlot() & String,right:Array<U32> & String,receipts:Receipts & String) -> Resources() & String:
  (counter,sc)=left
  (sibling,ss)=right
  (receipts,sr)=receipts
  (Product.Owner{counter,Product.Owner{sibling,receipts}},"Phase=" ++ sc ++ ";Sibling=" ++ ss ++ ";receipts=" ++ sr)
def resource_view(value:Resources()) -> Resources() & String:
  match value:
    case Product.Owner{counter,Product.Owner{sibling,Receipts{inverses,returned,errors,quarantines}}}:resource_join(phase_view(counter),Dump.u32_array(sibling),receipts_view(returned,errors,quarantines,inverse_count(inverses)))
