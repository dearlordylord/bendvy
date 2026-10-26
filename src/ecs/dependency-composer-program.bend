import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./dependency-registration.bend as Reg
import ./dependency-registry-program.bend as Prog
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./execution-parallel-registration.bend as Part
import ./owner-product.bend as Product
import ./execution-parallel-rootcut.bend as Root
import ./execution-parallel-scope-registry.bend as Tree

type Scope is Data:
  Scope{members:List<&2,U32>,children:List<&2,Scope>}
type Compiled<-World:Type,-Owners:Type,-Error:Data,-Out:Data,-dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>)> is Type:
  Compiled{registry:Reg.Registry<World,Owners,Error,Out,dispatch>,scope:Scope}
def Scoped(~Error:Data,~Out:Data,~World:Type,~Owners:Type,~dispatch:Prog.Dispatch(~World,~Owners,~Error,~Out)) -> Type:
  Compiled<World,Owners,Error,Out,dispatch>
def ids(nodes:List<&2,Plan.Node<String>>) -> List<&2,U32>:
  match nodes:
    case []:[]
    case Plan.Node{id,_} <> rest:id <> ids(rest)
def lifted(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Prog.Dispatch(~World,~Owners,~Error,~Out),registry:Reg.Registry<World,Owners,Error,Out,dispatch>) -> Compiled<World,Owners,Error,Out,dispatch>:
  match registry:
    case Reg.Registry{owners,+nodes}:Compiled{Reg.Registry{owners,nodes},Scope{ids(nodes),[]}}
def compile_leaf(~Error:Data,~Out:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Compiled<W.World<S,C,R,E>,Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out,Reg.leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body)>:
  lifted(~W.World<S,C,R,E>,~Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>,~Error,~Out,~Reg.leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body),Reg.leaf(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner))
def joined(~Error:Data,~Out:Data,~World:Type,~L:Type,~R:Type,~left:Prog.Dispatch(~World,~L,~Error,~Out),~right:Prog.Dispatch(~World,~R,~Error,~Out),leftScope:Scope,rightScope:Scope,registry:Reg.Registry<World,Reg.Product<L,R>,Error,Out,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right)>) -> Compiled<World,Reg.Product<L,R>,Error,Out,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right)>:
  match registry:
    case Reg.Registry{owners,+nodes}:Compiled{Reg.Registry{owners,nodes},Scope{ids(nodes),[leftScope,rightScope]}}
def compile_join(~Error:Data,~Out:Data,~World:Type,~L:Type,~R:Type,~left:Prog.Dispatch(~World,~L,~Error,~Out),~right:Prog.Dispatch(~World,~R,~Error,~Out),l:Compiled<World,L,Error,Out,left>,r:Compiled<World,R,Error,Out,right>) -> Compiled<World,Reg.Product<L,R>,Error,Out,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~left,~right)>:
  match l r:
    case Compiled{lr,+ls} Compiled{rr,+rs}:joined(~Error,~Out,~World,~L,~R,~left,~right,ls,rs,Reg.paired(~World,~L,~R,~Error,~Out,~left,~right,lr,rr))
def compile_empty(~Error:Data,~Out:Data,~World:Type) -> Compiled<World,Unit,Error,Out,Reg.empty_dispatch(~World,~Error,~Out)>:
  lifted(~World,~Unit,~Error,~Out,~Reg.empty_dispatch(~World,~Error,~Out),Reg.empty(~World,~Error,~Out))
def compile_partition(~Error:Data,~Out:Data,~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~LL:Type,~LR:Type,~OpsL:Type -> Type,~OpsR:Type -> Type,~dl:Build.Program(~S,~CL,~RL,~OpsL),~dr:Build.Program(~S,~CR,~RR,~OpsR),~bl:@-H:Type -> @-caps:OpsL(H) -> H -> LL -> H & (LL & Sys.Completion<Error,Out>),~br:@-H:Type -> @-caps:OpsR(H) -> H -> LR -> H & (LR & Sys.Completion<Error,Out>),owners:Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>) -> Compiled<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,Error,Out,Part.dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br)>:
  lifted(~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~Product.Owner<Sys.Owner<S,CL,RL,E,OpsL,LL,Error,Out,dl,bl>,Sys.Owner<S,CR,RR,E,OpsR,LR,Error,Out,dr,br>>,~Error,~Out,~Part.dispatch(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br),Part.registry(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~Error,~Out,~OpsL,~OpsR,~dl,~dr,~bl,~br,owners))
