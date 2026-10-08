import Base
import ../fixture-schema.bend as D
import ../query.bend as Query

def detached(row:Query.Row<D.Workshop,U32>) -> Query.Row<D.Workshop,U32>:
  row
