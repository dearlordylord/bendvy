import Base
import ../../../src/ecs/lifecycle.bend as L

# Owned scalar arrays; exceptional authority is disjoint (id0 or id>131072).
# Raw constructor consistency is trusted provisioning, not a universal refinement.
type Metadata is Type:
  Metadata{added:Array<U32>,changed:Array<U32>,capacity:U32,depth:Nat,exceptional:List<&2,L.Entry>}
def empty() -> Metadata:
  Metadata{ALeaf{0},ALeaf{0},1,0n,[]}
def normal(+id:U32) -> Bool:
  U32.is_gt(id,0) && U32.is_le(id,131072)
def got_changed(added:Array<U32>,+capacity:U32,+depth:Nat,exceptional:List<&2,L.Entry>,first:U32,observed:Array<U32> & U32) -> Metadata & L.Stamp:
  match observed:
    case (changed,last): (Metadata{added,changed,capacity,depth,exceptional},L.Stamp{first,last})
def got_added(+id:U32,changed:Array<U32>,capacity:U32,depth:Nat,exceptional:List<&2,L.Entry>,observed:Array<U32> & U32) -> Metadata & L.Stamp:
  match observed:
    case (added,first): got_changed(added,capacity,depth,exceptional,first,Array.get(U32,changed,U32.sub(id,1)))
def get_checked(+id:U32,added:Array<U32>,changed:Array<U32>,capacity:U32,depth:Nat,+exceptional:List<&2,L.Entry>,isnormal:Bool,fits:Bool) -> Metadata & L.Stamp:
  match isnormal fits:
    case False{} _: (Metadata{added,changed,capacity,depth,exceptional},L.get(exceptional,id))
    case True{} False{}: (Metadata{added,changed,capacity,depth,exceptional},L.Stamp{0,0})
    case True{} True{}: got_added(id,changed,capacity,depth,exceptional,Array.get(U32,added,U32.sub(id,1)))
def get(metadata:Metadata,+id:U32) -> Metadata & L.Stamp:
  match metadata:
    case Metadata{added,changed,+capacity,depth,exceptional}: get_checked(id,added,changed,capacity,depth,exceptional,normal(id),U32.is_le(id,capacity))
def write_ready(+id:U32,added:Array<U32>,changed:Array<U32>,capacity:U32,depth:Nat,exceptional:List<&2,L.Entry>,stamp:L.Stamp) -> Metadata:
  match stamp:
    case L.Stamp{first,last}: Metadata{Array.set(U32,added,U32.sub(id,1),first),Array.set(U32,changed,U32.sub(id,1),last),capacity,depth,exceptional}
# Factory-produced metadata starts at1 and normal targets require at most17 grows.
def write_grow(fuel:Nat,+id:U32,stamp:L.Stamp,added:Array<U32>,changed:Array<U32>,+capacity:U32,+depth:Nat,exceptional:List<&2,L.Entry>,fits:Bool) -> Metadata:
  match fuel fits:
    case _ True{}: write_ready(id,added,changed,capacity,depth,exceptional,stamp)
    case 0n False{}: Metadata{added,changed,capacity,depth,exceptional}
    case 1n+rest False{}:
      +next = U32.shl(capacity)
      write_grow(rest,id,stamp,ANode{added,Array.new(U32,depth,0)},ANode{changed,Array.new(U32,depth,0)},next,1n+depth,exceptional,U32.is_le(id,next))
def set_checked(+id:U32,+stamp:L.Stamp,added:Array<U32>,changed:Array<U32>,+capacity:U32,depth:Nat,exceptional:List<&2,L.Entry>,isnormal:Bool) -> Metadata:
  match isnormal:
    case False{}: Metadata{added,changed,capacity,depth,L.set(exceptional,id,stamp)}
    case True{}: write_grow(17n,id,stamp,added,changed,capacity,depth,exceptional,U32.is_le(id,capacity))
def set(metadata:Metadata,+id:U32,stamp:L.Stamp) -> Metadata:
  match metadata:
    case Metadata{added,changed,capacity,depth,exceptional}: set_checked(id,stamp,added,changed,capacity,depth,exceptional,normal(id))
def clear_checked(+id:U32,added:Array<U32>,changed:Array<U32>,capacity:U32,depth:Nat,exceptional:List<&2,L.Entry>,isnormal:Bool,fits:Bool) -> Metadata:
  match isnormal fits:
    case False{} _: Metadata{added,changed,capacity,depth,L.clear(exceptional,id)}
    case True{} False{}: Metadata{added,changed,capacity,depth,exceptional}
    case True{} True{}: write_ready(id,added,changed,capacity,depth,exceptional,L.Stamp{0,0})
def clear(metadata:Metadata,+id:U32) -> Metadata:
  match metadata:
    case Metadata{added,changed,+capacity,depth,exceptional}: clear_checked(id,added,changed,capacity,depth,exceptional,normal(id),U32.is_le(id,capacity))
