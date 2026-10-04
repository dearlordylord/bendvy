import Base
import ./dispatcher.bend as D
import ./schedule.bend as Q
import ./capture.bend as C
import ./types.bend as T

def names(values:List<&2,D.Requirement>) -> String:
  match values:
    case Nil{}: ""
    case Con{D.ResourceRequired{name},tail}: "resource:" ++ name ++ ";" ++ names(tail)
    case Con{D.ServiceRequired{name},tail}: "service:" ++ name ++ ";" ++ names(tail)
    case Con{D.StateRequired{name},tail}: "state:" ++ name ++ ";" ++ names(tail)
def capture_final(count:U32,result:C.Local & T.Four) -> String:
  match result:
    case (_,T.Four{a,b,c,d}): U32.show(count) ++ ":" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def capture_result(result:C.Local & U32) -> String:
  match result:
    case (owner,count): capture_final(count,C.observe(owner))
def twice(style:C.Style,result:C.Local & U32) -> String:
  match result:
    case (owner,_): capture_result(C.invoke(style,owner))
def checks(+nodes:List<&2,Q.Node>) -> String:
  "present=" ++ names(D.preflight(nodes,True{},True{},True{},"MotionLedger","MotionMode")) ++ "\n" ++
  "missing=" ++ names(D.preflight(nodes,False{},False{},True{},"MotionLedger","MotionMode")) ++ "\n" ++
  "returned=" ++ twice(C.Returned{},C.invoke(C.Returned{},C.initial())) ++ "\n" ++
  "regenerated=" ++ twice(C.Regenerated{},C.invoke(C.Regenerated{},C.initial()))
def main() -> String:
  checks([Q.Nested{[Q.Call{Q.System{1,"B",Q.B{},True{},True{},True{},True{}},Q.BFail{}}]},Q.Call{Q.System{2,"Tail",Q.Tail{},False{},False{},False{},False{}},Q.Normal{}}])
