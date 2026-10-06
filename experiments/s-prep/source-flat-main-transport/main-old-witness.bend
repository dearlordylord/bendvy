import Base
import /tmp/bendvy-flat-main-transport-v2/experiments/s-integrate/held-adapter.bend as HA
import /tmp/bendvy-flat-main-transport-v2/experiments/s-integrate/types.bend as T
import /tmp/bendvy-flat-main-transport-v2/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-flat-main-transport-v2/experiments/s-integrate/transaction.bend as X

type Report is Data:
  Report{label:U32,cells:List<&2,U32>,scalars:List<&2,U32>,cached:List<&2,U32>,retained:List<&2,U32>,ledger:List<&2,U32>,epoch:U32,ledgerCached:List<&2,U32>,space:U32,id:U32,old:U32,prior:U32,tailOld:U32,marks:List<&2,U32>}
def values(owner:List<&1,U32>) -> List<&2,U32>:
  match owner:
    case Nil{}: []
    case Con{head,rest}: head <> values(rest)
def observe_motion(label:U32,retained:T.PositionView,owner:HA.PrototypeMainArrayMotionOwner) -> Report:
  match retained owner:
    case T.PositionView{T.Four{ra,rb,rc0,rd},rf} HA.PrototypeMainArrayMotionOwner{array,frame,T.PositionView{T.Four{a,b,c,d},cf},T.MotionLedger{totals,epoch},T.LedgerView{T.Four{l0,l1,l2,l3},le},S.Handle{space,id},X.PrototypeFlatMain{8,4,old,X.PrototypeFlatMain{8,4,prior,X.PrototypeFlatLedger{tailOld,X.PrototypeFlatEnd{}}}},X.PrototypeFlatMark{8,4,X.PrototypeFlatMark{8,4,X.PrototypeFlatMark{9,2,X.PrototypeFlatMarksEnd{}}}}}:
      Report{label,values(Array.to_list(~U32,array)),[frame],[a,b,c,d,cf],[ra,rb,rc0,rd,rf],values(Array.to_list(~U32,totals)),epoch,[l0,l1,l2,l3,le],space,id,old,prior,tailOld,[8,4,8,4,9,2]}
    case _ _: Report{0,[],[],[],[],[],0,[],0,0,0,0,0,[]}
def ledger() -> Array<U32>: Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[1000:U32^3n],1,1001),2,1002),3,1003),4,1004),5,1005),6,1006),7,1007)
def run_motion(label:U32,array:Array<U32>) -> Report:
  +cached:T.PositionView = T.PositionView{T.Four{999,200,300,400},77}
  observe_motion(label,cached,HA.prototype_mainarray_motion_set(HA.prototype_mainarray_motion_set(HA.PrototypeMainArrayMotionOwner{array,42,cached,T.MotionLedger{ledger(),4},T.LedgerView{T.Four{9,8,7,6},77},S.Handle{8,4},X.PrototypeFlatLedger{55,X.PrototypeFlatEnd{}},X.PrototypeFlatMark{9,2,X.PrototypeFlatMarksEnd{}}},T.PositionToken{},500),T.PositionToken{},4294967295))
def observe_health(label:U32,retained:T.VitalsView,owner:HA.PrototypeMainArrayHealthOwner) -> Report:
  match retained owner:
    case T.VitalsView{T.Four{ra,rb,rc0,rd},rr,rc} HA.PrototypeMainArrayHealthOwner{array,reserve,class,T.VitalsView{T.Four{a,b,c,d},cr,cc},totals,epoch,T.LedgerView{T.Four{l0,l1,l2,l3},le},S.Handle{space,id},X.PrototypeFlatMain{8,4,old,X.PrototypeFlatMain{8,4,prior,X.PrototypeFlatLedger{tailOld,X.PrototypeFlatEnd{}}}},X.PrototypeFlatMark{8,4,X.PrototypeFlatMark{8,4,X.PrototypeFlatMark{9,2,X.PrototypeFlatMarksEnd{}}}}}:
      Report{label,values(Array.to_list(~U32,array)),[reserve,class],[a,b,c,d,cr,cc],[ra,rb,rc0,rd,rr,rc],values(Array.to_list(~U32,totals)),epoch,[l0,l1,l2,l3,le],space,id,old,prior,tailOld,[8,4,8,4,9,2]}
    case _ _: Report{0,[],[],[],[],[],0,[],0,0,0,0,0,[]}
def run_health(label:U32,array:Array<U32>) -> Report:
  +cached:T.VitalsView = T.VitalsView{T.Four{999,200,300,400},19,23}
  observe_health(label,cached,HA.prototype_mainarray_health_set(HA.prototype_mainarray_health_set(HA.PrototypeMainArrayHealthOwner{array,9,2,cached,ledger(),4,T.LedgerView{T.Four{9,8,7,6},77},S.Handle{8,4},X.PrototypeFlatLedger{55,X.PrototypeFlatEnd{}},X.PrototypeFlatMark{9,2,X.PrototypeFlatMarksEnd{}}},T.VitalsToken{},500),T.VitalsToken{},4294967295))
def main() -> List<&2,Report>:
  [run_motion(101,[100:U32^0n]),run_motion(102,Array.set(U32,[100:U32^1n],1,101)),run_motion(104,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103)),run_motion(108,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107)),run_health(201,[100:U32^0n]),run_health(202,Array.set(U32,[100:U32^1n],1,101)),run_health(204,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103)),run_health(208,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))]
