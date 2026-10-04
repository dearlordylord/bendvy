import Base
import ./types.bend as T

# Unapproved integration law candidates, not universal proofs or bound subjects.
# Future law foreign_command: actual command(world,foreign_handle,payload) returns
# MissingEntity, unchanged complete receiver/queue and the actual rejected owner.
# Future law rollback: actual two-write/failed finish restores declared full fields,
# retains previous commits, drops staged pubs, and preserves consumed reservation.
# Future law reader_finish: actual selected instance applies success/failure/skip
# boundaries below, preserving other readers and exact oracle read/lag values.
# Future law capture: actual invocation increments its sole lexical owner on both
# outcomes; skip preserves it. Bind these to actual subjects before law approval.

# Independently evaluable observation contracts. Strings must be lossless complete
# canonical queue/world encodings, not hashes. OwnerReturn is a trace assertion;
# this Data predicate does not prove identity, affinity, or retained Type ownership.
type ForeignObservation is Data:
  ForeignObservation{status: T.CommandStatus, beforeWorld: String, afterWorld: String,
    beforeQueue: String, afterQueue: String, ownerReturned: Bool}
def foreign_observation(observation: ForeignObservation) -> Bool:
  match observation:
    case ForeignObservation{T.MissingEntity{},bw,aw,bq,aq,returned}:
      Bool.and(String.eq(bw,aw),Bool.and(String.eq(bq,aq),returned))
    case ForeignObservation{T.Queued{},_,_,_,_,_}: False{}

def state_equal(left: T.ReaderState,right: T.ReaderState) -> Bool:
  match left right:
    case T.ReaderState{a,b,c} T.ReaderState{x,y,z}:
      Bool.and(U32.is_eq(a,x),Bool.and(U32.is_eq(b,y),U32.is_eq(c,z)))
type Completion is Data:
  Completed{}
  Failed{}
  Skipped{}
def reader_observation(kind: Completion,registered: Bool,before: T.ReaderState,after: T.ReaderState,+tick: U32) -> Bool:
  match kind registered before:
    case Completed{} True{} T.ReaderState{at,_,_}: state_equal(T.ReaderState{at,tick,tick},after)
    case Failed{} _ _: state_equal(before,after)
    case Skipped{} True{} T.ReaderState{at,last,_}: state_equal(T.ReaderState{at,last,tick},after)
    case Skipped{} False{} _: state_equal(before,after)
    case Completed{} False{} _: False{}
def capture_observation(invoked: Bool,before: U32,after: U32) -> Bool:
  match invoked:
    case True{}: U32.is_eq((before + 1 : U32),after)
    case False{}: U32.is_eq(before,after)

# Falsification controls are finite inputs, never claimed integration execution.
def fixtures() -> Bool:
  Bool.and(foreign_observation(ForeignObservation{T.MissingEntity{},"full world","full world","spawn:full payload","spawn:full payload",True{}}),
    Bool.and(Bool.not(foreign_observation(ForeignObservation{T.MissingEntity{},"full world","full world","spawn:full payload","",True{}})),
      Bool.and(reader_observation(Failed{},True{},T.ReaderState{1,2,3},T.ReaderState{1,2,3},4),
        Bool.and(Bool.not(reader_observation(Failed{},True{},T.ReaderState{1,2,3},T.ReaderState{1,4,4},4)),
          Bool.and(reader_observation(Skipped{},True{},T.ReaderState{1,2,3},T.ReaderState{1,2,4},4),
            Bool.and(Bool.not(reader_observation(Skipped{},True{},T.ReaderState{1,2,3},T.ReaderState{1,4,4},4)),
              Bool.and(capture_observation(True{},2,3),Bool.not(capture_observation(True{},2,2)))))))))
def main() -> Bool:
  fixtures()
