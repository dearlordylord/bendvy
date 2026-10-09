import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity

# No World is exposed to decoding/projection. The schema-owned typed admission
# runs only after complete validation; it supplies no automatic Raw->P inverse.
type Returned<W:Type,P:Type,O:Type> is Type:
  Admitted{world:W,value:O,canonical:D.Raw}
  ValidationRefused{world:W,owner:P,error:D.Error}
def admitted(~W:Type,~P:Type,~O:Type,canonical:D.Raw,result:W & O) -> Returned<W,P,O>:
  match result:
    case (world,value): Admitted{world,value,canonical}
def validated(~W:Type,~P:Type,~O:Type,~admit:W -> P -> D.Raw -> W & O,world:W,receipt:D.Receipt<P>) -> Returned<W,P,O>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}: ValidationRefused{world,owner,error}
    case D.Receipt{owner,D.Accepted{+canonical}}: admitted(~W,~P,~O,canonical,admit(world,owner,canonical))
def skipped(~W:Type,~P:Type,~O:Type,~admit:W -> P -> D.Raw -> W & O,world:W,result:P & D.Raw) -> Returned<W,P,O>:
  match result:
    case (owner,raw): validated(~W,~P,~O,~admit,world,D.Receipt{owner,D.Accepted{raw}})
def request(~S:Data,~W:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:W -> P -> D.Raw -> W & O,declaration:Decl.Constructed<S,P,identity,project>,world:W,owner:P) -> Returned<W,P,O>:
  skipped(~W,~P,~O,~admit,world,project(owner))
