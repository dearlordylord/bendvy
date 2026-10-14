import Base
import ../../../src/ecs/ordinary-lifetime-scope.bend as Ord
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/transaction.bend as T

def returned(~H:Type,seen:H & U32) -> H & (T.Outcome<Unit> & U32):
  match seen:
    case (owner,value):(owner,(T.Success{},value))
# Same public ordinary-body signature: the owner remains abstract H, not World.
# Ops supplies scope spawn/cleanup; it supplies no raw World metadata capability.
def forbidden(~S:Data,~H:Type,~ops:Ord.Ops<H,S,Unit>,args:Unit,owner:H) -> H & (T.Outcome<Unit> & U32):
  returned(~H,W.clock(~S,~A.Store<S,Sc.Store<S,Unit>>,~Unit,~A.Notice<S,U32>,owner))
