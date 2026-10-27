import Base
import ./extended-refusal.bend as Refusal
import ./declarations.bend as O

# Ordinary recovery entry: invalid detached scope metadata is rejected, then the
# same actual App is restored from its retained valid input and resumes execution.
def main() -> IO(Unit):IO.bind(Refusal.Outcome<O.Alpha>,Unit,Refusal.run_kind(~O.Alpha,Refusal.DuplicateScope{},False{}),a => IO.bind(Unit,Unit,IO.print("alpha-duplicate-serial " ++ Refusal.observed(~O.Alpha,a)),u => IO.bind(Refusal.Outcome<O.Beta>,Unit,Refusal.run_kind(~O.Beta,Refusal.StaleScope{},True{}),b => IO.print("beta-stale-native " ++ Refusal.observed(~O.Beta,b)))))
