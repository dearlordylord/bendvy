import Base
import ./query.bend as Q
import ./types.bend as T
def bad(cursor:Q.PrototypeIdCursor<T.MotionSchema>) -> Q.PrototypeIdCursor<T.MotionSchema> & Q.PrototypeIdCursor<T.MotionSchema>:
  (cursor,cursor)
