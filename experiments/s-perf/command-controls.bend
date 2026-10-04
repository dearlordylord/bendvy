import Base
import ./candidate/storage.bend as S
import ./candidate/commands.bend as C

type Alpha is Data:
  Alpha{}
type Beta is Data:
  Beta{}
type Cell is Type:
  Cell{first:U32,second:U32}
def maybe_cell(value:Maybe<Cell>) -> String:
  match value:
    case None{}: "none"
    case Some{Cell{a,b}}: U32.show(a) ++ "," ++ U32.show(b)
def maybe_flag(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}: "none"
    case Some{v}: U32.show(v)
def row_text(value:Maybe<S.Row<Cell,Cell,U32>>) -> String:
  match value:
    case None{}: "missing"
    case Some{S.Row{id,m,a,f,added,changed}}: U32.show(id) ++ ":" ++ maybe_cell(m) ++ ":" ++ maybe_cell(a) ++ ":" ++ maybe_flag(f) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def change_text(-Schema:Data,value:S.Change<Schema>) -> String:
  match value:
    case S.MainAdded{S.Handle{ns,id}}: "add" ++ U32.show(ns) ++ "," ++ U32.show(id)
    case S.MainChanged{S.Handle{ns,id}}: "change" ++ U32.show(ns) ++ "," ++ U32.show(id)
    case S.MainRemoved{S.Handle{ns,id}}: "remove" ++ U32.show(ns) ++ "," ++ U32.show(id)
    case S.Despawned{S.Handle{ns,id}}: "despawn" ++ U32.show(ns) ++ "," ++ U32.show(id)
def changes_text(-Schema:Data,values:List<&2,S.Change<Schema>>) -> String:
  match values:
    case Nil{}: ""
    case Con{v,tail}: change_text(Schema,v) ++ ";" ++ changes_text(Schema,tail)
def snapshot4(text:String,result:S.Rows<Cell,Cell,U32> & Maybe<S.Row<Cell,Cell,U32>>) -> String:
  match result:
    case (_,row): text ++ "|" ++ row_text(row)
def snapshot3(text:String,result:S.Rows<Cell,Cell,U32> & Maybe<S.Row<Cell,Cell,U32>>) -> String:
  match result:
    case (rows,row): snapshot4(text ++ "|" ++ row_text(row),S.rows_extract(Cell,Cell,U32,rows,65537))
def snapshot2(text:String,result:S.Rows<Cell,Cell,U32> & Maybe<S.Row<Cell,Cell,U32>>) -> String:
  match result:
    case (rows,row): snapshot3(text ++ "|" ++ row_text(row),S.rows_extract(Cell,Cell,U32,rows,5))
def snapshot1(rows:S.Rows<Cell,Cell,U32>,text:String) -> String:
  snapshot2(text,S.rows_extract(Cell,Cell,U32,rows,3))
def snapshot0(text:String,result:S.Rows<Cell,Cell,U32> & Maybe<S.Row<Cell,Cell,U32>>) -> String:
  match result:
    case (rows,row): snapshot1(rows,text ++ "|" ++ row_text(row))
def applied_text(-Schema:Data,result:C.CheckedApply<Schema,Cell,Cell,U32,Cell,U32>) -> String:
  match result:
    case C.Applied{S.World{ns,next,rows,pending,ledger,mode},changes}: snapshot0("ok" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(mode) ++ ":" ++ maybe_cell(ledger) ++ ":" ++ changes_text(Schema,changes),S.rows_extract(Cell,Cell,U32,rows,1))
    case C.CapacityRejected{_}: "unexpected-capacity-rejection"
    case C.InvariantFault{_,_,_}: "unexpected-invariant-fault"
def commands() -> List<S.Command<Cell,Cell,U32>>:
  [S.Spawn{1,S.Bundle{Some{Cell{11,12}},Some{Cell{13,14}},Some{15}}},
   S.Spawn{3,S.Bundle{Some{Cell{31,32}},Some{Cell{33,34}},Some{35}}},
   S.Spawn{5,S.Bundle{None{},Some{Cell{53,54}},None{}}},
   S.RemoveMain{3},S.InsertMain{3,Cell{301,302}},S.InsertMain{3,Cell{303,304}},S.InsertFlag{3,305},
   S.Despawn{1},S.InsertMain{1,Cell{101,102}},S.RemoveFlag{3},
   S.Spawn{65537,S.Bundle{Some{Cell{651,652}},Some{Cell{653,654}},Some{655}}}]
def success(-Schema:Data) -> String:
  applied_text(Schema,C.apply_checked(Schema,Cell,Cell,U32,Cell,U32,S.World{7,65538,S.rows_empty(Cell,Cell,U32),List.reverse(&1,S.Command<Cell,Cell,U32>,commands()),Some{Cell{71,72}},9},42))
def command_text(command:S.Command<Cell,Cell,U32>) -> String:
  match command:
    case S.Spawn{id,S.Bundle{m,a,f}}: "spawn" ++ U32.show(id) ++ ":" ++ maybe_cell(m) ++ ":" ++ maybe_cell(a) ++ ":" ++ maybe_flag(f)
    case S.InsertMain{id,m}: "main" ++ U32.show(id) ++ ":" ++ maybe_cell(Some{m})
    case S.InsertFlag{id,f}: "flag" ++ U32.show(id) ++ ":" ++ U32.show(f)
    case S.RemoveMain{id}: "remove" ++ U32.show(id)
    case S.RemoveFlag{id}: "unflag" ++ U32.show(id)
    case S.Despawn{id}: "despawn" ++ U32.show(id)
