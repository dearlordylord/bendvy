import core/inspector-query-projection.bend as Selection
import owner-carrier.bend as Carrier
import Base
import runtime-named-declarations.bend as D
import schema-families.bend as Families
import runtime-owners.bend as Owners
import full-consumer.bend as Consumer
import consumer-witness.bend as Caps
import format.bend as Format
import core/inspector-query.bend as Q
import core/inspector-query-world.bend as Traversal
import core/check.bend as Check
import core/world.bend as W
import core/string-equality.bend as SE

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
    case Consumer.Snapshot{rows,_,_,_}:(owner,Bool.and(nonempty(~Q.ProjectedRow<S,V>,rows),SE.equal(Format.snapshot(~S,~V,~format,name,value),expected)))
def checked(~H:Type,~S:Data,~V:Data,~format:V -> String,name:String,expected:String,observed:H & Result<&2,&2,Unit,Consumer.Snapshot<S,V>>) -> H & Bool:
  match observed:
    case (owner,Fail{_}):(owner,False{})
    case (owner,Done{value}):compared(~H,~S,~V,~format,name,expected,owner,value)
def body(~H:Type,~S:Data,~V:Data,~format:V -> String,~caps:Caps.Reads<H,S,V>,name:String,owner:H,args:Args<S>) -> H & Bool:
  match args:
    case Args{targets,expected}:checked(~H,~S,~V,~format,name,expected,Consumer.body(~H,~S,~V,~caps,targets,owner))
def selected_ops(~S:Data,~V:Data,H:Type) -> Type:
  Caps.Reads<H,S,V>
def selected_plan(~S:Data,~V:Data,~selection:Selection.DeclaredSelection<Carrier.CheckOwner<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>) -> Check.Plan<S,Families.Store<S>,Owners.Resource<S>,U32,selected_ops(~S,~V)>:
  Check.Plan{no_resources(~S),Caps.Reads{Carrier.check_grant(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~V,~selection,~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource<S>,~U32))}}
def selected_body(~S:Data,~V:Data,~format:V -> String,~name:String,~H:Type,~caps:Caps.Reads<H,S,V>,args:Args<S>,owner:H) -> H & Bool:
  body(~H,~S,~V,~format,~caps,name,owner,args)
def selected(~S:Data,~V:Data,~selection:Selection.DeclaredSelection<Carrier.CheckOwner<S,Families.Store<S>,Owners.Resource<S>,U32>,S,V>,~format:V -> String,~name:String,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource<S>,~U32,~selected_ops(~S,~V),~Args<S>,~selected_body(~S,~V,~format,~name),~selected_plan(~S,~V,~selection),args,world)
def empty(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueEmpty,~D.check_empty(~S,~Owners.Resource<S>),~Format.value_empty,~"empty",args,world)
def optionalFour(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueOptionalFour,~D.check_optionalFour(~S,~Owners.Resource<S>),~Format.value_optionalFour,~"optionalFour",args,world)
def requiredPair(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueRequiredPair,~D.check_requiredPair(~S,~Owners.Resource<S>),~Format.value_requiredPair,~"requiredPair",args,world)
def fiveAlias(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueFiveAlias,~D.check_fiveAlias(~S,~Owners.Resource<S>),~Format.value_fiveAlias,~"fiveAlias",args,world)
def withWithout(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueWithWithout,~D.check_withWithout(~S,~Owners.Resource<S>),~Format.value_withWithout,~"withWithout",args,world)
def multipleWith(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueMultipleWith,~D.check_multipleWith(~S,~Owners.Resource<S>),~Format.value_multipleWith,~"multipleWith",args,world)
def multipleWithout(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueMultipleWithout,~D.check_multipleWithout(~S,~Owners.Resource<S>),~Format.value_multipleWithout,~"multipleWithout",args,world)
def repeated(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueRepeated,~D.check_repeated(~S,~Owners.Resource<S>),~Format.value_repeated,~"repeated",args,world)
def contradictory(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource<S>,U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource<S>,U32>:
  selected(~S,~D.ValueContradictory,~D.check_contradictory(~S,~Owners.Resource<S>),~Format.value_contradictory,~"contradictory",args,world)
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
