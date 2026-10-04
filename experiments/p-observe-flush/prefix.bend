import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../p-observe-queries/helpers.bend as H
import ../p-observe-queries/invariants.bend as I
import ./coherence.bend as C

# For a distinct observed key, dropping/changing a matched target head contributes
# no count; use the already derived comparison coherence, not fabricated guards.
def count_changed_head(+action: T.Action, +id: Nat, +value: Nat, +tag: Bool, +key: Nat, +after: List<&2,T.Row>, e: {Nat.is_eq(id,key) == False{} : Bool}) -> {S.count(M.modify_one(True{},action,T.Row{id,value,tag},after),key) == S.count(after,key) : Nat}:
  match action:
    case T.Insert{}:
      %Equal.sym(Bool,Nat.is_eq(id,key),False{},e) : {S.add_if(_,S.count(after,key)) == S.count(after,key) : Nat}
      {==}
    case T.Remove{}:
      %Equal.sym(Bool,Nat.is_eq(id,key),False{},e) : {S.add_if(_,S.count(after,key)) == S.count(after,key) : Nat}
      {==}
    case T.Despawn{}: {==}

def count_other_node(+hit: Bool, +target: Nat, +key: Nat, +action: T.Action, +id: Nat, +value: Nat, +tag: Bool, +after: List<&2,T.Row>, +before: List<&2,T.Row>, hit_e: {Nat.is_eq(target,id) == hit : Bool}, neq: {Nat.is_eq(target,key) == False{} : Bool}, ih: {S.count(after,key) == S.count(before,key) : Nat}) -> {S.count(M.modify_one(hit,action,T.Row{id,value,tag},after),key) == S.count(T.Row{id,value,tag} <> before,key) : Nat}:
  match hit:
    case False{}:
      Equal.cong(Nat,Nat,n => S.add_if(Nat.is_eq(id,key),n),S.count(after,key),S.count(before,key),ih)
    case True{}:
      +e = C.other_row_nonmatch(target,id,key,hit_e,neq)
      %Equal.sym(Bool,Nat.is_eq(id,key),False{},e) : {S.count(M.modify_one(True{},action,T.Row{id,value,tag},after),key) == S.add_if(_,S.count(before,key)) : Nat}
      Equal.trans(Nat,S.count(M.modify_one(True{},action,T.Row{id,value,tag},after),key),S.count(after,key),S.count(before,key),count_changed_head(action,id,value,tag,key,after,e),ih)

def count_other(+rows: List<&2,T.Row>, +target: Nat, +key: Nat, +action: T.Action, +neq: {Nat.is_eq(target,key) == False{} : Bool}) -> {S.count(M.modify(target,action,rows),key) == S.count(rows,key) : Nat}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      count_other_node(Nat.is_eq(target,id),target,key,action,id,value,tag,M.modify(target,action,tail),tail,{==},neq,count_other(tail,target,key,action,neq))

# Whether an action preserves all row IDs (a local proof decomposition).
def keeps_ids(action: T.Action) -> Bool:
  match action:
    case T.Insert{}: True{}
    case T.Remove{}: True{}
    case T.Despawn{}: False{}

def count_kept_head(+hit: Bool, +action: T.Action, +id: Nat, +value: Nat, +tag: Bool, +after: List<&2,T.Row>, +key: Nat, safe: {True{} == keeps_ids(action) : Bool}) -> {S.count(M.modify_one(hit,action,T.Row{id,value,tag},after),key) == S.count(T.Row{id,value,tag} <> after,key) : Nat}:
  match hit action:
    case False{} _: {==}
    case True{} T.Insert{}: {==}
    case True{} T.Remove{}: {==}
    case True{} T.Despawn{}:
      Empty.absurd({S.count(after,key) == S.count(T.Row{id,value,tag} <> after,key) : Nat},C.true_false(safe))