def pending_text(commands:List<S.Command<Cell,Cell,U32>>) -> String:
  match commands:
    case Nil{}: ""
    case Con{c,tail}: command_text(c) ++ ";" ++ pending_text(tail)
def rejected_high(text:String,result:S.Rows<Cell,Cell,U32> & U32) -> String:
  match result:
    case (rows,h): snapshot0(text ++ ":high" ++ U32.show(h),S.rows_extract(Cell,Cell,U32,rows,1))
def rejected_text(-Schema:Data,result:C.CheckedApply<Schema,Cell,Cell,U32,Cell,U32>) -> String:
  match result:
    case C.CapacityRejected{S.World{ns,next,rows,pending,ledger,mode}}: rejected_high("reject" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(mode) ++ ":" ++ maybe_cell(ledger) ++ ":" ++ pending_text(pending),S.rows_high_water(Cell,Cell,U32,rows))
    case C.Applied{_,_}: "unexpected-applied-prefix"
    case C.InvariantFault{_,_,_}: "unexpected-invariant-fault"
def rejection(-Schema:Data,+id:U32) -> String:
  rejected_text(Schema,C.apply_checked(Schema,Cell,Cell,U32,Cell,U32,S.World{7,131074,S.rows_empty(Cell,Cell,U32),[S.Spawn{id,S.Bundle{Some{Cell{91,92}},Some{Cell{93,94}},Some{95}}},S.InsertMain{1,Cell{81,82}},S.Spawn{1,S.Bundle{Some{Cell{11,12}},Some{Cell{13,14}},Some{15}}}],Some{Cell{71,72}},9},42))
def fault_text(-Schema:Data,result:C.CheckedApply<Schema,Cell,Cell,U32,Cell,U32>) -> String:
  match result:
    case C.InvariantFault{S.World{ns,next,rows,pending,ledger,mode},row,changes}: snapshot0("fault" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(mode) ++ ":" ++ maybe_cell(ledger) ++ ":" ++ row_text(Some{row}) ++ ":" ++ pending_text(pending) ++ ":" ++ changes_text(Schema,changes),S.rows_extract(Cell,Cell,U32,rows,1))
    case C.Applied{_,_}: "unexpected-duplicate-applied"
    case C.CapacityRejected{_}: "unexpected-capacity-rejection"
def invariant_fault(-Schema:Data) -> String:
  fault_text(Schema,C.apply_checked(Schema,Cell,Cell,U32,Cell,U32,S.World{7,3,S.rows_empty(Cell,Cell,U32),[S.InsertMain{1,Cell{81,82}},S.Spawn{1,S.Bundle{Some{Cell{91,92}},Some{Cell{93,94}},Some{95}}},S.Spawn{1,S.Bundle{Some{Cell{11,12}},Some{Cell{13,14}},Some{15}}}],Some{Cell{71,72}},9},42))
def existing_rejected(-Schema:Data,result:S.Placement<Cell,Cell,U32>) -> String:
  match result:
    case S.Placed{rows}: rejected_text(Schema,C.apply_checked(Schema,Cell,Cell,U32,Cell,U32,S.World{7,131074,rows,[S.Spawn{131073,S.Bundle{Some{Cell{91,92}},Some{Cell{93,94}},Some{95}}},S.InsertMain{1,Cell{81,82}}],Some{Cell{71,72}},9},42))
    case S.Rejected{_,_}: "unexpected-initial-place-rejection"
def existing(-Schema:Data) -> String:
  existing_rejected(Schema,S.rows_place(Cell,Cell,U32,S.rows_empty(Cell,Cell,U32),S.Row{1,Some{Cell{21,22}},Some{Cell{23,24}},Some{25},26,27}))
def existing_commands(remove:Bool) -> List<S.Command<Cell,Cell,U32>>:
  match remove:
    case False{}: [S.InsertMain{1,Cell{81,82}}]
    case True{}: [S.RemoveMain{1}]
def existing_apply(-Schema:Data,remove:Bool,result:S.Placement<Cell,Cell,U32>) -> String:
  match result:
    case S.Placed{rows}: applied_text(Schema,C.apply_checked(Schema,Cell,Cell,U32,Cell,U32,S.World{7,3,rows,existing_commands(remove),Some{Cell{71,72}},9},42))
    case S.Rejected{_,_}: "unexpected-initial-place-rejection"
def existing_edit(-Schema:Data,remove:Bool) -> String:
  existing_apply(Schema,remove,S.rows_place(Cell,Cell,U32,S.rows_empty(Cell,Cell,U32),S.Row{1,Some{Cell{21,22}},Some{Cell{23,24}},Some{25},26,27}))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(success(Alpha))
    IO.print(success(Beta))
    IO.print(rejection(Alpha,131073))
    IO.print(rejection(Beta,0))
    IO.print(rejection(Alpha,4294967295))
    IO.print(invariant_fault(Alpha))
    IO.print(invariant_fault(Beta))
    IO.print(existing(Alpha))
    IO.print(existing(Beta))
    IO.print(existing_edit(Alpha,False{}))
    IO.print(existing_edit(Beta,True{}))
    return Unit{}
