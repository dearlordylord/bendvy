import Base
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/structural.bend as St
import ../../src/ecs/transaction.bend as T

type Schema is Data:
  Schema{}
type Stock is Type:
  Stock{value: U32,owned: Array<U32>,length: Nat}
type StockView is Data:
  StockView{value: U32,owned: List<&2,U32>}
type Recipe is Type:
  Recipe{value: U32,owned: Array<U32>,length: Nat}
type RecipeView is Data:
  RecipeView{value: U32,owned: List<&2,U32>}
type Queue is Type:
  Queue{value: U32,owned: Array<U32>,length: Nat}
type QueueView is Data:
  QueueView{value: U32,owned: List<&2,U32>}
type Enabled is Data:
  Enabled{}
type Locked is Data:
  Locked{}
type Notice is Data:
  Ping{value: U32}
  RemovedStock{handle: W.Handle<Schema>}
  RemovedAux{handle: W.Handle<Schema>}
  Gone{handle: W.Handle<Schema>}
type Store is Type:
  Store{stock: Col.Column<Schema,Stock>,recipe: Col.Column<Schema,Recipe>,queue: Col.Column<Schema,Queue>,enabled: Col.Column<Schema,Enabled>,locked: Col.Column<Schema,Locked>}
type StockToken is Data:
  StockToken{}
type StockRest is Type:
  StockRest{recipe: Col.Column<Schema,Recipe>,queue: Col.Column<Schema,Queue>,enabled: Col.Column<Schema,Enabled>,locked: Col.Column<Schema,Locked>}
def take_stock(store: Store) -> StockRest & Col.Column<Schema,Stock>:
  match store:
    case Store{stock,recipe,queue,enabled,locked}: (StockRest{recipe,queue,enabled,locked},stock)
def put_stock(rest: StockRest,column: Col.Column<Schema,Stock>) -> Store:
  match rest:
    case StockRest{recipe,queue,enabled,locked}: Store{column,recipe,queue,enabled,locked}
type RecipeToken is Data:
  RecipeToken{}
type RecipeRest is Type:
  RecipeRest{stock: Col.Column<Schema,Stock>,queue: Col.Column<Schema,Queue>,enabled: Col.Column<Schema,Enabled>,locked: Col.Column<Schema,Locked>}
def take_recipe(store: Store) -> RecipeRest & Col.Column<Schema,Recipe>:
  match store:
    case Store{stock,recipe,queue,enabled,locked}: (RecipeRest{stock,queue,enabled,locked},recipe)
def put_recipe(rest: RecipeRest,column: Col.Column<Schema,Recipe>) -> Store:
  match rest:
    case RecipeRest{stock,queue,enabled,locked}: Store{stock,column,queue,enabled,locked}
type QueueToken is Data:
  QueueToken{}
type QueueRest is Type:
  QueueRest{stock: Col.Column<Schema,Stock>,recipe: Col.Column<Schema,Recipe>,enabled: Col.Column<Schema,Enabled>,locked: Col.Column<Schema,Locked>}
def take_queue(store: Store) -> QueueRest & Col.Column<Schema,Queue>:
  match store:
    case Store{stock,recipe,queue,enabled,locked}: (QueueRest{stock,recipe,enabled,locked},queue)
def put_queue(rest: QueueRest,column: Col.Column<Schema,Queue>) -> Store:
  match rest:
    case QueueRest{stock,recipe,enabled,locked}: Store{stock,recipe,column,enabled,locked}
type EnabledToken is Data:
  EnabledToken{}
type EnabledRest is Type:
  EnabledRest{stock: Col.Column<Schema,Stock>,recipe: Col.Column<Schema,Recipe>,queue: Col.Column<Schema,Queue>,locked: Col.Column<Schema,Locked>}
def take_enabled(store: Store) -> EnabledRest & Col.Column<Schema,Enabled>:
  match store:
    case Store{stock,recipe,queue,enabled,locked}: (EnabledRest{stock,recipe,queue,locked},enabled)
def put_enabled(rest: EnabledRest,column: Col.Column<Schema,Enabled>) -> Store:
  match rest:
    case EnabledRest{stock,recipe,queue,locked}: Store{stock,recipe,queue,column,locked}
type LockedToken is Data:
  LockedToken{}
type LockedRest is Type:
  LockedRest{stock: Col.Column<Schema,Stock>,recipe: Col.Column<Schema,Recipe>,queue: Col.Column<Schema,Queue>,enabled: Col.Column<Schema,Enabled>}
