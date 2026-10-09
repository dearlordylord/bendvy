import Base
import ../capability.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decode
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query

# Trusted closed admission is part of the SAME descriptor's nominal type.
# Gameplay gets the derived owned grant; callers supply no access strings.
type Declaration<S:Data,C:Type,R:Type,E:Data,P:Type,O:Type,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw,-admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O> is Data:
  Declaration{constructed:Decode.Constructed<S,P,identity,project>}
def mutable(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,constructed:Decode.Constructed<S,P,identity,project>) -> Declaration<S,C,R,E,P,O,identity,project,admit>:
  Declaration{constructed}
def constructed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,declaration:Declaration<S,C,R,E,P,O,identity,project,admit>) -> Decode.Constructed<S,P,identity,project>:
  match declaration:
    case Declaration{constructed}:constructed
def clauses(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:(W.World<S,C,R,E> & W.Handle<S>) -> P -> D.Raw -> (W.World<S,C,R,E> & W.Handle<S>) & O,declaration:Declaration<S,C,R,E,P,O,identity,project,admit>) -> List<&2,Query.Clause<S>>:
  [Query.Clause{Identity.key(~S,~P,identity),Query.Write{}}]
def access(~S:Data,clauses:List<&2,Query.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Query.Clause{name,_} <> rest:name <> access(~S,rest)
