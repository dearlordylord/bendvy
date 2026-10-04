import Base
import ./helpers.bend as H
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Reflection is needed because S.rows_valid carries a Boolean count test.
def eq_reflect(+a: Nat, +b: Nat, h: {True{} == Nat.is_eq(a,b) : Bool}) -> {a == b : Nat}:
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: Empty.absurd({0n == 1n+q : Nat},H.false_true_absurd(Equal.sym(Bool,True{},False{},h)))
    case 1n+p 0n: Empty.absurd({1n+p == 0n : Nat},H.false_true_absurd(Equal.sym(Bool,True{},False{},h)))
    case 1n+p 1n+q:
      %eq_reflect(p,q,h) : {1n+p == 1n+_ : Nat}
      {==}

# These two contextual facts duplicate the checked lookup lane's tiny facts,
# keeping this independently mergeable package free of a new import dependency.
def eq_symmetric(+a: Nat, +b: Nat) -> {Nat.is_eq(a,b) == Nat.is_eq(b,a) : Bool}:
  match a b:
    case 0n 0n: {==}
    case 0n 1n+p: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: eq_symmetric(p,q)

def eligibility(+selection: T.Selection, +tag: Bool) -> {M.accepts(selection,tag) == S.eligible(selection,tag) : Bool}:
  match selection tag:
    case T.Any{} False{}: {==}
    case T.Any{} True{}: {==}
    case T.Present{} False{}: {==}
    case T.Present{} True{}: {==}
    case T.Absent{} False{}: {==}
    case T.Absent{} True{}: {==}

def zero_add_key(+ok: Bool, +n: Nat, h: {0n == S.add_if(ok,n) : Nat}) -> {False{} == ok : Bool}:
  match ok:
    case False{}: {==}
    case True{}: Empty.absurd({False{} == True{} : Bool},H.zero_succ_absurd(n,h))

def zero_add_tail(ok: Bool, +n: Nat, h: {0n == S.add_if(ok,n) : Nat}) -> {0n == n : Nat}:
  match ok:
    case False{}: h
    case True{}: Empty.absurd({0n == n : Nat},H.zero_succ_absurd(n,h))

def count_distinct(+id: Nat, +value: Nat, +tag: Bool, +rows: List<&2,T.Row>, +key: Nat,
  h: {False{} == Nat.is_eq(id,key) : Bool})
  -> {S.count(rows,key) == S.count(T.Row{id,value,tag} <> rows,key) : Nat}:
  %h : {S.count(rows,key) == S.add_if(_,S.count(rows,key)) : Nat}
  {==}

def and_intro(+a: Bool, +b: Bool, ha: {True{} == a : Bool}, hb: {True{} == b : Bool}) -> {True{} == Bool.and(a,b) : Bool}:
  %ha : {True{} == Bool.and(_,b) : Bool}
  hb

# Remove the same absent head from the whole-list parameter at every row.
# Both premises are actual evidence; rows can be a sublist of all.
def remove_absent(+rows: List<&2,T.Row>, +all: List<&2,T.Row>, +id: Nat, +value: Nat, +tag: Bool, +next: Nat,
  +hz: {0n == S.count(rows,id) : Nat},
  +hv: {True{} == S.rows_valid(rows,T.Row{id,value,tag} <> all,next) : Bool})
  -> {True{} == S.rows_valid(rows,all,next) : Bool}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+key,+v,+t},+rest}:
      distinct = Equal.trans(Bool,False{},Nat.is_eq(key,id),Nat.is_eq(id,key),
        zero_add_key(Nat.is_eq(key,id),S.count(rest,id),hz),eq_symmetric(key,id))
      counts = count_distinct(id,value,tag,all,key,distinct)
      head_valid = Equal.trans(Bool,True{},Nat.is_eq(S.count(T.Row{id,value,tag} <> all,key),1n),Nat.is_eq(S.count(all,key),1n),
        H.and_left(Nat.is_eq(S.count(T.Row{id,value,tag} <> all,key),1n),Bool.and(Nat.is_lt(key,next),S.rows_valid(rest,T.Row{id,value,tag} <> all,next)),hv),
        Equal.cong(Nat,Bool,n => Nat.is_eq(n,1n),S.count(T.Row{id,value,tag} <> all,key),S.count(all,key),
          Equal.sym(Nat,S.count(all,key),S.count(T.Row{id,value,tag} <> all,key),counts)))
      +rest_valid = H.and_right(Nat.is_eq(S.count(T.Row{id,value,tag} <> all,key),1n),Bool.and(Nat.is_lt(key,next),S.rows_valid(rest,T.Row{id,value,tag} <> all,next)),hv)
      and_intro(Nat.is_eq(S.count(all,key),1n),Bool.and(Nat.is_lt(key,next),S.rows_valid(rest,all,next)),head_valid,
        and_intro(Nat.is_lt(key,next),S.rows_valid(rest,all,next),
          H.and_left(Nat.is_lt(key,next),S.rows_valid(rest,T.Row{id,value,tag} <> all,next),rest_valid),
          remove_absent(rest,all,id,value,tag,next,zero_add_tail(Nat.is_eq(key,id),S.count(rest,id),hz),
            H.and_right(Nat.is_lt(key,next),S.rows_valid(rest,T.Row{id,value,tag} <> all,next),rest_valid))))

