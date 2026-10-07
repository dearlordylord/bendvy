import Base
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/indexed-lifecycle.bend as I

def legacy_get_shared(+entries:List<&2,L.Entry>,id:U32) -> List<&2,L.Entry> & L.Stamp:
  (entries,L.get(entries,id))
def legacy_get(entries:List<&2,L.Entry>,id:U32) -> List<&2,L.Entry> & L.Stamp:
  legacy_get_shared(entries,id)
def legacy_set(entries:List<&2,L.Entry>,id:U32,stamp:L.Stamp) -> List<&2,L.Entry>:
  L.set(entries,id,stamp)
def legacy_clear(entries:List<&2,L.Entry>,id:U32) -> List<&2,L.Entry>:
  L.clear(entries,id)

def indexed_get(metadata:I.Metadata,id:U32) -> I.Metadata & L.Stamp:
  I.get(metadata,id)
def indexed_set(metadata:I.Metadata,id:U32,stamp:L.Stamp) -> I.Metadata:
  I.set(metadata,id,stamp)
def indexed_clear(metadata:I.Metadata,id:U32) -> I.Metadata:
  I.clear(metadata,id)

# Destructuring a trusted diagnostic owner is not public authority/confinement.
def indexed_capacity(metadata:I.Metadata) -> I.Metadata & U32:
  match metadata:
    case I.Metadata{added,changed,+capacity,depth,exceptional}: (I.Metadata{added,changed,capacity,depth,exceptional},capacity)
