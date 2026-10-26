import Base
import ./schema.bend as Schema
import ./bodies.bend as Body
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/dependency-executor.bend as Exec
import ../../../src/ecs/dependency-plan.bend as Plan
import ../../../src/ecs/dependency-registration.bend as Reg
import ../../../src/ecs/dependency-application.bend as App
import ../../../src/ecs/dependency-registry-program.bend as Cond

def Writer(~S:Data) -> Type:Sys.Owner<S,Unit,Schema.Resources(),Unit,Schema.Write(),Schema.Local,String,U32,Schema.write(~S),Body.writer>
def WriterDispatch(~S:Data) -> Writer(~S) -> Schema.World(~S) -> U32 -> Writer(~S) & (Schema.World(~S) & Exec.Invocation<String,U32>):
  Reg.leaf_dispatch(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Write(),~Schema.Local,~String,~U32,~Schema.write(~S),~Body.writer)

def Reader(~S:Data) -> Type:Sys.Owner<S,Unit,Schema.Resources(),Unit,Schema.Read(),Schema.Local,String,U32,Schema.read(~S),Body.reader>
def ReaderDispatch(~S:Data) -> Reader(~S) -> Schema.World(~S) -> U32 -> Reader(~S) & (Schema.World(~S) & Exec.Invocation<String,U32>):
  Reg.leaf_dispatch(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader)

def Positive(~S:Data) -> Type:Sys.Owner<S,Unit,Schema.Resources(),Unit,Schema.Read(),Schema.Local,String,Bool,Schema.read(~S),Body.positive>
def PositiveDispatch(~S:Data) -> Positive(~S) -> Schema.World(~S) -> U32 -> Positive(~S) & (Schema.World(~S) & Exec.Invocation<String,Bool>):
  Reg.leaf_dispatch(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Bool,~Schema.read(~S),~Body.positive)

def Changing(~S:Data) -> Type:Sys.Owner<S,Unit,Schema.Resources(),Unit,Schema.Read(),Schema.Local,String,Bool,Schema.read(~S),Body.changing>
def ChangingDispatch(~S:Data) -> Changing(~S) -> Schema.World(~S) -> U32 -> Changing(~S) & (Schema.World(~S) & Exec.Invocation<String,Bool>):
  Reg.leaf_dispatch(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Bool,~Schema.read(~S),~Body.changing)

def Left(~S:Data) -> Type:Reg.Product<Writer(~S),Reader(~S)>
def Right(~S:Data) -> Type:Reg.Product<Reader(~S),Reader(~S)>
def Owners(~S:Data) -> Type:Reg.Product<Left(~S),Right(~S)>
def Guards(~S:Data) -> Type:Reg.Product<Positive(~S),Changing(~S)>
def LeftDispatch(~S:Data) -> Left(~S) -> Schema.World(~S) -> U32 -> Left(~S) & (Schema.World(~S) & Exec.Invocation<String,U32>):
  Reg.paired_dispatch(~Schema.World(~S),~Writer(~S),~Reader(~S),~String,~U32,~WriterDispatch(~S),~ReaderDispatch(~S))
def RightDispatch(~S:Data) -> Right(~S) -> Schema.World(~S) -> U32 -> Right(~S) & (Schema.World(~S) & Exec.Invocation<String,U32>):
  Reg.paired_dispatch(~Schema.World(~S),~Reader(~S),~Reader(~S),~String,~U32,~ReaderDispatch(~S),~ReaderDispatch(~S))
def OwnersDispatch(~S:Data) -> Owners(~S) -> Schema.World(~S) -> U32 -> Owners(~S) & (Schema.World(~S) & Exec.Invocation<String,U32>):
  Reg.paired_dispatch(~Schema.World(~S),~Left(~S),~Right(~S),~String,~U32,~LeftDispatch(~S),~RightDispatch(~S))
def GuardsDispatch(~S:Data) -> Guards(~S) -> Schema.World(~S) -> U32 -> Guards(~S) & (Schema.World(~S) & Exec.Invocation<String,Bool>):
  Reg.paired_dispatch(~Schema.World(~S),~Positive(~S),~Changing(~S),~String,~Bool,~PositiveDispatch(~S),~ChangingDispatch(~S))
