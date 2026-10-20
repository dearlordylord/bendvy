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

# Query membership requires a live handle independently of its declaration.
# Preserve the raw traversal path; this only chooses the query invocation list.
def live_prepend(~S:Data,~C:Type,~R:Type,~E:Data,selected:Bool,handle:W.Handle<S>,observed:Relation.World(~S,~C,~R,~E) & List<&2,W.Handle<S>>) -> Relation.World(~S,~C,~R,~E) & List<&2,W.Handle<S>>:
  match selected observed:
    case True{} Tuple{world,handles}:(world,handle <> handles)
    case False{} Tuple{world,handles}:(world,handles)
def live_checked(~S:Data,~C:Type,~R:Type,~E:Data,handle:W.Handle<S>,observed:Relation.World(~S,~C,~R,~E) & Bool,next:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & List<&2,W.Handle<S>>) -> Relation.World(~S,~C,~R,~E) & List<&2,W.Handle<S>>:
  match observed:
    case (world,selected):live_prepend(~S,~C,~R,~E,selected,handle,next(world))
def live_handles(~S:Data,~C:Type,~R:Type,~E:Data,handles:List<&2,W.Handle<S>>,world:Relation.World(~S,~C,~R,~E)) -> Relation.World(~S,~C,~R,~E) & List<&2,W.Handle<S>>:
  match handles:
    case []:(world,[])
    case +handle <> rest:live_checked(~S,~C,~R,~E,handle,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,handle),world => live_handles(~S,~C,~R,~E,rest,world))

# Keep the hierarchy diagnostic and existing composition result separately.
# The gameplay callback receives only the retained declaration's opaque owner.
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~Out:Data,path:Maybe<&2,Path.Path<S>>,result:Q.Executed<Relation.World(~S,~C,~R,~E),Q.Error<U>,Out>) -> Relation.World(~S,~C,~R,~E) & DTO.Product<Maybe<&2,Path.Path<S>>,Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<U>>,List<&2,Out>>>>:
  match result:
    case Q.Executed{world,outcome,values}:(world,DTO.Product{path,Some{DTO.Product{outcome,values}}})
def complete_live(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Arg:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,Ops(Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>)>,~body:@-H:Type -> @-caps:Ops(H) -> Arg -> H -> H & (Tx.Outcome<U> & Out),path:Maybe<&2,Path.Path<S>>,args:Arg,cursor:U32,observed:Relation.World(~S,~C,~R,~E) & List<&2,W.Handle<S>>) -> Relation.World(~S,~C,~R,~E) & DTO.Product<Maybe<&2,Path.Path<S>>,Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<U>>,List<&2,Out>>>>:
  executed(~S,~C,~R,~E,~U,~Out,path,Q.reserved(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Ops,~Arg,~U,~Out,~System.plan(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Ops,~Arg,~U,~Out,~query,~body),~body,args,cursor,observed))
def selected_path(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Arg:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,Ops(Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>)>,~body:@-H:Type -> @-caps:Ops(H) -> Arg -> H -> H & (Tx.Outcome<U> & Out),args:Arg,cursor:U32,observed:Relation.World(~S,~C,~R,~E) & Maybe<&2,Path.Path<S>>) -> Relation.World(~S,~C,~R,~E) & DTO.Product<Maybe<&2,Path.Path<S>>,Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<U>>,List<&2,Out>>>>:
  match observed:
    case (world,None{}):(world,DTO.Product{None{},None{}})
    case (world,Some{Path.Incomplete{handles,pending}}):(world,DTO.Product{Some{Path.Incomplete{handles,pending}},None{}})
    case (world,Some{Path.Complete{+handles}}):complete_live(~S,~C,~R,~E,~Ops,~Arg,~U,~Out,~query,~body,Some{Path.Complete{handles}},args,cursor,live_handles(~S,~C,~R,~E,handles,world))
# Run a declared query over a complete descendant traversal and return the App.
# Invalid target yields (None, None); incomplete traversal retains its diagnostic
# but returns no execution result and invokes no partial gameplay callbacks.
# For a complete path, revalidate each handle, retain live members in traversal
# order, then apply the declaration's selectors and opaque-owner body. Preserve
# the original raw path separately from the execution outcome and output list.
# Transaction failure rolls back through ordinary query semantics and clears row
# outputs. args and cursor are supplied for this invocation; this does not register
# or advance an App reader. Structural commands still require an explicit barrier.
# Uses only declared capabilities; it does not widen authority to arbitrary graph
# access. See docs/parity/hierarchy.md, ordinary App descendant-query scenarios.
def visit_descendants_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Ops:Type -> Type,~Arg:Data,~U:Data,~Out:Data,~query:Query.Declaration<S,Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,Ops(Q.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>)>,~body:@-H:Type -> @-caps:Ops(H) -> Arg -> H -> H & (Tx.Outcome<U> & Out),app:App.Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>,order:Traversal.Order,args:Arg,cursor:U32) -> App.Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & DTO.Product<Maybe<&2,Path.Path<S>>,Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<U>>,List<&2,Out>>>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:App.returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~DTO.Product<Maybe<&2,Path.Path<S>>,Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<U>>,List<&2,Out>>>>,owners,recipe,debug,selected_path(~S,~C,~R,~E,~Ops,~Arg,~U,~Out,~query,~body,args,cursor,H.lookup_descendants(~S,~C,~R,~E,~hierarchy,world,H.Descendants{target,order})))
