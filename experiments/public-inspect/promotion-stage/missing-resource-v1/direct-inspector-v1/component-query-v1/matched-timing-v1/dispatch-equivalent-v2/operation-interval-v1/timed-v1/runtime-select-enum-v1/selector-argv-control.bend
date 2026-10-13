import Base
import bend/repetition.bend as Repetition
def rendered(value:Maybe<&2,Repetition.Count>) -> String:
  match value:
    case None{}:"INVALID"
    case Some{Repetition.One{}}:"1:20"
    case Some{Repetition.Two{}}:"2:40"
    case Some{Repetition.Four{}}:"4:80"
def invoked(values:List<String>) -> IO(Unit):IO.print(rendered(Repetition.invoked(values)))
def main() -> IO(Unit):IO.bind(List<String>,Unit,IO.args(),invoked)
