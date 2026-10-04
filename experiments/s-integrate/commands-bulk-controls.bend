import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./payload.bend as P
import ./storage-stage-fixture.bend as F

# Real affine payloads are read and immediately returned, never reconstructed from views.
def eq4(value: T.Four,+x: U32) -> Bool:
  match value:
    case T.Four{a,b,c,d}: Bool.and(U32.is_eq(a,x),Bool.and(U32.is_eq(b,U32.add(x,1)),Bool.and(U32.is_eq(c,U32.add(x,2)),U32.is_eq(d,U32.add(x,3)))))
def position_read(result: T.Position & T.PositionView) -> T.Position & Bool:
  match result:
    case (owner,T.PositionView{v,f}): (owner,Bool.and(eq4(v,10),U32.is_eq(f,7)))
def position(owner: T.Position) -> T.Position & Bool: position_read(P.position_get(owner))
def velocity_read(result: T.Velocity & T.VelocityView) -> T.Velocity & Bool:
  match result:
    case (owner,T.VelocityView{v,m}): (owner,Bool.and(eq4(v,1),m))
def velocity(owner: T.Velocity) -> T.Velocity & Bool: velocity_read(P.velocity_get(owner))
def vitals_read(result: T.Vitals & T.VitalsView) -> T.Vitals & Bool:
  match result:
    case (owner,T.VitalsView{v,r,c}): (owner,Bool.and(eq4(v,10),Bool.and(U32.is_eq(r,9),U32.is_eq(c,2))))
def vitals(owner: T.Vitals) -> T.Vitals & Bool: vitals_read(P.vitals_get(owner))
def armor_read(result: T.Armor & T.ArmorView) -> T.Armor & Bool:
  match result:
    case (owner,T.ArmorView{v,g}): (owner,Bool.and(eq4(v,1),U32.is_eq(g,3)))
def armor(owner: T.Armor) -> T.Armor & Bool: armor_read(P.armor_get(owner))
def selected(value: T.Selected) -> Bool:
  match value:
    case T.Selected{g}: U32.is_eq(g,8)
def tracked(value: T.Tracked) -> Bool:
  match value:
    case T.Tracked{g}: U32.is_eq(g,8)
def ledger_result(-L: Type,result: L & T.LedgerView) -> L & Bool:
  match result:
    case (owner,T.LedgerView{v,e}): (owner,Bool.and(eq4(v,100),U32.is_eq(e,4)))
def motion_ledger(owner: T.MotionLedger) -> T.MotionLedger & Bool: ledger_result(T.MotionLedger,P.motion_ledger_get(owner))
def health_ledger(owner: T.HealthLedger) -> T.HealthLedger & Bool: ledger_result(T.HealthLedger,P.health_ledger_get(owner))
def motion_mode(value: T.MotionMode) -> Bool:
  match value:
    case T.MotionOn{}: True{}
    case T.MotionOff{}: False{}
def health_mode(value: T.HealthMode) -> Bool:
  match value:
    case T.HealthOn{}: True{}
    case T.HealthOff{}: False{}
def motion_bundle(unit: Unit) -> S.Bundle<T.Position,T.Velocity,T.Selected>:
  S.Bundle{Some{T.Position{F.vector(10),7}},Some{T.Velocity{F.vector(1),True{}}},Some{T.Selected{8}}}
def health_bundle(unit: Unit) -> S.Bundle<T.Vitals,T.Armor,T.Tracked>:
  S.Bundle{Some{T.Vitals{F.vector(10),9,2}},Some{T.Armor{F.vector(1),3}},Some{T.Tracked{8}}}

def option_done(-A: Type,result: A & Bool) -> Maybe<A> & Bool:
  match result:
    case (owner,ok): (Some{owner},ok)
def option(~A: Type,~read: A -> A & Bool,present: Bool,owner: Maybe<A>) -> Maybe<A> & Bool:
  match present owner:
    case False{} None{}: (None{},True{})
    case True{} Some{v}: option_done(A,read(v))
    case _ v: (v,False{})
def flag(~F: Data,~check: F -> Bool,value: Maybe<&2,F>) -> Bool:
  match value:
    case None{}: False{}
    case Some{v}: check(v)
