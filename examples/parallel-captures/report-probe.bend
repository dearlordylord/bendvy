import Base
import ./reports.bend as Report
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/string-equality.bend as StringEquality

def samples() -> List<&2,Exec.Observation<String,String>>:
  [Exec.Ran{9,"unknown"},Exec.BodyFailed{1,"body-error","body-out"},Exec.Ran{1,"duplicate"},Exec.ConditionFailed{8,"guard-error"},Exec.Skipped{7},Exec.ConditionRejected{6},Exec.AdmissionRejected{5}]
def observation() -> String:
  Report.report(App.Finished{samples()}) ++ "|" ++ Report.report(App.Stopped{"stop-error",samples()}) ++ "|" ++ Report.report(App.Invalid{Plan.Duplicate{41}}) ++ "|" ++ Report.report(App.Invalid{Plan.UnknownDependency{42}}) ++ "|" ++ Report.report(App.Invalid{Plan.Missing{43,"resource"}}) ++ "|" ++ Report.report(App.Invalid{Plan.Cycle{}}) ++ "|" ++ Report.report(App.Invalid{Plan.InvalidCondition{44}})
def expected() -> String:
  "[1/error/body-error/body-out, 1/success/duplicate, 5/refused, 6/condition-refused, 7/disabled, 8/condition-error/guard-error, 9/success/unknown]|stopped/stop-error/[1/error/body-error/body-out, 1/success/duplicate, 5/refused, 6/condition-refused, 7/disabled, 8/condition-error/guard-error, 9/success/unknown]|invalid/duplicate/41|invalid/unknown-dependency/42|invalid/missing/43/resource|invalid/cycle|invalid/invalid-condition/44"
def valid() -> Bool:StringEquality.equal(observation(),expected())
def main() -> IO(Unit):IO.print(observation())
