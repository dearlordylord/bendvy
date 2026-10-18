import Base
import types.bend as T
def render_push(value: String,acc: String) -> String:
  match value:
    case SNil{}: acc
    case SCon{head,tail}: render_push(tail,SCon{head,acc})
def render_chunks(values: List<&2,String>,acc: String) -> String:
  match values:
    case Nil{}: String.reverse(acc)
    case Con{head,tail}: render_chunks(tail,render_push(head,acc))
def render_concat(values: List<&2,String>) -> String:
  render_chunks(values,"")

def render_boolean(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def render_four(value: T.Four) -> String:
  match value:
    case T.Four{a,b,c,d}: render_concat(["{\"a\":", U32.show(a), ",\"b\":", U32.show(b), ",\"c\":", U32.show(c), ",\"d\":", U32.show(d), "}"])

def render_position(value: T.PositionView) -> String:
  match value:
    case T.PositionView{coordinates,frame}: render_concat(["{\"coordinates\":", render_four(coordinates), ",\"frame\":", U32.show(frame), "}"])

def render_vitals(value: T.VitalsView) -> String:
  match value:
    case T.VitalsView{levels,reserve,class}: render_concat(["{\"levels\":", render_four(levels), ",\"reserve\":", U32.show(reserve), ",\"class\":", U32.show(class), "}"])

def render_velocity(value: T.VelocityView) -> String:
  match value:
    case T.VelocityView{rates,moving}: render_concat(["{\"rates\":", render_four(rates), ",\"moving\":", render_boolean(moving), "}"])

def render_armor(value: T.ArmorView) -> String:
  match value:
    case T.ArmorView{layers,grade}: render_concat(["{\"layers\":", render_four(layers), ",\"grade\":", U32.show(grade), "}"])

def render_ledger(value: T.LedgerView) -> String:
  match value:
    case T.LedgerView{totals,epoch}: render_concat(["{\"totals\":", render_four(totals), ",\"epoch\":", U32.show(epoch), "}"])

def render_selected(value: T.Selected) -> String:
  match value:
    case T.Selected{group}: render_concat(["{\"group\":", U32.show(group), "}"])

def render_tracked(value: T.Tracked) -> String:
  match value:
    case T.Tracked{group}: render_concat(["{\"group\":", U32.show(group), "}"])
