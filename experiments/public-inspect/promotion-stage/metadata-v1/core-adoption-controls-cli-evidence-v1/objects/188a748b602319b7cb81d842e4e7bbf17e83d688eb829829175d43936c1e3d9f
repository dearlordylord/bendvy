import Base
import ../../../../../src/ecs/inspector-declaration.bend as Bind
import ../../../../../src/ecs/inspector-metadata.bend as Meta
import ../../../bend-candidate/consumer.bend as A
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/capabilities.bend as Cap

# Canonical declarations exported by this trusted nominal schema fixture.
type ScoreToken is Data:
  ScoreToken{}
type BonusToken is Data:
  BonusToken{}
type Resources is Type:
  Resources{score:A.Resource,bonus:A.Resource}
def score_join(bonus:A.Resource,observed:A.Resource & List<&2,U32>) -> Resources & List<&2,U32>:
  (score,values)=observed
  (Resources{score,bonus},values)
def bonus_join(score:A.Resource,observed:A.Resource & List<&2,U32>) -> Resources & List<&2,U32>:
  (bonus,values)=observed
  (Resources{score,bonus},values)
def project_score(owner:Resources) -> Resources & List<&2,U32>:
  match owner:
    case Resources{score,bonus}:score_join(bonus,A.project_resource(score))
def project_bonus(owner:Resources) -> Resources & List<&2,U32>:
  match owner:
    case Resources{score,bonus}:bonus_join(score,A.project_resource(bonus))
def score() -> Bind.Declaration<A.Schema,Resources,List<&2,U32>,ScoreToken,project_score>:
  Bind.canonical(~A.Schema,~Resources,~List<&2,U32>,~ScoreToken,~project_score,1,"Workshop/Score")
def bonus() -> Bind.Declaration<A.Schema,Resources,List<&2,U32>,BonusToken,project_bonus>:
  Bind.canonical(~A.Schema,~Resources,~List<&2,U32>,~BonusToken,~project_bonus,2,"Workshop/Bonus")
type Reads<-H:Type> is Type:
  Reads{bonus:Cap.ValueRead<H,List<&2,U32>>,bonusAlias:Cap.ValueRead<H,List<&2,U32>>,score:Cap.ValueRead<H,List<&2,U32>>}
def Ops(H:Type) -> Type:
  Reads<H>
# Constructor consumes actual BoundRead fields in the SAME declaration order;
# it accepts no independently supplied requirements or alternative lenses.
def finish(name:String,bonus:Meta.Resource<A.Schema> & Cap.ValueRead<I.Frame<A.Schema,A.Store,Resources,U32>,List<&2,U32>>,alias:Meta.Resource<A.Schema> & Cap.ValueRead<I.Frame<A.Schema,A.Store,Resources,U32>,List<&2,U32>>,score:Meta.Resource<A.Schema> & Cap.ValueRead<I.Frame<A.Schema,A.Store,Resources,U32>,List<&2,U32>>) -> Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,Resources,U32,Ops>>:
  (bonusMeta,bonusRead)=bonus
  (aliasMeta,aliasRead)=alias
  (scoreMeta,scoreRead)=score
  Meta.make(~A.Schema,~I.Plan<A.Schema,A.Store,Resources,U32,Ops>,name,[scoreMeta,aliasMeta,bonusMeta],I.Plan{Reads{bonusRead,aliasRead,scoreRead}})
def define(name:String,+bonus:Bind.Declaration<A.Schema,Resources,List<&2,U32>,BonusToken,project_bonus>,score:Bind.Declaration<A.Schema,Resources,List<&2,U32>,ScoreToken,project_score>) -> Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,Resources,U32,Ops>>:
  finish(name,Bind.split(~A.Schema,~I.Frame<A.Schema,A.Store,Resources,U32>,~List<&2,U32>,Bind.bind(~A.Schema,~A.Store,~Resources,~U32,~List<&2,U32>,~BonusToken,~project_bonus,bonus)),Bind.split(~A.Schema,~I.Frame<A.Schema,A.Store,Resources,U32>,~List<&2,U32>,Bind.bind(~A.Schema,~A.Store,~Resources,~U32,~List<&2,U32>,~BonusToken,~project_bonus,bonus)),Bind.split(~A.Schema,~I.Frame<A.Schema,A.Store,Resources,U32>,~List<&2,U32>,Bind.bind(~A.Schema,~A.Store,~Resources,~U32,~List<&2,U32>,~ScoreToken,~project_score,score)))
def canonical_definition() -> Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,Resources,U32,Ops>>:
  define("Workshop/BoundMetadata",bonus(),score())
