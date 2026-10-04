import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

# Finite logical lookup relation. Physical ordering is deliberately absent.
def Slots(fuel: Nat, +slot: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>) -> Type:
  match fuel:
    case 0n: Unit
    case 1n+rest:
      {S.at(left,slot) == S.at(right,slot) : Maybe<&2,T.Row>} & Slots(rest,1n+slot,left,right)

def slots_refl(fuel: Nat, +slot: Nat, +rows: List<&2,T.Row>) -> Slots(fuel,slot,rows,rows):
  match fuel:
    case 0n: Unit{}
    case 1n+rest: ({==},slots_refl(rest,1n+slot,rows))

def slots_from_equal(+fuel: Nat, +slot: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>,
  e: {left == right : List<&2,T.Row>}) -> Slots(fuel,slot,left,right):
  %e : Slots(fuel,slot,left,_)
  slots_refl(fuel,slot,left)

def enumerate_related(+fuel: Nat, +slot: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +selection: T.Selection,
  related: Slots(fuel,slot,left,right))
  -> {S.enumerate_rows(fuel,slot,left,selection) == S.enumerate_rows(fuel,slot,right,selection) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      (head,tail) = related
      %head : {S.query_at(selection,S.at(left,slot),S.enumerate_rows(rest,1n+slot,left,selection))
        == S.query_at(selection,_,S.enumerate_rows(rest,1n+slot,right,selection)) : List<&2,T.Row>}
      %enumerate_related(rest,1n+slot,left,right,selection,tail) :
        {S.query_at(selection,S.at(left,slot),S.enumerate_rows(rest,1n+slot,left,selection))
          == S.query_at(selection,S.at(left,slot),_) : List<&2,T.Row>}
      {==}

def bumped_related(+fuel: Nat, +slot: Nat, +target: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>,
  related: Slots(fuel,slot,left,right))
  -> {S.bumped(fuel,slot,target,left) == S.bumped(fuel,slot,target,right) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      (head,tail) = related
      %head : {S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),S.at(left,slot)),S.bumped(rest,1n+slot,target,left))
        == S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),_),S.bumped(rest,1n+slot,target,right)) : List<&2,T.Row>}
      %bumped_related(rest,1n+slot,target,left,right,tail) :
        {S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),S.at(left,slot)),S.bumped(rest,1n+slot,target,left))
          == S.query_at(T.Any{},S.immediate(Nat.cmp(slot,target),S.at(left,slot)),_) : List<&2,T.Row>}
      {==}

def materialize_related(+fuel: Nat, +slot: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>,
  +pending: List<&2,T.Command>, related: Slots(fuel,slot,left,right))
  -> {S.materialize(fuel,slot,left,pending) == S.materialize(fuel,slot,right,pending) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      (head,tail) = related
      %head : {S.query_at(T.Any{},S.replay(pending,slot,S.at(left,slot)),S.materialize(rest,1n+slot,left,pending))
        == S.query_at(T.Any{},S.replay(pending,slot,_),S.materialize(rest,1n+slot,right,pending)) : List<&2,T.Row>}
      %materialize_related(rest,1n+slot,left,right,pending,tail) :
        {S.query_at(T.Any{},S.replay(pending,slot,S.at(left,slot)),S.materialize(rest,1n+slot,left,pending))
          == S.query_at(T.Any{},S.replay(pending,slot,S.at(left,slot)),_) : List<&2,T.Row>}
      {==}

# Metadata is public; physical rows are related only through the logical interval.
def Related(left: T.World, right: T.World) -> Type:
  match left right:
    case T.World{id,next,rows,pending} T.World{other_id,other_next,other_rows,other_pending}:
      {id == other_id : Nat} & {next == other_next : Nat}
        & {pending == other_pending : List<&2,T.Command>} & Slots(next,0n,rows,other_rows)

def related_refl(+world: T.World) -> Related(world,world):
  match world:
    case T.World{id,+next,+rows,pending}: ({==},{==},{==},slots_refl(next,0n,rows))

def related_shared(+id: Nat, +next: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>,
  related: Slots(next,0n,left,right))
  -> Related(T.World{id,next,left,pending},T.World{id,next,right,pending}):
  ({==},{==},{==},related)

def observe_related(+left: T.World, +right: T.World, related: Related(left,right))
  -> {S.observe(left) == S.observe(right) : T.Observation}:
  match left right:
    case T.World{+id,+next,+rows,+pending} T.World{+other_id,+other_next,+other_rows,+other_pending}:
      (same_id,same_next,same_pending,slots) = related
      %same_id : {S.observe(T.World{id,next,rows,pending}) == S.observe(T.World{_,other_next,other_rows,other_pending}) : T.Observation}
      %same_next : {S.observe(T.World{id,next,rows,pending}) == S.observe(T.World{id,_,other_rows,other_pending}) : T.Observation}
      %same_pending : {S.observe(T.World{id,next,rows,pending}) == S.observe(T.World{id,next,other_rows,_}) : T.Observation}
      Equal.cong(List<&2,T.Row>,T.Observation,r => T.Observation{id,next,r,pending},
        S.enumerate_rows(next,0n,rows,T.Any{}),S.enumerate_rows(next,0n,other_rows,T.Any{}),
        enumerate_related(next,0n,rows,other_rows,T.Any{},slots))
