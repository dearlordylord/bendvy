import Base
import report-doc.bend as Doc
import motion-doc-world.bend as DW
import motion-dispose.bend as Dispose
import motion-program.bend as P
import motion-systems.bend as S
import motion-registration.bend as Reg
import motion-owner-observe.bend as O
import motion-observe.bend as W
import motion-boundary.bend as B
import motion-schedule.bend as Schedule
import motion.bend as F
import ../../../../src/ecs/world.bend as World
import ../dense-runtime-v1/types.bend as T

def status(value:P.Status) -> String:
  match value:
    case P.Complete{}:"Complete"
    case P.Stopped{reason}:"Stopped{" ++ W.audit_effect(reason) ++ "}"
def world_text(value:F.World() & Doc.Doc) -> Doc.Doc:
  match value:
    case (_,text):text
def owner_text(value:S.Owners & Doc.Doc) -> Doc.Doc:
  match value:
    case (_,text):text
def final_observed(prefix:Doc.Doc,value:P.State & P.Snapshot) -> Doc.Doc:
  match value:
    case (P.State{_,namespace,boundaries,schedules,result},P.Snapshot{world,owners,ids}):Doc.concat([prefix,Doc.text("final={namespace=" ++ U32.show(namespace) ++ ";ids=" ++ List.show(&2,U32,U32.show,ids) ++ ";world={"),world,Doc.text("};owners={"),owners,Doc.text("};boundaries="),Doc.show(~B.Boundary,~B.render,boundaries),Doc.text(";schedules=" ++ List.show(&2,String,W.audit_effect,schedules) ++ ";status=" ++ status(result) ++ "}\n")])
def final(prefix:Doc.Doc,value:P.State) -> Doc.Doc:final_observed(prefix,P.observe(value))
def write(value:Doc.Doc) -> IO(Unit):Doc.write(value)
