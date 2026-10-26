import Base
import ./world.bend as W
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./execution-system.bend as Sys

type Application<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-Local:Type,-Error:Data,-Out:Data,-declaration:Build.Program(~S,~C,~R,~Ops),-body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>)> is Type:
  Application{world:W.World<S,C,R,E>,system:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>}
type Built<-App:Type,-World:Type,-Local:Type> is Type:
  Built{application:App}
  BuildRefused{world:World,local:Local}
type Status<Error:Data,Out:Data> is Data:
  Ran{completion:Sys.Completion<Error,Out>}
  AdmissionRefused{}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),result:Sys.Defined<W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>) -> Built<Application<S,C,R,E,Ops,Local,Error,Out,declaration,body>,W.World<S,C,R,E>,Local>:
  match result:
    case Sys.Defined{world,system}:Built{Application{world,system}}
    case Sys.DefinitionRefused{world,local}:BuildRefused{world,local}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),world:W.World<S,C,R,E>,name:String,local:Local) -> Built<Application<S,C,R,E,Ops,Local,Error,Out,declaration,body>,W.World<S,C,R,E>,Local>:
  registered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Sys.define(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,world,name,local))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),result:Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>) -> Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Status<Error,Out>:
  match result:
    case Sys.Executed{world,system,completion}:(Application{world,system},Ran{completion})
    case Sys.Refused{world,system}:(Application{world,system},AdmissionRefused{})
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),application:Application<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Status<Error,Out>:
  match application:
    case Application{world,system}:returned(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Sys.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,system,world))
