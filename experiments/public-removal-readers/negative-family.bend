import Base
import ./schema.bend as S
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/world.bend as W

def change_family(reader: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>) -> Rm.Reader<S.Schema,S.Notice,S.AToken,S.selected_a>:
  reader
