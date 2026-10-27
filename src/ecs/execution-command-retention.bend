import Base
import ./execution-parallel-scope-registry.bend as Tree
import ./execution-command-system.bend as Cmd
import ./execution-composer-layout.bend as Layout
import ./execution-builder.bend as Build
import ./execution-system.bend as Sys
import ./execution-deferred-settings.bend as Settings
import ./owner-product.bend as Product

type Collector<-Owners:Type> is Type:
  Collector{owners:Owners,collect:List<&2,U32> -> Owners -> Owners & List<&2,U32>}
def Family(~Owners:Type) -> Type:Collector<Owners>
def none(~Owners:Type,ids:List<&2,U32>,owners:Owners) -> Owners & List<&2,U32>:
  (owners,[])
def plain(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Ops:Data -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Collector<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  Collector{owner,none(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>)}
def command_pending(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),id:U32,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,U32>:
  match result:
    case (owner,pending):(owner,Bool.pick(List<&2,U32>,pending,[id],[]))
def command_selected(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),id:U32,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,selected:Bool) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,U32>:
  match selected:
    case False{}:(owner,[])
    case True{}:command_pending(~S,~WC,~C,~R,~E,~Error,~Out,~layout,~route,~same,~valid,~Ops,~User,~declaration,~body,id,Cmd.pending(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
def command_metadata(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),ids:List<&2,U32>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Cmd.Metadata) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,U32>:
  match result:
    case (owner,Cmd.Metadata{+id,_,_}):command_selected(~S,~WC,~C,~R,~E,~Error,~Out,~layout,~route,~same,~valid,~Ops,~User,~declaration,~body,id,owner,Settings.member(id,ids))
def command_collect(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),ids:List<&2,U32>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,U32>:
  command_metadata(~S,~WC,~C,~R,~E,~Error,~Out,~layout,~route,~same,~valid,~Ops,~User,~declaration,~body,ids,Cmd.metadata(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
def command(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Collector<Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  Collector{owner,command_collect(~S,~WC,~C,~R,~E,~Error,~Out,~layout,~route,~same,~valid,~Ops,~User,~declaration,~body)}
def collected_right(~L:Type,~R:Type,left:L,leftIds:List<&2,U32>,result:R & List<&2,U32>) -> Product.Owner<L,R> & List<&2,U32>:
  match result:
    case (right,rightIds):(Product.Owner{left,right},List.append(&2,U32,leftIds,rightIds))
def collected_left(~L:Type,~R:Type,rightCollect:List<&2,U32> -> R -> R & List<&2,U32>,ids:List<&2,U32>,right:R,result:L & List<&2,U32>) -> Product.Owner<L,R> & List<&2,U32>:
  match result:
    case (left,leftIds):collected_right(~L,~R,left,leftIds,rightCollect(ids,right))
def collect_pair(~L:Type,~R:Type,leftCollect:List<&2,U32> -> L -> L & List<&2,U32>,rightCollect:List<&2,U32> -> R -> R & List<&2,U32>,+ids:List<&2,U32>,owners:Product.Owner<L,R>) -> Product.Owner<L,R> & List<&2,U32>:
  match owners:
    case Product.Owner{left,right}:collected_left(~L,~R,rightCollect,ids,right,leftCollect(ids,left))
def join(~L:Type,~R:Type,left:Collector<L>,right:Collector<R>) -> Collector<Product.Owner<L,R>>:
  match left right:
    case Collector{left,lcollect} Collector{right,rcollect}:Collector{Product.Owner{left,right},ids => owners => collect_pair(~L,~R,lcollect,rcollect,ids,owners)}
def collected(~Owners:Type,ids:List<&2,U32>,collector:Collector<Owners>) -> Owners & List<&2,U32>:
  match collector:
    case Collector{owners,collect}:collect(ids,owners)

# Unlike applicability checks, retention reads the actual queue even if its
# World registration is currently refused. This keeps both affine payloads and
# their unapplied identity history available for retry and pending-save refusal.
def collect(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Data,~Owners:Type,~selection:Tree.Selection(~S,~WC,~C,~R,~E,~Error,~Out,~Owners),ids:List<&2,U32>,owners:Owners) -> Owners & List<&2,U32>:
  collected(~Owners,ids,selection(Family,plain(~S,~WC,~C,~R,~E,~Error,~Out),command(~S,~WC,~C,~R,~E,~Error,~Out),join,owners))
