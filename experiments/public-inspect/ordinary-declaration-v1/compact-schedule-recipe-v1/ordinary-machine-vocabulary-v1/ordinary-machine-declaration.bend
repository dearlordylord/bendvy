import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine-world.bend as MW
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector-machine-projection.bend as P

# Closed ordinary declaration. Names never grant authority; K and the operational
# slot lens remain nominal/static. No Resource identity is fabricated for a machine.
type Declaration<-S:Data,-Token:Data,-V:Data,-R:Type,-take:R -> R & M.Slot<S,Token,V>> is Data:
  Declaration{name:String}
  Vocabulary{name:String,values:List<&2,V>}
def name(~S:Data,~Token:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,Token,V>,declaration:Declaration<S,Token,V,R,take>) -> String:
  match declaration:
    case Declaration{name}:name
    case Vocabulary{name,_}:name
# One ordinary declaration retains its finite ordered values. This is descriptive,
# not a queue membership restriction; legacy arbitrary V declarations stay valid.
def declared(~S:Data,~Token:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,Token,V>,name:String,values:List<&2,V>) -> Declaration<S,Token,V,R,take>:
  Vocabulary{name,values}
def values(~S:Data,~Token:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,Token,V>,declaration:Declaration<S,Token,V,R,take>) -> Maybe<&2,List<&2,V>>:
  match declaration:
    case Declaration{_}:None{}
    case Vocabulary{_,values}:Some{values}
def inspect(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:Declaration<S,Token,V,R,take>) -> Cap.ValueRead<I.Frame<S,C,R,E>,M.CurrentView<S,Token,V>>:
  P.provide(~S,~Token,~V,~C,~R,~E,~take)
def condition(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:Declaration<S,Token,V,R,take>) -> Cap.ValueRead<K.Frame<S,C,R,E>,M.CurrentView<S,Token,V>>:
  P.check_provide(~S,~Token,~V,~C,~R,~E,~take)

# Preflight consults the actual nominal slot and preserves the arbitrary World.
def availability(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,name:String,observed:W.World<S,C,R,E> & M.Slot<S,Token,V>) -> W.World<S,C,R,E> & List<&2,String>:
  match observed:
    case (world,M.Missing{}):(world,[name])
    case (world,M.Present{_,_,_,_}):(world,[])
def required(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:Declaration<S,Token,V,R,take>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:
  availability(~S,~Token,~V,~C,~R,~E,name(~S,~Token,~V,~R,~take,declaration),MW.take(~S,~Token,~V,~C,~R,~E,~take,world))
def get(~H:Type,~S:Data,~Token:Data,~V:Data,~cap:Cap.ValueRead<H,M.CurrentView<S,Token,V>>,owner:H) -> H & M.CurrentView<S,Token,V>:
  Cap.value_read(~H,~M.CurrentView<S,Token,V>,~cap,owner)
def compared(~H:Type,~S:Data,~Token:Data,~V:Data,~same:V -> V -> Bool,value:V,observed:H & M.CurrentView<S,Token,V>) -> H & Bool:
  (owner,view)=observed
  (owner,M.is_current(~S,~Token,~V,~same,view,value))
def matches(~H:Type,~S:Data,~Token:Data,~V:Data,~same:V -> V -> Bool,~cap:Cap.ValueRead<H,M.CurrentView<S,Token,V>>,owner:H,value:V) -> H & Bool:
  compared(~H,~S,~Token,~V,~same,value,get(~H,~S,~Token,~V,~cap,owner))
