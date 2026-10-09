import Base
import ../scenario-schema.bend as S
import ../scenario-queries.bend as Queries
import ../scenario-body.bend as Body
import ./app.bend as App
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/world.bend as W

# Independent detached fixture cursor. It is not borrowed from a registration.
type Observation is Data:
  Observation{cursor:U32,base:List<&2,IQ.ProjectedRow<S.Schema,Queries.base_view()>>,added:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,changed:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,without:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,withHealth:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>}

def collected_world(~Store:Type,base:List<&2,IQ.ProjectedRow<S.Schema,Queries.base_view()>>,added:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,changed:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,without:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,withHealth:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,frame:I.Frame<S.Schema,Store,Unit,Unit>) -> W.World<S.Schema,Store,Unit,Unit> & Maybe<&2,Observation>:
  match frame:
    case I.Frame{world,cursor}:(world,Some{Observation{cursor,base,added,changed,without,withHealth}})

def collected_withHealth(~Store:Type,base:List<&2,IQ.ProjectedRow<S.Schema,Queries.base_view()>>,added:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,changed:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,without:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,got:I.Frame<S.Schema,Store,Unit,Unit> & List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>) -> W.World<S.Schema,Store,Unit,Unit> & Maybe<&2,Observation>:
  match got:
    case (frame,withHealth):collected_world(~Store,base,added,changed,without,withHealth,frame)

def collected_without(~Store:Type,~withHealthQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,base:List<&2,IQ.ProjectedRow<S.Schema,Queries.base_view()>>,added:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,changed:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,got:I.Frame<S.Schema,Store,Unit,Unit> & List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>) -> W.World<S.Schema,Store,Unit,Unit> & Maybe<&2,Observation>:
  match got:
    case (frame,without):collected_withHealth(~Store,base,added,changed,without,IQ.each_composed(~I.Frame<S.Schema,Store,Unit,Unit>,~S.Schema,~Queries.filtered_view(),~O.inspect_query(~S.Schema,~Store,~Unit,~Unit,~Q.Frame<S.Schema,Store,Unit,Unit>,~Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),~Queries.filtered_view(),~withHealthQuery),frame))

def collected_changed(~Store:Type,~withoutQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~withHealthQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,base:List<&2,IQ.ProjectedRow<S.Schema,Queries.base_view()>>,added:List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>,got:I.Frame<S.Schema,Store,Unit,Unit> & List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>) -> W.World<S.Schema,Store,Unit,Unit> & Maybe<&2,Observation>:
  match got:
    case (frame,changed):collected_without(~Store,~withHealthQuery,base,added,changed,IQ.each_composed(~I.Frame<S.Schema,Store,Unit,Unit>,~S.Schema,~Queries.filtered_view(),~O.inspect_query(~S.Schema,~Store,~Unit,~Unit,~Q.Frame<S.Schema,Store,Unit,Unit>,~Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),~Queries.filtered_view(),~withoutQuery),frame))

def collected_added(~Store:Type,~changedQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~withoutQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~withHealthQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,base:List<&2,IQ.ProjectedRow<S.Schema,Queries.base_view()>>,got:I.Frame<S.Schema,Store,Unit,Unit> & List<&2,IQ.ProjectedRow<S.Schema,Queries.filtered_view()>>) -> W.World<S.Schema,Store,Unit,Unit> & Maybe<&2,Observation>:
  match got:
    case (frame,added):collected_changed(~Store,~withoutQuery,~withHealthQuery,base,added,IQ.each_composed(~I.Frame<S.Schema,Store,Unit,Unit>,~S.Schema,~Queries.filtered_view(),~O.inspect_query(~S.Schema,~Store,~Unit,~Unit,~Q.Frame<S.Schema,Store,Unit,Unit>,~Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),~Queries.filtered_view(),~changedQuery),frame))

def collected_base(~Store:Type,~addedQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~changedQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~withoutQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~withHealthQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,got:I.Frame<S.Schema,Store,Unit,Unit> & List<&2,IQ.ProjectedRow<S.Schema,Queries.base_view()>>) -> W.World<S.Schema,Store,Unit,Unit> & Maybe<&2,Observation>:
  match got:
    case (frame,base):collected_added(~Store,~changedQuery,~withoutQuery,~withHealthQuery,base,IQ.each_composed(~I.Frame<S.Schema,Store,Unit,Unit>,~S.Schema,~Queries.filtered_view(),~O.inspect_query(~S.Schema,~Store,~Unit,~Unit,~Q.Frame<S.Schema,Store,Unit,Unit>,~Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),~Queries.filtered_view(),~addedQuery),frame))

def collect(~Store:Type,~baseQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.Ops(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.base_view()>,~addedQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~changedQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~withoutQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,~withHealthQuery:O.Declaration<S.Schema,Q.Frame<S.Schema,Store,Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,Store,Unit,Unit>),I.Frame<S.Schema,Store,Unit,Unit>,Queries.filtered_view()>,debug:App.Debug,world:W.World<S.Schema,Store,Unit,Unit>) -> W.World<S.Schema,Store,Unit,Unit> & Maybe<&2,Observation>:
  match debug:
    case App.Disabled{}:(world,None{})
    case App.Enabled{}:collected_base(~Store,~addedQuery,~changedQuery,~withoutQuery,~withHealthQuery,IQ.each_composed(~I.Frame<S.Schema,Store,Unit,Unit>,~S.Schema,~Queries.base_view(),~O.inspect_query(~S.Schema,~Store,~Unit,~Unit,~Q.Frame<S.Schema,Store,Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,Store,Unit,Unit>),~Queries.base_view(),~baseQuery),I.Frame{world,0}))

def constructed(debug:App.Debug,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Observation>:
  collect(~S.constructed_store(),~Queries.constructed_base(),~Queries.constructed_base_added(),~Queries.constructed_base_changed(),~Queries.constructed_base_without_component(),~Queries.constructed_base_with_component(),debug,world)

def transient(debug:App.Debug,world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Observation>:
  collect(~S.transient_store(),~Queries.transient_base(),~Queries.transient_base_added(),~Queries.transient_base_changed(),~Queries.transient_base_without_component(),~Queries.transient_base_with_component(),debug,world)

def plain(debug:App.Debug,world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Observation>:
  collect(~S.plain_store(),~Queries.plain_base(),~Queries.plain_base_added(),~Queries.plain_base_changed(),~Queries.plain_base_without_component(),~Queries.plain_base_with_component(),debug,world)
