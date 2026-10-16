import Base
import ./fixture.bend as F
import ./scenario.bend as Scenario
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WI

def empty(_:Unit) -> Unit:Unit{}
def created(~S:Data,bypass:Bool,value:WI.Creation<S,Unit,F.Resources(~S),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run(~S,F.register(~S,bypass,world)))
    case _:IO.die(String,1,"checked predicate world creation failed")
def one(~S:Data,input:Maybe<&2,U32>,bypass:Bool) -> IO(String):
  IO.bind(WI.Creation<S,Unit,F.Resources(~S),Unit>,String,WI.create(~S,~Unit,~F.Resources(~S),~Unit,~empty,F.resources(~S,input)),created(~S,bypass))
def cases_last(before:String,value:String) -> String:before ++ "missing-reached\n" ++ value
def cases_positive(~S:Data,before:String,value:String) -> IO(String):IO.bind(String,String,one(~S,None{},True{}),last => IO.pure(String,cases_last(before ++ "positive\n" ++ value,last)))
def cases_zero(~S:Data,before:String,value:String) -> IO(String):IO.bind(String,String,one(~S,Some{5},False{}),cases_positive(~S,before ++ "zero\n" ++ value))
def cases_missing(~S:Data,value:String) -> IO(String):IO.bind(String,String,one(~S,Some{0},False{}),cases_zero(~S,"missing-skipped\n" ++ value))
def run(~S:Data) -> IO(String):IO.bind(String,String,one(~S,None{},False{}),cases_missing(~S))
def printed(a:String,b:String) -> IO(Unit):IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):IO.bind(String,Unit,run(~F.Garden),b => printed(a,b))
def main() -> IO(Unit):IO.bind(String,Unit,run(~F.Workshop),workshop)
