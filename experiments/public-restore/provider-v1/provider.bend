import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/standard-owned.bend as Owned
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Canonical

# Detached transport only: trusted schema author receives the retained recipe
# and ORIGINAL input. No World mutation, recovery inverse or issue rewriting.
def construct(~S:Data,~P:Type,~identity:Canonical.Declaration<S,P>,~project:P -> P & D.Raw,~Issues:Type,~Context:Type,~host:Context -> D.Codec -> D.Raw -> Context & Owned.Reply<D.Raw,P,Issues>,+declaration:Decl.Constructed<S,P,identity,project>,context:Context,raw:D.Raw) -> Decl.Constructed<S,P,identity,project> & (Context & Owned.Reply<D.Raw,P,Issues>):
  (declaration,host(context,Decl.codec(~S,~P,~identity,~project,declaration),raw))
