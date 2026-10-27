import Base
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/ordinary-declaration.bend as C
import ../../src/ecs/decode-data.bend as D

# Draft subjects only. No approval or proof is implied by source well-formedness.
# The actual affine application/owner is an erased logical binder, not a Data
# summary. These statements do not establish the ordinary pending fold itself.
law pending_returns_actual_application:
  for -Actual:Type
  for -Value:Data
  for -Error:Data
  for -project:Actual -> Actual & Gate.Outcome<Value,Error>
  for -actual:Actual
  {Gate.checked(~Actual,~Value,~Error,~project,(actual,True{})) == (actual,Gate.RefusedPending{}) : (Actual & Gate.Outcome<Value,Error>)}

law clear_gate_uses_exact_projection:
  for -Actual:Type
  for -Value:Data
  for -Error:Data
  for -project:Actual -> Actual & Gate.Outcome<Value,Error>
  for -actual:Actual
  {Gate.checked(~Actual,~Value,~Error,~project,(actual,False{})) == project(actual) : (Actual & Gate.Outcome<Value,Error>)}

law plain_retains_actual_owner:
  for -S:Data
  for -P:Type
  for -identity:C.Declaration<S,P>
  for -project:P -> P & D.Raw
  for -owner:P
  {Recipe.export(~S,~P,~identity,~project,Recipe.Plain{},owner) == (Recipe.Plain{},(owner,Recipe.Refused{Recipe.PlainUnserializable{C.key(~S,~P,identity)}})) : (Recipe.Leaf<S,P,identity,project> & (P & Recipe.Field))}

law transient_retains_actual_owner:
  for -S:Data
  for -P:Type
  for -identity:C.Declaration<S,P>
  for -project:P -> P & D.Raw
  for -owner:P
  {Recipe.export(~S,~P,~identity,~project,Recipe.Transient{},owner) == (Recipe.Transient{},(owner,Recipe.Omitted{})) : (Recipe.Leaf<S,P,identity,project> & (P & Recipe.Field))}
