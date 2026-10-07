import Base
import feature.bend as F
import core-feature.bend as Core
import combat-feature.bend as Combat
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/schedule-provision.bend as P
import ../../src/ecs/schedule.bend as Sch
type Schema is Data:
  Schema{}
def tail(trace:List<&2,String>,owners:F.Pack<Core.Owner,Unit>) -> List<&2,String> & F.Output<Schema,F.Pack<Core.Owner,Unit>>:
  F.build_head(~Schema,~List<&2,String>,~Core.Owner,~Unit,~Core.Owner,~Unit,~Core.build(~Schema),~F.build_empty(~Schema,~List<&2,String>),trace,owners)
def build(owners:F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>) -> List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>>:
  F.build_head(~Schema,~List<&2,String>,~Combat.Owner,~F.Pack<Core.Owner,Unit>,~Combat.Owner,~F.Pack<Core.Owner,Unit>,~Combat.build(~Schema),~tail,[],owners)
def owners() -> F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>:
  F.Pack{Combat.Owner{ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{41},ALeaf{42}},[ANode{ALeaf{51},ALeaf{52}}]},F.Pack{Core.Owner{ANode{ALeaf{11},ALeaf{12}},Core.Tag{}},Unit{}}}
def selected() -> F.Tree<Schema>:
  F.Sequence{Combat.definition(~Schema),F.Sequence{Core.definition(~Schema),F.Feature{"Empty",[],F.Empty{}}}}
def cells(owner:Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,U32,cells(left),cells(right))
def array_text(owner:Array<U32>) -> String:
  List.show(&2,U32,U32.show,cells(owner))
def owner_text(owners:F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>) -> String:
  match owners:
    case F.Pack{Combat.Owner{front,back,queued},F.Pack{Core.Owner{core,Core.Tag{}},Unit{}}}: array_text(front) ++ "/" ++ array_text(back) ++ "/" ++ List.show(&1,Array<U32>,array_text,queued) ++ "/" ++ array_text(core) ++ "/tag"
def step_text(step:Sch.Step) -> String:
  match step:
    case Sch.Phase{name}: name
    case Sch.System{id,condition}: "system:" ++ U32.show(id) ++ ":" ++ U32.show(condition)
    case Sch.Barrier{}: "barrier"
def requirement_text(item:P.Requirement<Schema>) -> String:
  match item:
    case P.Component{id}: "component:" ++ U32.show(id)
    case P.Resource{id}: "resource:" ++ U32.show(id)
    case P.Service{id}: "service:" ++ U32.show(id)
def identity(text:String) -> String:
  text
def entry_text(entry:SF.Entry<Schema>) -> String:
  match entry:
    case SF.Entry{_,key,name}: key ++ ":" ++ name
def error_text(error:F.Error) -> String:
  match error:
    case F.DuplicateFeature{name}: "Duplicate feature name: " ++ name
    case F.MissingDependency{name}: "Missing required feature: " ++ name
    case F.SchemaConflict{error}: "schema-conflict"
def output_text(result:List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>>) -> String:
  match result:
    case (+trace,F.Output{owners,+bootstrap,+update}): "trace=" ++ List.show(&2,String,identity,trace) ++ "|owners=" ++ owner_text(owners) ++ "|bootstrap=" ++ List.show(&2,Sch.Step,step_text,P.flatten(~Schema,bootstrap)) ++ "|update=" ++ List.show(&2,Sch.Step,step_text,P.flatten(~Schema,update)) ++ "|requirements=" ++ List.show(&2,P.Requirement<Schema>,requirement_text,P.requirements(~Schema,P.Sequence{bootstrap,update}))
def observed(result:F.Composition<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>,List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>>>) -> String:
  match result:
    case F.Built{output}: output_text(output)
    case F.Rejected{error,owners}: "error=" ++ error_text(error) ++ "|trace=[]|owners=" ++ owner_text(owners)
def run(tree:F.Tree<Schema>) -> String:
  observed(F.compose(~Schema,~F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>,~(List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>>),~build,tree,owners()))
def retry(result:F.Composition<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>,List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>>>) -> String:
  match result:
    case F.Rejected{error,owners}: observed(F.compose(~Schema,~F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>,~(List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>>),~build,selected(),owners))
    case F.Built{output}: "UNEXPECTED_BUILT"
def main() -> IO(Unit):
  IO.print("selected=" ++ run(selected()) ++ "\nduplicate=" ++ run(F.Sequence{Core.definition(~Schema),Core.definition(~Schema)}) ++ "\nmissing=" ++ run(Combat.definition(~Schema)) ++ "\npriority=" ++ run(F.Sequence{Combat.definition(~Schema),Combat.definition(~Schema)}) ++ "\nvisibility=" ++ List.show(&2,SF.Entry<Schema>,entry_text,F.visibility(~Schema,Combat.definition(~Schema))) ++ "\nretry=" ++ retry(F.compose(~Schema,~F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>,~(List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,Unit>>>),~build,Combat.definition(~Schema),owners())))