def count_kept(+rows: List<&2,T.Row>, +target: Nat, +action: T.Action, +key: Nat, +safe: {True{} == keeps_ids(action) : Bool}) -> {S.count(M.modify(target,action,rows),key) == S.count(rows,key) : Nat}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      Equal.trans(Nat,S.count(M.modify_one(Nat.is_eq(target,id),action,T.Row{id,value,tag},M.modify(target,action,tail)),key),S.count(T.Row{id,value,tag} <> M.modify(target,action,tail),key),S.count(T.Row{id,value,tag} <> tail,key),count_kept_head(Nat.is_eq(target,id),action,id,value,tag,M.modify(target,action,tail),key,safe),Equal.cong(Nat,Nat,n => S.add_if(Nat.is_eq(id,key),n),S.count(M.modify(target,action,tail),key),S.count(tail,key),count_kept(tail,target,action,key,safe)))

def retained_valid(+id: Nat, +value: Nat, +tag: Bool, +newtag: Bool, +all: List<&2,T.Row>, +newall: List<&2,T.Row>, +tail: List<&2,T.Row>, +next: Nat, +hv: {True{} == S.rows_valid(T.Row{id,value,tag} <> [],all,next) : Bool}, ih: {True{} == S.rows_valid(tail,newall,next) : Bool}, counts: {S.count(newall,id) == S.count(all,id) : Nat}) -> {True{} == S.rows_valid(T.Row{id,value,newtag} <> tail,newall,next) : Bool}:
  I.and_intro(Nat.is_eq(S.count(newall,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,newall,next)),Equal.trans(Bool,True{},Nat.is_eq(S.count(all,id),1n),Nat.is_eq(S.count(newall,id),1n),H.and_left(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),True{}),hv),Equal.cong(Nat,Bool,n => Nat.is_eq(n,1n),S.count(all,id),S.count(newall,id),Equal.sym(Nat,S.count(newall,id),S.count(all,id),counts))),I.and_intro(Nat.is_lt(id,next),S.rows_valid(tail,newall,next),H.and_left(Nat.is_lt(id,next),True{},H.and_right(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),True{}),hv)),ih))

# Drop the tail part of an existing row-validity premise to reuse its head.
def head_valid(+id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>, +all: List<&2,T.Row>, +next: Nat, +hv: {True{} == S.rows_valid(T.Row{id,value,tag} <> tail,all,next) : Bool}) -> {True{} == S.rows_valid(T.Row{id,value,tag} <> [],all,next) : Bool}:
  I.and_intro(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),True{}),H.and_left(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,all,next)),hv),I.and_intro(Nat.is_lt(id,next),True{},H.and_left(Nat.is_lt(id,next),S.rows_valid(tail,all,next),H.and_right(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,all,next)),hv)),{==}))

def modify_valid_node(+hit: Bool, +action: T.Action, +target: Nat, +id: Nat, +value: Nat, +tag: Bool, +after: List<&2,T.Row>, +all: List<&2,T.Row>, +next: Nat, hv: {True{} == S.rows_valid([T.Row{id,value,tag}],all,next) : Bool}, ih: {True{} == S.rows_valid(after,M.modify(target,action,all),next) : Bool}, he: {Nat.is_eq(target,id) == hit : Bool}) -> {True{} == S.rows_valid(M.modify_one(hit,action,T.Row{id,value,tag},after),M.modify(target,action,all),next) : Bool}:
  match hit action:
    case False{} a:
      retained_valid(id,value,tag,tag,all,M.modify(target,a,all),after,next,hv,ih,count_other(all,target,id,a,he))
    case True{} T.Insert{}:
      retained_valid(id,value,tag,True{},all,M.modify(target,T.Insert{},all),after,next,hv,ih,count_kept(all,target,T.Insert{},id,{==}))
    case True{} T.Remove{}:
      retained_valid(id,value,tag,False{},all,M.modify(target,T.Remove{},all),after,next,hv,ih,count_kept(all,target,T.Remove{},id,{==}))
    case True{} T.Despawn{}: ih

