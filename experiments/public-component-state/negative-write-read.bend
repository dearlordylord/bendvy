import Base
import state.bend as V
import schema.bend as S
import query.bend as Q
import gameplay.bend as G
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
import ../../src/ecs/compose.bend as Compose
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/world.bend as W

def main(frame: Q.Frame(~S.SchemaA)) -> Q.Frame(~S.SchemaA):
  Cap.set(~Q.Frame(~S.SchemaA),~V.Phase,~V.Phase,~Q.read_phase(~S.SchemaA),frame,V.Active{})
