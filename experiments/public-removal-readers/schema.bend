import Base
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/structural.bend as St
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/removals.bend as Rm

type Schema is Data:
  Schema{}
type AToken is Data:
  AToken{}
type BToken is Data:
  BToken{}
type AllToken is Data:
  AFamily{}
  BFamily{}
type Owner is Type:
  Owner{array: Array<U32>}
type Store is Type:
  Store{a: Col.Column<Schema,Owner>,b: Col.Column<Schema,Owner>}
type Notice is Data:
  ARemoved{handle: W.Handle<Schema>}
  BRemoved{handle: W.Handle<Schema>}
  Gone{handle: W.Handle<Schema>}

def empty(unit: Unit) -> Store:
  Store{Col.empty(~Schema,~Owner),Col.empty(~Schema,~Owner)}
def take_a(store: Store) -> Col.Column<Schema,Owner> & Col.Column<Schema,Owner>:
  match store:
    case Store{a,b}: (b,a)
def put_a(b: Col.Column<Schema,Owner>,a: Col.Column<Schema,Owner>) -> Store:
  Store{a,b}
def take_b(store: Store) -> Col.Column<Schema,Owner> & Col.Column<Schema,Owner>:
  match store:
    case Store{a,b}: (a,b)
def put_b(a: Col.Column<Schema,Owner>,b: Col.Column<Schema,Owner>) -> Store:
  Store{a,b}
def projected(observed: Array<U32> & U32) -> Owner & U32:
  (array,value) = observed
  (Owner{array},value)
def project(owner: Owner) -> Owner & U32:
  match owner:
    case Owner{array}:
      projected(Array.get(U32,array,0))
def a_record(handle: W.Handle<Schema>) -> Notice:
  ARemoved{handle}
def b_record(handle: W.Handle<Schema>) -> Notice:
  BRemoved{handle}
def gone_record(handle: W.Handle<Schema>) -> Notice:
  Gone{handle}
def selected(notice: Notice) -> Maybe<&2,Rm.Record<Schema,AllToken>>:
  match notice:
    case ARemoved{handle}: Some{Rm.Removed{handle,AFamily{}}}
    case BRemoved{handle}: Some{Rm.Removed{handle,BFamily{}}}
    case Gone{handle}: Some{Rm.Despawned{handle}}
def selected_a(notice: Notice) -> Maybe<&2,Rm.Record<Schema,AToken>>:
  match notice:
    case ARemoved{handle}: Some{Rm.Removed{handle,AToken{}}}
    case _: None{}
def replacement(result: F.Replacement<W.World<Schema,Store,Unit,Notice>,Owner>) -> W.World<Schema,Store,Unit,Notice>:
  match result:
    case F.Replaced{world,_}: world
    case F.ReplaceRejected{world,_,_}: world
def insert_a(world: W.World<Schema,Store,Unit,Notice>,handle: W.Handle<Schema>,value: U32) -> W.World<Schema,Store,Unit,Notice>:
  replacement(F.replace(~Schema,~Store,~Unit,~Notice,~Col.Column<Schema,Owner>,~Owner,~U32,~AToken,~take_a,~put_a,~project,F.Family{"A"},world,handle,Some{Owner{Array.new(U32,0n,value)}}))
def insert_b(world: W.World<Schema,Store,Unit,Notice>,handle: W.Handle<Schema>,value: U32) -> W.World<Schema,Store,Unit,Notice>:
  replacement(F.replace(~Schema,~Store,~Unit,~Notice,~Col.Column<Schema,Owner>,~Owner,~U32,~BToken,~take_b,~put_b,~project,F.Family{"B"},world,handle,Some{Owner{Array.new(U32,0n,value)}}))
def queued(result: St.Queued<T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>,Owner>) -> T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>:
  match result:
    case St.Queued{tx}: tx
    case St.QueueRejected{tx,_,_}: tx

def remove_a(tx: T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>,handle: W.Handle<Schema>) -> T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>:
  queued(St.tx_remove_observed(~Schema,~Store,~Unit,~Notice,~Col.Column<Schema,Owner>,~Owner,~U32,~AToken,~take_a,~put_a,~project,~a_record,F.Family{"A"},tx,handle))

def cleanup_a(handle: W.Handle<Schema>,result: Col.SwapOutcome<Schema,Owner>) -> Col.Column<Schema,Owner> & List<&2,Notice>:
  match result:
    case Col.Accepted{column,None{}}: (column,[])
    case Col.Accepted{column,Some{owner}}: (column,[ARemoved{handle}])
    case Col.Rejected{column,_}: (column,[])
def cleanup_b(handle: W.Handle<Schema>,result: Col.SwapOutcome<Schema,Owner>) -> Col.Column<Schema,Owner> & List<&2,Notice>:
  match result:
    case Col.Accepted{column,None{}}: (column,[])
    case Col.Accepted{column,Some{owner}}: (column,[BRemoved{handle}])
    case Col.Rejected{column,_}: (column,[])
def cleanup_join(a: Col.Column<Schema,Owner> & List<&2,Notice>,b: Col.Column<Schema,Owner> & List<&2,Notice>) -> Store & List<&2,Notice>:
  (a,as) = a
  (b,bs) = b
  (Store{a,b},List.append(&2,Notice,as,bs))
