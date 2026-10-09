import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build

# Application parser: one decimal digit, comma, one decimal digit.
# Coordinates are typed fields; arrays remain affine owned sentinels.
type Owner is Type:Owner{x:U32,y:U32,original:D.Raw,words:Array<U32>,flags:Array<Bool>}
type View is Data:View{x:U32,y:U32,raw:D.Raw,original:D.Raw,words:List<&2,U32>,flags:List<&2,Bool>}
type Error is Data:ParseError{raw:D.Raw}
def raw(+x:U32,+y:U32) -> D.Raw:D.Object{[D.Field{"x",D.Number{x}},D.Field{"y",D.Number{y}}]}
def codec() -> D.Codec:D.Struct{[D.NamedCodec{"x",D.Literal{D.Number{7}}},D.NamedCodec{"y",D.Integer{}}]}
def identity(~S:Data) -> Identity.Declaration<S,Owner>:Identity.component(~S,~Owner,"constructed-raw-owner")
def resource_identity(~S:Data) -> Identity.Declaration<S,Owner>:Identity.component(~S,~Owner,"constructed-raw-resource")
def project(owner:Owner) -> Owner & D.Raw:
  match owner:
    case Owner{+x,+y,original,words,flags}:(Owner{x,y,original,words,flags},raw(x,y))
def undo(owner:Owner) -> Input.Input:
  match owner:
    case Owner{_,_,original,words,flags}:Input.Input{original,words,flags}
def built(+x:U32,+y:U32,input:Input.Input) -> Build.Construction<Input.Input,Owner,Error>:
  match input:
    case Input.Input{original,words,flags}:Build.Constructed{Owner{x,y,original,words,flags},undo}
def digits(+a:U32,+b:U32,+canonical:D.Raw,input:Input.Input,valid:Bool) -> Build.Construction<Input.Input,Owner,Error>:
  match valid:
    case True{}:built(U32.sub(a,48),U32.sub(b,48),input)
    case False{}:Build.Invalid{input,ParseError{canonical}}
def digit(+code:U32) -> Bool:Bool.and(U32.is_ge(code,48),U32.is_le(code,57))
def parse(input:Input.Input,+canonical:D.Raw,text:String) -> Build.Construction<Input.Input,Owner,Error>:
  match text:
    case SCon{Chr{+a},SCon{Chr{44},SCon{Chr{+b},SNil{}}}}:digits(a,b,canonical,input,Bool.and(digit(a),digit(b)))
    case _:Build.Invalid{input,ParseError{canonical}}
def build(input:Input.Input,canonical:D.Raw) -> Build.Construction<Input.Input,Owner,Error>:
  match canonical:
    case D.Text{+text}:parse(input,D.Text{text},text)
    case value:Build.Invalid{input,ParseError{value}}
def owned(+x:U32,+y:U32) -> Owner:Owner{x,y,raw(x,y),ANode{ALeaf{81},ALeaf{82}},ANode{ALeaf{False{}},ALeaf{True{}}}}
def flagged(+x:U32,+y:U32,+original:D.Raw,words:Array<U32>,list:List<&2,U32>,value:Array<Bool> & List<&2,Bool>) -> Owner & View:
  match value:
    case (flags,values):(Owner{x,y,original,words,flags},View{x,y,raw(x,y),original,list,values})
def words(+x:U32,+y:U32,+original:D.Raw,flags:Array<Bool>,value:Array<U32> & List<&2,U32>) -> Owner & View:
  match value:
    case (words,list):flagged(x,y,original,words,list,Input.array(~Bool,flags))
def view(owner:Owner) -> Owner & View:
  match owner:
    case Owner{x,y,original,values,flags}:words(x,y,original,flags,Input.array(~U32,values))
