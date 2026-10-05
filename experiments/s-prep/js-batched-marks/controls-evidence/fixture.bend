import Base
import ./transaction.bend as X
import ./storage.bend as S
import ./types.bend as T
import ./owners.bend as A

def make_motion(+base: U32) -> A.Motion:
  A.Motion{Array.set(U32,Array.set(U32,Array.set(U32,[base : U32^2n],1,U32.add(base,1)),2,U32.add(base,2)),3,U32.add(base,3)),base}
def make_health(+base: U32) -> A.Health:
  A.Health{Array.set(U32,Array.set(U32,Array.set(U32,[base : U32^2n],1,U32.add(base,1)),2,U32.add(base,2)),3,U32.add(base,3)),base}
def motion_some(r: A.Motion & String) -> Maybe<A.Motion> & String:
  match r:
    case (m,text): (Some{m},text)
def motion_observe(m: Maybe<A.Motion>) -> Maybe<A.Motion> & String:
  match m:
    case None{}: (None{},"none")
    case Some{m}: motion_some(A.motion_observe(m))
def health_some(r: A.Health & String) -> Maybe<A.Health> & String:
  match r:
    case (a,text): (Some{a},text)
def health_observe(a: Maybe<A.Health>) -> Maybe<A.Health> & String:
  match a:
    case None{}: (None{},"none")
    case Some{a}: health_some(A.health_observe(a))
def flag_text(flag: Maybe<&2,Unit>) -> String:
  match flag:
    case None{}: "absent"
    case Some{_}: "present"
def row_observed(+id: U32,+flag: Maybe<&2,Unit>,+added: U32,+changed: U32,both: (Maybe<A.Motion> & String) & (Maybe<A.Health> & String)) -> S.Row<A.Motion,A.Health,Unit> & String:
  match both:
    case ((m,mt),(a,at)): (S.Row{id,m,a,flag,added,changed},U32.show(id) ++ "|" ++ mt ++ "|" ++ at ++ "|" ++ flag_text(flag) ++ "|" ++ U32.show(added) ++ ":" ++ U32.show(changed))
def row_observe(row: S.Row<A.Motion,A.Health,Unit>) -> S.Row<A.Motion,A.Health,Unit> & String:
  match row:
    case S.Row{id,m,a,f,added,changed}: row_observed(id,f,added,changed,(motion_observe(m),health_observe(a)))
def lookup_observed(prefix: String,rows: S.Rows<A.Motion,A.Health,Unit>,result: S.Row<A.Motion,A.Health,Unit> & String) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (row,text):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ text)
        return S.rows_restore(A.Motion,A.Health,Unit,rows,row)
def lookup_print(prefix: String,result: S.Rows<A.Motion,A.Health,Unit> & Maybe<S.Row<A.Motion,A.Health,Unit>>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (rows,None{}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "missing")
        return rows
    case (rows,Some{row}): lookup_observed(prefix,rows,row_observe(row))
def rejected_observed(prefix: String,rows: S.Rows<A.Motion,A.Health,Unit>,result: S.Row<A.Motion,A.Health,Unit> & String) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (_,text):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "rejected:" ++ text)
        return rows
def placement_print(prefix: String,result: S.Placement<A.Motion,A.Health,Unit>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case S.Placed{rows}:
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "placed")
        return rows
    case S.Rejected{rows,row}: rejected_observed(prefix,rows,row_observe(row))
def removed_observed(prefix: String,rows: S.Rows<A.Motion,A.Health,Unit>,result: S.Row<A.Motion,A.Health,Unit> & String) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (_,text):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ text)
        return rows
def remove_print(prefix: String,result: S.Rows<A.Motion,A.Health,Unit> & Maybe<S.Row<A.Motion,A.Health,Unit>>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (rows,None{}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "missing")
        return rows
    case (rows,Some{row}): removed_observed(prefix,rows,row_observe(row))
def effect_text(effect: S.MainEffect) -> String:
  match effect:
    case S.MissingMainTarget{}: "missing"
    case S.AddedMain{}: "added"
    case S.ChangedMain{}: "changed"
    case S.RemovedMain{}: "removed"
    case S.NoMainChange{}: "unchanged"
def effect_print(prefix: String,result: S.Rows<A.Motion,A.Health,Unit> & S.MainEffect) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (rows,effect):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ effect_text(effect))
        return rows
