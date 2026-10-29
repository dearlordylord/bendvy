import Base
import ./schema-fragments.bend as SF
import ./execution-composer-layout.bend as Layout
import ./execution-composer-schema.bend as Schema
import ./execution-parallel-scope-registry.bend as Registry
import ./dependency-composer-program.bend as Scoped
import ./dependency-composer.bend as Compose
import ./dependency-plan.bend as Plan
import ./owner-product.bend as Product

# Recursive author metadata contains no payload owners or gameplay authority.
# Detached feature selection metadata with named dependencies and schema
# entries. A dependency reference does not automatically select/build it;
# selected features must include required names. Owns no live world or payload.
type Tree<S:Data> is Data:
  Empty{}
  Feature{name:String,entries:List<&2,SF.Entry<S>>,dependencies:Tree<S>}
  Sequence{left:Tree<S>,right:Tree<S>}
# Feature composition refusal: duplicate selected feature, absent dependency
# name or schema descriptor conflict. No builder has run on validation refusal.
type Error is Data:
  DuplicateFeature{name:String}
  MissingDependency{name:String}
  SchemaConflict{error:SF.Error}
# Pure feature validation result; owns no application payload or context.
type Validation is Data:
  Valid{}
  Invalid{error:Error}
# Validated composition outcome. Built owns build output; Rejected returns
# the original affine Owners with the validation error for recovery or retry.
type Composition<S:Data,Owners:Type,Output:Type> is Type:
  Built{output:Output}
  Rejected{error:Error,owners:Owners}
# List selected feature names in authored sequence order, without recursively
# treating dependency references as additional selected features.
def names(~S:Data,tree:Tree<S>) -> List<&2,String>:
  match tree:
    case Empty{}: []
    case Feature{name,_,_}: [name]
    case Sequence{left,right}: List.append(&2,String,names(~S,left),names(~S,right))
# List entries from selected features in authored sequence order. Dependency
# metadata does not implicitly add those features or their schema entries.
def entries(~S:Data,tree:Tree<S>) -> List<&2,SF.Entry<S>>:
  match tree:
    case Empty{}: []
    case Feature{_,entries,_}: entries
    case Sequence{left,right}: List.append(&2,SF.Entry<S>,entries(~S,left),entries(~S,right))
# Collect own and referenced dependency entries recursively for visibility
# description. This does not select/build dependencies or validate composition.
def visibility(~S:Data,tree:Tree<S>) -> List<&2,SF.Entry<S>>:
  match tree:
    case Empty{}: []
    case Feature{_,own,dependencies}: List.append(&2,SF.Entry<S>,own,visibility(~S,dependencies))
    case Sequence{left,right}: List.append(&2,SF.Entry<S>,visibility(~S,left),visibility(~S,right))
def contains(items:List<&2,String>,+name:String) -> Bool:
  match items:
    case []: False{}
    case head <> rest: Bool.or(String.eq(head,name),contains(rest,name))
def repeated(present:Bool,name:String,next:Unit -> Validation) -> Validation:
  match present:
    case True{}: Invalid{DuplicateFeature{name}}
    case False{}: next(Unit{})
def duplicates(items:List<&2,String>,+seen:List<&2,String>) -> Validation:
  match items:
    case []: Valid{}
    case +name <> rest: repeated(contains(seen,name),name,_ => duplicates(rest,name <> seen))
def missing(present:Bool,name:String,next:Unit -> Validation) -> Validation:
  match present:
    case False{}: Invalid{MissingDependency{name}}
    case True{}: next(Unit{})
def required(items:List<&2,String>,+selected:List<&2,String>) -> Validation:
  match items:
    case []: Valid{}
    case +name <> rest: missing(contains(selected,name),name,_ => required(rest,selected))
def continue_validation(result:Validation,next:Unit -> Validation) -> Validation:
  match result:
    case Invalid{error}: Invalid{error}
    case Valid{}: next(Unit{})
