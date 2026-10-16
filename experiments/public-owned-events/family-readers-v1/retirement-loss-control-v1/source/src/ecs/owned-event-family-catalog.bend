import Base
import ./owned-event-log.bend as Log
import ./event-stream.bend as Stream
import ./event-publication.bend as Publication
import ./owner-product.bend as Product

# Trusted raw descriptor. Ordinary leaf/both derive complete matching log/stream trees.
type Catalog<E:Data,Logs:Type,F:Type,Receipt:Type,-retain:Logs -> List<&2,E> -> Logs & Receipt,-drain:Logs -> Logs & Receipt,-clear:F -> F> is Data:Catalog{}
def leaf_clear(~S:Data,stream:Stream.Stream<S,Nat>) -> Stream.Stream<S,Nat>:
  match stream:
    case Stream.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream.Stream{domain,[],positions,nextReader,frameStart,boundary,capacity,dropped}
def leaf(~S:Data,~P:Type) -> Catalog<Nat,Log.Log<P>,Stream.Stream<S,Nat>,List<Log.Row<P>>,Log.retain(~P),Log.drain(~P),leaf_clear(~S)>:Catalog{}
def joined(~LA:Type,~LB:Type,~RA:Type,~RB:Type,first:LA & RA,second:LB & RB) -> Product.Owner<LA,LB> & Product.Owner<RA,RB>:
  (first,receiptA)=first
  (second,receiptB)=second
  (Product.Owner{first,second},Product.Owner{receiptA,receiptB})
def pair_retain(~EA:Data,~EB:Data,~LA:Type,~LB:Type,~RA:Type,~RB:Type,~retainA:LA -> List<&2,EA> -> LA & RA,~retainB:LB -> List<&2,EB> -> LB & RB,logs:Product.Owner<LA,LB>,records:List<&2,Publication.Publication<EA,EB>>) -> Product.Owner<LA,LB> & Product.Owner<RA,RB>:
  match logs:
    case Product.Owner{first,second}:
      +shared=records
      joined(~LA,~LB,~RA,~RB,retainA(first,Publication.first_values(~EA,~EB,shared)),retainB(second,Publication.second_values(~EA,~EB,shared)))
def pair_drain(~LA:Type,~LB:Type,~RA:Type,~RB:Type,~drainA:LA -> LA & RA,~drainB:LB -> LB & RB,logs:Product.Owner<LA,LB>) -> Product.Owner<LA,LB> & Product.Owner<RA,RB>:
  match logs:
    case Product.Owner{first,second}:joined(~LA,~LB,~RA,~RB,drainA(first),drainB(second))
def pair_clear(~FA:Type,~FB:Type,~clearA:FA -> FA,~clearB:FB -> FB,family:Product.Owner<FA,FB>) -> Product.Owner<FA,FB>:
  match family:
    case Product.Owner{first,second}:Product.Owner{clearA(first),clearB(second)}
def both(~EA:Data,~LA:Type,~FA:Type,~RA:Type,~retainA:LA -> List<&2,EA> -> LA & RA,~drainA:LA -> LA & RA,~clearA:FA -> FA,~EB:Data,~LB:Type,~FB:Type,~RB:Type,~retainB:LB -> List<&2,EB> -> LB & RB,~drainB:LB -> LB & RB,~clearB:FB -> FB,~leftCatalog:Catalog<EA,LA,FA,RA,retainA,drainA,clearA>,~rightCatalog:Catalog<EB,LB,FB,RB,retainB,drainB,clearB>) -> Catalog<Publication.Publication<EA,EB>,Product.Owner<LA,LB>,Product.Owner<FA,FB>,Product.Owner<RA,RB>,pair_retain(~EA,~EB,~LA,~LB,~RA,~RB,~retainA,~retainB),pair_drain(~LA,~LB,~RA,~RB,~drainA,~drainB),pair_clear(~FA,~FB,~clearA,~clearB)>:Catalog{}
