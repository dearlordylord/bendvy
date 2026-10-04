import Base
import ./types.bend as T

# Independent logical oracle. No implementation imports. Entity-wise command
# replay differs from mutating physical rows and sorting the result.
def create_cmp(order: Cmp, +next: Nat) -> T.Creation:
  match order:
    case LT{}: T.Created{T.Factory{1n+next}, T.World{next, 1n, [], []}}
    case _: T.Full{T.Factory{next}}
def create(limit: Nat, factory: T.Factory) -> T.Creation:
  match factory:
    case T.Factory{+next}: create_cmp(Nat.cmp(next, limit), next)
def reserve_cmp(order: Cmp, +id: Nat, +next: Nat, rows: List<&2, T.Row>, pending: List<&2, T.Command>, value: Nat) -> T.Reservation:
  match order:
    case LT{}: T.Reserved{T.World{id, 1n+next, rows, List.append(&2, T.Command, pending, [T.Spawn{next, value}])}, T.Handle{id, next}}
    case _: T.Rejected{T.World{id, next, rows, pending}}
def reserve(limit: Nat, world: T.World, value: Nat) -> T.Reservation:
  match world:
    case T.World{id, +next, rows, pending}: reserve_cmp(Nat.cmp(next, limit), id, next, rows, pending, value)
def unwrap(result: T.Reservation) -> T.World:
  match result:
    case T.Reserved{world, _}: world
    case T.Rejected{world}: world

def pick(order: Cmp, row: T.Row, recur: Unit -> Maybe<&2, T.Row>) -> Maybe<&2, T.Row>:
  match order:
    case EQ{}: Some{row}
    case _: recur(Unit{})
def at(rows: List<&2, T.Row>, +slot: Nat) -> Maybe<&2, T.Row>:
  match rows:
    case Nil{}: None{}
    case Con{T.Row{+id,value,tag}, tail}: pick(Nat.cmp(id, slot), T.Row{id,value,tag}, _ => at(tail, slot))
def eligible(selection: T.Selection, tag: Bool) -> Bool:
  match selection tag:
    case T.Present{} False{}: False{}
    case T.Absent{} True{}: False{}
    case _ _: True{}
def selected_lookup(ok: Bool, row: T.Row) -> T.Lookup:
  match ok:
    case True{}: T.Found{row}
    case False{}: T.Mismatch{}
def describe(selection: T.Selection, row: Maybe<&2, T.Row>) -> T.Lookup:
  match row:
    case None{}: T.Missing{}
    case Some{T.Row{slot,value,+tag}}: selected_lookup(eligible(selection,tag), T.Row{slot,value,tag})
def lookup_namespace(order: Cmp, rows: List<&2, T.Row>, slot: Nat, selection: T.Selection) -> T.Lookup:
  match order:
    case EQ{}: describe(selection, at(rows,slot))
    case _: T.Missing{}
def lookup(world: T.World, handle: T.Handle, selection: T.Selection) -> T.Lookup:
  match world handle:
    case T.World{id,_,rows,_} T.Handle{namespace,slot}: lookup_namespace(Nat.cmp(id,namespace),rows,slot,selection)
def emit(ok: Bool, row: T.Row, tail: List<&2, T.Row>) -> List<&2, T.Row>:
  match ok:
    case False{}: tail
    case True{}: row <> tail
def query_at(selection: T.Selection, row: Maybe<&2, T.Row>, tail: List<&2, T.Row>) -> List<&2, T.Row>:
  match row:
    case None{}: tail
    case Some{T.Row{slot,value,+tag}}: emit(eligible(selection,tag),T.Row{slot,value,tag},tail)
def enumerate_rows(fuel: Nat, +slot: Nat, +rows: List<&2, T.Row>, +selection: T.Selection) -> List<&2, T.Row>:
  match fuel:
    case 0n: []
    case 1n+rest: query_at(selection,at(rows,slot),enumerate_rows(rest,1n+slot,rows,selection))
