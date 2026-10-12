import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Publication
type S is Data:S{}
type FirstEvent is Data:FirstEvent{value:U32}
type SecondEvent is Data:SecondEvent{value:Bool}
type UnusedEvent is Data:UnusedEvent{value:U32}
def PairEvents() -> Data:Publication.Publication<FirstEvent,SecondEvent>
def Publications() -> Data:Publication.Publication<PairEvents(),UnusedEvent>
def Events() -> Data:Relation.Notice<S,Publications()>
type Components is Type:Components{column:Col.Column<S,Array<U32>>,sibling:Array<U32>}
def Store() -> Type:Relation.Store<S,Components>
def Resources() -> Type:Array<U32>
def World() -> Type:W.World<S,Store(),Resources(),Events()>
def empty(unit:Unit) -> Store():Relation.Store{Components{Col.Column{ANode{ALeaf{Some{ANode{ALeaf{41},ALeaf{42}}}},ALeaf{None{}}},[]},ANode{ALeaf{11},ALeaf{12}}},G.Graph{[],[]}}
def parent() -> Ordinary.Declaration<S>:Ordinary.relation(~S,G.Descriptor{2,"Parent","Children",G.Hierarchy{}})

def parent_descriptor(value:Ordinary.Declaration<S>) -> G.Descriptor<S>:
  match value:
    case Ordinary.Declaration{descriptor}:descriptor
def descriptor() -> G.Descriptor<S>:parent_descriptor(parent())
