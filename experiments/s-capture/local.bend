import Base

# Proposed owner representation, not a reference Local API or contract approval.
type Local is Type:
  Local{counter: Array<U32>}
def initial() -> Local:
  Local{[0 : U32^0n]}
def incremented(result: Array<U32> & U32) -> Local & U32:
  match result:
    case (counter, old):
      +next = (old + 1 : U32)
      (Local{Array.set(U32, counter, 0, next)}, next)
def invoke(local: Local) -> Local & U32:
  match local:
    case Local{counter}: incremented(Array.get(U32, counter, 0))
def project(result: Array<U32> & U32) -> Local & U32:
  match result:
    case (counter, x): (Local{counter}, x)
def observe(local: Local) -> Local & U32:
  match local:
    case Local{counter}: project(Array.get(U32, counter, 0))
