import Base
import ./machine-world.bend as MW
import ./machine.bend as M
import ./world.bend as W
import ./inspector.bend as I
import ./check.bend as K
import ./capabilities.bend as Cap
import ./inspector-machine-projection.bend as P

# Closed ordinary declaration. Names never grant authority; K and the operational
# slot lens remain nominal/static. No Resource identity is fabricated for a machine.
# Schema/token/slot-indexed machine declaration. Printable names are
# metadata, never world or machine authority. Vocabulary optionally carries
# ordered Data values for description, without restricting queue membership.
# Contracts and consumers: docs/parity/machines.md.
type Declaration<-S:Data,-Token:Data,-V:Data,-R:Type,-take:R -> R & M.Slot<S,Token,V>> is Data:
  Declaration{name:String}
  Vocabulary{name:String,values:List<&2,V>}
# Return the authored machine name without reading its runtime slot.
def name(~S:Data,~Token:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,Token,V>,declaration:Declaration<S,Token,V,R,take>) -> String:
  match declaration:
    case Declaration{name}:name
    case Vocabulary{name,_}:name
# One ordinary declaration retains its finite ordered values. This is descriptive,
# not a queue membership restriction; legacy arbitrary V declarations stay valid.
# Declare a machine with an ordered descriptive vocabulary. Values are not
# an exhaustive runtime validation rule; the V type and slot operations govern
# accepted requests. Does not initialize a machine or register a system.
def declared(~S:Data,~Token:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,Token,V>,name:String,values:List<&2,V>) -> Declaration<S,Token,V,R,take>:
  Vocabulary{name,values}
# Return Some ordered descriptive values for Vocabulary, or None for the
# legacy Declaration variant. Neither result reads current state or queued work.
def values(~S:Data,~Token:Data,~V:Data,~R:Type,~take:R -> R & M.Slot<S,Token,V>,declaration:Declaration<S,Token,V,R,take>) -> Maybe<&2,List<&2,V>>:
  match declaration:
    case Declaration{_}:None{}
    case Vocabulary{_,values}:Some{values}
# Build a read-only Inspector capability for this machine current view.
# Retains the nominal slot lens; the declaration name grants no authority.
# Does not execute inspection or advance registered system/transition readers.
def inspect(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:Declaration<S,Token,V,R,take>) -> Cap.ValueRead<I.Frame<S,C,R,E>,M.CurrentView<S,Token,V>>:
  P.provide(~S,~Token,~V,~C,~R,~E,~take)
# Build a Check capability for this machine current view using the same
# nominal slot lens. Provides no transition write operations or reader cursor.
def condition(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:Declaration<S,Token,V,R,take>) -> Cap.ValueRead<K.Frame<S,C,R,E>,M.CurrentView<S,Token,V>>:
  P.check_provide(~S,~Token,~V,~C,~R,~E,~take)

# Preflight consults the actual nominal slot and preserves the arbitrary World.
def availability(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,name:String,observed:W.World<S,C,R,E> & M.Slot<S,Token,V>) -> W.World<S,C,R,E> & List<&2,String>:
  match observed:
    case (world,M.Missing{}):(world,[name])
    case (world,M.Present{_,_,_,_}):(world,[])
# Inspect actual machine-slot availability while returning the world owner.
# Missing yields the declared name in a one-element list; present yields [].
# Does not create or initialize the slot, run handlers or apply queued state.
def required(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:Declaration<S,Token,V,R,take>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:
  availability(~S,~Token,~V,~C,~R,~E,name(~S,~Token,~V,~R,~take,declaration),MW.take(~S,~Token,~V,~C,~R,~E,~take,world))
# Read CurrentView through an existing typed read capability and return its
# affine owner. Missing state remains explicit; no live machine alias escapes.
def get(~H:Type,~S:Data,~Token:Data,~V:Data,~cap:Cap.ValueRead<H,M.CurrentView<S,Token,V>>,owner:H) -> H & M.CurrentView<S,Token,V>:
  Cap.value_read(~H,~M.CurrentView<S,Token,V>,~cap,owner)
def compared(~H:Type,~S:Data,~Token:Data,~V:Data,~same:V -> V -> Bool,value:V,observed:H & M.CurrentView<S,Token,V>) -> H & Bool:
  (owner,view)=observed
  (owner,M.is_current(~S,~Token,~V,~same,view,value))
# Compare an observed current state with a Data value using the supplied
# closed equality function. Returns owner and Bool; missing state is false.
# Does not inspect queued targets, consume a cursor or schedule a transition.
def matches(~H:Type,~S:Data,~Token:Data,~V:Data,~same:V -> V -> Bool,~cap:Cap.ValueRead<H,M.CurrentView<S,Token,V>>,owner:H,value:V) -> H & Bool:
  compared(~H,~S,~Token,~V,~same,value,get(~H,~S,~Token,~V,~cap,owner))
