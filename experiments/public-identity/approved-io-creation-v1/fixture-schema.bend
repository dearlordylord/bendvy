import /workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/src/ecs/transaction.bend as T
import Base
import /workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/experiments/public-schedule-readers/schema.bend as S
import /workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/src/ecs/removals.bend as Rm
import /workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/experiments/public-identity/approved-io-creation-v1/fixture-reservation.bend as R

def bundle(+value:U32) -> S.Bundle:
  S.Bundle{Some{S.stock_payload(value)},Some{S.recipe_payload(value)},Some{S.queue_payload(value)},Some{S.Enabled{}},Some{S.Locked{}}}
def Owner() -> Type: R.Owner<S.Schema,S.Store,Unit,S.Notice>
def Tx() -> Type: R.Tx<S.Schema,S.Store,Unit,S.Notice>
def bind(~A:Type,~B:Type,~Out:Type,body:A -> B -> Out,pair:A & B) -> Out:
  (a,b)=pair
  body(a,b)
def status(result:W.Status) -> String:
  match result:
    case W.Accepted{}: "accepted"
    case W.Rejected{W.MissingEntity{}}: "MissingEntity"
    case W.Rejected{W.CapacityExceeded{}}: "CapacityExceeded"
    case _: "unexpected"
def handle(handle:W.Handle<S.Schema>) -> String:
  match handle:
    case W.Handle{ns,id}: U32.show(ns) ++ ":" ++ U32.show(id)
def notice(value:S.Notice) -> String:
  match value:
    case S.RemovedStock{h}: "stock:" ++ handle(h)
    case S.RemovedAux{h}: "queue:" ++ handle(h)
    case S.Gone{h}: "gone:" ++ handle(h)
    case S.Ping{n}: "ping:" ++ U32.show(n)
def view_stock(value:C.Access<S.StockView>) -> String:
  match value:
    case C.Found{S.StockView{n,owned}}: U32.show(n) ++ ":" ++ List.show(&2,U32,U32.show,owned)
    case C.ComponentAbsent{}: "absent"
    case C.MissingEntity{}: "MissingEntity"
def view_recipe(value:C.Access<S.RecipeView>) -> String:
  match value:
    case C.Found{S.RecipeView{n,owned}}: U32.show(n) ++ ":" ++ List.show(&2,U32,U32.show,owned)
    case C.ComponentAbsent{}: "absent"
    case C.MissingEntity{}: "MissingEntity"
def view_queue(value:C.Access<S.QueueView>) -> String:
  match value:
    case C.Found{S.QueueView{n,owned}}: U32.show(n) ++ ":" ++ List.show(&2,U32,U32.show,owned)
    case C.ComponentAbsent{}: "absent"
    case C.MissingEntity{}: "MissingEntity"
# Trusted observation of physical typed columns, including a retired slot.
# These return the complete Store; they are not gameplay liveness bypasses.
def stock(store:S.Store,id:U32) -> S.Store & C.Access<S.StockView>:
  C.get_store(~S.Schema,~S.Store,~Unit,~S.Notice,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,id,S.take_stock(store))
def recipe(store:S.Store,id:U32) -> S.Store & C.Access<S.RecipeView>:
  C.get_store(~S.Schema,~S.Store,~Unit,~S.Notice,~S.RecipeRest,~S.Recipe,~S.RecipeView,~S.RecipeToken,~S.take_recipe,~S.put_recipe,~S.project_recipe,id,S.take_recipe(store))
def queue(store:S.Store,id:U32) -> S.Store & C.Access<S.QueueView>:
  C.get_store(~S.Schema,~S.Store,~Unit,~S.Notice,~S.QueueRest,~S.Queue,~S.QueueView,~S.QueueToken,~S.take_queue,~S.put_queue,~S.project_queue,id,S.take_queue(store))
def present(~V:Data,value:C.Access<V>) -> String:
  match value:
    case C.Found{_}: "present"
    case C.ComponentAbsent{}: "absent"
    case C.MissingEntity{}: "MissingEntity"
def enabled(store:S.Store,id:U32) -> S.Store & C.Access<S.Enabled>:
  C.get_store(~S.Schema,~S.Store,~Unit,~S.Notice,~S.EnabledRest,~S.Enabled,~S.Enabled,~S.EnabledToken,~S.take_enabled,~S.put_enabled,~S.project_enabled,id,S.take_enabled(store))
