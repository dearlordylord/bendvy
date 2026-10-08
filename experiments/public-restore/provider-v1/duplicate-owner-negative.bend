import Base
import controls.bend as Controls
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/standard-owned.bend as Owned

def duplicate(result:Controls.Context & Owned.Reply<D.Raw,Controls.Payload,Controls.Issues>) -> Controls.Payload & Controls.Payload:
  match result:
    case (_,Owned.SyncAccepted{owner}): (owner,owner)
    case _: (Controls.Payload{ALeaf{0}},Controls.Payload{ALeaf{0}})