def dependencies(~S:Data,tree:Tree<S>,+selected:List<&2,String>) -> Validation:
  match tree:
    case Empty{}: Valid{}
    case Feature{_,_,deps}: required(names(~S,deps),selected)
    case Sequence{left,right}: continue_validation(dependencies(~S,left,selected),_ => dependencies(~S,right,selected))
def schema_validation(result:SF.Validation) -> Validation:
  match result:
    case SF.Valid{}: Valid{}
    case SF.Invalid{error}: Invalid{SchemaConflict{error}}
# Check selected feature names, required dependency names and schema entries
# before any owned builder runs. Dependencies are name requirements, not an
# automatic dependency resolver or topological reorder of authored selection.
def validate(~S:Data,+tree:Tree<S>) -> Validation:
  continue_validation(duplicates(names(~S,tree),[]),_ => continue_validation(dependencies(~S,tree,names(~S,tree)),_ => schema_validation(SF.validate(~S,entries(~S,tree)))))
def compose_checked(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,result:Validation,owners:Owners) -> Composition<S,Owners,Output>:
  match result:
    case Invalid{error}: Rejected{error,owners}
    case Valid{}: Built{build(owners)}
# Validate the metadata tree before passing affine Owners to the trusted
# build callback. Invalid returns Rejected with original owners; valid invokes
# build once. Does not make arbitrary builder effects transactional.
# Contract and accepted consumers: docs/parity/features.md.
def compose(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,tree:Tree<S>,owners:Owners) -> Composition<S,Owners,Output>:
  compose_checked(~S,~Owners,~Output,~build,validate(~S,tree),owners)

# Heterogeneous affine head/tail feature owners or outputs, preserving order.
# Nest this product for additional features; payloads need not be Data.
type Pack<Head:Type,Tail:Type> is Type:
  Pack{head:Head,tail:Tail}

type Definition<S:Data> is Data:
  Definition{name:String,entries:List<&2,SF.Entry<S>>,dependencies:Tree<S>}
def definition_tree(~S:Data,definition:Definition<S>) -> Tree<S>:
  match definition:
    case Definition{name,entries,dependencies}:Feature{name,entries,dependencies}

# Entries and node IDs come from the same accepted declarations that execute.
# Scope paths retain feature boundaries before dependency edges are flattened.
type Assembly<-S:Data,-Nodes:Type> is Type:
  Assembly{selected:Tree<S>,facts:Registry.GeneralizedFacts<Nodes>,scope:Scoped.Scope}
type AssemblyError is Data:
  InvalidFeatures{error:Error}
  InvalidComposition{error:Compose.Error}
type Lowered<-Nodes:Type> is Type:
  Lowered{facts:Registry.GeneralizedFacts<Nodes>,edges:List<&2,Plan.Edge>,invalid:Maybe<&2,AssemblyError>}
def needs_key(nodes:List<&2,Plan.Node<String>>,+key:String) -> Bool:
  match nodes:
    case []:False{}
    case Plan.Node{_,needs} <> rest:Bool.or(contains(needs,key),needs_key(rest,key))
def selected_entry(~S:Data,selected:Bool,entry:SF.Entry<S>,rest:List<&2,SF.Entry<S>>) -> List<&2,SF.Entry<S>>:
  match selected:
    case True{}:entry <> rest
    case False{}:rest
def own_entries(~S:Data,entries:List<&2,SF.Entry<S>>,+nodes:List<&2,Plan.Node<String>>) -> List<&2,SF.Entry<S>>:
  match entries:
    case []:[]
    case +entry <> rest:selected_entry(~S,needs_key(nodes,Compose.entry_key(~S,entry)),entry,own_entries(~S,rest,nodes))
def from_facts(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,-Nodes:Type,name:String,dependencies:Tree<S>,facts:Registry.GeneralizedFacts<Nodes>) -> Assembly<S,Nodes>:
  match facts:
    case Registry.GeneralizedFacts{nodes,+planNodes,entries,deferred}:Assembly{Feature{name,own_entries(~S,Schema.inventory(~S,~components,~resources),planNodes),dependencies},Registry.GeneralizedFacts{nodes,planNodes,entries,deferred},Scoped.Scope{Scoped.ids(planNodes),[]}}
