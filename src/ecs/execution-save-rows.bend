import Base
import ./execution-save-plan.bend as Plan
import ./execution-save-traversal.bend as Traverse
import ./execution-save-data.bend as Saved
import ./execution-save-recipe.bend as Recipe
import ./execution-composer-layout.bend as Layout
import ./world.bend as W
import ./entity-key.bend as Key

def prepended(~S:Data,~plan:Plan.Plan,key:Key.Key,fields:List<&2,Saved.Field>,result:Plan.Recipes(~S,plan) & (Layout.columns(~S,Plan.layout(plan)) & (List<&2,Saved.Entity> & Maybe<&2,Recipe.Refusal>))) -> Plan.Recipes(~S,plan) & (Layout.columns(~S,Plan.layout(plan)) & (List<&2,Saved.Entity> & Maybe<&2,Recipe.Refusal>)):
  match result:
    case (recipes,(columns,(rows,error))):(recipes,(columns,(Saved.Entity{key,fields} <> rows,error)))
def projected(~S:Data,~plan:Plan.Plan,key:Key.Key,next:Plan.Recipes(~S,plan) -> Layout.columns(~S,Plan.layout(plan)) -> Plan.Recipes(~S,plan) & (Layout.columns(~S,Plan.layout(plan)) & (List<&2,Saved.Entity> & Maybe<&2,Recipe.Refusal>)),result:Plan.Recipes(~S,plan) & (Layout.columns(~S,Plan.layout(plan)) & Saved.Fields)) -> Plan.Recipes(~S,plan) & (Layout.columns(~S,Plan.layout(plan)) & (List<&2,Saved.Entity> & Maybe<&2,Recipe.Refusal>)):
  match result:
    case (recipes,(columns,Saved.Fields{_,Some{error}})):(recipes,(columns,([],Some{error})))
    case (recipes,(columns,Saved.Fields{fields,None{}})):prepended(~S,~plan,key,fields,next(recipes,columns))
def rows(~S:Data,~plan:Plan.Plan,handles:List<&2,W.Handle<S>>,recipes:Plan.Recipes(~S,plan),columns:Layout.columns(~S,Plan.layout(plan))) -> Plan.Recipes(~S,plan) & (Layout.columns(~S,Plan.layout(plan)) & (List<&2,Saved.Entity> & Maybe<&2,Recipe.Refusal>)):
  match handles:
    case []:(recipes,(columns,([],None{})))
    case W.Handle{_,+key} <> rest:projected(~S,~plan,key,recipes => columns => rows(~S,~plan,rest,recipes,columns),Traverse.components(~S,plan)(recipes,Key.index(key),columns))