def modify_rows_valid(+rows: List<&2,T.Row>, +all: List<&2,T.Row>, +target: Nat, +action: T.Action, +next: Nat, +hv: {True{} == S.rows_valid(rows,all,next) : Bool}) -> {True{} == S.rows_valid(M.modify(target,action,rows),M.modify(target,action,all),next) : Bool}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      modify_valid_node(Nat.is_eq(target,id),action,target,id,value,tag,M.modify(target,action,tail),all,next,head_valid(id,value,tag,tail,all,next,hv),modify_rows_valid(tail,all,target,action,next,H.and_right(Nat.is_lt(id,next),S.rows_valid(tail,all,next),H.and_right(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,all,next)),hv))),{==})

# Add a fresh absent row to the whole-list parameter without invalidating rows.
def add_absent(+rows: List<&2,T.Row>, +all: List<&2,T.Row>, +slot: Nat, +value: Nat, +tag: Bool, +next: Nat, +hz: {0n == S.count(rows,slot) : Nat}, +hv: {True{} == S.rows_valid(rows,all,next) : Bool}) -> {True{} == S.rows_valid(rows,T.Row{slot,value,tag} <> all,next) : Bool}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+key,+v,+t},+rest}:
      distinct = Equal.trans(Bool,False{},Nat.is_eq(key,slot),Nat.is_eq(slot,key),I.zero_add_key(Nat.is_eq(key,slot),S.count(rest,slot),hz),I.eq_symmetric(key,slot))
      retained_valid(key,v,t,t,all,T.Row{slot,value,tag} <> all,rest,next,head_valid(key,v,t,rest,all,next,hv),add_absent(rest,all,slot,value,tag,next,I.zero_add_tail(Nat.is_eq(key,slot),S.count(rest,slot),hz),H.and_right(Nat.is_lt(key,next),S.rows_valid(rest,all,next),H.and_right(Nat.is_eq(S.count(all,key),1n),Bool.and(Nat.is_lt(key,next),S.rows_valid(rest,all,next)),hv))),Equal.sym(Nat,S.count(all,key),S.count(T.Row{slot,value,tag} <> all,key),I.count_distinct(slot,value,tag,all,key,distinct)))

def spawn_rows_valid(+rows: List<&2,T.Row>, +slot: Nat, +value: Nat, +next: Nat, hv: {True{} == S.rows_valid(rows,rows,next) : Bool}, +hz: {0n == S.count(rows,slot) : Nat}, hb: {True{} == Nat.is_lt(slot,next) : Bool}) -> {True{} == S.rows_valid(M.apply(T.Spawn{slot,value},rows),M.apply(T.Spawn{slot,value},rows),next) : Bool}:
  I.and_intro(Nat.is_eq(S.count(T.Row{slot,value,False{}} <> rows,slot),1n),Bool.and(Nat.is_lt(slot,next),S.rows_valid(rows,T.Row{slot,value,False{}} <> rows,next)),Equal.cong(Nat,Bool,n => Nat.is_eq(n,1n),1n,S.count(T.Row{slot,value,False{}} <> rows,slot),Equal.trans(Nat,1n,1n+S.count(rows,slot),S.count(T.Row{slot,value,False{}} <> rows,slot),Equal.cong(Nat,Nat,n => 1n+n,0n,S.count(rows,slot),hz),H.count_self(slot,value,False{},rows))),I.and_intro(Nat.is_lt(slot,next),S.rows_valid(rows,T.Row{slot,value,False{}} <> rows,next),hb,add_absent(rows,rows,slot,value,False{},next,hz,hv)))

def zero_count_head(+hit: Bool, +action: T.Action, +id: Nat, +value: Nat, +tag: Bool, +after: List<&2,T.Row>, +key: Nat, he: {False{} == Nat.is_eq(id,key) : Bool}, hz: {0n == S.count(after,key) : Nat}) -> {0n == S.count(M.modify_one(hit,action,T.Row{id,value,tag},after),key) : Nat}:
  match hit action:
    case False{} _:
      %he : {0n == S.add_if(_,S.count(after,key)) : Nat}
      hz
    case True{} T.Insert{}:
      %he : {0n == S.add_if(_,S.count(after,key)) : Nat}
      hz
    case True{} T.Remove{}:
      %he : {0n == S.add_if(_,S.count(after,key)) : Nat}
      hz
    case True{} T.Despawn{}: hz

