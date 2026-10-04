# Diagnostic compact encoding over actual complete observations; never a replacement for full-field correctness.
import Base
import ./types.bend as T
import ./storage.bend as S
import ./observations.bend as O

def mix(a:U32,b:U32) -> U32: U32.add(U32.mul(a,65599),b)
def four(seed:U32,value:T.Four) -> U32:
  match value:
    case T.Four{a,b,c,d}: mix(mix(mix(mix(seed,a),b),c),d)
def boolean(value:Bool) -> U32:
  match value:
    case False{}: 0
    case True{}: 1
def ledger(value:Maybe<&2,T.LedgerView>) -> U32:
  match value:
    case None{}: 0
    case Some{T.LedgerView{values,epoch}}: mix(four(1,values),epoch)

def motion_main(value:T.PositionView) -> U32:
  match value:
    case T.PositionView{values,frame}: mix(four(1,values),frame)
def motion_maybe_main(value:Maybe<&2,T.PositionView>) -> U32:
  match value:
    case None{}: 0
    case Some{main}: mix(1,motion_main(main))
def motion_aux(value:Maybe<&2,T.VelocityView>) -> U32:
  match value:
    case None{}: 0
    case Some{T.VelocityView{values,moving}}: mix(four(1,values),boolean(moving))
def motion_flag(value:Maybe<&2,T.Selected>) -> U32:
  match value:
    case None{}: 0
    case Some{T.Selected{group}}: mix(1,group)
def motion_mode(value:T.MotionMode) -> U32:
  match value:
    case T.MotionOn{}: 1
    case _: 0
def motion_query_row(value:O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>) -> U32:
  match value:
    case O.QueryRow{S.Handle{namespace,id},main,aux,flag}: mix(mix(mix(mix(mix(1,namespace),id),motion_main(main)),motion_aux(aux)),motion_flag(flag))
def motion_query(values:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,seed:U32) -> U32:
  match values:
    case Nil{}: mix(seed,0)
    case Con{head,tail}: motion_query(tail,mix(seed,motion_query_row(head)))
def motion_row(value:O.RowView<T.PositionView,T.VelocityView,T.Selected>) -> U32:
  match value:
    case O.RowView{id,main,aux,flag,added,changed}: mix(mix(mix(mix(mix(mix(1,id),motion_maybe_main(main)),motion_aux(aux)),motion_flag(flag)),added),changed)
def motion_rows(values:List<&2,O.RowView<T.PositionView,T.VelocityView,T.Selected>>,seed:U32) -> U32:
  match values:
    case Nil{}: mix(seed,0)
    case Con{head,tail}: motion_rows(tail,mix(seed,motion_row(head)))
def motion_bundle(value:O.BundleView<T.PositionView,T.VelocityView,T.Selected>) -> U32:
  match value:
    case O.BundleView{main,aux,flag}: mix(mix(mix(1,motion_maybe_main(main)),motion_aux(aux)),motion_flag(flag))
def motion_pending_row(value:O.PendingView<T.PositionView,T.VelocityView,T.Selected>) -> U32:
  match value:
    case O.SpawnView{id,bundle}: mix(mix(1,id),motion_bundle(bundle))
    case O.MainView{id,main}: mix(mix(2,id),motion_main(main))
    case O.FlagView{id,T.Selected{group}}: mix(mix(3,id),group)
    case O.RemoveMainView{id}: mix(4,id)
    case O.RemoveFlagView{id}: mix(5,id)
    case O.DespawnView{id}: mix(6,id)
def motion_pending(values:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>,seed:U32) -> U32:
  match values:
    case Nil{}: mix(seed,0)
    case Con{head,tail}: motion_pending(tail,mix(seed,motion_pending_row(head)))
def motion_world(value:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> U32:
  match value:
    case O.WorldView{namespace,next,rows,pending,resource,mode}: mix(mix(mix(mix(mix(mix(1,namespace),next),motion_rows(rows,1)),motion_pending(pending,1)),ledger(resource)),motion_mode(mode))

def health_main(value:T.VitalsView) -> U32:
  match value:
    case T.VitalsView{values,reserve,class}: mix(mix(four(1,values),reserve),class)
def health_maybe_main(value:Maybe<&2,T.VitalsView>) -> U32:
  match value:
    case None{}: 0
    case Some{main}: mix(1,health_main(main))
def health_aux(value:Maybe<&2,T.ArmorView>) -> U32:
  match value:
    case None{}: 0
    case Some{T.ArmorView{values,grade}}: mix(four(1,values),grade)
def health_flag(value:Maybe<&2,T.Tracked>) -> U32:
  match value:
    case None{}: 0
    case Some{T.Tracked{group}}: mix(1,group)
def health_mode(value:T.HealthMode) -> U32:
  match value:
    case T.HealthOn{}: 1
    case _: 0
def health_query_row(value:O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>) -> U32:
  match value:
    case O.QueryRow{S.Handle{namespace,id},main,aux,flag}: mix(mix(mix(mix(mix(1,namespace),id),health_main(main)),health_aux(aux)),health_flag(flag))
def health_query(values:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,seed:U32) -> U32:
  match values:
    case Nil{}: mix(seed,0)
    case Con{head,tail}: health_query(tail,mix(seed,health_query_row(head)))
def health_row(value:O.RowView<T.VitalsView,T.ArmorView,T.Tracked>) -> U32:
  match value:
    case O.RowView{id,main,aux,flag,added,changed}: mix(mix(mix(mix(mix(mix(1,id),health_maybe_main(main)),health_aux(aux)),health_flag(flag)),added),changed)
def health_rows(values:List<&2,O.RowView<T.VitalsView,T.ArmorView,T.Tracked>>,seed:U32) -> U32:
  match values:
    case Nil{}: mix(seed,0)
    case Con{head,tail}: health_rows(tail,mix(seed,health_row(head)))
def health_bundle(value:O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>) -> U32:
  match value:
    case O.BundleView{main,aux,flag}: mix(mix(mix(1,health_maybe_main(main)),health_aux(aux)),health_flag(flag))
def health_pending_row(value:O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>) -> U32:
  match value:
    case O.SpawnView{id,bundle}: mix(mix(1,id),health_bundle(bundle))
    case O.MainView{id,main}: mix(mix(2,id),health_main(main))
    case O.FlagView{id,T.Tracked{group}}: mix(mix(3,id),group)
    case O.RemoveMainView{id}: mix(4,id)
    case O.RemoveFlagView{id}: mix(5,id)
    case O.DespawnView{id}: mix(6,id)
def health_pending(values:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>,seed:U32) -> U32:
  match values:
    case Nil{}: mix(seed,0)
    case Con{head,tail}: health_pending(tail,mix(seed,health_pending_row(head)))
def health_world(value:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> U32:
  match value:
    case O.WorldView{namespace,next,rows,pending,resource,mode}: mix(mix(mix(mix(mix(mix(1,namespace),next),health_rows(rows,1)),health_pending(pending,1)),ledger(resource)),health_mode(mode))
