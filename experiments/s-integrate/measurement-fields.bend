# Lossless measurement-only encoding. Every scalar comes from actual provider observations.
import Base
import ./types.bend as T
import ./storage.bend as S
import ./observations.bend as O
import ./host-render.bend as J

def four(value:T.Four) -> String:
  match value:
    case T.Four{a,b,c,d}: J.render_list(U32,U32.show,[a,b,c,d])

def motion_main(value:T.PositionView) -> String:
  match value:
    case T.PositionView{values,frame}: "[" ++ four(values) ++ "," ++ U32.show(frame) ++ "]"
def motion_aux(value:T.VelocityView) -> String:
  match value:
    case T.VelocityView{values,moving}: "[" ++ four(values) ++ "," ++ J.render_boolean(moving) ++ "]"
def motion_flag(value:T.Selected) -> String:
  match value:
    case T.Selected{group}: U32.show(group)
def motion_query_row(value:O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>) -> String:
  match value:
    case O.QueryRow{S.Handle{namespace,id},main,aux,flag}:
      J.render_concat(["[[",U32.show(namespace),",",U32.show(id),"],",motion_main(main),",",J.render_optional(T.VelocityView,motion_aux,aux),",",J.render_optional(T.Selected,motion_flag,flag),"]"])
def motion_query(values:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> String: J.render_list(O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,motion_query_row,values)
def motion_row(value:O.RowView<T.PositionView,T.VelocityView,T.Selected>) -> String:
  match value:
    case O.RowView{id,main,aux,flag,added,changed}:
      J.render_concat(["[",U32.show(id),",",J.render_optional(T.PositionView,motion_main,main),",",J.render_optional(T.VelocityView,motion_aux,aux),",",J.render_optional(T.Selected,motion_flag,flag),",",U32.show(added),",",U32.show(changed),"]"])
def motion_world(value:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> String:
  match value:
    case O.WorldView{namespace,next,rows,pending,ledger,mode}:
      J.render_concat(["{\"namespace\":",U32.show(namespace),",\"next\":",U32.show(next),",\"rows\":",J.render_list(O.RowView<T.PositionView,T.VelocityView,T.Selected>,motion_row,rows),",\"pending\":",J.render_list(O.PendingView<T.PositionView,T.VelocityView,T.Selected>,J.render_pending(T.PositionView,T.VelocityView,T.Selected,J.render_position,J.render_velocity,J.render_selected),pending),",\"ledger\":",J.render_optional(T.LedgerView,J.render_ledger,ledger),",\"mode\":",J.render_motion_mode(mode),"}"])

def health_main(value:T.VitalsView) -> String:
  match value:
    case T.VitalsView{values,reserve,class}: "[" ++ four(values) ++ "," ++ U32.show(reserve) ++ "," ++ U32.show(class) ++ "]"
def health_aux(value:T.ArmorView) -> String:
  match value:
    case T.ArmorView{values,grade}: "[" ++ four(values) ++ "," ++ U32.show(grade) ++ "]"
def health_flag(value:T.Tracked) -> String:
  match value:
    case T.Tracked{group}: U32.show(group)
def health_query_row(value:O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>) -> String:
  match value:
    case O.QueryRow{S.Handle{namespace,id},main,aux,flag}:
      J.render_concat(["[[",U32.show(namespace),",",U32.show(id),"],",health_main(main),",",J.render_optional(T.ArmorView,health_aux,aux),",",J.render_optional(T.Tracked,health_flag,flag),"]"])
def health_query(values:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> String: J.render_list(O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,health_query_row,values)
def health_row(value:O.RowView<T.VitalsView,T.ArmorView,T.Tracked>) -> String:
  match value:
    case O.RowView{id,main,aux,flag,added,changed}:
      J.render_concat(["[",U32.show(id),",",J.render_optional(T.VitalsView,health_main,main),",",J.render_optional(T.ArmorView,health_aux,aux),",",J.render_optional(T.Tracked,health_flag,flag),",",U32.show(added),",",U32.show(changed),"]"])
def health_world(value:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> String:
  match value:
    case O.WorldView{namespace,next,rows,pending,ledger,mode}:
      J.render_concat(["{\"namespace\":",U32.show(namespace),",\"next\":",U32.show(next),",\"rows\":",J.render_list(O.RowView<T.VitalsView,T.ArmorView,T.Tracked>,health_row,rows),",\"pending\":",J.render_list(O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>,J.render_pending(T.VitalsView,T.ArmorView,T.Tracked,J.render_vitals,J.render_armor,J.render_tracked),pending),",\"ledger\":",J.render_optional(T.LedgerView,J.render_ledger,ledger),",\"mode\":",J.render_health_mode(mode),"}"])
