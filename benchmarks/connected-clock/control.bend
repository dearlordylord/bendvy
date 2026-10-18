import Base
import clock.bend as Clock
import control-delay.bend as Delay

def report(value:Nat) -> IO(Unit):IO.print(Nat.show(value))
def slept(value:Nat) -> IO(Unit):
  do IO<Unit>:
    Delay.wait()
    elapsed:Nat <- Clock.end()
    report(elapsed)
def doubled(value:Nat) -> IO(Unit):IO.bind(Nat,Unit,Clock.begin(),report)
def other(isDouble:Bool) -> IO(Unit):
  match isDouble:
    case True{}:IO.bind(Nat,Unit,Clock.begin(),doubled)
    case False{}:IO.bind(Nat,Unit,Clock.end(),report)
def selected(sleeping:Bool,value:String) -> IO(Unit):
  match sleeping:
    case True{}:IO.bind(Nat,Unit,Clock.begin(),slept)
    case False{}:other(String.eq(value,"double-begin"))
def mode(+value:String) -> IO(Unit):selected(String.eq(value,"sleep"),value)
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> value <> _:mode(value)
    case _:IO.die(Unit,2,"clock mode required")
def main() -> IO(Unit):IO.bind(List<String>,Unit,IO.args(),args)
