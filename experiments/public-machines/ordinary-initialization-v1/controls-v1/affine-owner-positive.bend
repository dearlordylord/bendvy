import Base
import ../schema.bend as Fixture
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../../src/ecs/world.bend as W

# This adapter is generic in both World owners. The actual declaration and its
# operational lens remain tied to the same schema, state key, payload, and R.
def init_then_insert(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~declaration:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,~make:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,world:W.World<S,C,R,E>,value:V) -> W.World<S,C,R,E>:
  Init.insert_state(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,Init.init_state(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,~make,world),value)

# Specialize the adapter against the real fixture lens and public API. Keeping
# this call reachable in the source control makes the checker instantiate the
# generic owner path instead of only checking its signature.
def specialized(world:W.World<Fixture.SchemaA,Array<U32>,Fixture.Resources<Fixture.SchemaA>,String>,value:Fixture.MachineState) -> W.World<Fixture.SchemaA,Array<U32>,Fixture.Resources<Fixture.SchemaA>,String>:
  init_then_insert(~Fixture.SchemaA,~Fixture.MachineKey<Fixture.SchemaA>,~Fixture.MachineState,~Array<U32>,~Fixture.Resources<Fixture.SchemaA>,~String,~Fixture.take_machine(~Fixture.SchemaA),~Fixture.put_machine(~Fixture.SchemaA),~Fixture.declaration(~Fixture.SchemaA),~Fixture.make_default(~Fixture.SchemaA),world,value)

# Also specialize with a Type owner containing a function field. This keeps
# the owner affine/non-Data while the initialization state remains one field
# inside the actual World resource.
type AffineResources<S:Data> is Type:
  AffineResources{machine:Init.State<S,Fixture.MachineKey<S>,Fixture.MachineState>,token:U32 -> U32}

def take_affine(~S:Data,resource:AffineResources<S>) -> AffineResources<S> & Init.State<S,Fixture.MachineKey<S>,Fixture.MachineState>:
  match resource:
    case AffineResources{+machine,token}:(AffineResources{machine,token},machine)

def put_affine(~S:Data,resource:AffineResources<S>,machine:Init.State<S,Fixture.MachineKey<S>,Fixture.MachineState>) -> AffineResources<S>:
  match resource:
    case AffineResources{_,token}:AffineResources{machine,token}

def affine_declaration(~S:Data) -> OD.Declaration<S,Fixture.MachineKey<S>,Fixture.MachineState,AffineResources<S>,Init.take_slot(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~AffineResources<S>,~take_affine(~S),~put_affine(~S))>:
  Init.declared(~S,~Fixture.MachineKey<S>,~Fixture.MachineState,~AffineResources<S>,~take_affine(~S),~put_affine(~S),"machine.state",[Fixture.A{},Fixture.B{},Fixture.C{},Fixture.D{}])

def affine_default(~S:Data,world:W.World<S,Array<U32>,AffineResources<S>,String>) -> W.World<S,Array<U32>,AffineResources<S>,String> & Fixture.MachineState:
  (world,Fixture.A{})

def affine_specialized(world:W.World<Fixture.SchemaA,Array<U32>,AffineResources<Fixture.SchemaA>,String>,value:Fixture.MachineState) -> W.World<Fixture.SchemaA,Array<U32>,AffineResources<Fixture.SchemaA>,String>:
  init_then_insert(~Fixture.SchemaA,~Fixture.MachineKey<Fixture.SchemaA>,~Fixture.MachineState,~Array<U32>,~AffineResources<Fixture.SchemaA>,~String,~take_affine(~Fixture.SchemaA),~put_affine(~Fixture.SchemaA),~affine_declaration(~Fixture.SchemaA),~affine_default(~Fixture.SchemaA),world,value)
