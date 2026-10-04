import Base
import ./owned-index-core.bend as A
def print_motion(prefix: String, r: Array<Maybe<A.Motion>> & String) -> IO(Array<Maybe<A.Motion>>):
  match r:
    case (col, text):
      do IO<Array<Maybe<A.Motion>>>:
        IO.print(prefix ++ text)
        return col
def print_health(prefix: String, r: Array<Maybe<A.Health>> & String) -> IO(Array<Maybe<A.Health>>):
  match r:
    case (col, text):
      do IO<Array<Maybe<A.Health>>>:
        IO.print(prefix ++ text)
        return col
def main() -> IO(Unit):
  do IO<Unit>:
    motion : Array<Maybe<A.Motion>> = A.empty(~A.Motion, 2n)
    motion : Array<Maybe<A.Motion>> = A.insert_done(~A.Motion, Array.swap(Maybe<A.Motion>, motion, 0, Some{A.Motion{ANode{ANode{ALeaf{10}, ALeaf{11}}, ANode{ALeaf{12}, ALeaf{13}}}, 10}}))
    motion : Array<Maybe<A.Motion>> = A.insert_done(~A.Motion, Array.swap(Maybe<A.Motion>, motion, 2, Some{A.Motion{ANode{ANode{ALeaf{30}, ALeaf{31}}, ANode{ALeaf{32}, ALeaf{33}}}, 30}}))
    motion : Array<Maybe<A.Motion>> = A.insert_done(~A.Motion, Array.swap(Maybe<A.Motion>, motion, 3, Some{A.Motion{ANode{ANode{ALeaf{40}, ALeaf{41}}, ANode{ALeaf{42}, ALeaf{43}}}, 40}}))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:7:0:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 0, 4, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:7:2:", A.access(~A.Motion, ~A.callback, A.motion_roundtrip, 7, 2, 4, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:7:3:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 3, 4, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:8:0:", A.access(~A.Motion, ~A.callback, A.motion_observe, 8, 0, 4, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:7:4:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 4, 4, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:7:4294967295:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 4294967295, 4, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:7:1:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 1, 4, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:mismatch:", A.checked(~A.Motion, ~A.callback, A.motion_observe, False{}, 0, motion))
    motion : Array<Maybe<A.Motion>> = ANode{motion, A.empty(~A.Motion, 2n)}
    motion : Array<Maybe<A.Motion>> = A.insert_done(~A.Motion, Array.swap(Maybe<A.Motion>, motion, 7, Some{A.Motion{ANode{ANode{ALeaf{80}, ALeaf{81}}, ANode{ALeaf{82}, ALeaf{83}}}, 80}}))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:grown:0:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 0, 8, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:grown:2:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 2, 8, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:grown:3:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 3, 8, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:grown:4:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 4, 8, motion))
    motion : Array<Maybe<A.Motion>> <- print_motion("motion:grown:7:", A.access(~A.Motion, ~A.callback, A.motion_observe, 7, 7, 8, motion))
    health : Array<Maybe<A.Health>> = A.empty(~A.Health, 2n)
    health : Array<Maybe<A.Health>> = A.insert_done(~A.Health, Array.swap(Maybe<A.Health>, health, 0, Some{A.Health{ANode{ANode{ALeaf{10}, ALeaf{11}}, ANode{ALeaf{12}, ALeaf{13}}}, 10}}))
    health : Array<Maybe<A.Health>> = A.insert_done(~A.Health, Array.swap(Maybe<A.Health>, health, 2, Some{A.Health{ANode{ANode{ALeaf{30}, ALeaf{31}}, ANode{ALeaf{32}, ALeaf{33}}}, 30}}))
    health : Array<Maybe<A.Health>> = A.insert_done(~A.Health, Array.swap(Maybe<A.Health>, health, 3, Some{A.Health{ANode{ANode{ALeaf{40}, ALeaf{41}}, ANode{ALeaf{42}, ALeaf{43}}}, 40}}))
    health : Array<Maybe<A.Health>> <- print_health("health:7:0:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 0, 4, health))
    health : Array<Maybe<A.Health>> <- print_health("health:7:2:", A.access(~A.Health, ~A.callback, A.health_roundtrip, 7, 2, 4, health))
    health : Array<Maybe<A.Health>> <- print_health("health:7:3:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 3, 4, health))
    health : Array<Maybe<A.Health>> <- print_health("health:8:0:", A.access(~A.Health, ~A.callback, A.health_observe, 8, 0, 4, health))
    health : Array<Maybe<A.Health>> <- print_health("health:7:4:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 4, 4, health))
    health : Array<Maybe<A.Health>> <- print_health("health:7:4294967295:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 4294967295, 4, health))
    health : Array<Maybe<A.Health>> <- print_health("health:7:1:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 1, 4, health))
    health : Array<Maybe<A.Health>> <- print_health("health:mismatch:", A.checked(~A.Health, ~A.callback, A.health_observe, False{}, 0, health))
    health : Array<Maybe<A.Health>> = ANode{health, A.empty(~A.Health, 2n)}
    health : Array<Maybe<A.Health>> = A.insert_done(~A.Health, Array.swap(Maybe<A.Health>, health, 7, Some{A.Health{ANode{ANode{ALeaf{80}, ALeaf{81}}, ANode{ALeaf{82}, ALeaf{83}}}, 80}}))
    health : Array<Maybe<A.Health>> <- print_health("health:grown:0:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 0, 8, health))
    health : Array<Maybe<A.Health>> <- print_health("health:grown:2:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 2, 8, health))
    health : Array<Maybe<A.Health>> <- print_health("health:grown:3:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 3, 8, health))
    health : Array<Maybe<A.Health>> <- print_health("health:grown:4:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 4, 8, health))
    health : Array<Maybe<A.Health>> <- print_health("health:grown:7:", A.access(~A.Health, ~A.callback, A.health_observe, 7, 7, 8, health))
    return Unit{}
