import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/registration.bend as Reg

def empty(u: Unit) -> Unit:
  u

def shown(observed: W.World<Unit,Unit,Unit,Unit> & Bool) -> IO(Unit):
  match observed:
    case (_,present): IO.print(Bool.show(present))
def second_retained(observed: W.World<Unit,Unit,Unit,Unit> & Bool) -> IO(Unit):
  match observed:
    case (world,removed): do IO<Unit>:
      IO.print(Bool.show(removed))
      shown(W.registration_matches(~Unit,~Unit,~Unit,~Unit,world,2,"second",[]))
def repeat_removed(observed: W.World<Unit,Unit,Unit,Unit> & Bool) -> IO(Unit):
  match observed:
    case (world,present): do IO<Unit>:
      IO.print(Bool.show(present))
      second_retained(Reg.remove(~Unit,~Unit,~Unit,~Unit,world,1,1,"first",[]))
def removed(observed: W.World<Unit,Unit,Unit,Unit> & Bool) -> IO(Unit):
  match observed:
    case (world,accepted): do IO<Unit>:
      IO.print(Bool.show(accepted))
      repeat_removed(W.registration_matches(~Unit,~Unit,~Unit,~Unit,world,1,"first",[]))
def first_retained(observed: W.World<Unit,Unit,Unit,Unit> & Bool) -> IO(Unit):
  match observed:
    case (world,present): do IO<Unit>:
      IO.print(Bool.show(present))
      removed(Reg.remove(~Unit,~Unit,~Unit,~Unit,world,1,1,"first",[]))
def foreign_refused(observed: W.World<Unit,Unit,Unit,Unit> & Bool) -> IO(Unit):
  match observed:
    case (world,accepted): do IO<Unit>:
      IO.print(Bool.show(accepted))
      first_retained(W.registration_matches(~Unit,~Unit,~Unit,~Unit,world,1,"first",[]))
def registered_second(observed: W.World<Unit,Unit,Unit,Unit> & W.Registration) -> IO(Unit):
  match observed:
    case (world,W.Registered{_}): foreign_refused(Reg.remove(~Unit,~Unit,~Unit,~Unit,world,2,1,"first",[]))
    case (_,W.RegistrationRejected{_}): IO.print("second rejected")
def registered_first(observed: W.World<Unit,Unit,Unit,Unit> & W.Registration) -> IO(Unit):
  match observed:
    case (world,W.Registered{_}): registered_second(W.register(~Unit,~Unit,~Unit,~Unit,world,"second",[]))
    case (_,W.RegistrationRejected{_}): IO.print("first rejected")
def created(result: W.Creation<Unit,Unit,Unit,Unit>) -> IO(Unit):
  match result:
    case W.Created{_,world}: registered_first(W.register(~Unit,~Unit,~Unit,~Unit,world,"first",[]))
    case W.CreateRejected{_,_}: IO.print("create rejected")
def main() -> IO(Unit):
  created(W.create(~Unit,~Unit,~Unit,~Unit,~empty,W.factory(),Unit{}))
