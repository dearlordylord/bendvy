import Base
import trace-value.bend as J
import trace-force.bend as Force
import trace-boundary.bend as Boundary
import trace-application.bend as App
# Foreign completion is separately qualified; all ECS/DTO/walk definitions remain safe.
def delivered(result:Force.Summary,trace:J.Value) -> IO(Unit):
  match result:
    case Force.Summary{nodes,characters,sum}:IO.bind(Unit,Unit,Boundary.complete(nodes,characters,sum),_ => IO.print(J.encode(trace)))
def materialized(+trace:J.Value) -> IO(Unit):
  delivered(Force.force(trace),trace)
def main() -> IO(Unit):
  IO.bind(Unit,Unit,Boundary.begin(),_ => IO.bind(Unit,Unit,Boundary.complete(0,0,0),_ => materialized(App.trace())))