def locked(store:S.Store,id:U32) -> S.Store & C.Access<S.Locked>:
  C.get_store(~S.Schema,~S.Store,~Unit,~S.Notice,~S.LockedRest,~S.Locked,~S.Locked,~S.LockedToken,~S.take_locked,~S.put_locked,~S.project_locked,id,S.take_locked(store))
def markers(world:S.World(),+id:U32,text:String) -> S.World() & String:
  bind(~S.World(),~C.Access<S.Enabled>,~S.World() & String,(world => a =>
    bind(~S.World(),~C.Access<S.Locked>,~S.World() & String,(world => b => (world,text ++ ",enabled=" ++ present(~S.Enabled,a) ++ ",locked=" ++ present(~S.Locked,b) ++ "}")),W.with_store(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Access<S.Locked>,(store => locked(store,id)),world))
  ),W.with_store(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Access<S.Enabled>,(store => enabled(store,id)),world))
def physical(world:S.World(),+id:U32) -> S.World() & String:
  bind(~S.World(),~C.Access<S.StockView>,~S.World() & String,(world => a =>
    bind(~S.World(),~C.Access<S.RecipeView>,~S.World() & String,(world => b =>
      bind(~S.World(),~C.Access<S.QueueView>,~S.World() & String,(world => c => markers(world,id,"slot" ++ U32.show(id) ++ "{stock=" ++ view_stock(a) ++ ",recipe=" ++ view_recipe(b) ++ ",queue=" ++ view_queue(c))),W.with_store(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Access<S.QueueView>,(store => queue(store,id)),world))
    ),W.with_store(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Access<S.RecipeView>,(store => recipe(store,id)),world))
  ),W.with_store(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Access<S.StockView>,(store => stock(store,id)),world))
def metadata(world:S.World()) -> S.World() & String:
  match world:
    case W.World{+ns,+next,+high,live,+capacity,+depth,store,resource,+events,pending,+registrations,+system,+clock}: (W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,system,clock},"ns=" ++ U32.show(ns) ++ "|next=" ++ U32.show(next) ++ "|high=" ++ U32.show(high) ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|clock=" ++ U32.show(clock) ++ "|events=" ++ List.show(&2,S.Notice,notice,events) ++ "|registrations=" ++ Nat.show(List.length(&2,W.RegistrationMeta,registrations)) ++ "|nextSystem=" ++ U32.show(system))
def snapshot(world:S.World(),label:String) -> S.World() & String:
  bind(~S.World(),~String,~S.World() & String,(world => a =>
    bind(~S.World(),~String,~S.World() & String,(world => b =>
      bind(~S.World(),~String,~S.World() & String,(world => c =>
        bind(~S.World(),~U32,~S.World() & String,(world => pending =>
          bind(~S.World(),~List<&2,W.Handle<S.Schema>>,~S.World() & String,(world => handles => (world,label ++ "|" ++ a ++ "|" ++ b ++ "|" ++ c ++ "|queue=" ++ U32.show(pending) ++ "|live=" ++ List.show(&2,W.Handle<S.Schema>,handle,handles) ++ "\n")),W.handles(~S.Schema,~S.Store,~Unit,~S.Notice,world))
        ),W.pending_count(~S.Schema,~S.Store,~Unit,~S.Notice,world))
      ),physical(world,2))
    ),physical(world,1))
  ),metadata(world))
def select(value:S.Notice) -> Maybe<&2,Rm.Record<S.Schema,S.AllToken>>:
  match value:
    case S.RemovedStock{h}: Some{Rm.Removed{h,S.StockFamily{}}}
    case S.RemovedAux{h}: Some{Rm.Removed{h,S.AuxFamily{}}}
    case S.Gone{h}: Some{Rm.Despawned{h}}
    case _: None{}
def removed(record:Rm.Record<S.Schema,S.AllToken>) -> String:
  match record:
    case Rm.Removed{h,S.StockFamily{}}: "stock:" ++ handle(h)
    case Rm.Removed{h,S.AuxFamily{}}: "queue:" ++ handle(h)
    case Rm.Despawned{h}: "gone:" ++ handle(h)
