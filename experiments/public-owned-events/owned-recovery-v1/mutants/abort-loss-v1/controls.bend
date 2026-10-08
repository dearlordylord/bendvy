import Base
import staging.bend as Stage

type Payload is Type: Payload{tag:String,cells:Array<U32>}
type Outcome is Type:
  Committed{receipt:Stage.Committed<Payload>}
  Aborted{receipt:Stage.Aborted<Payload>}
  Refused{receipt:Stage.Aborted<Payload>,incoming:Payload}
def first() -> Stage.Offered<Payload>:
  Stage.offer(~Payload,True{},Stage.empty(~Payload),Payload{"first",ANode{ALeaf{11},ALeaf{12}}})
def second(allowed:Bool,first:Stage.Offered<Payload>) -> Stage.Offered<Payload>:
  match first:
    case Stage.Accepted{stage}: Stage.offer(~Payload,allowed,stage,Payload{"second",ANode{ANode{ALeaf{21},ALeaf{22}},ANode{ALeaf{23},ALeaf{24}}}})
    case Stage.Refused{stage,incoming}: Stage.Refused{stage,incoming}
def finish(commit:Bool,offered:Stage.Offered<Payload>) -> Outcome:
  match commit offered:
    case True{} Stage.Accepted{stage}: Committed{Stage.commit(~Payload,stage)}
    case False{} Stage.Accepted{stage}: Aborted{Stage.abort(~Payload,stage)}
    case _ Stage.Refused{stage,incoming}: Refused{Stage.abort(~Payload,stage),incoming}
def success() -> Outcome:
  finish(True{},second(True{},first()))
def aborted() -> Outcome:
  finish(False{},second(True{},first()))
def refused() -> Outcome:
  finish(True{},second(False{},first()))
# Consume every Array leaf, payload and list item rather than observe a prefix.
def cells(owner:Array<U32>) -> String:
  match owner:
    case ALeaf{value}: U32.show(value) ++ ","
    case ANode{left,right}: cells(left) ++ cells(right)
def payload(owner:Payload) -> String:
  match owner:
    case Payload{tag,owner}: tag ++ ":" ++ cells(owner)
def owners(values:List<Payload>) -> String:
  match values:
    case []: ""
    case head <> tail: payload(head) ++ ";" ++ owners(tail)
def observe(outcome:Outcome) -> String:
  match outcome:
    case Committed{Stage.Committed{values}}: "commit:" ++ owners(values)
    case Aborted{Stage.Aborted{values}}: "abort:" ++ owners(values)
    case Refused{Stage.Aborted{values},incoming}: "refused:" ++ owners(values) ++ "|incoming:" ++ payload(incoming)
def complete_controls() -> String:
  observe(success()) ++ "\n" ++ observe(aborted()) ++ "\n" ++ observe(refused())
