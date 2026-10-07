import Base
import ../../../src/ecs/schedule-provision.bend as P
import ../../../src/ecs/schedule.bend as Sch

# Independent specifications: identity encoded as disjoint category + decimal ID;
# right-fold first-occurrence union; suffix traversal; grants-first subtraction.
def key(~S:Data,item:P.Requirement<S>) -> String:
  match item:
    case P.Component{id}: "component:" ++ U32.show(id)
    case P.Resource{id}: "resource:" ++ U32.show(id)
    case P.Service{id}: "service:" ++ U32.show(id)
def equal(~S:Data,a:P.Requirement<S>,b:P.Requirement<S>) -> Bool:
  String.eq(key(~S,a),key(~S,b))
def keep(~S:Data,same:Bool,+head:P.Requirement<S>,tail:List<&2,P.Requirement<S>>) -> List<&2,P.Requirement<S>>:
  match same:
    case True{}: tail
    case False{}: head <> tail
def remove(~S:Data,items:List<&2,P.Requirement<S>>,+item:P.Requirement<S>) -> List<&2,P.Requirement<S>>:
  match items:
    case []: []
    case +head <> rest: keep(~S,equal(~S,head,item),head,remove(~S,rest,item))
def union(~S:Data,items:List<&2,P.Requirement<S>>) -> List<&2,P.Requirement<S>>:
  match items:
    case []: []
    case +head <> rest: head <> remove(~S,union(~S,rest),head)
def flatten_into(~S:Data,plan:P.Plan<S>,tail:List<&2,Sch.Step>) -> List<&2,Sch.Step>:
  match plan:
    case P.Empty{}: tail
    case P.Entry{step,_}: step <> tail
    case P.Sequence{left,right}: flatten_into(~S,left,flatten_into(~S,right,tail))
def needs_into(~S:Data,plan:P.Plan<S>,tail:List<&2,P.Requirement<S>>) -> List<&2,P.Requirement<S>>:
  match plan:
    case P.Empty{}: tail
    case P.Entry{_,needs}: List.append(&2,P.Requirement<S>,needs,tail)
    case P.Sequence{left,right}: needs_into(~S,left,needs_into(~S,right,tail))
def missing(~S:Data,grants:List<&2,P.Requirement<S>>,needs:List<&2,P.Requirement<S>>) -> List<&2,P.Requirement<S>>:
  match grants:
    case []: needs
    case grant <> rest: missing(~S,rest,remove(~S,needs,grant))
