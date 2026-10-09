import Base
import /workspace/formal-proofs/bendvy/src/ecs/events.bend as Events
import ./ordinary-component.bend as Dump
import ./dump.bend as D
import ../app.bend as App
import ../scenario-schema.bend as S
import ../scenario-driver.bend as Driver
import ../scenario-dto.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View

type Report is Data:
  Report{baseline:DTO.ScenarioReport,observations:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>}
type Outcome is Data:
  Reported{report:Report}
  Failed{failure:Driver.Failure}

type ReaderSnapshot is Data:
  ReaderSnapshot{namespace:U32,offset:Nat}
type ReaderOutcome is Data:
  Kept{reader:ReaderSnapshot,outcome:Outcome}
  SeedFailed{failure:Driver.Failure}
# Reader is an actual affine log-reader owner, held outside all dump calls.
def retained(reader:Events.Reader<S.Schema>,outcome:Outcome) -> ReaderOutcome:
  match reader:
    case Events.Reader{namespace,offset}:Kept{ReaderSnapshot{namespace,offset},outcome}
def plain_finished(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Reported{Report{baseline,phases,dumps}}
def plain_after(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Driver.plain_observe(~Outcome,(factory => world => owners => phases => plain_finished(factory,world,owners,detached,baseline,phases,dumps)),factory,W.barrier(~S.Schema,~S.plain_store(),~Unit,~Unit,world),owners,phases,"after-explicit-barrier",DTO.Observed{},[])
def plain_disabled(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):Driver.plain_observe(~Outcome,(factory => world => owners => phases => plain_after(factory,world,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]))),factory,world,owners,phases,"after-repeated-dumps",DTO.Observed{},[])
def plain_disabled_normal(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):plain_disabled(factory,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]),Dump.plain_disabled_probe(world))
def plain_second(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,D.Population<S.Schema,View.FullCell>>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,second):plain_disabled_normal(factory,owners,detached,baseline,phases,[first,second],Dump.plain(App.Disabled{},world))
def plain_first(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,first):plain_second(factory,owners,detached,baseline,phases,first,Dump.plain(App.Enabled{},world))
def plain_before(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>) -> Outcome:
  plain_first(factory,owners,detached,baseline,phases,Dump.plain(App.Enabled{},world))
def plain_reader_created(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Events.Reader<S.Schema>) -> ReaderOutcome:
  match got:
    case (world,reader):retained(reader,Driver.plain_observe(~Outcome,(factory => world => owners => phases => plain_before(factory,world,owners,detached,baseline,phases)),factory,W.enqueue(~S.Schema,~S.plain_store(),~Unit,~Unit,W.event_publish(~S.Schema,~S.plain_store(),~Unit,~Unit,world,[Unit{},Unit{}]),(world => W.event_publish(~S.Schema,~S.plain_store(),~Unit,~Unit,world,[Unit{}]))),owners,[],"before-repeated-dumps",DTO.Observed{},[]))
def plain_delivered(delivery:Driver.Delivery<S.plain_store(),Driver.plain_owners()>) -> ReaderOutcome:
  match delivery:
    case Driver.Rejected{failure}:SeedFailed{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:plain_reader_created(factory,owners,detached,baseline,Events.create(~S.Schema,~S.plain_store(),~Unit,~Unit,world))

def transient_finished(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Reported{Report{baseline,phases,dumps}}
def transient_after(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Driver.transient_observe(~Outcome,(factory => world => owners => phases => transient_finished(factory,world,owners,detached,baseline,phases,dumps)),factory,W.barrier(~S.Schema,~S.transient_store(),~Unit,~Unit,world),owners,phases,"after-explicit-barrier",DTO.Observed{},[])
def transient_disabled(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):Driver.transient_observe(~Outcome,(factory => world => owners => phases => transient_after(factory,world,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]))),factory,world,owners,phases,"after-repeated-dumps",DTO.Observed{},[])
def transient_disabled_normal(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):transient_disabled(factory,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]),Dump.transient_disabled_probe(world))
def transient_second(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,D.Population<S.Schema,View.FullCell>>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,second):transient_disabled_normal(factory,owners,detached,baseline,phases,[first,second],Dump.transient(App.Disabled{},world))
def transient_first(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,first):transient_second(factory,owners,detached,baseline,phases,first,Dump.transient(App.Enabled{},world))
def transient_before(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>) -> Outcome:
  transient_first(factory,owners,detached,baseline,phases,Dump.transient(App.Enabled{},world))
