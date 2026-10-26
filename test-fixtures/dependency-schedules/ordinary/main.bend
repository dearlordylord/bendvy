import Base
import ./schema.bend as Schema
import ./setup.bend as Setup
import ./observe.bend as Observe
import ./bodies.bend as Body
import ../../../src/ecs/dependency-application.bend as Schedule

def run_again(~S:Data,app:Setup.Application(~S)) -> Setup.Application(~S) & Schedule.Report<String,U32>:
  Schedule.run(~Schema.World(~S),~Setup.Owners(~S),~Setup.Guards(~S),~Schema.Handler,~String,~U32,~Setup.OwnersDispatch(~S),~Setup.GuardsDispatch(~S),~Body.handle,app)
def third(~S:Data,a:String,b:String,result:Setup.Application(~S) & Schedule.Report<String,U32>) -> String:
  match result:
    case (app,report):a ++ "|" ++ b ++ "|" ++ Observe.report(report) ++ "|" ++ Observe.application(~S,app)
def second(~S:Data,a:String,result:Setup.Application(~S) & Schedule.Report<String,U32>) -> String:
  match result:
    case (app,report):third(~S,a,Observe.report(report),run_again(~S,app))
def first(~S:Data,result:Setup.Application(~S) & Schedule.Report<String,U32>) -> String:
  match result:
    case (app,report):second(~S,Observe.report(report),run_again(~S,app))
def built(~S:Data,result:Setup.Built<Setup.Application(~S)>) -> String:
  match result:
    case Setup.Failed{}:"ERROR: setup refused"
    case Setup.Built{app}:first(~S,run_again(~S,app))
def scenario(~S:Data) -> String:built(~S,Setup.build(~S))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("alpha=" ++ scenario(~Schema.Alpha))
    IO.print("beta=" ++ scenario(~Schema.Beta))