def LeftSelection(~S:Data,~F:Cond.Family(~String,~U32),~leaf:Cond.Leaf(~String,~U32,~F),~pair:Cond.Join(~String,~U32,~F),~empty:Cond.Vacant(~String,~U32,~F),owners:Left(~S)) -> F(Schema.World(~S),Left(~S),LeftDispatch(~S)):
  Cond.paired(~Schema.World(~S),~Writer(~S),~Reader(~S),~String,~U32,~WriterDispatch(~S),~ReaderDispatch(~S),~Cond.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Write(),~Schema.Local,~String,~U32,~Schema.write(~S),~Body.writer),~Cond.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader),~F,~leaf,~pair,~empty,owners)
def RightSelection(~S:Data,~F:Cond.Family(~String,~U32),~leaf:Cond.Leaf(~String,~U32,~F),~pair:Cond.Join(~String,~U32,~F),~empty:Cond.Vacant(~String,~U32,~F),owners:Right(~S)) -> F(Schema.World(~S),Right(~S),RightDispatch(~S)):
  Cond.paired(~Schema.World(~S),~Reader(~S),~Reader(~S),~String,~U32,~ReaderDispatch(~S),~ReaderDispatch(~S),~Cond.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader),~Cond.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader),~F,~leaf,~pair,~empty,owners)
def OwnersSelection(~S:Data,~F:Cond.Family(~String,~U32),~leaf:Cond.Leaf(~String,~U32,~F),~pair:Cond.Join(~String,~U32,~F),~empty:Cond.Vacant(~String,~U32,~F),owners:Owners(~S)) -> F(Schema.World(~S),Owners(~S),OwnersDispatch(~S)):
  Cond.paired(~Schema.World(~S),~Left(~S),~Right(~S),~String,~U32,~LeftDispatch(~S),~RightDispatch(~S),~LeftSelection(~S),~RightSelection(~S),~F,~leaf,~pair,~empty,owners)
def GuardSelection(~S:Data,~F:Cond.Family(~String,~Bool),~leaf:Cond.Leaf(~String,~Bool,~F),~pair:Cond.Join(~String,~Bool,~F),~empty:Cond.Vacant(~String,~Bool,~F),owners:Guards(~S)) -> F(Schema.World(~S),Guards(~S),GuardsDispatch(~S)):
  Cond.paired(~Schema.World(~S),~Positive(~S),~Changing(~S),~String,~Bool,~PositiveDispatch(~S),~ChangingDispatch(~S),~Cond.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Bool,~Schema.read(~S),~Body.positive),~Cond.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Bool,~Schema.read(~S),~Body.changing),~F,~leaf,~pair,~empty,owners)
def Application(~S:Data) -> Type:App.Application<Schema.World(~S),Owners(~S),Guards(~S),Schema.Handler,String,U32,OwnersDispatch(~S),GuardsDispatch(~S),Body.handle>
def id_at(ids:List<&2,U32>,index:Nat) -> U32:
  match ids index:
    case [] _:0
    case first <> _ 0n:first
    case _ <> rest 1n+prior:id_at(rest,prior)
def bindings(+systems:List<&2,U32>,+guards:List<&2,U32>) -> List<&2,App.Binding>:
  [App.Binding{id_at(systems,1n),id_at(guards,0n)},App.Binding{id_at(systems,2n),id_at(guards,1n)}]
def build_registries(~S:Data,world:Schema.World(~S),systems:Reg.Registry<Schema.World(~S),Owners(~S),String,U32,OwnersDispatch(~S)>,guards:Reg.ConditionRegistry<Schema.World(~S),Guards(~S),String,GuardsDispatch(~S)>) -> Application(~S):
  match systems guards:
    case Reg.Registry{owners,+nodes} Reg.ConditionRegistry{Reg.Registry{guardOwners,+guardNodes},invalid}:App.build(~Schema.World(~S),~Owners(~S),~Guards(~S),~Schema.Handler,~String,~U32,~OwnersDispatch(~S),~GuardsDispatch(~S),~OwnersSelection(~S),~GuardSelection(~S),~Body.handle,~Schema.available,world,owners,guardOwners,Schema.Handler{ALeaf{701},[]},Plan.chain(Reg.ids(nodes)),bindings(Reg.ids(nodes),Reg.ids(guardNodes)))
