import Base
import ../../timed-v5/bend/common-main.bend as Common
import ../../timed-v5/bend/timing.bend as Clock

def final_argument(values: List<String>, last: String) -> String:
  match values:
    case []: last
    case head <> rest: final_argument(rest, head)

def four(value: ((String & String) & Cmp)) -> Maybe<&2, Nat>:
  match value:
    case ((_, _), EQ{}): Some{4n}
    case _: None{}

def two(value: ((String & String) & Cmp)) -> Maybe<&2, Nat>:
  match value:
    case ((_, _), EQ{}): Some{2n}
    case ((text, _), _): four(String.cmp(text, "4"))

def after_one(value: ((String & String) & Cmp)) -> Maybe<&2, Nat>:
  match value:
    case ((_, _), EQ{}): Some{1n}
    case ((text, _), _): two(String.cmp(text, "2"))

def repetitions(text: String) -> Maybe<&2, Nat>:
  after_one(String.cmp(text, "1"))

def capture_all(remaining: Nat, +interval: U32) -> IO(Unit):
  match remaining:
    case 0n: Clock.finish(interval)
    case 1n+rest:
      IO.bind(Unit, Unit, Clock.begin(interval), _ =>
        IO.bind(Unit, Unit, Clock.capture(Common.main()), _ =>
          IO.bind(Unit, Unit, Clock.end(), _ =>
            capture_all(rest, U32.add(interval, 1)))))

def selected(value: Maybe<&2, Nat>) -> IO(Unit):
  match value:
    case Some{count}:
      IO.bind(Unit, Unit, Clock.reset(), _ => capture_all(count, 0))
    case None{}:
      IO.die(Unit, 2, "repetitions must be 1, 2, or 4")

def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    selected(repetitions(final_argument(values, "missing")))
