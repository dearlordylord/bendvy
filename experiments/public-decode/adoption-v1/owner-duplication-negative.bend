import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input

def duplicate(owner:Input.Owner) -> Input.Owner & Input.Owner: (owner,owner)
