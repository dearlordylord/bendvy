import Base
import ./declarations.bend as O
import ./observation.bend as Observe
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-schema.bend as Schema
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/world.bend as W
import ../../src/ecs/world-io.bend as WorldIO

def resources(~S:Data) -> Plan.Plan:Plan.Plain{O.Config<S>,O.ConfigView,O.config_view(~S),"plain-config",Policy.Ordinary{}}
def World(~S:Data) -> Type:W.World<S,Unit,Layout.resources(~S,Plan.layout(resources(~S))),Unit>
def Schema(~S:Data) -> Type:Plan.Schema<S,Plan.Empty{},resources(~S)>
type Outcome<-S:Data> is Type:
  Saved{schema:Schema(~S),world:World(~S),outcome:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
  CreationRefused{creation:WorldIO.Creation<S,Unit,Layout.resources(~S,Plan.layout(resources(~S))),Unit>}
def saved(~S:Data,result:Schema(~S) & (World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> Outcome<S>:
  match result:
    case (schema,(world,outcome)):Saved{schema,world,outcome}
def created(~S:Data,result:WorldIO.Creation<S,Unit,Layout.resources(~S,Plan.layout(resources(~S))),Unit>) -> Outcome<S>:
  match result:
    case WorldIO.Created{world}:saved(~S,Save.save(~S,~Plan.Empty{},~resources(~S),~Unit,Plan.Schema{Unit{},Decl.Plain{}},Schema.initialized_world(~S,~Layout.EmptyLayout{},~Plan.layout(resources(~S)),~Unit,world)))
    case other:CreationRefused{other}
# Plain eligibility is exercised at the generic World boundary; this is distinct
# from the Scheduled command-owner refusal consumer.
def run(~S:Data) -> IO(Outcome<S>):IO.bind(WorldIO.Creation<S,Unit,Layout.resources(~S,Plan.layout(resources(~S))),Unit>,Outcome<S>,WorldIO.create(~S,~Unit,~Layout.resources(~S,Plan.layout(resources(~S))),~Unit,~(u => u),Layout.ResourceSlot{Layout.Viewed{O.Config{True{},ALeaf{777}},O.ConfigView{True{},777}},Layout.unknown_stamp()}),result => IO.pure(Outcome<S>,created(~S,result)))
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Saved{_,W.World{namespace,_,_,Layout.ResourceSlot{Layout.Viewed{O.Config{enabled,limit},O.ConfigView{cachedEnabled,cachedLimit}},stamp},_,_,_,_,_,_},Gate.Refused{Recipe.PlainUnserializable{key}}}:"plain-refused/" ++ key ++ "/ns=" ++ U32.show(namespace) ++ "/actual=" ++ Bool.show(enabled) ++ ":" ++ Observe.captured(Array.get(U32,limit,0)) ++ "/cached=" ++ Bool.show(cachedEnabled) ++ ":" ++ U32.show(cachedLimit)
    case _:"other"
def main() -> IO(Unit):IO.bind(Outcome<O.Alpha>,Unit,run(~O.Alpha),a => IO.bind(Unit,Unit,IO.print("alpha " ++ observed(~O.Alpha,a)),u => IO.bind(Outcome<O.Beta>,Unit,run(~O.Beta),b => IO.print("beta " ++ observed(~O.Beta,b)))))
