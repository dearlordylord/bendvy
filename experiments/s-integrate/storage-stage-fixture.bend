import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./query.bend as Q
import ./payload.bend as P

def vector(+x: U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[x : U32^2n],1,(x + 1 : U32)),2,(x + 2 : U32)),3,(x + 3 : U32))
def four(values: T.Four) -> String:
  match values:
    case T.Four{a,b,c,d}: U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def bool(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def position(value: T.PositionView) -> String:
  match value:
    case T.PositionView{values,frame}: "position[" ++ four(values) ++ "];frame=" ++ U32.show(frame)
def vitals(value: T.VitalsView) -> String:
  match value:
    case T.VitalsView{values,reserve,class}: "vitals[" ++ four(values) ++ "];reserve=" ++ U32.show(reserve) ++ ";class=" ++ U32.show(class)
def velocity(value: T.VelocityView) -> String:
  match value:
    case T.VelocityView{values,moving}: "velocity[" ++ four(values) ++ "];moving=" ++ bool(moving)
def armor(value: T.ArmorView) -> String:
  match value:
    case T.ArmorView{values,grade}: "armor[" ++ four(values) ++ "];grade=" ++ U32.show(grade)
def ledger_show(value: T.LedgerView) -> String:
  match value:
    case T.LedgerView{values,epoch}: "ledger[" ++ four(values) ++ "];epoch=" ++ U32.show(epoch)
def selected(value: T.Selected) -> String:
  match value:
    case T.Selected{group}: "selected=" ++ U32.show(group)
def tracked(value: T.Tracked) -> String:
  match value:
    case T.Tracked{group}: "tracked=" ++ U32.show(group)
def motion_mode(value: T.MotionMode) -> String:
  match value:
    case T.MotionOn{}: "On"
    case T.MotionOff{}: "Off"
def health_mode(value: T.HealthMode) -> String:
  match value:
    case T.HealthOn{}: "On"
    case T.HealthOff{}: "Off"
def maybe(~V: Data,~show: V -> String,value: Maybe<&2,V>) -> String:
  match value:
    case None{}: "none"
    case Some{v}: show(v)
def observe_result(~Owner: Type,~V: Data,~show: V -> String,result: Owner & V) -> Owner & String:
  match result:
    case (owner,value): (owner,show(value))
def option_done(~Owner: Type,~V: Data,~show: V -> String,result: Owner & V) -> Maybe<Owner> & String:
  match result:
    case (owner,value): (Some{owner},show(value))
def option(~Owner: Type,~V: Data,~get: Owner -> Owner & V,~show: V -> String,value: Maybe<Owner>) -> Maybe<Owner> & String:
  match value:
    case None{}: (None{},"none")
    case Some{owner}: option_done(~Owner,~V,~show,get(owner))
def pair_text(-W: Type,result: W & String,next: W -> String -> String) -> String:
  match result:
    case (w,text): next(w,text)
def created(-W: Type,result: T.Creation<S.Factory,W>,next: S.Factory -> W -> String) -> String:
  match result:
    case T.CreateRejected{_}: "CREATE_REJECTED"
    case T.Created{factory,world}: next(factory,world)
def reserved(-W: Type,-H: Data,-B: Type,result: T.Reservation<W,H,B>,next: W -> H -> String) -> String:
  match result:
    case T.ReserveRejected{_,_}: "RESERVE_REJECTED"
    case T.Reserved{world,handle}: next(world,handle)
def applied(-W: Type,-Schema: Data,result: W & List<&2,S.Change<Schema>>,next: W -> String) -> String:
  match result:
    case (world,_): next(world)
def queued(-W: Type,-Payload: Type,result: T.CommandResult<W,Payload>,next: W -> String) -> String:
  match result:
    case T.CommandMissing{_,_}: "LOCAL_COMMAND_MISSING"
    case T.CommandQueued{world}: next(world)
def access(result: T.Access<String>) -> String:
  match result:
    case T.Missing{}: "MissingEntity"
    case T.Mismatch{}: "QueryMismatch"
    case T.Found{text}: "Found(" ++ text ++ ")"
def query_text(-W: Type,result: W & List<&2,String>) -> W & String:
  match result:
    case (w,text): (w,"[" ++ String.join(text,"|") ++ "]")
def lookup_text(-W: Type,result: W & T.Access<String>) -> W & String:
  match result:
    case (w,value): (w,access(value))
def bundle_aux(~M: Type,~A: Type,~F: Data,~fs: F -> String,main: Maybe<M>,mt: String,+flag: Maybe<&2,F>,result: Maybe<A> & String) -> S.Bundle<M,A,F> & String:
  match result:
    case (aux,at): (S.Bundle{main,aux,flag},mt ++ ";" ++ at ++ ";" ++ maybe(~F,~fs,flag))
def bundle_main(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~mg: M -> M & V,~ag: A -> A & AV,~ms: V -> String,~ashow: AV -> String,~fs: F -> String,aux: Maybe<A>,flag: Maybe<&2,F>,result: Maybe<M> & String) -> S.Bundle<M,A,F> & String:
  match result:
    case (main,text): bundle_aux(~M,~A,~F,~fs,main,text,flag,option(~A,~AV,~ag,~ashow,aux))
def bundle(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~mg: M -> M & V,~ag: A -> A & AV,~ms: V -> String,~ashow: AV -> String,~fs: F -> String,value: S.Bundle<M,A,F>) -> S.Bundle<M,A,F> & String:
  match value:
    case S.Bundle{main,aux,flag}: bundle_main(~M,~A,~F,~V,~AV,~mg,~ag,~ms,~ashow,~fs,aux,flag,option(~M,~V,~mg,~ms,main))
def row_done(-M: Type,-A: Type,-F: Data,+id: U32,+added: U32,+changed: U32,result: S.Bundle<M,A,F> & String) -> S.Row<M,A,F> & String:
  match result:
    case (S.Bundle{main,aux,flag},text): (S.Row{id,main,aux,flag,added,changed},U32.show(id) ++ "{" ++ text ++ ";added=" ++ U32.show(added) ++ ";changed=" ++ U32.show(changed) ++ "}")
def row(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~mg: M -> M & V,~ag: A -> A & AV,~ms: V -> String,~ashow: AV -> String,~fs: F -> String,value: S.Row<M,A,F>) -> S.Row<M,A,F> & String:
  match value:
    case S.Row{id,main,aux,flag,added,changed}: row_done(M,A,F,id,added,changed,bundle(~M,~A,~F,~V,~AV,~mg,~ag,~ms,~ashow,~fs,S.Bundle{main,aux,flag}))
def rows_tail(-M: Type,-A: Type,-F: Data,row: S.Row<M,A,F>,text: String,tail: List<S.Row<M,A,F>> & List<&2,String>) -> List<S.Row<M,A,F>> & List<&2,String>:
  match tail:
    case (rows,texts): (row <> rows,text <> texts)
def rows_join(-M: Type,-A: Type,-F: Data,value: S.Row<M,A,F> & String,tail: List<S.Row<M,A,F>> & List<&2,String>) -> List<S.Row<M,A,F>> & List<&2,String>:
  match value:
    case (r,text): rows_tail(M,A,F,r,text,tail)
def rows(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~mg: M -> M & V,~ag: A -> A & AV,~ms: V -> String,~ashow: AV -> String,~fs: F -> String,values: List<S.Row<M,A,F>>) -> List<S.Row<M,A,F>> & List<&2,String>:
  match values:
    case Nil{}: ([],[])
    case Con{r,tail}: rows_join(M,A,F,row(~M,~A,~F,~V,~AV,~mg,~ag,~ms,~ashow,~fs,r),rows(~M,~A,~F,~V,~AV,~mg,~ag,~ms,~ashow,~fs,tail))
def spawn_text(-M: Type,-A: Type,-F: Data,+id: U32,result: S.Bundle<M,A,F> & String) -> S.Command<M,A,F> & String:
  match result:
    case (owner,text): (S.Spawn{id,owner},"spawn:" ++ U32.show(id) ++ "{" ++ text ++ "}")
def main_text(~M: Type,~A: Type,~F: Data,~V: Data,~ms: V -> String,+id: U32,result: M & V) -> S.Command<M,A,F> & String:
  match result:
    case (owner,view): (S.InsertMain{id,owner},"insertMain:" ++ U32.show(id) ++ "{" ++ ms(view) ++ "}")
def command(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~mg: M -> M & V,~ag: A -> A & AV,~ms: V -> String,~ashow: AV -> String,~fs: F -> String,value: S.Command<M,A,F>) -> S.Command<M,A,F> & String:
  match value:
    case S.Spawn{id,owner}: spawn_text(M,A,F,id,bundle(~M,~A,~F,~V,~AV,~mg,~ag,~ms,~ashow,~fs,owner))
    case S.InsertMain{id,owner}: main_text(~M,~A,~F,~V,~ms,id,mg(owner))
    case S.InsertFlag{+id,+flag}: (S.InsertFlag{id,flag},"insertFlag:" ++ U32.show(id) ++ "{" ++ fs(flag) ++ "}")
    case S.RemoveMain{+id}: (S.RemoveMain{id},"removeMain:" ++ U32.show(id))
    case S.RemoveFlag{+id}: (S.RemoveFlag{id},"removeFlag:" ++ U32.show(id))
    case S.Despawn{+id}: (S.Despawn{id},"despawn:" ++ U32.show(id))
def commands_tail(-M: Type,-A: Type,-F: Data,cmd: S.Command<M,A,F>,text: String,tail: List<S.Command<M,A,F>> & List<&2,String>) -> List<S.Command<M,A,F>> & List<&2,String>:
  match tail:
    case (commands,texts): (cmd <> commands,text <> texts)
def commands_join(-M: Type,-A: Type,-F: Data,value: S.Command<M,A,F> & String,tail: List<S.Command<M,A,F>> & List<&2,String>) -> List<S.Command<M,A,F>> & List<&2,String>:
  match value:
    case (cmd,text): commands_tail(M,A,F,cmd,text,tail)
def commands(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~mg: M -> M & V,~ag: A -> A & AV,~ms: V -> String,~ashow: AV -> String,~fs: F -> String,values: List<S.Command<M,A,F>>) -> List<S.Command<M,A,F>> & List<&2,String>:
  match values:
    case Nil{}: ([],[])
    case Con{cmd,tail}: commands_join(M,A,F,command(~M,~A,~F,~V,~AV,~mg,~ag,~ms,~ashow,~fs,cmd),commands(~M,~A,~F,~V,~AV,~mg,~ag,~ms,~ashow,~fs,tail))
def observed_ledger(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mode_show: Mode -> String,+namespace: U32,+next: U32,rows: List<S.Row<M,A,F>>,rt: List<&2,String>,pending: List<S.Command<M,A,F>>,ct: List<&2,String>,+mode: Mode,result: Maybe<L> & String) -> S.World<Schema,M,A,F,L,Mode> & String:
  match result:
    case (ledger,text): (S.World{namespace,next,rows,pending,ledger,mode},"ns=" ++ U32.show(namespace) ++ ";next=" ++ U32.show(next) ++ ";rows=[" ++ String.join(rt,"|") ++ "];pending=[" ++ String.join(List.reverse(&2,String,ct),"|") ++ "];" ++ text ++ ";mode=" ++ mode_show(mode))

def motion_main(x: U32) -> T.Position: T.Position{vector(x),7}
def motion_aux() -> T.Velocity: T.Velocity{vector(1),True{}}
def motion_ledger(unit: Unit) -> T.MotionLedger: T.MotionLedger{vector(100),4}
def motion_row_text(handle: S.Handle<T.MotionSchema>,main: String,aux: String,flag: String) -> String:
  match handle:
    case S.Handle{namespace,id}: U32.show(namespace) ++ ":" ++ U32.show(id) ++ "{" ++ main ++ ";" ++ aux ++ ";" ++ flag ++ "}"
def motion_client_aux(-P: Type,-U: Type,main: P,mt: String,handle: S.Handle<T.MotionSchema>,flag: Maybe<&2,T.Selected>,result: U & Maybe<&2,T.VelocityView>) -> P & (U & String):
  match result:
    case (aux,av): (main,(aux,motion_row_text(handle,mt,maybe(~T.VelocityView,~velocity,av),maybe(~T.Selected,~selected,flag))))
def motion_client_main(-P: Type,-U: Type,aux: U,get_aux: U -> U & Maybe<&2,T.VelocityView>,handle: S.Handle<T.MotionSchema>,flag: Maybe<&2,T.Selected>,result: P & T.PositionView) -> P & (U & String):
  match result:
    case (main,value): motion_client_aux(P,U,main,position(value),handle,flag,get_aux(aux))
def motion_client(-P: Type,-U: Type,get: P -> T.PositionToken -> P & T.PositionView,get_aux: U -> U & Maybe<&2,T.VelocityView>,handle: S.Handle<T.MotionSchema>,flag: Maybe<&2,T.Selected>,main: P,aux: U) -> P & (U & String):
  motion_client_main(P,U,aux,get_aux,handle,flag,get(main,T.PositionToken{}))
def motion_observe_commands(+namespace: U32,+next: U32,rows: List<S.Row<T.Position,T.Velocity,T.Selected>>,rt: List<&2,String>,ledger: Maybe<T.MotionLedger>,mode: T.MotionMode,result: List<S.Command<T.Position,T.Velocity,T.Selected>> & List<&2,String>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match result:
    case (pending,ct): observed_ledger(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~motion_mode,namespace,next,rows,rt,pending,ct,mode,option(~T.MotionLedger,~T.LedgerView,~P.motion_ledger_get,~ledger_show,ledger))
def motion_observe_rows(namespace: U32,next: U32,pending: List<S.Command<T.Position,T.Velocity,T.Selected>>,ledger: Maybe<T.MotionLedger>,mode: T.MotionMode,result: List<S.Row<T.Position,T.Velocity,T.Selected>> & List<&2,String>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match result:
    case (rs,rt): motion_observe_commands(namespace,next,rs,rt,ledger,mode,commands(~T.Position,~T.Velocity,~T.Selected,~T.PositionView,~T.VelocityView,~P.position_get,~P.velocity_get,~position,~velocity,~selected,pending))
def motion_observe(world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match world:
    case S.World{namespace,next,rs,pending,ledger,mode}: motion_observe_rows(namespace,next,pending,ledger,mode,rows(~T.Position,~T.Velocity,~T.Selected,~T.PositionView,~T.VelocityView,~P.position_get,~P.velocity_get,~position,~velocity,~selected,rs))
def motion_query(world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selection: Q.Selection) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  query_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Q.each(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.PositionToken,~T.PositionView,~T.VelocityView,~String,~T.MotionLedger,~T.MotionMode,~P.position_get,~P.velocity_get,~motion_client,selection,world))
def motion_lookup(world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,handle: S.Handle<T.MotionSchema>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  lookup_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Q.lookup(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.PositionToken,~T.PositionView,~T.VelocityView,~String,~T.MotionLedger,~T.MotionMode,~P.position_get,~P.velocity_get,~motion_client,Q.Required{},world,handle))
def motion_collected(text: String,result: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match result:
    case (world,rest): (world,text ++ "\n" ++ rest)
def motion_collect(result: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String,rest: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match result:
    case (world,text): motion_collected(text,rest(world))
def motion_snapshot(world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,+a: S.Handle<T.MotionSchema>,c: S.Handle<T.MotionSchema>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  motion_collect(motion_observe(world),w => motion_collect(motion_query(w,Q.Required{}),w => motion_collect(motion_query(w,Q.Present{}),w => motion_collect(motion_query(w,Q.Absent{}),w => motion_collect(motion_query(w,Q.Optional{}),w => motion_collect(motion_lookup(w,a),w => motion_lookup(w,c)))))))
def motion_rejected(result: T.CommandResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position>,next: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> String -> String) -> String:
  match result:
    case T.CommandQueued{_}: "FOREIGN_COMMAND_ACCEPTED"
    case T.CommandMissing{world,payload}: pair_text(T.Position,observe_result(~T.Position,~T.PositionView,~position,P.position_get(payload)),owner => text => next(world,"MissingEntity;returned=" ++ text))
def motion_fifo(+a: S.Handle<T.MotionSchema>,c: S.Handle<T.MotionSchema>,world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> String:
  queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,a,motion_main(80)),world =>
  queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,a,motion_main(81)),world =>
  applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,2),world =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(world,a,c),world => text => "Motion/FIFO-alpha\n" ++ text))))
