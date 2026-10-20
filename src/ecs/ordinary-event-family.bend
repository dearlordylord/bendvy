import Base
import owner-product.bend as Product
import ordinary-event-declaration.bend as Event
import event-runtime.bend as Ev
import event-stream.bend as Leaf
import event-publication.bend as Publication

# Builder domains are operational declarations, not a second metadata list.
# Detached left/right domain declarations for a heterogeneous event family.
# Their nested shape matches the publication and storage product, not live readers.
type Domains<A:Data,B:Data> is Data:Domains{first:A,second:B}
# Typed family setup containing ordinary domains and closed storage/routing
# operations. Runtime streams are constructed separately; this declaration
# supplies no live cursor or affine payload. Raw constructors are trusted setup.
# Family construction and reader lifecycle: docs/parity/typed-data-events.md.
type Provision<S:Data,P:Data,D:Data,F:Type,-make:D -> Nat -> F,-sync:F -> Nat -> List<&2,P> -> F,-frame:F -> Nat -> F,-retain:F -> Nat -> List<&2,P> -> F & List<&2,P>,-inventory:F -> F & List<&2,String>> is Data:
  Provision{domains:D}
def leaf_make(~S:Data,~E:Data,domain:Event.Domain<S,E>,capacity:Nat) -> Leaf.Stream<S,E>:Leaf.provision(~S,~E,domain,capacity)
def leaf_sync(~S:Data,~E:Data,stream:Leaf.Stream<S,E>,tick:Nat,values:List<&2,E>) -> Leaf.Stream<S,E>:Leaf.append(~S,~E,stream,tick,values)
def leaf_frame(~S:Data,~E:Data,stream:Leaf.Stream<S,E>,tick:Nat) -> Leaf.Stream<S,E>:Leaf.frame(~S,~E,stream,tick)
def leaf_retained(~S:Data,~E:Data,stream:Leaf.Stream<S,E>,remove:Bool,values:List<&2,E>) -> Leaf.Stream<S,E> & List<&2,E>:
  match remove:
    case False{}:(stream,values)
    case True{}:(stream,[])
def leaf_retain(~S:Data,~E:Data,stream:Leaf.Stream<S,E>,tick:Nat,values:List<&2,E>) -> Leaf.Stream<S,E> & List<&2,E>:
  +retained=stream
  leaf_retained(~S,~E,retained,Nat.is_le(tick,Leaf.dropped(~S,~E,retained)),values)
def leaf_inventory(~S:Data,~E:Data,stream:Leaf.Stream<S,E>) -> Leaf.Stream<S,E> & List<&2,String>:
  +retained=stream
  (retained,[Leaf.inventory(~S,~E,retained)])
# Declare one Data event family leaf from its schema-scoped domain. The
# resulting provision supplies stream creation, synchronization and retention
# operations, but does not create a stream until runtime setup invokes make.
# Example: Family.leaf(~S,~E,Event.domain(~S,~E,"hit")).
def leaf(~S:Data,~E:Data,domain:Event.Domain<S,E>) -> Provision<S,E,Event.Domain<S,E>,Leaf.Stream<S,E>,leaf_make(~S,~E),leaf_sync(~S,~E),leaf_frame(~S,~E),leaf_retain(~S,~E),leaf_inventory(~S,~E)>:Provision{domain}
def pair_make(~DA:Data,~DB:Data,~FA:Type,~FB:Type,~makeA:DA -> Nat -> FA,~makeB:DB -> Nat -> FB,domains:Domains<DA,DB>,+capacity:Nat) -> Product.Owner<FA,FB>:
  match domains:
    case Domains{first,second}:Product.Owner{makeA(first,capacity),makeB(second,capacity)}
def pair_sync(~A:Data,~B:Data,~FA:Type,~FB:Type,~syncA:FA -> Nat -> List<&2,A> -> FA,~syncB:FB -> Nat -> List<&2,B> -> FB,family:Product.Owner<FA,FB>,+tick:Nat,+records:List<&2,Publication.Publication<A,B>>) -> Product.Owner<FA,FB>:
  match family:
    case Product.Owner{first,second}:Product.Owner{syncA(first,tick,Publication.first_values(~A,~B,records)),syncB(second,tick,Publication.second_values(~A,~B,records))}
def pair_frame(~FA:Type,~FB:Type,~frameA:FA -> Nat -> FA,~frameB:FB -> Nat -> FB,family:Product.Owner<FA,FB>,+tick:Nat) -> Product.Owner<FA,FB>:
  match family:
    case Product.Owner{first,second}:Product.Owner{frameA(first,tick),frameB(second,tick)}
