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

def health_body(owner:X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>) -> X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & U32:
  M.health_body(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,A.health_read_main,A.health_set_main0,A.health_read_ledger,A.health_set_ledger0,owner)

def health_handle(handle:S.Handle<T.HealthSchema>) -> String:
  match handle:
    case S.Handle{namespace,id}: U32.show(namespace) ++ "/" ++ U32.show(id)
def health_selected(scenario:U32) -> S.Handle<T.HealthSchema>:
  match scenario:
    case 1: S.Handle{8,1}
    case 2: S.Handle{7,0}
    case 3: S.Handle{7,3}
    case 6: S.Handle{7,2}
    case 7: S.Handle{7,2}
    case 8: S.Handle{7,2}
    case _: S.Handle{7,1}
def health_main(scenario:U32) -> Maybe<CC.Cache<T.Vitals,T.VitalsView>>:
  match scenario:
    case 4: None{}
    case _: Some{P.vitals_new(T.Vitals{quad(10),9,2})}
def health_ledger(scenario:U32) -> Maybe<CC.Cache<T.HealthLedger,T.LedgerView>>:
  match scenario:
    case 5: None{}
    case _: Some{P.health_ledger_new(T.HealthLedger{quad(100),4})}
def health_owner(+scenario:U32) -> X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>:
  X.Tx{S.World{7,3,S.Rows{ANode{ALeaf{health_main(scenario)},ALeaf{Some{P.vitals_new(T.Vitals{quad(900),9,2})}}},ANode{ALeaf{Some{T.Armor{quad(110),3}}},ALeaf{Some{T.Armor{quad(190),3}}}},ANode{ALeaf{S.Metadata{True{},Some{T.Tracked{8}},3,4}},ALeaf{S.Metadata{second_live(scenario),None{},5,6}}},2,1n,case_high(scenario)},[],health_ledger(scenario),T.HealthOn{}},health_selected(scenario),[X.LedgerInverse{77}],[S.RemoveFlag{1},S.Despawn{2}],[12,11],[S.Handle{7,2}]}
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
      health_view_done(HealthInspect{selected,undo,commands,pings,marks,value,views},O.world(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_uncached,P.armor_get,P.health_ledger_uncached,world))
def health_commands_done(carry:HealthCarry,result:List<S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>):
  match result:
    case (commands,views): health_commands_context(commands,views,carry)
def health_pre(result:X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & U32) -> IO(X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>):
  match result:
    case (X.Tx{world,selected,undo,commands,pings,marks},value): health_commands_done(HealthCarry{world,selected,undo,pings,marks,value},O.commands(CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,T.VitalsView,T.ArmorView,P.vitals_uncached,P.armor_get,commands))
def health_post_view(pings:List<&2,U32>,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match result:
    case (_,view): IO.print("{\"phase\":\"post\",\"pings\":" ++ R.render_list(U32,U32.show,pings) ++ ",\"world\":" ++ R.render_world(T.VitalsView,T.ArmorView,T.Tracked,R.render_vitals,R.render_armor,R.render_tracked,T.LedgerView,T.HealthMode,R.render_ledger,R.render_health_mode,view) ++ "}")
def health_post(result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,U32>) -> IO(Unit):
  match result:
    case (world,pings): health_post_view(pings,O.world(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_uncached,P.armor_get,P.health_ledger_uncached,world))
def health_finish(fail:Bool,owner:X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>) -> IO(Unit):
  match fail:
    case False{}: health_post(X.storage_commit(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,X.tx_finish_success(S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,owner),9))
    case True{}: health_post(X.storage_commit(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,A.health_finish_failure(owner),9))
def health_pair(+scenario:U32,+fail:Bool) -> IO(Unit):
  do IO<Unit>:
    original : X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> <- health_pre(health_body(health_owner(scenario)))
    health_finish(fail,original)
    integrated : X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> <- health_pre(HA.health_row(~M.health_body,health_owner(scenario)))
    health_finish(fail,integrated)
def cases(remaining:Nat,+scenario:U32) -> IO(Unit):
  match remaining:
    case 0n: IO.pure(Unit,Unit{})
    case 1n++rest:
      do IO<Unit>:
        health_pair(scenario,False{})
        health_pair(scenario,True{})
        cases(rest,U32.add(scenario,1))
def main() -> IO(Unit):
  cases(9n,0)