# Exact head-removal validity needed by the approved query list induction.
def valid_tail(+id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>, +next: Nat,
  +hv: {True{} == S.rows_valid(T.Row{id,value,tag} <> tail,T.Row{id,value,tag} <> tail,next) : Bool})
  -> {True{} == S.rows_valid(tail,tail,next) : Bool}:
  count_one = eq_reflect(S.count(T.Row{id,value,tag} <> tail,id),1n,
    H.and_left(Nat.is_eq(S.count(T.Row{id,value,tag} <> tail,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next)),hv))
  tail_zero = H.unique_head_tail_zero(id,value,tag,tail,Equal.sym(Nat,S.count(T.Row{id,value,tag} <> tail,id),1n,count_one))
  remove_absent(tail,tail,id,value,tag,next,tail_zero,
    H.and_right(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next),
      H.and_right(Nat.is_eq(S.count(T.Row{id,value,tag} <> tail,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next)),hv)))

# Enumeration can emit only the row whose key is the current logical slot.
def AtKey(result: Maybe<&2,T.Row>, +slot: Nat) -> Type:
  match result:
    case None{}: Unit
    case Some{T.Row{key,_,_}}: {True{} == Nat.is_eq(key,slot) : Bool}

def pick_key(order: Cmp, +id: Nat, +value: Nat, +tag: Bool, +slot: Nat, +tail: Maybe<&2,T.Row>,
  e: {order == Nat.cmp(id,slot) : Cmp}, ih: AtKey(tail,slot))
  -> AtKey(S.pick(order,T.Row{id,value,tag},_ => tail),slot):
  match order:
    case EQ{}:
      %e : {True{} == Cmp.is_eq(_) : Bool}
      {==}
    case LT{}: ih
    case GT{}: ih

def at_key(+rows: List<&2,T.Row>, +slot: Nat) -> AtKey(S.at(rows,slot),slot):
  match rows:
    case Nil{}: Unit{}
    case Con{T.Row{+id,+value,+tag},+tail}:
      pick_key(Nat.cmp(id,slot),id,value,tag,slot,S.at(tail,slot),{==},at_key(tail,slot))

# Initial enumeration slot is zero, regardless of the inserted row's key.
def zero_le(n: Nat) -> {True{} == Nat.is_le(0n,n) : Bool}:
  match n:
    case 0n: {==}
    case 1n+rest: {==}

# Contextual interval endpoint arithmetic, independent of U32/runtime bridges.
def add_zero(+n: Nat) -> {n == Nat.add(n,0n) : Nat}:
  match n:
    case 0n: {==}
    case 1n+rest:
      %add_zero(rest) : {1n+rest == 1n+_ : Nat}
      {==}

def le_lt_cycle(+a: Nat, +b: Nat, lo: {True{} == Nat.is_le(a,b) : Bool}, hi: {True{} == Nat.is_lt(b,a) : Bool}) -> Empty:
  match a b:
    case 0n 0n: H.false_true_absurd(Equal.sym(Bool,True{},False{},hi))
    case 0n 1n+q: H.false_true_absurd(Equal.sym(Bool,True{},False{},hi))
    case 1n+p 0n: H.false_true_absurd(Equal.sym(Bool,True{},False{},lo))
    case 1n+p 1n+q: le_lt_cycle(p,q,lo,hi)

# Strictly earlier keys stay earlier when logical enumeration advances one slot.
def lt_succ_right(+a: Nat, +b: Nat, h: {True{} == Nat.is_lt(a,b) : Bool})
  -> {True{} == Nat.is_lt(a,1n+b) : Bool}:
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: Empty.absurd({True{} == Nat.is_lt(p,0n) : Bool},H.false_true_absurd(Equal.sym(Bool,True{},False{},h)))
    case 1n+p 1n+q: lt_succ_right(p,q,h)

def lt_not_eq(+a: Nat, +b: Nat, h: {True{} == Nat.is_lt(a,b) : Bool})
  -> {False{} == Nat.is_eq(a,b) : Bool}:
  match a b:
    case 0n 0n: Equal.sym(Bool,True{},False{},h)
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: lt_not_eq(p,q,h)
