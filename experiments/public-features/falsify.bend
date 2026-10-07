import Base
import feature.bend as F
import spec.bend as Spec
import recipe-app.bend as A
import core-feature.bend as Core
import combat-feature.bend as Combat
import ../../src/ecs/schema-fragments.bend as SF
def pair(name:String,a:String,b:String) -> String:
  name ++ "|" ++ a ++ "|" ++ b ++ "\n"
def sample(+tree:F.Tree<A.Schema>) -> String:
  pair("names",List.show(&2,String,A.identity,F.names(~A.Schema,tree)),List.show(&2,String,A.identity,Spec.names_into(~A.Schema,tree,[]))) ++ pair("visibility",List.show(&2,SF.Entry<A.Schema>,A.entry_text,F.visibility(~A.Schema,tree)),List.show(&2,SF.Entry<A.Schema>,A.entry_text,Spec.visibility_into(~A.Schema,tree,[])))
def validation(result:F.Validation) -> String:
  match result:
    case F.Valid{}: "valid"
    case F.Invalid{error}: A.error_text(error)
def main() -> IO(Unit):
  IO.print(sample(F.Empty{}) ++ sample(F.Sequence{Combat.definition(~A.Schema),Core.definition(~A.Schema)}) ++ sample(F.Feature{"Addon",[SF.Entry{SF.Component{},"addon","addon"}],Combat.definition(~A.Schema)}) ++ pair("duplicate-priority",validation(F.validate(~A.Schema,F.Sequence{Combat.definition(~A.Schema),Combat.definition(~A.Schema)})),"Duplicate feature name: Combat") ++ pair("missing-priority",validation(F.validate(~A.Schema,F.Feature{"Combat",[SF.Entry{SF.Component{},"x","x"},SF.Entry{SF.Component{},"x","x"}],Core.definition(~A.Schema)})),"Missing required feature: Core"))