def row_aux(-M: Type,-A: Type,-F: Data,id: U32,added: U32,changed: U32,main: Maybe<M>,flag: Maybe<&2,F>,ok: Bool,result: Maybe<A> & Bool) -> S.Row<M,A,F> & Bool:
  match result:
    case (aux,valid): (S.Row{id,main,aux,flag,added,changed},Bool.and(ok,valid))
def row_main(~M: Type,~A: Type,~F: Data,~ar: A -> A & Bool,id: U32,added: U32,changed: U32,aux: Maybe<A>,flag: Maybe<&2,F>,ok: Bool,result: Maybe<M> & Bool) -> S.Row<M,A,F> & Bool:
  match result:
    case (main,valid): row_aux(M,A,F,id,added,changed,main,flag,Bool.and(ok,valid),option(~A,~ar,True{},aux))
def row(~M: Type,~A: Type,~F: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,present: Bool,expected: U32,+mark: U32,value: S.Row<M,A,F>) -> S.Row<M,A,F> & Bool:
  match value:
    case S.Row{+id,main,aux,+f,+added,+changed}: row_main(~M,~A,~F,~ar,id,added,changed,aux,f,Bool.and(U32.is_eq(id,expected),Bool.and(U32.is_eq(added,mark),Bool.and(U32.is_eq(changed,mark),flag(~F,~fc,f)))),option(~M,~mr,present,main))
type Rows<-M: Type,-A: Type,-F: Data> is Type:
  Rows{reverse: List<S.Row<M,A,F>>,next: U32,ok: Bool}
def row_acc(-M: Type,-A: Type,-F: Data,reverse: List<S.Row<M,A,F>>,next: U32,ok: Bool,result: S.Row<M,A,F> & Bool) -> Rows<M,A,F>:
  match result:
    case (r,valid): Rows{r <> reverse,U32.add(next,1),Bool.and(ok,valid)}
def rows(~M: Type,~A: Type,~F: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,values: List<S.Row<M,A,F>>,+present: Bool,+mark: U32,+count: U32,state: Rows<M,A,F>) -> List<S.Row<M,A,F>> & Bool:
  match values state:
    case Nil{} Rows{reverse,next,ok}: (List.reverse(&1,S.Row<M,A,F>,reverse),Bool.and(ok,U32.is_eq(next,U32.add(count,1))))
    case Con{v,tail} Rows{reverse,+next,ok}: rows(~M,~A,~F,~mr,~ar,~fc,tail,present,mark,count,row_acc(M,A,F,reverse,next,ok,row(~M,~A,~F,~mr,~ar,~fc,present,next,mark,v)))
def nil(-A: Type,value: List<A>) -> List<A> & Bool:
  match value:
    case Nil{}: ([],True{})
    case values: (values,False{})
def list_nil(-A: Type,value: List<A>) -> Bool:
  match value:
    case Nil{}: True{}
    case _: False{}

def world_ledger(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,namespace: U32,next: U32,rows: List<S.Row<M,A,F>>,pending: List<S.Command<M,A,F>>,mode: Mode,ok: Bool,result: Maybe<L> & Bool) -> S.World<Schema,M,A,F,L,Mode> & Bool:
  match result:
    case (ledger,valid): (S.World{namespace,next,rows,pending,ledger,mode},Bool.and(ok,valid))
def world_rows(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~lr: L -> L & Bool,namespace: U32,next: U32,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,ok: Bool,result: List<S.Row<M,A,F>> & Bool) -> S.World<Schema,M,A,F,L,Mode> & Bool:
  match result:
    case (rs,valid): world_ledger(Schema,M,A,F,L,Mode,namespace,next,rs,pending,mode,Bool.and(ok,valid),option(~L,~lr,True{},ledger))
def world_pending(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,+count: U32,present: Bool,mark: U32,expectedRows: U32,+namespace: U32,+next: U32,rs: List<S.Row<M,A,F>>,ledger: Maybe<L>,+mode: Mode,result: List<S.Command<M,A,F>> & Bool) -> S.World<Schema,M,A,F,L,Mode> & Bool:
  match result:
    case (pending,valid): world_rows(~Schema,~M,~A,~F,~L,~Mode,~lr,namespace,next,pending,ledger,mode,Bool.and(valid,Bool.and(U32.is_eq(namespace,1),Bool.and(U32.is_eq(next,U32.add(count,1)),mc(mode)))),rows(~M,~A,~F,~mr,~ar,~fc,rs,present,mark,expectedRows,Rows{[],1,True{}}))
