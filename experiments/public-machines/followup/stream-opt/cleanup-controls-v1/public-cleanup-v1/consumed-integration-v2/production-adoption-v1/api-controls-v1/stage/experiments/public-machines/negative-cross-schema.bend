import Base
import provider.bend as P
import reader-factory.bend as Factory

def denied(owner: Factory.Instance<P.SchemaA>) -> Factory.Instance<P.SchemaB>:
  owner

def main() -> Unit:
  Unit{}
