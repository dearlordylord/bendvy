import Base
import ./types.bend as T

# Read-only rank-2 client. It cannot name a concrete provider or setter.
def motion_read(~client: @-P: Type -> (P -> T.PositionToken -> P & T.PositionView) -> P -> P & T.PositionView,
  -P: Type, read: P -> T.PositionToken -> P & T.PositionView, owner: P) -> P & T.PositionView:
  client(P,read,owner)
def health_read(~client: @-P: Type -> (P -> T.VitalsToken -> P & T.VitalsView) -> P -> P & T.VitalsView,
  -P: Type, read: P -> T.VitalsToken -> P & T.VitalsView, owner: P) -> P & T.VitalsView:
  client(P,read,owner)

# Fresh affine operations per access. Setters journal internally in opaque Tx.
def two_write(~client: @-Tx: Type -> @-Capture: Type ->
  (Tx -> T.PositionToken -> Tx & T.PositionView) ->
  (Tx -> T.PositionToken -> U32 -> Tx) ->
  (Tx -> T.PositionToken -> Tx & T.PositionView) ->
  (Tx -> T.PositionToken -> U32 -> Tx) ->
  (Tx -> T.PositionToken -> Tx & T.PositionView) ->
  Tx -> Capture -> T.Invocation<Tx,Capture>,
  -Tx: Type, -Capture: Type,
  before: Tx -> T.PositionToken -> Tx & T.PositionView,
  first: Tx -> T.PositionToken -> U32 -> Tx,
  between: Tx -> T.PositionToken -> Tx & T.PositionView,
  second: Tx -> T.PositionToken -> U32 -> Tx,
  after: Tx -> T.PositionToken -> Tx & T.PositionView,
  owner: Tx, capture: Capture) -> T.Invocation<Tx,Capture>:
  client(Tx,Capture,before,first,between,second,after,owner,capture)

def retain_rejected(-W: Type, -P: Type, world: W, payload: P) -> T.CommandResult<W,P>:
  T.CommandMissing{world,payload}

def return_position(position: T.Position) -> T.Position:
  position
def return_vitals(vitals: T.Vitals) -> T.Vitals:
  vitals

def declared_motion(-P: Type, read: P -> T.PositionToken -> P & T.PositionView, owner: P) -> P & T.PositionView:
  read(owner,T.PositionToken{})
def returned_owner(-P: Type, owner: P) -> P:
  owner
def once_closure(f: Unit -> U32) -> U32:
  f(Unit{})
type SnapshotControl is Data:
  SnapshotControl{view: T.PositionView}

# Negative fixtures are extracted into temporary sibling directories by README.
# NEGATIVE double_owner / consumed more than once
#|import Base
#|def bad(-P: Type,p:P) -> P & P:
#|  (p,p)
# END
# NEGATIVE wrong_nominal / expected : T.PositionToken
#|import Base
#|import ../types.bend as T
#|def bad(-P:Type,read:P -> T.PositionToken -> P & T.PositionView,p:P) -> P & T.PositionView:
#|  read(p,T.VitalsToken{})
# END
# NEGATIVE fabricated_provider / expected : P
#|import Base
#|import ../types.bend as T
#|def bad(-P:Type) -> P:
#|  T.Position{[0 : U32^4n],7}
# END
# NEGATIVE payload_as_data / expected : Data
#|import Base
#|import ../types.bend as T
#|type Bad is Data:
#|  Bad{payload:T.Position}
# END
# NEGATIVE double_closure / consumed more than once
#|import Base
#|def bad(f:Unit -> U32) -> U32 & U32:
#|  (f(Unit{}),f(Unit{}))
# END
# NEGATIVE undeclared_set / observed : setter
#|import Base
#|import ../types.bend as T
#|def bad(-P:Type,read:P -> T.PositionToken -> P & T.PositionView,p:P) -> P:
#|  setter(p,T.PositionToken{},1)
# END
