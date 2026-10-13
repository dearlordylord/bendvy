import Base
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

# Fixture instrumentation only. Preload/record writes occur outside Check.run.
type Diagnostic<S:Data> is Data:
  Diagnostic{targets:List<&2,W.Handle<S>>,record:String,before:String,after:String,same:Bool,allowed:Bool,checks:U32,ran:U32}
type Extra is Type:
  Extra{first:Array<U32>,second:Array<U32>}
type Physical<S:Data> is Type:
  Physical{cells:Array<U32>,extra:Extra,diagnostic:Diagnostic<S>}
def fresh(~S:Data) -> Diagnostic<S>:
  Diagnostic{[],"","","",False{},False{},0,0}

type CheckInputs<S:Data> is Data:
  CheckInputs{kind:U32,targets:List<&2,W.Handle<S>>,expected:String}
def fresh_inputs(~S:Data) -> CheckInputs<S>:
  CheckInputs{0,[],""}
def Resource(~S:Data) -> Type:
  Product.Owner<Physical<S>,CheckInputs<S>>
