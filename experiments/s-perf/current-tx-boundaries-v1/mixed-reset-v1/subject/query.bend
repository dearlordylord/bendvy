import Base
import schema.bend as S
import sampler.bend as Sampler
import ../private/src/ecs/query-contract.bend as Contract
import ../private/src/ecs/ordinary-query-declaration.bend as Declaration
import ../private/src/ecs/ordinary-system.bend as Ordinary
import ../private/src/ecs/compose.bend as Q
import ../private/src/ecs/capabilities.bend as Cap
import ../private/src/ecs/world.bend as W

def Ops(H:Type) -> Type:Cap.Read<H,List<&2,U32>>
def declaration() -> Declaration.Declaration<S.Schema,Q.Frame<S.Schema,S.Store(),Array<U32>,U32>,Ops(Q.Frame<S.Schema,S.Store(),Array<U32>,U32>)>:Declaration.read(~S.Schema,~Array<U32>,~S.Store(),~Array<U32>,~U32,~Unit,~List<&2,U32>,~S.Token,~S.identity(),~S.project,~S.take,~S.put)
def plan() -> Q.Plan<S.Schema,S.Store(),Array<U32>,U32,Ops>:Ordinary.plan_parts(~S.Schema,~S.Store(),~Array<U32>,~U32,~Ops,declaration())
def scan(world:S.World()) -> Contract.Scanned<S.Schema,S.Store(),Array<U32>,U32>:Contract.scan(~S.Schema,~S.Store(),~Array<U32>,~U32,~Ops,~plan(),world,0)