def query(world: T.World, selection: T.Selection) -> List<&2, T.Row>:
  match world:
    case T.World{_,next,rows,_}: enumerate_rows(next,0n,rows,selection)
def observe(world: T.World) -> T.Observation:
  match world:
    case T.World{id,+next,rows,pending}: T.Observation{id,next,enumerate_rows(next,0n,rows,T.Any{}),pending}

def publish_cmp(order: Cmp, id: Nat, next: Nat, rows: List<&2,T.Row>, pending: List<&2,T.Command>, slot: Nat, action: T.Action) -> T.World:
  match order:
    case EQ{}: T.World{id,next,rows,List.append(&2,T.Command,pending,[T.Target{slot,action}])}
    case _: T.World{id,next,rows,pending}
def publish(world: T.World, handle: T.Handle, action: T.Action) -> T.World:
  match world handle:
    case T.World{+id,next,rows,pending} T.Handle{namespace,slot}: publish_cmp(Nat.cmp(id,namespace),id,next,rows,pending,slot,action)

# A command is interpreted for exactly one slot. Missing insert/remove/despawn
# stay missing; a spawn creates the slot; survivor values remain untouched.
def target_effect(action: T.Action, current: Maybe<&2,T.Row>) -> Maybe<&2,T.Row>:
  match action current:
    case T.Despawn{} _: None{}
    case _ None{}: None{}
    case T.Insert{} Some{T.Row{slot,value,_}}: Some{T.Row{slot,value,True{}}}
    case T.Remove{} Some{T.Row{slot,value,_}}: Some{T.Row{slot,value,False{}}}
def command_at(order: Cmp, command: T.Command, current: Maybe<&2,T.Row>) -> Maybe<&2,T.Row>:
  match order command:
    case EQ{} T.Spawn{slot,value}: Some{T.Row{slot,value,False{}}}
    case EQ{} T.Target{_,action}: target_effect(action,current)
    case _ _: current
def one(command: T.Command, +slot: Nat, current: Maybe<&2,T.Row>) -> Maybe<&2,T.Row>:
  match command:
    case T.Spawn{+id,value}: command_at(Nat.cmp(id,slot),T.Spawn{id,value},current)
    case T.Target{+id,action}: command_at(Nat.cmp(id,slot),T.Target{id,action},current)
def replay(commands: List<&2,T.Command>, +slot: Nat, current: Maybe<&2,T.Row>) -> Maybe<&2,T.Row>:
  match commands:
    case Nil{}: current
    case Con{command,tail}: replay(tail,slot,one(command,slot,current))
def materialize(fuel: Nat, +slot: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>) -> List<&2,T.Row>:
  match fuel:
    case 0n: []
    case 1n+rest: query_at(T.Any{},replay(pending,slot,at(rows,slot)),materialize(rest,1n+slot,rows,pending))
def flush(world: T.World) -> T.World:
  match world:
    case T.World{id,+next,rows,pending}: T.World{id,next,materialize(next,0n,rows,pending),[]}
def flush_observation(world: T.World) -> T.Observation:
  observe(flush(world))

def bump_at(row: Maybe<&2,T.Row>) -> Maybe<&2,T.Row>:
  match row:
    case None{}: None{}
    case Some{T.Row{slot,value,tag}}: Some{T.Row{slot,1n+value,tag}}
def immediate(order: Cmp, row: Maybe<&2,T.Row>) -> Maybe<&2,T.Row>:
  match order:
    case EQ{}: bump_at(row)
    case _: row
def bumped(fuel: Nat, +slot: Nat, +target: Nat, +rows: List<&2,T.Row>) -> List<&2,T.Row>:
  match fuel:
    case 0n: []
    case 1n+rest: query_at(T.Any{},immediate(Nat.cmp(slot,target),at(rows,slot)),bumped(rest,1n+slot,target,rows))