def motion_foreign(+a: S.Handle<T.MotionSchema>,+c: S.Handle<T.MotionSchema>,+z: S.Handle<T.MotionSchema>,alpha: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,beta: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> String:
  queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,alpha,a,motion_main(77)),alpha =>
  queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,z,motion_main(78)),beta =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(alpha,a,c),alpha => beforea =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(beta,z,z),beta => beforeb =>
  motion_rejected(C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,a,motion_main(500)),beta => rb =>
  motion_rejected(C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,alpha,z,motion_main(600)),alpha => ra =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(alpha,a,c),alpha => aftera =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(beta,z,z),beta => afterb =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(beta,a),beta => foreignb =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(alpha,z),alpha => foreigna =>
  "Motion/foreign-before-alpha\n" ++ beforea ++ "\nMotion/foreign-before-beta\n" ++ beforeb ++ "\n" ++ ra ++ "\n" ++ rb ++ "\nMotion/foreign-after-alpha\n" ++ aftera ++ "\nMotion/foreign-after-beta\n" ++ afterb ++ "\n" ++ foreigna ++ "\n" ++ foreignb ++ "\n" ++ motion_fifo(a,c,alpha)))))))))))
def motion_run(alpha: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,beta: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,+a: S.Handle<T.MotionSchema>,b: S.Handle<T.MotionSchema>,+c: S.Handle<T.MotionSchema>,+z: S.Handle<T.MotionSchema>) -> String:
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(alpha,a,c),alpha => e0a =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(beta,z,z),beta => e0b =>
  applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,alpha,1),alpha =>
  applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,1),beta =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(alpha,a,c),alpha => e1a =>
  pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_snapshot(beta,z,z),beta => e1b =>
  "Motion/E0-alpha\n" ++ e0a ++ "\nMotion/E0-beta\n" ++ e0b ++ "\nMotion/E1-alpha\n" ++ e1a ++ "\nMotion/E1-beta\n" ++ e1b ++ "\n" ++ motion_foreign(a,c,z,alpha,beta)))))))
