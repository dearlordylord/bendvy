import owner-carrier.bend as Carrier
import Base
import runtime-named-declarations.bend as D
import schema-families.bend as Families
import runtime-owners.bend as Owners
import full-consumer.bend as Consumer
import consumer-witness.bend as Caps
import format.bend as Format
import query.bend as Q
import traversal.bend as Traversal
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/world.bend as W

type QueryKind is Data:
  KindEmpty{}
  KindOptionalFour{}
  KindRequiredPair{}
  KindFiveAlias{}
  KindWithWithout{}
  KindMultipleWith{}
  KindMultipleWithout{}
  KindRepeated{}
  KindContradictory{}
  KindAddedBoth{}
  KindChangedBoth{}
  KindMixedFilters{}
  KindRepeatedAdded{}
  KindOptionalUnselectedFilter{}
def serialized(~H:Type,~S:Data,~V:Data,~format:V -> String,name:String,observed:H & Result<&2,&2,Unit,Consumer.Snapshot<S,V>>) -> H & Result<&2,&2,Unit,String>:
  match observed:
    case (owner,Fail{error}):(owner,Fail{error})
    case (owner,Done{value}):(owner,Done{Format.snapshot(~S,~V,~format,name,value)})
def empty_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueEmpty>
def empty_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,empty_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueEmpty,~D.inspect_empty(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def empty_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueEmpty>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueEmpty,~Format.value_empty,"empty",Consumer.body(~H,~S,~D.ValueEmpty,~caps,targets,owner))
def empty(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~empty_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~empty_plan(~S),~empty_body(~S),instance,targets,world)
def optionalFour_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueOptionalFour>
def optionalFour_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,optionalFour_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueOptionalFour,~D.inspect_optionalFour(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def optionalFour_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueOptionalFour>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueOptionalFour,~Format.value_optionalFour,"optionalFour",Consumer.body(~H,~S,~D.ValueOptionalFour,~caps,targets,owner))
def optionalFour(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~optionalFour_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~optionalFour_plan(~S),~optionalFour_body(~S),instance,targets,world)
def requiredPair_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueRequiredPair>
def requiredPair_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,requiredPair_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueRequiredPair,~D.inspect_requiredPair(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def requiredPair_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueRequiredPair>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueRequiredPair,~Format.value_requiredPair,"requiredPair",Consumer.body(~H,~S,~D.ValueRequiredPair,~caps,targets,owner))
def requiredPair(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~requiredPair_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~requiredPair_plan(~S),~requiredPair_body(~S),instance,targets,world)
def fiveAlias_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueFiveAlias>
def fiveAlias_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,fiveAlias_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueFiveAlias,~D.inspect_fiveAlias(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def fiveAlias_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueFiveAlias>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueFiveAlias,~Format.value_fiveAlias,"fiveAlias",Consumer.body(~H,~S,~D.ValueFiveAlias,~caps,targets,owner))
def fiveAlias(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~fiveAlias_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~fiveAlias_plan(~S),~fiveAlias_body(~S),instance,targets,world)
def withWithout_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueWithWithout>
def withWithout_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,withWithout_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueWithWithout,~D.inspect_withWithout(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def withWithout_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueWithWithout>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueWithWithout,~Format.value_withWithout,"withWithout",Consumer.body(~H,~S,~D.ValueWithWithout,~caps,targets,owner))
def withWithout(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~withWithout_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~withWithout_plan(~S),~withWithout_body(~S),instance,targets,world)
def multipleWith_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueMultipleWith>
def multipleWith_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,multipleWith_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueMultipleWith,~D.inspect_multipleWith(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def multipleWith_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueMultipleWith>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueMultipleWith,~Format.value_multipleWith,"multipleWith",Consumer.body(~H,~S,~D.ValueMultipleWith,~caps,targets,owner))
def multipleWith(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~multipleWith_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~multipleWith_plan(~S),~multipleWith_body(~S),instance,targets,world)
def multipleWithout_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueMultipleWithout>
def multipleWithout_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,multipleWithout_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueMultipleWithout,~D.inspect_multipleWithout(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def multipleWithout_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueMultipleWithout>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueMultipleWithout,~Format.value_multipleWithout,"multipleWithout",Consumer.body(~H,~S,~D.ValueMultipleWithout,~caps,targets,owner))
def multipleWithout(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~multipleWithout_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~multipleWithout_plan(~S),~multipleWithout_body(~S),instance,targets,world)
def repeated_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueRepeated>
def repeated_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,repeated_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueRepeated,~D.inspect_repeated(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def repeated_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueRepeated>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueRepeated,~Format.value_repeated,"repeated",Consumer.body(~H,~S,~D.ValueRepeated,~caps,targets,owner))
def repeated(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~repeated_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~repeated_plan(~S),~repeated_body(~S),instance,targets,world)
def contradictory_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueContradictory>
def contradictory_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,contradictory_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueContradictory,~D.inspect_contradictory(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def contradictory_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueContradictory>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueContradictory,~Format.value_contradictory,"contradictory",Consumer.body(~H,~S,~D.ValueContradictory,~caps,targets,owner))
def contradictory(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~contradictory_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~contradictory_plan(~S),~contradictory_body(~S),instance,targets,world)
def addedBoth_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueAddedBoth>
def addedBoth_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,addedBoth_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueAddedBoth,~D.inspect_addedBoth(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def addedBoth_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueAddedBoth>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueAddedBoth,~Format.value_addedBoth,"addedBoth",Consumer.body(~H,~S,~D.ValueAddedBoth,~caps,targets,owner))
def addedBoth(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~addedBoth_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~addedBoth_plan(~S),~addedBoth_body(~S),instance,targets,world)
def changedBoth_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueChangedBoth>
def changedBoth_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,changedBoth_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueChangedBoth,~D.inspect_changedBoth(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def changedBoth_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueChangedBoth>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueChangedBoth,~Format.value_changedBoth,"changedBoth",Consumer.body(~H,~S,~D.ValueChangedBoth,~caps,targets,owner))
def changedBoth(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~changedBoth_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~changedBoth_plan(~S),~changedBoth_body(~S),instance,targets,world)
def mixedFilters_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueMixedFilters>
def mixedFilters_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,mixedFilters_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueMixedFilters,~D.inspect_mixedFilters(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def mixedFilters_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueMixedFilters>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueMixedFilters,~Format.value_mixedFilters,"mixedFilters",Consumer.body(~H,~S,~D.ValueMixedFilters,~caps,targets,owner))
def mixedFilters(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~mixedFilters_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~mixedFilters_plan(~S),~mixedFilters_body(~S),instance,targets,world)
def repeatedAdded_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueRepeatedAdded>
def repeatedAdded_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,repeatedAdded_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueRepeatedAdded,~D.inspect_repeatedAdded(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def repeatedAdded_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueRepeatedAdded>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueRepeatedAdded,~Format.value_repeatedAdded,"repeatedAdded",Consumer.body(~H,~S,~D.ValueRepeatedAdded,~caps,targets,owner))
def repeatedAdded(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~repeatedAdded_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~repeatedAdded_plan(~S),~repeatedAdded_body(~S),instance,targets,world)
def optionalUnselectedFilter_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueOptionalUnselectedFilter>
def optionalUnselectedFilter_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,optionalUnselectedFilter_ops(~S)>:
  I.Plan{Caps.Reads{Carrier.inspect_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~D.ValueOptionalUnselectedFilter,~D.inspect_optionalUnselectedFilter(~S,~Owners.Resource<S>),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def optionalUnselectedFilter_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueOptionalUnselectedFilter>,targets:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,String>:
  serialized(~H,~S,~D.ValueOptionalUnselectedFilter,~Format.value_optionalUnselectedFilter,"optionalUnselectedFilter",Consumer.body(~H,~S,~D.ValueOptionalUnselectedFilter,~caps,targets,owner))
def optionalUnselectedFilter(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  I.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~optionalUnselectedFilter_ops(~S),~List<&2,W.Handle<S>>,~Unit,~String,~optionalUnselectedFilter_plan(~S),~optionalUnselectedFilter_body(~S),instance,targets,world)
def run(~S:Data,kind:QueryKind,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource<S>,U32,Unit,String>:
  match kind:
    case KindEmpty{}:empty(~S,world,instance,targets)
    case KindOptionalFour{}:optionalFour(~S,world,instance,targets)
    case KindRequiredPair{}:requiredPair(~S,world,instance,targets)
    case KindFiveAlias{}:fiveAlias(~S,world,instance,targets)
    case KindWithWithout{}:withWithout(~S,world,instance,targets)
    case KindMultipleWith{}:multipleWith(~S,world,instance,targets)
    case KindMultipleWithout{}:multipleWithout(~S,world,instance,targets)
    case KindRepeated{}:repeated(~S,world,instance,targets)
    case KindContradictory{}:contradictory(~S,world,instance,targets)
    case KindAddedBoth{}:addedBoth(~S,world,instance,targets)
    case KindChangedBoth{}:changedBoth(~S,world,instance,targets)
    case KindMixedFilters{}:mixedFilters(~S,world,instance,targets)
    case KindRepeatedAdded{}:repeatedAdded(~S,world,instance,targets)
    case KindOptionalUnselectedFilter{}:optionalUnselectedFilter(~S,world,instance,targets)
def workshop(kind:QueryKind,world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Owners.Resource<Families.Workshop>,U32>,instance:I.Instance<Families.Workshop>,targets:List<&2,W.Handle<Families.Workshop>>) -> I.Observed<Families.Workshop,Families.Store<Families.Workshop>,Owners.Resource<Families.Workshop>,U32,Unit,String>:
  run(~Families.Workshop,kind,world,instance,targets)
def garden(kind:QueryKind,world:W.World<Families.Garden,Families.Store<Families.Garden>,Owners.Resource<Families.Garden>,U32>,instance:I.Instance<Families.Garden>,targets:List<&2,W.Handle<Families.Garden>>) -> I.Observed<Families.Garden,Families.Store<Families.Garden>,Owners.Resource<Families.Garden>,U32,Unit,String>:
  run(~Families.Garden,kind,world,instance,targets)
def main() -> Unit:
  Unit{}
