import Base
import ./storage.bend as S
import ./query.bend as Q
import ./commands.bend as C
import ./types.bend as T
import ./owners.bend as A

type QuerySchemaOne is Data:
  QuerySchemaOne{}

def make_motion(+base: U32) -> A.Motion:
  A.Motion{Array.set(U32,Array.set(U32,Array.set(U32,[base : U32^2n],1,U32.add(base,1)),2,U32.add(base,2)),3,U32.add(base,3)),base}
def make_health(+base: U32) -> A.Health:
  A.Health{Array.set(U32,Array.set(U32,Array.set(U32,[base : U32^2n],1,U32.add(base,1)),2,U32.add(base,2)),3,U32.add(base,3)),base}
def flag_text(flag: Maybe<&2,Unit>) -> String:
  match flag:
    case None{}: "absent"
    case Some{_}: "present"
def access_text(result: T.Access<String>) -> String:
  match result:
    case T.Missing{}: "missing"
    case T.Mismatch{}: "mismatch"
    case T.Found{text}: text
def motion_some(result: A.Motion & String) -> Maybe<A.Motion> & String:
  match result:
    case (owner,text): (Some{owner},text)
def health_some(result: A.Health & String) -> Maybe<A.Health> & String:
  match result:
    case (owner,text): (Some{owner},text)
def optional_text(value: Maybe<&2,String>) -> String:
  match value:
    case None{}: "none"
    case Some{value}: value
def callback_aux(-P: Type,-U: Type,flag: Maybe<&2,Unit>,text: String,p: P,result: S.Handle<QuerySchemaOne> & (U & Maybe<&2,String>)) -> P & (U & String):
  match result:
    case (S.Handle{namespace,id},(u,value)): (p,(u,U32.show(namespace) ++ ":" ++ U32.show(id) ++ "|" ++ text ++ "|" ++ optional_text(value) ++ "|" ++ flag_text(flag)))
def callback_main(~P: Type,~U: Type,~get_aux: U -> U & Maybe<&2,String>,handle: S.Handle<QuerySchemaOne>,flag: Maybe<&2,Unit>,u: U,result: P & String) -> P & (U & String):
  match result:
    case (p,text): callback_aux(P,U,flag,text,p,(handle,get_aux(u)))
def callback(~P: Type,~U: Type,~get_main: P -> Unit -> P & String,~get_aux: U -> U & Maybe<&2,String>,handle: S.Handle<QuerySchemaOne>,flag: Maybe<&2,Unit>,p: P,u: U) -> P & (U & String):
  callback_main(~P,~U,~get_aux,handle,flag,u,get_main(p,Unit{}))
def prototype_owner_callback_aux(-P: Type,-U: Type,flag: Maybe<&2,Unit>,text: String,p: P,result: S.Handle<QuerySchemaOne> & (U & Maybe<&2,String>)) -> Q.PrototypeOwnerResult<P,U,String>:
  match result:
    case (S.Handle{namespace,id},(u,value)): Q.PrototypeOwnerResult{p,u,U32.show(namespace) ++ ":" ++ U32.show(id) ++ "|" ++ text ++ "|" ++ optional_text(value) ++ "|" ++ flag_text(flag)}

def prototype_owner_callback_main(~P: Type,~U: Type,~get_aux: U -> U & Maybe<&2,String>,handle: S.Handle<QuerySchemaOne>,flag: Maybe<&2,Unit>,u: U,result: P & String) -> Q.PrototypeOwnerResult<P,U,String>:
  match result:
    case (p,text): prototype_owner_callback_aux(P,U,flag,text,p,(handle,get_aux(u)))

def prototype_owner_callback(~P: Type,~U: Type,~get_main: P -> Unit -> P & String,~get_aux: U -> U & Maybe<&2,String>,handle: S.Handle<QuerySchemaOne>,flag: Maybe<&2,Unit>,p: P,u: U) -> Q.PrototypeOwnerResult<P,U,String>:
  prototype_owner_callback_main(~P,~U,~get_aux,handle,flag,u,get_main(p,Unit{}))
def strings(values: List<&2,String>) -> String:
  match values:
    case Nil{}: "end"
    case Con{value,tail}: value ++ ";" ++ strings(tail)
def each_print(prefix: String,result: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & List<&2,String>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  match result:
    case (world,values):
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ strings(values))
        return world
def each(prefix: String,selection: Q.Selection,world: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  each_print(prefix,Q.prototype_owner_each(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,String,String,String,Unit,Unit,A.motion_observe,A.health_observe,prototype_owner_callback,selection,world))
def lookup_print(prefix: String,result: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & T.Access<String>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  match result:
    case (world,observation):
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ access_text(observation))
        return world
def lookup(prefix: String,selection: Q.Selection,world: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>,handle: S.Handle<QuerySchemaOne>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  lookup_print(prefix,Q.lookup(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,String,String,String,Unit,Unit,A.motion_observe,A.health_observe,callback,selection,world,handle))
def queued(-Payload: Type,prefix: String,result: T.CommandResult<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>,Payload>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  match result:
    case T.CommandQueued{world}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ "queued")
        return world
    case T.CommandMissing{world,_}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ "missing")
        return world
def reserved(prefix: String,result: T.Reservation<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>,S.Handle<QuerySchemaOne>,S.Bundle<A.Motion,A.Health,Unit>>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  match result:
    case T.Reserved{world,S.Handle{namespace,id}}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ U32.show(namespace) ++ ":" ++ U32.show(id))
        return world
    case T.ReserveRejected{world,_}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ "rejected")
        return world
