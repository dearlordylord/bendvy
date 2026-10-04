import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S
import ../p-observe-queries/helpers.bend as H
import ../p-observe-queries/invariants.bend as Q

# Appended non-Spawn commands do not contribute to reservation multiplicity.
def publish_count(+commands: List<&2,T.Command>, +slot: Nat, +target: Nat, +action: T.Action)
  -> {S.spawn_count(commands,slot) == S.spawn_count(List.append(&2,T.Command,commands,[T.Target{target,action}]),slot) : Nat}:
  match commands:
    case Nil{}: {==}
    case Con{T.Target{id,a},tail}: publish_count(tail,slot,target,action)
    case Con{T.Spawn{+id,value},+tail}:
      %publish_count(tail,slot,target,action) :
        {S.add_if(Nat.is_eq(id,slot),S.spawn_count(tail,slot)) == S.add_if(Nat.is_eq(id,slot),_) : Nat}
      {==}

def publish_pending(+commands: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +next: Nat, +target: Nat, +action: T.Action)
  -> {S.pending_valid(commands,all,rows,next)
    == S.pending_valid(List.append(&2,T.Command,commands,[T.Target{target,action}]),List.append(&2,T.Command,all,[T.Target{target,action}]),rows,next) : Bool}:
  match commands:
    case Nil{}: {==}
    case Con{T.Target{id,a},tail}: publish_pending(tail,all,rows,next,target,action)
    case Con{T.Spawn{+slot,value},+tail}:
      %publish_count(all,slot,target,action) :
        {S.pending_valid(T.Spawn{slot,value} <> tail,all,rows,next)
          == Bool.and(Nat.is_eq(_,1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(List.append(&2,T.Command,tail,[T.Target{target,action}]),List.append(&2,T.Command,all,[T.Target{target,action}]),rows,next)))) : Bool}
      %publish_pending(tail,all,rows,next,target,action) :
        {S.pending_valid(T.Spawn{slot,value} <> tail,all,rows,next)
          == Bool.and(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),_))) : Bool}
      {==}

# Counts at the allocation frontier vanish by the independent strict row bounds.
def count_at_frontier(+rows: List<&2,T.Row>, +all: List<&2,T.Row>, +next: Nat,
  +valid: {True{} == S.rows_valid(rows,all,next) : Bool}) -> {0n == S.count(rows,next) : Nat}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+slot,value,tag},+tail}:
      +rest = H.and_right(Nat.is_eq(S.count(all,slot),1n),Bool.and(Nat.is_lt(slot,next),S.rows_valid(tail,all,next)),valid)
      %Q.lt_not_eq(slot,next,H.and_left(Nat.is_lt(slot,next),S.rows_valid(tail,all,next),rest)) :
        {0n == S.add_if(_,S.count(tail,next)) : Nat}
      count_at_frontier(tail,all,next,H.and_right(Nat.is_lt(slot,next),S.rows_valid(tail,all,next),rest))

def pending_count_frontier(+commands: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +next: Nat,
  +valid: {True{} == S.pending_valid(commands,all,rows,next) : Bool}) -> {0n == S.spawn_count(commands,next) : Nat}:
  match commands:
    case Nil{}: {==}
    case Con{T.Target{slot,action},tail}: pending_count_frontier(tail,all,rows,next,valid)
    case Con{T.Spawn{+slot,value},+tail}:
      rest = H.and_right(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next))),valid)
      +bound_tail = H.and_right(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)),rest)
      %Q.lt_not_eq(slot,next,H.and_left(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),bound_tail)) :
        {0n == S.add_if(_,S.spawn_count(tail,next)) : Nat}
      pending_count_frontier(tail,all,rows,next,H.and_right(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),bound_tail))

