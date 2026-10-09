import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode.bend as Decode
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

# A retained nominal declaration supplies admission. The schema author provides
# an actual reversible constructor, not an implicit inverse for arbitrary Type.
type Factory<-S:Data,-I:Type,-P:Type,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw,-incoming:I -> I & D.Raw,-build:I -> D.Raw -> Build.Construction<I,P,D.Error>> is Data:
  Factory{declaration:Decl.Constructed<S,P,identity,project>}
def factory(~S:Data,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>,declaration:Decl.Constructed<S,P,identity,project>) -> Factory<S,I,P,identity,project,incoming,build>:Factory{declaration}
def checked(~I:Type,~P:Type,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>,receipt:D.Receipt<I>) -> Build.Construction<I,P,D.Error>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}:Build.Invalid{owner,error}
    case D.Receipt{owner,D.Accepted{canonical}}:build(owner,canonical)
def construct(~S:Data,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>,factory:Factory<S,I,P,identity,project,incoming,build>,input:I) -> Build.Construction<I,P,D.Error>:
  match factory:
    case Factory{declaration}:checked(~I,~P,~build,Decode.decode_owner(~I,~incoming,Decl.codec(~S,~P,~identity,~project,declaration),input))
def request(~S:Data,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>,+factory:Factory<S,I,P,identity,project,incoming,build>,input:I) -> Factory<S,I,P,identity,project,incoming,build> & Build.Construction<I,P,D.Error>:
  (factory,construct(~S,~I,~P,~identity,~project,~incoming,~build,factory,input))
# Constructed output or exact refused raw owner crosses only an owned grant.
def grant(~S:Data,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>) -> Cap.OwnedRequest<Factory<S,I,P,identity,project,incoming,build>,I,Build.Construction<I,P,D.Error>>:
  Cap.OwnedRequest{factory => input => request(~S,~I,~P,~identity,~project,~incoming,~build,factory,input)}
def invoke(~S:Data,~I:Type,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,D.Error>,~A:Type,~Out:Type,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,I,Build.Construction<I,P,D.Error>> -> A -> H -> H & Out,factory:Factory<S,I,P,identity,project,incoming,build>,args:A) -> Factory<S,I,P,identity,project,incoming,build> & Out:
  Cap.invoke_owned(~(H => Cap.OwnedRequest<H,I,Build.Construction<I,P,D.Error>>),~A,~Out,~body,~Factory<S,I,P,identity,project,incoming,build>,~grant(~S,~I,~P,~identity,~project,~incoming,~build),args,factory)

# Custom constructors may fail with any Data error. Keep decoder and constructor
# errors distinct rather than coercing a host/business error into a codec path.
type Error<Custom:Data> is Data:Validation{error:D.Error} Constructor{error:Custom}
type FallibleFactory<-S:Data,-I:Type,-P:Type,-Custom:Data,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw,-incoming:I -> I & D.Raw,-build:I -> D.Raw -> Build.Construction<I,P,Custom>> is Data:
  FallibleFactory{declaration:Decl.Constructed<S,P,identity,project>}
def fallible_factory(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,declaration:Decl.Constructed<S,P,identity,project>) -> FallibleFactory<S,I,P,Custom,identity,project,incoming,build>:FallibleFactory{declaration}
def custom_result(~I:Type,~P:Type,~Custom:Data,result:Build.Construction<I,P,Custom>) -> Build.Construction<I,P,Error<Custom>>:
  match result:
    case Build.Invalid{owner,error}:Build.Invalid{owner,Constructor{error}}
    case Build.Constructed{owner,undo}:Build.Constructed{owner,undo}
def fallible_checked(~I:Type,~P:Type,~Custom:Data,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,receipt:D.Receipt<I>) -> Build.Construction<I,P,Error<Custom>>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}:Build.Invalid{owner,Validation{error}}
    case D.Receipt{owner,D.Accepted{canonical}}:custom_result(~I,~P,~Custom,build(owner,canonical))
def fallible_construct(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,factory:FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,input:I) -> Build.Construction<I,P,Error<Custom>>:
  match factory:
    case FallibleFactory{declaration}:fallible_checked(~I,~P,~Custom,~build,Decode.decode_owner(~I,~incoming,Decl.codec(~S,~P,~identity,~project,declaration),input))
def fallible_request(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>,+factory:FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,input:I) -> FallibleFactory<S,I,P,Custom,identity,project,incoming,build> & Build.Construction<I,P,Error<Custom>>:
  (factory,fallible_construct(~S,~I,~P,~Custom,~identity,~project,~incoming,~build,factory,input))
def fallible_grant(~S:Data,~I:Type,~P:Type,~Custom:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~incoming:I -> I & D.Raw,~build:I -> D.Raw -> Build.Construction<I,P,Custom>) -> Cap.OwnedRequest<FallibleFactory<S,I,P,Custom,identity,project,incoming,build>,I,Build.Construction<I,P,Error<Custom>>>:
  Cap.OwnedRequest{factory => input => fallible_request(~S,~I,~P,~Custom,~identity,~project,~incoming,~build,factory,input)}
