import Base
import core.bend as Core
import foreign-driver.bend as Foreign
import schema.bend as S
import ../../../../../../../../src/ecs/ordinary-service-declaration.bend as Service
import ../../../../../../../../src/ecs/world-io.bend as WI
import ../../../../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../../../../src/ecs/ordinary-app-records.bend as Leaf

def second(app:Core.Registered(),value:WI.Creation<S.Schema,S.Store,S.Resources,Unit>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.print(Foreign.evaluate(app,world))
    case _:IO.die(Unit,1,"second world refused")
def registered(app:Core.Registered()) -> IO(Unit):
  IO.bind(WI.Creation<S.Schema,S.Store,S.Resources,Unit>,Unit,WI.create(~S.Schema,~S.Store,~S.Resources,~Unit,~S.empty,S.Resources{Service.Ready{Array.new(U32,0n,0)}}),second(app))
def service_failed(app:Core.First()) -> IO(Unit):IO.die(Unit,1,"service registration refused")
def component_done(app:Core.First()) -> IO(Unit):
  Core.service_added(~IO(Unit),registered,service_failed,app)
def component_failed(app:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())>) -> IO(Unit):IO.die(Unit,1,"component registration refused")
def first(value:WI.Creation<S.Schema,S.Store,S.Resources,Unit>) -> IO(Unit):
  match value:
    case WI.Created{world}:Core.component_added(~IO(Unit),component_done,component_failed,world)
    case _:IO.die(Unit,1,"first world refused")
def main() -> IO(Unit):
  IO.bind(WI.Creation<S.Schema,S.Store,S.Resources,Unit>,Unit,WI.create(~S.Schema,~S.Store,~S.Resources,~Unit,~S.empty,S.Resources{Service.Ready{Array.new(U32,0n,0)}}),first)
