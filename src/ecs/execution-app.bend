import Base
import ./world.bend as W
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./execution-system.bend as Sys

type Application<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),-body:Sys.Body(~S,~Ops,~Local,~Error,~Out)> is Type:
  Application{world:W.World<S,C,R,E>,system:Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>}
type Built<-App:Type,-World:Type,-Local:Type> is Type:
  Built{application:App}
  BuildRefused{world:World,local:Local}
type Status<Error:Data,Out:Data> is Data:
  Ran{completion:Sys.Completion<Error,Out>}
  AdmissionRefused{}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),result:Sys.Defined<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>) -> Built<Application<S,C,R,E,Ops,Local,Error,Out,declaration,body>,W.World<S,C,R,E>,Local>:
  match result:
    case Sys.Defined{world,system}:Built{Application{world,system}}
    case Sys.DefinitionRefused{world,local}:BuildRefused{world,local}
def define_framework(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),world:W.World<S,C,R,E>,name:String,local:Local) -> Built<Application<S,C,R,E,Ops,Local,Error,Out,declaration,body>,W.World<S,C,R,E>,Local>:
  registered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Sys.define_framework(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,world,name,local))
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),world:W.World<S,C,R,E>,name:String,local:Local) -> Built<Application<S,C,R,E,Ops,Local,Error,Out,Build.framework_program(~S,~C,~C,~R,~Ops,~declaration),body>,W.World<S,C,R,E>,Local>:
  define_framework(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~Build.framework_program(~S,~C,~C,~R,~Ops,~declaration),~body,world,name,local)
# Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60 runs the App schedule before
# clear_trackers: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L150-L159
# This App boundary rotates after actual completion, including returned errors;
# admission refusal retains history. Bare system runs do not rotate.
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),result:Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>) -> Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Status<Error,Out>:
  match result:
    case Sys.Executed{world,system,completion}:(Application{W.maintain_lifecycle(~S,~C,~R,~E,world),system},Ran{completion})
    case Sys.Refused{world,system}:(Application{world,system},AdmissionRefused{})
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),application:Application<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> IO(Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Status<Error,Out>):
  match application:
    case Application{world,system}:IO.bind(Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Status<Error,Out>,Sys.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,system,world),result => IO.pure(Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Status<Error,Out>,returned(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,result)))
