import Base
import namespace-normal/bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# Actual selected Inspector scalar Lookup does not confer the write provider.
def rejected(~H:Type,~cap:I.Lookup<H,B.Scene,U32>,owner:H) -> H:
  Cap.set(~H,~U32,~U32,~cap,owner,15)
def main() -> Unit:
  Unit{}