def bump(world: T.World, slot: Nat) -> T.World:
  match world:
    case T.World{id,+next,rows,pending}: T.World{id,next,bumped(next,0n,slot,rows),pending}
def step(limit: Nat, world: T.World, s: T.Step) -> T.World:
  match s:
    case T.Reserve{value}: unwrap(reserve(limit,world,value))
    case T.Publish{handle,action}: publish(world,handle,action)
    case T.Bump{slot}: bump(world,slot)
    case T.Barrier{}: flush(world)
def run(steps: List<&2,T.Step>, +limit: Nat, world: T.World) -> T.World:
  match steps:
    case Nil{}: world
    case Con{s,tail}: run(tail,limit,step(limit,world,s))
def schedule_observation(limit: Nat, world: T.World, steps: List<&2,T.Step>) -> T.Observation:
  observe(run(steps,limit,world))

# Independent invariant uses counts, not implementation membership predicates.
def add_if(eq: Bool, n: Nat) -> Nat:
  match eq:
    case True{}: 1n+n
    case False{}: n
def count(rows: List<&2,T.Row>, +slot: Nat) -> Nat:
  match rows:
    case Nil{}: 0n
    case Con{T.Row{id,_,_},tail}: add_if(Nat.is_eq(id,slot),count(tail,slot))
def rows_valid(rows: List<&2,T.Row>, +all: List<&2,T.Row>, +next: Nat) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{T.Row{+slot,_,_},tail}: Bool.and(Nat.is_eq(count(all,slot),1n),Bool.and(Nat.is_lt(slot,next),rows_valid(tail,all,next)))
def spawn_count(commands: List<&2,T.Command>, +slot: Nat) -> Nat:
  match commands:
    case Nil{}: 0n
    case Con{T.Spawn{id,_},tail}: add_if(Nat.is_eq(id,slot),spawn_count(tail,slot))
    case Con{T.Target{_,_},tail}: spawn_count(tail,slot)
def pending_valid(commands: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +next: Nat) -> Bool:
  match commands:
    case Nil{}: True{}
    case Con{T.Spawn{+slot,_},tail}: Bool.and(Nat.is_eq(spawn_count(all,slot),1n),Bool.and(Nat.is_eq(count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),pending_valid(tail,all,rows,next))))
    case Con{T.Target{_,_},tail}: pending_valid(tail,all,rows,next)
def admissible(limit: Nat, world: T.World) -> Bool:
  match world:
    case T.World{_,+next,+rows,+pending}: Bool.and(Nat.is_le(next,limit),Bool.and(rows_valid(rows,rows,next),pending_valid(pending,pending,rows,next)))
def no_overflow_lookup(result: T.Lookup) -> Bool:
  match result:
    case T.Found{T.Row{_,value,_}}: Bool.not(Nat.is_ge(value,U32.to_nat(4294967295)))
    case _: True{}
def step_safe(world: T.World, operation: T.Step) -> Bool:
  match world operation:
    case T.World{+id,next,+rows,pending} T.Bump{slot}: no_overflow_lookup(lookup(T.World{id,next,rows,pending},T.Handle{id,slot},T.Any{}))
    case _ _: True{}

# Conditional proposition, not a Boolean equality validator. The guard comes
# from this independent oracle; true branches demand the actual stated equality.
def When(condition: Bool, claim: Type) -> Type:
  match condition:
    case True{}: claim
    case False{}: Unit

# All prefixes must stay admissible and every immediate update must be within
# U32 width. A safe initial state alone does not justify a multi-step schedule.
def run_safe(steps: List<&2,T.Step>, +limit: Nat, +world: T.World) -> Bool:
  match steps:
    case Nil{}: admissible(limit,world)
    case Con{+head,tail}: Bool.and(admissible(limit,world),Bool.and(step_safe(world,head),run_safe(tail,limit,step(limit,world,head))))
