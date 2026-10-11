import Base
import core/world.bend as W

# Fixture instrumentation only. Preload/record writes occur outside Check.run.
type Diagnostic<S:Data> is Data:
  Diagnostic{targets:List<&2,W.Handle<S>>,record:String,before:String,after:String,same:Bool,allowed:Bool,checks:U32,ran:U32}
type Extra is Type:
  Extra{first:Array<U32>,second:Array<U32>}
type Resource<S:Data> is Type:
  Resource{cells:Array<U32>,extra:Extra,diagnostic:Diagnostic<S>}
def fresh(~S:Data) -> Diagnostic<S>:
  Diagnostic{[],"","","",False{},False{},0,0}
