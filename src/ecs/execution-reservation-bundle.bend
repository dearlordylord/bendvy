import Base
import ./execution-composer-layout.bend as Layout
import ./world.bend as W
import ./execution-command-removed.bend as Removed

# Closed component-layout traversal: each family appears once, with its own
# actual affine payload type. None omits that family. Resources are separate.
def Payload(layout:Layout.Layout) -> Type:Removed.Removed(layout)
type Refusal is Data:
  InvalidPending{error:W.WorldError}
  PermissionDenied{}
  DuplicateFamily{}
  PhysicalIndex{}
  MalformedColumn{key:String}
  OccupiedFamily{key:String}
type Publication<-S:Data,-C:Type,-R:Type,-E:Data,-layout:Layout.Layout> is Type:
  Materialized{world:W.World<S,C,R,E>,handle:W.Handle<S>,previous:Payload(layout)}
  RefusedPublication{world:W.World<S,C,R,E>,handle:W.Handle<S>,bundle:Payload(layout),reason:Refusal}
