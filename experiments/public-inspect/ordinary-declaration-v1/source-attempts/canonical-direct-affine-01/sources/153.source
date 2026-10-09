import Base

type RelationKind is Data:
  Ordinary{}
  Hierarchy{}
type Descriptor<S: Data> is Data:
  Descriptor{key: U32,name: String,inverseName: String,kind: RelationKind}
type Edge<S: Data> is Data:
  Edge{relation: Descriptor<S>,source: U32,target: U32}
type Error is Data:
  MissingEntity{source: U32}
  MissingTargetEntity{source: U32,target: U32,relation: String}
  SelfRelationNotAllowed{source: U32,relation: String}
  HierarchyCycle{source: U32,target: U32,relation: String}
  MissingChildEntity{source: U32,child: U32,relation: String}
  DuplicateChild{source: U32,child: U32,relation: String}
  ChildNotRelatedToParent{source: U32,child: U32,relation: String}
  ChildSetMismatch{source: U32,relation: String}
type Operation is Data:
  Relate{}
  ReorderChildren{}
type Failure<S: Data> is Data:
  Failure{relation: Descriptor<S>,operation: Operation,source: U32,target: U32,error: Error}
type Inverse<S: Data> is Data:
  Inverse{relation: Descriptor<S>,target: U32,sources: List<&2,U32>}
type SpecGraph<S: Data> is Data:
  SpecGraph{edges: List<&2,Edge<S>>}
type Graph<S: Data> is Data:
  Graph{edges: List<&2,Edge<S>>,inverses: List<&2,Inverse<S>>}
type SpecResult<S: Data> is Data:
  SpecResult{graph: SpecGraph<S>,error: Maybe<&2,Error>}
type CoreResult<S: Data> is Data:
  CoreResult{graph: Graph<S>,error: Maybe<&2,Error>}
type ChildStatus is Data:
  ChildStatus{id: U32,live: Bool}

# Diagnostic continuation, not a new relation rejection policy.
type CleanupFrame<S:Data> is Data:
  CleanupEnter{id:U32}
  CleanupDescriptors{id:U32,remaining:List<&2,Descriptor<S>>}
  CleanupChildren{id:U32,descriptor:Descriptor<S>,remainingDescriptors:List<&2,Descriptor<S>>,remainingChildren:List<&2,U32>}
  CleanupFinish{id:U32}
# Public reorder provisioning accepts this nominal hierarchy family only.
type HierarchyDescriptor<S:Data> is Data:
  HierarchyDescriptor{key:U32,name:String,inverseName:String}
