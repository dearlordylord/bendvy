import Base
import ./schema.bend as S
import ../../src/ecs/removals.bend as Rm

def duplicate(reader: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>) -> Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected> & Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>:
  (reader,reader)