def assemble(~S:Data,world:Schema.World(~S),writer:Writer(~S),a:Reader(~S),b:Reader(~S),c:Reader(~S),positive:Positive(~S),changing:Changing(~S)) -> Application(~S):
  build_registries(~S,world,Reg.paired(~Schema.World(~S),~Left(~S),~Right(~S),~String,~U32,~LeftDispatch(~S),~RightDispatch(~S),Reg.paired(~Schema.World(~S),~Writer(~S),~Reader(~S),~String,~U32,~WriterDispatch(~S),~ReaderDispatch(~S),Reg.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Write(),~Schema.Local,~String,~U32,~Schema.write(~S),~Body.writer,writer),Reg.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader,a)),Reg.paired(~Schema.World(~S),~Reader(~S),~Reader(~S),~String,~U32,~ReaderDispatch(~S),~ReaderDispatch(~S),Reg.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader,b),Reg.leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader,c))),Reg.paired_conditions(~Schema.World(~S),~Positive(~S),~Changing(~S),~String,~PositiveDispatch(~S),~ChangingDispatch(~S),Reg.condition_leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Schema.read(~S),~Body.positive,positive),Reg.condition_leaf(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Schema.read(~S),~Body.changing,changing)))
type Built<-A:Type> is Type:
  Built{application:A}
  Failed{}

def registered_changing(~S:Data,writer:Writer(~S),a:Reader(~S),b:Reader(~S),c:Reader(~S),positive:Positive(~S),result:Sys.Defined<Schema.World(~S),Changing(~S),Schema.Local>) -> Built<Application(~S)>:
  match result:
    case Sys.DefinitionRefused{_,_}:Failed{}
    case Sys.Defined{world,changing}:Built{assemble(~S,world,writer,a,b,c,positive,changing)}

def registered_positive(~S:Data,writer:Writer(~S),a:Reader(~S),b:Reader(~S),c:Reader(~S),result:Sys.Defined<Schema.World(~S),Positive(~S),Schema.Local>) -> Built<Application(~S)>:
  match result:
    case Sys.DefinitionRefused{_,_}:Failed{}
    case Sys.Defined{world,positive}:registered_changing(~S,writer,a,b,c,positive,Sys.define(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Bool,~Schema.read(~S),~Body.changing,world,"changing",Schema.Local{ALeaf{602},0}))

def registered_c(~S:Data,writer:Writer(~S),a:Reader(~S),b:Reader(~S),result:Sys.Defined<Schema.World(~S),Reader(~S),Schema.Local>) -> Built<Application(~S)>:
  match result:
    case Sys.DefinitionRefused{_,_}:Failed{}
    case Sys.Defined{world,c}:registered_positive(~S,writer,a,b,c,Sys.define(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~Bool,~Schema.read(~S),~Body.positive,world,"positive",Schema.Local{ALeaf{601},0}))

def registered_b(~S:Data,writer:Writer(~S),a:Reader(~S),result:Sys.Defined<Schema.World(~S),Reader(~S),Schema.Local>) -> Built<Application(~S)>:
  match result:
    case Sys.DefinitionRefused{_,_}:Failed{}
    case Sys.Defined{world,b}:registered_c(~S,writer,a,b,Sys.define(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader,world,"c",Schema.Local{ALeaf{504},0}))

def registered_a(~S:Data,writer:Writer(~S),result:Sys.Defined<Schema.World(~S),Reader(~S),Schema.Local>) -> Built<Application(~S)>:
  match result:
    case Sys.DefinitionRefused{_,_}:Failed{}
    case Sys.Defined{world,a}:registered_b(~S,writer,a,Sys.define(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader,world,"b",Schema.Local{ALeaf{503},0}))

def registered_writer(~S:Data,result:Sys.Defined<Schema.World(~S),Writer(~S),Schema.Local>) -> Built<Application(~S)>:
  match result:
    case Sys.DefinitionRefused{_,_}:Failed{}
    case Sys.Defined{world,writer}:registered_a(~S,writer,Sys.define(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader,world,"a",Schema.Local{ALeaf{502},0}))

def created(~S:Data,result:W.Creation<S,Unit,Schema.Resources(),Unit>) -> Built<Application(~S)>:
  match result:
    case W.CreateRejected{_,_}:Failed{}
    case W.Created{_,world}:registered_writer(~S,Sys.define(~S,~Unit,~Schema.Resources(),~Unit,~Schema.Write(),~Schema.Local,~String,~U32,~Schema.write(~S),~Body.writer,world,"writer",Schema.Local{ALeaf{501},0}))
def build(~S:Data) -> Built<Application(~S)>:
  created(~S,W.create(~S,~Unit,~Schema.Resources(),~Unit,~Schema.empty,W.factory(),Schema.resources()))
