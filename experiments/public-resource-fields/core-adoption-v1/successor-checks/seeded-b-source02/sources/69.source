import Base
import ./world.bend as W
import ./registration.bend as Reg

# Runner identity is a closed erased index; each registration owns its Local.
type Outcome<World: Type,L: Type,Error: Data,Out: Type> is Type:
  Succeeded{world: World,local: L,output: Out}
  Failed{world: World,local: L,error: Error}
type Instance<S: Data,C: Type,R: Type,E: Data,L: Type,Args: Type,Error: Data,Out: Type,-runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>> is Type:
  Instance{namespace: U32,id: U32,name: String,access: List<&2,String>,local: L}
type Registered<S: Data,C: Type,R: Type,E: Data,L: Type,Args: Type,Error: Data,Out: Type,-runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>> is Type:
  Registered{world: W.World<S,C,R,E>,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>}
  RegistrationRejected{world: W.World<S,C,R,E>,local: L}
type Run<S: Data,C: Type,R: Type,E: Data,L: Type,Args: Type,Error: Data,Out: Type,-runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>> is Type:
  Completed{world: W.World<S,C,R,E>,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>,result: Result<&2,&1,Error,Out>}
  Refused{world: W.World<S,C,R,E>,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>,args: Args}
type Disposal<S: Data,C: Type,R: Type,E: Data,L: Type,Args: Type,Error: Data,Out: Type,-runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,Disposed: Type> is Type:
  Disposed{world: W.World<S,C,R,E>,output: Disposed}
  DisposalRejected{world: W.World<S,C,R,E>,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>}

# Rank-2 provider: callbacks get declared operations, not the concrete cell.
type Cell<L: Type> is Type:
  Cell{local: L}
type Ops<H: Type,L: Type,V: Data> is Type:
  Ops{read: H -> H & V,replace: H -> L -> H}
def projected(~L: Type,~V: Data,result: L & V) -> Cell<L> & V:
  (local,value) = result
  (Cell{local},value)
def read_cell(~L: Type,~V: Data,~project: L -> L & V,cell: Cell<L>) -> Cell<L> & V:
  match cell:
    case Cell{local}: projected(~L,~V,project(local))

def replace_cell(~L: Type,cell: Cell<L>,local: L) -> Cell<L>:
  match cell:
    case Cell{old}: Cell{local}
def modify_cell(~L: Type,cell: Cell<L>,modify: L -> L) -> Cell<L>:
  match cell:
    case Cell{local}: Cell{modify(local)}
def unwrapped(~L: Type,~Out: Type,result: Cell<L> & Out) -> L & Out:
  match result:
    case (Cell{local},out): (local,out)
def provide(~L: Type,~V: Data,~Out: Type,~project: L -> L & V,~consume: @-H: Type -> Ops<H,L,V> -> H -> H & Out,local: L) -> L & Out:
  unwrapped(~L,~Out,consume(Cell<L>,Ops{read_cell(~L,~V,~project),replace_cell(~L)},Cell{local}))

def provide_with(~L: Type,~V: Data,~Args: Type,~Out: Type,~project: L -> L & V,~consume: @-H: Type -> Ops<H,L,V> -> H -> Args -> H & Out,local: L,args: Args) -> L & Out:
  unwrapped(~L,~Out,consume(Cell<L>,Ops{read_cell(~L,~V,~project),replace_cell(~L)},Cell{local},args))

def register_result(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,registered: W.World<S,C,R,E> & W.Registration,+namespace: U32,+name: String,+access: List<&2,String>,local: L) -> Registered<S,C,R,E,L,Args,Error,Out,runner>:
  match registered:
    case (world,W.Registered{id}): Registered{world,Instance{namespace,id,name,access,local}}
    case (world,W.RegistrationRejected{_}): RegistrationRejected{world,local}
def register_named(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,named: W.World<S,C,R,E> & U32,+name: String,+access: List<&2,String>,local: L) -> Registered<S,C,R,E,L,Args,Error,Out,runner>:
  (world,+namespace) = named
  register_result(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,W.register(~S,~C,~R,~E,world,name,access),namespace,name,access,local)
def register(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,world: W.World<S,C,R,E>,name: String,access: List<&2,String>,local: L) -> Registered<S,C,R,E,L,Args,Error,Out,runner>:
  register_named(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,W.namespace(~S,~C,~R,~E,world),name,access,local)

def completed(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,namespace: U32,id: U32,name: String,access: List<&2,String>,outcome: Outcome<W.World<S,C,R,E>,L,Error,Out>) -> Run<S,C,R,E,L,Args,Error,Out,runner>:
  match outcome:
    case Succeeded{world,local,out}: Completed{world,Instance{namespace,id,name,access,local},Done{out}}
    case Failed{world,local,error}: Completed{world,Instance{namespace,id,name,access,local},Fail{error}}
def checked(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,allowed: Bool,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>,world: W.World<S,C,R,E>,args: Args) -> Run<S,C,R,E,L,Args,Error,Out,runner>:
  match allowed instance:
    case False{} instance: Refused{world,instance,args}
    case True{} Instance{namespace,id,name,access,local}: completed(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,namespace,id,name,access,runner(world,local,args))
def run(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>,world: W.World<S,C,R,E>,args: Args) -> Run<S,C,R,E,L,Args,Error,Out,runner>:
  match instance world:
    case Instance{+namespace,+id,+name,+access,local} W.World{+actual,nextId,highWater,live,capacity,depth,store,resource,events,pending,+registrations,nextSystemId,clock}:
      checked(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,Bool.and(U32.is_eq(namespace,actual),W.registration_list_matches(registrations,id,name,access)),Instance{namespace,id,name,access,local},W.World{actual,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},args)
def skip(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>) -> Instance<S,C,R,E,L,Args,Error,Out,runner>:
  instance

def identity(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>) -> Instance<S,C,R,E,L,Args,Error,Out,runner> & U32:
  match instance:
    case Instance{namespace,+id,name,access,local}: (Instance{namespace,id,name,access,local},id)
def observed(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,~V: Data,namespace: U32,id: U32,name: String,access: List<&2,String>,value: L & V) -> Instance<S,C,R,E,L,Args,Error,Out,runner> & V:
  (local,value) = value
  (Instance{namespace,id,name,access,local},value)
def observe(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,~V: Data,~project: L -> L & V,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>) -> Instance<S,C,R,E,L,Args,Error,Out,runner> & V:
  match instance:
    case Instance{namespace,id,name,access,local}: observed(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,~V,namespace,id,name,access,project(local))

def disposal(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,~Disposed: Type,~disposeLocal: L -> Disposed,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>,result: W.World<S,C,R,E> & Bool) -> Disposal<S,C,R,E,L,Args,Error,Out,runner,Disposed>:
  match instance result:
    case instance, (world,False{}): DisposalRejected{world,instance}
    case Instance{_,_,_,_,local}, (world,True{}): Disposed{world,disposeLocal(local)}
def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~L: Type,~Args: Type,~Error: Data,~Out: Type,~runner: W.World<S,C,R,E> -> L -> Args -> Outcome<W.World<S,C,R,E>,L,Error,Out>,~Disposed: Type,~disposeLocal: L -> Disposed,instance: Instance<S,C,R,E,L,Args,Error,Out,runner>,world: W.World<S,C,R,E>) -> Disposal<S,C,R,E,L,Args,Error,Out,runner,Disposed>:
  match instance:
    case Instance{+namespace,+id,+name,+access,local}: disposal(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,~Disposed,~disposeLocal,Instance{namespace,id,name,access,local},Reg.remove(~S,~C,~R,~E,world,namespace,id,name,access))
