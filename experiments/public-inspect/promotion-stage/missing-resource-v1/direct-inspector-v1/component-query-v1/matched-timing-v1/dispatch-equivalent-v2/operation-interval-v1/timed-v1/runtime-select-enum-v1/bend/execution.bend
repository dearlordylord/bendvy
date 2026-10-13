import Base
import schema-families.bend as Families
import runtime-owners.bend as Owners
import runtime-named-declarations.bend as D
import format.bend as Format
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-world.bend as Traversal
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
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
type Reads<-H:Type,-S:Data,-V:Data> is Type:
  Reads{query:Q.ComposedReadQuery<H,S,V>}
def query(~H:Type,~S:Data,~V:Data,caps:Reads<H,S,V>) -> Q.ComposedReadQuery<H,S,V>:
  match caps:
    case Reads{query}:query
type Record<S:Data> is Data:
  EmptyRecord{name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueEmpty>>}
  OptionalFourRecord{name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueOptionalFour>>}
  RequiredPairRecord{name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueRequiredPair>>}
  FiveAliasRecord{name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueFiveAlias>>}
  MixedFiltersRecord{name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueMixedFilters>>}
  OptionalUnselectedFilterRecord{name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueOptionalUnselectedFilter>>}
  UnitRecord{name:String,rows:List<&2,Q.ProjectedRow<S,Unit>>}
  ErrorRecord{message:String}
def empty_record(~S:Data,name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueEmpty>>) -> Record<S>:
  EmptyRecord{name,rows}
def optionalFour_record(~S:Data,name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueOptionalFour>>) -> Record<S>:
  OptionalFourRecord{name,rows}
def requiredPair_record(~S:Data,name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueRequiredPair>>) -> Record<S>:
  RequiredPairRecord{name,rows}
def fiveAlias_record(~S:Data,name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueFiveAlias>>) -> Record<S>:
  FiveAliasRecord{name,rows}
def mixedFilters_record(~S:Data,name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueMixedFilters>>) -> Record<S>:
  MixedFiltersRecord{name,rows}
def optionalUnselectedFilter_record(~S:Data,name:String,rows:List<&2,Q.ProjectedRow<S,D.ValueOptionalUnselectedFilter>>) -> Record<S>:
  OptionalUnselectedFilterRecord{name,rows}
def unit_record(~S:Data,name:String,rows:List<&2,Q.ProjectedRow<S,Unit>>) -> Record<S>:
  UnitRecord{name,rows}
def captured(~H:Type,~S:Data,~V:Data,~wrap:String -> List<&2,Q.ProjectedRow<S,V>> -> Record<S>,name:String,result:H & List<&2,Q.ProjectedRow<S,V>>) -> H & Result<&2,&2,Unit,Record<S>>:
  (owner,rows)=result
  (owner,Done{wrap(name,rows)})
def render(~S:Data,value:Record<S>) -> String:
  match value:
    case EmptyRecord{name,rows}:name ++ "=" ++ Format.list(~Q.ProjectedRow<S,D.ValueEmpty>,~Format.row(~S,~D.ValueEmpty,~Format.value_empty),rows)
    case OptionalFourRecord{name,rows}:name ++ "=" ++ Format.list(~Q.ProjectedRow<S,D.ValueOptionalFour>,~Format.row(~S,~D.ValueOptionalFour,~Format.value_optionalFour),rows)
    case RequiredPairRecord{name,rows}:name ++ "=" ++ Format.list(~Q.ProjectedRow<S,D.ValueRequiredPair>,~Format.row(~S,~D.ValueRequiredPair,~Format.value_requiredPair),rows)
    case FiveAliasRecord{name,rows}:name ++ "=" ++ Format.list(~Q.ProjectedRow<S,D.ValueFiveAlias>,~Format.row(~S,~D.ValueFiveAlias,~Format.value_fiveAlias),rows)
    case MixedFiltersRecord{name,rows}:name ++ "=" ++ Format.list(~Q.ProjectedRow<S,D.ValueMixedFilters>,~Format.row(~S,~D.ValueMixedFilters,~Format.value_mixedFilters),rows)
    case OptionalUnselectedFilterRecord{name,rows}:name ++ "=" ++ Format.list(~Q.ProjectedRow<S,D.ValueOptionalUnselectedFilter>,~Format.row(~S,~D.ValueOptionalUnselectedFilter,~Format.value_optionalUnselectedFilter),rows)
    case UnitRecord{name,rows}:name ++ "=" ++ Format.list(~Q.ProjectedRow<S,Unit>,~Format.row(~S,~Unit,~Format.value_unit),rows)
    case ErrorRecord{message}:message
