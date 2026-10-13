import Base
import runtime-named-declarations.bend as D
import schema-families.bend as Families
import runtime-owners.bend as Owners
import execution.bend as Consumer
import execution.bend as Caps
import format.bend as Format
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-world.bend as Traversal
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/string-equality.bend as SE

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
def no_resources(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> W.World<S,Families.Store<S>,Owners.Resource(~S),U32> & List<&2,String>:
  (world,[])
def nonempty(~A:Data,values:List<&2,A>) -> Bool:
  match values:
    case []:False{}
    case _ <> _:True{}
def checked(~H:Type,~S:Data,~V:Data,~format:V -> String,name:String,expected:String,result:H & List<&2,Q.ProjectedRow<S,V>>) -> H & Bool:
  (owner,+rows)=result
  (owner,Bool.and(nonempty(~Q.ProjectedRow<S,V>,rows),SE.equal(name ++ "=" ++ Format.list(~Q.ProjectedRow<S,V>,~Format.row(~S,~V,~format),rows),expected)))
def body(~H:Type,~S:Data,~V:Data,~format:V -> String,~caps:Caps.Reads<H,S,V>,name:String,owner:H,args:Args<S>) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~V,~format,name,expected,Q.each_composed(~H,~S,~V,~Consumer.query(~H,~S,~V,caps),owner))
def empty_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueEmpty>
def empty_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,empty_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueEmpty,~D.check_empty(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def empty_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueEmpty>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~D.ValueEmpty,~Format.value_empty,"empty",expected,Q.each_composed(~H,~S,~D.ValueEmpty,~Consumer.query(~H,~S,~D.ValueEmpty,caps),owner))
def empty(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~empty_ops(~S),~Args<S>,~empty_body(~S),~empty_plan(~S),args,world)
def optionalFour_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueOptionalFour>
def optionalFour_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,optionalFour_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueOptionalFour,~D.check_optionalFour(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def optionalFour_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueOptionalFour>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~D.ValueOptionalFour,~Format.value_optionalFour,"optionalFour",expected,Q.each_composed(~H,~S,~D.ValueOptionalFour,~Consumer.query(~H,~S,~D.ValueOptionalFour,caps),owner))
def optionalFour(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~optionalFour_ops(~S),~Args<S>,~optionalFour_body(~S),~optionalFour_plan(~S),args,world)
def requiredPair_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueRequiredPair>
def requiredPair_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,requiredPair_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueRequiredPair,~D.check_requiredPair(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def requiredPair_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueRequiredPair>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~D.ValueRequiredPair,~Format.value_requiredPair,"requiredPair",expected,Q.each_composed(~H,~S,~D.ValueRequiredPair,~Consumer.query(~H,~S,~D.ValueRequiredPair,caps),owner))
def requiredPair(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~requiredPair_ops(~S),~Args<S>,~requiredPair_body(~S),~requiredPair_plan(~S),args,world)
def fiveAlias_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,D.ValueFiveAlias>
def fiveAlias_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,fiveAlias_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueFiveAlias,~D.check_fiveAlias(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def fiveAlias_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,D.ValueFiveAlias>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~D.ValueFiveAlias,~Format.value_fiveAlias,"fiveAlias",expected,Q.each_composed(~H,~S,~D.ValueFiveAlias,~Consumer.query(~H,~S,~D.ValueFiveAlias,caps),owner))
def fiveAlias(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~fiveAlias_ops(~S),~Args<S>,~fiveAlias_body(~S),~fiveAlias_plan(~S),args,world)
def withWithout_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,Unit>
def withWithout_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,withWithout_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.check_withWithout(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def withWithout_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,Unit>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~Unit,~Format.value_unit,"withWithout",expected,Q.each_composed(~H,~S,~Unit,~Consumer.query(~H,~S,~Unit,caps),owner))
def withWithout(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~withWithout_ops(~S),~Args<S>,~withWithout_body(~S),~withWithout_plan(~S),args,world)
def multipleWith_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,Unit>
def multipleWith_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,multipleWith_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.check_multipleWith(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def multipleWith_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,Unit>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~Unit,~Format.value_unit,"multipleWith",expected,Q.each_composed(~H,~S,~Unit,~Consumer.query(~H,~S,~Unit,caps),owner))
def multipleWith(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~multipleWith_ops(~S),~Args<S>,~multipleWith_body(~S),~multipleWith_plan(~S),args,world)
def multipleWithout_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,Unit>
def multipleWithout_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,multipleWithout_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.check_multipleWithout(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def multipleWithout_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,Unit>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~Unit,~Format.value_unit,"multipleWithout",expected,Q.each_composed(~H,~S,~Unit,~Consumer.query(~H,~S,~Unit,caps),owner))
def multipleWithout(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~multipleWithout_ops(~S),~Args<S>,~multipleWithout_body(~S),~multipleWithout_plan(~S),args,world)
def repeated_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,Unit>
def repeated_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,repeated_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.check_repeated(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def repeated_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,Unit>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~Unit,~Format.value_unit,"repeated",expected,Q.each_composed(~H,~S,~Unit,~Consumer.query(~H,~S,~Unit,caps),owner))
def repeated(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~repeated_ops(~S),~Args<S>,~repeated_body(~S),~repeated_plan(~S),args,world)
def contradictory_ops(~S:Data,H:Type) -> Type:
  Caps.Reads<H,S,Unit>
