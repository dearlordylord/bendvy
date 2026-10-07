import Base
import fixture.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sy
import ../../src/ecs/event-runtime.bend as Ev

def final_snapshot(joined: Ev.Runtime<F.Schema,Unit,Unit,U32> & Ev.Snapshot<U32>,+prefix: List<&2,String>) -> List<&2,String>:
  match joined:
    case (_,Ev.Snapshot{_,retained,readers,_,_}): List.append(&2,String,prefix,["{\"label\":\"cleanup\",\"retained\":" ++ F.numbers(retained) ++ ",\"readerCount\":" ++ Nat.show(Ev.count(~Ev.ReaderStatus,readers)) ++ "}"])

def cleanup_result(result: Ev.RunResult<F.Schema,Unit,Unit,U32,F.ReadRequest,F.Error,F.Observation,F.read_runner>,+prefix: List<&2,String>) -> List<&2,String>:
  match result:
    case Ev.Ran{runtime,_,_,Ev.Succeeded{value}}: final_snapshot(Ev.inspect(~F.Schema,~Unit,~Unit,~U32,Ev.frame(~F.Schema,~Unit,~Unit,~U32,Ev.frame(~F.Schema,~Unit,~Unit,~U32,runtime))),List.append(&2,String,prefix,["{\"label\":\"remaining-read\",\"read\":" ++ F.observation(value) ++ "} "]))
    case _: ["{\"failure\":\"remaining-read\"}"]

def held_snapshot(joined: Ev.Runtime<F.Schema,Unit,Unit,U32> & Ev.Snapshot<U32>,slow: Ev.Reader<F.Schema>,slowReg: Sy.Registry<F.Schema,Unit,Unit,U32,Ev.Input<U32,F.ReadRequest>,F.Error,F.Observation,F.read_runner>) -> List<&2,String>:
  match joined:
    case (runtime,Ev.Snapshot{_,retained,readers,_,_}): cleanup_result(Ev.run(~F.Schema,~Unit,~Unit,~U32,~F.ReadRequest,~F.Error,~F.Observation,~F.read_runner,runtime,slow,slowReg,F.ReadRequest{"slow",False{}}),["{\"label\":\"after-disposal-and-frames\",\"retained\":" ++ F.numbers(retained) ++ ",\"readerCount\":" ++ Nat.show(Ev.count(~Ev.ReaderStatus,readers)) ++ "}"])

def disposed(result: Ev.Disposal<F.Schema,Unit,Unit,U32,F.ReadRequest,F.Error,F.Observation,F.read_runner>,slow: Ev.Reader<F.Schema>,slowReg: Sy.Registry<F.Schema,Unit,Unit,U32,Ev.Input<U32,F.ReadRequest>,F.Error,F.Observation,F.read_runner>) -> List<&2,String>:
  match result:
    case Ev.Disposed{runtime}: held_snapshot(Ev.inspect(~F.Schema,~Unit,~Unit,~U32,Ev.frame(~F.Schema,~Unit,~Unit,~U32,Ev.frame(~F.Schema,~Unit,~Unit,~U32,runtime))),slow,slowReg)
    case _: ["{\"failure\":\"dispose\"}"]

def disposal_start(host: F.Host) -> List<&2,String>:
  match host:
    case F.Host{runtime,fast,fastReg,slow,slowReg,_,_,_}: disposed(Ev.dispose(~F.Schema,~Unit,~Unit,~U32,~F.ReadRequest,~F.Error,~F.Observation,~F.read_runner,runtime,fast,fastReg),slow,slowReg)

def probe(host: F.Host,+count: U32) -> List<&2,String>:
  disposal_start(F.publish(F.begin(F.read(F.read(F.begin(host),True{},False{}),False{},False{})),F.PublishRequest{10,1,Some{11},False{}}))

def execute(count: Maybe<&2,U32>) -> IO(Unit):
  match count:
    case None{}: IO.die(Unit,2,"invalid count")
    case Some{count}: IO.print("{\"format\":1,\"checkpoints\":" ++ F.array(F.setup(~probe,count,W.create(~F.Schema,~Unit,~Unit,~U32,~F.empty,W.factory(),Unit{}))) ++ "}")
def args(args: List<String>) -> IO(Unit):
  match args:
    case _ <> count <> _: execute(U32.read(count))
    case _: IO.die(Unit,2,"count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
