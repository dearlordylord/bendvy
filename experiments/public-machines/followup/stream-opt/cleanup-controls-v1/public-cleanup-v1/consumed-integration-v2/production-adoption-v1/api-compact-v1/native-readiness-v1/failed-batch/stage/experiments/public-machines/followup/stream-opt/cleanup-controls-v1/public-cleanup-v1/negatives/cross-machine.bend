import Base
import ../caller.bend as D
import ../adapter.bend as G
import ../ports.bend as Ports
import ../current-core/ecs/world.bend as W
import ../current-core/ecs/machine-stream.bend as St

def denied(reader: St.Reader<D.SchemaA,D.AlphaKey>) -> St.Reader<D.SchemaA,D.BetaKey>:
  reader

def main() -> Unit:
  Unit{}