def metadata_print(rows: S.Rows<A.Motion,A.Health,Unit>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match rows:
    case S.Rows{m,a,f,+c,+d,+h}:
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print("shape:" ++ U32.show(c) ++ ":" ++ Nat.show(d) ++ ":" ++ U32.show(h))
        return S.Rows{m,a,f,c,d,h}
def access_text(result: T.Access<String>) -> String:
  match result:
    case T.Missing{}: "missing"
    case T.Mismatch{}: "mismatch"
    case T.Found{text}: text
def main_print(prefix: String,result: S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> & T.Access<String>) -> IO(S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit>):
  match result:
    case (world,result):
      do IO<S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ access_text(result))
        return world
def extract_world(world: S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit>) -> S.Rows<A.Motion,A.Health,Unit>:
  match world:
    case S.World{_,_,rows,_,_,_}: rows

def rejected_main(prefix: String,rows: S.Rows<A.Motion,A.Health,Unit>,result: A.Motion & String) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (_,text):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "rejected:" ++ text)
        return rows
def put_print(prefix: String,result: S.Rows<A.Motion,A.Health,Unit> & Maybe<A.Motion>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (rows,None{}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "accepted")
        return rows
    case (rows,Some{owner}): rejected_main(prefix,rows,A.motion_observe(owner))
def take_observed(prefix: String,id: U32,rows: S.Rows<A.Motion,A.Health,Unit>,result: A.Motion & String) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (owner,text):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ text)
        rows : S.Rows<A.Motion,A.Health,Unit> <- put_print("put-back:",S.put_rows(A.Motion,A.Health,Unit,rows,id,owner))
        return rows
