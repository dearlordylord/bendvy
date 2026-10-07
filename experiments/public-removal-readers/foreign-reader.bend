import Base
import ./schema.bend as S
import ../../src/ecs/world.bend as W
import ../../src/ecs/removals.bend as Rm

def retried(result: Rm.Disposal<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected>) -> IO(Unit):
  match result:
    case Rm.Disposed{world}: IO.print("foreign-reader:run-rejected;dispose-rejected;owner-recovered;valid-dispose")
    case _: IO.print("OWNER_RECOVERY_BUG")
def disposed(original: W.World<S.Schema,S.Store,Unit,S.Notice>,result: Rm.Disposal<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected>) -> IO(Unit):
  match result:
    case Rm.DisposalRejected{world,reader}: retried(Rm.dispose(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,reader,original))
    case _: IO.print("FOREIGN_DISPOSE_BUG")
def rejected(original: W.World<S.Schema,S.Store,Unit,S.Notice>,result: Rm.Run<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected,Unit,String>) -> IO(Unit):
  match result:
    case Rm.Invalid{reader,world}: disposed(original,Rm.dispose(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,reader,world))
    case _: IO.print("FOREIGN_RUN_BUG")
def second(original: W.World<S.Schema,S.Store,Unit,S.Notice>,reader: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,created: W.Creation<S.Schema,S.Store,Unit,S.Notice>) -> IO(Unit):
  match created:
    case W.Created{_,world}: rejected(original,Rm.run(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,~Unit,~String,~S.consume,reader,world))
    case _: IO.print("CREATE_ERROR")
def registered(factory: W.Factory,result: Rm.Registered<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected>) -> IO(Unit):
  match result:
    case Rm.Registered{world,reader}: second(world,reader,W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty,factory,Unit{}))
    case _: IO.print("REGISTER_ERROR")
def first(created: W.Creation<S.Schema,S.Store,Unit,S.Notice>) -> IO(Unit):
  match created:
    case W.Created{factory,world}: registered(factory,Rm.register(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,world,"bound"))
    case _: IO.print("CREATE_ERROR")
def main() -> IO(Unit):
  first(W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty,W.factory(),Unit{}))
