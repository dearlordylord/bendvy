import Base
import ../mutant-caller.bend as Caller

# The complete affine delivery is the observation: no payload/owner projection.
type Report is Type:
  Report{first:Caller.Delivery<Caller.A>,second:Caller.Delivery<Caller.Other>}
def main() -> Report:
  Report{Caller.run(~Caller.A),Caller.run(~Caller.Other)}
