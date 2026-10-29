import Base
import ./output-authority-positive.bend as P
import ./schema.bend as S
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/world.bend as W

def duplicate(-H:Type,cap:Q.GeneralOutputWriter<S.SchemaA,H,S.Position,U32,P.Output,String>,scope:H,output:P.Output,handle:W.Handle<S.SchemaA>) -> H & (H & (P.Output & Q.Report<String>)):
  (scope,P.invoke(H,cap,scope,output,handle))
