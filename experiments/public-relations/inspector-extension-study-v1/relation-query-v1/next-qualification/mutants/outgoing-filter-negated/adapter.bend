import Base
import selection.bend as Select
import query.bend as Query
import traversal.bend as Traverse
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/relation-types.bend as G
import core-v1/src/ecs/relation-commands.bend as A
import core-v1/src/ecs/relation-query.bend as RQ
import core-v1/src/ecs/query.bend as Modes

# Real Inspector Frame, not a fabricated transaction. Graph is detached Data;
# Store components/resources remain arbitrary affine Type owners.
def graph_joined(~S:Data,~C:Type,~R:Type,~E:Data,cursor:U32,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & G.Graph<S>) -> I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & G.Graph<S>:
  (world,graph)=observed
  (I.Frame{world,cursor},graph)
def graph(~S:Data,~C:Type,~R:Type,~E:Data,frame:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>) -> I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & G.Graph<S>:
  match frame:
    case I.Frame{world,cursor}:graph_joined(~S,~C,~R,~E,cursor,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~G.Graph<S>,RQ.graph_read(~S,~C),world))
# Experimental mutant: only the single outgoing Present filter is negated.
def outgoing_presence(~S:Data,spec:RQ.Spec<S>) -> Bool:
  match spec:
    case RQ.Spec{[RQ.Requirement{_,_,RQ.Outgoing{},Modes.Present{},False{}}]}:True{}
    case _:False{}
def flipped_selection(negate:Bool,selected:Bool) -> Bool:
  match negate:
    case True{}:Bool.not(selected)
    case False{}:selected
def filtered_selection(~S:Data,spec:RQ.Spec<S>,selected:Bool) -> Bool:
  flipped_selection(outgoing_presence(~S,spec),selected)

def accepted(~S:Data,observed:Bool & RQ.Row<S,Unit>) -> Bool:
  (selected,row)=observed
  selected
def cells(~S:Data,observed:Bool & RQ.Row<S,Unit>) -> List<&2,RQ.Cell<S>>:
  match observed:
    case (_,RQ.Row{_,items,_}):items
def matched(~S:Data,~C:Type,~R:Type,~E:Data,~spec:RQ.Spec<S>,target:W.Handle<S>,observed:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & G.Graph<S>) -> I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool:
  (frame,graph)=observed
  (frame,filtered_selection(~S,spec,accepted(~S,RQ.spec_rows(~S,~Unit,spec,graph,target,Unit{}))))
def matches(~S:Data,~C:Type,~R:Type,~E:Data,~spec:RQ.Spec<S>,frame:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,target:W.Handle<S>) -> I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool:
  matched(~S,~C,~R,~E,~spec,target,graph(~S,~C,~R,~E,frame))
def projected(~S:Data,~C:Type,~R:Type,~E:Data,~spec:RQ.Spec<S>,target:W.Handle<S>,observed:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & G.Graph<S>) -> I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,RQ.Cell<S>>:
  (frame,graph)=observed
  (frame,cells(~S,RQ.spec_rows(~S,~Unit,spec,graph,target,Unit{})))
def project(~S:Data,~C:Type,~R:Type,~E:Data,~spec:RQ.Spec<S>,frame:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,target:W.Handle<S>) -> I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,RQ.Cell<S>>:
  projected(~S,~C,~R,~E,~spec,target,graph(~S,~C,~R,~E,frame))
# Closed relation requirement list supports both directions, required/optional,
# presence/absence filters and every declared projection key/order unchanged.
def relations(~S:Data,~C:Type,~R:Type,~E:Data,~spec:RQ.Spec<S>) -> Select.Selection<I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,List<&2,RQ.Cell<S>>>:
  Select.Selection{matches(~S,~C,~R,~E,~spec),project(~S,~C,~R,~E,~spec)}
# Recursive Product/map component providers are reused, not reimplemented.
# Query.grant performs World namespace/liveness checks before public lookup.
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~component:Select.Selection<I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,V>,~spec:RQ.Spec<S>) -> Query.ReadQuery<I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,Select.Product<V,List<&2,RQ.Cell<S>>>>:
  Query.grant(~I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S,~Select.Product<V,List<&2,RQ.Cell<S>>>,~Select.pair(~I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S,~V,~List<&2,RQ.Cell<S>>,~component,~relations(~S,~C,~R,~E,~spec)),~Traverse.inspect_world(~S,~A.Store<S,C>,~R,~A.Notice<S,E>))

