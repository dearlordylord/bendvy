import Base
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/indexed-lifecycle.bend as M

# Counts are structural occurrences, not unique allocations or timestamp maxima.
type ArrayStats is Data:
  ArrayStats{leaves:Nat,nodes:Nat,nonzero:Nat}
type EntryStats is Data:
  EntryStats{physical:Nat,added:Nat,changed:Nat,populated:Nat}
type MetadataStats is Data:
  MetadataStats{added:ArrayStats,changed:ArrayStats,capacity:U32,depth:Nat,exceptional:EntryStats,populated:Nat}
def nonzero(value:Bool) -> Nat:
  match value:
    case True{}:1n
    case False{}:0n
def scalar(+value:U32) -> Array<U32> & ArrayStats:
  (ALeaf{value},ArrayStats{1n,0n,nonzero(U32.is_gt(value,0))})
def branch(left:Array<U32> & ArrayStats,right:Array<U32> & ArrayStats) -> Array<U32> & ArrayStats:
  match left right:
    case (left, ArrayStats{a,b,c}), (right, ArrayStats{x,y,z}):(ANode{left,right},ArrayStats{Nat.add(a,x),1n+Nat.add(b,y),Nat.add(c,z)})
def array(value:Array<U32>) -> Array<U32> & ArrayStats:
  match value:
    case ALeaf{value}:scalar(value)
    case ANode{left,right}:branch(array(left),array(right))
def entry_added(+first:U32,+last:U32,rest:EntryStats) -> EntryStats:
  match rest:
    case EntryStats{physical,added,changed,populated}:EntryStats{1n+physical,Nat.add(nonzero(U32.is_gt(first,0)),added),Nat.add(nonzero(U32.is_gt(last,0)),changed),Nat.add(nonzero(Bool.or(U32.is_gt(first,0),U32.is_gt(last,0))),populated)}
def entry(value:L.Entry,rest:EntryStats) -> EntryStats:
  match value:
    case L.Entry{_,L.Stamp{first,last}}:entry_added(first,last,rest)
def entries(values:List<&2,L.Entry>) -> EntryStats:
  match values:
    case []:EntryStats{0n,0n,0n,0n}
    case head <> tail:entry(head,entries(tail))
def flag_leaf(+value:U32) -> Array<U32> & List<&2,Bool>:(ALeaf{value},[U32.is_gt(value,0)])
def flag_node(left:Array<U32> & List<&2,Bool>,right:Array<U32> & List<&2,Bool>) -> Array<U32> & List<&2,Bool>:
  match left right:
    case (left,a), (right,b):(ANode{left,right},List.append(&2,Bool,a,b))
def flags(value:Array<U32>) -> Array<U32> & List<&2,Bool>:
  match value:
    case ALeaf{value}:flag_leaf(value)
    case ANode{left,right}:flag_node(flags(left),flags(right))
def union(left:List<&2,Bool>,right:List<&2,Bool>) -> Nat:
  match left right:
    case [], []:0n
    case head <> tail, []:Nat.add(nonzero(head),union(tail,[]))
    case [], head <> tail:Nat.add(nonzero(head),union([],tail))
    case a <> more, b <> rest:Nat.add(nonzero(Bool.or(a,b)),union(more,rest))
def metadata_flags(+capacity:U32,+depth:Nat,+exceptional:List<&2,L.Entry>,a:ArrayStats,c:ArrayStats,added:Array<U32> & List<&2,Bool>,changed:Array<U32> & List<&2,Bool>) -> M.Metadata & MetadataStats:
  match added changed:
    case (added,af), (changed,cf):(M.Metadata{added,changed,capacity,depth,exceptional},MetadataStats{a,c,capacity,depth,entries(exceptional),union(af,cf)})
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,L.Entry>,added:Array<U32> & ArrayStats,changed:Array<U32> & ArrayStats) -> M.Metadata & MetadataStats:
  match added changed:
    case (added,a), (changed,c):metadata_flags(capacity,depth,exceptional,a,c,flags(added),flags(changed))
def metadata(value:M.Metadata) -> M.Metadata & MetadataStats:
  match value:
    case M.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,array(added),array(changed))
