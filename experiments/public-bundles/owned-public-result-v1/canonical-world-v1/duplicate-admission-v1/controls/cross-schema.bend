import Base
import ../bundle.bend as B
import ../runtime.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../schemaB/runtime.bend as BR
def bad(registry:BR.Registry(),world:R.World(),args:BR.Args()) -> BR.RunResult():BR.run(registry,world,args)
