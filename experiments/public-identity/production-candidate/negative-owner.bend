import Base
import ./world-io.bend as H
import ../../public-schedule-readers/schema.bend as S

def duplicate(created:H.Creation<S.Schema,Unit,Array<U32>,U32>) -> H.Creation<S.Schema,Unit,Array<U32>,U32> & H.Creation<S.Schema,Unit,Array<U32>,U32>:
  (created,created)