def contradictory_plan(~S:Data) -> Check.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,contradictory_ops(~S)>:
  Check.Plan{no_resources(~S),Caps.Reads{Q.grant_composed(~Check.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.check_contradictory(~S,~Owners.Resource(~S)),~Traversal.check_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def contradictory_body(~S:Data,~H:Type,~caps:Caps.Reads<H,S,Unit>,args:Args<S>,owner:H) -> H & Bool:
  match args:
    case Args{_,expected}:checked(~H,~S,~Unit,~Format.value_unit,"contradictory",expected,Q.each_composed(~H,~S,~Unit,~Consumer.query(~H,~S,~Unit,caps),owner))
def contradictory(~S:Data,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~contradictory_ops(~S),~Args<S>,~contradictory_body(~S),~contradictory_plan(~S),args,world)
def run(~S:Data,kind:CheckKind,args:Args<S>,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>) -> Check.Checked<S,Families.Store<S>,Owners.Resource(~S),U32>:
  match kind:
    case CheckEmpty{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~empty_ops(~S),~Args<S>,~empty_body(~S),~empty_plan(~S),args,world)
    case CheckOptionalFour{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~optionalFour_ops(~S),~Args<S>,~optionalFour_body(~S),~optionalFour_plan(~S),args,world)
    case CheckRequiredPair{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~requiredPair_ops(~S),~Args<S>,~requiredPair_body(~S),~requiredPair_plan(~S),args,world)
    case CheckFiveAlias{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~fiveAlias_ops(~S),~Args<S>,~fiveAlias_body(~S),~fiveAlias_plan(~S),args,world)
    case CheckWithWithout{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~withWithout_ops(~S),~Args<S>,~withWithout_body(~S),~withWithout_plan(~S),args,world)
    case CheckMultipleWith{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~multipleWith_ops(~S),~Args<S>,~multipleWith_body(~S),~multipleWith_plan(~S),args,world)
    case CheckMultipleWithout{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~multipleWithout_ops(~S),~Args<S>,~multipleWithout_body(~S),~multipleWithout_plan(~S),args,world)
    case CheckRepeated{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~repeated_ops(~S),~Args<S>,~repeated_body(~S),~repeated_plan(~S),args,world)
    case CheckContradictory{}:Check.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~contradictory_ops(~S),~Args<S>,~contradictory_body(~S),~contradictory_plan(~S),args,world)