def pair_inventory_join(~FA:Type,~FB:Type,first:FA & List<&2,String>,second:FB & List<&2,String>) -> Product.Owner<FA,FB> & List<&2,String>:
  (first,firstNames)=first
  (second,secondNames)=second
  (Product.Owner{first,second},Ev.append(~String,firstNames,secondNames))
def pair_inventory(~FA:Type,~FB:Type,~inventoryA:FA -> FA & List<&2,String>,~inventoryB:FB -> FB & List<&2,String>,family:Product.Owner<FA,FB>) -> Product.Owner<FA,FB> & List<&2,String>:
  match family:
    case Product.Owner{first,second}:pair_inventory_join(~FA,~FB,inventoryA(first),inventoryB(second))
def retained_tail(~A:Data,~B:Data,~F:Type,record:Publication.Publication<A,B>,returned:F & List<&2,Publication.Publication<A,B>>) -> F & List<&2,Publication.Publication<A,B>>:
  match returned:
    case (family,rest):(family,Publication.retained_join(~A,~B,record,rest))
def retained_children(~A:Data,~B:Data,~FA:Type,~FB:Type,rest:Product.Owner<FA,FB> -> Product.Owner<FA,FB> & List<&2,Publication.Publication<A,B>>,first:FA & List<&2,A>,second:FB & List<&2,B>) -> Product.Owner<FA,FB> & List<&2,Publication.Publication<A,B>>:
  (first,firstValues)=first
  (second,secondValues)=second
  retained_tail(~A,~B,~Product.Owner<FA,FB>,Publication.Publication{firstValues,secondValues},rest(Product.Owner{first,second}))
def retained_record(~A:Data,~B:Data,~FA:Type,~FB:Type,~retainA:FA -> Nat -> List<&2,A> -> FA & List<&2,A>,~retainB:FB -> Nat -> List<&2,B> -> FB & List<&2,B>,rest:Product.Owner<FA,FB> -> Product.Owner<FA,FB> & List<&2,Publication.Publication<A,B>>,+tick:Nat,record:Publication.Publication<A,B>,family:Product.Owner<FA,FB>) -> Product.Owner<FA,FB> & List<&2,Publication.Publication<A,B>>:
  match record family:
    case Publication.Publication{a,b} Product.Owner{first,second}:retained_children(~A,~B,~FA,~FB,rest,retainA(first,tick,a),retainB(second,tick,b))
def retained_one_children(~A:Data,~B:Data,~FA:Type,~FB:Type,first:FA & List<&2,A>,second:FB & List<&2,B>) -> Product.Owner<FA,FB> & Publication.Publication<A,B>:
  (first,firstValues)=first
  (second,secondValues)=second
  (Product.Owner{first,second},Publication.Publication{firstValues,secondValues})
def retained_one(~A:Data,~B:Data,~FA:Type,~FB:Type,~retainA:FA -> Nat -> List<&2,A> -> FA & List<&2,A>,~retainB:FB -> Nat -> List<&2,B> -> FB & List<&2,B>,+tick:Nat,record:Publication.Publication<A,B>,family:Product.Owner<FA,FB>) -> Product.Owner<FA,FB> & Publication.Publication<A,B>:
  match record family:
    case Publication.Publication{a,b} Product.Owner{first,second}:retained_one_children(~A,~B,~FA,~FB,retainA(first,tick,a),retainB(second,tick,b))
def pair_retain_acc(~A:Data,~B:Data,~FA:Type,~FB:Type,~retainA:FA -> Nat -> List<&2,A> -> FA & List<&2,A>,~retainB:FB -> Nat -> List<&2,B> -> FB & List<&2,B>,records:List<&2,Publication.Publication<A,B>>,returned:Product.Owner<FA,FB> & Publication.Publication<A,B>,+tick:Nat,reversed:List<&2,Publication.Publication<A,B>>) -> Product.Owner<FA,FB> & List<&2,Publication.Publication<A,B>>:
  match records:
    case []:
      (family,record)=returned
      (family,List.reverse(&2,Publication.Publication<A,B>,Publication.retained_join(~A,~B,record,reversed)))
    case head <> rest:
      (family,record)=returned
      pair_retain_acc(~A,~B,~FA,~FB,~retainA,~retainB,rest,retained_one(~A,~B,~FA,~FB,~retainA,~retainB,tick,head,family),tick,Publication.retained_join(~A,~B,record,reversed))
