import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

# Contextual introduction of the conditional proposition; no encoder equation.
def when_known(guard: Bool, -claim: Type, proof: claim) -> S.When(guard, claim):
  match guard:
    case False{}: Unit{}
    case True{}: proof

# Empty physical source yields no logical rows for any enumeration interval.
def enumerate_empty(fuel: Nat, +slot: Nat, +selection: T.Selection) -> {[] == S.enumerate_rows(fuel, slot, [], selection) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest: enumerate_empty(rest,1n+slot,selection)

# Comparison toolkit, specialized to the Nat keys used by query sorting/count.
def cmp_reflexive(n: Nat) -> {EQ{} == Nat.cmp(n,n) : Cmp}:
  match n:
    case 0n: {==}
    case 1n+rest: cmp_reflexive(rest)

def cmp_zero_right(n: Nat) -> {False{} == Nat.is_lt(n,0n) : Bool}:
  match n:
    case 0n: {==}
    case 1n+rest: {==}

# Boolean constructor discrimination for invariant branch contradictions.
def FalseCase(b: Bool) -> Type:
  match b:
    case False{}: Unit
    case True{}: Empty

def false_true_absurd(e: {False{} == True{} : Bool}) -> Empty:
  %e : FalseCase(_)
  Unit{}

# Extracting the two pieces of an existing conjunction premise, not a world law.
def and_left(a: Bool, +b: Bool, h: {True{} == Bool.and(a,b) : Bool}) -> {True{} == a : Bool}:
  match a:
    case True{}: {==}
    case False{}: Empty.absurd({True{} == False{} : Bool},false_true_absurd(Equal.sym(Bool,True{},False{},h)))

def and_right(a: Bool, +b: Bool, h: {True{} == Bool.and(a,b) : Bool}) -> {True{} == b : Bool}:
  match a:
    case True{}: h
    case False{}: Empty.absurd({True{} == b : Bool},false_true_absurd(Equal.sym(Bool,True{},False{},h)))

# A zero count prevents the lookup from emitting a row (completeness substep).
def ZeroCase(n: Nat) -> Type:
  match n:
    case 0n: Unit
    case 1n+rest: Empty

def zero_succ_absurd(+n: Nat, e: {0n == 1n+n : Nat}) -> Empty:
  %e : ZeroCase(_)
  Unit{}

def at_zero_head(order: Cmp, +row: T.Row, +tail: List<&2,T.Row>, +slot: Nat,
  h: {0n == S.add_if(Cmp.is_eq(order),S.count(tail,slot)) : Nat},
  ih: {0n == S.count(tail,slot) : Nat} -> {None{} == S.at(tail,slot) : Maybe<&2,T.Row>})
  -> {None{} == S.pick(order,row,_ => S.at(tail,slot)) : Maybe<&2,T.Row>}:
  match order:
    case EQ{}: Empty.absurd({None{} == Some{row} : Maybe<&2,T.Row>},zero_succ_absurd(S.count(tail,slot),h))
    case LT{}: ih(h)
    case GT{}: ih(h)

def at_count_zero(+rows: List<&2,T.Row>, +slot: Nat, h: {0n == S.count(rows,slot) : Nat})
  -> {None{} == S.at(rows,slot) : Maybe<&2,T.Row>}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      at_zero_head(Nat.cmp(id,slot),T.Row{id,value,tag},tail,slot,h,e => at_count_zero(tail,slot,e))

# Counts at the current row's own slot expose precisely the tail contribution.
def count_self(+id: Nat, value: Nat, tag: Bool, +tail: List<&2,T.Row>)
  -> {1n+S.count(tail,id) == S.count(T.Row{id,value,tag} <> tail,id) : Nat}:
  %cmp_reflexive(id) : {1n+S.count(tail,id) == S.add_if(Cmp.is_eq(_),S.count(tail,id)) : Nat}
  {==}

def predecessor(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+rest: rest

def unique_head_tail_zero(+id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>,
  h: {1n == S.count(T.Row{id,value,tag} <> tail,id) : Nat})
  -> {0n == S.count(tail,id) : Nat}:
  Equal.cong(Nat,Nat,n => predecessor(n),1n,1n+S.count(tail,id),
    Equal.trans(Nat,1n,S.count(T.Row{id,value,tag} <> tail,id),1n+S.count(tail,id),h,
      Equal.sym(Nat,1n+S.count(tail,id),S.count(T.Row{id,value,tag} <> tail,id),count_self(id,value,tag,tail))))
