import Base
import provider.bend as P
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St

def misuse(reader: St.Reader<P.SchemaA,P.FlowToken>,stream: St.Stream<P.Flow>) -> St.Reader<P.SchemaB,P.FlowToken> & St.Stream<P.Flow>:
  St.finish(~P.SchemaB,~P.FlowToken,~P.Flow,reader,stream,0n,True{})
