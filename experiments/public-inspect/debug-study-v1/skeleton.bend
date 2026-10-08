import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

# No runtime family lookup by String. Closed setup specializes Token.
type Limit is Data:
  BoundedDecimal{digits:List<&2,U32>}
  Unbounded{}
type Filter<S:Data,Token:Data> is Data:
  Filter{entities:Maybe<&2,List<&2,U32>>,required:List<&2,Token>,limit:Limit}
type Output<V:Data> is Data:
  Disabled{}
  Enabled{value:V}

# The provider may be a cursor-free Check resource/query grant. No runner call.
def enabled(~H:Type,~V:Data,observed:H & V) -> H & Output<V>:
  (owner,value)=observed
  (owner,Enabled{value})
def dispatch(~H:Type,~V:Data,~read:Cap.ValueRead<H,V>,active:Bool,owner:H) -> H & Output<V>:
  match active:
    case False{}:(owner,Disabled{})
    case True{}:enabled(~H,~V,Cap.value_read(~H,~V,~read,owner))
