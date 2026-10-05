import Base
import ./types.bend as T
import ./storage.bend as S
import ./cached-payload.bend as P
import ./cache.bend as CC
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./prototype-static-client.bend as M
import ./identity.bend as I
import ./raw-boundaries.bend as RB
import ./commands.bend as Q
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
def motion_handle(handle:S.Handle<T.MotionSchema>) -> String:
  match handle:
    case S.Handle{namespace,id}: U32.show(namespace) ++ "/" ++ U32.show(id)
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
      motion_view_done(MotionInspect{selected,undo,commands,pings,marks,value,views},O.world(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world))
def motion_commands_done(carry:MotionCarry,result:List<S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> IO(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>):
  match result:
    case (commands,views): motion_commands_context(commands,views,carry)
def motion_pre(result:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32) -> IO(X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>):
  match result:
    case (X.Tx{world,selected,undo,commands,pings,marks},value): motion_commands_done(MotionCarry{world,selected,undo,pings,marks,value},O.commands(CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,T.PositionView,T.VelocityView,P.position_get,P.velocity_get,commands))
def health_handle(handle:S.Handle<T.HealthSchema>) -> String:
  match handle:
    case S.Handle{namespace,id}: U32.show(namespace) ++ "/" ++ U32.show(id)
type HealthCarry is Type:
  HealthCarry{world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,selected:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,value:U32}
type HealthInspect is Type:
  HealthInspect{selected:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,commands:List<S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,value:U32,views:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>}
def health_view_context(world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,view:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>,context:HealthInspect) -> IO(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>):
  match context:
    case HealthInspect{+selected,+undo,commands,+pings,+marks,value,views}:
      do IO<X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>>:
        IO.print("{\"phase\":\"pre\",\"value\":" ++ U32.show(value) ++ ",\"selected\":" ++ R.render_handle(T.HealthSchema,selected) ++ ",\"undo\":" ++ R.render_string(undo_text(S.Handle<T.HealthSchema>,health_handle,undo)) ++ ",\"commands\":" ++ R.render_list(O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>,R.render_pending(~T.VitalsView,~T.ArmorView,~T.Tracked,~R.render_vitals,~R.render_armor,~R.render_tracked),views) ++ ",\"pings\":" ++ R.render_list(U32,U32.show,pings) ++ ",\"marks\":" ++ R.render_list(S.Handle<T.HealthSchema>,R.render_handle(T.HealthSchema),marks) ++ ",\"world\":" ++ R.render_world(T.VitalsView,T.ArmorView,T.Tracked,R.render_vitals,R.render_armor,R.render_tracked,T.LedgerView,T.HealthMode,R.render_ledger,R.render_health_mode,view) ++ "}")
        return X.Tx{world,selected,undo,commands,pings,marks}
def health_view_done(context:HealthInspect,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>):
  match result:
    case (world,view): health_view_context(world,view,context)
def health_commands_context(commands:List<S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,views:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>,carry:HealthCarry) -> IO(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>):
  match carry:
    case HealthCarry{world,selected,undo,pings,marks,value}:
      health_view_done(HealthInspect{selected,undo,commands,pings,marks,value,views},O.world(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world))
def health_commands_done(carry:HealthCarry,result:List<S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>):
  match result:
    case (commands,views): health_commands_context(commands,views,carry)
def health_pre(result:X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & U32) -> IO(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>):
  match result:
    case (X.Tx{world,selected,undo,commands,pings,marks},value): health_commands_done(HealthCarry{world,selected,undo,pings,marks,value},O.commands(CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,T.VitalsView,T.ArmorView,P.vitals_get,P.armor_get,commands))
def motion_chosen(foreign:Bool,local:S.Handle<T.MotionSchema>,other:S.Handle<T.MotionSchema>) -> S.Handle<T.MotionSchema>:
  match foreign:
    case True{}: other
    case False{}: local
def motion_callback(+foreign:Bool,world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,+local:S.Handle<T.MotionSchema>,+other:S.Handle<T.MotionSchema>) -> IO(Unit):
  do IO<Unit>:
    owner : X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> <- motion_pre(HA.motion_row(~M.motion_body,X.Tx{world,motion_chosen(foreign,local,other),[X.LedgerInverse{77}],[S.RemoveFlag{1},S.Despawn{2}],[12,11],[local]}))
    return Unit{}
def motion_command(foreign:Bool,local:S.Handle<T.MotionSchema>,other:S.Handle<T.MotionSchema>,result:T.CommandResult<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,T.Position>) -> IO(Unit):
  match result:
    case T.CommandMissing{world,_}:
      do IO<Unit>:
        IO.print("{\"command\":\"MissingEntity\"}")
        motion_callback(foreign,world,local,other)
    case _: IO.print("foreign-command-accepted")
def motion_local_queued(foreign:Bool,local:S.Handle<T.MotionSchema>,+other:S.Handle<T.MotionSchema>,result:T.CommandResult<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,Unit>) -> IO(Unit):
  match result:
    case T.CommandQueued{world}: motion_command(foreign,local,other,RB.motion_insert(world,other,T.Position{quad(900),7}))
    case _: IO.print("local-command-rejected")
def motion_run(foreign:Bool,world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,+local:S.Handle<T.MotionSchema>,other:S.Handle<T.MotionSchema>) -> IO(Unit):
  motion_local_queued(foreign,local,other,Q.remove_flag(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,local))
def motion_applied2(+foreign:Bool,world1:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,+handle1:S.Handle<T.MotionSchema>,+handle2:S.Handle<T.MotionSchema>,result:Q.CheckedApply<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(Unit):
  match result:
    case Q.Applied{world2,_}:
      do IO<Unit>:
        motion_run(foreign,world1,handle1,handle2)
        motion_run(foreign,world2,handle2,handle1)
    case _: IO.print("construction-failed")
def motion_reserved2(foreign:Bool,world1:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,handle1:S.Handle<T.MotionSchema>,result:T.Reservation<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world2,+handle2}: motion_applied2(foreign,world1,handle1,handle2,Q.apply_checked(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world2,3))
    case _: IO.print("construction-failed")
def motion_created2(foreign:Bool,world1:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,handle1:S.Handle<T.MotionSchema>,result:T.Creation<S.Factory,S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>) -> IO(Unit):
  match result:
    case T.Created{_,world2}: motion_reserved2(foreign,world1,handle1,RB.motion_reserve(world2,S.Bundle{Some{T.Position{quad(10),7}},Some{T.Velocity{quad(110),True{}}},Some{T.Selected{8}}}))
    case _: IO.print("construction-failed")
def motion_applied1(foreign:Bool,factory:S.Factory,handle1:S.Handle<T.MotionSchema>,result:Q.CheckedApply<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(Unit):
  match result:
    case Q.Applied{world1,_}: motion_created2(foreign,world1,handle1,RB.motion_create(~unit => T.MotionLedger{quad(100),4},factory,T.MotionOn{}))
    case _: IO.print("construction-failed")
def motion_reserved1(foreign:Bool,factory:S.Factory,result:T.Reservation<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world1,handle1}: motion_applied1(foreign,factory,handle1,Q.apply_checked(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world1,3))
    case _: IO.print("construction-failed")
def motion_created1(foreign:Bool,result:T.Creation<S.Factory,S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>) -> IO(Unit):
  match result:
    case T.Created{factory,world1}: motion_reserved1(foreign,factory,RB.motion_reserve(world1,S.Bundle{Some{T.Position{quad(10),7}},Some{T.Velocity{quad(110),True{}}},Some{T.Selected{8}}}))
    case _: IO.print("construction-failed")
def motion_start(foreign:Bool) -> IO(Unit):
  motion_created1(foreign,RB.motion_create(~unit => T.MotionLedger{quad(100),4},I.factory(),T.MotionOn{}))

def health_chosen(foreign:Bool,local:S.Handle<T.HealthSchema>,other:S.Handle<T.HealthSchema>) -> S.Handle<T.HealthSchema>:
  match foreign:
    case True{}: other
    case False{}: local
def health_callback(+foreign:Bool,world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,+local:S.Handle<T.HealthSchema>,+other:S.Handle<T.HealthSchema>) -> IO(Unit):
  do IO<Unit>:
    owner : X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> <- health_pre(HA.health_row(~M.health_body,X.Tx{world,health_chosen(foreign,local,other),[X.LedgerInverse{77}],[S.RemoveFlag{1},S.Despawn{2}],[12,11],[local]}))
    return Unit{}
def health_command(foreign:Bool,local:S.Handle<T.HealthSchema>,other:S.Handle<T.HealthSchema>,result:T.CommandResult<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,T.Vitals>) -> IO(Unit):
  match result:
    case T.CommandMissing{world,_}:
      do IO<Unit>:
        IO.print("{\"command\":\"MissingEntity\"}")
        health_callback(foreign,world,local,other)
    case _: IO.print("foreign-command-accepted")
def health_local_queued(foreign:Bool,local:S.Handle<T.HealthSchema>,+other:S.Handle<T.HealthSchema>,result:T.CommandResult<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,Unit>) -> IO(Unit):
  match result:
    case T.CommandQueued{world}: health_command(foreign,local,other,RB.health_insert(world,other,T.Vitals{quad(900),9,2}))
    case _: IO.print("local-command-rejected")
def health_run(foreign:Bool,world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,+local:S.Handle<T.HealthSchema>,other:S.Handle<T.HealthSchema>) -> IO(Unit):
  health_local_queued(foreign,local,other,Q.remove_flag(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,local))
def health_applied2(+foreign:Bool,world1:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,+handle1:S.Handle<T.HealthSchema>,+handle2:S.Handle<T.HealthSchema>,result:Q.CheckedApply<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(Unit):
  match result:
    case Q.Applied{world2,_}:
      do IO<Unit>:
        health_run(foreign,world1,handle1,handle2)
        health_run(foreign,world2,handle2,handle1)
    case _: IO.print("construction-failed")
def health_reserved2(foreign:Bool,world1:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,handle1:S.Handle<T.HealthSchema>,result:T.Reservation<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world2,+handle2}: health_applied2(foreign,world1,handle1,handle2,Q.apply_checked(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world2,3))
    case _: IO.print("construction-failed")
def health_created2(foreign:Bool,world1:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,handle1:S.Handle<T.HealthSchema>,result:T.Creation<S.Factory,S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>) -> IO(Unit):
  match result:
    case T.Created{_,world2}: health_reserved2(foreign,world1,handle1,RB.health_reserve(world2,S.Bundle{Some{T.Vitals{quad(10),9,2}},Some{T.Armor{quad(110),3}},Some{T.Tracked{8}}}))
    case _: IO.print("construction-failed")
def health_applied1(foreign:Bool,factory:S.Factory,handle1:S.Handle<T.HealthSchema>,result:Q.CheckedApply<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(Unit):
  match result:
    case Q.Applied{world1,_}: health_created2(foreign,world1,handle1,RB.health_create(~unit => T.HealthLedger{quad(100),4},factory,T.HealthOn{}))
    case _: IO.print("construction-failed")
def health_reserved1(foreign:Bool,factory:S.Factory,result:T.Reservation<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world1,handle1}: health_applied1(foreign,factory,handle1,Q.apply_checked(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world1,3))
    case _: IO.print("construction-failed")
def health_created1(foreign:Bool,result:T.Creation<S.Factory,S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>) -> IO(Unit):
  match result:
    case T.Created{factory,world1}: health_reserved1(foreign,factory,RB.health_reserve(world1,S.Bundle{Some{T.Vitals{quad(10),9,2}},Some{T.Armor{quad(110),3}},Some{T.Tracked{8}}}))
    case _: IO.print("construction-failed")
def health_start(foreign:Bool) -> IO(Unit):
  health_created1(foreign,RB.health_create(~unit => T.HealthLedger{quad(100),4},I.factory(),T.HealthOn{}))
def main() -> IO(Unit):
  do IO<Unit>:
    motion_start(True{})
    motion_start(False{})
    health_start(True{})
    health_start(False{})
