import Base
import ./schema-fragments.bend as SF
import ./schedule-provision.bend as P

# Recursive author metadata contains no payload owners or gameplay authority.
type Tree<S:Data> is Data:
  Empty{}
  Feature{name:String,entries:List<&2,SF.Entry<S>>,dependencies:Tree<S>}
  Sequence{left:Tree<S>,right:Tree<S>}
type Error is Data:
  DuplicateFeature{name:String}
  MissingDependency{name:String}
  SchemaConflict{error:SF.Error}
type Validation is Data:
  Valid{}
  Invalid{error:Error}
type Composition<S:Data,Owners:Type,Output:Type> is Type:
  Built{output:Output}
  Rejected{error:Error,owners:Owners}
def names(~S:Data,tree:Tree<S>) -> List<&2,String>:
  match tree:
    case Empty{}: []
    case Feature{name,_,_}: [name]
    case Sequence{left,right}: List.append(&2,String,names(~S,left),names(~S,right))
def entries(~S:Data,tree:Tree<S>) -> List<&2,SF.Entry<S>>:
  match tree:
    case Empty{}: []
    case Feature{_,entries,_}: entries
    case Sequence{left,right}: List.append(&2,SF.Entry<S>,entries(~S,left),entries(~S,right))
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
def validate(~S:Data,+tree:Tree<S>) -> Validation:
  continue_validation(duplicates(names(~S,tree),[]),_ => continue_validation(dependencies(~S,tree,names(~S,tree)),_ => schema_validation(SF.validate(~S,entries(~S,tree)))))
def compose_checked(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,result:Validation,owners:Owners) -> Composition<S,Owners,Output>:
  match result:
    case Invalid{error}: Rejected{error,owners}
    case Valid{}: Built{build(owners)}
def compose(~S:Data,~Owners:Type,~Output:Type,~build:Owners -> Output,tree:Tree<S>,owners:Owners) -> Composition<S,Owners,Output>:
  compose_checked(~S,~Owners,~Output,~build,validate(~S,tree),owners)

# Typed builder composition threads Context and recursive heterogeneous owners.
# Schedule plans retain authored nested requirements and selected order.
type Pack<Head:Type,Tail:Type> is Type:
  Pack{head:Head,tail:Tail}
type Output<S:Data,Extra:Type> is Type:
  Output{extra:Extra,bootstrap:P.Plan<S>,update:P.Plan<S>}
def combine(~S:Data,~Ctx:Type,~HE:Type,~TE:Type,observed:Ctx & Output<S,TE>,head:Output<S,HE>) -> Ctx & Output<S,Pack<HE,TE>>:
  match observed head:
    case (ctx,Output{te,tb,tu}) Output{he,hb,hu}: (ctx,Output{Pack{he,te},P.Sequence{hb,tb},P.Sequence{hu,tu}})
def build_head_done(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,~tail:Ctx -> TO -> Ctx & Output<S,TE>,owners:TO,observed:Ctx & Output<S,HE>) -> Ctx & Output<S,Pack<HE,TE>>:
  match observed:
    case (ctx,output): combine(~S,~Ctx,~HE,~TE,tail(ctx,owners),output)
def build_head(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,~head:Ctx -> HO -> Ctx & Output<S,HE>,~tail:Ctx -> TO -> Ctx & Output<S,TE>,ctx:Ctx,owners:Pack<HO,TO>) -> Ctx & Output<S,Pack<HE,TE>>:
  match owners:
    case Pack{ho,to}: build_head_done(~S,~Ctx,~HO,~TO,~HE,~TE,~tail,to,head(ctx,ho))
def build_empty(~S:Data,~Ctx:Type,ctx:Ctx,owner:Unit) -> Ctx & Output<S,Unit>:
  (ctx,Output{owner,P.Empty{},P.Empty{}})