def compile_rootcut(~Error:Data,~Out:Data,~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~CR,~RR,~E,~Error,~Out,~R),owners:Product.Owner<L,R>) -> Compiled<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Product.Owner<L,R>,Error,Out,Root.dispatch(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right)>:
  lifted(~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,~Product.Owner<L,R>,~Error,~Out,~Root.dispatch(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right),Root.registry(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,~left,~right,owners))
def compile(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Prog.Dispatch(~World,~Owners,~Error,~Out),~selection:Prog.Selection(~World,~Owners,~Error,~Out,~dispatch),owners:Owners) -> Compiled<World,Owners,Error,Out,dispatch>:
  selection(Scoped(~Error,~Out),compile_leaf(~Error,~Out),compile_join(~Error,~Out),compile_partition(~Error,~Out),compile_rootcut(~Error,~Out),compile_empty(~Error,~Out),owners)



type Nested is Data:
  Nested{path:List<&2,U32>,edges:List<&2,Plan.Edge>}
type NestError is Data:
  UnknownScope{path:List<&2,U32>}
  InvalidEdges{path:List<&2,U32>,reason:Plan.Invalid<String>}
type Nesting is Data:
  Nesting{edges:List<&2,Plan.Edge>,invalid:Maybe<&2,NestError>}
def child_selected(first:Bool,current:Scope,next:Maybe<&2,Scope>) -> Maybe<&2,Scope>:
  match first:
    case True{}:Some{current}
    case False{}:next
def child(children:List<&2,Scope>,+index:U32) -> Maybe<&2,Scope>:
  match children:
    case []:None{}
    case scope <> rest:child_selected(U32.is_eq(index,0),scope,child(rest,U32.sub(index,1)))
def scoped(path:List<&2,U32>,scope:Maybe<&2,Scope>) -> Maybe<&2,Scope>:
  match path scope:
    case [] scope:scope
    case _ None{}:None{}
    case index <> rest Some{Scope{_,children}}:scoped(rest,child(children,index))
def members(values:List<&2,U32>) -> List<&2,Plan.Node<String>>:
  match values:
    case []:[]
    case id <> rest:Plan.Node{id,[]} <> members(rest)
def checked_endpoints(path:List<&2,U32>,value:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,NestError>:
  match value:
    case None{}:None{}
    case Some{reason}:Some{InvalidEdges{path,reason}}
def checked_scope(+path:List<&2,U32>,edges:List<&2,Plan.Edge>,scope:Maybe<&2,Scope>) -> Maybe<&2,NestError>:
  match scope:
    case None{}:Some{UnknownScope{path}}
    case Some{Scope{ids,_}}:checked_endpoints(path,Plan.endpoints(~String,edges,members(ids)))
def first_nesting(first:Maybe<&2,NestError>,next:Maybe<&2,NestError>) -> Maybe<&2,NestError>:
  match first:
    case None{}:next
    case Some{reason}:Some{reason}
def nested_next(edges:List<&2,Plan.Edge>,invalid:Maybe<&2,NestError>,next:Nesting) -> Nesting:
  match next:
    case Nesting{later,error}:Nesting{List.append(&2,Plan.Edge,edges,later),first_nesting(invalid,error)}
def nested(items:List<&2,Nested>,+scope:Scope) -> Nesting:
  match items:
    case []:Nesting{[],None{}}
    case Nested{+path,+edges} <> rest:nested_next(edges,checked_scope(path,edges,scoped(path,Some{scope})),nested(rest,scope))
