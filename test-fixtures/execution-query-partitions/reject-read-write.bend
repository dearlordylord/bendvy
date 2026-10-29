import Base
import ./schema.bend as S
import ../../src/ecs/execution-query-matches.bend as Q
import ../../src/ecs/execution-query-slice.bend as Slice
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/change-tick.bend as Tick

def write(cap:Q.ReadCap<S.SchemaA,S.positions()>,slot:Slice.Slot<S.SchemaA,L.Viewed<S.Position,U32>,S.positions()>) -> Q.WriteCap<S.SchemaA,S.positions()> & Slice.Edit<S.SchemaA,L.Viewed<S.Position,U32>,S.positions(),S.Position,Unit>:
  Q.cap_edit(~S.SchemaA,~S.positions(),~L.AtLeaf{},Unit,cap,slot,0,Tick.zero(),S.moved)
