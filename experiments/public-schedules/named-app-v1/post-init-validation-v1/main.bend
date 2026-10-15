import Base
import ./fixture.bend as F
import ./observer.bend as O
import ./owners.bend as D
import ../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../src/ecs/reader-parameter.bend as RP

def rejected_observed(before:String,access:List<&2,String>,observed:F.context_type() & String) -> String:
  match observed:
    case (_,after):"{\"before\":"++before++",\"status\":\"rejected-after-initialize\",\"returnedAccess\":"++O.strings(access)++",\"returnedDeclaration\":null,\"after\":"++after++"}"

def result(before:String,defined:F.definition_type()) -> String:
  match defined:
    case Ordinary.DefinitionRejected{context,parameter,declaration}:
      match parameter declaration:
        case RP.Param{access} Unit{}:
          rejected_observed(before,access,O.context(context))
    case Ordinary.DefinitionRegistered{_,_}:"unexpected-registered"
    case Ordinary.DefinitionDisposalRejected{_,_,_}:"unexpected-compensation-refusal"
def before(observed:F.context_type() & String) -> String:
  match observed:
    case (context,text):result(text,F.define_all(context,"invalid-initialized"))
def ready(setup:F.Setup) -> String:
  match setup:
    case F.Ready{context,_}:before(O.context(context))
    case F.SetupFailed{}:"setup-failed"
def main() -> IO(Unit):
  IO.print(ready(F.setup()))
