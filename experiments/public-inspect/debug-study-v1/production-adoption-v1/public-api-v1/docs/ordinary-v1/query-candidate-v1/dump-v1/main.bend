import Base
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

def plain_finished(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Reported{Report{baseline,phases,dumps}}
def plain_disabled(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):Driver.plain_observe(~Outcome,(factory => world => owners => phases => plain_finished(factory,world,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]))),factory,world,owners,phases,"after-repeated-dumps",DTO.Observed{},[])
def plain_second(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,D.Population<S.Schema,View.FullCell>>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,second):plain_disabled(factory,owners,detached,baseline,phases,[first,second],Dump.plain(App.Disabled{},world))
def plain_first(factory:W.Factory,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,first):plain_second(factory,owners,detached,baseline,phases,first,Dump.plain(App.Enabled{},world))
def plain_before(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>) -> Outcome:
  plain_first(factory,owners,detached,baseline,phases,Dump.plain(App.Enabled{},world))
def plain_delivered(delivery:Driver.Delivery<S.plain_store(),Driver.plain_owners()>) -> Outcome:
  match delivery:
    case Driver.Rejected{failure}:Failed{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:Driver.plain_observe(~Outcome,(factory => world => owners => phases => plain_before(factory,world,owners,detached,baseline,phases)),factory,world,owners,[],"before-repeated-dumps",DTO.Observed{},[])

def transient_finished(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Reported{Report{baseline,phases,dumps}}
def transient_disabled(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):Driver.transient_observe(~Outcome,(factory => world => owners => phases => transient_finished(factory,world,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]))),factory,world,owners,phases,"after-repeated-dumps",DTO.Observed{},[])
def transient_second(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,D.Population<S.Schema,View.FullCell>>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,second):transient_disabled(factory,owners,detached,baseline,phases,[first,second],Dump.transient(App.Disabled{},world))
def transient_first(factory:W.Factory,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,first):transient_second(factory,owners,detached,baseline,phases,first,Dump.transient(App.Enabled{},world))
def transient_before(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>) -> Outcome:
  transient_first(factory,owners,detached,baseline,phases,Dump.transient(App.Enabled{},world))
def transient_delivered(delivery:Driver.Delivery<S.transient_store(),Driver.transient_owners()>) -> Outcome:
  match delivery:
    case Driver.Rejected{failure}:Failed{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:Driver.transient_observe(~Outcome,(factory => world => owners => phases => transient_before(factory,world,owners,detached,baseline,phases)),factory,world,owners,[],"before-repeated-dumps",DTO.Observed{},[])

def constructed_finished(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>) -> Outcome:
  Reported{Report{baseline,phases,dumps}}
def constructed_disabled(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,dumps:List<&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,disabled):Driver.constructed_observe(~Outcome,(factory => world => owners => phases => constructed_finished(factory,world,owners,detached,baseline,phases,List.append(&2,Maybe<&2,D.Population<S.Schema,View.FullCell>>,dumps,[disabled]))),factory,world,owners,phases,"after-repeated-dumps",DTO.Observed{},[])
def constructed_second(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,D.Population<S.Schema,View.FullCell>>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,second):constructed_disabled(factory,owners,detached,baseline,phases,[first,second],Dump.constructed(App.Disabled{},world))
def constructed_first(factory:W.Factory,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,D.Population<S.Schema,View.FullCell>>) -> Outcome:
  match got:
    case (world,first):constructed_second(factory,owners,detached,baseline,phases,first,Dump.constructed(App.Enabled{},world))
def constructed_before(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),detached:List<Maybe<&1,Array<U32>>>,baseline:DTO.ScenarioReport,phases:List<&2,DTO.Snapshot>) -> Outcome:
  constructed_first(factory,owners,detached,baseline,phases,Dump.constructed(App.Enabled{},world))
def constructed_delivered(delivery:Driver.Delivery<S.constructed_store(),Driver.constructed_owners()>) -> Outcome:
  match delivery:
    case Driver.Rejected{failure}:Failed{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:Driver.constructed_observe(~Outcome,(factory => world => owners => phases => constructed_before(factory,world,owners,detached,baseline,phases)),factory,world,owners,[],"before-repeated-dumps",DTO.Observed{},[])

type Output is Data:
  Output{plain:Outcome,transient:Outcome,constructed:Outcome}
def main() -> Output:
  Output{plain_delivered(Driver.plain()),transient_delivered(Driver.transient()),constructed_delivered(Driver.constructed())}
