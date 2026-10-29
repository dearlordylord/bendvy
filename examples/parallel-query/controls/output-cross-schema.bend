import Base
import ../payloads.bend as P
import ../declarations.bend as D
import ../output-declaration.bend as Decl
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/execution-query.bend as Query
type First is Data:
  First{}
type Second is Data:
  Second{}
def foreign(~O:Type,handle:W.Handle<Second>,view:U32,owner:P.Output,output:O) -> P.Output & (O & Maybe<&2,String>):
  (owner,(output,None{}))
def rejected(~O:Type) -> Query.OutputBody(~First,~D.layout(),~Decl.route(),~O,~String):foreign(~O)
