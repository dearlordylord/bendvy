import Base
import ./world.bend as W
import ./change-tick.bend as Tick
import ./execution-state.bend as State
import ./execution-declaration.bend as D

type Completion<Error:Data,Out:Data> is Data:
  Success{output:Out}
  BodyError{error:Error,output:Out}
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-Local:Type,-Error:Data,-Out:Data,-declaration:D.Declaration<S,C,R,Ops>,-body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>)> is Type:
  Owner{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,local:Local}
type Defined<-World:Type,-System:Type,-Local:Type> is Type:
  Defined{world:World,system:System}
  DefinitionRefused{world:World,local:Local}
type RunResult<-World:Type,-System:Type,Error:Data,Out:Data> is Type:
  Executed{world:World,system:System,completion:Completion<Error,Out>}
  Refused{world:World,system:System}

def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),namespace:U32,name:String,access:List<&2,String>,local:Local,result:W.World<S,C,R,E> & W.Registration) -> Defined<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,W.RegistrationRejected{_}):DefinitionRefused{world,local}
    case (world,W.Registered{id}):Defined{world,Owner{namespace,id,name,access,None{},local}}
def named(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),+name:String,local:Local,result:W.World<S,C,R,E> & U32) -> Defined<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,namespace):registered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,name,D.access(~S,~C,~R,~Ops,declaration),local,W.register(~S,~C,~R,~E,world,name,D.access(~S,~C,~R,~Ops,declaration)))
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),world:W.World<S,C,R,E>,name:String,local:Local) -> Defined<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  named(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,name,local,W.namespace(~S,~C,~R,~E,world))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),admin:State.Administration<S,C,R,E>,namespace:U32,id:U32,name:String,access:List<&2,String>,+tick:Tick.Tick,result:State.Scope<S,C,R> & (Local & Completion<Error,Out>)) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match result:
    case (scope,(local,completion)):Executed{W.leave_run(~S,~C,~R,~E,State.reassemble(~S,~C,~R,~E,admin,scope)),Owner{namespace,id,name,access,Some{tick},local},completion}
def separated(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),namespace:U32,id:U32,name:String,access:List<&2,String>,local:Local,+tick:Tick.Tick,result:State.Administration<S,C,R,E> & State.Scope<S,C,R>) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match result:
    case (admin,scope):returned(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,admin,namespace,id,name,access,tick,body(State.Scope<S,C,R>,D.grants(~S,~C,~R,~Ops,declaration),scope,local))
def entered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),namespace:U32,id:U32,name:String,access:List<&2,String>,local:Local,result:W.World<S,C,R,E> & Tick.Tick) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match result:
    case (world,+tick):separated(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,id,name,access,local,tick,State.separate(~S,~C,~R,~E,world,tick))
def allowed(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),allowed:Bool,system:Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match allowed system:
    case False{} system:Refused{world,system}
    case True{} Owner{namespace,id,name,access,_,local}:entered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,id,name,access,local,W.enter_run(~S,~C,~R,~E,world))
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),system:Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,result:W.World<S,C,R,E> & Bool) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match result:
    case (world,ok):allowed(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,ok,system,world)
def namespace_checked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),allowed:Bool,system:Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match allowed system:
    case False{} system:Refused{world,system}
    case True{} Owner{+namespace,+id,+name,+access,cursor,local}:checked(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Owner{namespace,id,name,access,cursor,local},W.registration_matches(~S,~C,~R,~E,world,id,name,access))
def observed_namespace(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),+systemNamespace:U32,system:Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,result:W.World<S,C,R,E> & U32) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match result:
    case (world,actual):namespace_checked(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,U32.is_eq(systemNamespace,actual),system,world)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),system:Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> RunResult<W.World<S,C,R,E>,Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match system:
    case Owner{+namespace,id,name,access,cursor,local}:observed_namespace(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,Owner{namespace,id,name,access,cursor,local},W.namespace(~S,~C,~R,~E,world))

def metadata(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:D.Declaration<S,C,R,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Completion<Error,Out>),system:Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & W.RegistrationMeta:
  match system:
    case Owner{+namespace,+id,+name,+access,cursor,local}:(Owner{namespace,id,name,access,cursor,local},W.RegistrationMeta{id,name,access})
