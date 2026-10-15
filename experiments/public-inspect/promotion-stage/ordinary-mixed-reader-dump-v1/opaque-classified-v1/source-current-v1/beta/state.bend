import Base
import ../owner-observer.bend as Owner
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/relation-commands.bend as Relation
import ../../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../../src/ecs/relation-failure-reader.bend as Ordinary
import ../../../../../../../src/ecs/event-publication.bend as Publication
type S is Data:S{}
type FirstEvent is Data:FirstEvent{value:U32}
type SecondEvent is Data:SecondEvent{value:Bool}
type UnusedEvent is Data:UnusedEvent{value:U32}
def PairEvents() -> Data:Publication.Publication<FirstEvent,SecondEvent>
def Publications() -> Data:Publication.Publication<PairEvents(),UnusedEvent>
def Events() -> Data:Relation.Notice<S,Publications()>
type Payload is Type:Payload{left:Array<U32>,right:Array<U32>,tag:U32}
type Components is Type:Components{column:Col.Column<S,Payload>,sibling:Array<U32>}
def presented(+tag:U32,left:Array<U32> & String,right:Array<U32> & String) -> Payload & String:
  match left right:
    case (left,leftText),(right,rightText):(Payload{left,right,tag},"Payload{left=" ++ leftText ++ ";right=" ++ rightText ++ ";tag=" ++ U32.show(tag) ++ "}")
def present(value:Payload) -> Payload & String:
  match value:
    case Payload{left,right,tag}:presented(tag,Owner.u32_array(left),Owner.u32_array(right))
def Store() -> Type:Relation.Store<S,Components>
def Resources() -> Type:Array<U32>
def World() -> Type:W.World<S,Store(),Resources(),Events()>
def empty(unit:Unit) -> Store():Relation.Store{Components{Col.Column{ANode{ALeaf{Some{Payload{ANode{ALeaf{41},ALeaf{42}},ANode{ALeaf{51},ALeaf{52}},61}}},ALeaf{None{}}},[]},ANode{ALeaf{11},ALeaf{12}}},G.Graph{[],[]}}
def parent() -> Ordinary.Declaration<S>:Ordinary.relation(~S,G.Descriptor{2,"Parent","Children",G.Hierarchy{}})

def parent_descriptor(value:Ordinary.Declaration<S>) -> G.Descriptor<S>:
  match value:
    case Ordinary.Declaration{descriptor}:descriptor
def descriptor() -> G.Descriptor<S>:parent_descriptor(parent())