# Existing row bounds remain valid when a successful reserve grows the frontier.
def reserve_rows_bound(+rows: List<&2,T.Row>, +all: List<&2,T.Row>, +next: Nat,
  +valid: {True{} == S.rows_valid(rows,all,next) : Bool})
  -> {True{} == S.rows_valid(rows,all,1n+next) : Bool}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+slot,value,tag},+tail}:
      count = H.and_left(Nat.is_eq(S.count(all,slot),1n),Bool.and(Nat.is_lt(slot,next),S.rows_valid(tail,all,next)),valid)
      +rest = H.and_right(Nat.is_eq(S.count(all,slot),1n),Bool.and(Nat.is_lt(slot,next),S.rows_valid(tail,all,next)),valid)
      Q.and_intro(Nat.is_eq(S.count(all,slot),1n),Bool.and(Nat.is_lt(slot,1n+next),S.rows_valid(tail,all,1n+next)),count,
        Q.and_intro(Nat.is_lt(slot,1n+next),S.rows_valid(tail,all,1n+next),
          Q.lt_succ_right(slot,next,H.and_left(Nat.is_lt(slot,next),S.rows_valid(tail,all,next),rest)),
          reserve_rows_bound(tail,all,next,H.and_right(Nat.is_lt(slot,next),S.rows_valid(tail,all,next),rest))))

# Fresh append contributes only to its own reservation multiplicity.
def reserve_count_other(+commands: List<&2,T.Command>, +fresh: Nat, +value: Nat, +key: Nat,
  +different: {False{} == Nat.is_eq(fresh,key) : Bool})
  -> {S.spawn_count(commands,key) == S.spawn_count(List.append(&2,T.Command,commands,[T.Spawn{fresh,value}]),key) : Nat}:
  match commands:
    case Nil{}:
      %different : {0n == S.add_if(_,0n) : Nat}
      {==}
    case Con{T.Target{slot,action},tail}: reserve_count_other(tail,fresh,value,key,different)
    case Con{T.Spawn{+slot,v},+tail}:
      %reserve_count_other(tail,fresh,value,key,different) :
        {S.add_if(Nat.is_eq(slot,key),S.spawn_count(tail,key)) == S.add_if(Nat.is_eq(slot,key),_) : Nat}
      {==}

def add_if_successor(+hit: Bool, +count: Nat)
  -> {S.add_if(hit,1n+count) == 1n+S.add_if(hit,count) : Nat}:
  match hit:
    case False{}: {==}
    case True{}: {==}

def reserve_count_self(+commands: List<&2,T.Command>, +fresh: Nat, +value: Nat)
  -> {S.spawn_count(List.append(&2,T.Command,commands,[T.Spawn{fresh,value}]),fresh) == 1n+S.spawn_count(commands,fresh) : Nat}:
  match commands:
    case Nil{}:
      %H.cmp_reflexive(fresh) : {S.add_if(Cmp.is_eq(_),0n) == 1n : Nat}
      {==}
    case Con{T.Target{slot,action},tail}: reserve_count_self(tail,fresh,value)
    case Con{T.Spawn{+slot,v},+tail}:
      Equal.trans(Nat,S.add_if(Nat.is_eq(slot,fresh),S.spawn_count(List.append(&2,T.Command,tail,[T.Spawn{fresh,value}]),fresh)),
        S.add_if(Nat.is_eq(slot,fresh),1n+S.spawn_count(tail,fresh)),1n+S.add_if(Nat.is_eq(slot,fresh),S.spawn_count(tail,fresh)),
        Equal.cong(Nat,Nat,n => S.add_if(Nat.is_eq(slot,fresh),n),S.spawn_count(List.append(&2,T.Command,tail,[T.Spawn{fresh,value}]),fresh),
          1n+S.spawn_count(tail,fresh),reserve_count_self(tail,fresh,value)),
        add_if_successor(Nat.is_eq(slot,fresh),S.spawn_count(tail,fresh)))

