import Base
import provider.bend as P
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St

def misuse(reader: St.Reader<P.SchemaA,P.FlowToken>) -> St.Reader<P.SchemaA,P.FlowToken> & St.Reader<P.SchemaA,P.FlowToken>:
  (reader,reader)
