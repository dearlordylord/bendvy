import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands-bulk-controls.bend as B
import ./storage-stage-fixture.bend as F

# Actual issued command owners are partitioned, then published onto a nonempty queue.
def split(-A:Type,n:Nat,values:List<A>,reverse:List<A>) -> List<A> & List<A>:
  match n values:
    case Zero{} rest: (List.reverse(&1,A,reverse),rest)
    case Succ{k} Con{value,tail}: split(A,k,tail,value <> reverse)
    case Succ{_} Nil{}: (List.reverse(&1,A,reverse),[])
def joined(-Schema:Data,-M:Type,-A:Type,-Flag:Data,-L:Type,-Mode:Data,ns:U32,next:U32,rows:List<S.Row<M,A,Flag>>,ledger:Maybe<L>,mode:Mode,parts:List<S.Command<M,A,Flag>> & List<S.Command<M,A,Flag>>) -> S.World<Schema,M,A,Flag,L,Mode>:
  match parts:
    case (staged,pending): S.publish(Schema,M,A,Flag,L,Mode,S.World{ns,next,rows,pending,ledger,mode},staged)
def republish(-Schema:Data,-M:Type,-A:Type,-Flag:Data,-L:Type,-Mode:Data,count:U32,world:S.World<Schema,M,A,Flag,L,Mode>) -> S.World<Schema,M,A,Flag,L,Mode>:
  match world:
    case S.World{ns,next,rows,pending,ledger,mode}: joined(Schema,M,A,Flag,L,Mode,ns,next,rows,ledger,mode,split(S.Command<M,A,Flag>,U32.to_nat(U32.sub(count,1)),pending,[]))
def motion_reserved(+count:U32,state:B.Batch<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> Bool:
  match state:
    case B.Batch{world,handles,ok}: B.before(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~B.position,~B.velocity,~B.selected,~B.motion_ledger,~B.motion_mode,count,B.Batch{republish(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,count,world),handles,ok})
def health_reserved(+count:U32,state:B.Batch<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> Bool:
  match state:
    case B.Batch{world,handles,ok}: B.before(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~B.vitals,~B.armor,~B.tracked,~B.health_ledger,~B.health_mode,count,B.Batch{republish(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,count,world),handles,ok})
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
