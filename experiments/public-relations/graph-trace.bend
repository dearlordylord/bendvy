import Base
import types.bend as T
import graph-spec.bend as S
import graph-core.bend as C

type Workshop is Data:
  Workshop{}
type Other is Data:
  Other{}
type Step<S: Data> is Data:
  Set{relation: T.Descriptor<S>,source: U32,target: U32,sourceLive: Bool,targetLive: Bool}
  Clear{relation: T.Descriptor<S>,source: U32}
def ids(xs: List<&2,U32>) -> String:
  match xs:
    case []: "[]"
    case id <> rest: U32.show(id) ++ ":" ++ ids(rest)
def maybe_id(value: Maybe<&2,U32>) -> String:
  match value:
    case None{}: "none"
    case Some{id}: U32.show(id)
def error(value: Maybe<&2,T.Error>) -> String:
  match value:
    case None{}: "ok"
    case Some{T.MissingEntity{source}}: "MissingEntity:" ++ U32.show(source)
    case Some{T.MissingTargetEntity{source,target,name}}: "MissingTarget:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ name
    case Some{T.SelfRelationNotAllowed{source,name}}: "Self:" ++ U32.show(source) ++ ":" ++ name
    case Some{T.HierarchyCycle{source,target,name}}: "Cycle:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ name
    case Some{_}: "UNEXPECTED"
def observe_spec(~Schema: Data,+g: T.SpecGraph<Schema>,+d: T.Descriptor<Schema>) -> String:
  maybe_id(S.target(~Schema,g,d,1)) ++ "," ++ maybe_id(S.target(~Schema,g,d,2)) ++ "," ++ maybe_id(S.target(~Schema,g,d,3)) ++ "|" ++ ids(S.inverse(~Schema,g,d,1)) ++ "|" ++ ids(S.inverse(~Schema,g,d,2)) ++ "|" ++ ids(S.inverse(~Schema,g,d,3))
def observe_core(~Schema: Data,+g: T.Graph<Schema>,+d: T.Descriptor<Schema>) -> String:
  maybe_id(C.target(~Schema,g,d,1)) ++ "," ++ maybe_id(C.target(~Schema,g,d,2)) ++ "," ++ maybe_id(C.target(~Schema,g,d,3)) ++ "|" ++ ids(C.inverse(~Schema,g,d,1)) ++ "|" ++ ids(C.inverse(~Schema,g,d,2)) ++ "|" ++ ids(C.inverse(~Schema,g,d,3))
def spec_step(~Schema: Data,step: Step<Schema>,g: T.SpecGraph<Schema>) -> T.SpecResult<Schema>:
  match step:
    case Set{d,s,t,sl,tl}: S.relate(~Schema,g,d,s,t,sl,tl)
    case Clear{d,s}: T.SpecResult{S.unrelate(~Schema,g,d,s),None{}}
def core_step(~Schema: Data,step: Step<Schema>,g: T.Graph<Schema>) -> T.CoreResult<Schema>:
  match step:
    case Set{d,s,t,sl,tl}: C.relate(~Schema,g,d,s,t,sl,tl)
    case Clear{d,s}: T.CoreResult{C.unrelate(~Schema,g,d,s),None{}}
def line(~Schema: Data,+a: T.SpecResult<Schema>,+b: T.CoreResult<Schema>,+d: T.Descriptor<Schema>) -> String:
  match a b:
    case T.SpecResult{+ga,ea} T.CoreResult{+gb,eb}: error(ea) ++ ";" ++ observe_spec(~Schema,ga,d) ++ "#" ++ observe_spec(~Schema,ga,T.Descriptor{2,"OtherLink","OtherLinkedBy",T.Ordinary{}}) ++ "=" ++ error(eb) ++ ";" ++ observe_core(~Schema,gb,d) ++ "#" ++ observe_core(~Schema,gb,T.Descriptor{2,"OtherLink","OtherLinkedBy",T.Ordinary{}})
def next_spec(~Schema: Data,r: T.SpecResult<Schema>) -> T.SpecGraph<Schema>:
  match r:
    case T.SpecResult{g,_}: g
def next_core(~Schema: Data,r: T.CoreResult<Schema>) -> T.Graph<Schema>:
  match r:
    case T.CoreResult{g,_}: g
def continuation(~Schema: Data,+a: T.SpecResult<Schema>,+b: T.CoreResult<Schema>,+d: T.Descriptor<Schema>,next: T.SpecGraph<Schema> -> T.Graph<Schema> -> String) -> String:
  line(~Schema,a,b,d) ++ "\n" ++ next(next_spec(~Schema,a),next_core(~Schema,b))
def trace(~Schema: Data,steps: List<&2,Step<Schema>>,a: T.SpecGraph<Schema>,b: T.Graph<Schema>,+d: T.Descriptor<Schema>) -> String:
  match steps:
    case []: "done"
    case +step <> rest: continuation(~Schema,spec_step(~Schema,step,a),core_step(~Schema,step,b),d,ga => gb => trace(~Schema,rest,ga,gb,d))
def sequence(~Schema: Data,+d: T.Descriptor<Schema>) -> List<&2,Step<Schema>>:
  [Set{d,3,1,True{},True{}},Set{d,2,1,True{},True{}},Set{d,3,1,True{},True{}},Set{d,3,2,True{},True{}},Clear{d,3},Clear{d,3},Clear{d,999},Set{d,3,1,True{},True{}},Set{d,3,2,True{},True{}},Set{d,3,1,True{},True{}},Set{d,1,2,True{},True{}},Set{d,2,1,True{},True{}},Set{d,999,998,False{},False{}},Set{d,1,999,True{},False{}},Set{d,1,1,True{},True{}},Clear{d,1},Clear{d,2},Clear{d,3},Set{d,1,2,True{},True{}},Set{d,2,3,True{},True{}},Set{d,3,1,True{},True{}},Set{T.Descriptor{2,"OtherLink","OtherLinkedBy",T.Ordinary{}},3,2,True{},True{}},Clear{T.Descriptor{2,"OtherLink","OtherLinkedBy",T.Ordinary{}},3}]
def run(~Schema: Data,+kind: T.RelationKind) -> String:
  trace(~Schema,sequence(~Schema,T.Descriptor{1,"Link","LinkedBy",kind}),T.SpecGraph{[]},T.Graph{[],[]},T.Descriptor{1,"Link","LinkedBy",kind})
def main() -> IO(Unit):
  IO.print(run(~Workshop,T.Ordinary{}) ++ "\n" ++ run(~Workshop,T.Hierarchy{}) ++ "\n" ++ run(~Other,T.Ordinary{}) ++ "\n" ++ run(~Other,T.Hierarchy{}))
