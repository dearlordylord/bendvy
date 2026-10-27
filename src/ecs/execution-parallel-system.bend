import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./change-tick.bend as Tick

type Meta<-Owner:Type> is Data:
  Meta{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>}
def detached(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>> & Local:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,local}:(Meta{namespace,id,name,access,cursor},local)
def restored(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),meta:Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local) -> Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>:
  match meta:
    case Meta{namespace,id,name,access,cursor}:Sys.Owner{namespace,id,name,access,cursor,local}
def completed_meta(~Owner:Type,allowed:Bool,tick:Tick.Tick,meta:Meta<Owner>) -> Meta<Owner>:
  match allowed meta:
    case False{} meta:meta
    case True{} Meta{namespace,id,name,access,_}:Meta{namespace,id,name,access,Some{tick}}
def registered(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WR:Type,namespace:U32,name:String,access:List<&2,String>,local:Local,result:W.World<S,WC,WR,E> & W.Registration) -> Sys.Defined<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,W.RegistrationRejected{_}):Sys.DefinitionRefused{world,local}
    case (world,W.Registered{id}):Sys.Defined{world,Sys.Owner{namespace,id,name,access,None{},local}}
def named_compilation(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WR:Type,+name:String,local:Local,world:W.World<S,WC,WR,E>,namespace:U32,compilation:D.Compilation<S,WC,C,R,Ops>) -> Sys.Defined<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match compilation:
    case D.Unsupported{_,_,_}:Sys.DefinitionRefused{world,local}
    case D.Supported{D.Declaration{_,access},_}:
      +keys = D.keys(access)
      registered(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,name,keys,local,W.register(~S,~WC,~WR,~E,world,name,keys))
def named(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WR:Type,+name:String,local:Local,result:W.World<S,WC,WR,E> & U32) -> Sys.Defined<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,namespace):named_compilation(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,name,local,world,namespace,Build.compile(~S,~WC,~C,~R,~Ops,~declaration))

def define(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WR:Type,world:W.World<S,WC,WR,E>,name:String,local:Local) -> Sys.Defined<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  named(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,name,local,W.namespace(~S,~WC,~WR,~E,world))
def registration_verified(~S:Data,~C:Type,~R:Type,~E:Data,same:Bool,result:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Bool:
  match result:
    case (world,registered):(world,Bool.and(same,registered))
def namespace_actual(~S:Data,~C:Type,~R:Type,~E:Data,~Owner:Type,meta:Meta<Owner>,world:W.World<S,C,R,E>,actual:U32) -> W.World<S,C,R,E> & Bool:
  match meta:
    case Meta{namespace,id,name,access,_}:registration_verified(~S,~C,~R,~E,U32.is_eq(namespace,actual),W.registration_matches(~S,~C,~R,~E,world,id,name,access))
def namespace_verified(~S:Data,~C:Type,~R:Type,~E:Data,~Owner:Type,meta:Meta<Owner>,result:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Bool:
  match result:
    case (world,actual):namespace_actual(~S,~C,~R,~E,~Owner,meta,world,actual)
def verify(~S:Data,~C:Type,~R:Type,~E:Data,~Owner:Type,meta:Meta<Owner>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Bool:
  namespace_verified(~S,~C,~R,~E,~Owner,meta,W.namespace(~S,~C,~R,~E,world))
def enter(~S:Data,~C:Type,~R:Type,~E:Data,allowed:Bool,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Tick.Tick:
  match allowed:
    case False{}:W.execution_clock(~S,~C,~R,~E,world)
    case True{}:W.enter_run(~S,~C,~R,~E,world)
def leave(~S:Data,~C:Type,~R:Type,~E:Data,allowed:Bool,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match allowed:
    case False{}:world
    case True{}:W.leave_run(~S,~C,~R,~E,world)

def named_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WR:Type,+name:String,local:Local,result:W.World<S,WC,WR,E> & U32) -> Sys.Defined<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,namespace):named_compilation(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,name,local,world,namespace,Build.compile_with_general(~S,~WC,~C,~R,~provider,~Ops,~declaration))

def define_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.Program(~S,~WC,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WR:Type,world:W.World<S,WC,WR,E>,name:String,local:Local) -> Sys.Defined<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  named_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,~WR,name,local,W.namespace(~S,~WC,~WR,~E,world))