def transient_reader_created(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Events.Reader<S.Schema>) -> ReaderOutcome:
  match got:
    case (world,reader):retained(reader,Driver.transient_observe(~Outcome,(factory => world => owners => phases => transient_before(factory,world,owners,detached,baseline,phases)),factory,W.enqueue(~S.Schema,~S.transient_store(),~Unit,~Unit,W.event_publish(~S.Schema,~S.transient_store(),~Unit,~Unit,world,[Unit{},Unit{}]),(world => W.event_publish(~S.Schema,~S.transient_store(),~Unit,~Unit,world,[Unit{}]))),owners,[],"before-repeated-dumps",DTO.Observed{},[]))
def transient_delivered(delivery:Driver.Delivery<S.transient_store(),Driver.transient_owners()>) -> ReaderOutcome:
  match delivery:
    case Driver.Rejected{failure}:SeedFailed{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:transient_reader_created(factory,owners,detached,baseline,Events.create(~S.Schema,~S.transient_store(),~Unit,~Unit,world))

def constructed_finished(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Reported{Report{baseline,phases,dumps}}
def constructed_after(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Driver.constructed_observe(~Outcome,(factory => world => owners => phases => constructed_finished(factory,world,owners,detached,baseline,phases,dumps)),factory,W.barrier(~S.Schema,~S.constructed_store(),~Unit,~Unit,world),owners,phases,"after-explicit-barrier",DTO.Observed{},[])
def constructed_disabled(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):Driver.constructed_observe(~Outcome,(factory => world => owners => phases => constructed_after(factory,world,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]))),factory,world,owners,phases,"after-repeated-dumps",DTO.Observed{},[])
def constructed_disabled_normal(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):constructed_disabled(factory,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]),Dump.constructed_disabled_probe(world))
def constructed_second(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,D.Population<S.Schema,View.FullCell>>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,second):constructed_disabled_normal(factory,owners,detached,baseline,phases,[first,second],Dump.constructed(App.Disabled{},world))
def constructed_first(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,first):constructed_second(factory,owners,detached,baseline,phases,first,Dump.constructed(App.Enabled{},world))
def constructed_before(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>) -> Outcome:
  constructed_first(factory,owners,detached,baseline,phases,Dump.constructed(App.Enabled{},world))
def constructed_reader_created(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Events.Reader<S.Schema>) -> ReaderOutcome:
  match got:
    case (world,reader):retained(reader,Driver.constructed_observe(~Outcome,(factory => world => owners => phases => constructed_before(factory,world,owners,detached,baseline,phases)),factory,W.enqueue(~S.Schema,~S.constructed_store(),~Unit,~Unit,W.event_publish(~S.Schema,~S.constructed_store(),~Unit,~Unit,world,[Unit{},Unit{}]),(world => W.event_publish(~S.Schema,~S.constructed_store(),~Unit,~Unit,world,[Unit{}]))),owners,[],"before-repeated-dumps",DTO.Observed{},[]))
def constructed_delivered(delivery:Driver.Delivery<S.constructed_store(),Driver.constructed_owners()>) -> ReaderOutcome:
  match delivery:
    case Driver.Rejected{failure}:SeedFailed{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:constructed_reader_created(factory,owners,detached,baseline,Events.create(~S.Schema,~S.constructed_store(),~Unit,~Unit,world))

type Output is Data:
  Output{plain:ReaderOutcome,transient:ReaderOutcome,constructed:ReaderOutcome}
def main() -> Output:
  Output{plain_delivered(Driver.plain()),transient_delivered(Driver.transient()),constructed_delivered(Driver.constructed())}
