import Base
import ./normal-values.bend as Game
import ./canonical-schema.bend as Schema
import ./schema-validation.bend as Validation
import ./normal-snapshot.bend as Snapshot
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
# Actual adopted kind-local duplicate policy; both arbitrary affine inputs survive.
def layout() -> Schema.Layout<Game.GameSchema,Array<U32>,Game.Clock>:
  Schema.schema(~Game.GameSchema,~Array<U32>,~Game.Clock,"settings","settings")
type Observation is Data:
  Observation{error:Fragment.Error,left:String,right:String}
type Observed is Type:
  Rejected{left:Array<U32>,right:Game.Clock,observation:Observation}
  UnexpectedReady{owner:Schema.Owner<Game.GameSchema,Array<U32>,Game.Clock,layout()>}
def right(error:Fragment.Error,left:Array<U32>,leftText:String,observed:Array<U32> & String) -> Observed:
  match observed:
    case (owner,rightText):Rejected{left,Game.Clock{owner},Observation{error,leftText,rightText}}
def left(error:Fragment.Error,rightOwner:Array<U32>,observed:Array<U32> & String) -> Observed:
  match observed:
    case (owner,leftText):right(error,owner,leftText,Snapshot.array(~U32,~U32.show,rightOwner))
def result(checked:Validation.Bootstrapped<Game.GameSchema,Array<U32>,Game.Clock,layout()>) -> Observed:
  match checked:
    case Validation.Ready{owner}:UnexpectedReady{owner}
    case Validation.Rejected{error,settings,Game.Clock{clock}}:left(error,clock,Snapshot.array(~U32,~U32.show,settings))
def run(settings:Array<U32>,clock:Game.Clock) -> Observed:
  result(Validation.bootstrap(~Game.GameSchema,~Array<U32>,~Game.Clock,~layout(),settings,clock))