def consume(values:List<&2,Rm.Record<S.Schema,S.AllToken>>) -> Result<&2,&1,Unit,String>:
  Done{List.show(&2,Rm.Record<S.Schema,S.AllToken>,removed,values)}

def state(value:R.Entry<S.Schema>) -> String:
  match value:
    case R.Entry{h,R.Pending{}}: handle(h) ++ ":pending"
    case R.Entry{h,R.Live{}}: handle(h) ++ ":live"
    case R.Entry{h,R.Retired{}}: handle(h) ++ ":retired"
def change(value:R.Change<S.Schema>) -> String:
  match value:
    case R.Activate{h}: "activate:" ++ handle(h)
    case R.Retire{h}: "retire:" ++ handle(h)
def tx_counted(label:String,+states:List<&2,R.Entry<S.Schema>>,+before:List<&2,R.Change<S.Schema>>,+changes:List<&2,R.Change<S.Schema>>,+reserved:List<&2,W.Handle<S.Schema>>,world:S.World(),undo:List<(S.World() -> S.World())>,+events:List<&2,S.Notice>,commands:List<(S.World() -> S.World())>,undoCount:U32,count:U32) -> Tx() & String:
  bind(~S.World(),~String,~Tx() & String,(world => text => (R.Tx{T.Tx{world,undo,commands,events},states,before,changes,reserved},text ++ "staged=" ++ U32.show(count) ++ "|undo=" ++ U32.show(undoCount) ++ "|txEvents=" ++ List.show(&2,S.Notice,notice,events) ++ "|states=" ++ List.show(&2,R.Entry<S.Schema>,state,states) ++ "|before=" ++ List.show(&2,R.Change<S.Schema>,change,before) ++ "|changes=" ++ List.show(&2,R.Change<S.Schema>,change,changes) ++ "|reserved=" ++ List.show(&2,W.Handle<S.Schema>,handle,reserved) ++ "\n")),snapshot(world,label))
def tx_commands(label:String,states:List<&2,R.Entry<S.Schema>>,before:List<&2,R.Change<S.Schema>>,changes:List<&2,R.Change<S.Schema>>,reserved:List<&2,W.Handle<S.Schema>>,world:S.World(),undo:List<(S.World() -> S.World())>,events:List<&2,S.Notice>,undoCount:U32,result:List<(S.World() -> S.World())> & U32) -> Tx() & String:
  (commands,count)=result
  tx_counted(label,states,before,changes,reserved,world,undo,events,commands,undoCount,count)
def tx_undo(label:String,states:List<&2,R.Entry<S.Schema>>,before:List<&2,R.Change<S.Schema>>,changes:List<&2,R.Change<S.Schema>>,reserved:List<&2,W.Handle<S.Schema>>,world:S.World(),commands:List<(S.World() -> S.World())>,events:List<&2,S.Notice>,result:List<(S.World() -> S.World())> & U32) -> Tx() & String:
  (undo,count)=result
  tx_commands(label,states,before,changes,reserved,world,undo,events,count,W.pending_length(~S.Schema,~S.Store,~Unit,~S.Notice,commands))
def tx_snapshot(tx:Tx(),label:String) -> Tx() & String:
  match tx:
    case R.Tx{T.Tx{world,undo,commands,events},states,before,changes,reserved}: tx_undo(label,states,before,changes,reserved,world,commands,events,W.pending_length(~S.Schema,~S.Store,~Unit,~S.Notice,undo))

# Planted defect target: keep the actual Stock owner while clearing the rest.
# Only staged mutant systems call this; normal uses the original S.cleanup.
def cleanup_except_stock(store:S.Store,handle:W.Handle<S.Schema>) -> S.Store & List<&2,S.Notice>:
  match store handle:
    case S.Store{stock,recipe,queue,enabled,locked}, W.Handle{+ns,+id}: S.cleanup_join(S.clear_column(~S.Recipe,id,recipe),S.clear_column(~S.Enabled,id,enabled),S.clear_column(~S.Locked,id,locked),(stock,[]),S.clear_aux_result(W.Handle{ns,id},Col.clear(~S.Schema,~S.Queue,queue,id)))
