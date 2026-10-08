import Base
import ../fixture-schema.bend as D
import ../query.bend as Query

def affine_detached(row:Query.Row<D.Workshop,D.Stock>) -> Query.Row<D.Workshop,D.Stock>:
  row