def pair_retain_loop(~A:Data,~B:Data,~FA:Type,~FB:Type,~retainA:FA -> Nat -> List<&2,A> -> FA & List<&2,A>,~retainB:FB -> Nat -> List<&2,B> -> FB & List<&2,B>,records:List<&2,Publication.Publication<A,B>>,family:Product.Owner<FA,FB>,+tick:Nat) -> Product.Owner<FA,FB> & List<&2,Publication.Publication<A,B>>:
  match records:
    case []:(family,[])
    case record <> rest:pair_retain_acc(~A,~B,~FA,~FB,~retainA,~retainB,rest,retained_one(~A,~B,~FA,~FB,~retainA,~retainB,tick,record,family),tick,[])
def pair_retain(~A:Data,~B:Data,~FA:Type,~FB:Type,~retainA:FA -> Nat -> List<&2,A> -> FA & List<&2,A>,~retainB:FB -> Nat -> List<&2,B> -> FB & List<&2,B>,family:Product.Owner<FA,FB>,tick:Nat,records:List<&2,Publication.Publication<A,B>>) -> Product.Owner<FA,FB> & List<&2,Publication.Publication<A,B>>:
  pair_retain_loop(~A,~B,~FA,~FB,~retainA,~retainB,records,family,tick)

def node_make(~DA:Data,~DB:Data,~FA:Type,~FB:Type,~makeA:DA -> Nat -> FA,~makeB:DB -> Nat -> FB,domains:Domains<DA,DB>,capacity:Nat) -> Product.Owner<FA,FB>:pair_make(~DA,~DB,~FA,~FB,~makeA,~makeB,domains,capacity)
def node_sync(~A:Data,~B:Data,~FA:Type,~FB:Type,~syncA:FA -> Nat -> List<&2,A> -> FA,~syncB:FB -> Nat -> List<&2,B> -> FB,family:Product.Owner<FA,FB>,tick:Nat,records:List<&2,Publication.Publication<A,B>>) -> Product.Owner<FA,FB>:pair_sync(~A,~B,~FA,~FB,~syncA,~syncB,family,tick,records)
def node_frame(~FA:Type,~FB:Type,~frameA:FA -> Nat -> FA,~frameB:FB -> Nat -> FB,family:Product.Owner<FA,FB>,tick:Nat) -> Product.Owner<FA,FB>:pair_frame(~FA,~FB,~frameA,~frameB,family,tick)
# Compose two event provisions under the same schema in left/right order.
# Publication wrappers and family storage become matching nested products;
# each leaf retains its own typed stream. Composition neither publishes records
# nor combines independent reader cursors into one. Nest branches for more types.
def branch(~S:Data,~A:Data,~B:Data,~DA:Data,~DB:Data,~FA:Type,~FB:Type,~makeA:DA -> Nat -> FA,~makeB:DB -> Nat -> FB,~syncA:FA -> Nat -> List<&2,A> -> FA,~syncB:FB -> Nat -> List<&2,B> -> FB,~frameA:FA -> Nat -> FA,~frameB:FB -> Nat -> FB,~retainA:FA -> Nat -> List<&2,A> -> FA & List<&2,A>,~retainB:FB -> Nat -> List<&2,B> -> FB & List<&2,B>,~inventoryA:FA -> FA & List<&2,String>,~inventoryB:FB -> FB & List<&2,String>,first:Provision<S,A,DA,FA,makeA,syncA,frameA,retainA,inventoryA>,second:Provision<S,B,DB,FB,makeB,syncB,frameB,retainB,inventoryB>) -> Provision<S,Publication.Publication<A,B>,Domains<DA,DB>,Product.Owner<FA,FB>,node_make(~DA,~DB,~FA,~FB,~makeA,~makeB),node_sync(~A,~B,~FA,~FB,~syncA,~syncB),node_frame(~FA,~FB,~frameA,~frameB),pair_retain(~A,~B,~FA,~FB,~retainA,~retainB),pair_inventory(~FA,~FB,~inventoryA,~inventoryB)>:
  match first second:
    case Provision{first} Provision{second}:Provision{Domains{first,second}}

# Typed path to one event stream in a family, with owner-threading take/put
# operations. This Data path owns no stream or reader; raw indices are trusted
# setup. Equal payload types do not justify substituting unrelated family paths.
type Selection<S:Data,E:Data,F:Type,-take:F -> F & Leaf.Stream<S,E>,-put:F -> Leaf.Stream<S,E> -> F> is Data:Selection{}
def selected_leaf(~S:Data,~E:Data,stream:Leaf.Stream<S,E>) -> Leaf.Stream<S,E> & Leaf.Stream<S,E>:
  +retained=stream
  (retained,retained)
