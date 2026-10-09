import Base
import serialize-next-state.bend as S
import ../../../trace-value.bend as J
def show(result:S.EncodeResult) -> String:
  match result:
    case S.EncodeComplete{text}:"complete:" ++ text ++ "\n"
    case S.EncodeIncomplete{}:"incomplete\n"
def main() -> String:
  show(S.walk(0n,[],["b","a"])) ++
  show(S.walk(0n,[J.TraceEmit{"a"}],[])) ++
  show(S.walk(1n,[J.TraceEmit{"a"}],[])) ++
  show(S.walk(1n,[J.Visit{J.Null{}}],[])) ++
  show(S.walk(2n,[J.Visit{J.Null{}}],[])) ++
  show(S.walk(2n,[J.Visit{J.Object{[]}}],[])) ++
  show(S.walk(3n,[J.Visit{J.Object{[]}}],[]))
