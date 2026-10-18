import Base
import ./world.bend as W
import ./compose.bend as Q
import ./transaction.bend as T
import ./local.bend as Local
import ./ordinary-capture-query.bend as O
import ./ordinary-query-declaration.bend as Decl
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-records.bend as Pair
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
# Library-derived query bindings retain the real capture owner and reader cursor.
def fields(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>) -> O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body> & Fields.Fields<S>:
  match owner:
    case O.Owner{Local.Instance{+ns,+id,+name,+access,capture},+cursor}:(O.Owner{Local.Instance{ns,id,name,access,capture},cursor},Fields.Fields{ns,id,name,access,cursor,name,Decl.clauses(~S,~Q.Frame<S,C,R,E>,~Ops(Q.Frame<S,C,R,E>),query),Fields.ComponentKind{}})
def folded(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),result:O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body> & Fields.Fields<S>) -> O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body> & List<&2,Fields.Fields<S>>:
  match result:
    case (owner,field):(owner,[field])
def fold(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),owner:O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>) -> O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body> & List<&2,Fields.Fields<S>>:
  folded(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,fields(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,owner))
type Appended<Before:Type,After:Type,L:Type> is Type:
  Appended{app:After}
  AppendRejected{app:Before,capture:L}
def appended(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,previous:Previous,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,result:O.Registration<W.World<S,C,R,E>,O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,L>) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,Build.Registered<S,W.World<S,C,R,E>,Previous & O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,Rows,observe,Pair.fold_pair(~S,~Previous,~O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,~previousFold,~fold(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body))>,L>:
  match result:
    case O.Rejected{world,capture}:AppendRejected{Build.Registered{world,previous,recipe,debug},capture}
    case O.Registered{world,owner}:Appended{Build.Registered{world,(previous,owner),recipe,debug}}
def register(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> A -> H -> H & (L & (T.Outcome<U> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,name:String,capture:L) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,Build.Registered<S,W.World<S,C,R,E>,Previous & O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,Rows,observe,Pair.fold_pair(~S,~Previous,~O.Owner<S,C,R,E,L,Ops,A,U,Out,query,body>,~previousFold,~fold(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body))>,L>:
  match app:
    case Build.Registered{world,previous,recipe,debug}:appended(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,~Previous,~Rows,~observe,~previousFold,previous,recipe,debug,O.define(~S,~C,~R,~E,~L,~Ops,~A,~U,~Out,~query,~body,world,name,capture))
