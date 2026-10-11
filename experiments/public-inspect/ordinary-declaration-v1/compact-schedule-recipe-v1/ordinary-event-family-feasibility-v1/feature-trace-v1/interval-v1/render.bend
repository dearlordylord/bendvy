import Base
import ../trace.bend as T
import ../consumer.bend as C
import ../types.bend as V
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
# Detached test grammar matching the original show_main output, not product reflection.
def boolean(b:Bool) -> String:
  match b:
    case True{}:"True{}"
    case False{}:"False{}"
def quoted(s:String) -> String:"\"" ++ s ++ "\""
def first(v:V.First) -> String:
  match v:
    case V.First{n}:"types.First{" ++ U32.show(n) ++ "}"
def second(v:V.Second) -> String:
  match v:
    case V.Second{b}:"types.Second{" ++ boolean(b) ++ "}"
def reading_first(r:Ev.Reading<V.First>) -> String:
  match r:
    case Ev.Reading{values,lagged}:"../../../../../../../../bendvy/src/ecs/event-runtime.Reading{" ++ List.show(&2,V.First,first,values) ++ ", " ++ boolean(lagged) ++ "}"
def reading_second(r:Ev.Reading<V.Second>) -> String:
  match r:
    case Ev.Reading{values,lagged}:"../../../../../../../../bendvy/src/ecs/event-runtime.Reading{" ++ List.show(&2,V.Second,second,values) ++ ", " ++ boolean(lagged) ++ "}"
def observation(o:C.Observation) -> String:
  match o:
    case C.FirstRead{reading,failed}:"consumer.FirstRead{" ++ reading_first(reading) ++ ", " ++ boolean(failed) ++ "}"
    case C.SecondRead{reading,failed}:"consumer.SecondRead{" ++ reading_second(reading) ++ ", " ++ boolean(failed) ++ "}"
    case C.Published{failed}:"consumer.Published{" ++ boolean(failed) ++ "}"
    case C.Rejected{}:"consumer.Rejected{}"
    case C.Framed{}:"consumer.Framed{}"
    case C.SetupUnavailable{}:"consumer.SetupUnavailable{}"
def inventory_text(value:Maybe<&2,List<&2,String>>) -> String:
  match value:
    case None{}:"None{}"
    case Some{values}:"Some{" ++ List.show(&2,String,quoted,values) ++ "}"
def completion_text(value:Maybe<&2,C.Observation>) -> String:
  match value:
    case None{}:"None{}"
    case Some{value}:"Some{" ++ observation(value) ++ "}"
def row(r:T.Row) -> String:
  match r:
    case T.Row{enabled,inventory,completion,physical}:"trace.Row{" ++ boolean(enabled) ++ ", " ++ inventory_text(inventory) ++ ", " ++ completion_text(completion) ++ ", " ++ quoted(physical) ++ "}"
def rows(rs:List<&2,T.Row>) -> String:List.show(&2,T.Row,row,rs)
