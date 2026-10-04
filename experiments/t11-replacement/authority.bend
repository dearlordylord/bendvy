import Base
import ./runtime.bend as R

type Motion is Data:
  Position{}
type Health is Data:
  HitPoints{}
def got(slot: U32, tagged: Bool, result: Array<U32> & U32) -> R.Cell & U32:
  match result:
    case (array,+value): (R.Cell{slot,array,tagged},value)
def get(cell: R.Cell, token: Motion) -> R.Cell & U32:
  match cell:
    case R.Cell{slot,array,tagged}: got(slot,tagged,array[0])
def set(cell: R.Cell, token: Motion, value: U32) -> R.Cell:
  match cell:
    case R.Cell{slot,array,tagged}: R.Cell{slot,array[0] <- value,tagged}
def readonly(~callback: @-P: Type -> (P -> Motion -> P & U32) -> P -> P & U32, cell: R.Cell) -> R.Cell & U32:
  callback(R.Cell,get,cell)
def writable(~callback: @-P: Type -> (P -> Motion -> P & U32) -> (P -> Motion -> U32 -> P) -> P -> P & U32, cell: R.Cell) -> R.Cell & U32:
  callback(R.Cell,get,set,cell)
