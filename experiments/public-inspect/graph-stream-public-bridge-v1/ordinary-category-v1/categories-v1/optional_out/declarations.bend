import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord

def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}}
def parent(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{2,"Parent","Children",G.Hierarchy{}}
def declared_link(~S:Data) -> Ord.Declaration<S>:
  Ord.relation(~S,link(~S))
def declared_parent(~S:Data) -> Ord.Declaration<S>:
  Ord.relation(~S,parent(~S))