def motion_stage(alpha: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,beta: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> String:
  reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,alpha,S.Bundle{Some{motion_main(10)},Some{motion_aux()},Some{T.Selected{8}}}),alpha => a =>
  reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,alpha,S.Bundle{Some{motion_main(20)},None{},None{}}),alpha => b =>
  reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,alpha,S.Bundle{None{},Some{motion_aux()},Some{T.Selected{8}}}),alpha => c =>
  reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,S.Bundle{Some{motion_main(90)},None{},Some{T.Selected{8}}}),beta => z => motion_run(alpha,beta,a,b,c,z)))))

def health_main(x: U32) -> T.Vitals: T.Vitals{vector(x),9,2}
def health_aux() -> T.Armor: T.Armor{vector(1),3}
def health_ledger(unit: Unit) -> T.HealthLedger: T.HealthLedger{vector(100),4}
def health_row_text(handle: S.Handle<T.HealthSchema>,main: String,aux: String,flag: String) -> String:
  match handle:
    case S.Handle{namespace,id}: U32.show(namespace) ++ ":" ++ U32.show(id) ++ "{" ++ main ++ ";" ++ aux ++ ";" ++ flag ++ "}"
def health_client_aux(-P: Type,-U: Type,main: P,mt: String,handle: S.Handle<T.HealthSchema>,flag: Maybe<&2,T.Tracked>,result: U & Maybe<&2,T.ArmorView>) -> P & (U & String):
  match result:
    case (aux,av): (main,(aux,health_row_text(handle,mt,maybe(~T.ArmorView,~armor,av),maybe(~T.Tracked,~tracked,flag))))
