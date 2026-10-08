import Base
import provider.bend as Provider
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/decode.bend as Complete
import /workspace/formal-proofs/bendvy/experiments/public-decode/standard-owned.bend as Owned
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Canonical

type Schema is Data: Schema{}
type Payload is Type: Payload{cells:Array<Bool>}
type Issues is Type: Issues{error:D.Error,sentinel:Array<U32>}
type Context is Type: Context{sentinel:Array<U32>}
def identity() -> Canonical.Declaration<Schema,Payload>:
  Canonical.component(~Schema,~Payload,"boolean-cell")
def projected(pair:Array<Bool> & Bool) -> Payload & D.Raw:
  match pair:
    case (cells,value): (Payload{cells},D.Boolean{value})
def project(owner:Payload) -> Payload & D.Raw:
  match owner:
    case Payload{cells}: projected(Array.get(Bool,cells,0))
def raw_project(raw:D.Raw) -> D.Raw & D.Raw:
  match raw:
    case +raw: (raw,raw)
def issues(error:D.Error) -> Issues:
  Issues{error,ANode{ALeaf{501},ALeaf{502}}}
# This concrete trusted schema recipe creates its affine payload ONLY after
# complete validation. The generic provider remains arbitrary-P transport.
def accepted(context:Context,original:D.Raw,canonical:D.Raw) -> Context & Owned.Reply<D.Raw,Payload,Issues>:
  match canonical:
    case D.Boolean{value}: (context,Owned.SyncAccepted{Payload{ALeaf{value}}})
    case _: (context,Owned.SyncRejected{original,issues(D.Invalid{"$","boolean-cell recipe",canonical})})
def constructed(context:Context,receipt:D.Receipt<D.Raw>) -> Context & Owned.Reply<D.Raw,Payload,Issues>:
  match receipt:
    case D.Receipt{original,D.Accepted{canonical}}: accepted(context,original,canonical)
    case D.Receipt{original,D.Rejected{error}}: (context,Owned.SyncRejected{original,issues(error)})
def host(context:Context,codec:D.Codec,original:D.Raw) -> Context & Owned.Reply<D.Raw,Payload,Issues>:
  constructed(context,Complete.decode_owner(~D.Raw,~raw_project,codec,original))

type Observed is Type:
  Accepted{context:Context,receipt:D.Receipt<Payload>}
  Refused{context:Context,original:D.Raw,issues:Issues}
def roundtrip(declaration:Decl.Constructed<Schema,Payload,identity(),project>,result:Context & Owned.Reply<D.Raw,Payload,Issues>) -> Observed:
  match result:
    case (context,Owned.SyncAccepted{payload}): Accepted{context,Decl.validate(~Schema,~Payload,~identity(),~project,declaration,payload)}
    case (context,Owned.SyncRejected{original,error}): Refused{context,original,error}
    case (context,Owned.AsyncRejected{original,error}): Refused{context,original,error}
def finish(result:Decl.Constructed<Schema,Payload,identity(),project> & (Context & Owned.Reply<D.Raw,Payload,Issues>)) -> Observed:
  match result:
    case (declaration,reply): roundtrip(declaration,reply)
def run(original:D.Raw) -> Observed:
  finish(Provider.construct(~Schema,~Payload,~identity(),~project,~Issues,~Context,~host,Decl.constructed(~Schema,~Payload,~identity(),~project,D.BoolValue{}),Context{ANode{ALeaf{111},ALeaf{222}}},original))
def accepted_control() -> Observed:
  run(D.Boolean{True{}})
def refused_control() -> Observed:
  run(D.Text{"invalid original"})
