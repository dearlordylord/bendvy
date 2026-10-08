import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./geometry.bend as Geometry
import ./scenario.bend as Scenario

type Report is Data:
  TwoSchemaReport{workshop: List<&2,Scenario.Phase<Geometry.Workshop>>,garden: List<&2,Scenario.Phase<Geometry.Garden>>}
  InitializationRefused{schema: String}
def garden_run(workshop: List<&2,Scenario.Phase<Geometry.Workshop>>,run: Scenario.ScenarioRun<Geometry.Garden>) -> Report:
  match run:
    case Scenario.ScenarioRun{_,phases}: TwoSchemaReport{workshop,phases}
def garden(workshop: List<&2,Scenario.Phase<Geometry.Workshop>>,result: Scenario.ScenarioExecution<Geometry.Garden>) -> Report:
  match result:
    case Scenario.ScenarioExecuted{_,run}: garden_run(workshop,run)
    case Scenario.ScenarioInitializationRefused{_}: InitializationRefused{"Garden"}
def workshop_run(factory: W.Factory,run: Scenario.ScenarioRun<Geometry.Workshop>) -> Report:
  match run:
    case Scenario.ScenarioRun{_,phases}: garden(phases,Scenario.run(~Geometry.Garden,factory,64n))
def workshop(result: Scenario.ScenarioExecution<Geometry.Workshop>) -> Report:
  match result:
    case Scenario.ScenarioExecuted{factory,run}: workshop_run(factory,run)
    case Scenario.ScenarioInitializationRefused{_}: InitializationRefused{"Workshop"}
# The pure Data report prints every checkpoint; runtime owners are released
# only after their final complete observation has been retained in the trace.
def main() -> Report:
  workshop(Scenario.run(~Geometry.Workshop,W.factory(),64n))
