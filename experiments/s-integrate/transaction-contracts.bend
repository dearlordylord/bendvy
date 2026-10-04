import Base
import ./types.bend as T

# Signature canary only. No concrete Tx, world, journal or rollback implementation.
type ProbeAccess<-O: Data> is Data:
  ProbeFound{value: O}
  ProbeMismatch{}
  ProbeMissing{}

def main_join(-W: Type,-H: Data,-Main: Type,-O: Data,
  hook: W -> H -> (Main -> Main & O) -> W & ProbeAccess<O>,
  transform: Main -> Main & O, world: W, handle: H) -> W & ProbeAccess<O>:
  hook(world,handle,transform)

def ledger_join(-W: Type,-Ledger: Type,-O: Data,
  hook: W -> (Ledger -> Ledger & O) -> W & Maybe<&2,O>,
  transform: Ledger -> Ledger & O, world: W) -> W & Maybe<&2,O>:
  hook(world,transform)

# Client receives two fresh setters, no inverse record or restore operation.
def invoke(~client: @-Tx: Type -> @-Capture: Type ->
  (Tx -> T.PositionToken -> Tx & T.PositionView) ->
  (Tx -> T.PositionToken -> U32 -> Tx) ->
  (Tx -> T.PositionToken -> Tx & T.PositionView) ->
  (Tx -> T.PositionToken -> U32 -> Tx) ->
  (Tx -> T.PositionToken -> Tx & T.PositionView) ->
  Tx -> Capture -> T.Invocation<Tx,Capture>,
  -Tx: Type,-Capture: Type,
  before: Tx -> T.PositionToken -> Tx & T.PositionView,
  first: Tx -> T.PositionToken -> U32 -> Tx,
  between: Tx -> T.PositionToken -> Tx & T.PositionView,
  second: Tx -> T.PositionToken -> U32 -> Tx,
  after: Tx -> T.PositionToken -> Tx & T.PositionView,
  transaction: Tx,capture: Capture) -> T.Invocation<Tx,Capture>:
  client(Tx,Capture,before,first,between,second,after,transaction,capture)
