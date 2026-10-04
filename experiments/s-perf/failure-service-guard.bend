import Base
import ./failure-overlay/experiments/s-integrate/types.bend as T
import ./failure-overlay/experiments/s-integrate/storage.bend as S
import ./failure-overlay/experiments/s-integrate/observations.bend as O
import ./failure-overlay/experiments/s-integrate/audited-invoker.bend as AI
import ./failure-overlay/experiments/s-integrate/transaction-dispatch-adapters.bend as A
import ./failure-checks.bend as F

def checked(-Result:Type,valid:Bool,result:Result) -> IO(Result):
  match valid:
    case True{}: IO.pure(Result,result)
    case False{}: IO.die(Result,24,"quiet service own-write/reservation/ping full-field guard")
def guard(~W:Type,~Schema:Data,~V:Data,~AV:Data,~Flag:Data,~main:V -> T.Four -> Bool,count:U32,+i:U32,+b:Bool,motion:Bool,result:AI.ServiceResult<W,S.Handle<Schema>,V,AV,Flag>) -> IO(AI.ServiceResult<W,S.Handle<Schema>,V,AV,Flag>):
  match result:
    case AI.ServiceResult{A.RunResult{world,+outcome,+handle,+views,+pings},audit,+reservation}: checked(AI.ServiceResult<W,S.Handle<Schema>,V,AV,Flag>,Bool.and(F.own(i,b,motion,views),Bool.and(F.reservation(~V,~AV,~Flag,~main,i,b,reservation),Bool.and(F.escaped(Schema,count,i,b,F.did_fail(outcome),handle),F.published(i,b,F.did_fail(outcome),pings)))),AI.ServiceResult{A.RunResult{world,outcome,handle,views,pings},audit,reservation})