def render_list(~S:Data,records:List<&2,Record<S>>) -> List<&2,String>:
  match records:
    case []:[]
    case record <> rest:render(~S,record) <> render_list(~S,rest)
def empty_ops(~S:Data,H:Type) -> Type:Reads<H,S,D.ValueEmpty>
def empty_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,empty_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueEmpty,~D.inspect_empty(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def empty_body(~S:Data,~H:Type,~caps:Reads<H,S,D.ValueEmpty>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~D.ValueEmpty,~empty_record(~S),"empty",Q.each_composed(~H,~S,~D.ValueEmpty,~query(~H,~S,~D.ValueEmpty,caps),owner))
def empty(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~empty_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~empty_plan(~S),~empty_body(~S),instance,targets,world)
def optionalFour_ops(~S:Data,H:Type) -> Type:Reads<H,S,D.ValueOptionalFour>
def optionalFour_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,optionalFour_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueOptionalFour,~D.inspect_optionalFour(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def optionalFour_body(~S:Data,~H:Type,~caps:Reads<H,S,D.ValueOptionalFour>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~D.ValueOptionalFour,~optionalFour_record(~S),"optionalFour",Q.each_composed(~H,~S,~D.ValueOptionalFour,~query(~H,~S,~D.ValueOptionalFour,caps),owner))
def optionalFour(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~optionalFour_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~optionalFour_plan(~S),~optionalFour_body(~S),instance,targets,world)
def requiredPair_ops(~S:Data,H:Type) -> Type:Reads<H,S,D.ValueRequiredPair>
def requiredPair_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,requiredPair_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueRequiredPair,~D.inspect_requiredPair(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def requiredPair_body(~S:Data,~H:Type,~caps:Reads<H,S,D.ValueRequiredPair>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~D.ValueRequiredPair,~requiredPair_record(~S),"requiredPair",Q.each_composed(~H,~S,~D.ValueRequiredPair,~query(~H,~S,~D.ValueRequiredPair,caps),owner))
def requiredPair(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~requiredPair_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~requiredPair_plan(~S),~requiredPair_body(~S),instance,targets,world)
def fiveAlias_ops(~S:Data,H:Type) -> Type:Reads<H,S,D.ValueFiveAlias>
def fiveAlias_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,fiveAlias_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueFiveAlias,~D.inspect_fiveAlias(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def fiveAlias_body(~S:Data,~H:Type,~caps:Reads<H,S,D.ValueFiveAlias>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~D.ValueFiveAlias,~fiveAlias_record(~S),"fiveAlias",Q.each_composed(~H,~S,~D.ValueFiveAlias,~query(~H,~S,~D.ValueFiveAlias,caps),owner))
def fiveAlias(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~fiveAlias_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~fiveAlias_plan(~S),~fiveAlias_body(~S),instance,targets,world)
def withWithout_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def withWithout_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,withWithout_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_withWithout(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def withWithout_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"withWithout",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def withWithout(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~withWithout_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~withWithout_plan(~S),~withWithout_body(~S),instance,targets,world)
def multipleWith_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def multipleWith_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,multipleWith_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_multipleWith(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def multipleWith_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"multipleWith",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def multipleWith(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~multipleWith_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~multipleWith_plan(~S),~multipleWith_body(~S),instance,targets,world)
def multipleWithout_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def multipleWithout_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,multipleWithout_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_multipleWithout(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def multipleWithout_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"multipleWithout",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def multipleWithout(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~multipleWithout_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~multipleWithout_plan(~S),~multipleWithout_body(~S),instance,targets,world)
def repeated_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def repeated_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,repeated_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_repeated(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def repeated_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"repeated",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def repeated(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~repeated_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~repeated_plan(~S),~repeated_body(~S),instance,targets,world)
def contradictory_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def contradictory_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,contradictory_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_contradictory(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def contradictory_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"contradictory",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def contradictory(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~contradictory_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~contradictory_plan(~S),~contradictory_body(~S),instance,targets,world)
def addedBoth_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def addedBoth_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,addedBoth_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_addedBoth(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def addedBoth_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"addedBoth",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def addedBoth(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~addedBoth_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~addedBoth_plan(~S),~addedBoth_body(~S),instance,targets,world)
def changedBoth_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def changedBoth_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,changedBoth_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_changedBoth(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def changedBoth_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"changedBoth",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def changedBoth(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~changedBoth_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~changedBoth_plan(~S),~changedBoth_body(~S),instance,targets,world)
def mixedFilters_ops(~S:Data,H:Type) -> Type:Reads<H,S,D.ValueMixedFilters>
def mixedFilters_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,mixedFilters_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueMixedFilters,~D.inspect_mixedFilters(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def mixedFilters_body(~S:Data,~H:Type,~caps:Reads<H,S,D.ValueMixedFilters>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~D.ValueMixedFilters,~mixedFilters_record(~S),"mixedFilters",Q.each_composed(~H,~S,~D.ValueMixedFilters,~query(~H,~S,~D.ValueMixedFilters,caps),owner))
def mixedFilters(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~mixedFilters_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~mixedFilters_plan(~S),~mixedFilters_body(~S),instance,targets,world)
def repeatedAdded_ops(~S:Data,H:Type) -> Type:Reads<H,S,Unit>
def repeatedAdded_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,repeatedAdded_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~Unit,~D.inspect_repeatedAdded(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def repeatedAdded_body(~S:Data,~H:Type,~caps:Reads<H,S,Unit>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~Unit,~unit_record(~S),"repeatedAdded",Q.each_composed(~H,~S,~Unit,~query(~H,~S,~Unit,caps),owner))
def repeatedAdded(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~repeatedAdded_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~repeatedAdded_plan(~S),~repeatedAdded_body(~S),instance,targets,world)
def optionalUnselectedFilter_ops(~S:Data,H:Type) -> Type:Reads<H,S,D.ValueOptionalUnselectedFilter>
def optionalUnselectedFilter_plan(~S:Data) -> I.Plan<S,Families.Store<S>,Owners.Resource(~S),U32,optionalUnselectedFilter_ops(~S)>:
  I.Plan{Reads{Q.grant_composed(~I.Frame<S,Families.Store<S>,Owners.Resource(~S),U32>,~S,~D.ValueOptionalUnselectedFilter,~D.inspect_optionalUnselectedFilter(~S,~Owners.Resource(~S)),~Traversal.inspect_world(~S,~Families.Store<S>,~Owners.Resource(~S),~U32))}}
def optionalUnselectedFilter_body(~S:Data,~H:Type,~caps:Reads<H,S,D.ValueOptionalUnselectedFilter>,_:List<&2,W.Handle<S>>,owner:H) -> H & Result<&2,&2,Unit,Record<S>>:
  captured(~H,~S,~D.ValueOptionalUnselectedFilter,~optionalUnselectedFilter_record(~S),"optionalUnselectedFilter",Q.each_composed(~H,~S,~D.ValueOptionalUnselectedFilter,~query(~H,~S,~D.ValueOptionalUnselectedFilter,caps),owner))
def optionalUnselectedFilter(~S:Data,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
  I.run(~S,~Families.Store<S>,~Owners.Resource(~S),~U32,~optionalUnselectedFilter_ops(~S),~List<&2,W.Handle<S>>,~Unit,~Record<S>,~optionalUnselectedFilter_plan(~S),~optionalUnselectedFilter_body(~S),instance,targets,world)
def run(~S:Data,kind:QueryKind,world:W.World<S,Families.Store<S>,Owners.Resource(~S),U32>,instance:I.Instance<S>,targets:List<&2,W.Handle<S>>) -> I.Observed<S,Families.Store<S>,Owners.Resource(~S),U32,Unit,Record<S>>:
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
