import Base
import ./ordinary-owned-event-family-reader-binding.bend as Setup
import ./ordinary-owned-event-binding.bend as Binding
import ./ordinary-owned-event.bend as Pub
import ./owned-event-log.bend as Log
import ./owned-event-key-route.bend as KeyRoute
import ./ordinary-event-family.bend as Family
import ./owner-product.bend as Product
import ./event-publication.bend as Publication
import ./ordinary-event-declaration.bend as Declaration
import ./owned-event-family-catalog.bend as Catalog
import ./event-stream.bend as Stream

# A Data event family has no affine log owner to drain. Its ordinary domain
# supplies the same nominal stream used by setup/readers and catalog composition.
def data_retain(~E:Data,unit:Unit,records:List<&2,E>) -> Unit & Unit:
  (unit,Unit{})
def data_drain(unit:Unit) -> Unit & Unit:
  (unit,Unit{})
def data_clear(~S:Data,~E:Data,stream:Stream.Stream<S,E>) -> Stream.Stream<S,E>:
  match stream:
    case Stream.Stream{domain,_,positions,nextReader,frameStart,boundary,capacity,dropped}:Stream.Stream{domain,[],positions,nextReader,frameStart,boundary,capacity,dropped}
def data_catalog(~S:Data,~E:Data,domain:Declaration.Domain<S,E>) -> Catalog.Catalog<E,Unit,Stream.Stream<S,E>,Unit,data_retain(~E),data_drain,data_clear(~S,~E)>:
  Catalog.Catalog{}
def MixedSetup(~S:Data,~P:Type,~E:Data,~identity:Pub.Domain<S,P>) -> Data:
  Setup.Setup<S,Product.Owner<Log.Log<P>,Unit>,P,Unit & Unit,Publication.Publication<Nat,E>,Family.Domains<Declaration.Domain<S,Nat>,Declaration.Domain<S,E>>,Product.Owner<Stream.Stream<S,Nat>,Stream.Stream<S,E>>,Binding.left_path(~Log.Log<P>,~Unit,~P,~Unit,~Binding.identity_lens(~Log.Log<P>)),KeyRoute.inject_left(~Nat,~E,~KeyRoute.inject_leaf),KeyRoute.select_left(~Nat,~E,~KeyRoute.select_leaf),identity,Family.node_make(~Declaration.Domain<S,Nat>,~Declaration.Domain<S,E>,~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.leaf_make(~S,~Nat),~Family.leaf_make(~S,~E)),Family.node_sync(~Nat,~E,~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.leaf_sync(~S,~Nat),~Family.leaf_sync(~S,~E)),Family.node_frame(~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.leaf_frame(~S,~Nat),~Family.leaf_frame(~S,~E)),Family.pair_retain(~Nat,~E,~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.leaf_retain(~S,~Nat),~Family.leaf_retain(~S,~E)),Family.pair_inventory(~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.leaf_inventory(~S,~Nat),~Family.leaf_inventory(~S,~E)),Family.left_take(~S,~Nat,~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.selected_leaf(~S,~Nat)),Family.left_put(~S,~Nat,~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.replaced_leaf(~S,~Nat))>
def with_data(~S:Data,~P:Type,~E:Data,~identity:Pub.Domain<S,P>,domain:Declaration.Domain<S,E>) -> MixedSetup(~S,~P,~E,~identity):
  Setup.Setup{Binding.left(~S,~Log.Log<P>,~Unit,~P,~Unit,~Nat,~E,~Binding.identity_lens(~Log.Log<P>),~KeyRoute.inject_leaf,~KeyRoute.select_leaf,~identity,Binding.leaf(~S,~P,~identity)),Family.branch(~S,~Nat,~E,~Declaration.Domain<S,Nat>,~Declaration.Domain<S,E>,~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.leaf_make(~S,~Nat),~Family.leaf_make(~S,~E),~Family.leaf_sync(~S,~Nat),~Family.leaf_sync(~S,~E),~Family.leaf_frame(~S,~Nat),~Family.leaf_frame(~S,~E),~Family.leaf_retain(~S,~Nat),~Family.leaf_retain(~S,~E),~Family.leaf_inventory(~S,~Nat),~Family.leaf_inventory(~S,~E),Family.leaf(~S,~Nat,Setup.domain(~S,~P,identity)),Family.leaf(~S,~E,domain)),Family.select_left(~S,~Nat,~Stream.Stream<S,Nat>,~Stream.Stream<S,E>,~Family.selected_leaf(~S,~Nat),~Family.replaced_leaf(~S,~Nat),Family.select_leaf(~S,~Nat))}
