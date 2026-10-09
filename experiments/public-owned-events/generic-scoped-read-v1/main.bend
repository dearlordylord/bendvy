import Base
import controls.bend as C

type PayloadView is Data: PayloadView{cells:List<&2,Bool>,label:String,sentinel:List<&2,U32>}
type ObservationView is Data: ObservationView{projection:C.Projection,scratch:List<&2,Bool>,sentinel:List<&2,U32>}
type Report is Data: Report{payload:PayloadView,first:ObservationView,second:ObservationView}
def bool_cells(owner:Array<Bool>) -> List<&2,Bool>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,Bool,bool_cells(left),bool_cells(right))
def payload(owner:C.Payload) -> PayloadView:
  match owner:
    case C.Payload{cells,label,sentinel}: PayloadView{bool_cells(cells),label,C.u32_cells(sentinel)}
def observation(owner:C.Observation) -> ObservationView:
  match owner:
    case C.Observation{projection,scratch,sentinel}: ObservationView{projection,bool_cells(scratch),C.u32_cells(sentinel)}
def finish(result:C.Payload & (C.Observation & C.Observation)) -> Report:
  match result:
    case (owner,(first,second)): Report{payload(owner),observation(first),observation(second)}
def main() -> Report: finish(C.full())