def take_locked(store: Store) -> LockedRest & Col.Column<Schema,Locked>:
  match store:
    case Store{stock,recipe,queue,enabled,locked}: (LockedRest{stock,recipe,queue,enabled},locked)
def put_locked(rest: LockedRest,column: Col.Column<Schema,Locked>) -> Store:
  match rest:
    case LockedRest{stock,recipe,queue,enabled}: Store{stock,recipe,queue,enabled,column}
def World() -> Type:
  W.World<Schema,Store,Unit,Notice>
def Tx() -> Type:
  T.Tx<World(),Notice>
def array_join(left_view: Array<U32> & List<&2,U32>,right_view: Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (left,+xs) = left_view
  (right,+ys) = right_view
  (ANode{left,right},List.append(&2,U32,xs,ys))
def array_view(array: Array<U32>) -> Array<U32> & List<&2,U32>:
  match array:
    case ALeaf{+value}: (ALeaf{value},value <> [])
    case ANode{left,right}: array_join(array_view(left),array_view(right))
def prefix(fuel: Nat,xs: List<&2,U32>) -> List<&2,U32>:
  match fuel xs:
    case 0n xs: []
    case _ Nil{}: []
    case 1n+rest Con{+x,xs}: x <> prefix(rest,xs)
def fill(values: List<&2,U32>,+index: U32,array: Array<U32>) -> Array<U32>:
  match values:
    case []: array
    case +x <> rest: fill(rest,(index + 1 : U32),array[index] <- x)
# Runtime Arrays have power-of-two capacity; logical length exposes every
# payload cell and excludes padding. Capacity grows with the complete input.
type ArrayShape is Data:
  ArrayShape{capacity: Nat,depth: Nat,used: Nat}
def shape_choose(grow: Bool,+capacity: Nat,+depth: Nat,+used: Nat) -> ArrayShape:
  match grow:
    case True{}: ArrayShape{Nat.mul(2n,capacity),1n+depth,1n+used}
    case False{}: ArrayShape{capacity,depth,1n+used}
def shape_advance(shape: ArrayShape) -> ArrayShape:
  match shape:
    case ArrayShape{+capacity,+depth,+used}: shape_choose(Nat.is_eq(capacity,used),capacity,depth,used)
def shape(values: List<&2,U32>,current: ArrayShape) -> ArrayShape:
  match values:
    case []: current
    case _ <> rest: shape(rest,shape_advance(current))
def shape_depth(shape: ArrayShape) -> Nat:
  match shape:
    case ArrayShape{_,depth,_}: depth
def payload_array(+values: List<&2,U32>) -> Array<U32>:
  fill(values,0,Array.new(U32,shape_depth(shape(values,ArrayShape{1n,0n,0n})),0))
def project_stock_join(+value: U32,+length: Nat,observed: Array<U32> & List<&2,U32>) -> Stock & StockView:
  (array,+values) = observed
  (Stock{value,array,length},StockView{value,prefix(length,values)})
def project_stock(owner: Stock) -> Stock & StockView:
  match owner:
    case Stock{+value,array,+length}: project_stock_join(value,length,array_view(array))
def stock_owner(view: StockView) -> Stock:
  match view:
    case StockView{+value,+values}: Stock{value,payload_array(values),List.length(&2,U32,values)}
def stock_payload(+value: U32) -> Stock:
  Stock{value,payload_array([value,(value + 1 : U32),(value + 2 : U32)]),3n}
def stock() -> C.Family<Schema,Store,StockRest,Stock,StockView,StockToken,take_stock,put_stock,project_stock>:
  C.define(~Schema,~Store,~Unit,~Notice,~StockRest,~Stock,~StockView,~StockToken,~take_stock,~put_stock,~project_stock,"Stock")
def get_stock(world: World(),handle: W.Handle<Schema>) -> World() & C.Access<StockView>:
  C.get(~Schema,~Store,~Unit,~Notice,~StockRest,~Stock,~StockView,~StockToken,~take_stock,~put_stock,~project_stock,stock(),world,handle)
def project_recipe_join(+value: U32,+length: Nat,observed: Array<U32> & List<&2,U32>) -> Recipe & RecipeView:
  (array,+values) = observed
  (Recipe{value,array,length},RecipeView{value,prefix(length,values)})
def project_recipe(owner: Recipe) -> Recipe & RecipeView:
  match owner:
    case Recipe{+value,array,+length}: project_recipe_join(value,length,array_view(array))
def recipe_owner(view: RecipeView) -> Recipe:
  match view:
    case RecipeView{+value,+values}: Recipe{value,payload_array(values),List.length(&2,U32,values)}
def recipe_payload(+value: U32) -> Recipe:
  Recipe{value,payload_array([value,(value + 1 : U32),(value + 2 : U32)]),3n}
def recipe() -> C.Family<Schema,Store,RecipeRest,Recipe,RecipeView,RecipeToken,take_recipe,put_recipe,project_recipe>:
  C.define(~Schema,~Store,~Unit,~Notice,~RecipeRest,~Recipe,~RecipeView,~RecipeToken,~take_recipe,~put_recipe,~project_recipe,"Recipe")
def get_recipe(world: World(),handle: W.Handle<Schema>) -> World() & C.Access<RecipeView>:
  C.get(~Schema,~Store,~Unit,~Notice,~RecipeRest,~Recipe,~RecipeView,~RecipeToken,~take_recipe,~put_recipe,~project_recipe,recipe(),world,handle)
def project_queue_join(+value: U32,+length: Nat,observed: Array<U32> & List<&2,U32>) -> Queue & QueueView:
  (array,+values) = observed
  (Queue{value,array,length},QueueView{value,prefix(length,values)})
def project_queue(owner: Queue) -> Queue & QueueView:
  match owner:
    case Queue{+value,array,+length}: project_queue_join(value,length,array_view(array))
def queue_owner(view: QueueView) -> Queue:
  match view:
    case QueueView{+value,+values}: Queue{value,payload_array(values),List.length(&2,U32,values)}
def queue_payload(+value: U32) -> Queue:
  Queue{value,payload_array([value,(value + 1 : U32),(value + 2 : U32)]),3n}
def queue() -> C.Family<Schema,Store,QueueRest,Queue,QueueView,QueueToken,take_queue,put_queue,project_queue>:
  C.define(~Schema,~Store,~Unit,~Notice,~QueueRest,~Queue,~QueueView,~QueueToken,~take_queue,~put_queue,~project_queue,"Queue")
def get_queue(world: World(),handle: W.Handle<Schema>) -> World() & C.Access<QueueView>:
  C.get(~Schema,~Store,~Unit,~Notice,~QueueRest,~Queue,~QueueView,~QueueToken,~take_queue,~put_queue,~project_queue,queue(),world,handle)
def project_enabled(owner: Enabled) -> Enabled & Enabled:
  match owner:
    case Enabled{}: (Enabled{},Enabled{})
def enabled() -> C.Family<Schema,Store,EnabledRest,Enabled,Enabled,EnabledToken,take_enabled,put_enabled,project_enabled>:
  C.define(~Schema,~Store,~Unit,~Notice,~EnabledRest,~Enabled,~Enabled,~EnabledToken,~take_enabled,~put_enabled,~project_enabled,"Enabled")
def get_enabled(world: World(),handle: W.Handle<Schema>) -> World() & C.Access<Enabled>:
  C.get(~Schema,~Store,~Unit,~Notice,~EnabledRest,~Enabled,~Enabled,~EnabledToken,~take_enabled,~put_enabled,~project_enabled,enabled(),world,handle)
def project_locked(owner: Locked) -> Locked & Locked:
  match owner:
    case Locked{}: (Locked{},Locked{})
def locked() -> C.Family<Schema,Store,LockedRest,Locked,Locked,LockedToken,take_locked,put_locked,project_locked>:
  C.define(~Schema,~Store,~Unit,~Notice,~LockedRest,~Locked,~Locked,~LockedToken,~take_locked,~put_locked,~project_locked,"Locked")
def get_locked(world: World(),handle: W.Handle<Schema>) -> World() & C.Access<Locked>:
  C.get(~Schema,~Store,~Unit,~Notice,~LockedRest,~Locked,~Locked,~LockedToken,~take_locked,~put_locked,~project_locked,locked(),world,handle)
def empty_store(unit: Unit) -> Store:
  Store{Col.empty(~Schema,~Stock),Col.empty(~Schema,~Recipe),Col.empty(~Schema,~Queue),Col.empty(~Schema,~Enabled),Col.empty(~Schema,~Locked)}
def create(factory: W.Factory) -> W.Creation<Schema,Store,Unit,Notice>:
  W.create(~Schema,~Store,~Unit,~Notice,~empty_store,factory,Unit{})
type Bundle is Type:
  Bundle{stock: Maybe<&1,Stock>,recipe: Maybe<&1,Recipe>,queue: Maybe<&1,Queue>,enabled: Maybe<&1,Enabled>,locked: Maybe<&1,Locked>}
def replaced(~Owner: Type,result: C.Replacement<World(),Owner>) -> World():
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def queued(~Owner: Type,result: St.Queued<Tx(),Owner>) -> Tx():
  match result:
    case St.Queued{tx}: tx
    case St.QueueRejected{tx,_,_}: tx
def populate_stock(world: World(),handle: W.Handle<Schema>,incoming: Maybe<&1,Stock>) -> World():
  replaced(~Stock,C.structural_replace(~Schema,~Store,~Unit,~Notice,~StockRest,~Stock,~StockView,~StockToken,~take_stock,~put_stock,~project_stock,stock(),world,handle,incoming))
def queue_stock(tx: Tx(),handle: W.Handle<Schema>,incoming: Maybe<&1,Stock>) -> Tx():
  queued(~Stock,St.tx_replace(~Schema,~Store,~Unit,~Notice,~StockRest,~Stock,~StockView,~StockToken,~take_stock,~put_stock,~project_stock,stock(),tx,handle,incoming))
def populate_recipe(world: World(),handle: W.Handle<Schema>,incoming: Maybe<&1,Recipe>) -> World():
  replaced(~Recipe,C.structural_replace(~Schema,~Store,~Unit,~Notice,~RecipeRest,~Recipe,~RecipeView,~RecipeToken,~take_recipe,~put_recipe,~project_recipe,recipe(),world,handle,incoming))
def queue_recipe(tx: Tx(),handle: W.Handle<Schema>,incoming: Maybe<&1,Recipe>) -> Tx():
  queued(~Recipe,St.tx_replace(~Schema,~Store,~Unit,~Notice,~RecipeRest,~Recipe,~RecipeView,~RecipeToken,~take_recipe,~put_recipe,~project_recipe,recipe(),tx,handle,incoming))
def populate_queue(world: World(),handle: W.Handle<Schema>,incoming: Maybe<&1,Queue>) -> World():
  replaced(~Queue,C.structural_replace(~Schema,~Store,~Unit,~Notice,~QueueRest,~Queue,~QueueView,~QueueToken,~take_queue,~put_queue,~project_queue,queue(),world,handle,incoming))
def queue_queue(tx: Tx(),handle: W.Handle<Schema>,incoming: Maybe<&1,Queue>) -> Tx():
  queued(~Queue,St.tx_replace(~Schema,~Store,~Unit,~Notice,~QueueRest,~Queue,~QueueView,~QueueToken,~take_queue,~put_queue,~project_queue,queue(),tx,handle,incoming))
def populate_enabled(world: World(),handle: W.Handle<Schema>,incoming: Maybe<&1,Enabled>) -> World():
  replaced(~Enabled,C.structural_replace(~Schema,~Store,~Unit,~Notice,~EnabledRest,~Enabled,~Enabled,~EnabledToken,~take_enabled,~put_enabled,~project_enabled,enabled(),world,handle,incoming))
def queue_enabled(tx: Tx(),handle: W.Handle<Schema>,incoming: Maybe<&1,Enabled>) -> Tx():
  queued(~Enabled,St.tx_replace(~Schema,~Store,~Unit,~Notice,~EnabledRest,~Enabled,~Enabled,~EnabledToken,~take_enabled,~put_enabled,~project_enabled,enabled(),tx,handle,incoming))
def populate_locked(world: World(),handle: W.Handle<Schema>,incoming: Maybe<&1,Locked>) -> World():
  replaced(~Locked,C.structural_replace(~Schema,~Store,~Unit,~Notice,~LockedRest,~Locked,~Locked,~LockedToken,~take_locked,~put_locked,~project_locked,locked(),world,handle,incoming))
def queue_locked(tx: Tx(),handle: W.Handle<Schema>,incoming: Maybe<&1,Locked>) -> Tx():
  queued(~Locked,St.tx_replace(~Schema,~Store,~Unit,~Notice,~LockedRest,~Locked,~Locked,~LockedToken,~take_locked,~put_locked,~project_locked,locked(),tx,handle,incoming))
def populate_inner(world: World(),+handle: W.Handle<Schema>,bundle: Bundle) -> World():
  match bundle:
    case Bundle{stock,recipe,queue,enabled,locked}: populate_locked(populate_enabled(populate_queue(populate_recipe(populate_stock(world,handle,stock),handle,recipe),handle,queue),handle,enabled),handle,locked)
def populate(world: World(),handle: W.Handle<Schema>,bundle: Bundle) -> World():
  match handle:
    case W.Handle{+namespace,+id}: populate_inner(world,W.Handle{namespace,id},bundle)
def clear_column_result(~Owner: Type,result: Col.SwapOutcome<Schema,Owner>) -> Col.Column<Schema,Owner>:
  match result:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def clear_column(~Owner: Type,+id: U32,column: Col.Column<Schema,Owner>) -> Col.Column<Schema,Owner>:
  clear_column_result(~Owner,Col.clear(~Schema,~Owner,column,id))
def clear_inner(store: Store,+id: U32) -> Store:
  match store:
    case Store{stock,recipe,queue,enabled,locked}: Store{clear_column(~Stock,id,stock),clear_column(~Recipe,id,recipe),clear_column(~Queue,id,queue),clear_column(~Enabled,id,enabled),clear_column(~Locked,id,locked)}
def clear(store: Store,handle: W.Handle<Schema>) -> Store:
  match handle:
    case W.Handle{_,+id}: clear_inner(store,id)
def is_event(value: Notice) -> Bool:
  match value:
    case Ping{_}: True{}
    case _: False{}

type AllToken is Data:
  StockFamily{}
  AuxFamily{}
def stock_removed(handle: W.Handle<Schema>) -> Notice: RemovedStock{handle}
def aux_removed(handle: W.Handle<Schema>) -> Notice: RemovedAux{handle}
def gone(handle: W.Handle<Schema>) -> Notice: Gone{handle}
def remove_stock(tx: Tx(),handle: W.Handle<Schema>) -> Tx():
  queued(~Stock,St.tx_remove_observed(~Schema,~Store,~Unit,~Notice,~StockRest,~Stock,~StockView,~StockToken,~take_stock,~put_stock,~project_stock,~stock_removed,stock(),tx,handle))
def remove_aux(tx: Tx(),handle: W.Handle<Schema>) -> Tx():
  queued(~Queue,St.tx_remove_observed(~Schema,~Store,~Unit,~Notice,~QueueRest,~Queue,~QueueView,~QueueToken,~take_queue,~put_queue,~project_queue,~aux_removed,queue(),tx,handle))
def clear_stock_result(handle: W.Handle<Schema>,result: Col.SwapOutcome<Schema,Stock>) -> Col.Column<Schema,Stock> & List<&2,Notice>:
  match result:
    case Col.Accepted{column,Some{_}}: (column,[RemovedStock{handle}])
    case Col.Accepted{column,None{}}: (column,[])
    case Col.Rejected{column,_}: (column,[])
def clear_aux_result(handle: W.Handle<Schema>,result: Col.SwapOutcome<Schema,Queue>) -> Col.Column<Schema,Queue> & List<&2,Notice>:
  match result:
    case Col.Accepted{column,Some{_}}: (column,[RemovedAux{handle}])
    case Col.Accepted{column,None{}}: (column,[])
    case Col.Rejected{column,_}: (column,[])
def cleanup_join(recipe: Col.Column<Schema,Recipe>,enabled: Col.Column<Schema,Enabled>,locked: Col.Column<Schema,Locked>,stock: Col.Column<Schema,Stock> & List<&2,Notice>,queue: Col.Column<Schema,Queue> & List<&2,Notice>) -> Store & List<&2,Notice>:
  (stock,+a) = stock
  (queue,+b) = queue
  (Store{stock,recipe,queue,enabled,locked},List.append(&2,Notice,a,b))
def cleanup(store: Store,handle: W.Handle<Schema>) -> Store & List<&2,Notice>:
  match store handle:
    case Store{stock,recipe,queue,enabled,locked}, W.Handle{+namespace,+id}: cleanup_join(clear_column(~Recipe,id,recipe),clear_column(~Enabled,id,enabled),clear_column(~Locked,id,locked),clear_stock_result(W.Handle{namespace,id},Col.clear(~Schema,~Stock,stock,id)),clear_aux_result(W.Handle{namespace,id},Col.clear(~Schema,~Queue,queue,id)))
