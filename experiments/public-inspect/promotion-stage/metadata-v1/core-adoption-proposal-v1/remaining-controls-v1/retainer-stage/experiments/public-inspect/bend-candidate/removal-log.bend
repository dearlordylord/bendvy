import Base
import removal-publication.bend as P
import ../../../src/ecs/removals.bend as Rm

# One declared family/despawn stream. Publication ticks originate in P, never
# in transport. H owns real registered reader owners; the closed positions
# projection must thread each actual System.cursor owner. Inspectors own no H.
type Log<S:Data,F:Data,H:Type> is Type:
  Log{holders:H,items:List<&2,P.Notice<S,F>>,droppedThrough:U32,capacity:Nat}
type Reading<S:Data,F:Data> is Data:
  Reading{items:List<&2,Rm.Record<S,F>>,lagged:Bool}
def choose(less:Bool,a:U32,b:U32) -> U32:
  match less:
    case True{}:a
    case False{}:b
def min(+a:U32,+b:U32) -> U32:
  choose(U32.is_lt(a,b),a,b)
def max(+a:U32,+b:U32) -> U32:
  choose(U32.is_lt(a,b),b,a)
def boundary(cursors:List<&2,U32>,window:U32) -> U32:
  match cursors:
    case []:window
    case cursor <> rest:boundary(rest,min(cursor,window))
def count(~S:Data,~F:Data,items:List<&2,P.Notice<S,F>>) -> Nat:
  match items:
    case []:0n
    case _ <> rest:(1n + count(~S,~F,rest) : Nat)
def include(~S:Data,~F:Data,selected:Bool,record:Rm.Record<S,F>,rest:List<&2,Rm.Record<S,F>>) -> List<&2,Rm.Record<S,F>>:
  match selected:
    case True{}:record <> rest
    case False{}:rest
def since(~S:Data,~F:Data,items:List<&2,P.Notice<S,F>>,+cursor:U32) -> List<&2,Rm.Record<S,F>>:
  match items:
    case []:[]
    case P.Notice{tick,record} <> rest:include(~S,~F,U32.is_lt(cursor,tick),record,since(~S,~F,rest,cursor))
def read(~S:Data,~F:Data,~H:Type,+cursor:U32,+registeredAt:U32,log:Log<S,F,H>) -> Log<S,F,H> & Reading<S,F>:
  match log:
    case Log{holders,+items,+dropped,+capacity}:(Log{holders,items,dropped,capacity},Reading{since(~S,~F,items,cursor),U32.is_lt(max(cursor,registeredAt),dropped)})
def overflow(~S:Data,~F:Data,excess:Bool,+tick:U32,+record:Rm.Record<S,F>,+rest:List<&2,P.Notice<S,F>>,dropped:U32,continue:U32 -> List<&2,P.Notice<S,F>> & U32) -> List<&2,P.Notice<S,F>> & U32:
  match excess:
    case False{}:(P.Notice{tick,record} <> rest,dropped)
    case True{}:continue(max(dropped,tick))
def capacity_loop(~S:Data,~F:Data,items:List<&2,P.Notice<S,F>>,+capacity:Nat,dropped:U32) -> List<&2,P.Notice<S,F>> & U32:
  match items:
    case []:([],dropped)
    case P.Notice{+tick,+record} <> +rest:overflow(~S,~F,Nat.is_lt(capacity,count(~S,~F,P.Notice{tick,record} <> rest)),tick,record,rest,dropped,gone => capacity_loop(~S,~F,rest,capacity,gone))
def past(~S:Data,~F:Data,keep:Bool,+tick:U32,+record:Rm.Record<S,F>,+rest:List<&2,P.Notice<S,F>>,dropped:U32,capacity:Nat,continue:U32 -> List<&2,P.Notice<S,F>> & U32) -> List<&2,P.Notice<S,F>> & U32:
  match keep:
    case True{}:capacity_loop(~S,~F,P.Notice{tick,record} <> rest,capacity,dropped)
    case False{}:continue(max(dropped,tick))
def trim_loop(~S:Data,~F:Data,items:List<&2,P.Notice<S,F>>,+cutoff:U32,dropped:U32,+capacity:Nat) -> List<&2,P.Notice<S,F>> & U32:
  match items:
    case []:([],dropped)
    case P.Notice{+tick,+record} <> +rest:past(~S,~F,U32.is_lt(cutoff,tick),tick,record,rest,dropped,capacity,gone => trim_loop(~S,~F,rest,cutoff,gone,capacity))
def trimmed(~S:Data,~F:Data,~H:Type,holders:H,+capacity:Nat,result:List<&2,P.Notice<S,F>> & U32) -> Log<S,F,H>:
  (items,dropped)=result
  Log{holders,items,dropped,capacity}
def positions(~S:Data,~F:Data,~H:Type,+window:U32,+items:List<&2,P.Notice<S,F>>,+dropped:U32,+capacity:Nat,result:H & List<&2,U32>) -> Log<S,F,H>:
  (holders,+cursors)=result
  trimmed(~S,~F,~H,holders,capacity,trim_loop(~S,~F,items,boundary(cursors,window),dropped,capacity))
def trim(~S:Data,~F:Data,~H:Type,~project:H -> H & List<&2,U32>,+window:U32,log:Log<S,F,H>) -> Log<S,F,H>:
  match log:
    case Log{holders,+items,+dropped,+capacity}:positions(~S,~F,~H,window,items,dropped,capacity,project(holders))
