import Base
import ./types.bend as T
import ./storage.bend as S
import ./payload.bend as P
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./observations.bend as O
import ./host-render.bend as R
import ./held.bend as H
import ./callbacks.bend as B

def quad(+n:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[n:U32^2n],1,U32.add(n,1)),2,U32.add(n,2)),3,U32.add(n,3))
def undo_text(~Z:Data,~handle:Z -> String,values:List<&2,X.Inverse<Z>>) -> String:
  match values:
    case Nil{}: ""
    case Con{X.MainInverse{h,old},rest}: "M" ++ handle(h) ++ ":" ++ U32.show(old) ++ ";" ++ undo_text(Z,handle,rest)
    case Con{X.LedgerInverse{old},rest}: "L:" ++ U32.show(old) ++ ";" ++ undo_text(Z,handle,rest)


def snapshot_row(-V:Data,-AV:Data,-F:Data,selected:Bool,view:V,row:O.RowView<V,AV,F>) -> O.RowView<V,AV,F>:
  match selected row:
    case False{} row: row
    case True{} O.RowView{id,_,aux,flag,added,changed}: O.RowView{id,Some{view},aux,flag,added,changed}
def snapshot_rows(-V:Data,-AV:Data,-F:Data,+view:V,rows:List<&2,O.RowView<V,AV,F>>) -> List<&2,O.RowView<V,AV,F>>:
  match rows:
    case Nil{}: []
    case Con{O.RowView{+id,main,aux,flag,added,changed},tail}: snapshot_row(V,AV,F,U32.is_eq(id,1),view,O.RowView{id,main,aux,flag,added,changed}) <> snapshot_rows(V,AV,F,view,tail)
