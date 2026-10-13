import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import ./format.bend as Format

def constructor(~S:Data,schema:String,label:String,codec:D.Codec,raw:D.Raw) -> String:
  Format.constructed_entry(schema,label,Input.construct(~S,codec,raw))

def resource(~S:Data,~codec:D.Codec,schema:String,label:String,raw:D.Raw,fail:Bool) -> String:
  Format.resource_entry(schema,label,Input.resource(~S,~codec,raw,fail))

def constructors(~S:Data,+schema:String) -> List<&2,String>:
  [
    constructor(~S,schema,"finite-number-u32",D.FiniteNumber{},D.Number{7}),
    constructor(~S,schema,"finite-number-signed",D.FiniteNumber{},D.SignedInteger{False{},7n}),
    constructor(~S,schema,"finite-f32",D.FiniteNumber{},D.Float{2.5}),
    constructor(~S,schema,"finite-f32-infinity",D.FiniteNumber{},D.Float{F32.div(1.0,0.0)}),
    constructor(~S,schema,"finite-binary64",D.FiniteNumber{},D.Binary64{1072693248,0}),
    constructor(~S,schema,"finite-binary64-infinity",D.FiniteNumber{},D.Binary64{2146435072,0}),
    constructor(~S,schema,"boolean-true",D.BoolValue{},D.Boolean{True{}}),
    constructor(~S,schema,"boolean-wrong-kind",D.BoolValue{},D.Float{1.0}),
    constructor(~S,schema,"literal-values-number-float",D.LiteralValues{[D.Number{1},D.Text{"alternate"}]},D.Float{1.0}),
    constructor(~S,schema,"literal-values-mismatch",D.LiteralValues{[D.Number{1},D.Text{"alternate"}]},D.Number{2}),
    constructor(~S,schema,"literal-rendered-text-utf16",D.LiteralRendered{[D.Text{"alpha"}],"expected alpha"},D.Utf16Text{[97,108,112,104,97]}),
    constructor(~S,schema,"literal-rendered-custom-error",D.LiteralRendered{[D.Text{"alpha"}],"expected alpha"},D.Utf16Text{[98,101,116,97]}),
    constructor(~S,schema,"utf16-string-lone-surrogate",D.StringValue{},D.Utf16Text{[65,55296]}),
    constructor(~S,schema,"utf16-string-out-of-range",D.StringValue{},D.Utf16Text{[65536]})
  ]

def resources(~S:Data,+schema:String) -> List<&2,String>:
  [
    resource(~S,~D.FiniteNumber{},schema,"resource-f32-accepted",D.Float{2.5},False{}),
    resource(~S,~D.FiniteNumber{},schema,"resource-binary64-accepted",D.Binary64{1072693248,0},False{}),
    resource(~S,~D.BoolValue{},schema,"resource-boolean-accepted",D.Boolean{True{}},False{}),
    resource(~S,~D.LiteralRendered{[D.Text{"alpha"}],"expected alpha"},schema,"resource-literal-rendered-refused",D.Utf16Text{[98,101,116,97]},False{}),
    resource(~S,~D.StringValue{},schema,"resource-utf16-refused",D.Utf16Text{[65536]},False{}),
    resource(~S,~D.FiniteNumber{},schema,"resource-f32-aborted",D.Float{2.5},True{})
  ]

def schema_rows(~S:Data,+schema:String) -> List<&2,String>:
  List.append(&2,String,constructors(~S,schema),resources(~S,schema))

def entries() -> List<&2,String>:
  List.append(&2,String,schema_rows(~Input.First,"First"),schema_rows(~Input.Second,"Second"))
