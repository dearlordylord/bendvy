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
import core-v1/src/ecs/check.bend as Check
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/string-equality.bend as SE

type CheckKind is Data:
  CheckEmpty{}
  CheckOptionalFour{}
  CheckRequiredPair{}
  CheckFiveAlias{}
  CheckWithWithout{}
  CheckMultipleWith{}
  CheckMultipleWithout{}
  CheckRepeated{}
  CheckContradictory{}
type Args<S:Data> is Data:
  Args{targets:List<&2,W.Handle<S>>,record:String}
def no_resources(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> W.World<S,Families.Store<S>,Owners.Resource<S>,U32> & List<&2,String>:
  (world,[])
def nonempty(~A:Data,values:List<&2,A>) -> Bool:
  match values:
    case []:False{}
    case _ <> _:True{}
def compared(~H:Type,~S:Data,~V:Data,~format:V -> String,name:String,expected:String,owner:H,+value:Consumer.Snapshot<S,V>) -> H & Bool:
  match value:
    case Consumer.Snapshot{rows,_,_,_}:(owner,Bool.and(nonempty(~Q.Row<S,V>,rows),SE.equal(Format.snapshot(~S,~V,~format,name,value),expected)))
def checked(~H:Type,~S:Data,~V:Data,~format:V -> String,name:String,expected:String,observed:H & Result<&2,&2,Unit,Consumer.Snapshot<S,V>>) -> H & Bool:
  match observed:
    case (owner,Fail{_}):(owner,False{})
    case (owner,Done{value}):compared(~H,~S,~V,~format,name,expected,owner,value)
def body(~H:Type,~S:Data,~V:Data,~format:V -> String,~caps:Caps.Reads<H,S,V>,name:String,owner:H,args:Args<S>) -> H & Bool:
  match args:
    case Args{targets,expected}:checked(~H,~S,~V,~format,name,expected,Consumer.body(~H,~S,~V,~caps,targets,owner))
def empty_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueEmpty>
def empty_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,empty_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueEmpty,~D.check_empty(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def empty_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueEmpty>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueEmpty,~Format.value_empty,~caps,"empty",owner,args)
def empty(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~empty_ops(~S),~Args<S>,~empty_body(~S),~empty_plan(~S),args,world)
def optionalFour_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueOptionalFour>
def optionalFour_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,optionalFour_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueOptionalFour,~D.check_optionalFour(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def optionalFour_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueOptionalFour>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueOptionalFour,~Format.value_optionalFour,~caps,"optionalFour",owner,args)
def optionalFour(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~optionalFour_ops(~S),~Args<S>,~optionalFour_body(~S),~optionalFour_plan(~S),args,world)
def requiredPair_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueRequiredPair>
def requiredPair_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,requiredPair_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueRequiredPair,~D.check_requiredPair(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def requiredPair_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueRequiredPair>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueRequiredPair,~Format.value_requiredPair,~caps,"requiredPair",owner,args)
def requiredPair(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~requiredPair_ops(~S),~Args<S>,~requiredPair_body(~S),~requiredPair_plan(~S),args,world)
def fiveAlias_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueFiveAlias>
def fiveAlias_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,fiveAlias_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueFiveAlias,~D.check_fiveAlias(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def fiveAlias_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueFiveAlias>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueFiveAlias,~Format.value_fiveAlias,~caps,"fiveAlias",owner,args)
def fiveAlias(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~fiveAlias_ops(~S),~Args<S>,~fiveAlias_body(~S),~fiveAlias_plan(~S),args,world)
def withWithout_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueWithWithout>
def withWithout_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,withWithout_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueWithWithout,~D.check_withWithout(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def withWithout_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueWithWithout>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueWithWithout,~Format.value_withWithout,~caps,"withWithout",owner,args)
def withWithout(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~withWithout_ops(~S),~Args<S>,~withWithout_body(~S),~withWithout_plan(~S),args,world)
def multipleWith_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueMultipleWith>
def multipleWith_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,multipleWith_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueMultipleWith,~D.check_multipleWith(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def multipleWith_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueMultipleWith>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueMultipleWith,~Format.value_multipleWith,~caps,"multipleWith",owner,args)
def multipleWith(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~multipleWith_ops(~S),~Args<S>,~multipleWith_body(~S),~multipleWith_plan(~S),args,world)
def multipleWithout_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueMultipleWithout>
def multipleWithout_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,multipleWithout_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueMultipleWithout,~D.check_multipleWithout(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def multipleWithout_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueMultipleWithout>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueMultipleWithout,~Format.value_multipleWithout,~caps,"multipleWithout",owner,args)
def multipleWithout(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~multipleWithout_ops(~S),~Args<S>,~multipleWithout_body(~S),~multipleWithout_plan(~S),args,world)
def repeated_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueRepeated>
def repeated_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,repeated_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueRepeated,~D.check_repeated(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def repeated_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueRepeated>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueRepeated,~Format.value_repeated,~caps,"repeated",owner,args)
def repeated(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~repeated_ops(~S),~Args<S>,~repeated_body(~S),~repeated_plan(~S),args,world)
def contradictory_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueContradictory>
def contradictory_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,contradictory_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~D.ValueContradictory,~D.check_contradictory(~S,~Owners.Resource<S>),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def contradictory_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueContradictory>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~D.ValueContradictory,~Format.value_contradictory,~caps,"contradictory",owner,args)
def contradictory(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~contradictory_ops(~S),~Args<S>,~contradictory_body(~S),~contradictory_plan(~S),args,world)
def run(~S:Data,kind:CheckKind,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  match kind:
    case CheckEmpty{}:empty(~S,args,world)
    case CheckOptionalFour{}:optionalFour(~S,args,world)
    case CheckRequiredPair{}:requiredPair(~S,args,world)
    case CheckFiveAlias{}:fiveAlias(~S,args,world)
    case CheckWithWithout{}:withWithout(~S,args,world)
    case CheckMultipleWith{}:multipleWith(~S,args,world)
    case CheckMultipleWithout{}:multipleWithout(~S,args,world)
    case CheckRepeated{}:repeated(~S,args,world)
    case CheckContradictory{}:contradictory(~S,args,world)
def workshop(kind:CheckKind,args:Args<Families.Workshop>,world:W.World<Families.Workshop,Families.Store<Families.Workshop>,Owners.Resource<Families.Workshop>,U32>) -> Check.Checked<Families.Workshop,Families.Store<Families.Workshop>,Owners.Resource<Families.Workshop>,U32>:
  run(~Families.Workshop,kind,args,world)
def garden(kind:CheckKind,args:Args<Families.Garden>,world:W.World<Families.Garden,Families.Store<Families.Garden>,Owners.Resource<Families.Garden>,U32>) -> Check.Checked<Families.Garden,Families.Store<Families.Garden>,Owners.Resource<Families.Garden>,U32>:
  run(~Families.Garden,kind,args,world)
def main() -> Unit:
  Unit{}
