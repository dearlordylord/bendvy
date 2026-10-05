import Base
import ./types.bend as T
import ./uncached-payload.bend as P

def position_print(old1: U32,old2: U32,result: T.Position & T.PositionView) -> IO(Unit):
  match result:
    case (_,T.PositionView{T.Four{a,b,c,d},frame}): IO.print("position old1=" ++ U32.show(old1) ++ " old2=" ++ U32.show(old2) ++ " cells=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ " frame=" ++ U32.show(frame))
def position_second(old1: U32,result: T.Position & U32) -> IO(Unit):
  match result:
    case (owner,old2): position_print(old1,old2,P.position_get(owner))
def position_first(result: T.Position & U32) -> IO(Unit):
  match result:
    case (owner,old1): position_second(old1,P.position_swap(owner,101))
def vitals_print(old1: U32,old2: U32,result: T.Vitals & T.VitalsView) -> IO(Unit):
  match result:
    case (_,T.VitalsView{T.Four{a,b,c,d},reserve,class}): IO.print("vitals old1=" ++ U32.show(old1) ++ " old2=" ++ U32.show(old2) ++ " cells=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ " reserve=" ++ U32.show(reserve) ++ " class=" ++ U32.show(class))
def vitals_second(old1: U32,result: T.Vitals & U32) -> IO(Unit):
  match result:
    case (owner,old2): vitals_print(old1,old2,P.vitals_get(owner))
def vitals_first(result: T.Vitals & U32) -> IO(Unit):
  match result:
    case (owner,old1): vitals_second(old1,P.vitals_swap(owner,102))
def motion_ledger_print(old1: U32,old2: U32,result: T.MotionLedger & T.LedgerView) -> IO(Unit):
  match result:
    case (_,T.LedgerView{T.Four{a,b,c,d},epoch}): IO.print("motion_ledger old1=" ++ U32.show(old1) ++ " old2=" ++ U32.show(old2) ++ " cells=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ " epoch=" ++ U32.show(epoch))
def motion_ledger_second(old1: U32,result: T.MotionLedger & U32) -> IO(Unit):
  match result:
    case (owner,old2): motion_ledger_print(old1,old2,P.motion_ledger_get(owner))
def motion_ledger_first(result: T.MotionLedger & U32) -> IO(Unit):
  match result:
    case (owner,old1): motion_ledger_second(old1,P.motion_ledger_swap(owner,103))
def health_ledger_print(old1: U32,old2: U32,result: T.HealthLedger & T.LedgerView) -> IO(Unit):
  match result:
    case (_,T.LedgerView{T.Four{a,b,c,d},epoch}): IO.print("health_ledger old1=" ++ U32.show(old1) ++ " old2=" ++ U32.show(old2) ++ " cells=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ " epoch=" ++ U32.show(epoch))
def health_ledger_second(old1: U32,result: T.HealthLedger & U32) -> IO(Unit):
  match result:
    case (owner,old2): health_ledger_print(old1,old2,P.health_ledger_get(owner))
def health_ledger_first(result: T.HealthLedger & U32) -> IO(Unit):
  match result:
    case (owner,old1): health_ledger_second(old1,P.health_ledger_swap(owner,104))
def main() -> IO(Unit):
  do IO<Unit>:
    position_first(P.position_swap(T.Position{ANode{ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{13},ALeaf{14}}},7},91))
    vitals_first(P.vitals_swap(T.Vitals{ANode{ANode{ALeaf{21},ALeaf{22}},ANode{ALeaf{23},ALeaf{24}}},8,9},92))
    motion_ledger_first(P.motion_ledger_swap(T.MotionLedger{ANode{ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{33},ALeaf{34}}},10},93))
    health_ledger_first(P.health_ledger_swap(T.HealthLedger{ANode{ANode{ALeaf{41},ALeaf{42}},ANode{ALeaf{43},ALeaf{44}}},11},94))
