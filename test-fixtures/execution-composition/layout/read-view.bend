import Base
import ../../../src/ecs/execution-resource-policy.bend as Policy
import ../../../src/ecs/chunk-column.bend as Col
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/change-tick.bend as Tick

import ../../../src/ecs/execution-composer-layout.bend as Layout

def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def schema() -> Layout.Layout:Layout.LayoutLeaf{Array<U32>,U32,project,"value",Policy.Ordinary{}}
def finish(view:U32,changed:Maybe<&2,Tick.Tick>,result:Array<U32> & U32) -> String:
  match changed result:
    case Some{Tick.Tick{_,tick}},(_,value):U32.show(view) ++ "," ++ U32.show(value) ++ "," ++ U32.show(tick)
    case _ _:"missing"
def stamped(view:U32,stamp:Array<L.Stamp> & L.Stamp,payload:Array<Maybe<&1,Layout.Viewed<Array<U32>,U32>>> & Maybe<&1,Layout.Viewed<Array<U32>,U32>>) -> String:
  match stamp payload:
    case (_,L.Stamp{_,changed}),(_,Some{Layout.Viewed{owner,_}}): finish(view,changed,Array.get(U32,owner,0))
    case _ _:"missing"
def observed(result:Col.Column<Unit,Layout.Viewed<Array<U32>,U32>> & Maybe<&2,U32>) -> String:
  match result:
    case (Col.Leaf{values,stamps},Some{view}): stamped(view,Array.get(L.Stamp,stamps,0),Array.swap(Maybe<&1,Layout.Viewed<Array<U32>,U32>>,values,0,None{}))
    case _:"missing"
def main() -> IO(Unit):
  IO.print(observed(Col.view(~Unit,~Layout.Viewed<Array<U32>,U32>,~U32,~Layout.read(~Array<U32>,~U32),Col.Leaf{ALeaf{Some{Layout.initialize(schema(),Layout.AtLeaf{},ALeaf{777})}},ALeaf{L.Stamp{Some{Tick.Tick{0n,1}},Some{Tick.Tick{0n,9}}}}},0)))
