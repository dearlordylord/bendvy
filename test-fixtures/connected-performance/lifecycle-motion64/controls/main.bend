import Base
import core.bend as C
import ../../../../src/ecs/world-io.bend as WI

def create(fail:Bool,result:WI.Creation<Unit,Unit,Unit,Unit>) -> C.Created:
  match result:
    case WI.Created{world}:C.register(world,fail)
    case _:C.Refused{}
def make(fail:Bool) -> IO(C.Created):IO.bind(WI.Creation<Unit,Unit,Unit,Unit>,C.Created,WI.create(~Unit,~Unit,~Unit,~Unit,~C.empty,Unit{}),result => IO.pure(C.Created,create(fail,result)))
def foreign_first(first:C.Created) -> IO(Unit):IO.bind(C.Created,Unit,make(False{}),second => C.foreign_pair(first,second))
def after_wrong(_:Unit) -> IO(Unit):IO.bind(C.Created,Unit,make(False{}),foreign_first)
def after_failure(_:Unit) -> IO(Unit):IO.bind(Unit,Unit,IO.bind(C.Created,Unit,make(False{}),C.wrong),after_wrong)
def after_normal(_:Unit) -> IO(Unit):IO.bind(Unit,Unit,IO.bind(C.Created,Unit,make(True{}),C.failing),after_failure)
def main() -> IO(Unit):IO.bind(Unit,Unit,IO.bind(C.Created,Unit,make(False{}),C.normal),after_normal)
