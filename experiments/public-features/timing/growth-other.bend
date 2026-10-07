import Base
import ../runtime-other.bend as A
import ../runtime-context-other.bend as X
import ../runtime-combat-other.bend as Combat
import ../runtime-core-other.bend as Core
import ../combat-feature.bend as C
import ../core-feature.bend as K
import ../../../src/ecs/feature.bend as F
import ../../../src/ecs/world.bend as W
# Each grow consumes the original two-cell owner and independent padding.
def grow(owner:Array<U32>,padding:Array<U32>) -> Array<U32>:
  ANode{owner,padding}
def owners() -> F.Pack<C.Owner,F.Pack<K.Owner,F.Pack<Unit,Unit>>>:
  F.Pack{C.Owner{grow(ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{33},ALeaf{34}}),grow(ANode{ALeaf{41},ALeaf{42}},ANode{ALeaf{43},ALeaf{44}}),[grow(ANode{ALeaf{51},ALeaf{52}},ANode{ALeaf{53},ALeaf{54}})]},F.Pack{K.Owner{grow(ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{13},ALeaf{14}}),K.Tag{}},F.Pack{Unit{},Unit{}}}}
def recipe(head:F.Definition<X.Schema>,tail:F.Definition<X.Schema>,owners:F.Pack<C.Owner,F.Pack<K.Owner,F.Pack<Unit,Unit>>>) -> F.Recipe<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,F.Pack<C.Owner,F.Pack<K.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<A.EmptyExtra,Unit>>>>:
  match owners:
    case F.Pack{co,F.Pack{ko,F.Pack{Unit{},Unit{}}}}: F.prepend(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~C.Owner,~F.Pack<K.Owner,F.Pack<Unit,Unit>>,~Combat.Built,~F.Pack<Core.Built,F.Pack<A.EmptyExtra,Unit>>,Combat.provided(head,co),F.prepend(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~K.Owner,~F.Pack<Unit,Unit>,~Core.Built,~F.Pack<A.EmptyExtra,Unit>,Core.provided(tail,ko),F.prepend(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~Unit,~Unit,~A.EmptyExtra,~Unit,A.empty_feature(),F.recipe_empty(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>))))
def created(head:F.Definition<X.Schema>,tail:F.Definition<X.Schema>,owners:F.Pack<C.Owner,F.Pack<K.Owner,F.Pack<Unit,Unit>>>,creation:W.Creation<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  match creation:
    case W.Created{factory,world}: A.result(F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<C.Owner,F.Pack<K.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<A.EmptyExtra,Unit>>>,world,recipe(head,tail,owners)))
    case W.CreateRejected{factory,resource}: "UNEXPECTED_CREATION_REFUSAL"
def run(head:F.Definition<X.Schema>,tail:F.Definition<X.Schema>) -> String:
  created(head,tail,owners(),W.create(~X.Schema,~X.Declarations,~X.Trace,~U32,~X.empty_store,W.factory(),X.resource()))
