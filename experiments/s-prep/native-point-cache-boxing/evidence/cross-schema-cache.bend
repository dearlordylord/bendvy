import Base
import /tmp/bendvy-native-point-cache-boxing/experiments/s-integrate/held-adapter.bend as H
import /tmp/bendvy-native-point-cache-boxing/experiments/s-integrate/cache.bend as CC
import /tmp/bendvy-native-point-cache-boxing/experiments/s-integrate/types.bend as T
type Raw is Type:
  Raw{values: Array<U32>}
def restore(-R:Type,box:H.PrototypeWorldBox<CC.Cache<R,U32>>) -> CC.Cache<R,U32>:
  H.prototype_world_unbox(CC.Cache<R,U32>,box)
def observed(view:U32,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,value): U32.add(view,value)
def observe(cache:CC.Cache<Raw,U32>) -> U32:
  match cache:
    case CC.Cache{Raw{values},view}:
      observed(view,Array.get(U32,values,0))
def main() -> IO(Unit):
  IO.print(U32.show(observe(restore(Raw,H.PrototypeWorldNested{H.PrototypeWorldNested{H.PrototypeWorldRoot{CC.Cache{Raw{[7 : U32^0n]},23}}}}))))
def cross_schema(box:H.PrototypeWorldBox<CC.Cache<T.Position,T.PositionView>>) -> H.PrototypeWorldBox<CC.Cache<T.Vitals,T.VitalsView>>:
  box
