import Base
import feature.bend as F
import core-feature.bend as Core
import combat-feature.bend as Combat
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/schedule-provision.bend as P
import ../../src/ecs/schedule.bend as Sch
type Schema is Data:
  Schema{}
def empty_feature() -> F.Feature<Schema,List<&2,String>,Unit,Unit>:
  F.FeatureOwner{F.Definition{"Empty",[],F.Empty{}},Unit{},F.build_empty(~Schema,~List<&2,String>)}
def recipe(head:F.Definition<Schema>,tail:F.Definition<Schema>) -> F.Recipe<Schema,List<&2,String>,F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>>:
  F.prepend(~Schema,~List<&2,String>,~Combat.Owner,~F.Pack<Core.Owner,F.Pack<Unit,Unit>>,~Combat.Owner,~F.Pack<Core.Owner,F.Pack<Unit,Unit>>,F.FeatureOwner{head,Combat.Owner{ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{41},ALeaf{42}},[ANode{ALeaf{51},ALeaf{52}}]},Combat.build(~Schema)},F.prepend(~Schema,~List<&2,String>,~Core.Owner,~F.Pack<Unit,Unit>,~Core.Owner,~F.Pack<Unit,Unit>,F.FeatureOwner{tail,Core.Owner{ANode{ALeaf{11},ALeaf{12}},Core.Tag{}},Core.build(~Schema)},F.prepend(~Schema,~List<&2,String>,~Unit,~Unit,~Unit,~Unit,empty_feature(),F.recipe_empty(~Schema,~List<&2,String>))))
def cells(owner:Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,U32,cells(left),cells(right))
def array_text(owner:Array<U32>) -> String:
  List.show(&2,U32,U32.show,cells(owner))
def owner_text(owners:F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>) -> String:
  match owners:
    case F.Pack{Combat.Owner{front,back,queued},F.Pack{Core.Owner{core,Core.Tag{}},F.Pack{Unit{},Unit{}}}}: array_text(front) ++ "/" ++ array_text(back) ++ "/" ++ List.show(&1,Array<U32>,array_text,queued) ++ "/" ++ array_text(core) ++ "/tag"
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
def output_text(result:List<&2,String> & F.Output<Schema,F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>>) -> String:
  match result:
    case (+trace,F.Output{owners,+bootstrap,+update}): "trace=" ++ List.show(&2,String,identity,trace) ++ "|owners=" ++ owner_text(owners) ++ "|bootstrap=" ++ List.show(&2,Sch.Step,step_text,P.flatten(~Schema,bootstrap)) ++ "|update=" ++ List.show(&2,Sch.Step,step_text,P.flatten(~Schema,update)) ++ "|requirements=" ++ List.show(&2,P.Requirement<Schema>,requirement_text,P.requirements(~Schema,P.Sequence{bootstrap,update}))
def observed(result:F.RecipeResult<Schema,List<&2,String>,F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>>) -> String:
  match result:
    case F.Completed{trace,output}: output_text((trace,output))
    case F.Refused{error,trace,F.Recipe{tree,owners,build}}: "error=" ++ error_text(error) ++ "|trace=" ++ List.show(&2,String,identity,trace) ++ "|owners=" ++ owner_text(owners)
def run(head:F.Definition<Schema>,tail:F.Definition<Schema>) -> String:
  observed(F.run_recipe(~Schema,~List<&2,String>,~F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Owner,F.Pack<Core.Owner,F.Pack<Unit,Unit>>>,[],recipe(head,tail)))
def main() -> IO(Unit):
  IO.print("selected=" ++ run(Combat.declaration(~Schema),Core.declaration(~Schema)) ++ "\nduplicate=" ++ run(Core.declaration(~Schema),Core.declaration(~Schema)) ++ "\nmissing=" ++ run(Combat.declaration(~Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\npriority=" ++ run(Combat.declaration(~Schema),Combat.declaration(~Schema)) ++ "\nvisibility=" ++ List.show(&2,SF.Entry<Schema>,entry_text,F.visibility(~Schema,Combat.definition(~Schema))))
