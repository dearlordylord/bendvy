import Base
import ./dependency-registration.bend as Reg
import ./dependency-executor.bend as Exec

# This generic pure registry carries Data dispatch. System-backed conditions use
# execution-condition-registry and the canonical taskful IO path.
def Dispatch(~World:Type,~Owners:Type,~Error:Data,~Out:Data) -> Type:
  Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>)
def Family(~Error:Data,~Out:Data) -> Type:
  @-World:Type -> @-Owners:Type -> @-dispatch:Dispatch(~World,~Owners,~Error,~Out) -> Type
def Embed(~Error:Data,~Out:Data,~F:Family(~Error,~Out)) -> Type:
  @-World:Type -> @-Owners:Type -> @-dispatch:Dispatch(~World,~Owners,~Error,~Out) -> Reg.Registry<World,Owners,Error,Out,dispatch> -> F(World,Owners,dispatch)
def Join(~Error:Data,~Out:Data,~F:Family(~Error,~Out)) -> Type:
  @-World:Type -> @-L:Type -> @-R:Type -> @-left:Dispatch(~World,~L,~Error,~Out) -> @-right:Dispatch(~World,~R,~Error,~Out) -> F(World,L,left) -> F(World,R,right) -> F(World,Reg.Product<L,R>,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right))
def Vacant(~Error:Data,~Out:Data,~F:Family(~Error,~Out)) -> Type:
  @-World:Type -> F(World,Unit,Reg.empty_dispatch(~World,~Error,~Out))
def Selection(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Dispatch(~World,~Owners,~Error,~Out)) -> Type:
  @-F:Family(~Error,~Out) -> @-embed:Embed(~Error,~Out,~F) -> @-pair:Join(~Error,~Out,~F) -> @-empty:Vacant(~Error,~Out,~F) -> Owners -> F(World,Owners,dispatch)
def Checked(~Error:Data,~Out:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error,~Out)) -> Type:
  Reg.Registry<World,Owners,Error,Out,dispatch>
def compile_embed(~Error:Data,~Out:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error,~Out),registry:Reg.Registry<World,Owners,Error,Out,dispatch>) -> Reg.Registry<World,Owners,Error,Out,dispatch>:
  registry
def compile_join(~Error:Data,~Out:Data,~World:Type,~L:Type,~R:Type,~left:Dispatch(~World,~L,~Error,~Out),~right:Dispatch(~World,~R,~Error,~Out),l:Reg.Registry<World,L,Error,Out,left>,r:Reg.Registry<World,R,Error,Out,right>) -> Reg.Registry<World,Reg.Product<L,R>,Error,Out,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right)>:
  Reg.paired(~World,~L,~R,~Error,~Out,~left,~right,l,r)
def compile_empty(~Error:Data,~Out:Data,~World:Type) -> Reg.Registry<World,Unit,Error,Out,Reg.empty_dispatch(~World,~Error,~Out)>:
  Reg.empty(~World,~Error,~Out)
def compile(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Dispatch(~World,~Owners,~Error,~Out),~selection:Selection(~World,~Owners,~Error,~Out,~dispatch),owners:Owners) -> Reg.Registry<World,Owners,Error,Out,dispatch>:
  selection(Checked(~Error,~Out),compile_embed(~Error,~Out),compile_join(~Error,~Out),compile_empty(~Error,~Out),owners)
def ConditionChecked(~Error:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error,~Bool)) -> Type:
  Reg.ConditionRegistry<World,Owners,Error,dispatch>
def condition_embed(~Error:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error,~Bool),registry:Reg.Registry<World,Owners,Error,Bool,dispatch>) -> Reg.ConditionRegistry<World,Owners,Error,dispatch>:
  Reg.ConditionRegistry{registry,None{}}
def condition_join(~Error:Data,~World:Type,~L:Type,~R:Type,~left:Dispatch(~World,~L,~Error,~Bool),~right:Dispatch(~World,~R,~Error,~Bool),l:Reg.ConditionRegistry<World,L,Error,left>,r:Reg.ConditionRegistry<World,R,Error,right>) -> Reg.ConditionRegistry<World,Reg.Product<L,R>,Error,Reg.paired_dispatch(~World,~L,~R,~Error,~Bool,~left,~right)>:
  Reg.paired_conditions(~World,~L,~R,~Error,~left,~right,l,r)
def condition_empty(~Error:Data,~World:Type) -> Reg.ConditionRegistry<World,Unit,Error,Reg.empty_dispatch(~World,~Error,~Bool)>:
  Reg.empty_conditions(~World,~Error)
def compile_conditions(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error,~Bool),~selection:Selection(~World,~Owners,~Error,~Bool,~dispatch),owners:Owners) -> Reg.ConditionRegistry<World,Owners,Error,dispatch>:
  selection(ConditionChecked(~Error),condition_embed(~Error),condition_join(~Error),condition_empty(~Error),owners)
def empty(~World:Type,~Error:Data,~Out:Data,~F:Family(~Error,~Out),~embed:Embed(~Error,~Out,~F),~pair:Join(~Error,~Out,~F),~empty:Vacant(~Error,~Out,~F),_:Unit) -> F(World,Unit,Reg.empty_dispatch(~World,~Error,~Out)):
  empty(World)
