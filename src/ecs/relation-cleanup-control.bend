import Base
import ./relation-types.bend as T
import ./entity-key.bend as Key

# Both storage adapters execute this same cleanup continuation. Intents carry
# identities and descriptors only; they contain no World mutator or owner.
type Intent<-S:Data> is Data:
  Check{key:Key.Key,descriptors:List<&2,T.Descriptor<S>>,frames:List<&2,T.CleanupFrame<S>>}
  Observe{key:Key.Key,descriptor:T.Descriptor<S>,remaining:List<&2,T.Descriptor<S>>,frames:List<&2,T.CleanupFrame<S>>}
  Unrelate{key:Key.Key,descriptor:T.Descriptor<S>,frames:List<&2,T.CleanupFrame<S>>}
  Finish{key:Key.Key,frames:List<&2,T.CleanupFrame<S>>}
  Continue{frames:List<&2,T.CleanupFrame<S>>}
def child_intent(-S:Data,kind:T.RelationKind,+key:Key.Key,+descriptor:T.Descriptor<S>,remaining:List<&2,T.Descriptor<S>>,child:Key.Key,children:List<&2,Key.Key>,frames:List<&2,T.CleanupFrame<S>>) -> Intent<S>:
  match kind:
    case T.Hierarchy{}:Continue{T.CleanupEnter{child} <> T.CleanupChildren{key,descriptor,remaining,children} <> frames}
    case T.Ordinary{}:Unrelate{child,descriptor,T.CleanupChildren{key,descriptor,remaining,children} <> frames}
def kind(-S:Data,descriptor:T.Descriptor<S>) -> T.RelationKind:
  match descriptor:
    case T.Descriptor{_,_,_,kind}:kind
def next(-S:Data,frame:T.CleanupFrame<S>,descriptors:List<&2,T.Descriptor<S>>,frames:List<&2,T.CleanupFrame<S>>) -> Intent<S>:
  match frame:
    case T.CleanupEnter{key}:Check{key,descriptors,frames}
    case T.CleanupDescriptors{key,[]}:Continue{T.CleanupFinish{key} <> frames}
    case T.CleanupDescriptors{key,descriptor <> remaining}:Observe{key,descriptor,remaining,frames}
    case T.CleanupChildren{+key,descriptor,remaining,[]}:Unrelate{key,descriptor,T.CleanupDescriptors{key,remaining} <> frames}
    case T.CleanupChildren{key,+descriptor,remaining,child <> children}:child_intent(S,kind(S,descriptor),key,descriptor,remaining,child,children,frames)
    case T.CleanupFinish{key}:Finish{key,frames}
