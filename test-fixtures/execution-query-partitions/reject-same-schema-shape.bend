import Base
import ./schema.bend as S
import ../../src/ecs/execution-query-schema.bend as Q

def cross(book:Q.Book<S.SchemaA,S.layout_a()>) -> Q.Book<S.SchemaA,S.layout_b()>:
  book