def health_client_main(-P: Type,-U: Type,aux: U,get_aux: U -> U & Maybe<&2,T.ArmorView>,handle: S.Handle<T.HealthSchema>,flag: Maybe<&2,T.Tracked>,result: P & T.VitalsView) -> P & (U & String):
  match result:
    case (main,value): health_client_aux(P,U,main,vitals(value),handle,flag,get_aux(aux))
def health_client(-P: Type,-U: Type,get: P -> T.VitalsToken -> P & T.VitalsView,get_aux: U -> U & Maybe<&2,T.ArmorView>,handle: S.Handle<T.HealthSchema>,flag: Maybe<&2,T.Tracked>,main: P,aux: U) -> P & (U & String):
  health_client_main(P,U,aux,get_aux,handle,flag,get(main,T.VitalsToken{}))
def health_observe_commands(+namespace: U32,+next: U32,rows: List<S.Row<T.Vitals,T.Armor,T.Tracked>>,rt: List<&2,String>,ledger: Maybe<T.HealthLedger>,mode: T.HealthMode,result: List<S.Command<T.Vitals,T.Armor,T.Tracked>> & List<&2,String>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match result:
    case (pending,ct): observed_ledger(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~health_mode,namespace,next,rows,rt,pending,ct,mode,option(~T.HealthLedger,~T.LedgerView,~P.health_ledger_get,~ledger_show,ledger))
def health_observe_rows(namespace: U32,next: U32,pending: List<S.Command<T.Vitals,T.Armor,T.Tracked>>,ledger: Maybe<T.HealthLedger>,mode: T.HealthMode,result: List<S.Row<T.Vitals,T.Armor,T.Tracked>> & List<&2,String>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match result:
    case (rs,rt): health_observe_commands(namespace,next,rs,rt,ledger,mode,commands(~T.Vitals,~T.Armor,~T.Tracked,~T.VitalsView,~T.ArmorView,~P.vitals_get,~P.armor_get,~vitals,~armor,~tracked,pending))
def health_observe(world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match world:
    case S.World{namespace,next,rs,pending,ledger,mode}: health_observe_rows(namespace,next,pending,ledger,mode,rows(~T.Vitals,~T.Armor,~T.Tracked,~T.VitalsView,~T.ArmorView,~P.vitals_get,~P.armor_get,~vitals,~armor,~tracked,rs))
def health_query(world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selection: Q.Selection) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  query_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Q.each(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~String,~T.HealthLedger,~T.HealthMode,~P.vitals_get,~P.armor_get,~health_client,selection,world))
def health_lookup(world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,handle: S.Handle<T.HealthSchema>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  lookup_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Q.lookup(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~String,~T.HealthLedger,~T.HealthMode,~P.vitals_get,~P.armor_get,~health_client,Q.Required{},world,handle))
def health_collected(text: String,result: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match result:
    case (world,rest): (world,text ++ "\n" ++ rest)
def health_collect(result: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String,rest: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match result:
    case (world,text): health_collected(text,rest(world))
def health_snapshot(world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,+a: S.Handle<T.HealthSchema>,c: S.Handle<T.HealthSchema>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  health_collect(health_observe(world),w => health_collect(health_query(w,Q.Required{}),w => health_collect(health_query(w,Q.Present{}),w => health_collect(health_query(w,Q.Absent{}),w => health_collect(health_query(w,Q.Optional{}),w => health_collect(health_lookup(w,a),w => health_lookup(w,c)))))))
def health_rejected(result: T.CommandResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals>,next: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> String -> String) -> String:
  match result:
    case T.CommandQueued{_}: "FOREIGN_COMMAND_ACCEPTED"
    case T.CommandMissing{world,payload}: pair_text(T.Vitals,observe_result(~T.Vitals,~T.VitalsView,~vitals,P.vitals_get(payload)),owner => text => next(world,"MissingEntity;returned=" ++ text))
def health_fifo(+a: S.Handle<T.HealthSchema>,c: S.Handle<T.HealthSchema>,world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> String:
  queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,a,health_main(80)),world =>
  queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,a,health_main(81)),world =>
  applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,2),world =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(world,a,c),world => text => "Health/FIFO-alpha\n" ++ text))))
