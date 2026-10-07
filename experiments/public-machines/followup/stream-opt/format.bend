import Base

# Exact List.show textual contract, implemented with a decreasing tail loop.
# Observer only; every item is rendered once in its original order.
def show_loop(~E: Data,~show: E -> String,items: List<&2,E>,acc: String) -> String:
  match items:
    case []: acc ++ "]"
    case head <> rest: show_loop(~E,~show,rest,acc ++ ", " ++ show(head))
def show(~E: Data,~render: E -> String,items: List<&2,E>) -> String:
  match items:
    case []: "[]"
    case head <> rest: show_loop(~E,~render,rest,"[" ++ render(head))
