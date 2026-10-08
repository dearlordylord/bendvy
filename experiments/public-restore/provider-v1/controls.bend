import Base
import provider.bend as Provider
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/standard-owned.bend as Owned
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Canonical

type Schema is Data: Schema{}
type Payload is Type: Payload{cells:Array<U32>}
type Issues is Type: Issues{cells:Array<U32>}
type Context is Type: Context{sentinel:Array<U32>}
def identity() -> Canonical.Declaration<Schema,Payload>:
  Canonical.component(~Schema,~Payload,"detached")
def project(owner:Payload) -> Payload & D.Raw:
  (owner,D.Null{})
# Deliberately author-owned callback, not generic Raw -> Type synthesis.
def host(mode:U32,context:Context,codec:D.Codec,raw:D.Raw) -> Context & Owned.Reply<D.Raw,Payload,Issues>:
  match mode:
    case 0: (context,Owned.SyncAccepted{Payload{ANode{ALeaf{11},ALeaf{22}}}})
    case _: (context,Owned.SyncRejected{raw,Issues{ANode{ALeaf{31},ALeaf{32}}}})
def run(~mode:U32) -> Decl.Constructed<Schema,Payload,identity(),project> & (Context & Owned.Reply<D.Raw,Payload,Issues>):
  Provider.construct(~Schema,~Payload,~identity(),~project,~Issues,~Context,~host(mode),Decl.constructed(~Schema,~Payload,~identity(),~project,D.Integer{}),Context{ANode{ALeaf{111},ALeaf{222}}},D.Text{"original"})
