import Base
import ./scenario-schema.bend as S
import ./scenario-dto.bend as DTO
import ./scenario-driver.bend as Driver

# Source-level delivery retains final World and every actual registered owner.
# This executable observes them completely before process-end fixture teardown.
type Output is Data:
  Report{plain:DTO.ScenarioReport,transient:DTO.ScenarioReport,constructed:DTO.ScenarioReport}
  Failure{category:String,details:Driver.Failure}
def constructed_done(plain:DTO.ScenarioReport,transient:DTO.ScenarioReport,delivered:Driver.Delivery<S.constructed_store(),Driver.constructed_owners()>) -> Output:
  match delivered:
    case Driver.Delivered{factory,world,owners,detached,report}:Report{plain,transient,report}
    case Driver.Rejected{failure}:Failure{"constructed",failure}
def transient_done(plain:DTO.ScenarioReport,delivered:Driver.Delivery<S.transient_store(),Driver.transient_owners()>) -> Output:
  match delivered:
    case Driver.Delivered{factory,world,owners,detached,report}:constructed_done(plain,report,Driver.constructed())
    case Driver.Rejected{failure}:Failure{"transient",failure}
def plain_done(delivered:Driver.Delivery<S.plain_store(),Driver.plain_owners()>) -> Output:
  match delivered:
    case Driver.Delivered{factory,world,owners,detached,report}:transient_done(report,Driver.transient())
    case Driver.Rejected{failure}:Failure{"plain",failure}
def main() -> Output:
  plain_done(Driver.plain())
