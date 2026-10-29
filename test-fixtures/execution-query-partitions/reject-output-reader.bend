import Base
import ./output-authority-positive.bend as P
import ./schema.bend as S
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/world.bend as W

def write(reader:Q.GeneralReader<S.SchemaA,P.Output,U32>,scope:P.Output,output:P.Output,handle:W.Handle<S.SchemaA>) -> P.Output & (P.Output & Q.Report<String>):
  Q.general_traverse(~S.SchemaA,~P.Output,~S.Position,~U32,~P.Output,~String,reader,Q.Parallel{},scope,output,Q.ExplicitHandles{[handle]})
