import Base
import ./storage.bend as S
import ./cached-payload.bend as CP
import ./types.bend as T
import ./host-render.bend as R
def data(values:List<&1,U32>) -> List<&2,U32>:
  match values:
    case Nil{}: []
    case Con{head,tail}: head <> data(tail)
def observe(label:U32,retained:T.VitalsView,first:U32,result:CP.PrototypeHealthMainSlot & U32) -> IO(Unit):
  match result:
    case (CP.PrototypeHealthMainSlot{array,reserve,class,a,b,c,d,cr,cc},second): IO.print("{\"length\":" ++ U32.show(label) ++ ",\"array\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"rawReserve\":" ++ U32.show(reserve) ++ ",\"rawClass\":" ++ U32.show(class) ++ ",\"cached\":" ++ R.render_vitals(T.VitalsView{T.Four{a,b,c,d},cr,cc}) ++ ",\"retained\":" ++ R.render_vitals(retained) ++ ",\"old\":[" ++ U32.show(first) ++ "," ++ U32.show(second) ++ "]}")
def first(label:U32,retained:T.VitalsView,result:CP.PrototypeHealthMainSlot & U32) -> IO(Unit):
  match result:
    case (owner,old): observe(label,retained,old,CP.prototype_slot_vitals_swap(owner,700))
def got(label:U32,result:CP.PrototypeHealthMainSlot & T.VitalsView) -> IO(Unit):
  match result:
    case (owner,retained): first(label,retained,CP.prototype_slot_vitals_swap(owner,500))
def restored(+label:U32,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,Some{S.Row{id,Some{owner},None{},None{},added,changed}}):
      do IO<Unit>:
        IO.print("restored:" ++ U32.show(label) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
        got(label,CP.prototype_slot_vitals_get(owner))
        return Unit{}
    case _: IO.print("unexpected-restored")
def reinstalled(+label:U32,result:S.Placement<CP.PrototypeHealthMainSlot,Unit,Unit>) -> IO(Unit):
  match result:
    case S.Placed{rows}: restored(label,S.rows_extract(CP.PrototypeHealthMainSlot,Unit,Unit,rows,3))
    case _: IO.print("unexpected-reinstall")
def missing4294967295(+label:U32,owner:CP.PrototypeHealthMainSlot,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,None{}):
      do IO<Unit>:
        IO.print("missing:" ++ U32.show(label) ++ ":4294967295")
        reinstalled(label,S.rows_place(CP.PrototypeHealthMainSlot,Unit,Unit,rows,S.Row{3,Some{owner},None{},None{},31,32}))
        return Unit{}
    case _: IO.print("unexpected-present")
def missing5(+label:U32,owner:CP.PrototypeHealthMainSlot,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,None{}):
      do IO<Unit>:
        IO.print("missing:" ++ U32.show(label) ++ ":5")
        missing4294967295(label,owner,S.rows_extract(CP.PrototypeHealthMainSlot,Unit,Unit,rows,4294967295))
        return Unit{}
    case _: IO.print("unexpected-present")
def missing3(+label:U32,owner:CP.PrototypeHealthMainSlot,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,None{}):
      do IO<Unit>:
        IO.print("missing:" ++ U32.show(label) ++ ":3")
        missing5(label,owner,S.rows_extract(CP.PrototypeHealthMainSlot,Unit,Unit,rows,5))
        return Unit{}
    case _: IO.print("unexpected-present")
def missing2(+label:U32,owner:CP.PrototypeHealthMainSlot,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,None{}):
      do IO<Unit>:
        IO.print("missing:" ++ U32.show(label) ++ ":2")
        missing3(label,owner,S.rows_extract(CP.PrototypeHealthMainSlot,Unit,Unit,rows,3))
        return Unit{}
    case _: IO.print("unexpected-present")
def missing0(+label:U32,owner:CP.PrototypeHealthMainSlot,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,None{}):
      do IO<Unit>:
        IO.print("missing:" ++ U32.show(label) ++ ":0")
        missing2(label,owner,S.rows_extract(CP.PrototypeHealthMainSlot,Unit,Unit,rows,2))
        return Unit{}
    case _: IO.print("unexpected-present")
def removed(+label:U32,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,Some{S.Row{+id,Some{owner},None{},None{},added,changed}}):
      do IO<Unit>:
        IO.print("removed:" ++ U32.show(label) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
        missing0(label,owner,S.rows_extract(CP.PrototypeHealthMainSlot,Unit,Unit,rows,0))
        return Unit{}
    case _: IO.print("unexpected-remove")
def taken(+label:U32,result:S.Rows<CP.PrototypeHealthMainSlot,Unit,Unit> & Maybe<S.Row<CP.PrototypeHealthMainSlot,Unit,Unit>>) -> IO(Unit):
  match result:
    case (rows,Some{S.Row{+id,Some{owner},None{},None{},+added,+changed}}):
      do IO<Unit>:
        IO.print("live:" ++ U32.show(label) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
        removed(label,S.rows_remove(CP.PrototypeHealthMainSlot,Unit,Unit,S.rows_restore(CP.PrototypeHealthMainSlot,Unit,Unit,rows,S.Row{id,Some{owner},None{},None{},added,changed}),3))
        return Unit{}
    case _: IO.print("unexpected-live")
def placed(+label:U32,result:S.Placement<CP.PrototypeHealthMainSlot,Unit,Unit>) -> IO(Unit):
  match result:
    case S.Placed{S.Rows{main,aux,metadata,+capacity,+depth,+high}}:
      do IO<Unit>:
        IO.print("shape:" ++ U32.show(label) ++ ":" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ":" ++ U32.show(high))
        taken(label,S.rows_extract(CP.PrototypeHealthMainSlot,Unit,Unit,S.Rows{main,aux,metadata,capacity,depth,high},3))
        return Unit{}
    case _: IO.print("unexpected-place")
def run(label:U32,array:Array<U32>) -> IO(Unit):
  placed(label,S.rows_place(CP.PrototypeHealthMainSlot,Unit,Unit,S.rows_empty(CP.PrototypeHealthMainSlot,Unit,Unit),S.Row{3,Some{CP.PrototypeHealthMainSlot{array,4,5,999,200,300,400,77,88}},None{},None{},11,22}))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[100:U32^0n])
    run(2,Array.set(U32,[100:U32^1n],1,101))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))
    run(16,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^4n],1,101),2,102),3,103),4,104),5,105),6,106),7,107),8,108),9,109),10,110),11,111),12,112),13,113),14,114),15,115))
    return Unit{}
