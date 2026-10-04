import Base
import ./types.bend as T
import ./payload.bend as P

type Local is Type:
  Local{count: Array<U32>}
type Style is Data:
  Returned{}
  Regenerated{}
def initial() -> Local:
  Local{[0 : U32^2n]}
def incremented(result: Array<U32> & U32) -> Local & U32:
  match result:
    case (array,+count): (Local{Array.set(U32,array,0,U32.add(count,1))},U32.add(count,1))
def increment(local: Local) -> Local & U32:
  match local:
    case Local{array}: incremented(Array.get(U32,array,0))
def closure(local: Local) -> Unit -> Local & U32:
  _ => increment(local)
def call(callback: Unit -> Local & U32) -> Local & U32:
  callback(Unit{})
def invoke(style: Style,local: Local) -> Local & U32:
  match style:
    case Returned{}: increment(local)
    case Regenerated{}: call(closure(local))
def observed(result: Array<U32> & T.Four) -> Local & T.Four:
  match result:
    case (array,view): (Local{array},view)
def observe(local: Local) -> Local & T.Four:
  match local:
    case Local{array}: observed(P.four(array))
