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

# Next independently runnable contracts; still no actual subject bindings.
def four_equal(left: T.Four,right: T.Four) -> Bool:
  match left right:
    case T.Four{a,b,c,d} T.Four{w,x,y,z}:
      Bool.and(U32.is_eq(a,w),Bool.and(U32.is_eq(b,x),Bool.and(U32.is_eq(c,y),U32.is_eq(d,z))))
def main_equal(left: T.MainView,right: T.MainView) -> Bool:
  match left right:
    case T.MotionMain{T.PositionView{a,f}} T.MotionMain{T.PositionView{b,g}}:
      Bool.and(four_equal(a,b),U32.is_eq(f,g))
    case T.HealthMain{T.VitalsView{a,r,c}} T.HealthMain{T.VitalsView{b,s,d}}:
      Bool.and(four_equal(a,b),Bool.and(U32.is_eq(r,s),U32.is_eq(c,d)))
    case _ _: False{}
def ledger_equal(left: T.LedgerView,right: T.LedgerView) -> Bool:
  match left right:
    case T.LedgerView{a,e} T.LedgerView{b,f}: Bool.and(four_equal(a,b),U32.is_eq(e,f))
type RollbackObservation is Data:
  RollbackObservation{beforeB: T.MainView, afterB: T.MainView,
    committedA: T.MainView, afterA: T.MainView,
    committedLedger: T.LedgerView, afterLedger: T.LedgerView,
    beforeQueue: String, afterQueue: String, failedEventPublished: Bool, failedMarkVisible: Bool}
def rollback_observation(value: RollbackObservation) -> Bool:
  match value:
    case RollbackObservation{b,c,a,d,l,m,q,r,event,mark}:
      Bool.and(main_equal(b,c),Bool.and(main_equal(a,d),Bool.and(ledger_equal(l,m),
        Bool.and(String.eq(q,r),Bool.and(Bool.not(event),Bool.not(mark))))))
type AllocationObservation is Data:
  AllocationObservation{failed: U32, subsequent: U32, failedMissing: Bool, failedSpawnDiscarded: Bool}
def allocation_observation(value: AllocationObservation) -> Bool:
  match value:
    case AllocationObservation{failed,subsequent,missing,discarded}:
      Bool.and(U32.is_lt(failed,subsequent),Bool.and(missing,discarded))
type PublicationObservation is Data:
  PublicationObservation{success: Bool, stagedEvents: String, publishedEvents: String,
    stagedCommands: String, committedDelta: String}
def publication_observation(value: PublicationObservation) -> Bool:
  match value:
    case PublicationObservation{True{},events,published,commands,committed}:
      Bool.and(String.eq(events,published),String.eq(commands,committed))
    case PublicationObservation{False{},_,published,_,committed}:
      Bool.and(String.eq(published,""),String.eq(committed,""))

# Both nominal observations include every Main field, every Ledger field.
def motion_view(+x: U32) -> T.MainView:
  T.MotionMain{T.PositionView{T.Four{x,21,22,23},7}}
def health_view(+x: U32,+class: U32) -> T.MainView:
  T.HealthMain{T.VitalsView{T.Four{x,21,22,23},9,class}}
def ledger_view() -> T.LedgerView:
  T.LedgerView{T.Four{101,101,102,103},4}
def motion_a() -> T.MainView:
  T.MotionMain{T.PositionView{T.Four{11,11,12,13},7}}
def health_a() -> T.MainView:
  T.HealthMain{T.VitalsView{T.Four{11,11,12,13},9,2}}
def motion_queue() -> String:
  "Spawn(p4,Position([50,51,52,53],frame7),AuxNone,Selected8);Remove(a1,Selected)"
def health_queue() -> String:
  "Spawn(p4,Vitals([50,51,52,53],reserve9,class2),AuxNone,Tracked8);Remove(a1,Tracked)"
def extended_fixtures() -> Bool:
  Bool.and(rollback_observation(RollbackObservation{motion_view(20),motion_view(20),motion_a(),motion_a(),ledger_view(),ledger_view(),motion_queue(),motion_queue(),False{},False{}}),
    Bool.and(Bool.not(rollback_observation(RollbackObservation{motion_view(20),motion_view(30),motion_a(),motion_a(),ledger_view(),ledger_view(),motion_queue(),motion_queue(),False{},False{}})),
      Bool.and(rollback_observation(RollbackObservation{health_view(20,2),health_view(20,2),health_a(),health_a(),ledger_view(),ledger_view(),health_queue(),health_queue(),False{},False{}}),
        Bool.and(Bool.not(main_equal(health_view(20,2),health_view(20,3))),
          Bool.and(allocation_observation(AllocationObservation{5,6,True{},True{}}),
            Bool.and(Bool.not(allocation_observation(AllocationObservation{5,5,True{},True{}})),
              Bool.and(publication_observation(PublicationObservation{False{},"Ping9","","spawn q",""}),
                Bool.not(publication_observation(PublicationObservation{False{},"Ping9","Ping9","spawn q",""})))))))))

def main() -> Bool:
  Bool.and(fixtures(),extended_fixtures())
