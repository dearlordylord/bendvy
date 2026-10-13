import Base
import bend/repetition.bend as Repetition
def rendered(value:Maybe<&2,Repetition.Count>) -> String:
  match value:
    case None{}:"INVALID"
    case Some{Repetition.One{}}:"1:20"
    case Some{Repetition.Two{}}:"2:40"
    case Some{Repetition.Four{}}:"4:80"
def main() -> List<String>:
  [rendered(Repetition.invoked(["program","1"])),rendered(Repetition.invoked(["program","2"])),rendered(Repetition.invoked(["program","4"])),rendered(Repetition.invoked(["program","3"])),rendered(Repetition.invoked(["program"])),rendered(Repetition.invoked(["program","1","2"])),rendered(Repetition.invoked([]))]
