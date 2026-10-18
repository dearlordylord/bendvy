import Base
import ../matched-feature-v1/main.bend as App
import ../matched-feature-v1/fixture.bend as F
import ../matched-feature-v1/observer.bend as O

def scenes(+debug:Bool) -> IO(List<&2,String>):
  IO.bind(String,List<&2,String>,App.scene(~F.Workshop,"Workshop",debug),a => IO.bind(String,List<&2,String>,App.scene(~F.Garden,"Garden",debug),b => IO.pure(List<&2,String>,[a,b])))
def loops(count:Nat,+debug:Bool) -> IO(List<&2,String>):
  match count:
    case 0n:IO.pure(List<&2,String>,[])
    case 1n+rest:IO.bind(List<&2,String>,List<&2,String>,scenes(debug),head => IO.bind(List<&2,String>,List<&2,String>,loops(rest,debug),tail => IO.pure(List<&2,String>,List.append(&2,String,head,tail))))
def run_mode(count:Nat,debug:Bool) -> IO(String):
  IO.bind(List<&2,String>,String,loops(count,debug),items => IO.pure(String,"["++O.join(items)++"]"))
def main() -> IO(Unit):
  IO.bind(String,Unit,run_mode(1n,True{}),IO.print)
