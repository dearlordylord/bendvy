import Base
import ../refusal-control.bend as P
import ../row-cell-control.bend as M
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C

type Row is Type:
  Row{payload:P.Payload}
def project_join(result:P.Payload & P.View) -> Row & C.Access<P.View>:
  match result:
    case (owner,view): (Row{owner},C.Found{view})
def get(row:Row) -> Row & C.Access<P.View>:
  match row:
    case Row{owner}: project_join(M.mutate(owner))
def set(row:Row,incoming:P.Payload) -> Row:
  match row:
    case Row{_}: Row{incoming}
def reader() -> Cap.Read<Row,P.View>:
  Cap.Read{get}
def writer() -> Cap.Write<Row,P.Payload,P.View>:
  Cap.Write{get,set}
# Legal runtime callback application fusion; it does NOT erase cap construction.
def apply_read(~H:Type,~V:Data,cap:Cap.Read<H,V>,row:H) -> H & C.Access<V>:
  match cap:
    case Cap.Read{get}: get(row)
def apply_get(~H:Type,~A:Type,~V:Data,cap:Cap.Write<H,A,V>,row:H) -> H & C.Access<V>:
  match cap:
    case Cap.Write{get,_}: get(row)
def apply_set(~H:Type,~A:Type,~V:Data,cap:Cap.Write<H,A,V>,row:H,incoming:A) -> H:
  match cap:
    case Cap.Write{_,set}: set(row,incoming)
def static_read(~H:Type,~V:Data,~cap:Cap.Read<H,V>,row:H) -> H & C.Access<V>:
  apply_read(~H,~V,cap,row)
def static_get(~H:Type,~A:Type,~V:Data,~cap:Cap.Write<H,A,V>,row:H) -> H & C.Access<V>:
  apply_get(~H,~A,~V,cap,row)
def static_set(~H:Type,~A:Type,~V:Data,~cap:Cap.Write<H,A,V>,row:H,incoming:A) -> H:
  apply_set(~H,~A,~V,cap,row,incoming)
def raw(row:Row) -> List<&2,U32>:
  match row:
    case Row{owner}: M.incoming([],P.project(owner))
def result(points:List<&2,U32>,observed:Row & C.Access<P.View>) -> List<&2,U32>:
  match observed:
    case (row,C.Found{view}): List.append(&2,U32,points,List.append(&2,U32,M.cells(view),raw(row)))
    case (row,_): List.append(&2,U32,[999],raw(row))
def second(isstatic:Bool,observed:Row & C.Access<P.View>) -> List<&2,U32>:
  match isstatic observed:
    case False{}, (row,C.Found{view}): result(M.cells(view),Cap.write_read_field(~Row,~P.Payload,~P.View,writer())(row))
    case True{}, (row,C.Found{view}): result(M.cells(view),Cap.get(~Row,~P.Payload,~P.View,~writer(),row))
    case _, (row,_): raw(row)
def initial() -> Row:
  Row{P.Payload{ANode{ALeaf{3},ALeaf{7}}}}
def read_pair(isstatic:Bool) -> List<&2,U32>:
  match isstatic:
    case False{}: second(False{},Cap.read_field(~Row,~P.View,reader())(initial()))
    case True{}: second(True{},Cap.read(~Row,~P.View,~reader(),initial()))
def write_pair(isstatic:Bool) -> List<&2,U32>:
  match isstatic:
    case False{}: result([],Cap.write_read_field(~Row,~P.Payload,~P.View,writer())(Cap.write_field(~Row,~P.Payload,~P.View,writer())(initial(),P.Payload{ANode{ALeaf{41},ALeaf{43}}})))
    case True{}: result([],Cap.get(~Row,~P.Payload,~P.View,~writer(),Cap.set(~Row,~P.Payload,~P.View,~writer(),initial(),P.Payload{ANode{ALeaf{41},ALeaf{43}}})))
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),[read_pair(False{}),read_pair(True{}),write_pair(False{}),write_pair(True{})]))