# Trusted schema constructors pair each definition with its actual owned builder.
# Gameplay does not receive these raw constructors or callback fields.
type Definition<S:Data> is Data:
  Definition{name:String,entries:List<&2,SF.Entry<S>>,dependencies:Tree<S>}
type Feature<S:Data,Ctx:Type,Owners:Type,Extra:Type> is Type:
  FeatureOwner{definition:Definition<S>,owners:Owners,build:Ctx -> Owners -> Ctx & Output<S,Extra>}
type Recipe<S:Data,Ctx:Type,Owners:Type,Extra:Type> is Type:
  Recipe{selected:Tree<S>,owners:Owners,build:Ctx -> Owners -> Ctx & Output<S,Extra>}
type RecipeResult<S:Data,Ctx:Type,Owners:Type,Extra:Type> is Type:
  Completed{ctx:Ctx,output:Output<S,Extra>}
  Refused{error:Error,ctx:Ctx,recipe:Recipe<S,Ctx,Owners,Extra>}
def definition_tree(~S:Data,definition:Definition<S>) -> Tree<S>:
  match definition:
    case Definition{name,entries,dependencies}: Feature{name,entries,dependencies}
def callbacks_done(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,tail:Ctx -> TO -> Ctx & Output<S,TE>,owners:TO,observed:Ctx & Output<S,HE>) -> Ctx & Output<S,Pack<HE,TE>>:
  match observed:
    case (ctx,output): combine(~S,~Ctx,~HE,~TE,tail(ctx,owners),output)
def callbacks(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,head:Ctx -> HO -> Ctx & Output<S,HE>,tail:Ctx -> TO -> Ctx & Output<S,TE>,ctx:Ctx,owners:Pack<HO,TO>) -> Ctx & Output<S,Pack<HE,TE>>:
  match owners:
    case Pack{ho,to}: callbacks_done(~S,~Ctx,~HO,~TO,~HE,~TE,tail,to,head(ctx,ho))
def prepend(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,head:Feature<S,Ctx,HO,HE>,tail:Recipe<S,Ctx,TO,TE>) -> Recipe<S,Ctx,Pack<HO,TO>,Pack<HE,TE>>:
  match head tail:
    case FeatureOwner{definition,ho,head} Recipe{tree,to,tail}: Recipe{Sequence{definition_tree(~S,definition),tree},Pack{ho,to},ctx => owners => callbacks(~S,~Ctx,~HO,~TO,~HE,~TE,head,tail,ctx,owners)}
def recipe_empty(~S:Data,~Ctx:Type) -> Recipe<S,Ctx,Unit,Unit>:
  Recipe{Empty{},Unit{},ctx => owners => build_empty(~S,~Ctx,ctx,owners)}
def recipe_completed(~S:Data,~Ctx:Type,~Owners:Type,~Extra:Type,observed:Ctx & Output<S,Extra>) -> RecipeResult<S,Ctx,Owners,Extra>:
  match observed:
    case (ctx,output): Completed{ctx,output}
def recipe_checked(~S:Data,~Ctx:Type,~Owners:Type,~Extra:Type,result:Validation,ctx:Ctx,recipe:Recipe<S,Ctx,Owners,Extra>) -> RecipeResult<S,Ctx,Owners,Extra>:
  match result recipe:
    case Invalid{error} recipe: Refused{error,ctx,recipe}
    case Valid{} Recipe{_,owners,build}: recipe_completed(~S,~Ctx,~Owners,~Extra,build(ctx,owners))
def run_recipe(~S:Data,~Ctx:Type,~Owners:Type,~Extra:Type,ctx:Ctx,recipe:Recipe<S,Ctx,Owners,Extra>) -> RecipeResult<S,Ctx,Owners,Extra>:
  match recipe:
    case Recipe{+tree,owners,build}: recipe_checked(~S,~Ctx,~Owners,~Extra,validate(~S,tree),ctx,Recipe{tree,owners,build})
