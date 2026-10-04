import Base

# Input matrix only until the actual Host bulk invocation is delivered.
# These are fixture commands, not Q.BodyKind or a replacement dispatcher.
# Every RetFrame must become one real D.tick, including empty frames.
type RetActor is Data:
  RetFast{}
  RetB{}
  RetLate{}
type RetOp is Data:
  RetSpawn{count: U32,firstPayload: U32}
  RetEmit{first: U32,count: U32}
  RetRead{actor: RetActor,fails: Bool}
  RetRemoveAll{}
  RetDespawnAll{}
  RetRemoveFirstDespawnSecond{}
  RetWriteMain0{value: U32}
  RetBarrier{}
type RetFrame is Data:
  RetFrame{label: String,ops: List<&2,RetOp>}
type RetLane is Data:
  RetMessage{}
  RetRemoved{}
  RetDespawned{}
  RetUnheld{}
  RetMarks{}

def message_frames() -> List<&2,RetFrame>:
  [RetFrame{"seed-payload",[RetSpawn{1,10},RetBarrier{}]},
   RetFrame{"prime-fast",[RetRead{RetFast{},False{}}]},RetFrame{"prime-B",[RetRead{RetB{},False{}}]},
   RetFrame{"publish-full",[RetEmit{0,65536}]},RetFrame{"fast-full",[RetRead{RetFast{},False{}}]},
   RetFrame{"publish-one",[RetEmit{65536,1}]},RetFrame{"trim-full",[]},
   RetFrame{"B-first-post-drop-fails",[RetRead{RetB{},True{}}]},RetFrame{"B-same-instance-retry",[RetRead{RetB{},False{}}]},
   RetFrame{"independent-fast",[RetRead{RetFast{},False{}}]},RetFrame{"publish-oversized",[RetEmit{65537,65537}]},
   RetFrame{"trim-oversized",[]},RetFrame{"B-oversized-empty-lag",[RetRead{RetB{},False{}}]},
   RetFrame{"Fast-oversized-empty-lag",[RetRead{RetFast{},False{}}]},RetFrame{"late-registration-no-historical-lag",[RetRead{RetLate{},False{}}]}]
def lifecycle_frames(delete: RetOp) -> List<&2,RetFrame>:
  [RetFrame{"prime-fast",[RetRead{RetFast{},False{}}]},RetFrame{"prime-B",[RetRead{RetB{},False{}}]},
   RetFrame{"spawn-capacity-plus-one",[RetSpawn{65537,10},RetBarrier{}]},
   RetFrame{"Fast-all-added-full-fields",[RetRead{RetFast{},False{}}]},RetFrame{"B-all-added-full-fields",[RetRead{RetB{},False{}}]},
   RetFrame{"Fast-removals-before-trim",[delete,RetBarrier{},RetRead{RetFast{},False{}}]},RetFrame{"capacity-trim",[]},
   RetFrame{"late-registration-retained-records-no-historical-lag",[RetRead{RetLate{},False{}}]},
   RetFrame{"B-first-post-drop-fails",[RetRead{RetB{},True{}}]},RetFrame{"B-same-instance-retry",[RetRead{RetB{},False{}}]},
   RetFrame{"independent-fast-empty-not-lagged",[RetRead{RetFast{},False{}}]}]
def unheld_frames() -> List<&2,RetFrame>:
  [RetFrame{"spawn-unheld",[RetSpawn{2,10},RetBarrier{}]},RetFrame{"delete-unheld",[RetRemoveFirstDespawnSecond{},RetBarrier{}]},
   RetFrame{"empty1",[]},RetFrame{"empty2",[]},RetFrame{"empty3",[]},RetFrame{"first-Fast-no-history-or-lag",[RetRead{RetFast{},False{}}]}]
def marks_frames() -> List<&2,RetFrame>:
  [RetFrame{"prime-fast",[RetRead{RetFast{},False{}}]},RetFrame{"spawn",[RetSpawn{1,10},RetBarrier{}]},
   RetFrame{"Fast-seed",[RetRead{RetFast{},False{}}]},RetFrame{"write-slot0",[RetWriteMain0{11}]},
   RetFrame{"empty1",[]},RetFrame{"empty2",[]},RetFrame{"empty3",[]},RetFrame{"first-B-old-surviving-marks",[RetRead{RetB{},False{}}]}]
def frames(lane: RetLane) -> List<&2,RetFrame>:
  match lane:
    case RetMessage{}: message_frames()
    case RetRemoved{}: lifecycle_frames(RetRemoveAll{})
    case RetDespawned{}: lifecycle_frames(RetDespawnAll{})
    case RetUnheld{}: unheld_frames()
    case RetMarks{}: marks_frames()
