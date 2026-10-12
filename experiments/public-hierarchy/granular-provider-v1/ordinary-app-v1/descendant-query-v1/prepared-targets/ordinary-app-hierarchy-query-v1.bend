import Base
import ./ordinary-app-hierarchy.bend as App
import ./ordinary-app-relation.bend as Relation
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./relation-types.bend as G
import ./relation-commands.bend as A
import ./hierarchy-traversal-provider.bend as H
import ./hierarchy-provider.bend as Path
import ./hierarchy-traversal.bend as Traversal
import ./ordinary-query-declaration.bend as Query
import ./ordinary-system.bend as System
import ./compose.bend as Q
import ./transaction.bend as Tx
import ./world.bend as W

# Keep the hierarchy diagnostic and existing composition result separately.
# The gameplay callback receives only the retained declaration's opaque owner.
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~Out:Data,path:Maybe<&2,Path.Path<S>>,result:Q.Executed<Relation.World(~S,~C,~R,~E),Q.Error<U>,Out>) -> Relation.World(~S,~C,~R,~E) & (Maybe<&2,Path.Path<S>> & Maybe<&2,(Tx.Outcome<Q.Error<U>> & List<&2,Out>)>):
  match result:
    case Q.Executed{world,outcome,values}:(world,(path,Some{(outcome,values)}))
def selected_path(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Arg:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,Ops(Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>)>,~body:@-H:Type -> @-caps:Ops(H) -> Arg -> H -> H & (Tx.Outcome<U> & Out),args:Arg,cursor:U32,observed:Relation.World(~S,~C,~R,~E) & Maybe<&2,Path.Path<S>>) -> Relation.World(~S,~C,~R,~E) & (Maybe<&2,Path.Path<S>> & Maybe<&2,(Tx.Outcome<Q.Error<U>> & List<&2,Out>)>):
  match observed:
    case (world,None{}):(world,(None{},None{}))
    case (world,Some{Path.Incomplete{handles,pending}}):(world,(Some{Path.Incomplete{handles,pending}},None{}))
    case (world,Some{Path.Complete{+handles}}):executed(~S,~C,~R,~E,~U,~Out,Some{Path.Complete{handles}},Q.reserved(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Ops,~Arg,~U,~Out,~System.plan(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Ops,~Arg,~U,~Out,~query,~body),~body,args,cursor,(world,handles)))
def visit_descendants_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Ops:Type -> Type,~Arg:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,Ops(Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>)>,~body:@-H:Type -> @-caps:Ops(H) -> Arg -> H -> H & (Tx.Outcome<U> & Out),app:App.Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>,order:Traversal.Order,args:Arg,cursor:U32) -> App.Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & (Maybe<&2,Path.Path<S>> & Maybe<&2,(Tx.Outcome<Q.Error<U>> & List<&2,Out>)>):
  match app:
    case Build.Registered{world,owners,recipe,debug}:App.returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~(Maybe<&2,Path.Path<S>> & Maybe<&2,(Tx.Outcome<Q.Error<U>> & List<&2,Out>)>),owners,recipe,debug,selected_path(~S,~C,~R,~E,~Ops,~Arg,~U,~Out,~query,~body,args,cursor,H.lookup_descendants(~S,~C,~R,~E,~hierarchy,world,H.Descendants{target,order})))
