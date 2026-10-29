import Base
import ./schema.bend as Schema
import ./bodies.bend as Body
import ./observe.bend as Observe
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/dependency-executor.bend as Exec
import ../../../src/ecs/dependency-plan.bend as Plan
import ../../../src/ecs/dependency-registration.bend as Reg
import ../../../src/ecs/dependency-application.bend as Schedule
import ../../../src/ecs/dependency-registry-program.bend as Cond

def writable_returned(~H:Type,local:Schema.Local,result:H & U32) -> H & (Schema.Local & Sys.Completion<String,Bool>):
  match local result:
    case Schema.Local{token,runs}, (scope,_):(scope,(Schema.Local{token,U32.add(runs,1)},Sys.Success{True{}}))
def writable(~H:Type,~caps:Schema.Write()(H),scope:H,local:Schema.Local) -> H & (Schema.Local & Sys.Completion<String,Bool>):
  writable_returned(~H,local,Access.resource_modify_field(~H,~Schema.Counter,~U32,caps)(Schema.increment,scope))

def Reader(~S:Data) -> Type:Sys.Owner<S,Unit,Unit,Schema.Resources(~S),Unit,Schema.Read(),Schema.Local,String,U32,Schema.read(~S),Body.reader>
def ReaderDispatch(~S:Data) -> Reader(~S) -> Schema.World(~S) -> U32 -> Reader(~S) & (Schema.World(~S) & Exec.Invocation<String,U32>):
  Reg.leaf_dispatch(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader)

def Guard(~S:Data) -> Type:Sys.Owner<S,Unit,Unit,Schema.Resources(~S),Unit,Schema.Write(),Schema.Local,String,Bool,Schema.write(~S),writable>
def GuardDispatch(~S:Data) -> Guard(~S) -> Schema.World(~S) -> U32 -> Guard(~S) & (Schema.World(~S) & Exec.Invocation<String,Bool>):
  Reg.leaf_dispatch(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Write(),~Schema.Local,~String,~Bool,~Schema.write(~S),~writable)
def observed(~S:Data,result:Schedule.Application<Schema.World(~S),Reader(~S),Guard(~S),Schema.Handler,String,U32,ReaderDispatch(~S),GuardDispatch(~S),Body.handle> & Schedule.Report<String,U32>) -> String:
  match result:
    case (Schedule.Application{Schedule.State{world,Sys.Owner{readerNamespace,readerId,readerName,readerAccess,readerCursor,reader},Sys.Owner{guardNamespace,guardId,guardName,guardAccess,guardCursor,guard},handler,stateBindings},actualPlan,appBindings},Schedule.Invalid{Plan.InvalidCondition{id}}):"invalid-condition/" ++ U32.show(id) ++ "|" ++ Observe.world(~S,world) ++ "|reader=" ++ Observe.owner(readerNamespace,readerId,readerName,readerAccess,readerCursor,reader) ++ "|guard=" ++ Observe.owner(guardNamespace,guardId,guardName,guardAccess,guardCursor,guard) ++ "|handler=" ++ Observe.handler(handler) ++ "|state-bindings=" ++ Observe.bindings(stateBindings) ++ "|plan=" ++ Observe.plan(actualPlan) ++ "|app-bindings=" ++ Observe.bindings(appBindings)
    case _ :"ERROR: writable condition was not refused"
def built(~S:Data,world:Schema.World(~S),reader:Reader(~S),guard:Guard(~S)) -> String:
  observed(~S,Schedule.run(~Schema.World(~S),~Reader(~S),~Guard(~S),~Schema.Handler,~String,~U32,~ReaderDispatch(~S),~GuardDispatch(~S),~Body.handle,Schedule.build(~Schema.World(~S),~Reader(~S),~Guard(~S),~Schema.Handler,~String,~U32,~ReaderDispatch(~S),~GuardDispatch(~S),~Cond.leaf(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader),~Cond.leaf(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Write(),~Schema.Local,~String,~Bool,~Schema.write(~S),~writable),~Body.handle,~Schema.available,world,reader,guard,Schema.Handler{ALeaf{701},[]},[],[Schedule.Binding{1,2}])))
def registered_guard(~S:Data,reader:Reader(~S),result:Sys.Defined<Schema.World(~S),Guard(~S),Schema.Local>) -> String:
  match result:
    case Sys.Defined{world,guard}:built(~S,world,reader,guard)
    case _ :"ERROR: guard registration"
def registered_reader(~S:Data,result:Sys.Defined<Schema.World(~S),Reader(~S),Schema.Local>) -> String:
  match result:
    case Sys.Defined{world,reader}:registered_guard(~S,reader,Sys.define(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Write(),~Schema.Local,~String,~Bool,~Schema.write(~S),~writable,world,"writable-guard",Schema.Local{ALeaf{902},0}))
    case _ :"ERROR: reader registration"
def created(~S:Data,result:W.Creation<S,Unit,Schema.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:registered_reader(~S,Sys.define(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader,world,"reader",Schema.Local{ALeaf{901},0}))
    case _ :"ERROR: creation"
def scenario(~S:Data) -> String:
  created(~S,W.create(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.empty,W.factory(),Schema.resources(~S)))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("alpha=" ++ scenario(~Schema.Alpha))
    IO.print("beta=" ++ scenario(~Schema.Beta))