def taken_print(prefix: String,+id: U32,result: S.Rows<A.Motion,A.Health,Unit> & S.Taken<A.Motion>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (rows,S.NoEntity{}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "missing")
        return rows
    case (rows,S.NoMain{}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "no-main")
        return rows
    case (rows,S.Taken{owner}): take_observed(prefix,id,rows,A.motion_observe(owner))
def removal_restore_observed(rows: S.Rows<A.Motion,A.Health,Unit>,result: S.Row<A.Motion,A.Health,Unit> & String) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (row,text):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print("rollback-detached:" ++ text)
        return S.rows_restore(A.Motion,A.Health,Unit,rows,row)
def removal_restore(result: S.Rows<A.Motion,A.Health,Unit> & Maybe<S.Row<A.Motion,A.Health,Unit>>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (rows,None{}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print("rollback-detached:missing")
        return rows
    case (rows,Some{row}): removal_restore_observed(rows,row_observe(row))
def bool_text(value: Bool) -> String:
  match value:
    case True{}: "live"
    case False{}: "dead"
def physical_done(prefix: String,m: Array<Maybe<A.Motion>>,a: Array<Maybe<A.Health>>,c: U32,d: Nat,h: U32,result: S.MetadataColumns<Unit> & S.Metadata<Unit>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (metadata,S.Metadata{live,flag,added,changed}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ bool_text(live) ++ "|" ++ flag_text(flag) ++ "|" ++ U32.show(added) ++ ":" ++ U32.show(changed))
        return S.Rows{m,a,metadata,c,d,h}
def physical(prefix: String,rows: S.Rows<A.Motion,A.Health,Unit>,id: U32) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match rows:
    case S.Rows{m,a,metadata,c,d,h}: physical_done(prefix,m,a,c,d,h,S.metadata_get(Unit,metadata,U32.sub(id,1)))
def main() -> IO(Unit):
  do IO<Unit>:
    rows : S.Rows<A.Motion,A.Health,Unit> = S.rows_empty(A.Motion,A.Health,Unit)
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("insert1:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{1,Some{make_motion(10)},Some{make_health(110)},Some{Unit{}},1,2}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("insert2:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{2,None{},Some{make_health(120)},None{},3,4}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("insert4:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{4,Some{make_motion(40)},Some{make_health(140)},None{},5,6}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("insert8:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{8,Some{make_motion(80)},Some{make_health(180)},Some{Unit{}},7,8}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("insert65537:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{65537,Some{make_motion(90)},Some{make_health(190)},Some{Unit{}},9,10}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- metadata_print(rows)
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("first:",S.rows_extract(A.Motion,A.Health,Unit,rows,1))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("no-main:",S.rows_extract(A.Motion,A.Health,Unit,rows,2))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("middle:",S.rows_extract(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("oldlast:",S.rows_extract(A.Motion,A.Health,Unit,rows,8))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("last:",S.rows_extract(A.Motion,A.Health,Unit,rows,65537))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("zero:",S.rows_extract(A.Motion,A.Health,Unit,rows,0))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("hole:",S.rows_extract(A.Motion,A.Health,Unit,rows,3))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("out:",S.rows_extract(A.Motion,A.Health,Unit,rows,131073))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("max:",S.rows_extract(A.Motion,A.Health,Unit,rows,4294967295))
    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("physical-hole:",rows,3)
    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("physical-live:",rows,4)
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = S.World{7,65538,rows,[],None{},Unit{}}
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> <- main_print("roundtrip:",S.with_main(Unit,A.Motion,A.Health,Unit,Unit,Unit,String,world,S.Handle{7,4},A.motion_roundtrip))
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> <- main_print("mismatch:",S.with_main(Unit,A.Motion,A.Health,Unit,Unit,Unit,String,world,S.Handle{7,2},A.motion_observe))
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> <- main_print("foreign:",S.with_main(Unit,A.Motion,A.Health,Unit,Unit,Unit,String,world,S.Handle{8,1},A.motion_observe))
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = X.storage_mark_all(Unit,A.Motion,A.Health,Unit,Unit,Unit,[S.Handle{7,4},S.Handle{7,4},S.Handle{8,1},S.Handle{7,0},S.Handle{7,3},S.Handle{7,65538},S.Handle{7,131073},S.Handle{7,4294967295}],world,77)
    rows : S.Rows<A.Motion,A.Health,Unit> = extract_world(world)
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("marked:",S.rows_extract(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("reject0:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{0,Some{make_motion(200)},Some{make_health(210)},Some{Unit{}},11,12}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("rejectmax:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{4294967295,Some{make_motion(220)},Some{make_health(230)},None{},13,14}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("rejectoccupied:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{1,Some{make_motion(240)},Some{make_health(250)},None{},15,16}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("retained-first:",S.rows_extract(A.Motion,A.Health,Unit,rows,1))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("retained-last:",S.rows_extract(A.Motion,A.Health,Unit,rows,65537))
    rows : S.Rows<A.Motion,A.Health,Unit> <- taken_print("take-main:",1,S.take_rows(A.Motion,A.Health,Unit,rows,1))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("after-put:",S.rows_extract(A.Motion,A.Health,Unit,rows,1))
    rows : S.Rows<A.Motion,A.Health,Unit> <- taken_print("take-empty:",2,S.take_rows(A.Motion,A.Health,Unit,rows,2))
    rows : S.Rows<A.Motion,A.Health,Unit> <- taken_print("take-hole:",3,S.take_rows(A.Motion,A.Health,Unit,rows,3))
    rows : S.Rows<A.Motion,A.Health,Unit> <- put_print("put-zero:",S.put_rows(A.Motion,A.Health,Unit,rows,0,make_motion(700)))
    rows : S.Rows<A.Motion,A.Health,Unit> <- put_print("put-hole:",S.put_rows(A.Motion,A.Health,Unit,rows,3,make_motion(710)))
    rows : S.Rows<A.Motion,A.Health,Unit> <- effect_print("main-add:",S.rows_replace_main(A.Motion,A.Health,Unit,rows,2,Some{make_motion(20)},50))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("main-added:",S.rows_extract(A.Motion,A.Health,Unit,rows,2))
    rows : S.Rows<A.Motion,A.Health,Unit> <- effect_print("main-change:",S.rows_replace_main(A.Motion,A.Health,Unit,rows,2,Some{make_motion(21)},51))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("main-changed:",S.rows_extract(A.Motion,A.Health,Unit,rows,2))
    rows : S.Rows<A.Motion,A.Health,Unit> <- effect_print("main-remove:",S.rows_replace_main(A.Motion,A.Health,Unit,rows,2,None{},52))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("main-removed:",S.rows_extract(A.Motion,A.Health,Unit,rows,2))
    rows : S.Rows<A.Motion,A.Health,Unit> <- effect_print("main-again:",S.rows_replace_main(A.Motion,A.Health,Unit,rows,2,None{},53))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("main-unchanged:",S.rows_extract(A.Motion,A.Health,Unit,rows,2))
    rows : S.Rows<A.Motion,A.Health,Unit> <- effect_print("main-stale:",S.rows_replace_main(A.Motion,A.Health,Unit,rows,131073,Some{make_motion(99)},54))
    rows : S.Rows<A.Motion,A.Health,Unit> <- removal_restore(S.rows_remove(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("physical-rollback:",rows,4)
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("rollback-restored:",S.rows_extract(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- remove_print("removed:",S.rows_remove(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("physical-tombstone:",rows,4)
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("tombstone:",S.rows_extract(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- remove_print("repeat-remove:",S.rows_remove(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- placement_print("reinstall:",S.rows_place(A.Motion,A.Health,Unit,rows,S.Row{4,Some{make_motion(400)},Some{make_health(410)},Some{Unit{}},81,82}))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("reinstalled:",S.rows_extract(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- metadata_print(rows)
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = S.World{7,65538,rows,[],None{},Unit{}}
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = X.storage_mark_all(Unit,A.Motion,A.Health,Unit,Unit,Unit,[S.Handle{7,8},S.Handle{7,4},S.Handle{7,1},S.Handle{7,4}],world,99)
    rows : S.Rows<A.Motion,A.Health,Unit> = extract_world(world)
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-nonmonotonic-1:",S.rows_extract(A.Motion,A.Health,Unit,rows,1))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-nonmonotonic-4:",S.rows_extract(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-nonmonotonic-8:",S.rows_extract(A.Motion,A.Health,Unit,rows,8))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-nonmonotonic-65537:",S.rows_extract(A.Motion,A.Health,Unit,rows,65537))
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = S.World{7,65538,rows,[],None{},Unit{}}
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = X.storage_mark_all(Unit,A.Motion,A.Health,Unit,Unit,Unit,[],world,101)
    rows : S.Rows<A.Motion,A.Health,Unit> = extract_world(world)
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-empty-1:",S.rows_extract(A.Motion,A.Health,Unit,rows,1))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-empty-4:",S.rows_extract(A.Motion,A.Health,Unit,rows,4))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-empty-8:",S.rows_extract(A.Motion,A.Health,Unit,rows,8))
    rows : S.Rows<A.Motion,A.Health,Unit> <- lookup_print("batch-empty-65537:",S.rows_extract(A.Motion,A.Health,Unit,rows,65537))
    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("batch-hole:",rows,3)
    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("batch-above-high:",rows,65538)
    rows : S.Rows<A.Motion,A.Health,Unit> <- remove_print("batch-remove8:",S.rows_remove(A.Motion,A.Health,Unit,rows,8))
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = S.World{7,65538,rows,[],None{},Unit{}}
    world : S.World<Unit,A.Motion,A.Health,Unit,Unit,Unit> = X.storage_mark_all(Unit,A.Motion,A.Health,Unit,Unit,Unit,[S.Handle{7,8},S.Handle{7,3},S.Handle{7,65538}],world,103)
    rows : S.Rows<A.Motion,A.Health,Unit> = extract_world(world)
    rows : S.Rows<A.Motion,A.Health,Unit> <- physical("batch-dead:",rows,8)
    return Unit{}
