import Base
import ./types.bend as T
import ./storage.bend as S
import ./cached-payload.bend as P
import ./cache.bend as CC
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./measurement-bend.bend as M
import ./held-adapter.bend as HA
import ./observations.bend as O
import ./host-render.bend as R

def quad(+n:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[n:U32^2n],1,U32.add(n,1)),2,U32.add(n,2)),3,U32.add(n,3))
def undo_text(~Z:Data,~handle:Z -> String,values:List<&2,X.Inverse<Z>>) -> String:
  match values:
    case Nil{}: ""
    case Con{X.MainInverse{h,old},rest}: "M" ++ handle(h) ++ ":" ++ U32.show(old) ++ ";" ++ undo_text(Z,handle,rest)
    case Con{X.LedgerInverse{old},rest}: "L:" ++ U32.show(old) ++ ";" ++ undo_text(Z,handle,rest)
def case_high(scenario:U32) -> U32:
  match scenario:
    case 7: 1
    case _: 2
def second_live(scenario:U32) -> Bool:
  match scenario:
    case 7: True{}
    case 8: True{}
    case _: False{}

def motion_handle(handle:S.Handle<T.MotionSchema>) -> String:
  match handle:
    case S.Handle{namespace,id}: U32.show(namespace) ++ "/" ++ U32.show(id)
def motion_selected(scenario:U32) -> S.Handle<T.MotionSchema>:
  match scenario:
    case 1: S.Handle{8,1}
    case 2: S.Handle{7,0}
    case 3: S.Handle{7,3}
    case 6: S.Handle{7,2}
    case 7: S.Handle{7,2}
    case 8: S.Handle{7,2}
    case _: S.Handle{7,1}
def motion_main(scenario:U32) -> Maybe<CC.Cache<T.Position,T.PositionView>>:
  match scenario:
    case 4: None{}
    case _: Some{P.position_new(T.Position{quad(10),7})}
def motion_ledger(scenario:U32) -> Maybe<CC.Cache<T.MotionLedger,T.LedgerView>>:
  match scenario:
    case 5: None{}
    case _: Some{P.motion_ledger_new(T.MotionLedger{quad(100),4})}
def motion_owner(+scenario:U32) -> X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>:
  X.Tx{S.World{7,3,S.Rows{ANode{ALeaf{motion_main(scenario)},ALeaf{Some{P.position_new(T.Position{quad(900),7})}}},ANode{ALeaf{Some{T.Velocity{quad(110),True{}}}},ALeaf{Some{T.Velocity{quad(190),True{}}}}},ANode{ALeaf{S.Metadata{True{},Some{T.Selected{8}},3,4}},ALeaf{S.Metadata{second_live(scenario),None{},5,6}}},2,1n,case_high(scenario)},[],motion_ledger(scenario),T.MotionOn{}},motion_selected(scenario),[X.LedgerInverse{77}],[S.RemoveFlag{1},S.Despawn{2}],[12,11],[S.Handle{7,2}]}
type MotionCarry is Type:
  MotionCarry{world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,selected:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,value:U32}
type MotionInspect is Type:
  MotionInspect{selected:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,commands:List<S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,value:U32,views:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>}
def motion_view_context(world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,view:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>,context:MotionInspect) -> IO(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>):
  match context:
    case MotionInspect{+selected,+undo,commands,+pings,+marks,value,views}:
      do IO<X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>>:
        IO.print("{\"phase\":\"pre\",\"value\":" ++ U32.show(value) ++ ",\"selected\":" ++ R.render_handle(T.MotionSchema,selected) ++ ",\"undo\":" ++ R.render_string(undo_text(S.Handle<T.MotionSchema>,motion_handle,undo)) ++ ",\"commands\":" ++ R.render_list(O.PendingView<T.PositionView,T.VelocityView,T.Selected>,R.render_pending(~T.PositionView,~T.VelocityView,~T.Selected,~R.render_position,~R.render_velocity,~R.render_selected),views) ++ ",\"pings\":" ++ R.render_list(U32,U32.show,pings) ++ ",\"marks\":" ++ R.render_list(S.Handle<T.MotionSchema>,R.render_handle(T.MotionSchema),marks) ++ ",\"world\":" ++ R.render_world(T.PositionView,T.VelocityView,T.Selected,R.render_position,R.render_velocity,R.render_selected,T.LedgerView,T.MotionMode,R.render_ledger,R.render_motion_mode,view) ++ "}")
        return X.Tx{world,selected,undo,commands,pings,marks}
def motion_view_done(context:MotionInspect,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>):
  match result:
    case (world,view): motion_view_context(world,view,context)
def motion_commands_context(commands:List<S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,views:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>,carry:MotionCarry) -> IO(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>):
  match carry:
    case MotionCarry{world,selected,undo,pings,marks,value}:
      motion_view_done(MotionInspect{selected,undo,commands,pings,marks,value,views},O.world(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_uncached,P.velocity_get,P.motion_ledger_uncached,world))
def motion_commands_done(carry:MotionCarry,result:List<S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> IO(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>):
  match result:
    case (commands,views): motion_commands_context(commands,views,carry)
def motion_pre(result:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32) -> IO(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>):
  match result:
    case (X.Tx{world,selected,undo,commands,pings,marks},value): motion_commands_done(MotionCarry{world,selected,undo,pings,marks,value},O.commands(CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,T.PositionView,T.VelocityView,P.position_uncached,P.velocity_get,commands))
def motion_post_view(pings:List<&2,U32>,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match result:
    case (_,view): IO.print("{\"phase\":\"post\",\"pings\":" ++ R.render_list(U32,U32.show,pings) ++ ",\"world\":" ++ R.render_world(T.PositionView,T.VelocityView,T.Selected,R.render_position,R.render_velocity,R.render_selected,T.LedgerView,T.MotionMode,R.render_ledger,R.render_motion_mode,view) ++ "}")
def motion_post(result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,U32>) -> IO(Unit):
  match result:
    case (world,pings): motion_post_view(pings,O.world(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_uncached,P.velocity_get,P.motion_ledger_uncached,world))
def motion_finish(fail:Bool,owner:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>) -> IO(Unit):
  match fail:
    case False{}: motion_post(X.storage_commit(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,X.tx_finish_success(S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,owner),9))
    case True{}: motion_post(X.storage_commit(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,A.motion_finish_failure(owner),9))

def motion_body(owner:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>) -> X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32:
  M.motion_body(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,A.motion_read_main,A.motion_set_main0,A.motion_read_ledger,A.motion_set_ledger0,owner)

def motion_pair(+scenario:U32,+fail:Bool) -> IO(Unit):
  do IO<Unit>:
    original : X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> <- motion_pre(motion_body(motion_owner(scenario)))
    motion_finish(fail,original)
    integrated : X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> <- motion_pre(HA.motion_row(~M.motion_body,motion_owner(scenario)))
    motion_finish(fail,integrated)

def cases(remaining:Nat,+scenario:U32) -> IO(Unit):
  match remaining:
    case 0n: IO.pure(Unit,Unit{})
    case 1n++rest:
      do IO<Unit>:
        motion_pair(scenario,False{})
        motion_pair(scenario,True{})
        cases(rest,U32.add(scenario,1))
def main() -> IO(Unit):
  cases(9n,0)