def clear(store: Store,handle: W.Handle<Schema>) -> Store & List<&2,Notice>:
  match store handle:
    case Store{a,b} W.Handle{+ns,+id}: cleanup_join(cleanup_a(W.Handle{ns,id},Col.clear(~Schema,~Owner,a,id)),cleanup_b(W.Handle{ns,id},Col.clear(~Schema,~Owner,b,id)))
def despawn_join(result: T.Tx<W.World<Schema,Store,Unit,Notice>,Notice> & W.Status) -> T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>:
  (tx,status) = result
  tx
def despawn(tx: T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>,handle: W.Handle<Schema>) -> T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>:
  despawn_join(Cmd.tx_despawn_observed(~Schema,~Store,~Unit,~Notice,~clear,~gone_record,tx,handle))

def committed(result: T.Returned<W.World<Schema,Store,Unit,Notice>,Unit>) -> W.World<Schema,Store,Unit,Notice>:
  match result:
    case T.Returned{world,_}: world

def finish(tx: T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>,outcome: T.Outcome<Unit>) -> W.World<Schema,Store,Unit,Notice>:
  committed(Cmd.tx_finish(~Schema,~Store,~Unit,~Notice,~Unit,tx,outcome))

def record_text(record: Rm.Record<Schema,AllToken>) -> String:
  match record:
    case Rm.Removed{W.Handle{_,id},AFamily{}}: "A" ++ U32.show(id) ++ ";"
    case Rm.Removed{W.Handle{_,id},BFamily{}}: "B" ++ U32.show(id) ++ ";"
    case Rm.Despawned{W.Handle{_,id}}: "D" ++ U32.show(id) ++ ";"
def records_text(records: List<&2,Rm.Record<Schema,AllToken>>) -> String:
  match records:
    case []: ""
    case record <> rest: record_text(record) ++ records_text(rest)
def consume(records: List<&2,Rm.Record<Schema,AllToken>>) -> Result<&2,&1,Unit,String>:
  Done{records_text(records)}
def reject(records: List<&2,Rm.Record<Schema,AllToken>>) -> Result<&2,&1,Unit,String>:
  Fail{Unit{}}

def maybe_text(value: Maybe<&2,U32>) -> String:
  match value:
    case None{}: "-"
    case Some{value}: U32.show(value)
def column_second(first: String,observed: Col.Column<Schema,Owner> & Maybe<&2,U32>) -> Col.Column<Schema,Owner> & String:
  (column,value) = observed
  (column,first ++ "," ++ maybe_text(value))
def column_first(observed: Col.Column<Schema,Owner> & Maybe<&2,U32>) -> Col.Column<Schema,Owner> & String:
  (column,value) = observed
  column_second(maybe_text(value),Col.view(~Schema,~Owner,~U32,~project,column,2))
def column_text(column: Col.Column<Schema,Owner>) -> Col.Column<Schema,Owner> & String:
  column_first(Col.view(~Schema,~Owner,~U32,~project,column,1))
def store_text_join(a: Col.Column<Schema,Owner> & String,b: Col.Column<Schema,Owner> & String) -> Store & String:
  (a,at) = a
  (b,bt) = b
  (Store{a,b},"A=" ++ at ++ ";B=" ++ bt)
def store_text(store: Store) -> Store & String:
  match store:
    case Store{a,b}: store_text_join(column_text(a),column_text(b))

def stage_a(tx: T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>,handle: W.Handle<Schema>,value: U32) -> T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>:
  queued(St.tx_insert(~Schema,~Store,~Unit,~Notice,~Col.Column<Schema,Owner>,~Owner,~U32,~AToken,~take_a,~put_a,~project,F.Family{"A"},tx,handle,Owner{Array.new(U32,0n,value)}))
def stage_b(tx: T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>,handle: W.Handle<Schema>,value: U32) -> T.Tx<W.World<Schema,Store,Unit,Notice>,Notice>:
  queued(St.tx_insert(~Schema,~Store,~Unit,~Notice,~Col.Column<Schema,Owner>,~Owner,~U32,~BToken,~take_b,~put_b,~project,F.Family{"B"},tx,handle,Owner{Array.new(U32,0n,value)}))
def seed(world: W.World<Schema,Store,Unit,Notice>,+one: W.Handle<Schema>,+two: W.Handle<Schema>) -> W.World<Schema,Store,Unit,Notice>:
  tx = T.begin(~W.World<Schema,Store,Unit,Notice>,~Notice,world)
  tx = stage_a(tx,one,11)
  tx = stage_b(tx,one,21)
  tx = stage_a(tx,two,12)
  tx = stage_b(tx,two,22)
  W.barrier(~Schema,~Store,~Unit,~Notice,finish(tx,T.Success{}))

def access_text(access: F.Access<U32>) -> String:
  match access:
    case F.Found{value}: "found:" ++ U32.show(value)
    case F.ComponentAbsent{}: "absent"
    case F.MissingEntity{}: "missing"
def lookup_text(result: W.World<Schema,Store,Unit,Notice> & F.Access<U32>) -> W.World<Schema,Store,Unit,Notice> & String:
  (world,access) = result
  (world,access_text(access))
def lookup_a(world: W.World<Schema,Store,Unit,Notice>,handle: W.Handle<Schema>) -> W.World<Schema,Store,Unit,Notice> & String:
  lookup_text(F.get(~Schema,~Store,~Unit,~Notice,~Col.Column<Schema,Owner>,~Owner,~U32,~AToken,~take_a,~put_a,~project,F.Family{"A"},world,handle))