def health_foreign(+a: S.Handle<T.HealthSchema>,+c: S.Handle<T.HealthSchema>,+z: S.Handle<T.HealthSchema>,alpha: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,beta: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> String:
  queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,alpha,a,health_main(77)),alpha =>
  queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,z,health_main(78)),beta =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(alpha,a,c),alpha => beforea =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(beta,z,z),beta => beforeb =>
  health_rejected(C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,a,health_main(500)),beta => rb =>
  health_rejected(C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,alpha,z,health_main(600)),alpha => ra =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(alpha,a,c),alpha => aftera =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(beta,z,z),beta => afterb =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(beta,a),beta => foreignb =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(alpha,z),alpha => foreigna =>
  "Health/foreign-before-alpha\n" ++ beforea ++ "\nHealth/foreign-before-beta\n" ++ beforeb ++ "\n" ++ ra ++ "\n" ++ rb ++ "\nHealth/foreign-after-alpha\n" ++ aftera ++ "\nHealth/foreign-after-beta\n" ++ afterb ++ "\n" ++ foreigna ++ "\n" ++ foreignb ++ "\n" ++ health_fifo(a,c,alpha)))))))))))
def health_run(alpha: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,beta: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,+a: S.Handle<T.HealthSchema>,b: S.Handle<T.HealthSchema>,+c: S.Handle<T.HealthSchema>,+z: S.Handle<T.HealthSchema>) -> String:
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(alpha,a,c),alpha => e0a =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(beta,z,z),beta => e0b =>
  applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,alpha,1),alpha =>
  applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,1),beta =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(alpha,a,c),alpha => e1a =>
  pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_snapshot(beta,z,z),beta => e1b =>
  "Health/E0-alpha\n" ++ e0a ++ "\nHealth/E0-beta\n" ++ e0b ++ "\nHealth/E1-alpha\n" ++ e1a ++ "\nHealth/E1-beta\n" ++ e1b ++ "\n" ++ health_foreign(a,c,z,alpha,beta)))))))
