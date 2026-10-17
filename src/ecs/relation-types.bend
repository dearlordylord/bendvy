import Base
import entity-key.bend as K

type RelationKind is Data:
  Ordinary{}
  Hierarchy{}
type Descriptor<S: Data> is Data:
  Descriptor{key: U32,name: String,inverseName: String,kind: RelationKind}
type Edge<S: Data> is Data:
  Edge{relation: Descriptor<S>,source: K.Key,target: K.Key}
type Error is Data:
  MissingEntity{source: K.Key}
  MissingTargetEntity{source: K.Key,target: K.Key,relation: String}
  SelfRelationNotAllowed{source: K.Key,relation: String}
  HierarchyCycle{source: K.Key,target: K.Key,relation: String}
  MissingChildEntity{source: K.Key,child: K.Key,relation: String}
  DuplicateChild{source: K.Key,child: K.Key,relation: String}
  ChildNotRelatedToParent{source: K.Key,child: K.Key,relation: String}
  ChildSetMismatch{source: K.Key,relation: String}
type Operation is Data:
  Relate{}
  ReorderChildren{}
type Failure<S: Data> is Data:
  Failure{relation: Descriptor<S>,operation: Operation,source: K.Key,target: K.Key,error: Error}
type Inverse<S: Data> is Data:
  Inverse{relation: Descriptor<S>,target: K.Key,sources: List<&2,K.Key>}
type SpecGraph<S: Data> is Data:
  SpecGraph{edges: List<&2,Edge<S>>}
type Graph<S: Data> is Data:
  Graph{edges: List<&2,Edge<S>>,inverses: List<&2,Inverse<S>>}
type SpecResult<S: Data> is Data:
  SpecResult{graph: SpecGraph<S>,error: Maybe<&2,Error>}
type CoreResult<S: Data> is Data:
  CoreResult{graph: Graph<S>,error: Maybe<&2,Error>}
type ChildStatus is Data:
  ChildStatus{id: K.Key,live: Bool}

# Diagnostic continuation, not a new relation rejection policy.
type CleanupFrame<S:Data> is Data:
  CleanupEnter{id:K.Key}
  CleanupDescriptors{id:K.Key,remaining:List<&2,Descriptor<S>>}
  CleanupChildren{id:K.Key,descriptor:Descriptor<S>,remainingDescriptors:List<&2,Descriptor<S>>,remainingChildren:List<&2,K.Key>}
  CleanupFinish{id:K.Key}
# Public reorder provisioning accepts this nominal hierarchy family only.
type HierarchyDescriptor<S:Data> is Data:
  HierarchyDescriptor{key:U32,name:String,inverseName:String}
