import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./payload.bend as P
import ./payload-controls.bend as V
import ./transaction.bend as X

def motion_main(+value:U32) -> T.Position:
  T.Position{V.quad(value,(value + 1 : U32),(value + 2 : U32),(value + 3 : U32)),7}
def motion_ledger(u:Unit) -> T.MotionLedger:
  T.MotionLedger{V.quad(100,101,102,103),4}
def motion_queue_head(+id:U32,tail:List<S.Command<T.Position,T.Velocity,T.Selected>>,text:String,result:T.Position & T.PositionView) -> List<S.Command<T.Position,T.Velocity,T.Selected>> & String:
  match result:
    case (owner,view): (S.InsertMain{id,owner} <> tail,V.position_text(view) ++ ";" ++ text)
def motion_queue_command(command:S.Command<T.Position,T.Velocity,T.Selected>,tail:List<S.Command<T.Position,T.Velocity,T.Selected>>,text:String) -> List<S.Command<T.Position,T.Velocity,T.Selected>> & String:
  match command:
    case S.InsertMain{id,owner}: motion_queue_head(id,tail,text,P.position_get(owner))
    case command: (command <> tail,"unexpected;" ++ text)
def motion_queue_join(command:S.Command<T.Position,T.Velocity,T.Selected>,result:List<S.Command<T.Position,T.Velocity,T.Selected>> & String) -> List<S.Command<T.Position,T.Velocity,T.Selected>> & String:
  match result:
    case (tail,text): motion_queue_command(command,tail,text)
def motion_queue(commands:List<S.Command<T.Position,T.Velocity,T.Selected>>) -> List<S.Command<T.Position,T.Velocity,T.Selected>> & String:
  match commands:
    case Nil{}: ([],"")
    case Con{head,tail}: motion_queue_join(head,motion_queue(tail))
def motion_queue_world(namespace:U32,next:U32,rows:List<S.Row<T.Position,T.Velocity,T.Selected>>,ledger:Maybe<T.MotionLedger>,mode:T.MotionMode,result:List<S.Command<T.Position,T.Velocity,T.Selected>> & String) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match result:
    case (pending,text): (S.World{namespace,next,rows,pending,ledger,mode},text)
def motion_pending(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}: motion_queue_world(namespace,next,rows,ledger,mode,motion_queue(pending))
def motion_final(prefix:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<T.PositionView>) -> String:
  match result:
    case (world,T.Found{view}): prefix ++ "after=" ++ V.position_text(view)
    case (_, _): "missingafter"
def motion_applied(+handle:S.Handle<T.MotionSchema>,prefix:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> String:
  match result:
    case (world,_): motion_final(prefix,S.with_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,world,handle,P.position_get))
def motion_before(handle:S.Handle<T.MotionSchema>,pending:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<T.PositionView>) -> String:
  match result:
    case (world,T.Found{view}): motion_applied(handle,"pending=" ++ pending ++ "before=" ++ V.position_text(view) ++ ";",C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,7))
    case (_, _): "missingbefore"
def motion_pending_done(+handle:S.Handle<T.MotionSchema>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> String:
  match result:
    case (world,text): motion_before(handle,text,S.with_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,world,handle,P.position_get))
def motion_committed(handle:S.Handle<T.MotionSchema>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,U32>) -> String:
  match result:
    case (world,_): motion_pending_done(handle,motion_pending(world))
def motion_live_handle(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,handle:S.Handle<T.MotionSchema>) -> String:
  match handle:
    case S.Handle{+space,+id}: motion_committed(S.Handle{space,id},X.storage_commit(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,X.tx_finish_success(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,X.tx_stage_command(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,X.tx_stage_command(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,S.Handle{space,id}),S.InsertMain{id,motion_main(80)}),S.InsertMain{id,motion_main(81)})),6))
def motion_live(handle:S.Handle<T.MotionSchema>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> String:
  match result:
    case (world,_): motion_live_handle(world,handle)
def motion_reserved(result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> String:
  match result:
    case T.Reserved{world,+handle}: motion_live(handle,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1))
    case T.ReserveRejected{_,_}: "reservefailed"
def motion_created(result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> String:
  match result:
    case T.Created{factory,world}: motion_reserved(C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{motion_main(20)},None{},None{}}))
    case T.CreateRejected{_}: "createfailed"