def world(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,count: U32,present: Bool,mark: U32,expectedRows: U32,value: S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode> & Bool:
  match value:
    case S.World{ns,next,rs,pending,ledger,mode}: world_pending(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,present,mark,expectedRows,ns,next,rs,ledger,mode,nil(S.Command<M,A,F>,pending))
type Batch<-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data> is Type:
  Batch{world: S.World<Schema,M,A,F,L,Mode>,handles: List<&2,S.Handle<Schema>>,ok: Bool}
def reserved(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,handles: List<&2,S.Handle<Schema>>,ok: Bool,result: T.Reservation<S.World<Schema,M,A,F,L,Mode>,S.Handle<Schema>,S.Bundle<M,A,F>>) -> Batch<Schema,M,A,F,L,Mode>:
  match result:
    case T.Reserved{world,handle}: Batch{world,handle <> handles,ok}
    case T.ReserveRejected{world,_}: Batch{world,handles,False{}}
def reserve(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~make: Unit -> S.Bundle<M,A,F>,count: Nat,state: Batch<Schema,M,A,F,L,Mode>) -> Batch<Schema,M,A,F,L,Mode>:
  match count state:
    case Zero{} Batch{world,handles,ok}: Batch{world,List.reverse(&2,S.Handle<Schema>,handles),ok}
    case Succ{n} Batch{world,handles,ok}: reserve(~Schema,~M,~A,~F,~L,~Mode,~make,n,reserved(Schema,M,A,F,L,Mode,handles,ok,C.reserve(Schema,M,A,F,L,Mode,world,make(Unit{}))))
def queued(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,result: T.CommandResult<S.World<Schema,M,A,F,L,Mode>,Unit>) -> S.World<Schema,M,A,F,L,Mode>:
  match result:
    case T.CommandQueued{world}: world
    case T.CommandMissing{world,_}: world
# Receives the actual handles returned by reserve, never synthesized identifiers.
def stage(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~op: S.World<Schema,M,A,F,L,Mode> -> S.Handle<Schema> -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,Unit>,handles: List<&2,S.Handle<Schema>>,world: S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode>:
  match handles:
    case Nil{}: world
    case Con{h,tail}: stage(~Schema,~M,~A,~F,~L,~Mode,~op,tail,queued(Schema,M,A,F,L,Mode,op(world,h)))
def changes(-Schema: Data,values: List<&2,S.Change<Schema>>,+phase: U32,+count: U32,+expected: U32,part: U32,ok: Bool) -> Bool:
  match values:
    case Nil{}: Bool.and(ok,Bool.and(U32.is_eq(expected,U32.add(count,1)),U32.is_eq(part,0)))
    case Con{S.MainAdded{S.Handle{ns,id}},tail}: changes(Schema,tail,phase,count,expected,1,Bool.and(ok,Bool.and(U32.is_eq(phase,0),Bool.and(U32.is_eq(part,0),Bool.and(U32.is_eq(ns,1),U32.is_eq(id,expected))))))
    case Con{S.MainChanged{S.Handle{ns,id}},tail}: changes(Schema,tail,phase,count,U32.add(expected,1),0,Bool.and(ok,Bool.and(U32.is_eq(phase,0),Bool.and(U32.is_eq(part,1),Bool.and(U32.is_eq(ns,1),U32.is_eq(id,expected))))))
    case Con{S.MainRemoved{S.Handle{ns,id}},tail}: changes(Schema,tail,phase,count,U32.add(expected,1),0,Bool.and(ok,Bool.and(U32.is_eq(phase,1),Bool.and(U32.is_eq(part,0),Bool.and(U32.is_eq(ns,1),U32.is_eq(id,expected))))))
    case Con{S.Despawned{S.Handle{ns,id}},tail}: changes(Schema,tail,phase,count,U32.add(expected,1),0,Bool.and(ok,Bool.and(U32.is_eq(phase,2),Bool.and(U32.is_eq(part,0),Bool.and(U32.is_eq(ns,1),U32.is_eq(id,expected))))))
def merge(-W: Type,ok: Bool,result: W & Bool) -> W & Bool:
  match result:
    case (w,valid): (w,Bool.and(ok,valid))
def checked_apply(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,+count: U32,phase: U32,present: Bool,mark: U32,expectedRows: U32,result: S.World<Schema,M,A,F,L,Mode> & List<&2,S.Change<Schema>>) -> S.World<Schema,M,A,F,L,Mode> & Bool:
  match result:
    case (w,log): merge(S.World<Schema,M,A,F,L,Mode>,changes(Schema,log,phase,count,1,0,True{}),world(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,present,mark,expectedRows,w))
def final(-W: Type,ok: Bool,result: W & Bool) -> Bool:
  match result:
    case (_,valid): Bool.and(ok,valid)
def removed(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,count: U32,handles: List<&2,S.Handle<Schema>>,ok: Bool,result: S.World<Schema,M,A,F,L,Mode> & Bool) -> Bool:
  match result:
    case (w,valid): final(S.World<Schema,M,A,F,L,Mode>,Bool.and(ok,valid),checked_apply(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,2,False{},0,0,C.apply(Schema,M,A,F,L,Mode,stage(~Schema,~M,~A,~F,~L,~Mode,~C.despawn(Schema,M,A,F,L,Mode),handles,w),3)))
def spawned(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,+count: U32,+handles: List<&2,S.Handle<Schema>>,ok: Bool,result: S.World<Schema,M,A,F,L,Mode> & Bool) -> Bool:
  match result:
    case (w,valid): removed(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,handles,Bool.and(ok,valid),checked_apply(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,1,False{},0,count,C.apply(Schema,M,A,F,L,Mode,stage(~Schema,~M,~A,~F,~L,~Mode,~C.remove_main(Schema,M,A,F,L,Mode),handles,w),2)))
def pending_count(-A: Type,values: List<A>,reverse: List<A>,count: U32) -> List<A> & U32:
  match values:
    case Nil{}: (List.reverse(&1,A,reverse),count)
    case Con{v,tail}: pending_count(A,tail,v <> reverse,U32.add(count,1))
def before_count(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,+count: U32,handles: List<&2,S.Handle<Schema>>,ok: Bool,+ns: U32,+next: U32,rs: List<S.Row<M,A,F>>,ledger: Maybe<L>,mode: Mode,result: List<S.Command<M,A,F>> & U32) -> Bool:
  match result:
    case (pending,n): spawned(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,handles,Bool.and(ok,Bool.and(U32.is_eq(n,count),Bool.and(U32.is_eq(ns,1),U32.is_eq(next,U32.add(count,1))))),checked_apply(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,0,True{},1,count,C.apply(Schema,M,A,F,L,Mode,S.World{ns,next,rs,pending,ledger,mode},1)))
def before(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,count: U32,state: Batch<Schema,M,A,F,L,Mode>) -> Bool:
  match state:
    case Batch{S.World{ns,next,Nil{},pending,ledger,mode},handles,ok}: before_count(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,handles,ok,ns,next,[],ledger,mode,pending_count(S.Command<M,A,F>,pending,[],0))
    case _: False{}
def created(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~mr: M -> M & Bool,~ar: A -> A & Bool,~fc: F -> Bool,~lr: L -> L & Bool,~mc: Mode -> Bool,~make: Unit -> S.Bundle<M,A,F>,+count: U32,result: T.Creation<S.Factory,S.World<Schema,M,A,F,L,Mode>>) -> Bool:
  match result:
    case T.CreateRejected{_}: False{}
    case T.Created{_,w}: before(~Schema,~M,~A,~F,~L,~Mode,~mr,~ar,~fc,~lr,~mc,count,reserve(~Schema,~M,~A,~F,~L,~Mode,~make,U32.to_nat(count),Batch{w,[],True{}}))

def motion(+count: U32) -> Bool:
  created(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~position,~velocity,~selected,~motion_ledger,~motion_mode,~motion_bundle,count,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~F.motion_ledger,I.factory(),T.MotionOn{}))

def health(+count: U32) -> Bool:
  created(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~vitals,~armor,~tracked,~health_ledger,~health_mode,~health_bundle,count,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~F.health_ledger,I.factory(),T.HealthOn{}))
