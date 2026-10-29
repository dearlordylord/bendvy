import Base
import ../../src/ecs/dependency-composer-program.bend as Compose
import ../../src/ecs/dependency-plan.bend as Plan

def scope() -> Compose.Scope:
  Compose.Scope{[1,2,3,4],[Compose.Scope{[1,2],[]},Compose.Scope{[3,4],[]}]}
def observation(result:Compose.Nesting) -> String:
  match result:
    case Compose.Nesting{_,None{}}:"accepted"
    case Compose.Nesting{_,Some{Compose.UnknownScope{_}}}:"unknown-scope"
    case Compose.Nesting{_,Some{Compose.InvalidEdges{_,Plan.UnknownDependency{id}}}}:"outside-scope:" ++ U32.show(id)
    case _:"unexpected"
def main() -> IO(Unit):
  IO.print(observation(Compose.nested([Compose.Nested{[0],[Plan.Edge{1,2}]}],scope())) ++ ";" ++ observation(Compose.nested([Compose.Nested{[0],[Plan.Edge{1,3}]}],scope())) ++ ";" ++ observation(Compose.nested([Compose.Nested{[],[Plan.Edge{2,3}]}],scope())) ++ ";" ++ observation(Compose.nested([Compose.Nested{[2],[]}],scope())))
