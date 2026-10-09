import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/registered-v1/log.bend as Log
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/registered-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/registered-v1/observation.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P

type DirectView is Data: DirectView{log:O.LogView,value:Maybe<&2,List<&2,U32>>,errors:List<&2,Log.Refusal>,refused:List<&2,O.RowView>}
def log_view_only(result:Log.Log<P.Payload> & O.LogView) -> O.LogView:
  match result:
    case (_,view): view
def row_only(result:Log.Row<P.Payload> & O.RowView) -> O.RowView:
  match result:
    case (_,view): view
def data_value(value:Maybe<&1,List<&2,U32>>) -> Maybe<&2,List<&2,U32>>:
  match value:
    case None{}: None{}
    case Some{value}: Some{value}
def reading_view(result:Log.Reading<P.Payload,List<&2,U32>>) -> DirectView:
  match result:
    case Log.Reading{log,value,errors}: DirectView{log_view_only(O.log_view(log)),data_value(value),errors,[]}
def published_view(result:Log.Published<P.Payload>) -> DirectView:
  match result:
    case Log.Published{log}: DirectView{log_view_only(O.log_view(log)),None{},[],[]}
    case Log.Refused{log,incoming,error}: DirectView{log_view_only(O.log_view(log)),None{},[error],[row_only(O.row(Log.Row{1,incoming}))]}
def owned_value(result:Array<U32> & List<&2,U32>) -> Maybe<&2,List<&2,U32>>:
  match result:
    case (_,value): Some{value}
def owned_option(owner:Maybe<&1,Array<U32>>) -> Maybe<&2,List<&2,U32>>:
  match owner:
    case None{}: None{}
    case Some{owner}: owned_value(O.array(owner))
def owned_view(result:Log.Reading<P.Payload,Array<U32>>) -> DirectView:
  match result:
    case Log.Reading{log,value,errors}: DirectView{log_view_only(O.log_view(log)),owned_option(value),errors,[]}
def normal() -> Log.Log<P.Payload>:
  Log.Log{[1,2],[F.packet(1,11),F.packet(2,21)]}
def missing() -> DirectView:
  reading_view(Log.read(~P.Payload,~List<&2,U32>,~P.at,~P.first_reader,normal(),99))
def duplicate_rows() -> DirectView:
  reading_view(Log.read(~P.Payload,~List<&2,U32>,~P.at,~P.first_reader,Log.Log{[1],[F.packet(1,11),F.packet(1,21)]},1))
def duplicate_publication() -> DirectView:
  published_view(Log.publish(~P.Payload,1,normal(),P.Payload{ANode{ANode{ALeaf{91},ALeaf{92}},ANode{ALeaf{93},ALeaf{94}}},ANode{ALeaf{191},ALeaf{192}}}))
def owned_output() -> DirectView:
  owned_view(Log.read(~P.Payload,~Array<U32>,~P.at,~P.owned_reader,normal(),1))
