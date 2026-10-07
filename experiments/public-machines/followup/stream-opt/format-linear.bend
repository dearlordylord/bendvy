import Base

# Observer only. Accumulate reversed actual characters, never append a growing
# left String. Matching each rendered piece preserves all Unicode Char values.
def push_chars(piece: String,acc: List<&2,Char>) -> List<&2,Char>:
  match piece:
    case SNil{}: acc
    case SCon{head,rest}: push_chars(rest,head <> acc)
def finish_chars(chars: List<&2,Char>,acc: String) -> String:
  match chars:
    case []: acc
    case head <> rest: finish_chars(rest,SCon{head,acc})
def show_loop(~E: Data,~show: E -> String,items: List<&2,E>,acc: List<&2,Char>) -> String:
  match items:
    case []: finish_chars(acc,"]")
    case head <> rest: show_loop(~E,~show,rest,push_chars(show(head),Chr{32} <> Chr{44} <> acc))
def show(~E: Data,~render: E -> String,items: List<&2,E>) -> String:
  match items:
    case []: "[]"
    case head <> rest: show_loop(~E,~render,rest,push_chars(render(head),[Chr{91}]))
