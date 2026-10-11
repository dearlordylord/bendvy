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
def declaration(~S:Data,hierarchy:G.HierarchyDescriptor<S>) -> Ord.Declaration<S>:
  Ord.relation(~S,Reorder.descriptor(~S,hierarchy))
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Relation.Application(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold)
def install(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,Relation.World(~S,~C,~R,~E),Owners,Rows,prior,fold>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold):
  Relation.install(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,app)
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Value:Data,owners:Owners,recipe:Relation.Recipe(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold),debug:Bool,result:Relation.World(~S,~C,~R,~E) & Value) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Value:
  match result:
    case (world,value):(Build.Registered{world,owners,recipe,debug},value)
def root_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,W.Handle<S>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~Maybe<&2,W.Handle<S>>,owners,recipe,debug,H.lookup_root(~S,~C,~R,~E,~hierarchy,world,target))
def ancestors_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,Path.Path<S>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~Maybe<&2,Path.Path<S>>,owners,recipe,debug,H.lookup_ancestors(~S,~C,~R,~E,~hierarchy,world,target))
def descendants_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),target:W.Handle<S>,order:Traversal.Order) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,Path.Path<S>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:returned(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold,~Maybe<&2,Path.Path<S>>,owners,recipe,debug,H.lookup_descendants(~S,~C,~R,~E,~hierarchy,world,H.Descendants{target,order}))
def relate_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),targets:P.Targets<S>,outcome:Tx.Outcome<Error>) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,Tx.Outcome<Error>>:
  Relation.relate_app(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,~Error,app,targets,outcome)
def barrier_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold)) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold):
  Relation.barrier_app(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,app)
def snapshot_app(~S:Data,~C:Type,~R:Type,~E:Data,~hierarchy:G.HierarchyDescriptor<S>,~Owners:Type,~Rows:Data,~prior:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold),flag:Bool) -> Application(~S,~C,~R,~E,~hierarchy,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Relation.ObservedRows(~S,~Rows)>>>:
  Relation.snapshot_app(~S,~C,~R,~E,~declaration(~S,hierarchy),~Owners,~Rows,~prior,~fold,app,flag)