def zero_count_modify(+rows: List<&2,T.Row>, +target: Nat, +action: T.Action, +key: Nat, +hz: {0n == S.count(rows,key) : Nat}) -> {0n == S.count(M.modify(target,action,rows),key) : Nat}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      zero_count_head(Nat.is_eq(target,id),action,id,value,tag,M.modify(target,action,tail),key,I.zero_add_key(Nat.is_eq(id,key),S.count(tail,key),hz),zero_count_modify(tail,target,action,key,I.zero_add_tail(Nat.is_eq(id,key),S.count(tail,key),hz)))

# Existing future reservations remain fresh after tag updates or despawn.
def pending_modify(+commands: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +target: Nat, +action: T.Action, +next: Nat, +hp: {True{} == S.pending_valid(commands,all,rows,next) : Bool}) -> {True{} == S.pending_valid(commands,all,M.modify(target,action,rows),next) : Bool}:
  match commands:
    case Nil{}: {==}
    case Con{T.Target{_,_},+tail}: pending_modify(tail,all,rows,target,action,next,hp)
    case Con{T.Spawn{+slot,value},+tail}:
      +rest = H.and_right(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next))),hp)
      +last = H.and_right(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)),rest)
      hz = Equal.sym(Nat,S.count(rows,slot),0n,I.eq_reflect(S.count(rows,slot),0n,H.and_left(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)),rest)))
      I.and_intro(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(M.modify(target,action,rows),slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,M.modify(target,action,rows),next))),H.and_left(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next))),hp),I.and_intro(Nat.is_eq(S.count(M.modify(target,action,rows),slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,M.modify(target,action,rows),next)),Equal.cong(Nat,Bool,n => Nat.is_eq(n,0n),0n,S.count(M.modify(target,action,rows),slot),zero_count_modify(rows,target,action,slot,hz)),I.and_intro(Nat.is_lt(slot,next),S.pending_valid(tail,all,M.modify(target,action,rows),next),H.and_left(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),last),pending_modify(tail,all,rows,target,action,next,H.and_right(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),last)))))

# Remove a Target head from the whole pending-list parameter: it contributes
# nothing to any spawn count, while every reservation still has its guard.
def pending_drop_target(+commands: List<&2,T.Command>, +all: List<&2,T.Command>, +target: Nat, +action: T.Action, +rows: List<&2,T.Row>, +next: Nat, +hp: {True{} == S.pending_valid(commands,T.Target{target,action} <> all,rows,next) : Bool}) -> {True{} == S.pending_valid(commands,all,rows,next) : Bool}:
  match commands:
    case Nil{}: {==}
    case Con{T.Target{_,_},+tail}: pending_drop_target(tail,all,target,action,rows,next,hp)
    case Con{T.Spawn{+slot,value},+tail}:
      +rest = H.and_right(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Target{target,action} <> all,rows,next))),hp)
      +last = H.and_right(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Target{target,action} <> all,rows,next)),rest)
      I.and_intro(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next))),H.and_left(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Target{target,action} <> all,rows,next))),hp),I.and_intro(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)),H.and_left(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Target{target,action} <> all,rows,next)),rest),I.and_intro(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),H.and_left(Nat.is_lt(slot,next),S.pending_valid(tail,T.Target{target,action} <> all,rows,next),last),pending_drop_target(tail,all,target,action,rows,next,H.and_right(Nat.is_lt(slot,next),S.pending_valid(tail,T.Target{target,action} <> all,rows,next),last)))))

