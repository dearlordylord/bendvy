import Base
import ../admission.bend as Gate
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/decode.bend as Complete
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity

# Resource initialization mirrors the explicit constructor/result boundary.
# Plain/transient already-typed input is not a constructed entryRaw operation.
type Descriptor<-S:Data,-P:Type,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw> is Data:
  Plain{declaration:Decl.Plain<S,P,identity>}
  Transient{declaration:Decl.Transient<S,P,identity>}
  Constructed{declaration:Decl.Constructed<S,P,identity,project>,decode:Maybe<&2,D.Codec>}
def projected(~W:Type,~P:Type,~O:Type,~admit:W -> P -> D.Raw -> W & O,world:W,result:P & D.Raw) -> Gate.Returned<W,P,O>:
  match result:
    case (owner,raw): Gate.validated(~W,~P,~O,~admit,world,D.Receipt{owner,D.Accepted{raw}})
def initialize(~S:Data,~W:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:W -> P -> D.Raw -> W & O,descriptor:Descriptor<S,P,identity,project>,world:W,owner:P) -> Gate.Returned<W,P,O>:
  match descriptor:
    case Plain{_}: projected(~W,~P,~O,~admit,world,project(owner))
    case Transient{_}: projected(~W,~P,~O,~admit,world,project(owner))
    case Constructed{declaration,_}: Gate.request(~S,~W,~P,~O,~identity,~project,~admit,declaration,world,owner)
# Decoder selection is a detached constructed boundary, not World restoration.
def decoder(codec:D.Codec,decode:Maybe<&2,D.Codec>) -> D.Codec:
  match decode:
    case None{}: codec
    case Some{decode}: decode
def load(~S:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,decode:Maybe<&2,D.Codec>,owner:P) -> D.Receipt<P>:
  Complete.decode_owner(~P,~project,decoder(Decl.codec(~S,~P,~identity,~project,declaration),decode),owner)
