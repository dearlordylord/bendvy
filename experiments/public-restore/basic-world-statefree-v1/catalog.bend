import Base
import model.bend as F
import events.bend as Event
import ../../../src/ecs/restore-data.bend as Change
import ../../../src/ecs/restore-events.bend as RestoreEvents
import ../../../src/ecs/owned-event-family-catalog.bend as Catalog
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/event-stream.bend as Stream
import ../../../src/ecs/event-publication.bend as Publication
def DrainReceipt() -> Type:Product.Owner<List<Log.Row<Array<U32>>>,Unit>
def catalog_retain(~S:Data) -> (F.Logs() -> List<&2,F.Events(~S)> -> F.Logs() & DrainReceipt()):Catalog.pair_retain(~Nat,~Change.Change<S>,~Log.Log<Array<U32>>,~Unit,~List<Log.Row<Array<U32>>>,~Unit,~Log.retain(~Array<U32>),~RestoreEvents.data_retain(~Change.Change<S>))
def catalog_drain() -> (F.Logs() -> F.Logs() & DrainReceipt()):Catalog.pair_drain(~Log.Log<Array<U32>>,~Unit,~List<Log.Row<Array<U32>>>,~Unit,~Log.drain(~Array<U32>),~RestoreEvents.data_drain)
def catalog_clear(~S:Data) -> (Event.FamilyOwner(~S) -> Event.FamilyOwner(~S)):Catalog.pair_clear(~Stream.Stream<S,Nat>,~Stream.Stream<S,Change.Change<S>>,~Catalog.leaf_clear(~S),~RestoreEvents.data_clear(~S,~Change.Change<S>))
def catalog(~S:Data) -> Catalog.Catalog<F.Events(~S),F.Logs(),Event.FamilyOwner(~S),DrainReceipt(),catalog_retain(~S),catalog_drain(),catalog_clear(~S)>:Catalog.both(~Nat,~Log.Log<Array<U32>>,~Stream.Stream<S,Nat>,~List<Log.Row<Array<U32>>>,~Log.retain(~Array<U32>),~Log.drain(~Array<U32>),~Catalog.leaf_clear(~S),~Change.Change<S>,~Unit,~Stream.Stream<S,Change.Change<S>>,~Unit,~RestoreEvents.data_retain(~Change.Change<S>),~RestoreEvents.data_drain,~RestoreEvents.data_clear(~S,~Change.Change<S>),~Catalog.leaf(~S,~Array<U32>),~RestoreEvents.data_catalog(~S,~Change.Change<S>,Event.lifecycle(~S)))
def emit(~S:Data,change:Change.Change<S>) -> F.Events(~S):Publication.Publication{[],[change]}
