import Base
import ./core.bend as A

def prepared(-T: Type, mode: U32, t: T, before: A.View, after: A.View) -> A.Prepared<T>:
  match mode:
    case 0: A.Prepared{t, A.Success{}, "good:own:" ++ A.view_text(after), Some{1}, Some{A.Remove{0}}}
    case 1: A.Prepared{t, A.Success{}, "fail:before:" ++ A.view_text(before) ++ "\nfail:own1:" ++ A.view_text(after), None{}, None{}}
    case 2: A.Prepared{t, A.Failure{"Fail", 7}, "\nfail:own2:" ++ A.view_text(after) ++ "\nhost:failure-effect", Some{9}, Some{A.Insert{0}}}
    case 3: A.Prepared{t, A.Success{}, "", None{}, None{}}
    case _: A.Prepared{t, A.Success{}, "", Some{9}, Some{A.Insert{0}}}
def step_after(-T: Type, mode: U32, before: A.View, result: T & A.View) -> A.Prepared<T>:
  match result:
    case (t, v): prepared(T, mode, t, before, v)
def step_write(-T: Type, set: T -> U32 -> U32 -> U32 -> T, after: T -> T & A.View, t: T, v: A.View, config: A.StepConfig) -> A.Prepared<T>:
  match config:
    case A.StepConfig{x, r, p, mode}: step_after(T, mode, v, after(set(t, x, r, p)))
def step_before(-T: Type, set: T -> U32 -> U32 -> U32 -> T, after: T -> T & A.View, config: A.StepConfig, result: T & A.View) -> A.Prepared<T>:
  match result:
    case (t, v): step_write(T, set, after, t, v, config)
def step(-T: Type, before: T -> T & A.View, set: T -> U32 -> U32 -> U32 -> T, after: T -> T & A.View, config: A.StepConfig, t: T) -> A.Prepared<T>:
  step_before(T, set, after, config, before(t))
def good() -> A.StepConfig:
  A.StepConfig{5, 7, 13, 0}
def fail_first() -> A.StepConfig:
  A.StepConfig{9, 11, 17, 1}
def fail_second() -> A.StepConfig:
  A.StepConfig{12, 13, 19, 2}
def control_first() -> A.StepConfig:
  A.StepConfig{9, 11, 17, 3}
def control_second() -> A.StepConfig:
  A.StepConfig{12, 13, 19, 4}
