import Base
import ./output-authority-positive.bend as P
import ./schema.bend as S
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/world.bend as W

def cross(cap:P.Caps(P.Output),scope:P.Output,output:P.Output,foreign:W.Handle<S.SchemaB>) -> P.Output & (P.Output & Q.Report<String>):
  Q.general_traverse(~S.SchemaA,~P.Output,~S.Position,~U32,~P.Output,~String,cap,Q.Parallel{},scope,output,Q.ExplicitHandles{[foreign]})
