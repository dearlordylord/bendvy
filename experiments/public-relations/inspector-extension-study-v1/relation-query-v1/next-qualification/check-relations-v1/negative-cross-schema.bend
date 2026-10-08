import Base
import ../../query.bend as Query
import ../../fixture-schema.bend as D
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/inspector-query.bend as Errors

def refused(~H:Type,~cap:Query.ReadQuery<H,D.Workshop,Unit>,owner:H,target:W.Handle<D.Garden>) -> H & Result<&2,&2,Errors.LookupError,Query.Row<D.Workshop,Unit>>:
  Query.get(~H,~D.Workshop,~Unit,~cap,owner,target)
def main() -> Nat:
  0n
