import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def count_bump_head(+change: Bool, +id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>, +slot: Nat)
  -> {S.count(M.bump_one(change,T.Row{id,value,tag}) <> tail,slot)
    == S.add_if(Nat.is_eq(id,slot),S.count(tail,slot)) : Nat}:
  match change:
    case False{}: {==}
    case True{}: {==}

# Count preservation for the actual value-only physical update, arbitrary rows.
def count_bump(+rows: List<&2,T.Row>, +target: Nat, +slot: Nat)
  -> {S.count(M.bump_rows(target,rows),slot) == S.count(rows,slot) : Nat}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      Equal.trans(Nat,S.count(M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag}) <> M.bump_rows(target,tail),slot),
        S.add_if(Nat.is_eq(id,slot),S.count(M.bump_rows(target,tail),slot)),
        S.add_if(Nat.is_eq(id,slot),S.count(tail,slot)),
        count_bump_head(Nat.is_eq(target,id),id,value,tag,M.bump_rows(target,tail),slot),
        Equal.cong(Nat,Nat,n => S.add_if(Nat.is_eq(id,slot),n),S.count(M.bump_rows(target,tail),slot),S.count(tail,slot),count_bump(tail,target,slot)))

def valid_bump_head(+change: Bool, +id: Nat, +value: Nat, +tag: Bool,
  +tail: List<&2,T.Row>, +all: List<&2,T.Row>, +next: Nat)
  -> {S.rows_valid(M.bump_one(change,T.Row{id,value,tag}) <> tail,all,next)
    == Bool.and(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,all,next))) : Bool}:
  match change:
    case False{}: {==}
    case True{}: {==}

# Both walked rows and their whole-list counting source are updated identically.
def rows_valid_bump(+rows: List<&2,T.Row>, +all: List<&2,T.Row>, +target: Nat, +next: Nat)
  -> {S.rows_valid(M.bump_rows(target,rows),M.bump_rows(target,all),next)
    == S.rows_valid(rows,all,next) : Bool}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      %Equal.sym(Bool,
        S.rows_valid(M.bump_one(Nat.is_eq(target,id),T.Row{id,value,tag}) <> M.bump_rows(target,tail),M.bump_rows(target,all),next),
        Bool.and(Nat.is_eq(S.count(M.bump_rows(target,all),id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(M.bump_rows(target,tail),M.bump_rows(target,all),next))),
        valid_bump_head(Nat.is_eq(target,id),id,value,tag,M.bump_rows(target,tail),M.bump_rows(target,all),next)) :
        {_ == S.rows_valid(T.Row{id,value,tag} <> tail,all,next) : Bool}
      %count_bump(all,target,id) :
        {Bool.and(Nat.is_eq(S.count(M.bump_rows(target,all),id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(M.bump_rows(target,tail),M.bump_rows(target,all),next)))
          == Bool.and(Nat.is_eq(_,1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,all,next))) : Bool}
      %rows_valid_bump(tail,all,target,next) :
        {Bool.and(Nat.is_eq(S.count(M.bump_rows(target,all),id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(M.bump_rows(target,tail),M.bump_rows(target,all),next)))
          == Bool.and(Nat.is_eq(S.count(M.bump_rows(target,all),id),1n),Bool.and(Nat.is_lt(id,next),_)) : Bool}
      {==}

def pending_valid_bump(+pending: List<&2,T.Command>, +all: List<&2,T.Command>, +rows: List<&2,T.Row>, +target: Nat, +next: Nat)
  -> {S.pending_valid(pending,all,M.bump_rows(target,rows),next) == S.pending_valid(pending,all,rows,next) : Bool}:
  match pending:
    case Nil{}: {==}
    case Con{T.Target{slot,action},+tail}: pending_valid_bump(tail,all,rows,target,next)
    case Con{T.Spawn{+slot,value},+tail}:
      %count_bump(rows,target,slot) :
        {Bool.and(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(M.bump_rows(target,rows),slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,M.bump_rows(target,rows),next))))
          == Bool.and(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(_,0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,rows,next)))) : Bool}
      %pending_valid_bump(tail,all,rows,target,next) :
        {Bool.and(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(M.bump_rows(target,rows),slot),0n),Bool.and(Nat.is_lt(slot,next),S.pending_valid(tail,all,M.bump_rows(target,rows),next))))
          == Bool.and(Nat.is_eq(S.spawn_count(all,slot),1n),Bool.and(Nat.is_eq(S.count(M.bump_rows(target,rows),slot),0n),Bool.and(Nat.is_lt(slot,next),_))) : Bool}
      {==}
