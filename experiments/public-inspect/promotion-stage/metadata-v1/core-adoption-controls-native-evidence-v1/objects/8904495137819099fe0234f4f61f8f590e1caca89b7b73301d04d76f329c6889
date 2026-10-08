import Base
import binding-fixtures/workshop.bend as D
import ../../../../src/ecs/inspector-metadata.bend as Meta
import ../../bend-candidate/consumer.bend as A
import ../../../../src/ecs/inspector.bend as I
import ../../../../src/ecs/world.bend as World
import ../../../../src/ecs/capabilities.bend as Cap

# Closed canonical descriptor index; Arrays/Extra are the runtime owners.
type Fields is Data:
  Fields{bonus:List<&2,U32>,bonusAlias:List<&2,U32>,score:List<&2,U32>}
def bonus(~H:Type,reads:D.Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match reads:
    case D.Reads{bonus,_,_}:bonus
def alias(~H:Type,reads:D.Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match reads:
    case D.Reads{_,alias,_}:alias
def score(~H:Type,reads:D.Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match reads:
    case D.Reads{_,_,score}:score
def with_score(~H:Type,bonus:List<&2,U32>,alias:List<&2,U32>,observed:H & List<&2,U32>) -> H & Result<&2,&2,Fields,Fields>:
  (ctx,score)=observed
  (ctx,Done{Fields{bonus,alias,score}})
def with_alias(~H:Type,~caps:D.Reads<H>,bonus:List<&2,U32>,observed:H & List<&2,U32>) -> H & Result<&2,&2,Fields,Fields>:
  (ctx,alias)=observed
  with_score(~H,bonus,alias,Cap.value_read(~H,~List<&2,U32>,~score(~H,caps),ctx))
def with_bonus(~H:Type,~caps:D.Reads<H>,observed:H & List<&2,U32>) -> H & Result<&2,&2,Fields,Fields>:
  (ctx,bonus)=observed
  with_alias(~H,~caps,bonus,Cap.value_read(~H,~List<&2,U32>,~alias(~H,caps),ctx))
def body(~H:Type,~caps:D.Reads<H>,args:Unit,ctx:H) -> H & Result<&2,&2,Fields,Fields>:
  with_bonus(~H,~caps,Cap.value_read(~H,~List<&2,U32>,~bonus(~H,caps),ctx))
type State<-descriptor:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>,-Extra:Type> is Type:
  State{left:Array<U32>,right:Array<U32>,extra:Extra}
def attach(~descriptor:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>,~Extra:Type,left:Array<U32>,right:Array<U32>,extra:Extra) -> State<descriptor,Extra>:
  State{left,right,extra}
def metadata_field(definition:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>) -> Meta.Metadata<A.Schema>:
  match definition:
    case Meta.Definition{metadata,_}:metadata
def metadata(~descriptor:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>) -> Meta.Metadata<A.Schema>:
  metadata_field(descriptor)
def plan(~descriptor:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>) -> I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>:
  Meta.into_plan(~A.Schema,~I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>,descriptor)
def read(~descriptor:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>,~Extra:Type,state:State<descriptor,Extra>) -> State<descriptor,Extra> & Meta.Metadata<A.Schema>:
  (state,metadata(~descriptor))
def invoke(~descriptor:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>,~Extra:Type,state:State<descriptor,Extra>,instance:I.Instance<A.Schema>,world:World.World<A.Schema,A.Store,D.Resources,U32>) -> State<descriptor,Extra> & I.Observed<A.Schema,A.Store,D.Resources,U32,Fields,Fields>:
  (state,I.run(~A.Schema,~A.Store,~D.Resources,~U32,~D.Ops,~Unit,~Fields,~Fields,~plan(~descriptor),~body,instance,Unit{},world))
