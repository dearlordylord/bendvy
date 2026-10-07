import Base
import ../../../src/ecs/schedule-provision.bend as P
import ../../../src/ecs/schedule.bend as Sch
import ./spec.bend as Spec

type Schema is Data:
  Schema{}
def render(items:List<&2,P.Requirement<Schema>>) -> String:
  List.show(&2,P.Requirement<Schema>,Spec.key(~Schema),items)
def step(item:Sch.Step) -> String:
  match item:
    case Sch.System{id,condition}: "system:" ++ U32.show(id) ++ ":" ++ U32.show(condition)
    case Sch.Phase{name}: "phase:" ++ name
    case Sch.Barrier{}: "barrier"
def steps(items:List<&2,Sch.Step>) -> String:
  List.show(&2,Sch.Step,step,items)
def plan() -> P.Plan<Schema>:
  P.Sequence{P.Entry{Sch.System{1,2},[P.Service{1},P.Resource{1},P.Service{1}]},P.Sequence{P.Empty{},P.Sequence{P.Entry{Sch.Phase{"middle"},[P.Component{1},P.Resource{1}]},P.Entry{Sch.Barrier{},[P.Service{2}]}}}}
def pair(+name:String,a:String,b:String) -> String:
  name ++ "|" ++ a ++ "|" ++ b ++ "\n"
def sample(+items:List<&2,P.Requirement<Schema>>,+grants:List<&2,P.Requirement<Schema>>) -> String:
  pair("union",render(P.unique(~Schema,items)),render(Spec.union(~Schema,items))) ++ pair("missing",render(P.missing_requirements(~Schema,items,grants)),render(Spec.missing(~Schema,grants,items)))
def main() -> IO(Unit):
  IO.print(pair("flatten",steps(P.flatten(~Schema,plan())),steps(Spec.flatten_into(~Schema,plan(),[]))) ++ pair("requirements",render(P.requirements(~Schema,plan())),render(Spec.needs_into(~Schema,plan(),[]))) ++ sample([],[]) ++ sample([P.Service{1},P.Resource{1},P.Service{1},P.Component{1},P.Service{4294967295}],[]) ++ sample([P.Service{1},P.Resource{1},P.Service{1},P.Component{1}],[P.Resource{1},P.Resource{1}]) ++ sample([P.Component{0},P.Service{0},P.Resource{0}],[P.Service{0},P.Component{0},P.Resource{0}]) ++ pair("identity-cross",Bool.show(P.same(~Schema,P.Service{1},P.Resource{1})),Bool.show(Spec.equal(~Schema,P.Service{1},P.Resource{1}))))
