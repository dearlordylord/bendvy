import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C

# Public constructor confidentiality is NOT assumed. Gameplay is checked for
# arbitrary H; only the trusted closed author supplies the concrete getter.
def provide(~P:Type,~V:Data,~get:P -> P & C.Access<V>,~body:@-H:Type -> Cap.Read<H,V> -> H -> H & Unit,ctx:P) -> P & Unit:
  body(P,Cap.Read{get},ctx)
def read_done(-H:Type,observed:H & C.Access<String>) -> H & Unit:
  match observed:
    case (ctx,value): (ctx,Unit{})
def read_applied(-H:Type,cap:Cap.Read<H,String>,ctx:H) -> H & C.Access<String>:
  match cap:
    case Cap.Read{get}: get(ctx)
def legitimate(-H:Type,cap:Cap.Read<H,String>,ctx:H) -> H & Unit:
  read_done(H,read_applied(H,cap,ctx))
