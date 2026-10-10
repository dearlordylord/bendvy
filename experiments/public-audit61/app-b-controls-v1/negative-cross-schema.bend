import Base
import namespace-normal/bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
type Other is Data:
  Other{}
# Exact AppB scalar gameplay provider, abstract affine H; equal payload cannot cross S.
def rejected(~H:Type,~cap:I.Lookup<H,B.Scene,U32>,target:W.Handle<Other>,owner:H) -> H & I.Value<U32>:
  I.lookup(~H,~Other,~U32,~cap,owner,target)
def main() -> Unit:
  Unit{}
