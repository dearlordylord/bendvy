import Base
import machine.bend as M
import provider.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as Tx

def gameplay(family: M.Family<P.SchemaA,P.FlowToken,P.Flow,W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,(world => P.flow_take(~P.SchemaA,world)),(world => slot => P.flow_put(~P.SchemaA,world,slot))>,tx: Tx.Tx<W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>,Unit>) -> Tx.Tx<W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>,Unit>:
  M.next_declared(~P.SchemaB,~P.FlowToken,~P.Flow,~W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>,~Unit,~(world => P.flow_take(~P.SchemaB,world)),~(world => slot => P.flow_put(~P.SchemaB,world,slot)),family,tx,M.Set{P.Play{},False{}})
