import Base
import ../../mutant-caller.bend as Caller
import mutant-observe.bend as Observe

# Fixture teardown after printing, not a public function-owner disposal policy.
def finished(~Owner:Type,owner:Owner,unit:Unit) -> IO(Unit):
  IO.pure(Unit,Unit{})
def emitted(~Owner:Type,observed:Owner & String) -> IO(Unit):
  match observed:
    case (owner,text):IO.bind(Unit,Unit,IO.print(text),finished(~Owner,owner))
def main() -> IO(Unit):
  emitted(~(Caller.Delivery<Caller.A> & Caller.Delivery<Caller.Other>),Observe.run())
