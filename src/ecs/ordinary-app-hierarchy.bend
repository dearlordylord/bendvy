import Base
import ./ordinary-app-relation.bend as Relation
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./relation-failure-reader.bend as Ord
import ./relation-types.bend as G
import ./relation-reorder.bend as Reorder
import ./hierarchy-traversal-provider.bend as H
import ./hierarchy-provider.bend as Path
import ./hierarchy-traversal.bend as Traversal
import ./relation-providers.bend as P
import ./relation-commands.bend as A
import ./transaction.bend as Tx
import ./world.bend as W

# One hierarchy declaration supplies the installed relation and traversal authority.
# Trusted setup projection of a hierarchy descriptor into its relation declaration.
# Hierarchy authority retains the descriptor, rather than relying on its display name.
def declaration(~S:Data,hierarchy:G.HierarchyDescriptor<S>) -> Ord.Declaration<S>:
  Ord.relation(~S,Reorder.descriptor(~S,hierarchy))
# Hierarchy App with the relation storage/notice wrappers and installed observer.
# Its World and registration owners are affine and returned by the operations below.
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Relation.Application(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold)
# Install hierarchy observation on the existing App, preserving World and owners.
# Does not create parent edges. See docs/parity/hierarchy.md for accepted App and
# traversal scenarios; relate_app followed by barrier_app establishes visible edges.
def install(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,Relation.World(~S,~C,~R,~E),Owners,Rows,prior,fold>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold):
  Relation.install(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,app)
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Value:Data,owners:Owners,recipe:Relation.Recipe(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold),debug:Bool,result:Relation.World(~S,~C,~R,~E) & Value) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Value:
  match result:
    case (world,value):(Build.Registered{world,owners,recipe,debug},value)
# Return the App and root of a valid target, including the target itself when it
# has no parent. Invalid targets or incomplete ancestor traversal return None.
# Reads current edges without applying queued changes.
def root_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,W.Handle<S>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~Maybe<&2,W.Handle<S>>,owners,recipe,debug,H.lookup_root(~S,~C,~R,~E,~hierarchy,world,target))
# Return the App and raw ancestor path, nearest parent first, excluding target.
# None means invalid target; Some may be Complete or an Incomplete diagnostic.
# The seed is validated; this raw path is not a query that revalidates every member.
def ancestors_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,Path.Path<S>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~Maybe<&2,Path.Path<S>>,owners,recipe,debug,H.lookup_ancestors(~S,~C,~R,~E,~hierarchy,world,target))
# Return the App and raw descendants, excluding target, in requested depth-first
# or breadth-first order using stored child order. None means invalid target.
# Some Incomplete preserves visited/pending diagnostics; forged cyclic graphs are
# not promised complete traversal. Queued reparenting needs a barrier first.
def descendants_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>,order:Traversal.Order) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,Path.Path<S>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~Maybe<&2,Path.Path<S>>,owners,recipe,debug,H.lookup_descendants(~S,~C,~R,~E,~hierarchy,world,H.Descendants{target,order}))
# Stage a child (source) to parent (target) edge, returning App, queue status and
# transaction outcome separately. Applied hierarchy edges enforce one parent and
# reject self/cycle violations; barrier-time rejection appears as relation notices.
def relate_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),targets:P.Targets<S>,outcome:Tx.Outcome<Error>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,Tx.Outcome<Error>>:
  Relation.relate_app(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,~Error,app,targets,outcome)
# Apply all pending World structural commands and return the hierarchy App.
# Use before traversal or observation when queued graph changes must be visible.
def barrier_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold)) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold):
  Relation.barrier_app(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,app)
# Return the hierarchy App and optional combined snapshot under flag enablement.
# Observation does not itself apply pending graph commands.
def snapshot_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),flag:Bool) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Relation.ObservedRows(~S,~Rows)>>>:
  Relation.snapshot_app(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,app,flag)

# Stage an exact permutation of a parent's complete current child set, then finish
# with the supplied transaction outcome. Queue admission is not application success.
# Missing, duplicate, unrelated or mismatched child sets are rejected at application
# without changing edges, with a failure notice; apply through barrier_app.
def reorder_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),args:Reorder.Args<S>,outcome:Tx.Outcome<Error>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,Tx.Outcome<Error>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:Relation.queued(~S,~C,~R,~E,~declaration(~S,hierarchy),~Relation.builtin_row(~S),~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,outcome,Reorder.invoke(~S,~C,~R,~E,~hierarchy,~A.QueueStatus,~Reorder.body(~S),args,Tx.begin(~Relation.World(~S,~C,~R,~E),~A.Notice<S,E>,world)))
