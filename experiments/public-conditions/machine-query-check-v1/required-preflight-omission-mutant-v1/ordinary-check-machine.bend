import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MD
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

# The existing nominal machine declaration owns both read and availability.
# No Resource identity or second caller-authored description is fabricated.
type Read<-S:Data,-Token:Data,-V:Data,-H:Type> is Type:
  Read{read:Cap.ValueRead<H,M.CurrentView<S,Token,V>>}
def Ops(~S:Data,~Token:Data,~V:Data,H:Type) -> Type:Read<S,Token,V,H>
def read_field(~S:Data,~Token:Data,~V:Data,~H:Type,value:Read<S,Token,V,H>) -> H -> H & M.CurrentView<S,Token,V>:
  match value:
    case Read{read}:Cap.value_read_field(~H,~M.CurrentView<S,Token,V>,read)
def read(~S:Data,~Token:Data,~V:Data,~H:Type,~caps:Read<S,Token,V,H>,owner:H) -> H & M.CurrentView<S,Token,V>:read_field(~S,~Token,~V,~H,caps)(owner)
def optional(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:MD.Declaration<S,Token,V,R,take>) -> D.Declaration<S,C,R,E,Ops(~S,~Token,~V)>:
  D.Declaration{K.Plan{D.provided(~S,~C,~R,~E),Read{MD.condition(~S,~Token,~V,~C,~R,~E,~take,~declaration)}},[D.Use{D.Machine{},MD.name(~S,~Token,~V,~R,~take,declaration),D.Read{},False{}}]}
def required(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:MD.Declaration<S,Token,V,R,take>) -> D.Declaration<S,C,R,E,Ops(~S,~Token,~V)>:
  D.Declaration{K.Plan{D.provided(~S,~C,~R,~E),Read{MD.condition(~S,~Token,~V,~C,~R,~E,~take,~declaration)}},[D.Use{D.Machine{},MD.name(~S,~Token,~V,~R,~take,declaration),D.Read{},True{}}]}
