import Base
import ./game.bend as Game
import ./declaration.bend as Decl
import ./leaf.bend as Leaf
import ./admission.bend as Admission
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/setup.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-product.bend as Product

type Filled<-S:Data> is Type:
  ColumnReady{leaf:Game.Saved(~S)}
  ColumnRefused{leaf:Game.Saved(~S),incoming:Maybe<F.Payload>}
def second_inserted(~S:Data,result:Admission.Insertion<S,F.Payload,F.declaration(~S),F.project>) -> Filled<S>:
  match result:
    case Admission.Insertion{declaration,_,Col.Accepted{column,_}}:ColumnReady{Leaf.Component{column,declaration}}
    case Admission.Insertion{declaration,_,Col.Rejected{column,incoming}}:ColumnRefused{Leaf.Component{column,declaration},incoming}
def first_inserted(~S:Data,result:Admission.Insertion<S,F.Payload,F.declaration(~S),F.project>) -> Filled<S>:
  match result:
    case Admission.Insertion{declaration,_,Col.Accepted{column,_}}:second_inserted(~S,Admission.insert(~S,~F.Payload,~F.declaration(~S),~F.project,declaration,column,2,F.payload(17,19)))
    case Admission.Insertion{declaration,_,Col.Rejected{column,incoming}}:ColumnRefused{Leaf.Component{column,declaration},incoming}
def filled(~S:Data,declaration:Decl.Constructed<S,F.Payload,F.declaration(~S),F.project>) -> Filled<S>:
  first_inserted(~S,Admission.insert(~S,~F.Payload,~F.declaration(~S),~F.project,declaration,Col.ensure(~S,~F.Payload,Col.empty(~S,~F.Payload),2),1,F.payload(7,9)))
def columns_ready(~S:Data,scratchRecipe:Decl.Transient<S,F.Payload,Game.scratch(~S)>,units:Product.Owner<Unit,Unit>,saved:Filled<S>,transient:Old.Filled<S>) -> Game.Store(~S) & Maybe<F.Payload> & Bool:
  match saved transient:
    case ColumnReady{saved} Old.ColumnReady{transient}:(Product.Owner{Product.Owner{saved,Leaf.TransientComponent{transient,scratchRecipe}},units},None{},True{})
    case ColumnRefused{saved,incoming} Old.ColumnReady{transient}:(Product.Owner{Product.Owner{saved,Leaf.TransientComponent{transient,scratchRecipe}},units},incoming,False{})
    case ColumnReady{saved} Old.ColumnRefused{transient}:(Product.Owner{Product.Owner{saved,Leaf.TransientComponent{transient,scratchRecipe}},units},None{},False{})
    case ColumnRefused{saved,incoming} Old.ColumnRefused{transient}:(Product.Owner{Product.Owner{saved,Leaf.TransientComponent{transient,scratchRecipe}},units},incoming,False{})
def populated(~S:Data,store:Game.Store(~S)) -> Game.Store(~S) & Maybe<F.Payload> & Bool:
  match store:
    case Product.Owner{Product.Owner{Leaf.Component{_,declaration},Leaf.TransientComponent{_,scratchRecipe}},units}:columns_ready(~S,scratchRecipe,units,filled(~S,declaration),Old.filled(~S,107,109,117,119))
type Setup<-S:Data> is Type:
  Ready{world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>}
  Refused{world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,incoming:Maybe<F.Payload>}
def done(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Maybe<F.Payload> & Bool) -> Setup<S>:
  match observed:
    case (world,_,True{}):Ready{world}
    case (world,incoming,False{}):Refused{world,incoming}
def reserved_inactive(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.ReservationRejected{_}):Refused{world,None{}}
    case (world,W.Reserved{_}):done(~S,W.with_store(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~Maybe<F.Payload> & Bool,populated(~S),world))
def activated_second(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & W.Status) -> Setup<S>:
  match observed:
    case (world,W.Rejected{_}):Refused{world,None{}}
    case (world,W.Accepted{}):reserved_inactive(~S,W.reserve_id(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,world))
def reserved_second(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.ReservationRejected{_}):Refused{world,None{}}
    case (world,W.Reserved{handle}):activated_second(~S,W.activate(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,world,handle))
def activated_first(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & W.Status) -> Setup<S>:
  match observed:
    case (world,W.Rejected{_}):Refused{world,None{}}
    case (world,W.Accepted{}):reserved_second(~S,W.reserve_id(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,world))
def reserved_first(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.ReservationRejected{_}):Refused{world,None{}}
    case (world,W.Reserved{handle}):activated_first(~S,W.activate(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,world,handle))
def setup(~S:Data,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> Setup<S>:
  reserved_first(~S,W.reserve_id(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,world))
