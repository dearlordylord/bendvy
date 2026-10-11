import Base
import ./relation-failure-reader.bend as Ord
import ./relation-types.bend as G
import ./relation-query.bend as RQ
import ./relation-commands.bend as A
import ./inspector.bend as I
import ./check.bend as K
import ./inspector-query.bend as Query
import ./inspector-query-projection.bend as Select
import ./inspector-relation-projection.bend as IR
import ./check-relation-projection.bend as CR

# A closed ordinary relation declaration selects every relation clause.
# Traversal, liveness and owner preservation remain in the existing projections.
type Mode is Data:
  RequiredOut{key:String}
  OptionalOut{key:String}
  PresentOut{}
  AbsentOut{}
  RequiredIn{key:String}
  OptionalIn{key:String}
  PresentIn{}
  AbsentIn{}
type Declaration<S:Data> is Data:
  Declaration{source:Ord.Declaration<S>,mode:Mode}
def descriptor(~S:Data,declaration:Ord.Declaration<S>) -> G.Descriptor<S>:
  match declaration:
    case Ord.Declaration{value}:value
def selected_spec(~S:Data,source:Ord.Declaration<S>,mode:Mode) -> RQ.Spec<S>:
  match mode:
    case RequiredOut{key}:RQ.Spec{[RQ.read_relation(~S,key,descriptor(~S,source))]}
    case OptionalOut{key}:RQ.Spec{[RQ.optional_relation(~S,key,descriptor(~S,source))]}
    case PresentOut{}:RQ.Spec{[RQ.with_relation(~S,descriptor(~S,source))]}
    case AbsentOut{}:RQ.Spec{[RQ.without_relation(~S,descriptor(~S,source))]}
    case RequiredIn{key}:RQ.Spec{[RQ.read_relation(~S,key,descriptor(~S,source))]}
    case OptionalIn{key}:RQ.Spec{[RQ.optional_related(~S,key,descriptor(~S,source))]}
    case PresentIn{}:RQ.Spec{[RQ.with_related(~S,descriptor(~S,source))]}
    case AbsentIn{}:RQ.Spec{[RQ.without_related(~S,descriptor(~S,source))]}
def spec(~S:Data,declaration:Declaration<S>) -> RQ.Spec<S>:
  match declaration:
    case Declaration{source,mode}:selected_spec(~S,source,mode)
def required_out(~S:Data,key:String,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,RequiredOut{key}}
def optional_out(~S:Data,key:String,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,OptionalOut{key}}
def present_out(~S:Data,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,PresentOut{}}
def absent_out(~S:Data,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,AbsentOut{}}
def required_in(~S:Data,key:String,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,RequiredIn{key}}
def optional_in(~S:Data,key:String,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,OptionalIn{key}}
def present_in(~S:Data,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,PresentIn{}}
def absent_in(~S:Data,declaration:Ord.Declaration<S>) -> Declaration<S>:
  Declaration{declaration,AbsentIn{}}
def inspect(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~component:Select.DeclaredSelection<I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,V>,~declaration:Declaration<S>) -> Query.ComposedReadQuery<I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,Select.Product<V,List<&2,RQ.Cell<S>>>>:
  IR.grant(~S,~C,~R,~E,~V,~component,~spec(~S,declaration))
def condition(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~component:Select.DeclaredSelection<K.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,V>,~declaration:Declaration<S>) -> Query.ComposedReadQuery<K.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,Select.Product<V,List<&2,RQ.Cell<S>>>>:
  CR.grant(~S,~C,~R,~E,~V,~component,~spec(~S,declaration))
