import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-decode/adoption-v1/admission.bend as Gate
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity

# S is fixed before opaque H. Payload and result may own arbitrary Type values.
type Input<S:Data,P:Type> is Type:
  Input{owner:P}
type Output<S:Data,P:Type,O:Type> is Type:
  Admitted{value:O,canonical:D.Raw}
  ValidationRefused{owner:P,error:D.Error}

def split(~S:Data,~Ctx:Type,~P:Type,~O:Type,result:Gate.Returned<Ctx,P,O>) -> Ctx & Output<S,P,O>:
  match result:
    case Gate.Admitted{ctx,value,canonical}: (ctx,Admitted{value,canonical})
    case Gate.ValidationRefused{ctx,owner,error}: (ctx,ValidationRefused{owner,error})

# Trusted schema provisioning only. Ctx can be a transactional capability frame;
# no callback parameter is imposed on the gameplay body and no owner is copied.
def request(~S:Data,~Ctx:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:Ctx -> P -> D.Raw -> Ctx & O,~declaration:Decl.Constructed<S,P,identity,project>,ctx:Ctx,input:Input<S,P>) -> Ctx & Output<S,P,O>:
  match input:
    case Input{owner}: split(~S,~Ctx,~P,~O,Gate.request(~S,~Ctx,~P,~O,~identity,~project,~admit,declaration,ctx,owner))

def grant(~S:Data,~Ctx:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:Ctx -> P -> D.Raw -> Ctx & O,~declaration:Decl.Constructed<S,P,identity,project>) -> Cap.OwnedRequest<Ctx,Input<S,P>,Output<S,P,O>>:
  Cap.OwnedRequest{ctx => input => request(~S,~Ctx,~P,~O,~identity,~project,~admit,~declaration,ctx,input)}

# This consumer receives the existing ordinary owned capability, never World.
def gameplay(~S:Data,~P:Type,~O:Type,-H:Type,cap:Cap.OwnedRequest<H,Input<S,P>,Output<S,P,O>>,input:Input<S,P>,ctx:H) -> H & Output<S,P,O>:
  match cap:
    case Cap.OwnedRequest{run}: run(ctx,input)

# Runtime-retained descriptor, as ordinary schema assembly requires. It is Data
# and is restored around the single affine application context on every result.
type Frame<S:Data,Ctx:Type,P:Type,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Frame{context:Ctx,declaration:Decl.Constructed<S,P,identity,project>}
def frame_result(~S:Data,~Ctx:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,result:Ctx & Output<S,P,O>) -> Frame<S,Ctx,P,identity,project> & Output<S,P,O>:
  match result:
    case (ctx,out): (Frame{ctx,declaration},out)
def retained_request(~S:Data,~Ctx:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:Ctx -> P -> D.Raw -> Ctx & O,frame:Frame<S,Ctx,P,identity,project>,input:Input<S,P>) -> Frame<S,Ctx,P,identity,project> & Output<S,P,O>:
  match frame input:
    case Frame{ctx,+declaration} Input{owner}: frame_result(~S,~Ctx,~P,~O,~identity,~project,declaration,split(~S,~Ctx,~P,~O,Gate.request(~S,~Ctx,~P,~O,~identity,~project,~admit,declaration,ctx,owner)))
def retained_grant(~S:Data,~Ctx:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:Ctx -> P -> D.Raw -> Ctx & O) -> Cap.OwnedRequest<Frame<S,Ctx,P,identity,project>,Input<S,P>,Output<S,P,O>>:
  Cap.OwnedRequest{frame => input => retained_request(~S,~Ctx,~P,~O,~identity,~project,~admit,frame,input)}
def returned(~S:Data,~Ctx:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,result:Frame<S,Ctx,P,identity,project> & Output<S,P,O>) -> Gate.Returned<Ctx,P,O>:
  match result:
    case (Frame{ctx,_},Admitted{value,canonical}): Gate.Admitted{ctx,value,canonical}
    case (Frame{ctx,_},ValidationRefused{owner,error}): Gate.ValidationRefused{ctx,owner,error}
# Application-authored body is universally quantified over H, while declaration,
# trusted admission and physical context are closed by schema provisioning.
def invoke(~S:Data,~Ctx:Type,~P:Type,~O:Type,~A:Type,~U:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:Ctx -> P -> D.Raw -> Ctx & O,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Input<S,P>,Output<S,P,O>> -> A -> H -> H & U,declaration:Decl.Constructed<S,P,identity,project>,ctx:Ctx,args:A) -> Frame<S,Ctx,P,identity,project> & U:
  Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Input<S,P>,Output<S,P,O>>),~A,~U,~body,~Frame<S,Ctx,P,identity,project>,~retained_grant(~S,~Ctx,~P,~O,~identity,~project,~admit),args,Frame{ctx,declaration})

def provide(~S:Data,~Ctx:Type,~P:Type,~O:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~admit:Ctx -> P -> D.Raw -> Ctx & O,declaration:Decl.Constructed<S,P,identity,project>,ctx:Ctx,owner:P) -> Gate.Returned<Ctx,P,O>:
  returned(~S,~Ctx,~P,~O,~identity,~project,invoke(~S,~Ctx,~P,~O,~Input<S,P>,~Output<S,P,O>,~identity,~project,~admit,~(H => cap => input => ctx => gameplay(~S,~P,~O,H,cap,input,ctx)),declaration,ctx,Input{owner}))
