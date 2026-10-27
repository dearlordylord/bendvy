import Base
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/world.bend as W

# Unapproved, unproved drafts. These actual Type-owner equations describe exact
# refusal branches, not complete save execution or correctness of projectors.
law world_pending_returns_actual_schema_and_world:
  for -S:Data
  for -cp:Plan.Plan
  for -rp:Plan.Plan
  for -E:Data
  for -schema:Plan.Schema<S,cp,rp>
  for -world:W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E>
  {Save.ready(~S,~cp,~rp,~E,schema,(world,False{})) == (schema,(world,Gate.RefusedPending{})) : (Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>))}

law schema_refusal_returns_actual_schema_and_world:
  for -S:Data
  for -cp:Plan.Plan
  for -rp:Plan.Plan
  for -E:Data
  for -schema:Plan.Schema<S,cp,rp>
  for -world:W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E>
  for -error:Recipe.Refusal
  {Save.eligible(~S,~cp,~rp,~E,schema,world,Some{error}) == (schema,(world,Gate.Refused{error})) : (Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>))}
