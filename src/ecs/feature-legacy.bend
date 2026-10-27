import Base
# Historical schedule builders share metadata identities with public Feature.
import ./feature.bend as F
import ./schedule-provision.bend as P

# Owned extra feature result plus bootstrap/update operational schedule plans.
# These plans describe later execution; constructing Output runs no schedule.
type Output<S:Data,Extra:Type> is Type:
  Output{extra:Extra,bootstrap:P.Plan<S>,update:P.Plan<S>}
def combine(~S:Data,~Ctx:Type,~HE:Type,~TE:Type,observed:Ctx & Output<S,TE>,head:Output<S,HE>) -> Ctx & Output<S,F.Pack<HE,TE>>:
  match observed head:
    case (ctx,Output{te,tb,tu}) Output{he,hb,hu}: (ctx,Output{F.Pack{he,te},P.Sequence{hb,tb},P.Sequence{hu,tu}})
def build_head_done(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,~tail:Ctx -> TO -> Ctx & Output<S,TE>,owners:TO,observed:Ctx & Output<S,HE>) -> Ctx & Output<S,F.Pack<HE,TE>>:
  match observed:
    case (ctx,output): combine(~S,~Ctx,~HE,~TE,tail(ctx,owners),output)
def build_head(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,~head:Ctx -> HO -> Ctx & Output<S,HE>,~tail:Ctx -> TO -> Ctx & Output<S,TE>,ctx:Ctx,owners:F.Pack<HO,TO>) -> Ctx & Output<S,F.Pack<HE,TE>>:
  match owners:
    case F.Pack{ho,to}: build_head_done(~S,~Ctx,~HO,~TO,~HE,~TE,~tail,to,head(ctx,ho))
def build_empty(~S:Data,~Ctx:Type,ctx:Ctx,owner:Unit) -> Ctx & Output<S,Unit>:
  (ctx,Output{owner,P.Empty{},P.Empty{}})

# Trusted schema constructors pair each definition with its actual owned builder.
# Gameplay does not receive these raw constructors or callback fields.
# Trusted static feature definition: name, own schema entries and dependency
# references. It contains no live feature owners or gameplay authority.
# Owned feature definition and trusted builder. build consumes/returns its
# context and consumes Owners to produce Extra plus plans; raw callbacks remain
# trusted setup rather than constrained system-body capabilities.
type Feature<S:Data,Ctx:Type,Owners:Type,Extra:Type> is Type:
  FeatureOwner{definition:F.Definition<S>,owners:Owners,build:Ctx -> Owners -> Ctx & Output<S,Extra>}
# Selected feature metadata with actual heterogeneous owners and builder.
# Thread affinely into run_recipe; metadata validation never copies owners.
type Recipe<S:Data,Ctx:Type,Owners:Type,Extra:Type> is Type:
  Recipe{selected:F.Tree<S>,owners:Owners,build:Ctx -> Owners -> Ctx & Output<S,Extra>}
# Completed returns context and built output; Refused returns context and
# the entire original recipe on metadata validation failure. No builder runs
# in Refused, so its owners can be retried or disposed by the caller.
type RecipeResult<S:Data,Ctx:Type,Owners:Type,Extra:Type> is Type:
  Completed{ctx:Ctx,output:Output<S,Extra>}
  Refused{error:F.Error,ctx:Ctx,recipe:Recipe<S,Ctx,Owners,Extra>}
def callbacks_done(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,tail:Ctx -> TO -> Ctx & Output<S,TE>,owners:TO,observed:Ctx & Output<S,HE>) -> Ctx & Output<S,F.Pack<HE,TE>>:
  match observed:
    case (ctx,output): combine(~S,~Ctx,~HE,~TE,tail(ctx,owners),output)
def callbacks(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,head:Ctx -> HO -> Ctx & Output<S,HE>,tail:Ctx -> TO -> Ctx & Output<S,TE>,ctx:Ctx,owners:F.Pack<HO,TO>) -> Ctx & Output<S,F.Pack<HE,TE>>:
  match owners:
    case F.Pack{ho,to}: callbacks_done(~S,~Ctx,~HO,~TO,~HE,~TE,tail,to,head(ctx,ho))
# Prepend an owned feature to a recipe, retaining head-before-tail build
# and bootstrap/update plan order. Does not validate, invoke builders or
# automatically add dependencies; run_recipe validates the completed selection.
def prepend(~S:Data,~Ctx:Type,~HO:Type,~TO:Type,~HE:Type,~TE:Type,head:Feature<S,Ctx,HO,HE>,tail:Recipe<S,Ctx,TO,TE>) -> Recipe<S,Ctx,F.Pack<HO,TO>,F.Pack<HE,TE>>:
  match head tail:
    case FeatureOwner{definition,ho,head} Recipe{tree,to,tail}: Recipe{F.Sequence{F.definition_tree(~S,definition),tree},F.Pack{ho,to},ctx => owners => callbacks(~S,~Ctx,~HO,~TO,~HE,~TE,head,tail,ctx,owners)}
# Create the empty recipe with Unit owners and empty schedule plans.
# No context is consumed until the resulting builder is executed.
def recipe_empty(~S:Data,~Ctx:Type) -> Recipe<S,Ctx,Unit,Unit>:
  Recipe{F.Empty{},Unit{},ctx => owners => build_empty(~S,~Ctx,ctx,owners)}
def recipe_completed(~S:Data,~Ctx:Type,~Owners:Type,~Extra:Type,observed:Ctx & Output<S,Extra>) -> RecipeResult<S,Ctx,Owners,Extra>:
  match observed:
    case (ctx,output): Completed{ctx,output}
def recipe_checked(~S:Data,~Ctx:Type,~Owners:Type,~Extra:Type,result:F.Validation,ctx:Ctx,recipe:Recipe<S,Ctx,Owners,Extra>) -> RecipeResult<S,Ctx,Owners,Extra>:
  match result recipe:
    case F.Invalid{error} recipe: Refused{error,ctx,recipe}
    case F.Valid{} Recipe{_,owners,build}: recipe_completed(~S,~Ctx,~Owners,~Extra,build(ctx,owners))
# Validate the selected tree before executing its trusted owned builder.
# Refusal returns context and original recipe; success returns context plus
# built extras/plans. Authored order is preserved; no automatic rollback of
# arbitrary callback effects or host IO is provided.
def run_recipe(~S:Data,~Ctx:Type,~Owners:Type,~Extra:Type,ctx:Ctx,recipe:Recipe<S,Ctx,Owners,Extra>) -> RecipeResult<S,Ctx,Owners,Extra>:
  match recipe:
    case Recipe{+tree,owners,build}: recipe_checked(~S,~Ctx,~Owners,~Extra,F.validate(~S,tree),ctx,Recipe{tree,owners,build})
