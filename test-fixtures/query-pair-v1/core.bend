import Base
import ../../src/ecs/ordinary-query-declaration.bend as D

type Schema is Data:
  Schema{}
type Grant is Type:
  Grant{cells:Array<U32>}
type Owner is Type:
  Owner{cells:Array<U32>,allowLeft:Bool,allowRight:Bool}
type Returned is Type:
  Returned{left:Grant,right:Grant,owner:Owner,selected:Bool,clauses:List<&2,D.Clause<Schema>>}
type Snapshot is Data:
  Snapshot{left:List<&2,U32>,right:List<&2,U32>,owner:List<&2,U32>,allowLeft:Bool,allowRight:Bool,selected:Bool,clauses:List<&2,D.Clause<Schema>>}
def left_read(+allowLeft:Bool,allowRight:Bool,observed:Array<U32> & U32) -> Owner & Bool:
  match observed:
    case (cells,value):(Owner{Array.set(U32,cells,0,U32.add(value,1)),allowLeft,allowRight},allowLeft)
def left_select(owner:Owner) -> Owner & Bool:
  match owner:
    case Owner{cells,allowLeft,allowRight}:left_read(allowLeft,allowRight,Array.get(U32,cells,0))
def right_read(allowLeft:Bool,+allowRight:Bool,observed:Array<U32> & U32) -> Owner & Bool:
  match observed:
    case (cells,value):(Owner{Array.set(U32,cells,1,U32.add(value,10)),allowLeft,allowRight},allowRight)
def right_select(owner:Owner) -> Owner & Bool:
  match owner:
    case Owner{cells,allowLeft,allowRight}:right_read(allowLeft,allowRight,Array.get(U32,cells,1))
def left() -> D.Declaration<Schema,Owner,Grant>:
  D.Declaration{Grant{ANode{ALeaf{101},ALeaf{102}}},left_select,[D.Clause{"duplicate",D.Read{}},D.Clause{"duplicate",D.With{}}]}
def right() -> D.Declaration<Schema,Owner,Grant>:
  D.Declaration{Grant{ANode{ALeaf{201},ALeaf{202}}},right_select,[D.Clause{"tail",D.Changed{}},D.Clause{"duplicate",D.Read{}}]}
def selected(left:Grant,right:Grant,clauses:List<&2,D.Clause<Schema>>,observed:Owner & Bool) -> Returned:
  match observed:
    case (owner,selected):Returned{left,right,owner,selected,clauses}
def invoke(owner:Owner,declaration:D.Declaration<Schema,Owner,Grant & Grant>) -> Returned:
  match declaration:
    case D.Declaration{(left,right),select,clauses}:selected(left,right,clauses,select(owner))
def one(allowLeft:Bool,allowRight:Bool) -> Returned:
  invoke(Owner{ANode{ANode{ALeaf{7},ALeaf{9}},ANode{ALeaf{333},ALeaf{444}}},allowLeft,allowRight},D.pair(~Schema,~Owner,~Grant,~Grant,~left(),~right()))
def cells(value:Array<U32>) -> List<&2,U32>:
  match value:
    case ALeaf{value}:[value]
    case ANode{left,right}:List.append(&2,U32,cells(left),cells(right))
def snapshot(value:Returned) -> Snapshot:
  match value:
    case Returned{Grant{left},Grant{right},Owner{owner,allowLeft,allowRight},selected,clauses}:Snapshot{cells(left),cells(right),cells(owner),allowLeft,allowRight,selected,clauses}
def run() -> List<&2,Snapshot>:
  [snapshot(one(False{},True{})),snapshot(one(True{},False{})),snapshot(one(True{},True{}))]