def motion() -> String:
  motion_created(I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,motion_ledger,I.factory(),T.MotionOn{}))
def health_main(+value:U32) -> T.Vitals:
  T.Vitals{V.quad(value,(value + 1 : U32),(value + 2 : U32),(value + 3 : U32)),9,2}
def health_ledger(u:Unit) -> T.HealthLedger:
  T.HealthLedger{V.quad(100,101,102,103),4}
def health_queue_head(+id:U32,tail:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,text:String,result:T.Vitals & T.VitalsView) -> List<S.Command<T.Vitals,T.Armor,T.Tracked>> & String:
  match result:
    case (owner,view): (S.InsertMain{id,owner} <> tail,V.vitals_text(view) ++ ";" ++ text)
def health_queue_command(command:S.Command<T.Vitals,T.Armor,T.Tracked>,tail:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,text:String) -> List<S.Command<T.Vitals,T.Armor,T.Tracked>> & String:
  match command:
    case S.InsertMain{id,owner}: health_queue_head(id,tail,text,P.vitals_get(owner))
    case command: (command <> tail,"unexpected;" ++ text)
def health_queue_join(command:S.Command<T.Vitals,T.Armor,T.Tracked>,result:List<S.Command<T.Vitals,T.Armor,T.Tracked>> & String) -> List<S.Command<T.Vitals,T.Armor,T.Tracked>> & String:
  match result:
    case (tail,text): health_queue_command(command,tail,text)
def health_queue(commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>) -> List<S.Command<T.Vitals,T.Armor,T.Tracked>> & String:
  match commands:
    case Nil{}: ([],"")
    case Con{head,tail}: health_queue_join(head,health_queue(tail))
def health_queue_world(namespace:U32,next:U32,rows:List<S.Row<T.Vitals,T.Armor,T.Tracked>>,ledger:Maybe<T.HealthLedger>,mode:T.HealthMode,result:List<S.Command<T.Vitals,T.Armor,T.Tracked>> & String) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match result:
    case (pending,text): (S.World{namespace,next,rows,pending,ledger,mode},text)
def health_pending(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}: health_queue_world(namespace,next,rows,ledger,mode,health_queue(pending))
def health_final(prefix:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<T.VitalsView>) -> String:
  match result:
    case (world,T.Found{view}): prefix ++ "after=" ++ V.vitals_text(view)
    case (_, _): "missingafter"
def health_applied(+handle:S.Handle<T.HealthSchema>,prefix:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> String:
  match result:
    case (world,_): health_final(prefix,S.with_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,world,handle,P.vitals_get))
def health_before(handle:S.Handle<T.HealthSchema>,pending:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<T.VitalsView>) -> String:
  match result:
    case (world,T.Found{view}): health_applied(handle,"pending=" ++ pending ++ "before=" ++ V.vitals_text(view) ++ ";",C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,7))
    case (_, _): "missingbefore"
def health_pending_done(+handle:S.Handle<T.HealthSchema>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> String:
  match result:
    case (world,text): health_before(handle,text,S.with_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,world,handle,P.vitals_get))
def health_committed(handle:S.Handle<T.HealthSchema>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,U32>) -> String:
  match result:
    case (world,_): health_pending_done(handle,health_pending(world))
def health_live_handle(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,handle:S.Handle<T.HealthSchema>) -> String:
  match handle:
    case S.Handle{+space,+id}: health_committed(S.Handle{space,id},X.storage_commit(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,X.tx_finish_success(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,X.tx_stage_command(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,X.tx_stage_command(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,S.Handle{space,id}),S.InsertMain{id,health_main(80)}),S.InsertMain{id,health_main(81)})),6))
def health_live(handle:S.Handle<T.HealthSchema>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> String:
  match result:
    case (world,_): health_live_handle(world,handle)
def health_reserved(result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> String:
  match result:
    case T.Reserved{world,+handle}: health_live(handle,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1))
    case T.ReserveRejected{_,_}: "reservefailed"
def health_created(result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> String:
  match result:
    case T.Created{factory,world}: health_reserved(C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{health_main(20)},None{},None{}}))
    case T.CreateRejected{_}: "createfailed"
def health() -> String:
  health_created(I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,health_ledger,I.factory(),T.HealthOn{}))
def main() -> String:
  motion() ++ "\n" ++ health()
