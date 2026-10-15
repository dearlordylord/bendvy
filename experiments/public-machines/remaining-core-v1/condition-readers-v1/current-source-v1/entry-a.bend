import Base
import ../provider.bend as P
import trace.bend as Trace

def main() -> String:
  Trace.trace(~P.SchemaA) ++ Trace.trace(~P.SchemaB)
