import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as S
type Schema is Data:
  Schema{}
type Error is Data:
  Error{}
def empty(u: Unit) -> Unit:
  Unit{}
def body(world: W.World<Schema,Unit,U32,U32>,ok: Bool) -> S.Outcome<W.World<Schema,Unit,U32,U32>,Error,Unit>:
  match ok:
    case False{}: S.Failed{world,Error{}}
    case True{}: S.Succeeded{world,Unit{}}
def finish(result: S.RunResult<Schema,Unit,U32,U32,Bool,Error,Unit,body>) -> U32:
  match result:
    case S.RegistrationRejected{_,_,_}: 990
    case S.Completed{S.Registry{_,+id,_,_,+cursor},S.Succeeded{_,_}}: (id * 100 + cursor : U32)
    case S.Completed{_,S.Failed{_,_}}: 991
def retry_allowed(ok: Bool,registry: S.Registry<Schema,Unit,U32,U32,Bool,Error,Unit,body>,world: W.World<Schema,Unit,U32,U32>) -> U32:
  match ok:
    case False{}: 992
    case True{}: finish(S.run_to_cursor(~Schema,~Unit,~U32,~U32,~Bool,~Error,~Unit,~body,registry,world,True{},7))
def retry_meta(registry: S.Registry<Schema,Unit,U32,U32,Bool,Error,Unit,body>,world: W.World<Schema,Unit,U32,U32>) -> U32:
  match registry:
    case S.Registry{+namespace,+id,+name,+access,+cursor}: retry_allowed(Bool.and(U32.is_eq(id,1),U32.is_eq(cursor,0)),S.Registry{namespace,id,name,access,cursor},world)
def retry(result: S.RunResult<Schema,Unit,U32,U32,Bool,Error,Unit,body>) -> U32:
  match result:
    case S.RegistrationRejected{_,_,_}: 993
    case S.Completed{registry,S.Failed{world,_}}: retry_meta(registry,world)
    case S.Completed{_,S.Succeeded{_,_}}: 994
def registered(result: S.RegistrationResult<Schema,Unit,U32,U32,Bool,Error,Unit,body>) -> U32:
  match result:
    case S.RegistrationFailed{_}: 995
    case S.Registered{world,registry}: retry(S.run_to_cursor(~Schema,~Unit,~U32,~U32,~Bool,~Error,~Unit,~body,registry,world,False{},99))
def created(result: W.Creation<Schema,Unit,U32,U32>) -> U32:
  match result:
    case W.CreateRejected{_,_}: 996
    case W.Created{_,world}: registered(S.register(~Schema,~Unit,~U32,~U32,~Bool,~Error,~Unit,~body,world,"reader",["events.read"]))
def main() -> U32:
  created(W.create(~Schema,~Unit,~U32,~U32,~empty,W.factory(),0))
