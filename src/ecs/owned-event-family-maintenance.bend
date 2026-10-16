import Base
import ./world.bend as W
import ./world-resource-owner.bend as WR
import ./owner-product.bend as Product
import ./event-runtime.bend as Ev
import ./event-family-runtime.bend as FR
import ./event-family-routing.bend as Route
import ./owned-event-family-catalog.bend as Catalog
# The complete typed catalog is derived by leaf/both, not a list of user cleanup
# callbacks. All payload owners are returned before shared publication state clears.
def resource_returned(~S:Data,~C:Type,~User:Type,~Logs:Type,~E:Data,~Receipt:Type,rest:WR.Rest<S,C,Product.Owner<User,Logs>,E>,user:User,result:Logs & Receipt) -> W.World<S,C,Product.Owner<User,Logs>,E> & Receipt:
  match result:
    case (logs,receipt):(WR.put(~S,~C,~Product.Owner<User,Logs>,~E,rest,Product.Owner{user,logs}),receipt)
def resource_taken(~S:Data,~C:Type,~User:Type,~Logs:Type,~E:Data,~Receipt:Type,~retain:Logs -> List<&2,E> -> Logs & Receipt,~drain:Logs -> Logs & Receipt,shutdown:Bool,records:List<&2,E>,result:WR.Rest<S,C,Product.Owner<User,Logs>,E> & Product.Owner<User,Logs>) -> W.World<S,C,Product.Owner<User,Logs>,E> & Receipt:
  match shutdown result:
    case False{}, (rest,Product.Owner{user,logs}):resource_returned(~S,~C,~User,~Logs,~E,~Receipt,rest,user,retain(logs,records))
    case True{}, (rest,Product.Owner{user,logs}):resource_returned(~S,~C,~User,~Logs,~E,~Receipt,rest,user,drain(logs))
def completed(~S:Data,~C:Type,~User:Type,~Logs:Type,~E:Data,~F:Type,~Owners:Type,~Receipt:Type,~clear:F -> F,shutdown:Bool,family:F,owners:Owners,journal:List<&2,Ev.Batch<E>>,frameStart:Nat,tick:Nat,result:W.World<S,C,Product.Owner<User,Logs>,E> & Receipt) -> Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>> & Receipt:
  match shutdown result:
    case False{}, (world,receipt):(Route.Runtime{world,FR.State{family,owners,journal,frameStart},tick},receipt)
    case True{}, (world,receipt):(Route.Runtime{W.events_replace(~S,~C,~Product.Owner<User,Logs>,~E,world,[]),FR.State{clear(family),owners,[],frameStart},tick},receipt)
def observed(~S:Data,~C:Type,~User:Type,~Logs:Type,~E:Data,~F:Type,~Owners:Type,~Receipt:Type,~retain:Logs -> List<&2,E> -> Logs & Receipt,~drain:Logs -> Logs & Receipt,~clear:F -> F,+shutdown:Bool,family:F,owners:Owners,journal:List<&2,Ev.Batch<E>>,frameStart:Nat,tick:Nat,result:W.World<S,C,Product.Owner<User,Logs>,E> & List<&2,E>) -> Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>> & Receipt:
  match result:
    case (world,records):completed(~S,~C,~User,~Logs,~E,~F,~Owners,~Receipt,~clear,shutdown,family,owners,journal,frameStart,tick,resource_taken(~S,~C,~User,~Logs,~E,~Receipt,~retain,~drain,shutdown,records,WR.take(~S,~C,~Product.Owner<User,Logs>,~E,world)))
def collect(~S:Data,~C:Type,~User:Type,~Logs:Type,~E:Data,~F:Type,~Owners:Type,~Receipt:Type,~retain:Logs -> List<&2,E> -> Logs & Receipt,~drain:Logs -> Logs & Receipt,~clear:F -> F,shutdown:Bool,runtime:Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>>) -> Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>> & Receipt:
  match runtime:
    case Route.Runtime{world,FR.State{family,owners,journal,frameStart},tick}:observed(~S,~C,~User,~Logs,~E,~F,~Owners,~Receipt,~retain,~drain,~clear,shutdown,family,owners,journal,frameStart,tick,W.events_view(~S,~C,~Product.Owner<User,Logs>,~E,world))
def frame(~S:Data,~C:Type,~User:Type,~Logs:Type,~E:Data,~F:Type,~Owners:Type,~Receipt:Type,~retain:Logs -> List<&2,E> -> Logs & Receipt,~drain:Logs -> Logs & Receipt,~clear:F -> F,~catalog:Catalog.Catalog<E,Logs,F,Receipt,retain,drain,clear>,~frame:F -> Nat -> F,~retainRecords:F -> Nat -> List<&2,E> -> F & List<&2,E>,runtime:Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>>) -> Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>> & Receipt:
  collect(~S,~C,~User,~Logs,~E,~F,~Owners,~Receipt,~retain,~drain,~clear,False{},FR.frame(~S,~C,~Product.Owner<User,Logs>,~E,~F,~Owners,~frame,~retainRecords,runtime))
def shutdown(~S:Data,~C:Type,~User:Type,~Logs:Type,~E:Data,~F:Type,~Owners:Type,~Receipt:Type,~retain:Logs -> List<&2,E> -> Logs & Receipt,~drain:Logs -> Logs & Receipt,~clear:F -> F,~catalog:Catalog.Catalog<E,Logs,F,Receipt,retain,drain,clear>,runtime:Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>>) -> Route.Runtime<S,C,Product.Owner<User,Logs>,E,FR.State<E,F,Owners>> & Receipt:
  collect(~S,~C,~User,~Logs,~E,~F,~Owners,~Receipt,~retain,~drain,~clear,True{},runtime)
