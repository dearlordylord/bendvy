import Base
import ./world.bend as W
import ./registration.bend as Reg
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./change-tick.bend as Tick

type Detached<-System:Type> is Type:
  Detached{system:System}
type Retirement<-World:Type,-System:Type> is Type:
  Retired{world:World,detached:Detached<System>}
  RetirementRefused{world:World,system:System}
type Restoration<-World:Type,-System:Type> is Type:
  Restored{world:World,system:System}
  RestorationRefused{world:World,detached:Detached<System>}
type Identity is Data:
  Identity{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>}
type Released<-Local:Type> is Type:
  Released{identity:Identity,local:Local}

def retired(~World:Type,~System:Type,system:System,result:World & Bool) -> Retirement<World,System>:
  match result:
    case (world,False{}):RetirementRefused{world,system}
    case (world,True{}):Retired{world,Detached{system}}
def retire(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,~WE:Data,system:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,WC,WR,WE>) -> Retirement<W.World<S,WC,WR,WE>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  match system:
    case Sys.Owner{+namespace,+id,+name,+access,cursor,local}:retired(~W.World<S,WC,WR,WE>,~Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Sys.Owner{namespace,id,name,access,cursor,local},Reg.remove(~S,~WC,~WR,~WE,world,namespace,id,name,access))

def contains_id(registrations:List<&2,W.RegistrationMeta>,+id:U32) -> Bool:
  match registrations:
    case []:False{}
    case W.RegistrationMeta{actual,_,_} <> rest:Bool.or(U32.is_eq(actual,id),contains_id(rest,id))
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,~WE:Data,allowed:Bool,system:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,WC,WR,WE>) -> Restoration<W.World<S,WC,WR,WE>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  match allowed system world:
    case False{} system world:RestorationRefused{world,Detached{system}}
    case True{} Sys.Owner{+namespace,+id,+name,+access,cursor,local} W.World{actual,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:Restored{W.World{actual,allocator,store,resource,events,pending,W.RegistrationMeta{id,name,access} <> registrations,nextSystemId,clock,lifecycle},Sys.Owner{namespace,id,name,access,cursor,local}}
def restore_world(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,~WE:Data,system:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,WC,WR,WE>) -> Restoration<W.World<S,WC,WR,WE>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  match system world:
    case Sys.Owner{+namespace,+id,+name,+access,cursor,local} W.World{+actual,allocator,store,resource,events,pending,+registrations,+nextSystemId,clock,lifecycle}:restored(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR,~WE,Bool.and(U32.is_eq(namespace,actual),Bool.and(U32.is_lt(id,nextSystemId),Bool.and(Bool.not(contains_id(registrations,id)),W.access_equal(access,D.access(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration)))))),Sys.Owner{namespace,id,name,access,cursor,local},W.World{actual,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle})
def restore(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,~WE:Data,detached:Detached<Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>>,world:W.World<S,WC,WR,WE>) -> Restoration<W.World<S,WC,WR,WE>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  match detached:
    case Detached{system}:restore_world(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR,~WE,system,world)
def release(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),detached:Detached<Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>>) -> Released<Local>:
  match detached:
    case Detached{Sys.Owner{namespace,id,name,access,cursor,local}}:Released{Identity{namespace,id,name,access,cursor},local}