def scope_members(scope:Scoped.Scope) -> List<&2,U32>:
  match scope:
    case Scoped.Scope{members,_}:members
def pair(~S:Data,-Left:Type,-Right:Type,left:Assembly<S,Left>,right:Assembly<S,Right>) -> Assembly<S,Product.Owner<Left,Right>>:
  match left right:
    case Assembly{left,lf,+ls} Assembly{right,rf,+rs}:Assembly{Sequence{left,right},Registry.generalized_pair_facts(Left,Right,lf,rf),Scoped.Scope{List.append(&2,U32,scope_members(ls),scope_members(rs)),[ls,rs]}}
def feature_error(validation:Validation) -> Maybe<&2,AssemblyError>:
  match validation:
    case Valid{}:None{}
    case Invalid{error}:Some{InvalidFeatures{error}}
def composition_error(error:Maybe<&2,Compose.Error>) -> Maybe<&2,AssemblyError>:
  match error:
    case None{}:None{}
    case Some{error}:Some{InvalidComposition{error}}
def first_error(first:Maybe<&2,AssemblyError>,second:Maybe<&2,AssemblyError>) -> Maybe<&2,AssemblyError>:
  match first:
    case Some{error}:Some{error}
    case None{}:second
def nesting_error(error:Maybe<&2,Scoped.NestError>) -> Maybe<&2,Compose.Error>:
  match error:
    case None{}:None{}
    case Some{error}:Some{Compose.Nesting{error}}
def lower_nested(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,-Nodes:Type,selected:Tree<S>,facts:Registry.GeneralizedFacts<Nodes>,nested:Scoped.Nesting) -> Lowered<Nodes>:
  match facts nested:
    case Registry.GeneralizedFacts{nodes,+planNodes,entries,deferred} Scoped.Nesting{edges,invalid}:Lowered{Registry.GeneralizedFacts{nodes,planNodes,entries,deferred},edges,first_error(feature_error(validate(~S,selected)),composition_error(Compose.first_error(nesting_error(invalid),Compose.first_error(Compose.schema_error(Schema.validate(~S,~components,~resources)),Compose.schedule_error(Compose.missing(~S,planNodes,Schema.inventory(~S,~components,~resources)))))))}
def lower(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,-Nodes:Type,groups:List<&2,Scoped.Nested>,assembly:Assembly<S,Nodes>) -> Lowered<Nodes>:
  match assembly:
    case Assembly{selected,facts,scope}:lower_nested(~S,~components,~resources,Nodes,selected,facts,Scoped.nested(groups,scope))

type Application<-Root:Type,-Provisions:Type> is Type:
  Application{root:Root,provisions:Provisions,invalid:Maybe<&2,AssemblyError>}
type Report<Out:Data> is Data:
  Executed{report:Out}
  Refused{error:AssemblyError}
def returned(-Root:Type,-Provisions:Type,-Out:Data,provisions:Provisions,result:Root & Out) -> Application<Root,Provisions> & Report<Out>:
  match result:
    case (root,report):(Application{root,provisions,None{}},Executed{report})
def run(-Root:Type,-Provisions:Type,-Out:Data,invoke:Root -> IO(Root & Out),application:Application<Root,Provisions>) -> IO(Application<Root,Provisions> & Report<Out>):
  match application:
    case Application{root,provisions,Some{+error}}:IO.pure(Application<Root,Provisions> & Report<Out>,(Application{root,provisions,Some{error}},Refused{error}))
    case Application{root,provisions,None{}}:IO.bind(Root & Out,Application<Root,Provisions> & Report<Out>,invoke(root),value => IO.pure(Application<Root,Provisions> & Report<Out>,returned(Root,Provisions,Out,provisions,value)))