def ping_text(values:List<&2,U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{x,tail}: U32.show(x) ++ ";" ++ ping_text(tail)

def motion_get(owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,token:T.PositionToken) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.PositionView>:
  match token:
    case T.PositionToken{}: H.main_read(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,T.PositionView,P.position_get,owner)

def motion_ledger(owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,token:T.MotionLedgerToken) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & Maybe<&2,T.LedgerView>:
  match token:
    case T.MotionLedgerToken{}: H.ledger_read(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,T.LedgerView,P.motion_ledger_get,owner)

def motion_set(owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,token:T.PositionToken,value:U32) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>:
  match token:
    case T.PositionToken{}: H.main_write(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,P.position_swap,owner,value)

def motion_setledger(owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,token:T.MotionLedgerToken,value:U32) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>:
  match token:
    case T.MotionLedgerToken{}: H.ledger_write(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,P.motion_ledger_swap,owner,value)

def motion_invoke(~client:@-Owner:Type -> (Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>) -> (Owner -> T.PositionToken -> U32 -> Owner) -> (Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> (Owner -> T.MotionLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & U32:
  client(H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,motion_get,motion_set,motion_ledger,motion_setledger,owner)
def motion_twice(result:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & U32) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & U32:
  match result:
    case (owner,_): motion_invoke(B.motion_body,owner)
def motion_handle(handle:S.Handle<T.MotionSchema>) -> String:
  match handle:
    case S.Handle{_,id}: U32.show(id)
def motion_world_observed(label:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match result:
    case (_,view): IO.print(label ++ R.render_world(T.PositionView,T.VelocityView,T.Selected,R.render_position,R.render_velocity,R.render_selected,T.LedgerView,T.MotionMode,R.render_ledger,R.render_motion_mode,view))
def motion_observe(label:String,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> IO(Unit):
  motion_world_observed(label,O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world))
def motion_published_world(fail:Bool,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> IO(Unit):
  match fail:
    case False{}: motion_observe("motion:success:",world)
    case True{}: motion_observe("motion:failure:",world)
def motion_published(fail:Bool,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,U32>) -> IO(Unit):
  match result:
    case (world,pings):
      do IO<Unit>:
        IO.print("motion:published-pings:" ++ ping_text(pings))
        motion_published_world(fail,world)
def motion_finish(fail:Bool,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match fail:
    case False{}: motion_published(False{},X.storage_commit(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,X.tx_finish_success(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,X.Tx{world,S.Handle{7,1},undo,commands,pings,marks}),9))
    case True{}: motion_published(True{},X.storage_commit(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,X.Reverted{X.unwind(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,A.motion_world_restore,A.motion_world_ledger_restore,undo,world)},9))
def motion_reintegrate(fail:Bool,result:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & U32) -> IO(Unit):
  match result:
    case (H.Held{S.World{namespace,next,rows,pending,_,mode},main,ledger,handle,+undo,commands,pings,marks},total):
      do IO<Unit>:
        IO.print("motion:sum:" ++ U32.show(total))
        IO.print("motion:inverse:" ++ undo_text(S.Handle<T.MotionSchema>,motion_handle,undo))

        motion_finish(fail,S.World{namespace,next,S.put_finish(T.Position,T.Velocity,T.Selected,S.put_rows(T.Position,T.Velocity,T.Selected,rows,1,main)),pending,Some{ledger},mode},undo,commands,pings,marks)
type MotionSnapshot is Type:
  MotionSnapshot{main:T.Position,ledger:T.MotionLedger,handle:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,mv:T.PositionView,lv:T.LedgerView}
def motion_snapshot_world(pair:MotionSnapshot & (S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>)) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>:
  match pair:
    case (MotionSnapshot{main,ledger,handle,undo,commands,pings,marks,mv,lv},(world,O.WorldView{namespace,next,rows,pending,_,mode})): (H.Held{world,main,ledger,handle,undo,commands,pings,marks},O.WorldView{namespace,next,snapshot_rows(T.PositionView,T.VelocityView,T.Selected,mv,rows),pending,Some{lv},mode})
def motion_snapshot_ledger(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,main:T.Position,handle:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,mv:T.PositionView,result:T.MotionLedger & T.LedgerView) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>:
  match result:
    case (ledger,lv): motion_snapshot_world((MotionSnapshot{main,ledger,handle,undo,commands,pings,marks,mv,lv},O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world)))
def motion_snapshot_main(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,ledger:T.MotionLedger,handle:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,result:T.Position & T.PositionView) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>:
  match result:
    case (main,mv): motion_snapshot_ledger(world,main,handle,undo,commands,pings,marks,mv,P.motion_ledger_get(ledger))
def motion_snapshot(owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>:
  match owner:
    case H.Held{world,main,ledger,handle,undo,commands,pings,marks}: motion_snapshot_main(world,ledger,handle,undo,commands,pings,marks,P.position_get(main))
def motion_lookup_checked(valid:Bool,owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.PositionView>:
  match valid:
    case False{}: (owner,T.Missing{})
    case True{}: motion_get(owner,T.PositionToken{})
def motion_same_handle(left:S.Handle<T.MotionSchema>,right:S.Handle<T.MotionSchema>) -> Bool:
  match left right:
    case S.Handle{ln,li} S.Handle{rn,ri}: Bool.and(U32.is_eq(ln,rn),U32.is_eq(li,ri))
def motion_selected(owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & S.Handle<T.MotionSchema>:
  match owner:
    case H.Held{world,main,ledger,+handle,undo,commands,pings,marks}: (H.Held{world,main,ledger,handle,undo,commands,pings,marks},handle)
def motion_lookup_selected(query:S.Handle<T.MotionSchema>,pair:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & S.Handle<T.MotionSchema>) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.PositionView>:
  match pair:
    case (owner,selected): motion_lookup_checked(motion_same_handle(selected,query),owner)
def motion_lookup(owner:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,query:S.Handle<T.MotionSchema>) -> H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.PositionView>:
  motion_lookup_selected(query,motion_selected(owner))
def motion_preflight_snapshot(fail:Bool,total:U32,result:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match result:
    case (owner,view):
      do IO<Unit>:
        IO.print("motion:held-snapshot:" ++ R.render_world(T.PositionView,T.VelocityView,T.Selected,R.render_position,R.render_velocity,R.render_selected,T.LedgerView,T.MotionMode,R.render_ledger,R.render_motion_mode,view))
        motion_reintegrate(fail,(owner,total))
def motion_preflight_lookup(fail:Bool,total:U32,result:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.PositionView>) -> IO(Unit):
  match result:
    case (owner,T.Found{view}):
      do IO<Unit>:
        IO.print("motion:held-lookup:" ++ R.render_position(view))
        motion_preflight_snapshot(fail,total,motion_snapshot(owner))
    case (owner,_): motion_preflight_snapshot(fail,total,motion_snapshot(owner))
def motion_preflight_foreign(fail:Bool,total:U32,result:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.PositionView>) -> IO(Unit):
  match result:
    case (owner,T.Missing{}):
      do IO<Unit>:
        IO.print("motion:foreign:missing")
        motion_preflight_lookup(fail,total,motion_lookup(owner,S.Handle{7,1}))
    case (owner,_):
      do IO<Unit>:
        IO.print("motion:foreign:unexpected")
        motion_preflight_lookup(fail,total,motion_lookup(owner,S.Handle{7,1}))
def motion_preflight(fail:Bool,result:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & U32) -> IO(Unit):
  match result:
    case (owner,total): motion_preflight_foreign(fail,total,motion_lookup(owner,S.Handle{8,1}))
def motion_extra(fail:Bool,result:H.Held<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,T.MotionLedger,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & U32) -> IO(Unit):
  match result:
    case (owner,total): motion_preflight(fail,(motion_set(motion_setledger(motion_set(owner,T.PositionToken{},77),T.MotionLedgerToken{},88),T.PositionToken{},99),total))
def motion_case(fail:Bool) -> IO(Unit):
  motion_extra(fail,motion_twice(motion_invoke(B.motion_body,H.Held{S.World{7,3,S.Rows{ANode{ALeaf{None{}},ALeaf{Some{T.Position{quad(900),7}}}},ANode{ALeaf{Some{T.Velocity{quad(110),True{}}}},ALeaf{Some{T.Velocity{quad(190),True{}}}}},ANode{ALeaf{S.Metadata{True{},Some{T.Selected{8}},3,4}},ALeaf{S.Metadata{True{},None{},5,6}}},2,1n,2},[],None{},T.MotionOn{}},T.Position{quad(10),7},T.MotionLedger{quad(100),4},S.Handle{7,1},[],[S.Despawn{2},S.InsertFlag{2,T.Selected{9}}],[12,11],[]})))

def health_get(owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,token:T.VitalsToken) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & T.Access<T.VitalsView>:
  match token:
    case T.VitalsToken{}: H.main_read(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,T.VitalsView,P.vitals_get,owner)

def health_ledger(owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,token:T.HealthLedgerToken) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & Maybe<&2,T.LedgerView>:
  match token:
    case T.HealthLedgerToken{}: H.ledger_read(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,T.LedgerView,P.health_ledger_get,owner)

def health_set(owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,token:T.VitalsToken,value:U32) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>:
  match token:
    case T.VitalsToken{}: H.main_write(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,P.vitals_swap,owner,value)

def health_setledger(owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,token:T.HealthLedgerToken,value:U32) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>:
  match token:
    case T.HealthLedgerToken{}: H.ledger_write(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,P.health_ledger_swap,owner,value)

def health_invoke(~client:@-Owner:Type -> (Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>) -> (Owner -> T.VitalsToken -> U32 -> Owner) -> (Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> (Owner -> T.HealthLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & U32:
  client(H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,health_get,health_set,health_ledger,health_setledger,owner)
def health_twice(result:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & U32) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & U32:
  match result:
    case (owner,_): health_invoke(B.health_body,owner)
def health_handle(handle:S.Handle<T.HealthSchema>) -> String:
  match handle:
    case S.Handle{_,id}: U32.show(id)
def health_world_observed(label:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match result:
    case (_,view): IO.print(label ++ R.render_world(T.VitalsView,T.ArmorView,T.Tracked,R.render_vitals,R.render_armor,R.render_tracked,T.LedgerView,T.HealthMode,R.render_ledger,R.render_health_mode,view))
def health_observe(label:String,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> IO(Unit):
  health_world_observed(label,O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world))
def health_published_world(fail:Bool,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> IO(Unit):
  match fail:
    case False{}: health_observe("health:success:",world)
    case True{}: health_observe("health:failure:",world)
def health_published(fail:Bool,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,U32>) -> IO(Unit):
  match result:
    case (world,pings):
      do IO<Unit>:
        IO.print("health:published-pings:" ++ ping_text(pings))
        health_published_world(fail,world)
def health_finish(fail:Bool,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match fail:
    case False{}: health_published(False{},X.storage_commit(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,X.tx_finish_success(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,X.Tx{world,S.Handle{7,1},undo,commands,pings,marks}),9))
    case True{}: health_published(True{},X.storage_commit(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,X.Reverted{X.unwind(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,A.health_world_restore,A.health_world_ledger_restore,undo,world)},9))
def health_reintegrate(fail:Bool,result:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & U32) -> IO(Unit):
  match result:
    case (H.Held{S.World{namespace,next,rows,pending,_,mode},main,ledger,handle,+undo,commands,pings,marks},total):
      do IO<Unit>:
        IO.print("health:sum:" ++ U32.show(total))
        IO.print("health:inverse:" ++ undo_text(S.Handle<T.HealthSchema>,health_handle,undo))

        health_finish(fail,S.World{namespace,next,S.put_finish(T.Vitals,T.Armor,T.Tracked,S.put_rows(T.Vitals,T.Armor,T.Tracked,rows,1,main)),pending,Some{ledger},mode},undo,commands,pings,marks)
type HealthSnapshot is Type:
  HealthSnapshot{main:T.Vitals,ledger:T.HealthLedger,handle:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,mv:T.VitalsView,lv:T.LedgerView}
def health_snapshot_world(pair:HealthSnapshot & (S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>)) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>:
  match pair:
    case (HealthSnapshot{main,ledger,handle,undo,commands,pings,marks,mv,lv},(world,O.WorldView{namespace,next,rows,pending,_,mode})): (H.Held{world,main,ledger,handle,undo,commands,pings,marks},O.WorldView{namespace,next,snapshot_rows(T.VitalsView,T.ArmorView,T.Tracked,mv,rows),pending,Some{lv},mode})
def health_snapshot_ledger(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,main:T.Vitals,handle:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,mv:T.VitalsView,result:T.HealthLedger & T.LedgerView) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>:
  match result:
    case (ledger,lv): health_snapshot_world((HealthSnapshot{main,ledger,handle,undo,commands,pings,marks,mv,lv},O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world)))
def health_snapshot_main(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,ledger:T.HealthLedger,handle:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,result:T.Vitals & T.VitalsView) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>:
  match result:
    case (main,mv): health_snapshot_ledger(world,main,handle,undo,commands,pings,marks,mv,P.health_ledger_get(ledger))
def health_snapshot(owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>:
  match owner:
    case H.Held{world,main,ledger,handle,undo,commands,pings,marks}: health_snapshot_main(world,ledger,handle,undo,commands,pings,marks,P.vitals_get(main))
def health_lookup_checked(valid:Bool,owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & T.Access<T.VitalsView>:
  match valid:
    case False{}: (owner,T.Missing{})
    case True{}: health_get(owner,T.VitalsToken{})
def health_same_handle(left:S.Handle<T.HealthSchema>,right:S.Handle<T.HealthSchema>) -> Bool:
  match left right:
    case S.Handle{ln,li} S.Handle{rn,ri}: Bool.and(U32.is_eq(ln,rn),U32.is_eq(li,ri))
def health_selected(owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & S.Handle<T.HealthSchema>:
  match owner:
    case H.Held{world,main,ledger,+handle,undo,commands,pings,marks}: (H.Held{world,main,ledger,handle,undo,commands,pings,marks},handle)
def health_lookup_selected(query:S.Handle<T.HealthSchema>,pair:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & S.Handle<T.HealthSchema>) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & T.Access<T.VitalsView>:
  match pair:
    case (owner,selected): health_lookup_checked(health_same_handle(selected,query),owner)
def health_lookup(owner:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,query:S.Handle<T.HealthSchema>) -> H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & T.Access<T.VitalsView>:
  health_lookup_selected(query,health_selected(owner))
def health_preflight_snapshot(fail:Bool,total:U32,result:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match result:
    case (owner,view):
      do IO<Unit>:
        IO.print("health:held-snapshot:" ++ R.render_world(T.VitalsView,T.ArmorView,T.Tracked,R.render_vitals,R.render_armor,R.render_tracked,T.LedgerView,T.HealthMode,R.render_ledger,R.render_health_mode,view))
        health_reintegrate(fail,(owner,total))
def health_preflight_lookup(fail:Bool,total:U32,result:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & T.Access<T.VitalsView>) -> IO(Unit):
  match result:
    case (owner,T.Found{view}):
      do IO<Unit>:
        IO.print("health:held-lookup:" ++ R.render_vitals(view))
        health_preflight_snapshot(fail,total,health_snapshot(owner))
    case (owner,_): health_preflight_snapshot(fail,total,health_snapshot(owner))
def health_preflight_foreign(fail:Bool,total:U32,result:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & T.Access<T.VitalsView>) -> IO(Unit):
  match result:
    case (owner,T.Missing{}):
      do IO<Unit>:
        IO.print("health:foreign:missing")
        health_preflight_lookup(fail,total,health_lookup(owner,S.Handle{7,1}))
    case (owner,_):
      do IO<Unit>:
        IO.print("health:foreign:unexpected")
        health_preflight_lookup(fail,total,health_lookup(owner,S.Handle{7,1}))
def health_preflight(fail:Bool,result:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & U32) -> IO(Unit):
  match result:
    case (owner,total): health_preflight_foreign(fail,total,health_lookup(owner,S.Handle{8,1}))
def health_extra(fail:Bool,result:H.Held<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,T.HealthLedger,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & U32) -> IO(Unit):
  match result:
    case (owner,total): health_preflight(fail,(health_set(health_setledger(health_set(owner,T.VitalsToken{},77),T.HealthLedgerToken{},88),T.VitalsToken{},99),total))
def health_case(fail:Bool) -> IO(Unit):
  health_extra(fail,health_twice(health_invoke(B.health_body,H.Held{S.World{7,3,S.Rows{ANode{ALeaf{None{}},ALeaf{Some{T.Vitals{quad(900),9,2}}}},ANode{ALeaf{Some{T.Armor{quad(110),3}}},ALeaf{Some{T.Armor{quad(190),3}}}},ANode{ALeaf{S.Metadata{True{},Some{T.Tracked{8}},3,4}},ALeaf{S.Metadata{True{},None{},5,6}}},2,1n,2},[],None{},T.HealthOn{}},T.Vitals{quad(10),9,2},T.HealthLedger{quad(100),4},S.Handle{7,1},[],[S.Despawn{2},S.InsertFlag{2,T.Tracked{9}}],[12,11],[]})))

def main() -> IO(Unit):
  do IO<Unit>:
    motion_case(False{})
    motion_case(True{})
    health_case(False{})
    health_case(True{})