def frontier_successor(+next: Nat) -> {True{} == Nat.is_lt(next,1n+next) : Bool}:
  match next:
    case 0n: {==}
    case 1n+rest: frontier_successor(rest)

# Exact fresh-append obligation needed by a successful schedule Reserve branch.
def reserve_pending(+commands: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +next: Nat, +value: Nat,
  +valid: {True{} == S.pending_valid(commands,all,rows,next) : Bool},
  +fresh_rows: {0n == S.count(rows,next) : Nat}, +fresh_commands: {0n == S.spawn_count(all,next) : Nat})
  -> {True{} == S.pending_valid(List.append(&2,T.Command,commands,[T.Spawn{next,value}]),List.append(&2,T.Command,all,[T.Spawn{next,value}]),rows,1n+next) : Bool}:
  match commands:
    case Nil{}:
      %Equal.sym(Nat,S.spawn_count(List.append(&2,T.Command,all,[T.Spawn{next,value}]),next),1n+S.spawn_count(all,next),reserve_count_self(all,next,value)) :
        {True{} == Bool.and(Nat.is_eq(_,1n),Bool.and(Nat.is_eq(S.count(rows,next),0n),Bool.and(Nat.is_lt(next,1n+next),True{}))) : Bool}
      %fresh_commands :
        {True{} == Bool.and(Nat.is_eq(1n+_,1n),Bool.and(Nat.is_eq(S.count(rows,next),0n),Bool.and(Nat.is_lt(next,1n+next),True{}))) : Bool}
      %fresh_rows : {True{} == Bool.and(Nat.is_eq(_,0n),Bool.and(Nat.is_lt(next,1n+next),True{})) : Bool}
      %frontier_successor(next) : {True{} == Bool.and(_,True{}) : Bool}
      {==}
    case Con{T.Target{slot,action},tail}: reserve_pending(tail,all,rows,next,value,valid,fresh_rows,fresh_commands)
    case Con{T.Spawn{+slot,v},+tail}:
      multiplicity = H.and_left(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next))),valid)
      +rest = H.and_right(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next))),valid)
      +bound_tail = H.and_right(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)),rest)
      +bound = H.and_left(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),bound_tail)
      different = Equal.trans(Bool,False{},Nat.is_eq(slot,next),Nat.is_eq(next,slot),Q.lt_not_eq(slot,next,bound),Q.eq_symmetric(slot,next))
      counts = reserve_count_other(all,next,value,slot,different)
      Q.and_intro(Nat.is_eq(S.spawn_count(List.append(&2,T.Command,all,[T.Spawn{next,value}]),slot),1n),
        Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,1n+next),S.pending_valid(List.append(&2,T.Command,tail,[T.Spawn{next,value}]),List.append(&2,T.Command,all,[T.Spawn{next,value}]),rows,1n+next))),
        Equal.trans(Bool,True{},Nat.is_eq(S.spawn_count(all,slot),1n),Nat.is_eq(S.spawn_count(List.append(&2,T.Command,all,[T.Spawn{next,value}]),slot),1n),multiplicity,
          Equal.cong(Nat,Bool,n => Nat.is_eq(n,1n),S.spawn_count(all,slot),S.spawn_count(List.append(&2,T.Command,all,[T.Spawn{next,value}]),slot),counts)),
        Q.and_intro(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,1n+next),S.pending_valid(List.append(&2,T.Command,tail,[T.Spawn{next,value}]),List.append(&2,T.Command,all,[T.Spawn{next,value}]),rows,1n+next)),
          H.and_left(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)),rest),
          Q.and_intro(Nat.is_lt(slot,1n+next),S.pending_valid(List.append(&2,T.Command,tail,[T.Spawn{next,value}]),List.append(&2,T.Command,all,[T.Spawn{next,value}]),rows,1n+next),
            Q.lt_succ_right(slot,next,bound),
            reserve_pending(tail,all,rows,next,value,H.and_right(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),bound_tail),fresh_rows,fresh_commands))))
