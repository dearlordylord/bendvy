import Base
import ./owned-index-core.bend as A
def printcol(r: Array<Maybe<A.Motion>> & String) -> IO(Array<Maybe<A.Motion>>):
  match r:
    case (col, text):
      do IO<Array<Maybe<A.Motion>>>:
        IO.print(text)
        return col
def printplacement(prefix: String, r: A.Placement & String) -> IO(A.Placement):
  match r:
    case (p, text):
      do IO<A.Placement>:
        IO.print(prefix ++ text)
        return p
def rejected(prefix: String, r: A.Placement & String) -> IO(A.Placement):
  match r:
    case (p, status): printplacement(prefix ++ status ++ ":", A.placement_meta(A.placement_snapshot(p)))
def main() -> IO(Unit):
  do IO<Unit>:
    c : Array<Maybe<A.Motion>> = ANode{ALeaf{Some{A.Motion{ANode{ANode{ALeaf{10}, ALeaf{11}}, ANode{ALeaf{12}, ALeaf{13}}}, 10}}}, ALeaf{Some{A.Motion{ANode{ANode{ALeaf{20}, ALeaf{21}}, ANode{ALeaf{22}, ALeaf{23}}}, 20}}}}
    c : Array<Maybe<A.Motion>> <- printcol(A.snapshot(~A.Motion, ~A.motion_observe, c))
    c : Array<Maybe<A.Motion>> = ANode{c, A.empty(~A.Motion, 1n)}
    c : Array<Maybe<A.Motion>> <- printcol(A.snapshot(~A.Motion, ~A.motion_observe, c))
    c : Array<Maybe<A.Motion>> = ANode{c, A.empty(~A.Motion, 2n)}
    c : Array<Maybe<A.Motion>> <- printcol(A.snapshot(~A.Motion, ~A.motion_observe, c))
    c : Array<Maybe<A.Motion>> = ANode{c, A.empty(~A.Motion, 3n)}
    c : Array<Maybe<A.Motion>> <- printcol(A.snapshot(~A.Motion, ~A.motion_observe, c))
    p : A.Placement = A.Placement{Array.set(Maybe<A.Motion>, A.empty(~A.Motion, 4n), 0, Some{A.Motion{ANode{ANode{ALeaf{10}, ALeaf{11}}, ANode{ALeaf{12}, ALeaf{13}}}, 10}}), Array.set(Maybe<A.Health>, Array.set(Maybe<A.Health>, A.empty(~A.Health, 4n), 0, Some{A.Health{ANode{ANode{ALeaf{50}, ALeaf{51}}, ANode{ALeaf{52}, ALeaf{53}}}, 50}}), 1, Some{A.Health{ANode{ANode{ALeaf{60}, ALeaf{61}}, ANode{ALeaf{62}, ALeaf{63}}}, 60}}), Array.set(U32, Array.set(U32, [0 : U32^4n], 0, 2), 1, 1), A.Motion{ANode{ANode{ALeaf{70}, ALeaf{71}}, ANode{ALeaf{72}, ALeaf{73}}}, 70}, A.Health{ANode{ANode{ALeaf{80}, ALeaf{81}}, ANode{ALeaf{82}, ALeaf{83}}}, 80}, A.Motion{ANode{ANode{ALeaf{90}, ALeaf{91}}, ANode{ALeaf{92}, ALeaf{93}}}, 90} <> A.Motion{ANode{ANode{ALeaf{100}, ALeaf{101}}, ANode{ALeaf{102}, ALeaf{103}}}, 100} <> []}
    p : A.Placement <- printplacement("before:", A.placement_meta(A.placement_snapshot(p)))
    p : A.Placement <- rejected("reject:7:0:", A.preflight(7, 0, p))
    p : A.Placement <- rejected("reject:8:1:", A.preflight(8, 1, p))
    p : A.Placement <- rejected("reject:7:17:", A.preflight(7, 17, p))
    p : A.Placement <- rejected("reject:7:65537:", A.preflight(7, 65537, p))
    p : A.Placement <- rejected("reject:7:4294967295:", A.preflight(7, 4294967295, p))
    IO.print(A.lookup_state(0, False{}))
    IO.print(A.lookup_state(1, False{}))
    IO.print(A.lookup_state(2, True{}))
    return Unit{}
