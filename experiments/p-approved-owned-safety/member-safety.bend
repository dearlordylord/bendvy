import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S
import ../p-observe-queries/helpers.bend as H
import ../p-observe-queries/invariants.bend as Q

type Bound is Data:
  Overflow{}
  Below{value: Nat}
def apply(bound: Bound,row: T.Row) -> Bool:
  match bound:
    case Overflow{}: S.no_overflow_lookup(S.describe(T.Any{},Some{row}))
    case Below{value}:
      match row:
        case T.Row{_,payload,_}: Bool.not(Nat.is_ge(payload,value))

def row_safe(+bound: Bound,row: T.Row) -> Bool:
  apply(bound,row)
def lookup_safe(+bound: Bound,found: Maybe<&2,T.Row>) -> Bool:
  match found:
    case None{}: True{}
    case Some{row}: row_safe(bound,row)

def guard(+bound: Bound,order: Cmp,+row: T.Row,tail: Bool) -> Bool:
  match order:
    case EQ{}: Bool.and(row_safe(bound,row),tail)
    case LT{}: tail
    case GT{}: tail

def BumpSafe(+bound: Bound,rows: List<&2,T.Row>,+target: Nat) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{T.Row{+id,+value,+tag},tail}: guard(bound,Nat.cmp(id,target),T.Row{id,value,tag},BumpSafe(bound,tail,target))

def absent_head(+bound: Bound,order: Cmp,+row: T.Row,+tail: Bool,e: {False{} == Cmp.is_eq(order) : Bool})
  -> {tail == guard(bound,order,row,tail) : Bool}:
  match order:
    case EQ{}: Empty.absurd({tail == guard(bound,EQ{},row,tail) : Bool},H.false_true_absurd(e))
    case LT{}: {==}
    case GT{}: {==}

def absent(+bound: Bound,+rows: List<&2,T.Row>,+target: Nat,+zero: {0n == S.count(rows,target) : Nat})
  -> {True{} == BumpSafe(bound,rows,target) : Bool}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      Equal.trans(Bool,True{},BumpSafe(bound,tail,target),guard(bound,Nat.cmp(id,target),T.Row{id,value,tag},BumpSafe(bound,tail,target)),
        absent(bound,tail,target,Q.zero_add_tail(Nat.is_eq(id,target),S.count(tail,target),zero)),
        absent_head(bound,Nat.cmp(id,target),T.Row{id,value,tag},BumpSafe(bound,tail,target),Q.zero_add_key(Nat.is_eq(id,target),S.count(tail,target),zero)))

def head_case(+bound: Bound,order: Cmp,+id: Nat,+value: Nat,+tag: Bool,+tail: List<&2,T.Row>,+target: Nat,+next: Nat,
  e: {order == Nat.cmp(id,target) : Cmp},
  +valid: {True{} == S.rows_valid(T.Row{id,value,tag} <> tail,T.Row{id,value,tag} <> tail,next) : Bool},
  safe: {True{} == lookup_safe(bound,S.pick(order,T.Row{id,value,tag},_ => S.at(tail,target))) : Bool},
  ih: {True{} == S.rows_valid(tail,tail,next) : Bool} -> {True{} == lookup_safe(bound,S.at(tail,target)) : Bool}
    -> {True{} == BumpSafe(bound,tail,target) : Bool})
  -> {True{} == guard(bound,order,T.Row{id,value,tag},BumpSafe(bound,tail,target)) : Bool}:
  match order:
    case EQ{}:
      %Q.eq_reflect(id,target,Equal.cong(Cmp,Bool,o => Cmp.is_eq(o),EQ{},Nat.cmp(id,target),e)) : {True{} == Bool.and(row_safe(bound,T.Row{id,value,tag}),BumpSafe(bound,tail,_)) : Bool}
      Q.and_intro(row_safe(bound,T.Row{id,value,tag}),BumpSafe(bound,tail,id),safe,
        absent(bound,tail,id,H.unique_head_tail_zero(id,value,tag,tail,
          Equal.sym(Nat,S.count(T.Row{id,value,tag} <> tail,id),1n,Q.eq_reflect(S.count(T.Row{id,value,tag} <> tail,id),1n,H.and_left(Nat.is_eq(S.count(T.Row{id,value,tag} <> tail,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next)),valid))))))
    case LT{}: ih(Q.valid_tail(id,value,tag,tail,next,valid),safe)
    case GT{}: ih(Q.valid_tail(id,value,tag,tail,next,valid),safe)

def from_lookup(+bound: Bound,+rows: List<&2,T.Row>,+target: Nat,+next: Nat,
  valid: {True{} == S.rows_valid(rows,rows,next) : Bool},
  safe: {True{} == lookup_safe(bound,S.at(rows,target)) : Bool})
  -> {True{} == BumpSafe(bound,rows,target) : Bool}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      head_case(bound,Nat.cmp(id,target),id,value,tag,tail,target,next,{==},valid,safe,
        v => h => from_lookup(bound,tail,target,next,v,h))



def oracle_guard(+found: Maybe<&2,T.Row>)
  -> {lookup_safe(Overflow{},found) == S.no_overflow_lookup(S.describe(T.Any{},found)) : Bool}:
  match found:
    case None{}: {==}
    case Some{row}: {==}

def from_step(+id: Nat,+next: Nat,+rows: List<&2,T.Row>,+pending: List<&2,T.Command>,+target: Nat,
  valid: {True{} == S.rows_valid(rows,rows,next) : Bool},
  safe: {True{} == S.step_safe(T.World{id,next,rows,pending},T.Bump{target}) : Bool})
  -> {True{} == BumpSafe(Overflow{},rows,target) : Bool}:
  from_lookup(Overflow{},rows,target,next,valid,
    Equal.trans(Bool,True{},S.no_overflow_lookup(S.describe(T.Any{},S.at(rows,target))),lookup_safe(Overflow{},S.at(rows,target)),
      Equal.trans(Bool,True{},S.no_overflow_lookup(S.lookup_namespace(Nat.cmp(id,id),rows,target,T.Any{})),S.no_overflow_lookup(S.describe(T.Any{},S.at(rows,target))),safe,
        Equal.cong(Cmp,Bool,o => S.no_overflow_lookup(S.lookup_namespace(o,rows,target,T.Any{})),Nat.cmp(id,id),EQ{},Equal.sym(Cmp,EQ{},Nat.cmp(id,id),H.cmp_reflexive(id)))),
      Equal.sym(Bool,lookup_safe(Overflow{},S.at(rows,target)),S.no_overflow_lookup(S.describe(T.Any{},S.at(rows,target))),oracle_guard(S.at(rows,target)))))
