import Base
import provider.bend as P
import reader-factory.bend as Factory

def observe(owner: Factory.Instance<P.SchemaA>) -> Factory.Instance<P.SchemaA>:
  owner

def main() -> Unit:
  Unit{}
