import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-validated-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/resource.bend as ExistingResource

type First is Data:First{}
type Second is Data:Second{}
type Input is Type:Input{raw:D.Raw,words:Array<U32>,flags:Array<Bool>}
type Owner is Type:Owner{raw:D.Raw,original:D.Raw,words:Array<U32>,flags:Array<Bool>}
type View is Data:View{raw:D.Raw,original:D.Raw,words:List<&2,U32>,flags:List<&2,Bool>}
type InputView is Data:InputView{raw:D.Raw,words:List<&2,U32>,flags:List<&2,Bool>}
def input(raw:D.Raw) -> Input:Input{raw,ANode{ALeaf{111},ALeaf{222}},ANode{ALeaf{True{}},ALeaf{False{}}}}
def incoming(value:Input) -> Input & D.Raw:
  match value:
    case Input{+raw,words,flags}:(Input{raw,words,flags},raw)
def project(value:Owner) -> Owner & D.Raw:
  match value:
    case Owner{+raw,original,words,flags}:(Owner{raw,original,words,flags},raw)
def undo(value:Owner) -> Input:
  match value:
    case Owner{_,original,words,flags}:Input{original,words,flags}
def build(value:Input,canonical:D.Raw) -> Build.Construction<Input,Owner,D.Error>:
  match value:
    case Input{original,words,flags}:Build.Constructed{Owner{canonical,original,words,flags},undo}
def identity(~S:Data) -> Identity.Declaration<S,Owner>:Identity.component(~S,~Owner,"Value")
def resource_identity(~S:Data) -> Identity.Declaration<S,Owner>:Identity.component(~S,~Owner,"Resource")
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input,Build.Construction<Input,Owner,D.Error>>,value:Input,ctx:H) -> H & Build.Construction<Input,Owner,D.Error>:
  Cap.owned_request(~H,~Input,~Build.Construction<Input,Owner,D.Error>,~cap,ctx,value)
def joined(~V:Data,left:Array<V> & List<&2,V>,right:Array<V> & List<&2,V>) -> Array<V> & List<&2,V>:
  match left right:
    case (left,a),(right,b):(ANode{left,right},List.append(&2,V,a,b))
def array(~V:Data,owner:Array<V>) -> Array<V> & List<&2,V>:
  match owner:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:joined(~V,array(~V,left),array(~V,right))
def flagged(+raw:D.Raw,+original:D.Raw,words:Array<U32>,list:List<&2,U32>,value:Array<Bool> & List<&2,Bool>) -> Owner & View:
  match value:
    case (flags,values):(Owner{raw,original,words,flags},View{raw,original,list,values})
def words(+raw:D.Raw,+original:D.Raw,flags:Array<Bool>,value:Array<U32> & List<&2,U32>) -> Owner & View:
  match value:
    case (words,list):flagged(raw,original,words,list,array(~Bool,flags))
def view(value:Owner) -> Owner & View:
  match value:
    case Owner{raw,original,values,flags}:words(raw,original,flags,array(~U32,values))
def input_flagged(+raw:D.Raw,words:Array<U32>,list:List<&2,U32>,value:Array<Bool> & List<&2,Bool>) -> Input & InputView:
  match value:
    case (flags,values):(Input{raw,words,flags},InputView{raw,list,values})
def input_words(+raw:D.Raw,flags:Array<Bool>,value:Array<U32> & List<&2,U32>) -> Input & InputView:
  match value:
    case (words,list):input_flagged(raw,words,list,array(~Bool,flags))
def input_view(value:Input) -> Input & InputView:
  match value:
    case Input{raw,words,flags}:input_words(raw,flags,array(~U32,words))
type ConstructedView is Data:Constructed{owner:View,recovered:InputView} Rejected{input:InputView,error:D.Error}
def rejected(error:D.Error,value:Input & InputView) -> ConstructedView:
  match value:
    case (_,view):Rejected{view,error}
def restored(owner:View,value:Input & InputView) -> ConstructedView:
  match value:
    case (_,input):Constructed{owner,input}
def constructed(reverse:Owner -> Input,value:Owner & View) -> ConstructedView:
  match value:
    case (owner,view):restored(view,input_view(reverse(owner)))
def observe(result:Build.Construction<Input,Owner,D.Error>) -> ConstructedView:
  match result:
    case Build.Invalid{raw,error}:rejected(error,input_view(raw))
    case Build.Constructed{cooked,reverse}:constructed(reverse,view(cooked))
def invoked(~S:Data,result:Constructor.Factory<S,Input,Owner,identity(~S),project,incoming,build> & Build.Construction<Input,Owner,D.Error>) -> ConstructedView:
  match result:
    case (_,result):observe(result)
def construct(~S:Data,codec:D.Codec,raw:D.Raw) -> ConstructedView:
  invoked(~S,Constructor.invoke(~S,~Input,~Owner,~identity(~S),~project,~incoming,~build,~Input,~Build.Construction<Input,Owner,D.Error>,~(H => cap => input => ctx => body(~H,~cap,input,ctx)),Constructor.factory(~S,~Input,~Owner,~identity(~S),~project,~incoming,~build,Decl.constructed(~S,~Owner,~identity(~S),~project,codec)),input(raw)))


def owned(+raw:D.Raw,first:U32,second:U32) -> Owner:Owner{raw,raw,ANode{ALeaf{first},ALeaf{second}},ANode{ALeaf{False{}},ALeaf{True{}}}}