def pending_spawn_intro(+slot: Nat, value: Nat, +tail: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +next: Nat, hs: {True{} == Nat.is_eq(S.spawn_count(all,slot),1n) : Bool}, hz: {0n == S.count(rows,slot) : Nat}, hb: {True{} == Nat.is_lt(slot,next) : Bool}, ht: {True{} == S.pending_valid(tail,all,rows,next) : Bool}) -> {True{} == S.pending_valid(T.Spawn{slot,value} <> tail,all,rows,next) : Bool}:
  I.and_intro(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next))),hs,I.and_intro(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)),Equal.cong(Nat,Bool,n => Nat.is_eq(n,0n),0n,S.count(rows,slot),hz),I.and_intro(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next),hb,ht)))

def spawn_count_distinct(+slot: Nat, value: Nat, +all: List<&2,T.Command>, +key: Nat, e: {False{} == Nat.is_eq(slot,key) : Bool}) -> {S.spawn_count(all,key) == S.spawn_count(T.Spawn{slot,value} <> all,key) : Nat}:
  %e : {S.spawn_count(all,key) == S.add_if(_,S.spawn_count(all,key)) : Nat}
  {==}

def spawn_count_self(+slot: Nat, value: Nat, +tail: List<&2,T.Command>) -> {1n+S.spawn_count(tail,slot) == S.spawn_count(T.Spawn{slot,value} <> tail,slot) : Nat}:
  %H.cmp_reflexive(slot) : {1n+S.spawn_count(tail,slot) == S.add_if(Cmp.is_eq(_),S.spawn_count(tail,slot)) : Nat}
  {==}

def spawn_tail_zero(+slot: Nat, value: Nat, +tail: List<&2,T.Command>, h: {1n == S.spawn_count(T.Spawn{slot,value} <> tail,slot) : Nat}) -> {0n == S.spawn_count(tail,slot) : Nat}:
  Equal.cong(Nat,Nat,H.predecessor,1n,1n+S.spawn_count(tail,slot),Equal.trans(Nat,1n,S.spawn_count(T.Spawn{slot,value} <> tail,slot),1n+S.spawn_count(tail,slot),h,Equal.sym(Nat,1n+S.spawn_count(tail,slot),S.spawn_count(T.Spawn{slot,value} <> tail,slot),spawn_count_self(slot,value,tail))))

# Future spawn guards survive moving an earlier fresh spawn from pending to live.
def pending_after_spawn(+commands: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +slot: Nat, +value: Nat, +next: Nat, +hz: {0n == S.spawn_count(commands,slot) : Nat}, +hp: {True{} == S.pending_valid(commands,T.Spawn{slot,value} <> all,rows,next) : Bool}) -> {True{} == S.pending_valid(commands,all,T.Row{slot,value,False{}} <> rows,next) : Bool}:
  match commands:
    case Nil{}: {==}
    case Con{T.Target{_,_},+tail}: pending_after_spawn(tail,all,rows,slot,value,next,hz,hp)
    case Con{T.Spawn{+key,+v},+tail}:
      +distinct = Equal.trans(Bool,False{},Nat.is_eq(key,slot),Nat.is_eq(slot,key),I.zero_add_key(Nat.is_eq(key,slot),S.spawn_count(tail,slot),hz),I.eq_symmetric(key,slot))
      +rest = H.and_right(Nat.is_eq(S.spawn_count(T.Spawn{slot,value} <> all,key),1n),Bool.and(Nat.is_eq(S.count(rows,key),0n),Bool.and(Nat.is_lt(key,next),S.pending_valid(tail,T.Spawn{slot,value} <> all,rows,next))),hp)
      +last = H.and_right(Nat.is_eq(S.count(rows,key),0n),Bool.and(Nat.is_lt(key,next),S.pending_valid(tail,T.Spawn{slot,value} <> all,rows,next)),rest)
      counts = spawn_count_distinct(slot,value,all,key,distinct)
      head = Equal.trans(Bool,True{},Nat.is_eq(S.spawn_count(T.Spawn{slot,value} <> all,key),1n),Nat.is_eq(S.spawn_count(all,key),1n),H.and_left(Nat.is_eq(S.spawn_count(T.Spawn{slot,value} <> all,key),1n),Bool.and(Nat.is_eq(S.count(rows,key),0n),Bool.and(Nat.is_lt(key,next),S.pending_valid(tail,T.Spawn{slot,value} <> all,rows,next))),hp),Equal.cong(Nat,Bool,n => Nat.is_eq(n,1n),S.spawn_count(T.Spawn{slot,value} <> all,key),S.spawn_count(all,key),Equal.sym(Nat,S.spawn_count(all,key),S.spawn_count(T.Spawn{slot,value} <> all,key),counts)))
      oldzero = Equal.sym(Nat,S.count(rows,key),0n,I.eq_reflect(S.count(rows,key),0n,H.and_left(Nat.is_eq(S.count(rows,key),0n),Bool.and(Nat.is_lt(key,next),S.pending_valid(tail,T.Spawn{slot,value} <> all,rows,next)),rest)))
      newzero = Equal.trans(Nat,0n,S.count(rows,key),S.count(T.Row{slot,value,False{}} <> rows,key),oldzero,I.count_distinct(slot,value,False{},rows,key,distinct))
      pending_spawn_intro(key,v,tail,all,T.Row{slot,value,False{}} <> rows,next,head,newzero,H.and_left(Nat.is_lt(key,next),S.pending_valid(tail,T.Spawn{slot,value} <> all,rows,next),last),pending_after_spawn(tail,all,rows,slot,value,next,I.zero_add_tail(Nat.is_eq(key,slot),S.spawn_count(tail,slot),hz),H.and_right(Nat.is_lt(key,next),S.pending_valid(tail,T.Spawn{slot,value} <> all,rows,next),last)))

