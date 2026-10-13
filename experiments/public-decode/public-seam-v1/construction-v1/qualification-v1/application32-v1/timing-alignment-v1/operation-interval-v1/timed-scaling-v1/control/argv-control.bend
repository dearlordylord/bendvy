import Base

# The final item is the workload selector after runtime-owned options have
# been removed by the installed Bend IO.args effect.
def last(values: List<String>, prior: String) -> String:
  match values:
    case []: prior
    case head <> rest: last(rest, head)

def report(values: List<String>) -> IO(Unit):
  IO.print("selector=" ++ last(values, "missing"))

def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    report(values)
