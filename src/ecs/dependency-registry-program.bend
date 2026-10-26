import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./dependency-registration.bend as Reg
import ./dependency-executor.bend as Exec
import ./execution-parallel-registration.bend as Part
import ./owner-product.bend as Product

def Dispatch(~World:Type,~Owners:Type,~Error:Data,~Out:Data) -> Type:
  Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>)
def Family(~Error:Data,~Out:Data) -> Type:
  @-World:Type -> @-Owners:Type -> @-dispatch:Dispatch(~World,~Owners,~Error,~Out) -> Type

def Leaf(~Error:Data,~Out:Data,~F:Family(~Error,~Out)) -> Type:
  @-S:Data -> @-C:Type -> @-R:Type -> @-E:Data -> @-Ops:(Type -> Type) -> @-Local:Type -> @-declaration:Build.Program(~S,~C,~R,~Ops) -> @-body:(@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>)) -> Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> -> F(W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Reg.leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body))

def Join(~Error:Data,~Out:Data,~F:Family(~Error,~Out)) -> Type:
  @-World:Type -> @-L:Type -> @-R:Type -> @-left:Dispatch(~World,~L,~Error,~Out) -> @-right:Dispatch(~World,~R,~Error,~Out) -> F(World,L,left) -> F(World,R,right) -> F(World,Reg.Product<L,R>,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right))
def Partition(~Error:Data,~Out:Data,~F:Family(~Error,~Out)) -> Type:
  @-S:(Data) -> @-CL:(Type) -> @-CR:(Type) -> @-RL:(Type) -> @-RR:(Type) -> @-E:(Data) -> @-LL:(Type) -> @-LR:(Type) -> @-OpsL:(Type -> Type) -> @-OpsR:(Type -> Type) -> @-dl:(Build.Program(~S,~CL,~RL,~OpsL)) -> @-dr:(Build.Program(~S,~CR,~RR,~OpsR)) -> @-bl:(@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>)) -> @-br:(@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>)) -> Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>> -> F(W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,Part.dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br))
def Vacant(~Error:Data,~Out:Data,~F:Family(~Error,~Out)) -> Type:
  @-World:Type -> F(World,Unit,Reg.empty_dispatch(~World,~Error,~Out))
def Selection(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Dispatch(~World,~Owners,~Error,~Out)) -> Type:
  @-F:Family(~Error,~Out) -> @-leaf:Leaf(~Error,~Out,~F) -> @-pair:Join(~Error,~Out,~F) -> @-partition:Partition(~Error,~Out,~F) -> @-empty:Vacant(~Error,~Out,~F) -> Owners -> F(World,Owners,dispatch)

def Checked(~Error:Data,~Out:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error,~Out)) -> Type:
  Reg.Registry<World,Owners,Error,Out,dispatch>
def compile_leaf(~Error:Data,~Out:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Reg.Registry<W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out,Reg.leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body)>:
  Reg.leaf(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner)
def compile_join(~Error:Data,~Out:Data,~World:Type,~L:Type,~R:Type,~left:Dispatch(~World,~L,~Error,~Out),~right:Dispatch(~World,~R,~Error,~Out),l:Reg.Registry<World,L,Error,Out,left>,r:Reg.Registry<World,R,Error,Out,right>) -> Reg.Registry<World,Reg.Product<L,R>,Error,Out,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right)>:
  Reg.paired(~World,~L,~R,~Error,~Out,~left,~right,l,r)
def compile_empty(~Error:Data,~Out:Data,~World:Type) -> Reg.Registry<World,Unit,Error,Out,Reg.empty_dispatch(~World,~Error,~Out)>:
  Reg.empty(~World,~Error,~Out)
def compile_partition(~Error:Data,~Out:Data,~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>) -> Reg.Registry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,Error,Out,Part.dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br)>:
  Part.registry(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,owners)
def compile(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Dispatch(~World,~Owners,~Error,~Out),~selection:Selection(~World,~Owners,~Error,~Out,~dispatch),owners:Owners) -> Reg.Registry<World,Owners,Error,Out,dispatch>:
  selection(Checked(~Error,~Out),compile_leaf(~Error,~Out),compile_join(~Error,~Out),compile_partition(~Error,~Out),compile_empty(~Error,~Out),owners)


def leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~F:Family(~Error,~Out),~leaf:Leaf(~Error,~Out,~F),~pair:Join(~Error,~Out,~F),~partition:Partition(~Error,~Out,~F),~empty:Vacant(~Error,~Out,~F),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> F(W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Reg.leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body)):
  leaf(S,C,R,E,Ops,Local,declaration,body,owner)
def paired(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~left:Dispatch(~World,~L,~Error,~Out),~right:Dispatch(~World,~R,~Error,~Out),~leftSelection:Selection(~World,~L,~Error,~Out,~left),~rightSelection:Selection(~World,~R,~Error,~Out,~right),~F:Family(~Error,~Out),~leaf:Leaf(~Error,~Out,~F),~pair:Join(~Error,~Out,~F),~partition:Partition(~Error,~Out,~F),~empty:Vacant(~Error,~Out,~F),owners:Reg.Product<L,R>) -> F(World,Reg.Product<L,R>,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right)):
  match owners:
    case Reg.Product{l,r,_}:pair(World,L,R,left,right,leftSelection(F,leaf,pair,partition,empty,l),rightSelection(F,leaf,pair,partition,empty,r))
def empty(~World:Type,~Error:Data,~Out:Data,~F:Family(~Error,~Out),~leaf:Leaf(~Error,~Out,~F),~pair:Join(~Error,~Out,~F),~partition:Partition(~Error,~Out,~F),~empty:Vacant(~Error,~Out,~F),_:Unit) -> F(World,Unit,Reg.empty_dispatch(~World,~Error,~Out)):
  empty(World)

def ConditionChecked(~Error:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error,~Bool)) -> Type:
  Reg.ConditionRegistry<World,Owners,Error,dispatch>
def condition_leaf(~Error:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Bool>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Bool,declaration,body>) -> Reg.ConditionRegistry<W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Bool,declaration,body>,Error,Reg.leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~Bool,~declaration,~body)>:
  Reg.condition_leaf(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,owner)
def condition_join(~Error:Data,~World:Type,~L:Type,~R:Type,~left:Dispatch(~World,~L,~Error,~Bool),~right:Dispatch(~World,~R,~Error,~Bool),l:Reg.ConditionRegistry<World,L,Error,left>,r:Reg.ConditionRegistry<World,R,Error,right>) -> Reg.ConditionRegistry<World,Reg.Product<L,R>,Error,Reg.paired_dispatch(~World,~L,~R,~Error,~Bool,~left,~right)>:
  Reg.paired_conditions(~World,~L,~R,~Error,~left,~right,l,r)
def condition_empty(~Error:Data,~World:Type) -> Reg.ConditionRegistry<World,Unit,Error,Reg.empty_dispatch(~World,~Error,~Bool)>:
  Reg.empty_conditions(~World,~Error)
def condition_partition(~Error:Data,~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Bool>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Bool>),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Bool,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Bool,dr,br>>) -> Reg.ConditionRegistry<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Bool,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Bool,dr,br>>,Error,Part.dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Bool,~OpsL,~OpsR,~dl,~dr,~bl,~br)>:
  Part.condition_registry(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~OpsL,~OpsR,~dl,~dr,~bl,~br,owners)
def compile_conditions(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error,~Bool),~selection:Selection(~World,~Owners,~Error,~Bool,~dispatch),owners:Owners) -> Reg.ConditionRegistry<World,Owners,Error,dispatch>:
  selection(ConditionChecked(~Error),condition_leaf(~Error),condition_join(~Error),condition_partition(~Error),condition_empty(~Error),owners)


def partition(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~Error:Data,~Out:Data,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),~F:Family(~Error,~Out),~leaf:Leaf(~Error,~Out,~F),~pair:Join(~Error,~Out,~F),~partition:Partition(~Error,~Out,~F),~empty:Vacant(~Error,~Out,~F),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>) -> F(W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,Part.dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br)):
  partition(S,CL,CR,RL,RR,E,LL,LR,OpsL,OpsR,dl,dr,bl,br,owners)
