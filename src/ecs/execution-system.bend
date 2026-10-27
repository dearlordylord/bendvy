import Base
import ./world.bend as W
import ./change-tick.bend as Tick
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-driver.bend as Driver
import ./execution-reservation-permit.bend as RuntimePermit

type Completion<Error:Data,Out:Data> is Data:
  Success{output:Out}
  BodyError{error:Error,output:Out}
def Body(~S:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data) -> Type:
  @-Permit:Data -> @-H:Type -> @-caps:Ops(Permit,H) -> H -> Local -> Effect.Task<S,Permit,H & (Local & Completion<Error,Out>)>
def map(-S:Data,-Permit:Data,-R:Type,-Out:Type,task:Effect.Task<S,Permit,R>,next:R -> Out) -> Effect.Task<S,Permit,Out>:
  Effect.bind(S,Permit,R,Out,task,value => Effect.TDone{next(value)})
type Owner<-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-declaration:Build.Program(~S,~WC,~C,~R,~Ops),-body:Body(~S,~Ops,~Local,~Error,~Out)> is Type:
  Owner{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,local:Local}
type Defined<-World:Type,-System:Type,-Local:Type> is Type:
  Defined{world:World,system:System}
  DefinitionRefused{world:World,local:Local}
type RunResult<-World:Type,-System:Type,Error:Data,Out:Data> is Type:
  Executed{world:World,system:System,completion:Completion<Error,Out>}
  Refused{world:World,system:System}

def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),namespace:U32,name:String,access:List<&2,String>,local:Local,result:W.World<S,C,R,E> & W.Registration) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,W.RegistrationRejected{_}):DefinitionRefused{world,local}
    case (world,W.Registered{id}):Defined{world,Owner{namespace,id,name,access,None{},local}}
def named_compilation(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),+name:String,local:Local,world:W.World<S,C,R,E>,namespace:U32,compilation:D.Compilation<S,C,C,R,Ops>) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match compilation:
    case D.Unsupported{_,_,_}:DefinitionRefused{world,local}
    case D.Supported{D.Declaration{_,access},_}:
      +keys = D.keys(access)
      registered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,name,keys,local,W.register(~S,~C,~R,~E,world,name,keys))
def named(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),+name:String,local:Local,result:W.World<S,C,R,E> & U32) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,namespace):named_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,name,local,world,namespace,Build.compile(~S,~C,~C,~R,~Ops,~declaration))

def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),world:W.World<S,C,R,E>,name:String,local:Local) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  named(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,name,local,W.namespace(~S,~C,~R,~E,world))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),admin:State.Administration<S,C,R,E>,namespace:U32,id:U32,name:String,access:List<&2,String>,+tick:Tick.Tick,result:State.Scope<S,C,R> & (Local & Completion<Error,Out>)) -> RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match result:
    case (scope,(local,completion)):Executed{W.leave_run(~S,~C,~R,~E,State.reassemble(~S,~C,~R,~E,admin,scope)),Owner{namespace,id,name,access,Some{tick},local},completion}

def driven(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),namespace:U32,id:U32,name:String,access:List<&2,String>,tick:Tick.Tick,result:State.Administration<S,C,R,E> & (State.Scope<S,C,R> & (Local & Completion<Error,Out>))) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match result:
    case (admin,result):IO.pure(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,returned(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,admin,namespace,id,name,access,tick,result))
def separated_compilation(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),+namespace:U32,+id:U32,name:String,access:List<&2,String>,prior:Maybe<&2,Tick.Tick>,local:Local,+tick:Tick.Tick,admin:State.Administration<S,C,R,E>,scope:State.Scope<S,C,R>,compilation:D.Compilation<S,C,C,R,Ops>) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match compilation:
    case D.Unsupported{_,_,_}:IO.pure(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Refused{State.reassemble(~S,~C,~R,~E,admin,scope),Owner{namespace,id,name,access,prior,local}})
    case D.Supported{D.Declaration{_,_},_}:IO.bind(State.Administration<S,C,R,E> & (State.Scope<S,C,R> & (Local & Completion<Error,Out>)),RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Driver.run(~S,~C,~R,~E,~(State.Scope<S,C,R> & (Local & Completion<Error,Out>)),[id],admin,Effect.map_permit(~S,~Effect.Granted,~RuntimePermit.Permit,~(State.Scope<S,C,R> & (Local & Completion<Error,Out>)),~RuntimePermit.Context,~RuntimePermit.qualify,RuntimePermit.Context{namespace,id,RuntimePermit.NoStructural{}},body(Effect.Granted,State.Scope<S,C,R>,compiledCaps,State.window(~S,~C,~R,scope,prior),local))),result => driven(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,id,name,access,tick,result))
def separated(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),namespace:U32,id:U32,name:String,access:List<&2,String>,prior:Maybe<&2,Tick.Tick>,local:Local,+tick:Tick.Tick,result:State.Administration<S,C,R,E> & State.Scope<S,C,R>) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match result:
    case (admin,scope):separated_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~D.trusted_construction_caps(~S,~C,~C,~R,~Ops,Build.compile(~S,~C,~C,~R,~Ops,~declaration)),namespace,id,name,access,prior,local,tick,admin,scope,Build.compile(~S,~C,~C,~R,~Ops,~declaration))

def entered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),namespace:U32,id:U32,name:String,access:List<&2,String>,prior:Maybe<&2,Tick.Tick>,local:Local,result:W.World<S,C,R,E> & Tick.Tick) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match result:
    case (world,+tick):separated(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,id,name,access,prior,local,tick,State.separate(~S,~C,~R,~E,world,tick))
def allowed(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),allowed:Bool,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match allowed system:
    case False{} system:IO.pure(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Refused{world,system})
    case True{} Owner{namespace,id,name,access,prior,local}:entered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,id,name,access,prior,local,W.enter_run(~S,~C,~R,~E,world))
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,result:W.World<S,C,R,E> & Bool) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match result:
    case (world,ok):allowed(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Bool.and(ok,D.compilation_supported(~S,~C,~C,~R,~Ops,Build.compile(~S,~C,~C,~R,~Ops,~declaration))),system,world)
def namespace_checked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),allowed:Bool,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match allowed system:
    case False{} system:IO.pure(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Refused{world,system})
    case True{} Owner{+namespace,+id,+name,+access,cursor,local}:checked(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Owner{namespace,id,name,access,cursor,local},W.registration_matches(~S,~C,~R,~E,world,id,name,access))
def observed_namespace(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),+systemNamespace:U32,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,result:W.World<S,C,R,E> & U32) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match result:
    case (world,actual):namespace_checked(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,U32.is_eq(systemNamespace,actual),system,world)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> IO(RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>):
  match system:
    case Owner{+namespace,id,name,access,cursor,local}:observed_namespace(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,Owner{namespace,id,name,access,cursor,local},W.namespace(~S,~C,~R,~E,world))

def metadata(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),system:Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & W.RegistrationMeta:
  match system:
    case Owner{+namespace,+id,+name,+access,cursor,local}:(Owner{namespace,id,name,access,cursor,local},W.RegistrationMeta{id,name,access})
