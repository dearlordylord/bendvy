import Base
import ../caller.bend as D
import ../adapter.bend as G
import ../ports.bend as Ports
import ../current-core/ecs/world.bend as W
import ../current-core/ecs/machine-stream.bend as St

def denied(ports: Ports.Two<D.SchemaB,D.AlphaKey,D.BetaKey>) -> Ports.Two<D.SchemaA,D.AlphaKey,D.BetaKey> & Bool:
  Ports.validate_two(~D.SchemaA,~D.AlphaKey,~D.BetaKey,ports,1,1)

def main() -> Unit:
  Unit{}
