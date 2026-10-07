import Base
import metadata.bend as M
import ../../../src/ecs/lifecycle.bend as L
import ../refusal-control.bend as P
import ../row-cell-control.bend as R

type Op is Data:
  Set{id:U32,stamp:L.Stamp}
  Clear{id:U32}
  Observe{}
def ids() -> List<&2,U32>:
  [0,1,2,3,4,5,63,64,65,131071,131072,131073,4294967295]
def append_stamp(rest:List<&2,U32>,stamp:L.Stamp) -> List<&2,U32>:
  match stamp:
    case L.Stamp{a,b}: a <> b <> rest
def stamps(remaining:List<&2,U32>,+legacy:List<&2,L.Entry>) -> List<&2,U32>:
  match remaining:
    case []: []
    case id <> rest: append_stamp(stamps(rest,legacy),L.get(legacy,id))
def observed_join(stamp:L.Stamp,observed:M.Metadata & List<&2,U32>) -> M.Metadata & List<&2,U32>:
  match observed:
    case (metadata,values): (metadata,append_stamp(values,stamp))
def observed_next(next:M.Metadata -> M.Metadata & List<&2,U32>,observed:M.Metadata & L.Stamp) -> M.Metadata & List<&2,U32>:
  match observed:
    case (metadata,stamp): observed_join(stamp,next(metadata))
def indexed_stamps(remaining:List<&2,U32>,metadata:M.Metadata) -> M.Metadata & List<&2,U32>:
  match remaining:
    case []: (metadata,[])
    case id <> rest: observed_next((metadata => indexed_stamps(rest,metadata)),M.get(metadata,id))
def same(points:List<&2,List<&2,U32>>,+expected:List<&2,U32>,observed:M.Metadata & List<&2,U32>) -> M.Metadata & List<&2,List<&2,U32>>:
  match observed:
    case (metadata,actual): (metadata,expected <> actual <> points)
def snapshot(legacy:List<&2,L.Entry>,points:List<&2,List<&2,U32>>,metadata:M.Metadata) -> M.Metadata & List<&2,List<&2,U32>>:
  same(points,stamps(ids(),legacy),indexed_stamps(ids(),metadata))
def trace_next(next:M.Metadata -> List<&2,List<&2,U32>> -> M.Metadata & List<&2,List<&2,U32>>,observed:M.Metadata & List<&2,List<&2,U32>>) -> M.Metadata & List<&2,List<&2,U32>>:
  match observed:
    case (metadata,points): next(metadata,points)
def trace(ops:List<&2,Op>,+legacy:List<&2,L.Entry>,metadata:M.Metadata,points:List<&2,List<&2,U32>>) -> M.Metadata & List<&2,List<&2,U32>>:
  match ops:
    case []: snapshot(legacy,points,metadata)
    case Set{+id,+stamp} <> rest: trace(rest,L.set(legacy,id,stamp),M.set(metadata,id,stamp),points)
    case Clear{+id} <> rest: trace(rest,L.clear(legacy,id),M.clear(metadata,id),points)
    case Observe{} <> rest: trace_next((metadata => points => trace(rest,legacy,metadata,points)),snapshot(legacy,points,metadata))
def result(observed:M.Metadata & List<&2,List<&2,U32>>) -> List<&2,List<&2,U32>>:
  match observed:
    case (_,points): points
def ops() -> List<&2,Op>:
  [Observe{},Set{1,L.Stamp{5,9}},Set{2,L.Stamp{0,13}},Observe{},Set{3,L.Stamp{17,0}},Set{5,L.Stamp{0,0}},Observe{},Set{64,L.Stamp{23,29}},Set{65,L.Stamp{31,37}},Observe{},Set{131072,L.Stamp{41,43}},Observe{},Set{0,L.Stamp{47,53}},Set{131073,L.Stamp{59,61}},Set{4294967295,L.Stamp{67,71}},Observe{},Set{1,L.Stamp{5,73}},Set{1,L.Stamp{5,79}},Observe{},Set{1,L.Stamp{5,73}},Set{1,L.Stamp{5,9}},Observe{},Clear{2},Clear{0},Clear{131073},Clear{4294967295},Clear{131072},Observe{}]
def payload_metadata(points:List<&2,U32>,observed:M.Metadata & L.Stamp) -> List<&2,U32>:
  match observed:
    case (M.Metadata{_,_,capacity,depth,_},L.Stamp{a,b}): List.append(&2,U32,points,[a,b,capacity,U32.from_nat(depth)])
def payload_seen(metadata:M.Metadata,observed:P.Payload & P.View) -> List<&2,U32>:
  match observed:
    case (owner,view): payload_metadata(R.incoming(R.cells(view),P.project(owner)),M.get(metadata,131073))
def payload_mutation() -> List<&2,U32>:
  payload_seen(M.set(M.empty(),131073,L.Stamp{5,9}),R.mutate(P.Payload{ANode{ALeaf{3},ALeaf{7}}}))
def legacy_entry(entry:L.Entry) -> List<&2,U32>:
  match entry:
    case L.Entry{id,L.Stamp{a,b}}: [id,a,b]
def legacy_entries(entries:List<&2,L.Entry>) -> List<&2,U32>:
  match entries:
    case []: []
    case entry <> rest: List.append(&2,U32,legacy_entry(entry),legacy_entries(rest))
def duplicates() -> List<&2,List<&2,U32>>:
  +entries:List<&2,L.Entry> = [L.Entry{1,L.Stamp{5,9}},L.Entry{2,L.Stamp{0,13}},L.Entry{1,L.Stamp{17,19}},L.Entry{0,L.Stamp{23,29}}]
  [stamps([1,2,0],entries),legacy_entries(L.set(entries,1,L.Stamp{31,37})),legacy_entries(L.clear(entries,1))]
def exceptional() -> List<&2,List<&2,U32>>:
  +entries:List<&2,L.Entry> = [L.Entry{0,L.Stamp{5,9}},L.Entry{131073,L.Stamp{17,19}},L.Entry{0,L.Stamp{23,29}}]
  result(trace([Observe{},Set{0,L.Stamp{31,37}},Observe{},Clear{0},Observe{}],entries,M.Metadata{ALeaf{0},ALeaf{0},1,0n,entries},[]))
def dense_ids(fuel:Nat,+id:U32) -> List<&2,U32>:
  match fuel:
    case 0n: []
    case 1n+rest: id <> dense_ids(rest,U32.add(id,1))
def dense_indexed(fuel:Nat,+id:U32,metadata:M.Metadata) -> M.Metadata:
  match fuel:
    case 0n: metadata
    case 1n+rest: dense_indexed(rest,U32.add(id,1),M.set(metadata,id,L.Stamp{id,U32.add(id,1)}))
def dense_legacy(fuel:Nat,+id:U32,legacy:List<&2,L.Entry>) -> List<&2,L.Entry>:
  match fuel:
    case 0n: legacy
    case 1n+rest: dense_legacy(rest,U32.add(id,1),L.set(legacy,id,L.Stamp{id,U32.add(id,1)}))
def dense() -> List<&2,List<&2,U32>>:
  result(same([],stamps(dense_ids(64n,1),dense_legacy(64n,1,[])),indexed_stamps(dense_ids(64n,1),dense_indexed(64n,1,M.empty()))))
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),List.append(&2,List<&2,U32>,dense(),List.append(&2,List<&2,U32>,result(trace(ops(),[],M.empty(),[])),List.append(&2,List<&2,U32>,exceptional(),List.append(&2,List<&2,U32>,duplicates(),[payload_mutation()]))))))
