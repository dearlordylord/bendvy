import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ./storage.bend as Storage
import ./owner-view.bend as Owner

# Read the physical slots of every allocated id, including dead/reserved ids.
# This observation retains all three affine columns exactly.
type EntityCells is Data:
  EntityCells{id: U32,position: Maybe<&2,Owner.FullCell>,velocity: Maybe<&2,Owner.FullCell>,health: Maybe<&2,Owner.FullCell>}
def health_viewed(~S: Data,id: U32,position: Col.Column<S,Array<U32>>,velocity: Col.Column<S,Array<U32>>,p: Maybe<&2,Owner.FullCell>,v: Maybe<&2,Owner.FullCell>,observed: Col.Column<S,Array<U32>> & Maybe<&2,Owner.FullCell>) -> Storage.Store<S> & EntityCells:
  match observed:
    case (health,h): (Storage.Store{position,velocity,health},EntityCells{id,p,v,h})
def velocity_viewed(~S: Data,+id: U32,position: Col.Column<S,Array<U32>>,health: Col.Column<S,Array<U32>>,p: Maybe<&2,Owner.FullCell>,observed: Col.Column<S,Array<U32>> & Maybe<&2,Owner.FullCell>) -> Storage.Store<S> & EntityCells:
  match observed:
    case (velocity,v): health_viewed(~S,id,position,velocity,p,v,Col.view(~S,~Array<U32>,~Owner.FullCell,~Owner.view,health,id))
def position_viewed(~S: Data,+id: U32,velocity: Col.Column<S,Array<U32>>,health: Col.Column<S,Array<U32>>,observed: Col.Column<S,Array<U32>> & Maybe<&2,Owner.FullCell>) -> Storage.Store<S> & EntityCells:
  match observed:
    case (position,p): velocity_viewed(~S,id,position,health,p,Col.view(~S,~Array<U32>,~Owner.FullCell,~Owner.view,velocity,id))
def entity(~S: Data,+id: U32,store: Storage.Store<S>) -> Storage.Store<S> & EntityCells:
  match store:
    case Storage.Store{position,velocity,health}: position_viewed(~S,id,velocity,health,Col.view(~S,~Array<U32>,~Owner.FullCell,~Owner.view,position,id))
def collected_head(~S: Data,head: EntityCells,observed: Storage.Store<S> & List<&2,EntityCells>) -> Storage.Store<S> & List<&2,EntityCells>:
  match observed:
    case (store,tail): (store,head <> tail)
def collected_next(~S: Data,next: Storage.Store<S> -> Storage.Store<S> & List<&2,EntityCells>,observed: Storage.Store<S> & EntityCells) -> Storage.Store<S> & List<&2,EntityCells>:
  match observed:
    case (store,head): collected_head(~S,head,next(store))
def allocated(~S: Data,count: Nat,+id: U32,store: Storage.Store<S>) -> Storage.Store<S> & List<&2,EntityCells>:
  match count:
    case 0n: (store,[])
    case 1n+rest: collected_next(~S,(store => allocated(~S,rest,(id + 1 : U32),store)),entity(~S,id,store))
