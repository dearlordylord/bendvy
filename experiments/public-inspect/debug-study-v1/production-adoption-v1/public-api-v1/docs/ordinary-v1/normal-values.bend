import Base
import ./canonical-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

type GameSchema is Data:
  GameSchema{}
type Clock is Type:
  Clock{cells:Array<U32>}
# One ordinary schema declaration. No structural name/access callbacks.
def layout() -> Schema.Layout<GameSchema,Array<U32>,Clock>:
  Schema.schema(~GameSchema,~Array<U32>,~Clock,"settings","clock")
# Reverse access order deliberately: schema IDs remain settings1/clock2.
def parameters() -> Schema.Params<GameSchema,Array<U32>,Clock,layout()>:
  Schema.params(~GameSchema,~Array<U32>,~Clock,~layout(),Schema.Right{},Schema.Left{})
# Value presentation only. Structure derives from layout(), not these defs.
def settings(owner:Array<U32>) -> Array<U32> & U32:
  Array.get(U32,owner,0)
def clock_done(observed:Array<U32> & U32) -> Clock & Bool:
  match observed:
    case (cells,value):(Clock{cells},U32.is_eq(value,23))
def clock(owner:Clock) -> Clock & Bool:
  match owner:
    case Clock{cells}:clock_done(Array.get(U32,cells,0))
def BodyOps(H:Type) -> Type:
  Cap.Bundle<Cap.ValueRead<H,Bool>,Cap.ValueRead<H,U32>>
def body_done(~H:Type,clock:Bool,observed:H & U32) -> H & Result<&2,&2,Unit,Bool>:
  match observed:
    case (owner,value):(owner,Done{Bool.and(clock,U32.is_eq(value,17))})
def body_clock(~H:Type,~caps:BodyOps(H),observed:H & Bool) -> H & Result<&2,&2,Unit,Bool>:
  match observed:
    case (owner,clock):body_done(~H,clock,Cap.value_read(~H,~U32,~Cap.second(~Cap.ValueRead<H,Bool>,~Cap.ValueRead<H,U32>,caps),owner))
def body(~H:Type,~caps:BodyOps(H),args:Unit,owner:H) -> H & Result<&2,&2,Unit,Bool>:
  body_clock(~H,~caps,Cap.value_read(~H,~Bool,~Cap.first(~Cap.ValueRead<H,Bool>,~Cap.ValueRead<H,U32>,caps),owner))