# The recursive call receives independently counted validity/freshness of the
# actual intermediate rows and remaining FIFO commands. No step-preservation law.
def apply_all_rows_valid(+commands: List<&2,T.Command>, +rows: List<&2,T.Row>, +next: Nat, +hr: {True{} == S.rows_valid(rows,rows,next) : Bool}, +hp: {True{} == S.pending_valid(commands,commands,rows,next) : Bool}) -> {True{} == S.rows_valid(M.apply_all(commands,rows),M.apply_all(commands,rows),next) : Bool}:
  match commands:
    case Nil{}: hr
    case Con{T.Target{+target,+action},+tail}:
      apply_all_rows_valid(tail,M.modify(target,action,rows),next,modify_rows_valid(rows,rows,target,action,next,hr),pending_modify(tail,tail,rows,target,action,next,pending_drop_target(tail,tail,target,action,rows,next,hp)))
    case Con{T.Spawn{+slot,+value},+tail}:
      +rest = H.and_right(Nat.is_eq(S.spawn_count(T.Spawn{slot,value} <> tail,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Spawn{slot,value} <> tail,rows,next))),hp)
      +last = H.and_right(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Spawn{slot,value} <> tail,rows,next)),rest)
      hz = Equal.sym(Nat,S.count(rows,slot),0n,I.eq_reflect(S.count(rows,slot),0n,H.and_left(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Spawn{slot,value} <> tail,rows,next)),rest)))
      spawnszero = spawn_tail_zero(slot,value,tail,Equal.sym(Nat,S.spawn_count(T.Spawn{slot,value} <> tail,slot),1n,I.eq_reflect(S.spawn_count(T.Spawn{slot,value} <> tail,slot),1n,H.and_left(Nat.is_eq(S.spawn_count(T.Spawn{slot,value} <> tail,slot),1n),Bool.and(Nat.is_eq(S.count(rows,slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,T.Spawn{slot,value} <> tail,rows,next))),hp))))
      apply_all_rows_valid(tail,T.Row{slot,value,False{}} <> rows,next,spawn_rows_valid(rows,slot,value,next,hr,hz,H.and_left(Nat.is_lt(slot,next),S.pending_valid(tail,T.Spawn{slot,value} <> tail,rows,next),last)),pending_after_spawn(tail,tail,rows,slot,value,next,spawnszero,H.and_right(Nat.is_lt(slot,next),S.pending_valid(tail,T.Spawn{slot,value} <> tail,rows,next),last)))
