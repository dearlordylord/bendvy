import Base
import ./types.bend as T
import ./runtime.bend as R

# Independent structural interpretation of an affine world. These reference
# observations consume owners; laws use erased owners only in propositions.
# No runtime.project/query/apply/schedule helper is called.
def payload(result: Array<U32> & U32) -> Nat:
  match result:
    case (_,value): U32.to_nat(value)
def cell(cell: R.Cell) -> T.Row:
  match cell:
    case R.Cell{slot,array,tag}: T.Row{U32.to_nat(slot),payload(array[0]),tag}
def rows(cells: List<R.Cell>) -> List<&2,T.Row>:
  match cells:
    case Nil{}: []
    case Con{head,tail}: cell(head) <> rows(tail)
def command(command: R.Command) -> T.Command:
  match command:
    case R.Spawn{slot,value}: T.Spawn{U32.to_nat(slot),U32.to_nat(value)}
    case R.Target{slot,action}: T.Target{U32.to_nat(slot),action}
def commands(values: List<&2,R.Command>) -> List<&2,T.Command>:
  match values:
    case Nil{}: []
    case Con{head,tail}: command(head) <> commands(tail)
def snapshot(world: R.World) -> T.World:
  match world:
    case R.World{id,next,cells,pending}: T.World{U32.to_nat(id),U32.to_nat(next),rows(cells),commands(pending)}
def factory(factory: R.Factory) -> T.Factory:
  match factory:
    case R.Factory{next}: T.Factory{U32.to_nat(next)}
def creation_world(factory: T.Factory, world: Maybe<R.World>) -> T.Creation:
  match world:
    case None{}: T.Full{factory}
    case Some{world}: T.Created{factory,snapshot(world)}
def creation(result: R.Factory & Maybe<R.World>) -> T.Creation:
  match result:
    case (f,world): creation_world(factory(f),world)
def step(operation: R.Step) -> T.Step:
  match operation:
    case R.Reserve{value}: T.Reserve{U32.to_nat(value)}
    case R.Publish{R.Handle{id,slot},action}: T.Publish{T.Handle{U32.to_nat(id),U32.to_nat(slot)},action}
    case R.Bump{slot}: T.Bump{U32.to_nat(slot)}
    case R.Barrier{}: T.Barrier{}

def handle(value: R.Handle) -> T.Handle:
  match value:
    case R.Handle{id,slot}: T.Handle{U32.to_nat(id),U32.to_nat(slot)}
def query(result: R.World & List<&2,T.Row>) -> T.QueryObservation:
  match result:
    case (world,rows): T.QueryObservation{snapshot(world),rows}
def lookup(result: R.World & T.Lookup) -> T.LookupObservation:
  match result:
    case (world,found): T.LookupObservation{snapshot(world),found}
def reserved(world: R.World, result: Maybe<&2,R.Handle>) -> T.Reservation:
  match result:
    case None{}: T.Rejected{snapshot(world)}
    case Some{value}: T.Reserved{snapshot(world),handle(value)}
def reservation(result: R.World & Maybe<&2,R.Handle>) -> T.Reservation:
  match result:
    case (world,value): reserved(world,value)
def steps(values: List<&2,R.Step>) -> List<&2,T.Step>:
  match values:
    case Nil{}: []
    case Con{head,tail}: step(head) <> steps(tail)
