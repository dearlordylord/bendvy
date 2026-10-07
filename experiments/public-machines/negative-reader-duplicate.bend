import Base
import provider.bend as P
import stream.bend as St

def misuse(reader: St.Reader<P.SchemaA,P.FlowToken>) -> St.Reader<P.SchemaA,P.FlowToken> & St.Reader<P.SchemaA,P.FlowToken>:
  (reader,reader)