def applied(prefix: String,result: C.CheckedApply<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  match result:
    case C.Applied{world,_}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ "applied")
        return world
    case C.CapacityRejected{world}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ "capacity-rejected")
        return world
    case C.InvariantFault{world,_,_}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        IO.print(prefix ++ "invariant-fault")
        return world
def row_main(value: Maybe<A.Motion>) -> Maybe<A.Motion> & String:
  match value:
    case None{}: (None{},"none")
    case Some{value}: motion_some(A.motion_observe(value))
def row_aux(value: Maybe<A.Health>) -> Maybe<A.Health> & String:
  match value:
    case None{}: (None{},"none")
    case Some{value}: health_some(A.health_observe(value))
def row_observed(+id: U32,+flag: Maybe<&2,Unit>,+added: U32,+changed: U32,result: (Maybe<A.Motion> & String) & (Maybe<A.Health> & String)) -> S.Row<A.Motion,A.Health,Unit> & String:
  match result:
    case ((m,mt),(a,at)): (S.Row{id,m,a,flag,added,changed},U32.show(id) ++ "|" ++ mt ++ "|" ++ at ++ "|" ++ flag_text(flag) ++ "|" ++ U32.show(added) ++ ":" ++ U32.show(changed))
def row_observe(row: S.Row<A.Motion,A.Health,Unit>) -> S.Row<A.Motion,A.Health,Unit> & String:
  match row:
    case S.Row{id,m,a,flag,added,changed}: row_observed(id,flag,added,changed,(row_main(m),row_aux(a)))
def row_print(prefix: String,rows: S.Rows<A.Motion,A.Health,Unit>,result: S.Row<A.Motion,A.Health,Unit> & String) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (row,text):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ text)
        return S.rows_restore(A.Motion,A.Health,Unit,rows,row)
def extracted_print(prefix: String,result: S.Rows<A.Motion,A.Health,Unit> & Maybe<S.Row<A.Motion,A.Health,Unit>>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match result:
    case (rows,None{}):
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print(prefix ++ "missing")
        return rows
    case (rows,Some{row}): row_print(prefix,rows,row_observe(row))
def rows_shape(rows: S.Rows<A.Motion,A.Health,Unit>) -> IO(S.Rows<A.Motion,A.Health,Unit>):
  match rows:
    case S.Rows{m,a,metadata,+c,+d,+h}:
      do IO<S.Rows<A.Motion,A.Health,Unit>>:
        IO.print("shape:" ++ U32.show(c) ++ ":" ++ Nat.show(d) ++ ":" ++ U32.show(h))
        return S.Rows{m,a,metadata,c,d,h}
def snapshot(prefix: String,world: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>,id: U32) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        rows : S.Rows<A.Motion,A.Health,Unit> <- extracted_print(prefix,S.rows_extract(A.Motion,A.Health,Unit,rows,id))
        return S.World{namespace,next,rows,pending,ledger,mode}
def shape(world: S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>) -> IO(S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>):
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}:
      do IO<S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>>:
        rows : S.Rows<A.Motion,A.Health,Unit> <- rows_shape(rows)
        return S.World{namespace,next,rows,pending,ledger,mode}
def main() -> IO(Unit):
  do IO<Unit>:
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> = S.World{7,1,S.rows_empty(A.Motion,A.Health,Unit),[],None{},Unit{}}
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- reserved("spawn1:",C.reserve(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Bundle{Some{make_motion(10)},Some{make_health(110)},Some{Unit{}}}))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- reserved("spawn2:",C.reserve(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Bundle{None{},Some{make_health(120)},None{}}))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- reserved("spawn3:",C.reserve(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Bundle{Some{make_motion(30)},None{},None{}}))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("before-barrier:",Q.Required{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- applied("barrier10:",C.apply_checked(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,10))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- shape(world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("initial-required:",Q.Required{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("initial-present:",Q.Present{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("initial-absent:",Q.Absent{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("initial-optional:",Q.Optional{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("row1:",world,1)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("row2:",world,2)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("row3:",world,3)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- queued(Unit,"flag3:",C.insert_flag(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Handle{7,3},Unit{}))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- queued(Unit,"unflag1:",C.remove_flag(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Handle{7,1}))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- queued(A.Motion,"main2:",C.insert_main(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Handle{7,2},make_motion(20)))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("queued-required:",Q.Required{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- applied("barrier20:",C.apply_checked(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,20))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("updated-required:",Q.Required{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("updated-present:",Q.Present{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("updated-absent:",Q.Absent{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("updated-row1:",world,1)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("updated-row2:",world,2)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("updated-row3:",world,3)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- queued(Unit,"despawn2:",C.despawn(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Handle{7,2}))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- reserved("spawn4:",C.reserve(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,S.Bundle{Some{make_motion(40)},Some{make_health(140)},Some{Unit{}}}))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- applied("barrier30:",C.apply_checked(QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit,world,30))
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("final-required:",Q.Required{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("final-present:",Q.Present{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("final-absent:",Q.Absent{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- each("final-optional:",Q.Optional{},world)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- lookup("lookup1-present:",Q.Present{},world,S.Handle{7,1})
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- lookup("lookup3-absent:",Q.Absent{},world,S.Handle{7,3})
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- lookup("lookup2-hole:",Q.Required{},world,S.Handle{7,2})
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- lookup("lookup4:",Q.Optional{},world,S.Handle{7,4})
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- lookup("lookup-foreign:",Q.Required{},world,S.Handle{8,1})
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("final-row1:",world,1)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("final-row2:",world,2)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("final-row3:",world,3)
    world : S.World<QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> <- snapshot("final-row4:",world,4)
    return Unit{}