def replaced_leaf(~S:Data,~E:Data,_:Leaf.Stream<S,E>,stream:Leaf.Stream<S,E>) -> Leaf.Stream<S,E>:stream
# Select a stream that is itself the complete family owner. The selection
# records closed extraction/replacement operations and performs neither here.
def select_leaf(~S:Data,~E:Data) -> Selection<S,E,Leaf.Stream<S,E>,selected_leaf(~S,~E),replaced_leaf(~S,~E)>:Selection{}
def selected_left(~S:Data,~E:Data,~FA:Type,~FB:Type,second:FB,returned:FA & Leaf.Stream<S,E>) -> Product.Owner<FA,FB> & Leaf.Stream<S,E>:
  match returned:
    case (first,stream):(Product.Owner{first,second},stream)
def left_take(~S:Data,~E:Data,~FA:Type,~FB:Type,~take:FA -> FA & Leaf.Stream<S,E>,family:Product.Owner<FA,FB>) -> Product.Owner<FA,FB> & Leaf.Stream<S,E>:
  match family:
    case Product.Owner{first,second}:selected_left(~S,~E,~FA,~FB,second,take(first))
def left_put(~S:Data,~E:Data,~FA:Type,~FB:Type,~put:FA -> Leaf.Stream<S,E> -> FA,family:Product.Owner<FA,FB>,stream:Leaf.Stream<S,E>) -> Product.Owner<FA,FB>:
  match family:
    case Product.Owner{first,second}:Product.Owner{put(first,stream),second}
def selected_right(~S:Data,~E:Data,~FA:Type,~FB:Type,first:FA,returned:FB & Leaf.Stream<S,E>) -> Product.Owner<FA,FB> & Leaf.Stream<S,E>:
  match returned:
    case (second,stream):(Product.Owner{first,second},stream)
def right_take(~S:Data,~E:Data,~FA:Type,~FB:Type,~take:FB -> FB & Leaf.Stream<S,E>,family:Product.Owner<FA,FB>) -> Product.Owner<FA,FB> & Leaf.Stream<S,E>:
  match family:
    case Product.Owner{first,second}:selected_right(~S,~E,~FA,~FB,first,take(second))
def right_put(~S:Data,~E:Data,~FA:Type,~FB:Type,~put:FB -> Leaf.Stream<S,E> -> FB,family:Product.Owner<FA,FB>,stream:Leaf.Stream<S,E>) -> Product.Owner<FA,FB>:
  match family:
    case Product.Owner{first,second}:Product.Owner{first,put(second,stream)}
# Lift a leaf selection through the left side of a family product.
# The generated path preserves the right sibling when accessing/replacing
# the selected stream; it does not allocate or advance a reader.
def select_left(~S:Data,~E:Data,~FA:Type,~FB:Type,~take:FA -> FA & Leaf.Stream<S,E>,~put:FA -> Leaf.Stream<S,E> -> FA,_:Selection<S,E,FA,take,put>) -> Selection<S,E,Product.Owner<FA,FB>,left_take(~S,~E,~FA,~FB,~take),left_put(~S,~E,~FA,~FB,~put)>:Selection{}
# Lift a leaf selection through the right side of a family product,
# preserving the left sibling. Compose paths to address nested families.
def select_right(~S:Data,~E:Data,~FA:Type,~FB:Type,~take:FB -> FB & Leaf.Stream<S,E>,~put:FB -> Leaf.Stream<S,E> -> FB,_:Selection<S,E,FB,take,put>) -> Selection<S,E,Product.Owner<FA,FB>,right_take(~S,~E,~FA,~FB,~take),right_put(~S,~E,~FA,~FB,~put)>:Selection{}
# Identity injection for a Data event in a leaf publication. Does not send
# it or establish a publication tick; runtime publication does that separately.
def inject_leaf(~E:Data,event:E) -> E:event
# Wrap one event on the left side of a heterogeneous publication with an
# empty right list. The closed inject callback embeds nested leaf shapes;
# this creates a Data publication value, without mutating any runtime stream.
def inject_left(~E:Data,~A:Data,~B:Data,~inject:E -> A,event:E) -> Publication.Publication<A,B>:Publication.Publication{[inject(event)],[]}
# Wrap one event on the right side of a heterogeneous publication with an
# empty left list. Retains the nested injection shape; does not publish or
# change a cursor until the runtime processes the resulting value.
def inject_right(~E:Data,~A:Data,~B:Data,~inject:E -> B,event:E) -> Publication.Publication<A,B>:Publication.Publication{[],[inject(event)]}
