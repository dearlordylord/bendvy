import Base
import provider.bend as P
import machine.bend as M
import conditions.bend as C

def environment(~S: Data) -> P.ConditionEnv<S>:
  P.ConditionEnv{M.Present{P.Boot{},M.NoPending{},None{},False{}},M.Present{P.Low{},M.NoPending{},None{},True{}}}

def missing_level(~S: Data) -> P.ConditionEnv<S>:
  P.ConditionEnv{M.Present{P.Boot{},M.NoPending{},None{},False{}},M.Missing{}}

def show_result(label: String,value: Bool) -> String:
  label ++ "=" ++ Bool.show(value)

def show_check(label: String,result: P.ConditionCheck) -> String:
  match result:
    case P.ConditionMissing{}: label ++ "=missing"
    case P.ConditionValue{passes}: label ++ "=value:" ++ Bool.show(passes)

def rows(~S: Data) -> List<&2,String>:
  [show_result("mixed-all",P.condition_from_env(~S,C.all(~P.Atom<S>,[C.Leaf{P.InFlow{P.Boot{}}},C.Leaf{P.InLevel{P.Low{}}},C.Leaf{P.LevelChanged{}}]),environment(~S))),
   show_result("mixed-false",P.condition_from_env(~S,C.Both{C.Leaf{P.InFlow{P.Play{}}},C.Leaf{P.LevelChanged{}}},environment(~S))),
   show_result("mixed-any",P.condition_from_env(~S,C.any(~P.Atom<S>,[C.Leaf{P.InFlow{P.Play{}}},C.Leaf{P.InLevel{P.Low{}}}]),environment(~S))),
   show_result("negated",P.condition_from_env(~S,C.Negate{C.Leaf{P.FlowChanged{}}},environment(~S))),
   show_result("empty-all",P.condition_from_env(~S,C.all(~P.Atom<S>,[]),missing_level(~S))),
   show_result("empty-any",P.condition_from_env(~S,C.any(~P.Atom<S>,[]),missing_level(~S))),
   show_check("missing-hidden-by-true",P.condition_check(~S,C.Either{C.Constant{True{}},C.Leaf{P.InLevel{P.Low{}}}},missing_level(~S))),
   show_check("missing-negated",P.condition_check(~S,C.Negate{C.Leaf{P.LevelChanged{}}},missing_level(~S)))]

def main() -> IO(Unit):
  IO.print("A=" ++ List.show(&2,String,(text => text),rows(~P.SchemaA)) ++ "\nB=" ++ List.show(&2,String,(text => text),rows(~P.SchemaB)))