def health_stage(alpha: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,beta: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> String:
  reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,alpha,S.Bundle{Some{health_main(10)},Some{health_aux()},Some{T.Tracked{8}}}),alpha => a =>
  reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,alpha,S.Bundle{Some{health_main(20)},None{},None{}}),alpha => b =>
  reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,alpha,S.Bundle{None{},Some{health_aux()},Some{T.Tracked{8}}}),alpha => c =>
  reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,S.Bundle{Some{health_main(90)},None{},Some{T.Tracked{8}}}),beta => z => health_run(alpha,beta,a,b,c,z)))))
def factory_end(factory: S.Factory,motion: String,health: String) -> String:
  match factory:
    case S.Factory{next}: "factory-next=" ++ U32.show(next) ++ "\n" ++ motion ++ "\n" ++ health
def run(factory: S.Factory) -> String:
  created(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~motion_ledger,factory,T.MotionOn{}),factory => ma =>
  created(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~motion_ledger,factory,T.MotionOn{}),factory => mb =>
  created(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~health_ledger,factory,T.HealthOn{}),factory => ha =>
  created(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~health_ledger,factory,T.HealthOn{}),factory => hb => factory_end(factory,motion_stage(ma,mb),health_stage(ha,hb))))))
def main() -> IO(Unit):
  IO.print(run(I.factory()))
