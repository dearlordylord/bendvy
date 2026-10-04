import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./query.bend as Q
import ./observations.bend as O
import ./host.bend as H
import ./commands-bulk-controls.bend as B
import ./storage-stage-fixture.bend as F

def aux(value:Maybe<&2,Bool>) -> Bool:
  match value:
    case Some{valid}: valid
    case None{}: False{}
def rows(~Schema:Data,~Flag:Data,~check:Flag -> Bool,values:List<&2,O.QueryRow<Schema,Bool,Bool,Flag>>,+count:U32,+next:U32,ok:Bool) -> Bool:
  match values:
    case Nil{}: Bool.and(ok,U32.is_eq(next,U32.add(count,1)))
    case Con{O.QueryRow{S.Handle{ns,+id},main,a,flag},tail}:
      rows(Schema,Flag,check,tail,count,U32.add(next,1),Bool.and(ok,Bool.and(U32.is_eq(ns,1),Bool.and(U32.is_eq(id,next),Bool.and(main,Bool.and(aux(a),B.flag(Flag,check,flag)))))))
def world_rows(~Flag:Data,~check:Flag -> Bool,values:List<&2,O.RowView<Bool,Bool,Flag>>,+count:U32,+next:U32,ok:Bool) -> Bool:
  match values:
    case Nil{}: Bool.and(ok,U32.is_eq(next,U32.add(count,1)))
    case Con{O.RowView{id,main,a,flag,added,changed},tail}:
      world_rows(Flag,check,tail,count,U32.add(next,1),Bool.and(ok,Bool.and(U32.is_eq(id,next),Bool.and(aux(main),Bool.and(aux(a),Bool.and(B.flag(~Flag,~check,flag),Bool.and(U32.is_eq(added,1),U32.is_eq(changed,1))))))))
def empty(-A:Data,value:List<&2,A>) -> Bool:
  match value:
    case Nil{}: True{}
    case _: False{}
def marks(~Schema:Data,~Flag:Data,~check:Flag -> Bool,+count:U32,+rs:List<&2,O.RowView<Bool,Bool,Flag>>,+values:List<&2,O.QueryRow<Schema,Bool,Bool,Flag>>) -> Bool:
  Bool.and(rows(Schema,Flag,check,H.filter_mark(Schema,Bool,Bool,Flag,rs,False{},0,1,values),count,1,True{}),Bool.and(rows(Schema,Flag,check,H.filter_mark(Schema,Bool,Bool,Flag,rs,True{},0,1,values),count,1,True{}),Bool.and(empty(O.QueryRow<Schema,Bool,Bool,Flag>,H.filter_mark(Schema,Bool,Bool,Flag,rs,False{},1,1,values)),empty(O.QueryRow<Schema,Bool,Bool,Flag>,H.filter_mark(Schema,Bool,Bool,Flag,rs,True{},0,0,values)))))
def observed(~Schema:Data,~M:Type,~A:Type,~Flag:Data,~L:Type,~Mode:Data,~flag_read:Flag -> Bool,~mode_read:Mode -> Bool,+count:U32,ok:Bool,values:List<&2,O.QueryRow<Schema,Bool,Bool,Flag>>,result:S.World<Schema,M,A,Flag,L,Mode> & O.WorldView<Bool,Bool,Flag,Bool,Mode>) -> Bool:
  match result:
    case (_,O.WorldView{ns,next,+rs,pending,ledger,mode}): Bool.and(Bool.and(Bool.and(ok,mode_read(mode)),marks(Schema,Flag,flag_read,count,rs,values)),Bool.and(U32.is_eq(ns,1),Bool.and(U32.is_eq(next,U32.add(count,1)),Bool.and(world_rows(Flag,flag_read,rs,count,1,True{}),Bool.and(empty(O.PendingView<Bool,Bool,Flag>,pending),aux(ledger))))))
def motion_observe(+count:U32,ok:Bool,values:List<&2,O.QueryRow<T.MotionSchema,Bool,Bool,T.Selected>>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> Bool:
  observed(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,B.selected,B.motion_mode,count,ok,values,O.world(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~Bool,~Bool,~Bool,~B.position,~B.velocity,~B.motion_ledger,world))
def health_observe(+count:U32,ok:Bool,values:List<&2,O.QueryRow<T.HealthSchema,Bool,Bool,T.Tracked>>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> Bool:
  observed(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,B.tracked,B.health_mode,count,ok,values,O.world(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~Bool,~Bool,~Bool,~B.vitals,~B.armor,~B.health_ledger,world))
def motion_result(+count:U32,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,Bool,Bool,T.Selected>>) -> Bool:
  match result:
    case (world,+values): motion_observe(count,rows(T.MotionSchema,T.Selected,B.selected,values,count,1,True{}),values,world)
def health_result(+count:U32,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,Bool,Bool,T.Tracked>>) -> Bool:
  match result:
    case (world,+values): health_observe(count,rows(T.HealthSchema,T.Tracked,B.tracked,values,count,1,True{}),values,world)
def motion_applied(count:U32,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> Bool:
  match result:
    case (world,_): motion_result(count,Q.each(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.PositionToken,~Bool,~Bool,~O.QueryRow<T.MotionSchema,Bool,Bool,T.Selected>,~T.MotionLedger,~T.MotionMode,~B.position,~B.velocity,~O.client(~T.MotionSchema,~T.PositionToken,~Bool,~Bool,~T.Selected,~T.PositionToken{}),Q.Required{},world))
def health_applied(count:U32,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> Bool:
  match result:
    case (world,_): health_result(count,Q.each(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.VitalsToken,~Bool,~Bool,~O.QueryRow<T.HealthSchema,Bool,Bool,T.Tracked>,~T.HealthLedger,~T.HealthMode,~B.vitals,~B.armor,~O.client(~T.HealthSchema,~T.VitalsToken,~Bool,~Bool,~T.Tracked,~T.VitalsToken{}),Q.Required{},world))
def motion_reserved(count:U32,state:B.Batch<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> Bool:
  match state:
    case B.Batch{world,_,_}: motion_applied(count,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1))
def health_reserved(count:U32,state:B.Batch<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> Bool:
  match state:
    case B.Batch{world,_,_}: health_applied(count,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1))
def motion_created(+count:U32,result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> Bool:
  match result:
    case T.CreateRejected{_}: False{}
    case T.Created{_,world}: motion_reserved(count,B.reserve(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~B.motion_bundle,U32.to_nat(count),B.Batch{world,[],True{}}))
def health_created(+count:U32,result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> Bool:
  match result:
    case T.CreateRejected{_}: False{}
    case T.Created{_,world}: health_reserved(count,B.reserve(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~B.health_bundle,U32.to_nat(count),B.Batch{world,[],True{}}))
def choose(schema:U32,+count:U32) -> Bool:
  match schema:
    case 0: motion_created(count,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~F.motion_ledger,I.factory(),T.MotionOn{}))
    case 1: health_created(count,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~F.health_ledger,I.factory(),T.HealthOn{}))
    case _: False{}
def parsed(schema:Maybe<&2,U32>,count:Maybe<&2,U32>) -> IO(Unit):
  match schema count:
    case Some{schema} Some{count}: IO.print(F.bool(choose(schema,count)))
    case _ _: IO.die(Unit,2,"invalid arguments")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,_}}}: parsed(U32.read(schema),U32.read(count))
    case _: IO.die(Unit,2,"schema count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
